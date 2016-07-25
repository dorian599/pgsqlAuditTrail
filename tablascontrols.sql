
CREATE TABLE k_logs.tablascontrols
(
  id bigserial NOT NULL,
  esquema character varying(100),
  nombretabla character varying(100),
  log smallint DEFAULT 0,
  CONSTRAINT tablascontrols_pkey PRIMARY KEY (id ),
  CONSTRAINT tablascontrols_log_check CHECK (log = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6, 7]))
);


CREATE OR REPLACE FUNCTION k_logs.f_audit_control()
  RETURNS trigger AS
$BODY$

DECLARE

    c_t_01           CURSOR FOR SELECT esquema, nombretabla, log FROM k_logs.tablascontrols WHERE nombretabla != 'tablascontrols' ;

    v_t_nombre       VARCHAR(100) ;
    v_t_esquema      VARCHAR(100) ;
    v_t_log          int ;
    v_t_condiciones  VARCHAR(100) ;

BEGIN

    IF (TG_OP = 'UPDATE') THEN

        OPEN c_t_01 ;
            LOOP
                FETCH c_t_01 INTO v_t_esquema, v_t_nombre, v_t_log ;
                    EXIT WHEN NOT FOUND ;

                    IF ( v_t_log != 0 ) THEN

                        begin

                            CASE v_t_log
                                 WHEN 1 THEN
                                     v_t_condiciones := 'AFTER UPDATE' ;
                                 WHEN 2 THEN
                                     v_t_condiciones := 'AFTER INSERT' ;
                                 WHEN 3 THEN
                                     v_t_condiciones := 'AFTER DELETE' ;
                                 WHEN 4 THEN
                                     v_t_condiciones := 'AFTER INSERT OR UPDATE' ;
                                 WHEN 5 THEN
                                     v_t_condiciones := 'AFTER UPDATE OR DELETE' ;
                                 WHEN 6 THEN
                                     v_t_condiciones := 'AFTER INSERT OR DELETE' ;
                                 WHEN 7 THEN
                                     v_t_condiciones := 'AFTER INSERT OR UPDATE OR DELETE' ;
                                 --1  AFTER UPDATE
                                 --2  AFTER INSERT
                                 --3  AFTER DELETE
                                 --4  AFTER INSERT OR UPDATE
                                 --5  AFTER UPDATE OR DELETE
                                 --6  AFTER INSERT OR DELETE
                                 --7  AFTER INSERT OR UPDATE OR DELETE
                            END CASE ;

                            EXECUTE ( 'DROP TRIGGER aaudit_globlal_log ON '||v_t_esquema||'.'||v_t_nombre );
                            EXECUTE ( 'CREATE TRIGGER aaudit_globlal_log '||v_t_condiciones||' ON '||v_t_esquema||'.'||v_t_nombre||' FOR EACH ROW EXECUTE PROCEDURE k_logs.f_globallogs()' ) ;

                            EXCEPTION WHEN OTHERS THEN
                                EXECUTE ( 'CREATE TRIGGER aaudit_globlal_log '||v_t_condiciones||' ON '||v_t_esquema||'.'||v_t_nombre||' FOR EACH ROW EXECUTE PROCEDURE k_logs.f_globallogs()' ) ;

                        end;

                    ELSE

                        begin

                            EXECUTE ( 'ALTER TABLE '||v_t_esquema||'.'||v_t_nombre||' DISABLE TRIGGER aaudit_globlal_log' ) ;

                            EXCEPTION WHEN OTHERS THEN
                                EXECUTE ( 'CREATE TRIGGER aaudit_globlal_log AFTER DELETE ON '||v_t_esquema||'.'||v_t_nombre||' FOR EACH ROW EXECUTE PROCEDURE k_logs.f_globallogs()' ) ;
                                EXECUTE ( 'ALTER TABLE '||v_t_esquema||'.'||v_t_nombre||' DISABLE TRIGGER aaudit_globlal_log' ) ;
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



  CREATE TRIGGER t_audit_control
  AFTER INSERT OR UPDATE
  ON k_logs.tablascontrols
  FOR EACH ROW
  EXECUTE PROCEDURE k_logs.f_audit_control()
