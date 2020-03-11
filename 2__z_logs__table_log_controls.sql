CREATE TABLE z_logs.log_controls(
  id          bigserial PRIMARY KEY NOT NULL,
  schema_name character varying(100),
  table_name  character varying(100),
  log         smallint DEFAULT 0,
  CONSTRAINT log_controls_log_check CHECK (log = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6, 7]))
);
