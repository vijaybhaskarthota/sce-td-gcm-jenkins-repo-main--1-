SET LINESIZE 180
SET FEEDBACK OFF

column CHANGELIST_JOB_ID heading "JOBID" Format a40
column CHANGE_LIST_PROCESSED_TIME heading "CHANGE_LIST_PROCESSED_TIME" Format a40
column COUNT_IN_PAYLOAD heading "COUNT_IN_PAYLOAD" Format 999999999
column COUNT_IN_DELTA_TABLE heading "COUNT_IN_DELTA_TABLE" Format 999999999
column DELTA_PAYLOAD_PROCESSED heading "DELTA_PAYLOAD_PROCESSED" Format 999999999


SELECT CHANGELIST_JOB_ID,max(CHANGE_LIST_PROCESSED_TIME) CHANGE_LIST_PROCESSED_TIME,max(COUNT_IN_PAYLOAD) COUNT_IN_PAYLOAD,
count(1) COUNT_IN_DELTA_TABLE, SUM(CASE WHEN D.PROCESS_STATUS='PROCESSED' THEN 1 ELSE 0 END) DELTA_PAYLOAD_PROCESSED
FROM 
(SELECT DER.CHANGELIST_JOB_ID,DER.CHANGE_LIST_PROCESSED_TIME,count( distinct DER_LIST.mRID) COUNT_IN_PAYLOAD
FROM   TCGACDS.GCM_DER_DM_LIST_JOB_DTLS DER,
       XMLTABLE('/DERProjectListInfo/Project'
         PASSING XMLTYPE(replace(DER.XML_OUTPUT,'m:',''))
         COLUMNS 
           mRID     VARCHAR2(500)  PATH 'mRID'
         ) DER_LIST  where DER.PROCESS_STATUS in ('MAIN_SERVICE_UNPROCESSED','CHANGELIST_PROCESSED') and DER.XML_OUTPUT is not null
GROUP BY DER.CHANGELIST_JOB_ID,CHANGE_LIST_PROCESSED_TIME) L, TCGACDS.GCM_DER_DM_LIST_DELTA D
where D.JOB_ID=L.CHANGELIST_JOB_ID
Group BY CHANGELIST_JOB_ID ORDER BY CHANGE_LIST_PROCESSED_TIME DESC
FETCH NEXT 10 ROWS ONLY;