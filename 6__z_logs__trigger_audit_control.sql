CREATE TRIGGER t_audit_control
AFTER UPDATE
ON z_logs.log_controls
FOR EACH ROW
EXECUTE PROCEDURE z_logs.f_audit_control()
