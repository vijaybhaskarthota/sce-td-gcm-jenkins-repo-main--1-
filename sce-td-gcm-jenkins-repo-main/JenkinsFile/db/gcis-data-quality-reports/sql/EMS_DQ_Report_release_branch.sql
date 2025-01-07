column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10


--DEF 8096
-- FOR EMS
SELECT '1.10:EMS Substn not having power XFMR(SUB INTERNAL):' AS Category, count(*) as count,case when count(*)>0 then
'8096' else 'Passed'   end as Comments FROM (
select distinct mrid from TCGACDS.gcm_SCIM_substation
where gcm_jobid = (SELECT jobid FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID = 'Y')
Minus
select distinct gcm_substation_id from TCGACDS.gcm_scim_powertransformer
where gcm_jobid = (SELECT jobid FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID = 'Y') )
-- FOR GESW
UNION

SELECT '1.11:GESW Substn not having  power XFMR(SUB INTERNAL):' AS Category, count(*) as count,case when count(*)>0 then
'8096' else 'Passed'   end as Comments FROM (
WITH MAX_JOB AS (SELECT MRID, MAX(GCM_JOBID) JOB_ID FROM TCGACDS.GCM_SCIM_SUBSTATION SUB JOIN TCGACDS.GCM_SUB_DIST_JOB_STATUS
JOB ON JOB.jobid= sub.gcm_jobid WHERE GCM_SOR = 'GESW' AND job.current_job<>'Y' AND job.SUCCESS='Y' GROUP BY MRID)
SELECT DISTINCT SUB.MRID FROM TCGACDS.GCM_SCIM_SUBSTATION SUB INNER JOIN MAX_JOB MJ ON MJ.MRID = SUB.MRID and MJ.JOB_ID = SUB.GCM_JOBID
JOIN TCGACDS.GCM_SCIM_SUBSTATIONIDENTIFIER ID ON ID.GCM_JOBID=SUB.GCM_JOBID AND ID.SUBSTATIONID=SUB.MRID
WHERE ID.NAMETYPE='SUBSTATION NUMBER' AND ID.NAME NOT IN(
SELECT NVL(EID.NAME,'x') FROM TCGACDS.GCM_SCIM_SUBSTATION ESUB
LEFT JOIN TCGACDS.GCM_SCIM_SUBSTATIONIDENTIFIER EID ON ESUB.MRID=EID.SUBSTATIONID AND EID.GCM_JOBID=ESUB.GCM_JOBID AND EID.NAMETYPE='SCE_SAP_ID'
WHERE ESUB.TYP IN ('B-BANK','DISTRIBUTION','NO_XFMR')
AND ESUB.GCM_JOBID=(SELECT JOBID FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID='Y'))
Minus
select distinct gcm_substation_id from TCGACDS.gcm_scim_powertransformer )

union
-- def 9003
SELECT '1.2:substn has conform load but no breaker(SUB INTERNAL):' AS Category, count(*) as count,case when count(*)>0 then
'9003' else 'Passed'   end as Comments FROM (
SELECT BR.NAME,BR.GCM_SUBSTATION_ID,BR.FUNCLOCDESC,BR.IDENTIFIERNAME FROM TCGACDS.GCM_V_SUB_I_BREAKER BR JOIN TCGACDS.ODS011_SAP_EQUIP FC ON BR.IDENTIFIERNAME=FC.EQUIPMENT
WHERE IDENTIFIERNAME IN
(SELECT EQUIPMENT FROM TCGACDS.ODS011_SAP_EQUIP SA JOIN TCGACDS.ODS010_SAP_FLOC FL ON SA.FUNCTIONAL_LOCATION=FL.FLOC_ID
WHERE
TRIM(SUBSTR(TRIM(SUBSTR(FL.FLOC_DESCRIPTION,1,INSTR(FL.FLOC_DESCRIPTION,'KV CB',-1,1))),1,
INSTR(TRIM(SUBSTR(FL.FLOC_DESCRIPTION,1,INSTR(FL.FLOC_DESCRIPTION,'KV CB',-1,1))),' ',-1,1)))
in (select NAME from TCGACDS.GCM_V_SUB_I_CONFORMLOAD
WHERE NAME IN (SELECT CIRCUIT_NAME FROM TCGACDS.CIRCUIT_HEAD)))
AND FC.SYSTEM_STATUS NOT LIKE '%DLFL%' AND FC.SYSTEM_STATUS NOT LIKE '%INAC%')

UNION

---def 9017
--THIRD FALLOUT 
SELECT '1.3:Records in analog table for which substn id is null:' AS Category, count(*) as count,case when count(*)>0 then
'9017' else 'Passed'   end as Comments FROM(
select distinct (mrid) from TCGACDS.GCM_SCIM_ANALOG WHERE GCM_SUBSTATION_ID IS NULL AND GCM_JOBID IN (SELECT GCM_JOBID FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID='Y'))
union

-- DEF 16006
SELECT '1.9:XFMRS missing identifier number:' AS Category, count(*) as count,case when count(*)>0 then
'16006' else 'Passed'  end as Comments from TCGACDS.GCM_SCIM_PowerTransformer  PT left join TCGACDS.GCM_SCIM_PowerTransformerIdentifier PTI 
on PT.mrid = PTI.powertransformerid where  PT.gcm_jobid in
(select jobid from TCGACDS.gcm_process_status where activejobid='Y') AND PTI.NAME IS NULL
union
--select* from TCGACDS.GCM_SCIM_PowerTransformerIdentifier


--DOUBT
--def 17009
SELECT '1.40:Breaker equip from EMS inactive in SAP:' AS Category, count(*) as count,case when count(*)>0 then
'17009' else 'Passed'   end as Comments FROM(
SELECT BR.NAME,BR.GCM_SUBSTATION_ID,BR.FUNCLOCDESC,BR.IDENTIFIERNAME FROM TCGACDS.GCM_V_SUB_I_BREAKER BR JOIN TCGACDS.ODS011_SAP_EQUIP FC ON BR.IDENTIFIERNAME=FC.EQUIPMENT
WHERE IDENTIFIERNAME IN
(SELECT EQUIPMENT FROM TCGACDS.ODS011_SAP_EQUIP SA JOIN TCGACDS.ODS010_SAP_FLOC FL ON SA.FUNCTIONAL_LOCATION=FL.FLOC_ID)
AND FC.SYSTEM_STATUS LIKE '%DLFL%' AND FC.SYSTEM_STATUS LIKE '%INAC%')
union
SELECT '1.41:XFMR  equip from EMS inactive in SAP:' AS Category, count(*) as count,case when count(*)>0 then
'17009' else 'Passed'   end as Comments FROM(
SELECT BR.NAME,BR.GCM_SUBSTATION_ID,BR.FUNCLOCDESC,BR.IDENTIFIERNAME FROM TCGACDS.GCM_V_SUB_I_POWER_TRNFMR BR JOIN TCGACDS.ODS011_SAP_EQUIP FC ON BR.IDENTIFIERNAME=FC.EQUIPMENT
WHERE IDENTIFIERNAME IN
(SELECT EQUIPMENT FROM TCGACDS.ODS011_SAP_EQUIP SA JOIN TCGACDS.ODS010_SAP_FLOC FL ON SA.FUNCTIONAL_LOCATION=FL.FLOC_ID)
AND FC.SYSTEM_STATUS LIKE '%DLFL%' AND FC.SYSTEM_STATUS LIKE '%INAC%')

union
--DEF 18257
--NO QUERIES FOUND
select'1.8:Abank and Bbank without Floc no(sub-heir):' AS Category, count(*) as count,case when count(*)>0 then
'18257' else 'Passed'   end as Comments from TCGACDS.GCM_SUB_HIER_fac_meta_final where NODE_CATEGORY not like 'CIRCUIT' and sub_type is null and SUB_NO is null



union

--DEF 18264
SELECT '1.5:Substn without SAP Floc in EMS_SUBSTN TABLE:' AS Category, count(*) as count,case when count(*)>0 then
'18264' else 'Passed'   end as Comments  from  TCGACDS.EMS_SUBSTATION WHERE SAP_FLOC IS NULL
union

-- DEF 18265

SELECT '1.6:Substn without substn type (sub-internal):' AS Category, count(*) as count,case when count(*)>0 then
'18265' else 'Passed'   end as Comments  from (
select mrid,name,typ,gcm_substation_id,gcm_sor,gcm_jobid from tcgacds.gcm_scim_substation where typ is null and gcm_jobid in
(select jobid from tcgacds.gcm_process_status where activejobid='Y')) 

union
--DEF 35071

SELECT '1.7:Circts  with EMS substn with primary volt>40:' AS Category, count(*) as count,case when count(*)>0 then
'35071' else 'Passed'   end as Comments  FROM TCGACDS.GCM_SUB_HIER_NODE$_FINAL WHERE NODE_ID IN (SELECT END_NODE_ID  FROM TCGACDS.GCM_SUB_HIER_LINK$_FINAL)
and TRIM('K' FROM(TRIM(BOTH 'V' FROM  PRIM_VOLTAGE)))>40.0 AND NODE_TYPE='CIRCUIT';
