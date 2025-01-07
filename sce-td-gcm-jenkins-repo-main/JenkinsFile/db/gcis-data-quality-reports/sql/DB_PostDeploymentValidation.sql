WITH INVALID_OBJECT_REC AS (SELECT OBJECT_NAME,OBJECT_TYPE,STATUS FROM ALL_OBJECTS where owner in ('TCGACDS','ECMRW') AND STATUS='INVALID')
SELECT 'All DB Objects Compiled and Valid 'as comments, case when count(1)>0 then 'FAILED' else 'PASSED' end as status, count(1) as count 
FROM INVALID_OBJECT_REC ;