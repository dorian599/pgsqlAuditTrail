CREATE OR REPLACE FUNCTION z_logs.f_globallogs()
  RETURNS trigger AS
$BODY$
DECLARE
    v_old_data TEXT;
    v_new_data TEXT;
    v_ui_user_name TEXT;
BEGIN

    v_ui_user_name := z_logs.current_user_id();

    IF (TG_OP::TEXT = 'UPDATE') THEN
        v_old_data := ROW(OLD.*); -- Old Data
        v_new_data := ROW(NEW.*); -- New Data
        INSERT INTO z_logs.global_logs (schema_name,table_name,db_role,action,original_data,new_data,query_executed,ui_user)
        VALUES (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data,v_new_data, current_query(),v_ui_user_name);
        RETURN NEW;

    ELSIF (TG_OP::TEXT = 'DELETE') THEN
        v_old_data := ROW(OLD.*); -- Old Data
        INSERT INTO z_logs.global_logs (schema_name,table_name,db_role,action,original_data,query_executed,ui_user)
        VALUES (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data, current_query(),v_ui_user_name);
        RETURN OLD;

    ELSIF (TG_OP::TEXT = 'INSERT') THEN
        v_new_data := ROW(NEW.*); -- new Data
        INSERT INTO z_logs.global_logs (schema_name,table_name,db_role,action,new_data,query_executed,ui_user)
        VALUES (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_new_data, current_query(),v_ui_user_name);
        RETURN NEW;

    ELSE
        RAISE WARNING '[Z_LOGS.IF_MODIFIED_FUNC] - Other action occurred: %, at %',TG_OP,now();
        RETURN NULL;

    END IF;

EXCEPTION
    WHEN data_exception THEN
        RAISE WARNING '[Z_LOGS.IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
        RETURN NULL;

    WHEN unique_violation THEN
        RAISE WARNING '[Z_LOGS.IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
        RETURN NULL;

    WHEN OTHERS THEN
        RAISE WARNING '[Z_LOGS.IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
        RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
