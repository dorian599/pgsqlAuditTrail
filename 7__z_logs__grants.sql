--
-- Grant USAGE over the schela "z_logs" to the DB roles if applicable
--
GRANT USAGE ON SCHEMA z_logs TO <<ROLE_NAME>>;


--
-- Grant INSERT over the table "z_logs.global_logs" to the DB roles to allow then to insert the Audit Trail
--
GRANT INSERT ON z_logs.global_logs TO <<ROLE_NAME>>;
