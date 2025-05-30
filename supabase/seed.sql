-- Create test users and profiles

-- Test User 1
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'user1@example.com', '{"name":"Taylor Smith"}');

INSERT INTO public.profiles (user_id, name, avatar, hobbies)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'Taylor Smith', 'https://randomuser.me/api/portraits/women/1.jpg', ARRAY['Photography', 'Hiking', 'Coffee']);

INSERT INTO public.user_locations (user_id, latitude, longitude)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 37.5547, 126.9706);

-- Test User 2
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 'user2@example.com', '{"name":"Alex Johnson"}');

INSERT INTO public.profiles (user_id, name, avatar, hobbies)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 'Alex Johnson', 'https://randomuser.me/api/portraits/men/1.jpg', ARRAY['Hiking', 'Reading', 'Coffee']);

INSERT INTO public.user_locations (user_id, latitude, longitude)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 37.5547, 126.9706);

-- Generate more test users
DO $$
DECLARE
  user_id UUID;
  user_email TEXT;
  user_name TEXT;
  avatar_url TEXT;
  hobbies TEXT[];
  lat DOUBLE PRECISION;
  lng DOUBLE PRECISION;
  first_names TEXT[] := ARRAY['Jordan', 'Morgan', 'Casey', 'Riley', 'Jamie', 'Avery', 'Quinn', 'Blake', 'Cameron', 'Reese'];
  last_names TEXT[] := ARRAY['Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez'];
  all_hobbies TEXT[] := ARRAY['Photography', 'Hiking', 'Reading', 'Cooking', 'Painting', 'Yoga', 'Running', 'Cycling', 'Swimming', 'Gardening', 'Traveling', 'Music', 'Dancing', 'Writing', 'Coding', 'Gaming', 'Meditation', 'Coffee', 'Films', 'Climbing'];
  selected_hobbies TEXT[];
  i INTEGER;
  j INTEGER;
  random_first TEXT;
  random_last TEXT;
  is_male BOOLEAN;
  hobby_count INTEGER;
BEGIN
  FOR i IN 3..20 LOOP
    -- Generate UUID
    user_id := gen_random_uuid();
    
    -- Generate name
    random_first := first_names[1 + floor(random() * array_length(first_names, 1))::INT];
    random_last := last_names[1 + floor(random() * array_length(last_names, 1))::INT];
    user_name := random_first || ' ' || random_last;
    
    -- Generate email
    user_email := lower(random_first) || '.' || lower(random_last) || i::TEXT || '@example.com';
    
    -- Determine gender for avatar (simplified)
    is_male := random() > 0.5;
    
    -- Generate avatar URL
    avatar_url := 'https://randomuser.me/api/portraits/' || 
                  CASE WHEN is_male THEN 'men' ELSE 'women' END || 
                  '/' || (1 + floor(random() * 70)::INT)::TEXT || '.jpg';
    
    -- Generate random location near NYC
    lat := 37.5547 + (random() * 0.015 - 0.0075); -- 약 ±1.5km
    lng := 126.9706 + (random() * 0.015 - 0.0075); -- 약 ±1.5km
    
    -- Generate 2-4 random hobbies
    hobby_count := 2 + floor(random() * 3)::INT;
    selected_hobbies := ARRAY[]::TEXT[];
    
    FOR j IN 1..hobby_count LOOP
      -- Add a random hobby that's not already selected
      LOOP
        -- Pick a random hobby
        random_first := all_hobbies[1 + floor(random() * array_length(all_hobbies, 1))::INT];
        
        -- Check if it's not already in selected_hobbies
        IF NOT random_first = ANY(selected_hobbies) THEN
          selected_hobbies := selected_hobbies || random_first;
          EXIT;
        END IF;
      END LOOP;
    END LOOP;
    
    -- Insert user
    INSERT INTO auth.users (id, email, raw_user_meta_data)
    VALUES (user_id, user_email, json_build_object('name', user_name));
    
    -- Insert profile
    INSERT INTO public.profiles (user_id, name, avatar, hobbies)
    VALUES (user_id, user_name, avatar_url, selected_hobbies);
    
    -- Insert location
    INSERT INTO public.user_locations (user_id, latitude, longitude)
    VALUES (user_id, lat, lng);
    
  END LOOP;
END;
$$;
