-- Create conversation_topics table
CREATE TABLE IF NOT EXISTS public.conversation_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic TEXT NOT NULL,
  description TEXT NOT NULL,
  tags TEXT[] NOT NULL,
  color TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS on conversation_topics
ALTER TABLE public.conversation_topics ENABLE ROW LEVEL SECURITY;

-- Everyone can read conversation topics
CREATE POLICY "Conversation topics are viewable by everyone" 
  ON public.conversation_topics 
  FOR SELECT 
  USING (true);

-- Seed data for conversation topics
INSERT INTO public.conversation_topics (topic, description, tags, color)
VALUES 
  ('Photography techniques for urban landscapes', 'Discuss your favorite camera settings for city photography and how to capture the essence of urban life.', ARRAY['Photography', 'Travel'], '#3b82f6'),
  ('Recent hiking trails you''ve explored', 'Share experiences from your recent outdoor adventures and recommendations for scenic routes.', ARRAY['Hiking', 'Outdoors', 'Travel'], '#14b8a6'),
  ('Favorite coffee brewing methods', 'Compare notes on different ways to prepare coffee and discuss your preferred beans and roasts.', ARRAY['Coffee', 'Cooking'], '#ef4444'),
  ('Book recommendations based on genre', 'Exchange book suggestions and discuss recent reads that made an impact on you.', ARRAY['Reading', 'Books'], '#8b5cf6'),
  ('Creative cooking hacks', 'Share your favorite cooking shortcuts and techniques that save time without sacrificing flavor.', ARRAY['Cooking', 'Food'], '#f59e0b'),
  ('Fitness routines and motivation', 'Talk about workout routines and strategies for staying motivated and consistent.', ARRAY['Fitness', 'Running', 'Yoga'], '#84cc16'),
  ('Travel destinations on your bucket list', 'Discuss dream travel destinations and exchange travel planning tips.', ARRAY['Travel', 'Adventure'], '#06b6d4'),
  ('Photography gear and equipment', 'Compare notes on cameras, lenses, and accessories that have improved your photography.', ARRAY['Photography', 'Technology'], '#3b82f6'),
  ('Sustainable living practices', 'Share environmentally friendly habits and products that have made a positive impact.', ARRAY['Environment', 'Gardening'], '#10b981'),
  ('Favorite indie music discoveries', 'Recommend lesser-known artists and bands that deserve more recognition.', ARRAY['Music', 'Art'], '#8b5cf6'),
  ('Art exhibitions and installations', 'Discuss recent art experiences and exhibitions that left an impression.', ARRAY['Art', 'Museums', 'Culture'], '#ec4899'),
  ('Movie recommendations by decade', 'Share your favorite films from different decades and why they stand the test of time.', ARRAY['Films', 'Entertainment'], '#6366f1'),
  ('Coding projects and programming languages', 'Talk about interesting coding projects and languages you''re learning or using.', ARRAY['Coding', 'Technology'], '#0ea5e9'),
  ('Board games and strategy games', 'Discuss favorite board games, card games, and tabletop gaming experiences.', ARRAY['Gaming', 'Entertainment'], '#f43f5e'),
  ('Local hidden gems and restaurants', 'Share lesser-known spots in your city that visitors might not discover on their own.', ARRAY['Food', 'Travel', 'Local'], '#f97316');
