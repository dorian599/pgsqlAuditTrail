CREATE FUNCTION z_logs.current_user_id()
RETURNS TEXT AS $$
  SELECT authentication.current_user_id()::TEXT
$$ LANGUAGE SQL STABLE;
