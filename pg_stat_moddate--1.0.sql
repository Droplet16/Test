-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pg_stat_moddate" to load this file. \quit

CREATE TABLE IF NOT EXISTS gwi_stat_moddate(
    recdate timestamp DEFAULT now(),
    moddate timestamp DEFAULT now(),
    user_name name DEFAULT current_user,
    user_ip inet DEFAULT inet_client_addr(),
    obj_type text,
    obj_name text,
    obj_schema text,
    CONSTRAINT pk_gwi_stat_moddate PRIMARY KEY(obj_type, obj_name, obj_schema)    
);

--pg_creation_time_on_create
CREATE FUNCTION gwi_note_event_ddl_command_end() RETURNS event_trigger AS $$
DECLARE 
    r RECORD; 
    robj_name text;
BEGIN
    --RAISE NOTICE 'gwi_note_event_ddl_command_end() called';
    
    FOR r IN SELECT * FROM pg_event_trigger_ddl_commands() LOOP
        --RAISE NOTICE 'caught % end event on % of type % in schema %', r.command_tag, r.object_identity, r.object_type, r.schema_name;
        IF r.object_type in ('table', 'view', 'materialized view', 'function') THEN
            -- materialized views have schema in objname, function have schema in arguments types
            robj_name := replace(replace(r.object_identity, r.schema_name || '.', ''),'pg_catalog.','');
            INSERT INTO public.gwi_stat_moddate (obj_type,obj_name,obj_schema) VALUES (r.object_type,robj_name,r.schema_name) 
                ON CONFLICT (obj_type,obj_name,obj_schema) DO UPDATE SET moddate = now(), user_name = current_user, user_ip = inet_client_addr();
        END IF;
    END LOOP;
    EXCEPTION WHEN OTHERS THEN 
        RAISE NOTICE '% %', SQLERRM, SQLSTATE;    
END;
$$
LANGUAGE plpgsql;

CREATE FUNCTION gwi_note_event_sql_drop() RETURNS event_trigger AS $$
DECLARE 
    r RECORD; 
    robj_name text;
BEGIN
    --RAISE NOTICE 'gwi_note_event_sql_drop() called';
    
    FOR r IN SELECT * FROM pg_event_trigger_dropped_objects () LOOP
        --RAISE NOTICE 'caught % drop event on % of type % in schema %', tg_tag, r.object_identity, r.object_type, r.schema_name;
        IF r.object_type in ('table', 'view', 'materialized view', 'function') THEN
            -- materialized views have schema in objname, function have schema in arguments types
            robj_name := replace(replace(r.object_identity, r.schema_name || '.', ''),'pg_catalog.','');
            DELETE FROM public.gwi_stat_moddate where (obj_type,obj_name,obj_schema) = (r.object_type,robj_name,r.schema_name);
        END IF;
    END LOOP;
    EXCEPTION WHEN OTHERS THEN 
        RAISE NOTICE '% %', SQLERRM, SQLSTATE;    
END;
$$
LANGUAGE plpgsql;

CREATE EVENT TRIGGER tr_gwi_note_event_ddl_command_end
  ON ddl_command_end WHEN TAG IN ('ALTER TABLE', 'CREATE TABLE', 'CREATE TABLE AS', 'ALTER VIEW', 'CREATE VIEW', 'ALTER MATERIALIZED VIEW', 'CREATE MATERIALIZED VIEW', 'ALTER FUNCTION', 'CREATE FUNCTION' )
  EXECUTE PROCEDURE gwi_note_event_ddl_command_end();

CREATE EVENT TRIGGER tr_gwi_note_event_sql_drop
  ON sql_drop WHEN TAG IN ('DROP TABLE', 'DROP VIEW', 'DROP MATERIALIZED VIEW', 'DROP FUNCTION')
  EXECUTE PROCEDURE gwi_note_event_sql_drop();
          
        