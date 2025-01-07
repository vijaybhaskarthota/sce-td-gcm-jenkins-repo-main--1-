-- This report validates M2G Data quality from source to final and explains the reasons for different fallout
-- Last Modified date: 9/15/2021
----------------------------------------------------------------------------------------------

column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10
----circuit having transformer and unit with re-installed status (removed and instaleld)

select '1.Circuit count having transformer replaced#' as Category, count (distinct FEEDER_MRID) as COUNT, 
'Info' as Comments  from TCGACDS.GCM_SCIM_DIST_FEEDER_DS WHERE FEEDER_CIRCUITID IN (
select DISTINCT TRANSFORMERBANK_CIRCUITID from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS 
WHERE TRANSFORMERBANK_STATUS_VLU<>'REMOVED'  and
TRANSFORMERBANK_MRID IN (select TRANSFORMERBANK_MRID from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS where TRANSFORMERBANK_STATUS_VLU='REMOVED')  UNION
select DISTINCT TRANSFORMERBANK_CIRCUITID from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS 
WHERE POWERTRANSFOMER_STATUS_VLU<>'REMOVED' and
  TRANSFORMERBANK_MRID IN (select TRANSFORMERBANK_MRID from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS where POWERTRANSFOMER_STATUS_VLU='REMOVED')
)

UNION
select '2.Transbank with replaced and multi statuses' as category, count(TRANSFORMERBANK_MRID ),'Info' as Comments
from (
Select DISTINCT TRANSFORMERBANK_CIRCUITID,TRANSFORMERBANK_MRID  from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS 
WHERE TRANSFORMERBANK_STATUS_VLU<>'REMOVED'  and
  TRANSFORMERBANK_MRID IN (select TRANSFORMERBANK_MRID from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS where TRANSFORMERBANK_STATUS_VLU='REMOVED')
    )
    
UNION

select '3.TransUnit with replaced and multi statuses' as category, count(POWERTRANSFOMER_MRID ),'Info' as Comments
from (
select DISTINCT TRANSFORMERBANK_CIRCUITID,POWERTRANSFOMER_MRID  from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS 
WHERE POWERTRANSFOMER_STATUS_VLU<>'REMOVED'  and
  POWERTRANSFOMER_MRID IN (select POWERTRANSFOMER_MRID from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS where POWERTRANSFOMER_STATUS_VLU='REMOVED')
)
 UNION
 
---- Transformer unit having multiple status installed and updated ----
select '4.TransUnit w/Multi statuses installed_updated' as category, count(POWERTRANSFOMER_MRID ), CASE WHEN COUNT(*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments from
(
select DISTINCT TRANSFORMERBANK_CIRCUITID,POWERTRANSFOMER_MRID  from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS 
WHERE POWERTRANSFOMER_STATUS_VLU NOT IN ('REMOVED', 'UPDATED')  and
  POWERTRANSFOMER_MRID IN (select POWERTRANSFOMER_MRID from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS where POWERTRANSFOMER_STATUS_VLU='UPDATED')
  )

UNION

select '5.TransUnit w/different circuitid wrt TransBank' as category, count(POWERTRANSFOMER_MRID ),
CASE WHEN COUNT(*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
from (
SELECT distinct powertransfomer_MRID, transformerbank_circuitid,powertransfomer_circuitid, POWERTRANSFOMER_STATUS_VLU, TRANSFOMERBANK_STATUS_VLU
FROM TCGACDS.gcm_scim_dist_structxfm_ds 
WHERE transformerbank_circuitid <> powertransfomer_circuitid )

UNION

select '6.TransBank w/different circuitid wrt TransUnit' as category, count(transformerbank_MRID ) as COUNT,
CASE WHEN COUNT(*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
from (
SELECT distinct transformerbank_MRID, transformerbank_circuitid,powertransfomer_circuitid,
POWERTRANSFOMER_STATUS_VLU, TRANSFOMERBANK_STATUS_VLU
FROM TCGACDS.gcm_scim_dist_structxfm_ds 
WHERE transformerbank_circuitid <> powertransfomer_circuitid
)

UNION

SELECT '7.0-TransBank total count in SCIM' as Category, COUNT (DISTINCT MRID) as COUNT,
'Info' as Comments
FROM(select DISTINCT MRID from TCGACDS.GCM_V_M2G_TRANSFORMER_scim )

UNION

SELECT '7.1-TransBank not linked to circuit in SCIM' as Category, COUNT (DISTINCT MRID) as COUNT,
CASE WHEN COUNT (*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments
FROM(select DISTINCT MRID from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS  NULL )

UNION

SELECT '7.2-TransBank  linked to circuit in SCIM' as Category, COUNT (DISTINCT MRID) as COUNT,
'Info' as Comments
FROM(select DISTINCT MRID from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS NOT NULL )


UNION

SELECT '7.3-TransBank total in M2G SCIM' as Category, COUNT(*) AS COUNT,
'Info' as Comments
FROM (
SELECT  distinct transformerbank_MRID  
FROM TCGACDS.gcm_scim_dist_structxfm_ds where TRANSFOMERBANK_STATUS_VLU <>'REMOVED' 
)

UNION

SELECT '7.4-TransBank at source, not in M2G Final' as Category, COUNT(DISTINCT MRID) as COUNT,
CASE WHEN COUNT (*) > 0 THEN 'NeedReview'
ELSE 'Passed' END as Comments
FROM( select MRID  from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE
MRID NOT in (
SELECT transformerbank_MRID FROM TCGACDS.gcm_scim_dist_structxfm_ds  )--647955, 279
)
UNION

select '7.41-TransBank in M2G, not in source' as Category, COUNT(DISTINCT TRANSFORMERBANKIDENTIFIER_NAME) as COUNT,
CASE WHEN COUNT(DISTINCT TRANSFORMERBANKIDENTIFIER_NAME) > 0 THEN 'NeedReview'
ELSE 'Passed' END as Comments
from (
select distinct TRANSFORMERBANKIDENTIFIER_NAME,TRANSFORMERBANK_TYP from TCGACDS.GCM_SCIM_DIST_STRUCTXFM_DS ds
where TRANSFOMERBANK_STATUS_VLU<>'REMOVED' and not exists 
(select 1 from TCGACDS.GCM_V_M2G_TRANSFORMER_scim sc where sc.mrid =ds.TRANSFORMERBANK_MRID)
)

UNION

SELECT '7.5- TransBank without TransUnits' as Category, COUNT (DISTINCT transformerbank_MRID) as COUNT,
CASE WHEN COUNT (DISTINCT transformerbank_MRID) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
FROM(
SELECT transformerbank_MRID FROM TCGACDS.gcm_scim_dist_structxfm_ds WHERE POWERTRANSFOMER_MRID IS NULL )

UNION

SELECT '7.6-TransBank active, without KVA in M2G SCIM' as Category, Count(*) AS COUNT,
CASE WHEN COUNT (*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
FROM (
SELECT  distinct transformerbank_MRID 
FROM TCGACDS.gcm_scim_dist_structxfm_ds where POWERTRANSFOMER_CIRCUITID  IS NOT NULL and 
TRANSFOMERBANK_STATUS_VLU <>'REMOVED' and 
TRANSFORMERBANK_KVASIZE in ('0', 'NULL', 'UNKNOWN') 
)

UNION
SELECT '7.61-TransBank removed status, without KVA in M2G' as Category, Count(*) AS COUNT,
CASE WHEN COUNT (*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
FROM (
SELECT  distinct transformerbank_MRID 
FROM TCGACDS.gcm_scim_dist_structxfm_ds where POWERTRANSFOMER_CIRCUITID  IS NOT NULL and 
TRANSFOMERBANK_STATUS_VLU ='REMOVED' and 
TRANSFORMERBANK_KVASIZE in ('0', 'NULL', 'UNKNOWN') 
)

UNION 

SELECT '7.7-TransBank active w/KVA,SerialNum,UsagePoint' as Category, COUNT(*) AS COUNT,
'Info' as Comments
FROM (
SELECT  distinct transformerbank_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where POWERTRANSFOMER_CIRCUITID  IS NOT NULL and 
TRANSFOMERBANK_STATUS_VLU <>'REMOVED' and
TRANSFORMERBANK_KVASIZE NOT in ('0', 'NULL', 'UNKNOWN')
AND POWERTRANSFOMERASSET_SERIALNUMBER is NOT null
AND TRANSFORMERBANK_MRID IN ( select TRANSFORMERBANK_MRID from TCGACDS.GCM_V_SCIM_DIST_USAGEPOINT_DS)
)

UNION

SELECT '7.8- TransBank removed w/KVA, SerialNum and UsagePoint' as Category, COUNT(*) AS COUNT,
'Info' as Comments
FROM (
SELECT  distinct transformerbank_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where POWERTRANSFOMER_CIRCUITID  IS NOT NULL and 
TRANSFOMERBANK_STATUS_VLU = 'REMOVED' and
TRANSFORMERBANK_KVASIZE NOT in ('0', 'NULL', 'UNKNOWN')
AND POWERTRANSFOMERASSET_SERIALNUMBER is NOT null
AND TRANSFORMERBANK_MRID IN ( select TRANSFORMERBANK_MRID from TCGACDS.GCM_V_SCIM_DIST_USAGEPOINT_DS)
)

UNION

select '8.0-STR total count at source' as Category, STR_COUNT AS COUNT,
'Info' as Comments FROM (
select count (DISTINCT STRUCTURE_NUMBER) as STR_COUNT from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS NOT NULL  )

UNION

select '8.1-STR count in M2G FINAL' as Category, STR_COUNT AS COUNT,
'Info' as Comments FROM (
SELECT COUNT(DISTINCT STRUCTURE_MRID) as STR_COUNT  FROM TCGACDS.gcm_scim_dist_structxfm_ds
) 

UNION

--Count of distinct structure ---
SELECT '8.11-STR active in M2G SCIM' as category, COUNT (STRUCTURE_MRID),
'Info' as Comments
FROM(
SELECT   distinct STRUCTURE_MRID  
FROM TCGACDS.gcm_scim_dist_structxfm_ds
where STRUCTURE_STATUS_VLU <>'REMOVED' 
and TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'
)

UNION
--Count of distinct structure ---
SELECT '8.2-STR removed state in M2G SCIM' as category, COUNT (STRUCTURE_MRID),
'Info' as Comments
FROM(
SELECT   distinct STRUCTURE_MRID  
FROM TCGACDS.gcm_scim_dist_structxfm_ds
where STRUCTURE_STATUS_VLU ='REMOVED' 
and TRANSFOMERBANK_STATUS_VLU  ='REMOVED' 
)


UNION

SELECT '8.3-STR count with TB KVA 0, NULL or Unknown' as Category, COUNT(*) AS COUNT,
CASE WHEN COUNT (*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
FROM (
SELECT distinct STRUCTURE_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where POWERTRANSFOMER_CIRCUITID  IS NOT NULL and 
TRANSFORMERBANK_KVASIZE in ('0', 'NULL', 'UNKNOWN')
and TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'
and STRUCTURE_STATUS_VLU  <> 'REMOVED'
)

UNION
SELECT '8.31-STR count with TRU KVA null or unknown' as Category, COUNT(*) AS COUNT,
CASE WHEN COUNT (*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
FROM (
SELECT distinct STRUCTURE_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where POWERTRANSFOMER_CIRCUITID  IS NOT NULL and 
POWERTRANSFOMERASSETINFO_KVASIZE  in ('NULL', 'UNKNOWN')
and TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'
and POWERTRANSFOMER_STATUS_VLU <>'REMOVED'
and STRUCTURE_STATUS_VLU  <> 'REMOVED'
)

UNION

SELECT '8.32-STR count with TRU KVA as 0' as Category, COUNT(*) AS COUNT,
CASE WHEN COUNT (*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
FROM (
SELECT *
FROM TCGACDS.gcm_scim_dist_structxfm_ds where 
POWERTRANSFOMERASSETINFO_KVASIZE = '0'
and TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'
and POWERTRANSFOMER_STATUS_VLU <>'REMOVED'
and STRUCTURE_STATUS_VLU  <> 'REMOVED'
)

UNION

SELECT '8.4-STR count with TRU SerialNumber Null' as Category, COUNT(*) AS COUNT,
CASE WHEN COUNT (*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
FROM (
SELECT distinct STRUCTURE_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where POWERTRANSFOMER_CIRCUITID  IS NOT NULL 
---and  TRANSFORMERBANK_KVASIZE in ('0', 'NULL', 'UNKNOWN')
AND POWERTRANSFOMERASSET_SERIALNUMBER is null
and TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'
and POWERTRANSFOMER_STATUS_VLU <>'REMOVED'
and STRUCTURE_STATUS_VLU  <> 'REMOVED'
)


UNION

SELECT '8.5-STR count having TransBank with no usagepoint' as Category, COUNT(*) AS COUNT,
'Info' as Comments
FROM (

SELECT  distinct ds.STRUCTURE_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds ds 
LEFT JOIN  (select distinct TRANSFORMERBANK_MRID from TCGACDS.GCM_V_SCIM_DIST_USAGEPOINT_DS) UP  
ON UP.TRANSFORMERBANK_MRID =ds.TRANSFORMERBANK_MRID---646153
where UP.TRANSFORMERBANK_MRID is NULL ---566922, 80193
and ds.TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'---80017

)

UNION

SELECT '8.6-STR with invalid TRU KVA, serialNum or usagepoint' as Category, COUNT(DISTINCT STRUCTURE_MRID) AS COUNT,
'Info' as Comments from (
SELECT distinct STRUCTURE_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where 
POWERTRANSFOMERASSET_SERIALNUMBER is null
and TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'
and POWERTRANSFOMER_STATUS_VLU <>'REMOVED'
and STRUCTURE_STATUS_VLU  <> 'REMOVED' union
SELECT  distinct ds.STRUCTURE_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds ds 
LEFT JOIN  (select distinct TRANSFORMERBANK_MRID from TCGACDS.GCM_V_SCIM_DIST_USAGEPOINT_DS) UP  
ON UP.TRANSFORMERBANK_MRID =ds.TRANSFORMERBANK_MRID
where UP.TRANSFORMERBANK_MRID is NULL 
and ds.TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'
and ds.POWERTRANSFOMER_STATUS_VLU <>'REMOVED'
and ds.STRUCTURE_STATUS_VLU  <> 'REMOVED'
union

SELECT distinct STRUCTURE_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where
POWERTRANSFOMERASSETINFO_KVASIZE in ( 'NULL', 'UNKNOWN')
and TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'
and STRUCTURE_STATUS_VLU  <> 'REMOVED'
and POWERTRANSFOMER_STATUS_VLU <>'REMOVED'
)


UNION

SELECT '8.7-STR  w/active TRU valid KVA,SerialNum,Usagepoint' as Category, COUNT(*) AS COUNT,
'Info' as Comments
FROM (

SELECT  distinct ds.STRUCTURE_MRID,STRUCTURE_STATUS_VLU
FROM TCGACDS.gcm_scim_dist_structxfm_ds ds 
INNER JOIN  (select TRANSFORMERBANK_MRID from TCGACDS.GCM_V_SCIM_DIST_USAGEPOINT_DS where METER_MRID IS NOT NULL group by TRANSFORMERBANK_MRID) UP  
ON UP.TRANSFORMERBANK_MRID =ds.TRANSFORMERBANK_MRID
where ds.POWERTRANSFOMERASSETINFO_KVASIZE NOT in ('NULL', 'UNKNOWN') 
and ds.POWERTRANSFOMERASSET_SERIALNUMBER is NOT null
and TRANSFOMERBANK_STATUS_VLU  <> 'REMOVED'
and STRUCTURE_STATUS_VLU  <> 'REMOVED'
and POWERTRANSFOMER_STATUS_VLU <>'REMOVED'

)

UNION
Select '8.80-STR w/HighFire exists in source,missing in M2G' as category, Count(DISTINCT STRUCTURE_NUMBER) as count,
CASE WHEN COUNT(DISTINCT STRUCTURE_NUMBER) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments
 from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS M2G inner join TCGACDS.GCM_STRUCTURE_DETAILS Map3d
on M2G.STRUCTURE_NUMBR=Map3d.STRUCTURE_NUMBER where LOCATION_SUBTYPE is Null and HIGH_FIRE_AREA is null
and STRUCTURE_NUMBER in (
select FLOC_ID from (select REPLACE(FLOC_ID,'OH-') as FLOC_ID from tcgacds.ods012_floc_chars 
where CHAR_NAME='E_HIGH_FIRE_AREA'
and CHAR_VALUE is not null 
UNION select REPLACE(FLOC_ID,'UG-') as FLOC_ID from tcgacds.ods012_floc_chars where CHAR_NAME='E_HIGH_FIRE_AREA' and CHAR_VALUE is not null)
)
UNION

Select '8.81-STR w/HighFire missing in source and M2G' as category, Count(DISTINCT STRUCTURE_NUMBER) as count,
CASE WHEN COUNT(DISTINCT STRUCTURE_NUMBER) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
 from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS M2G inner join TCGACDS.GCM_STRUCTURE_DETAILS Map3d
on M2G.STRUCTURE_NUMBR=Map3d.STRUCTURE_NUMBER where 
LOCATION_SUBTYPE is Null and 

HIGH_FIRE_AREA is null
and STRUCTURE_NUMBER in (
select FLOC_ID from (select REPLACE(FLOC_ID,'OH-') as FLOC_ID from tcgacds.ods012_floc_chars 
where CHAR_NAME='E_HIGH_FIRE_AREA'
and CHAR_VALUE is  null 
UNION select REPLACE(FLOC_ID,'UG-') as FLOC_ID from tcgacds.ods012_floc_chars where CHAR_NAME='E_HIGH_FIRE_AREA' and CHAR_VALUE is  null)
)
UNION
select '8.820-STR w/climate zone null in M2G' as category, count(DISTINCT M2G.STRUCTURE_MRID) as count,'Info' as comments
from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS M2G where STRUCTURE_STATUS_VLU <>'REMOVED' and LOCATION_CLIMATEZONE is Null
UNION
select '8.821-STR w/climate zone null as STR in map3D' as category, count(DISTINCT M2G.STRUCTURE_MRID) as count,'DQ Issue' as comments
from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS M2G where STRUCTURE_STATUS_VLU <>'REMOVED' and LOCATION_CLIMATEZONE is Null and
STRUCTURE_NUMBR NOT in ( select STRUCTURE_NUMBER from TCGACDS.GCM_STRUCTURE_DETAILS Map3d )
UNION
select '8.822-STR presents in map3D and climate zone null' as category, count(DISTINCT M2G.STRUCTURE_MRID) as count,'DQ Issue' as comments
from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS M2G where STRUCTURE_STATUS_VLU <>'REMOVED' and LOCATION_CLIMATEZONE is Null and
STRUCTURE_NUMBR  in ( select STRUCTURE_NUMBER from TCGACDS.GCM_STRUCTURE_DETAILS Map3d )
UNION
select '8.823-STR w/climate zone in STR detials and M2G' as category, count(DISTINCT M2G.STRUCTURE_MRID) as count,'DQ Issue' as comments
from TCGACDS.GCM_V_SCIM_DIST_STRUCTXFM_DS M2G where STRUCTURE_STATUS_VLU <>'REMOVED' and LOCATION_CLIMATEZONE is Null and
STRUCTURE_NUMBR  in ( select STRUCTURE_NUMBER from TCGACDS.GCM_STRUCTURE_DETAILS Map3d where CLIMATE_ZONE is null )

UNION
-------- str belongs to multiple circuits ----- 331/359
SELECT '8.9-STR belongs to multiple circuit' as Category, COUNT(*) as COUNT,
CASE WHEN COUNT(*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
from
(
SELECT  count(distinct transformerbank_circuitid), STRUCTURE_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds group by STRUCTURE_MRID having count(distinct transformerbank_circuitid) >1

)

--Count of distinct transformer unit---
UNION

SELECT '9.0-TransUnit Active in M2G SCIM' as Category, COUNT (*),
'Info' as Comments
FROM (
SELECT  distinct powertransfomer_MRID, POWERTRANSFOMER_STATUS_VLU
FROM TCGACDS.gcm_scim_dist_structxfm_ds where  powertransfomer_MRID is not null 
and POWERTRANSFOMER_STATUS_VLU <>'REMOVED' 
)

UNION
SELECT '9.1-TransUnit without serialNumber in M2G SCIM' as Category, COUNT (powertransfomer_MRID) as COUNT,
CASE WHEN COUNT(powertransfomer_MRID) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
FROM (
SELECT  distinct powertransfomer_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where POWERTRANSFOMERASSET_SERIALNUMBER is null and powertransfomer_MRID is not null
and POWERTRANSFOMER_STATUS_VLU <>'REMOVED'

)

-----SELECT * FROM TCGACDS.gcm_scim_dist_structxfm_ds---POWERTRANSFOMERASSETINFO_KVASIZE, TRANSFORMERBANK_KVASIZE

UNION
----transformer unit belongs to multiple structure---1 /2
SELECT '9.4-TransUnit belongs to multiple structure' as Category, COUNT(*) as COUNT,
CASE WHEN COUNT(*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
from (
SELECT count(distinct STRUCTURE_MRID) as CNT, powertransfomer_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds WHERE powertransfomer_MRID is NOT NULL
group by powertransfomer_MRID having count(distinct STRUCTURE_MRID) >1 
)

UNION
---transformer unit in multiple circuit---

SELECT '9.5-.TransUnit belongs to multiple circuit' as Category, COUNT(*) as COUNT,
CASE WHEN COUNT(*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
from
(
SELECT  count(distinct powertransfomer_circuitid), powertransfomer_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where TRANSFOMERBANK_STATUS_VLU <> 'REMOVED'
group by powertransfomer_MRID having count(distinct powertransfomer_circuitid) >1
)
UNION
--------transformer bank belongs to multiple structure---3/3
SELECT '9.6-TransBank belongs to multiple structure' as Category, COUNT(*) as COUNT,
CASE WHEN COUNT(*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
from
(

SELECT  count(distinct STRUCTURE_MRID) as CNT, transformerbank_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds group by transformerbank_MRID having count(distinct STRUCTURE_MRID) >1
)
UNION
--------- transformer bank belongs to multiple circuit-------1 /27

SELECT '9.61-TransBank belongs to multiple circuit' as Category, COUNT(*) as COUNT,
CASE WHEN COUNT(*) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
from
(
SELECT  count(distinct transformerbank_circuitid), transformerbank_MRID
FROM TCGACDS.gcm_scim_dist_structxfm_ds where TRANSFOMERBANK_STATUS_VLU <> 'REMOVED'
group by transformerbank_MRID having count(distinct transformerbank_circuitid) >1
)
UNION
select '9.7-TransBank duplicate M3I_Object_ID' as category, count(M3I_OBJECT_ID ) as count, 
CASE WHEN COUNT(M3I_OBJECT_ID) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments from 
(
select M3I_OBJECT_ID, count(ID) from TCGACDS.OH_TRANSFORMER group by M3I_OBJECT_ID having count (ID)>1
union
select M3I_OBJECT_ID, count(ID) from TCGACDS.UG_TRANSFORMER group by M3I_OBJECT_ID having count (ID)>1
UNION
select M3I_OBJECT_ID, count(ID) from TCGACDS.IBANK group by M3I_OBJECT_ID having count (ID)>1
)
UNION
select '9.8-TransUnit Duplicate M3I_Object_ID' as category, count(M3I_OBJECT_ID ) as count, 
CASE WHEN COUNT(M3I_OBJECT_ID) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments from 

(
select M3I_OBJECT_ID, count(ID)from TCGACDS.OH_TRANSFORMER_UNIT group by M3I_OBJECT_ID having count (ID)>1
union
select M3I_OBJECT_ID, count(ID) from TCGACDS.UG_TRANSFORMER_UNIT group by M3I_OBJECT_ID having count (ID)>1
UNION
select M3I_OBJECT_ID, count(ID) from TCGACDS.GROUND_BANK group by M3I_OBJECT_ID having count (ID)>1
)

UNION

Select '9.930-UsagePoint total in ODS030' as category, count(distinct ISVC_NUM) as count,
'Info' as Comments  from TCGACDS.ods030_meter_dtls ods
where XFMR_BANK_ID is not null
UNION
Select '9.931-UsagePoint in ODS030 with TB null' as category, count(distinct ISVC_NUM) as count, 
'DQ Issue' as Comments  from TCGACDS.ods030_meter_dtls ods 
where MAPPER_ACTION_FLAG <> 'REMOVE' and XFMR_BANK_ID is  null
UNION
Select '9.932-UsagePoint active in ODS030' as category, count(distinct ISVC_NUM) as count,
'Info' as Comments   from TCGACDS.ods030_meter_dtls ods
where XFMR_BANK_ID is not null and  MAPPER_ACTION_FLAG <> 'REMOVE'
UNION
Select '9.933-UsagePoint Active, electrical in ODS030' as category, count(distinct ISVC_NUM) as count,
'Info' as Comments   from TCGACDS.ods030_meter_dtls ods
where XFMR_BANK_ID is not null and  MAPPER_ACTION_FLAG <>'REMOVE' and SERVICE_TYPE_CODE='E'
UNION
Select '9.940-UsagePoint in ODS030 not in M2G' as category, count(distinct ISVC_NUM) as count, 
'NeedReview' as Comments   from TCGACDS.ods030_meter_dtls ods
where XFMR_BANK_ID is not null and  MAPPER_ACTION_FLAG <>'REMOVE' and SERVICE_TYPE_CODE='E' and ISVC_NUM NOT IN
(select usagepoint_number from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm )

UNION

Select '9.941-UsagePoint w/XMFR id not in GESW ' as category, count(distinct ISVC_NUM) as count, 
'TCON Issue' as Comments  from TCGACDS.ods030_meter_dtls ods
where XFMR_BANK_ID is not null and  MAPPER_ACTION_FLAG <>'REMOVE' and SERVICE_TYPE_CODE='E' and ISVC_NUM NOT IN
(select usagepoint_number from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm )
and XFMR_BANK_ID NOT IN ( select ID from TCGACDS.gcm_v_m2g_transformer_scim )

UNION

Select '9.942-UsagePoint w/XMFR id in GESW, missing in M2G ' as category, count(distinct ISVC_NUM) as count, 
'NeedReview' as Comments  from TCGACDS.ods030_meter_dtls ods
where XFMR_BANK_ID is not null and  MAPPER_ACTION_FLAG <>'REMOVE' and SERVICE_TYPE_CODE='E' and ISVC_NUM NOT IN
(select usagepoint_number from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm )
and XFMR_BANK_ID  IN ( select ID from TCGACDS.gcm_v_m2g_transformer_scim )

UNION

select '9.950-UsagePoint w/STR mismatch in ODS030 and M2G' as category, count(distinct isvc_num ) as count, 
'Info' as comments from ( 
Select ods.isvc_num,ods.serv_connect_id AS ODS_030_STR, gcm.STRUCTURE_MRID AS GCM_UP_STR,
ods.xfmr_bank_id AS ODS_XFMR_BANK_ID from TCGACDS.ods030_meter_dtls ods inner join TCGACDS.gcm_scim_dist_usagepoint_ds gcm
on ods.isvc_num = gcm.usagepoint_number
and ods.MAPPER_ACTION_FLAG <>'REMOVE'
and ods.service_type_code ='E'
and gcm.usagepoint_number is not null 
and ods.serv_connect_id <> gcm.STRUCTURE_MRID
)
UNION
select '9.951-UsagePoint w/diff STR as duplicate MTR/XMFR' as category, count(USAGEPOINT_NUMBER ) as count, 
CASE WHEN COUNT(USAGEPOINT_NUMBER) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from (
select usagepoint_number, count(distinct TRANSFORMERBANK_MRID)  from TCGACDS.gcm_scim_dist_usagepoint_ds where usagepoint_number in (
select isvc_num from (
select  ISVC_NUM, count(distinct MTR_DEVICE_NUM) from TCGACDS.ods030_meter_dtls ods where service_type_code ='E' and
MAPPER_ACTION_FLAG <>'REMOVE'
group by ISVC_NUM having count(distinct MTR_DEVICE_NUM)>1 ) ) group by usagepoint_number having count(distinct TRANSFORMERBANK_MRID) >1 
)
UNION
select '9.952-UsagePoint active w/more than 1 meter' as Category, count (distinct ISVC_NUM) as count, 'DQ Issue' as Comments from (
select  ISVC_NUM, count(distinct MTR_DEVICE_NUM) from TCGACDS.ods030_meter_dtls ods where service_type_code ='E' and
MAPPER_ACTION_FLAG <>'REMOVE'
group by ISVC_NUM having count(distinct MTR_DEVICE_NUM)>1 )

UNION
select '9.953-Meter Active in ODS030' as category, count(distinct MTR_DEVICE_NUM) as count, 'Info' as Comments from TCGACDS.ods030_meter_dtls ods where service_type_code ='E' and
MAPPER_ACTION_FLAG <>'REMOVE'

UNION
select '9.954-Meter Active in M2G SCIM' as Category, count(distinct METER_MRID) as count, 'Info' as Comments from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm;