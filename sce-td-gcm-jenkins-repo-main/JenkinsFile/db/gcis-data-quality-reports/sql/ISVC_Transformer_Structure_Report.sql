SET LINESIZE 180
SET FEEDBACK OFF
column Category heading "Category" Format a51
column COUNT heading "COUNT" Format 99999999999999999999
column Comments heading "Comment" Format a10

alter session set current_schema=tcgacds;
select '1.0-Total Active ISVC Recvd from TCONN' as category, count(distinct ISVC_NUM) as count, 
'Info' as Comments from (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and A.MAPPER_ACTION_FLAG <> 'REMOVE' AND A.SERVICE_TYPE_CODE='E'
UNION
select '1.1-Total Active ISVC published by GCM' as Category, count(distinct USAGEPOINT_NUMBER) as count, 
'Info' as Comments from  TCGACDS.gcm_scim_dist_usagepoint_ds gcm where USAGEPOINT_NUMBER in (
select distinct ISVC_NUM from (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and a.MAPPER_ACTION_FLAG <> 'REMOVE' AND a.SERVICE_TYPE_CODE = 'E')
UNION
Select '1.2-Total Fallout' as category, count(distinct ISVC_NUM) as count, 
'GCM fallout' as Comments  from (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and a.XFMR_BANK_ID is not null and  a.MAPPER_ACTION_FLAG <>'REMOVE' and a.SERVICE_TYPE_CODE='E' and a.ISVC_NUM NOT IN
(select usagepoint_number from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm )
and XFMR_BANK_ID NOT IN ( select ID from TCGACDS.gcm_v_m2g_transformer_scim )
UNION
Select '1.2.1-TCON ISVC w/XMFR id not in GESW ' as category, count(distinct ISVC_NUM) as count, 
'Fallout due to TCONN-GESW Issue' as Comments  from (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and a.XFMR_BANK_ID is not null and  a.MAPPER_ACTION_FLAG <>'REMOVE' and a.SERVICE_TYPE_CODE='E' and a.ISVC_NUM NOT IN
(select usagepoint_number from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm )
and XFMR_BANK_ID NOT IN ( select ID from TCGACDS.gcm_v_m2g_transformer_scim )
UNION
Select '1.2.2-Total ISVC_FALLOUT' as category, count(distinct ISVC_NUM) as count, 'FALLOUT' as comments
from (select distinct to_char(ISVC_NUM) as ISVC_NUM from (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and A.MAPPER_ACTION_FLAG <> 'REMOVE' AND A.SERVICE_TYPE_CODE='E' and a.xfmr_bank_id is not null and  a.xfmr_bank_id in(select id from TCGACDS.gcm_v_m2g_transformer_scim)
minus
select distinct(USAGEPOINT_NUMBER )as ISVC_NUM from  TCGACDS.GCM_SCIM_DIST_USAGEPOINT_DS)
UNION
--rephrase the category comments
select '1.2.3-ODS300_SYNC_TRANS table has not populated with correct time' as category, 
count(distinct ISVC_NUM) as count,'FALLOUT FOR TRANSACTION TABLE' as comments 
from (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and A.MAPPER_ACTION_FLAG <> 'REMOVE' AND A.SERVICE_TYPE_CODE='E' 
and A.isvc_num not in (select USAGEPOINT_NUMBER from tcgacds.GCM_SCIM_DIST_USAGEPOINT_DS) 
and exists (select 1 from tcgacds.GCM_V_M2G_TRANSFORMER_SCIM where id=xfmr_bank_id)
UNION
select '1.2.4-Total ISVC w/transformer null' as category, count(distinct ISVC_NUM) as count, 
'Info' as Comments from TCGACDS.ods030_meter_dtls ods where service_type_code ='E' and
MAPPER_ACTION_FLAG <>'REMOVE' AND XFMR_BANK_ID IS NULL
UNION
SELECT '2.0-Total TransBank count in Base Table' as Category, COUNT (DISTINCT MRID) as COUNT,
'Info' as Comments
FROM(select DISTINCT MRID from TCGACDS.GCM_V_M2G_TRANSFORMER_scim )
UNION
SELECT '2.1-Transformer published by GCM' as Category, COUNT(*) AS COUNT,
'Info' as Comments
FROM (
SELECT  distinct transformerbank_MRID  
FROM TCGACDS.gcm_scim_dist_structxfm_ds where TRANSFOMERBANK_STATUS_VLU <>'REMOVED' 
)
UNION
SELECT '2.2-Transformer not published by GCM' as Category, COUNT(*) AS COUNT,
'Fallout' as Comments
FROM (
select DISTINCT MRID from TCGACDS.GCM_V_M2G_TRANSFORMER_scim
MINUS
SELECT  distinct transformerbank_MRID  
FROM TCGACDS.gcm_scim_dist_structxfm_ds where TRANSFOMERBANK_STATUS_VLU <>'REMOVED' )
UNION
SELECT '2.2.1-Fallout due to xfmr not associated to circuit' as Category, COUNT (DISTINCT MRID) as COUNT,
CASE WHEN COUNT (*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments
FROM(select DISTINCT MRID from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS  NULL )
UNION
SELECT '2.2.2-Total SCIM Fallout for Transformers due to transaction not available' as Category, COUNT(*) AS COUNT,
'DQ Issue' as Comments FROM (
select DISTINCT ID from TCGACDS.GCM_V_M2G_TRANSFORMER_scim
minus
select DISTINCT TRANSFORMERBANKID from TCGACDS.GCM_SCIM_DIST_TRANSFORMERBANK )
WHERE ID NOT IN (SELECT RECORD_ID FROM TCGACDS.SWSYNC_TRANSACTION )
UNION
SELECT '2.2.3-TransBank without Units' as Category, COUNT (DISTINCT transformerbank_MRID) as COUNT,
CASE WHEN COUNT (DISTINCT transformerbank_MRID) > 0 THEN 'DQ Issue'
ELSE 'Passed' END as Comments
FROM(
SELECT transformerbank_MRID FROM TCGACDS.gcm_scim_dist_structxfm_ds WHERE POWERTRANSFOMER_MRID IS NULL )
UNION
Select '2.2.4-UsagePoint w/XMFR id in GESW, missing in M2G ' as category, count(distinct ISVC_NUM) as count, 
'NeedReview' as Comments  from TCGACDS.ods030_meter_dtls ods
where XFMR_BANK_ID is not null and  MAPPER_ACTION_FLAG <>'REMOVE' and SERVICE_TYPE_CODE='E' and ISVC_NUM NOT IN
(select usagepoint_number from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm )
and XFMR_BANK_ID  IN ( select ID from TCGACDS.gcm_v_m2g_transformer_scim )
UNION
select '2.2.5-XMFR id in GESW not in TCONN' as category, count(distinct mrid) as count, 
'TCON Issue' as Comments  from TCGACDS.gcm_v_m2g_transformer_scim WHERE ID NOT IN 
(SELECT XFMR_BANK_ID FROM (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and a.XFMR_BANK_ID is not null and  a.MAPPER_ACTION_FLAG <>'REMOVE' and a.SERVICE_TYPE_CODE='E' )
UNION
select '3.0-Total Structure count in Base Table' as Category, STR_COUNT AS COUNT,
'Info' as Comments FROM (
select count (DISTINCT STRUCTURE_NUMBER) as STR_COUNT from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS NOT NULL  )
UNION
select '3.1-Structure published by GCM' as Category, STR_COUNT AS COUNT,
'Info' as Comments FROM (
SELECT COUNT(DISTINCT STRUCTURE_MRID) as STR_COUNT  FROM TCGACDS.gcm_scim_dist_structxfm_ds
) 
UNION
SELECT '3.2-Structure not published by GCM' as Category, COUNT(*) AS COUNT,
'Fallout' as Comments
FROM (
select DISTINCT STRUCTURE_NUMBER from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS NOT NULL 
MINUS
SELECT DISTINCT STRUCTURE_MRID FROM TCGACDS.gcm_scim_dist_structxfm_ds WHERE TRANSFOMERBANK_STATUS_VLU<>'REMOVED')
UNION
SELECT '3.2.1-Total Structure Fallout due to transaction not available for corresponding transformer' as Category, COUNT(*) AS COUNT,
'Fallout' as Comments
FROM tcgacds.GCM_V_M2G_TRANSFORMER_scim where STRUCTURE_NUMBER in(
select DISTINCT STRUCTURE_NUMBER from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS NOT NULL 
MINUS
SELECT DISTINCT STRUCTURE_MRID FROM TCGACDS.gcm_scim_dist_structxfm_ds)
and ID NOT IN (SELECT RECORD_ID FROM TCGACDS.SWSYNC_TRANSACTION)
union
select '3.2.2-Structure in GESW not in TCONN' as category, count(distinct structure_number) as count, 
'TCON Issue' as Comments  from TCGACDS.gcm_v_m2g_transformer_scim WHERE ID NOT IN 
(SELECT XFMR_BANK_ID FROM (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and a.XFMR_BANK_ID is not null and  a.MAPPER_ACTION_FLAG <>'REMOVE' and a.SERVICE_TYPE_CODE='E' );

