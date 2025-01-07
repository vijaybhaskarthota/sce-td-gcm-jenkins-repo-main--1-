-- This report provides stats about parallel,twin parallel and non twin parallel power transformers.
-- Last Modified date: 10/30/2023
----------------------------------------------------------------------------------------------
SET LINESIZE 200
SET FEEDBACK OFF
column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10 


select '1.10Power transformer at source' as category, COUNT(distinct POWERTRANSFORMER_ID) as COUNT, 'Info' as Comments
from TCGACDS.EMS_POWER_TRNFMR

UNION

Select '1.11 Ground Bank transformer at source' as category, COUNT(distinct DISCONNECTOR_ID) as COUNT, 
'Info' as Comments from TCGACDS.EMS_DISCONNECTOR where identifiedobject_Name like '%GROUND BANK PSE%'

UNION

select  '1.12Power transformer at Final' as category, COUNT(distinct MRID) as COUNT, 'Info' as Comments
 from TCGACDS.GCM_SCIM_POWERTRANSFORMER where GCM_JOBID = 
(select jobid from TCGACDS.gcm_process_status where activejobid = 'Y') 

UNION

select '1.20Single instance power transformer' as category, COUNT(*) as COUNT, 'Info' as 
Comments from TCGACDS.GCM_SCIM_POWERTRANSFORMER  where TRANSFORMERBANKID in (
select TRANSFORMERBANKID from (
select TRANSFORMERBANKID, COUNT(MRID) from TCGACDS.GCM_SCIM_POWERTRANSFORMER where GCM_JOBID = 
(select jobid from TCGACDS.gcm_process_status where activejobid = 'Y') GROUP BY TRANSFORMERBANKID HAVING COUNT(MRID)=1 ))
and  GCM_JOBID =  (select jobid from TCGACDS.gcm_process_status where activejobid = 'Y')

UNION
select '1.30Parallel power transformer' as category, COUNT(*) as COUNT, 'Info' as 
Comments from TCGACDS.GCM_SCIM_POWERTRANSFORMER  where TRANSFORMERBANKID in (
select TRANSFORMERBANKID from (
select TRANSFORMERBANKID, COUNT(MRID) from TCGACDS.GCM_SCIM_POWERTRANSFORMER where GCM_JOBID = 
(select jobid from TCGACDS.gcm_process_status where activejobid = 'Y') GROUP BY TRANSFORMERBANKID HAVING COUNT(MRID)>1 ))
and GCM_JOBID = (select jobid from TCGACDS.gcm_process_status where activejobid = 'Y') 

UNION

select '1.31Parallel power transformer at same position' as category, COUNT(*) as COUNT, 'Info' as 
Comments from TCGACDS.GCM_SCIM_POWERTRANSFORMER  where TRANSFORMERBANKID in (
select TRANSFORMERBANKID from (
select TRANSFORMERBANKID, COUNT(MRID) from TCGACDS.GCM_SCIM_POWERTRANSFORMER where GCM_JOBID = 
(select jobid from TCGACDS.gcm_process_status where activejobid = 'Y') 
and TRANSFORMERBANKID NOT LIKE '%-%'
GROUP BY TRANSFORMERBANKID HAVING COUNT(MRID)>1 ))
and GCM_JOBID = (select jobid from TCGACDS.gcm_process_status where activejobid = 'Y')

UNION

select '1.32Parallel power transformer at diff position' as category, COUNT(*) as COUNT, 'Info' as 
Comments from TCGACDS.GCM_SCIM_POWERTRANSFORMER  where TRANSFORMERBANKID in (
select TRANSFORMERBANKID from (
select TRANSFORMERBANKID, COUNT(MRID) from TCGACDS.GCM_SCIM_POWERTRANSFORMER where GCM_JOBID = 
(select jobid from TCGACDS.gcm_process_status where activejobid = 'Y') 
and TRANSFORMERBANKID  LIKE '%-%' GROUP BY TRANSFORMERBANKID HAVING COUNT(MRID)>1 ))
and GCM_JOBID = (select jobid from TCGACDS.gcm_process_status where activejobid = 'Y') ;



