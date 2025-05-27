-- Create meetings table
CREATE TABLE IF NOT EXISTS public.meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  user_b UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('requested', 'coordinating', 'confirmed', 'completed', 'cancelled')),
  meeting_point JSONB,
  user_a_pin JSONB,
  user_b_pin JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS on meetings
ALTER TABLE public.meetings ENABLE ROW LEVEL SECURITY;

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS meetings_user_a_idx ON public.meetings(user_a);
CREATE INDEX IF NOT EXISTS meetings_user_b_idx ON public.meetings(user_b);
CREATE INDEX IF NOT EXISTS meetings_status_idx ON public.meetings(status);

-- RLS Policies

-- Users can read meetings they are part of
CREATE POLICY "Users can view their own meetings" 
  ON public.meetings 
  FOR SELECT 
  USING (auth.uid() = user_a OR auth.uid() = user_b);

-- Users can create meetings where they are user_a
CREATE POLICY "Users can create meetings as initiator" 
  ON public.meetings 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_a);

-- Users can update meetings they are part of
CREATE POLICY "Users can update their own meetings" 
  ON public.meetings 
  FOR UPDATE 
  USING (auth.uid() = user_a OR auth.uid() = user_b);
