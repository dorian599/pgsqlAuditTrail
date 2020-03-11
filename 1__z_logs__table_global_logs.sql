CREATE TABLE z_logs.global_logs (
  id int DEFAULT extract(epoch from now())::INT,
  schema_name text NOT NULL,
  table_name text NOT NULL,
  db_role text,
  action_datetime timestamp without time zone NOT NULL DEFAULT now(),
  action text NOT NULL,
  original_data text,
  new_data text,
  query_executed text,
  ui_user text,
  CONSTRAINT global_logs_action_check CHECK (action = ANY (ARRAY['I'::text, 'D'::text, 'U'::text]))
);
