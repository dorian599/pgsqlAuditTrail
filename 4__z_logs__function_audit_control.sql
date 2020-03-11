CREATE OR REPLACE FUNCTION z_logs.f_audit_control()
  RETURNS trigger AS
$BODY$

DECLARE

    c_t_01         CURSOR FOR SELECT schema_name, table_name, log FROM z_logs.log_controls WHERE table_name != 'log_controls' ;

    v_t_name       VARCHAR(100) ;
    v_t_schema     VARCHAR(100) ;
    v_t_log        int ;
    v_t_conditions VARCHAR(100) ;

BEGIN

    IF (TG_OP = 'UPDATE') THEN

        OPEN c_t_01 ;
            LOOP
                FETCH c_t_01 INTO v_t_schema, v_t_name, v_t_log ;
                    EXIT WHEN NOT FOUND ;

                    IF ( v_t_log != 0 ) THEN

                        begin

                            CASE v_t_log
                                 WHEN 1 THEN
                                     v_t_conditions := 'AFTER UPDATE' ;
                                 WHEN 2 THEN
                                     v_t_conditions := 'AFTER INSERT' ;
                                 WHEN 3 THEN
                                     v_t_conditions := 'AFTER DELETE' ;
                                 WHEN 4 THEN
                                     v_t_conditions := 'AFTER INSERT OR UPDATE' ;
                                 WHEN 5 THEN
                                     v_t_conditions := 'AFTER UPDATE OR DELETE' ;
                                 WHEN 6 THEN
                                     v_t_conditions := 'AFTER INSERT OR DELETE' ;
                                 WHEN 7 THEN
                                     v_t_conditions := 'AFTER INSERT OR UPDATE OR DELETE' ;
                                 --1  AFTER UPDATE
                                 --2  AFTER INSERT
                                 --3  AFTER DELETE
                                 --4  AFTER INSERT OR UPDATE
                                 --5  AFTER UPDATE OR DELETE
                                 --6  AFTER INSERT OR DELETE
                                 --7  AFTER INSERT OR UPDATE OR DELETE
                            END CASE ;

                            EXECUTE ( 'DROP TRIGGER aaudit_globlal_log ON '||v_t_schema||'.'||v_t_name );
                            EXECUTE ( 'CREATE TRIGGER aaudit_globlal_log '||v_t_conditions||' ON '||v_t_schema||'.'||v_t_name||' FOR EACH ROW EXECUTE PROCEDURE z_logs.f_globallogs()' ) ;

                            EXCEPTION WHEN OTHERS THEN
                                EXECUTE ( 'CREATE TRIGGER aaudit_globlal_log '||v_t_conditions||' ON '||v_t_schema||'.'||v_t_name||' FOR EACH ROW EXECUTE PROCEDURE z_logs.f_globallogs()' ) ;

                        end;

                    ELSE

                        begin

                            EXECUTE ( 'ALTER TABLE '||v_t_schema||'.'||v_t_name||' DISABLE TRIGGER aaudit_globlal_log' ) ;

                            EXCEPTION WHEN OTHERS THEN
                                EXECUTE ( 'CREATE TRIGGER aaudit_globlal_log AFTER DELETE ON '||v_t_schema||'.'||v_t_name||' FOR EACH ROW EXECUTE PROCEDURE z_logs.f_globallogs()' ) ;
                                EXECUTE ( 'ALTER TABLE '||v_t_schema||'.'||v_t_name||' DISABLE TRIGGER aaudit_globlal_log' ) ;
                        end;

                    END IF ;

            END LOOP ;
        CLOSE c_t_01 ;
    END IF;
RETURN NULL ;

END ;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
