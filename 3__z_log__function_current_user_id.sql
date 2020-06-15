CREATE OR REPLACE FUNCTION z_logs.current_user_id()
RETURNS TEXT AS $$
  --SELECT authentication.current_user_id()::TEXT
  SELECT 'noUserId'::TEXT;
$$ LANGUAGE SQL STABLE;
