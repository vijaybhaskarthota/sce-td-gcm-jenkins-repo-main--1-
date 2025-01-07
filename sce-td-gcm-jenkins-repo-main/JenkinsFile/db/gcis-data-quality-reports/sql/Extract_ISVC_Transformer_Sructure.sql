SET ECHO OFF
SET WRAP OFF
SET LINESIZE 200
column IDENTIFIER heading "IDENTIFIER" format  A20
column TABLE_NAME heading "TABLE" format A20
column CIRCUIT_NAME heading "CIRCUIT" format A8
column TRANSFORMERBANK_ID heading "XFMR_BANK_ID" format A8
column Remarks heading "REMARKS" format A6
column Validation heading "VALIDATION" format A60
column STRUCTURE_NUMBER heading "STRUCTURE" format A9


alter session set current_schema=tcgacds;
select TO_CHAR(A.ISVC_NUM) IDENTIFIER,'ODS030_METER_DTLS' TABLE_NAME,A.CIRCUIT_NAME CIRCUIT_NAME,A.XFMR_BANK_ID TRANSFORMERBANK_ID,'Fail' as Remarks,
'1.2-Total Fallout' as Validation,A.SERV_CONNECT_ID STRUCTURE_NUMBER from (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and a.XFMR_BANK_ID is not null and  a.MAPPER_ACTION_FLAG <>'REMOVE' and a.SERVICE_TYPE_CODE='E' and a.ISVC_NUM NOT IN
(select usagepoint_number from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm )
and XFMR_BANK_ID NOT IN ( select ID from TCGACDS.gcm_v_m2g_transformer_scim )

UNION

select TO_CHAR(A.ISVC_NUM) IDENTIFIER,'ODS030_METER_DTLS' TABLE_NAME,A.CIRCUIT_NAME CIRCUIT_NAME,A.XFMR_BANK_ID TRANSFORMERBANK_ID,'Fail' as Remarks,
'1.2.1-TCON ISVC w/XMFR id not in GESW ' as Validation,A.SERV_CONNECT_ID STRUCTURE_NUMBER from (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and a.XFMR_BANK_ID is not null and  a.MAPPER_ACTION_FLAG <>'REMOVE' and a.SERVICE_TYPE_CODE='E' and a.ISVC_NUM NOT IN
(select usagepoint_number from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm )
and XFMR_BANK_ID NOT IN ( select ID from TCGACDS.gcm_v_m2g_transformer_scim )

UNION

select distinct TO_CHAR(ISVC_NUM) IDENTIFIER,'ODS030_METER_DTLS' TABLE_NAME,CIRCUIT_NAME,XFMR_BANK_ID TRANSFORMERBANK_ID,'Fail' as Remarks,
'1.2.2-Total ISVC_FALLOUT' as Validation,SERV_CONNECT_ID STRUCTURE_NUMBER from 
(select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and A.MAPPER_ACTION_FLAG <> 'REMOVE' AND A.SERVICE_TYPE_CODE='E' and a.xfmr_bank_id is not null and  
a.xfmr_bank_id in(select id from TCGACDS.gcm_v_m2g_transformer_scim) and A.ISVC_NUM not in (
select distinct(USAGEPOINT_NUMBER )as ISVC_NUM from  TCGACDS.GCM_SCIM_DIST_USAGEPOINT_DS)

UNION

select distinct TO_CHAR(ISVC_NUM) IDENTIFIER,'ODS030_METER_DTLS' TABLE_NAME,CIRCUIT_NAME,XFMR_BANK_ID TRANSFORMERBANK_ID,'Fail' as Remarks,
'1.2.3-ODS300_SYNC_TRANS table has not populated with correct time' as Validation,SERV_CONNECT_ID STRUCTURE_NUMBER
from (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and A.MAPPER_ACTION_FLAG <> 'REMOVE' AND A.SERVICE_TYPE_CODE='E' 
and A.isvc_num not in (select USAGEPOINT_NUMBER from tcgacds.GCM_SCIM_DIST_USAGEPOINT_DS) 
and exists (select 1 from tcgacds.GCM_V_M2G_TRANSFORMER_SCIM where id=xfmr_bank_id)

UNION

select DISTINCT TO_CHAR(ISVC_NUM) IDENTIFIER,'ODS030_METER_DTLS' TABLE_NAME,CIRCUIT_NAME,XFMR_BANK_ID TRANSFORMERBANK_ID,'Fail' as Remarks,
'1.2.4-Total ISVC w/transformer null' as Validation,SERV_CONNECT_ID STRUCTURE_NUMBER from TCGACDS.ods030_meter_dtls ods 
where service_type_code ='E' and MAPPER_ACTION_FLAG <>'REMOVE' AND XFMR_BANK_ID IS NULL

UNION

select DISTINCT M3I_OBJECT_ID IDENTIFIER,FEATURE_NAME TABLE_NAME,CIRCUIT_NAME1 CIRCUIT_NAME,ID TRANSFORMER_BANK_ID,
'Fail' as Remarks,'2.2-Transformer not published by GCM' as Validation,
STRUCTURE_NUMBER from TCGACDS.GCM_V_M2G_TRANSFORMER_scim
where mrid not in (SELECT  distinct transformerbank_MRID  
FROM TCGACDS.gcm_scim_dist_structxfm_ds where TRANSFOMERBANK_STATUS_VLU <>'REMOVED')

UNION

select DISTINCT M3I_OBJECT_ID IDENTIFIER,FEATURE_NAME TABLE_NAME,CIRCUIT_NAME1 CIRCUIT_NAME,ID TRANSFORMER_BANK_ID,
'Fail' as Remarks,'2.2.1-Fallout due to xfmr not associated to circuit' as Validation,
STRUCTURE_NUMBER from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS  NULL 

UNION

select DISTINCT M3I_OBJECT_ID IDENTIFIER,FEATURE_NAME TABLE_NAME,CIRCUIT_NAME1 CIRCUIT_NAME,ID TRANSFORMER_BANK_ID,
'Fail' as Remarks,'2.2.2-Total SCIM Fallout for Transformers due to transaction not available' as Validation,
STRUCTURE_NUMBER from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE ID NOT IN
(select DISTINCT TRANSFORMERBANKID from TCGACDS.GCM_SCIM_DIST_TRANSFORMERBANK )
and ID NOT IN (SELECT RECORD_ID FROM TCGACDS.SWSYNC_TRANSACTION )

UNION

select DISTINCT G.TRANSFORMERBANK_MRID IDENTIFIER,G.TRANSFORMERBANK_TYP TABLE_NAME,C.CIRCUIT_NAME CIRCUIT_NAME,
NULL,'Fail' as Remarks,
'2.2.3-TransBank without Units' as Validation,G.STRUCTURE_NUMBR from TCGACDS.gcm_scim_dist_structxfm_ds G,
circuit_head C where G.TRANSFORMERBANK_CIRCUITID=C.CIRCT_ID AND G.POWERTRANSFOMER_MRID IS NULL

UNION

Select distinct TO_CHAR(ISVC_NUM) IDENTIFIER,'ODS030_METER_DTLS' TABLE_NAME,CIRCUIT_NAME,XFMR_BANK_ID TRANSFORMER_BANK_ID,'Fail' as Remarks,
'2.2.4-UsagePoint w/XMFR id in GESW, missing in M2G' as Validation,SERV_CONNECT_ID STRUCTURE_NUMBER 
from TCGACDS.ods030_meter_dtls ods
where XFMR_BANK_ID is not null and  MAPPER_ACTION_FLAG <>'REMOVE' and SERVICE_TYPE_CODE='E' and ISVC_NUM NOT IN
(select usagepoint_number from   TCGACDS.gcm_scim_dist_usagepoint_ds gcm )
and XFMR_BANK_ID  IN ( select ID from TCGACDS.gcm_v_m2g_transformer_scim )

UNION

select DISTINCT M3I_OBJECT_ID IDENTIFIER,FEATURE_NAME TABLE_NAME,CIRCUIT_NAME1 CIRCUIT_NAME,ID TRANSFORMER_BANK_ID,
'Fail' as Remarks,'2.2.5 XMFR id in GESW not in TCONN' as Validation,
STRUCTURE_NUMBER from TCGACDS.gcm_v_m2g_transformer_scim WHERE ID NOT IN 
(SELECT XFMR_BANK_ID FROM (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and a.XFMR_BANK_ID is not null and  a.MAPPER_ACTION_FLAG <>'REMOVE' and a.SERVICE_TYPE_CODE='E' )

UNION

select DISTINCT M3I_OBJECT_ID IDENTIFIER,FEATURE_NAME TABLE_NAME,CIRCUIT_NAME1 CIRCUIT_NAME,ID TRANSFORMER_BANK_ID,
'Fail' as Remarks,'3.2-Structure not published by GCM' as Validation,
STRUCTURE_NUMBER FROM TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS NOT NULL AND STRUCTURE_NUMBER NOT IN 
(SELECT DISTINCT STRUCTURE_MRID FROM TCGACDS.gcm_scim_dist_structxfm_ds)

UNION

SELECT  DISTINCT M3I_OBJECT_ID IDENTIFIER,FEATURE_NAME TABLE_NAME,CIRCUIT_NAME1 CIRCUIT_NAME,ID TRANSFORMER_BANK_ID,'Fail' as Remarks,
'3.2.1-Total Structure Fallout due to transaction not available for corresponding XFMR' as Validation,
STRUCTURE_NUMBER FROM tcgacds.GCM_V_M2G_TRANSFORMER_scim where STRUCTURE_NUMBER in(
select DISTINCT STRUCTURE_NUMBER from TCGACDS.GCM_V_M2G_TRANSFORMER_scim WHERE CIRCUIT_NAME1 IS NOT NULL 
MINUS
SELECT DISTINCT STRUCTURE_MRID FROM TCGACDS.gcm_scim_dist_structxfm_ds)
and ID NOT IN (SELECT RECORD_ID FROM TCGACDS.SWSYNC_TRANSACTION)

UNION

select distinct M3I_OBJECT_ID IDENTIFIER,FEATURE_NAME TABLE_NAME,CIRCUIT_NAME1 CIRCUIT_NAME,ID TRANSFORMER_BANK_ID,'Fail' as Remarks,
'3.2.2 Structure in GESW not in TCONN' as Validation,STRUCTURE_NUMBER from TCGACDS.gcm_v_m2g_transformer_scim WHERE ID NOT IN 
(SELECT XFMR_BANK_ID FROM (select A.*, RANK() over (partition by ISVC_NUM order by created_date desc)as RANK_NO from tcgacds.ODS030_METER_DTLS A)A
where A.RANK_NO=1 and a.XFMR_BANK_ID is not null and  a.MAPPER_ACTION_FLAG <>'REMOVE' and a.SERVICE_TYPE_CODE='E' );