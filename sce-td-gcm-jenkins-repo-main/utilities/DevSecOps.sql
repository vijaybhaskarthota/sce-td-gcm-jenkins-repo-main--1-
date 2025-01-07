-- Retrieve Deployment History from TCGACDS Schema
SELECT * FROM GCM_VERSION_HISTORY ORDER BY DATE_TIME DESC
-- Retrieve Open Cursor count for GCM ID's
SELECT  B.NAME, A.VALUE,S.USERNAME,S.SID,S.OSUSER,S.MACHINE,S.Logon_time,S.SERIAL#
  FROM V$SESSTAT A,V$STATNAME B,V$SESSION S
  WHERE A.STATISTIC# = B.STATISTIC#
    AND S.SID        = A.SID
    AND B.NAME       = 'opened cursors current'
    AND (USERNAME in ('ECMRW','TCGACDS') or USERNAME like '%GCM%' or USERNAME like '%FME%')
    --AND USERNAME='GCMSTDPUSR'
 ORDER BY A.VALUE DESC;
-- Retrieve all Java Exceptions
select * from GCM2020_JAVA_EXCEPTION order by DATED DESC
-- Retrieve all DB Exceptions
select * from GCM2020_EXCEPTION order by DATE_TIME_STAMP DESC
