
CREATE TABLE k_logs.global_logs
(
  id bigserial NOT NULL,
  schema_name text NOT NULL,
  table_name text NOT NULL,
  user_name text,
  action_tstamp timestamp without time zone NOT NULL DEFAULT now(),
  action text NOT NULL,
  original_data text,
  new_data text,
  query text,
  CONSTRAINT global_logs_pkey PRIMARY KEY (id ),
  CONSTRAINT global_logs_action_check CHECK (action = ANY (ARRAY['I'::text, 'D'::text, 'U'::text]))
);



CREATE OR REPLACE FUNCTION k_logs.f_globallogs()
  RETURNS trigger AS
$BODY$
DECLARE
    v_old_data TEXT;
    v_new_data TEXT;
BEGIN

    IF (TG_OP = 'UPDATE') THEN
        v_old_data := ROW(OLD.*); -- Old Data
        v_new_data := ROW(NEW.*); -- New Data
        INSERT INTO k_logs.global_logs (schema_name,table_name,user_name,action,original_data,new_data,query) 
        VALUES (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data,v_new_data, current_query());
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        v_old_data := ROW(OLD.*); -- Old Data
        INSERT INTO k_logs.global_logs (schema_name,table_name,user_name,action,original_data,query)
        VALUES (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data, current_query());
        RETURN OLD;

    ELSIF (TG_OP = 'INSERT') THEN
        v_new_data := ROW(NEW.*); -- new Data
        INSERT INTO k_logs.global_logs (schema_name,table_name,user_name,action,new_data,query)
        VALUES (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_new_data, current_query());
        RETURN NEW;

    ELSE
        RAISE WARNING '[K_LOGS.IF_MODIFIED_FUNC] - Other action occurred: %, at %',TG_OP,now();
        RETURN NULL;

    END IF;
 
EXCEPTION
    WHEN data_exception THEN
        RAISE WARNING '[K_LOGS.IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
        RETURN NULL;

    WHEN unique_violation THEN
        RAISE WARNING '[K_LOGS.IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
        RETURN NULL;
        
    WHEN OTHERS THEN
        RAISE WARNING '[K_LOGS.IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
        RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
