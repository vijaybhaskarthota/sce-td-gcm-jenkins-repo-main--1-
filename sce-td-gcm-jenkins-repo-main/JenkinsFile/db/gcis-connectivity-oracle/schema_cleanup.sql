
/**********************************************************************
/* 
   !WARNING ,DO NOT RUN THIS !!!!!!!!!!!!!
   The following anonymous block would drop all the user objects from 
   the TCGACDS schema.
   Usage : Schema clean up for fresh deployment    
/**********************************************************************/
SET SERVEROUTPUT ON SIZE UNLIMITED 
DECLARE
sqlstmnt VARCHAR2(500);
dbname VARCHAR2(100);
BEGIN
Select Global_name INTO dbname from Global_name;
--check that the DB is l986
IF dbname = 'PL986' THEN
         
    --fetching from user objects view 

    FOR ROW IN ( SELECT 'drop '||object_type||' '|| object_name || '' AS QUERY FROM user_objects 

    WHERE object_type IN 
    --objects that needs to be dropped from the schema 
    ('INDEX',
    'TRIGGER',
    'PACKAGE BODY',
    'PACKAGE',
    'PROCEDURE',
    'FUNCTION',
    'SEQUENCE',
    'MATERIALIZED VIEW',
    'TYPE',
    'TABLE'
    ,'VIEW'
    ) 

    AND object_name NOT LIKE 'SYS_%'
        )
    LOOP

        BEGIN
            EXECUTE IMMEDIATE 'truncate table drop_schema_log_output';
             INSERT INTO drop_schema_log_output (log_message) VALUES ('Script Execution start :    '||ROW.QUERY );
             EXECUTE IMMEDIATE ROW.QUERY;
             INSERT INTO drop_schema_log_output (log_message) VALUES ('Script Execution Success :    '||ROW.QUERY );
        EXCEPTION
            WHEN OTHERS THEN
             INSERT INTO drop_schema_log_output (log_message) VALUES ('An error was encountered while running- '|| ROW.QUERY||SQLCODE||' -ERROR- '||sqlerrm);
        END;
    END LOOP;
ELSE 
             INSERT INTO drop_schema_log_output (log_message) VALUES ('Not in L986 ,Script not executed');
END IF;
COMMIT;
END;
