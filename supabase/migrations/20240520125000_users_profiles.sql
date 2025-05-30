-- Create auth schema if not exists (this should be automatic in Supabase)
CREATE SCHEMA IF NOT EXISTS auth;

-- Enable RLS
--ALTER TABLE IF EXISTS auth.users ENABLE ROW LEVEL SECURITY;

-- Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  avatar TEXT,
  hobbies TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create user_locations table for tracking user positions
CREATE TABLE IF NOT EXISTS public.user_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS on user_locations
ALTER TABLE public.user_locations ENABLE ROW LEVEL SECURITY;

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS profiles_user_id_idx ON public.profiles(user_id);
CREATE INDEX IF NOT EXISTS user_locations_user_id_idx ON public.user_locations(user_id);

-- Create function to get nearby users
CREATE OR REPLACE FUNCTION public.get_nearby_users(
  user_lat DOUBLE PRECISION,
  user_lng DOUBLE PRECISION,
  radius_km DOUBLE PRECISION
) RETURNS SETOF json AS $$
DECLARE
  earth_radius_km CONSTANT DOUBLE PRECISION := 6371;
  distance DOUBLE PRECISION;
  user_record RECORD;
  result json;
BEGIN
  FOR user_record IN
    SELECT 
      p.id,
      p.name,
      p.avatar,
      p.hobbies,
      l.latitude,
      l.longitude,
      l.updated_at
    FROM 
      public.profiles p
    JOIN 
      public.user_locations l ON p.user_id = l.user_id
  LOOP
    -- Calculate distance using Haversine formula
    distance := 2 * earth_radius_km * asin(sqrt(
      power(sin((radians(user_lat) - radians(user_record.latitude)) / 2), 2) +
      cos(radians(user_lat)) * cos(radians(user_record.latitude)) *
      power(sin((radians(user_lng) - radians(user_record.longitude)) / 2), 2)
    ));
    
    -- Only include users within the specified radius
    IF distance <= radius_km THEN
      result := json_build_object(
        'id', user_record.id,
        'name', user_record.name,
        'distance', round(distance::numeric, 1),
        'hobbies', user_record.hobbies,
        'avatar', user_record.avatar,
        'last_seen', user_record.updated_at
      );
      RETURN NEXT result;
    END IF;
  END LOOP;
  
  RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS Policies

-- Profiles policies
-- Users can read any profile
CREATE POLICY "Profiles are viewable by everyone" 
  ON public.profiles 
  FOR SELECT 
  USING (true);

-- Users can only update their own profiles
CREATE POLICY "Users can update their own profiles" 
  ON public.profiles 
  FOR UPDATE 
  USING (auth.uid() = user_id);

-- Users can only insert their own profiles
CREATE POLICY "Users can insert their own profiles" 
  ON public.profiles 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- User locations policies
-- Users can read any location
CREATE POLICY "User locations are viewable by everyone" 
  ON public.user_locations 
  FOR SELECT 
  USING (true);

-- Users can only update their own location
CREATE POLICY "Users can update their own location" 
  ON public.user_locations 
  FOR UPDATE 
  USING (auth.uid() = user_id);

-- Users can only insert their own location
CREATE POLICY "Users can insert their own location" 
  ON public.user_locations 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);
