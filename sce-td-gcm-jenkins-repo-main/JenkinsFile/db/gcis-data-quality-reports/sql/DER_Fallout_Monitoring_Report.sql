--------------------------------------------------------------------------------------------------------------------------------------------------------
SET LINESIZE 180
column Validations heading "Validations" 
column COUNT heading "COUNT" 
column Remarks heading "Remarks" 
----------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER SESSION SET CURRENT_SCHEMA = TCGACDS;

SELECT '1.01-Project-Tech Type count from input DER file' AS Validations, TOTAL_COUNT AS COUNT,'INFO' AS REMARKS
FROM GCM_DER_PROCESS_STATUS WHERE JOBID IN (
SELECT MAX(JOBID) FROM GCM_DER_PROCESS_STATUS WHERE JOBNAME = 'DER FILE INGESTION' AND INGESTION_COMPLETE_STATUS ='Y' AND REMARKS = 'INGESTION SUCCESSFUL')

UNION

SELECT '1.02-Project-Tech Type count from input DER file excluding duplicates' AS Validations, FEATURE_COUNT AS COUNT,'INFO' AS REMARKS
FROM GCM_DER_PROCESS_STATUS WHERE JOBID IN (
SELECT MAX(JOBID) FROM GCM_DER_PROCESS_STATUS WHERE JOBNAME = 'DER FILE INGESTION' AND INGESTION_COMPLETE_STATUS ='Y' AND REMARKS = 'INGESTION SUCCESSFUL')

UNION

SELECT '1.03-Project-Tech Type published as GENERATOR' AS Validations, COUNT(*) AS COUNT, 'INFO' AS Remarks FROM GCM_CONN_DER_DS WHERE ASSET_TYPE = 'GENERATOR'

UNION

SELECT '1.04-Project-Tech Type published as SYNC MACHINE' AS Validations, COUNT(*) AS COUNT, 'INFO' AS Remarks FROM 
GCM_CONN_DER_SYNC_MACHINE_DS WHERE IS_SECONDARY = '1'

UNION

SELECT '1.05-Project-Tech Type published as Line Sub Energy Consumer' AS Validations, SUM(COUNT_TT) AS COUNT, 'INFO' AS Remarks FROM 
(SELECT COUNT(*) AS COUNT_TT FROM GCM_CONN_DER_DS WHERE ASSET_TYPE = 'ENERGY_SOURCE_LINE_SUB' AND DER_PROJECT_ID IS NOT NULL
UNION
SELECT COUNT(*) AS COUNT_TT FROM GCM_CONN_DER_SYNC_MACHINE_DS WHERE IS_SECONDARY = '0')

UNION

SELECT '1.06-DER Dropped as structure value is missing in input DER file' AS Validations, COUNT(*) AS COUNT, 'FAIL' AS Remarks FROM 
ECM001_DER_INTERCONN WHERE  STRUCTURE IS NULL

UNION

SELECT '1.07-DER Dropped as structure of the DER without xfmr' AS Validations, COUNT(*) AS COUNT, 'FAIL' AS Remarks FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE STRUCTURE NOT IN (SELECT STRUCTURE_NUMBER FROM TCGACDS.GCM_V_TRANSFORMER)and  structure is not null

UNION

SELECT '1.08-Duplicate record in the input DER file' AS Validations, TO_NUMBER(DUPLICATE_COUNT) AS COUNT,
(CASE WHEN DUPLICATE_COUNT> 0 THEN 'FAIL' WHEN DUPLICATE_COUNT =0 THEN 'PASS' END) AS REMARKS
FROM GCM_DER_PROCESS_STATUS WHERE JOBID IN (
SELECT MAX(JOBID) FROM GCM_DER_PROCESS_STATUS WHERE JOBNAME = 'DER FILE INGESTION' AND INGESTION_COMPLETE_STATUS ='Y' AND REMARKS = 'INGESTION SUCCESSFUL')

UNION

SELECT '1.09-Invalid circuit no or circuit no value is null in input DER file' AS Validations, COUNT(*) AS COUNT, 'WARNING' AS Remarks FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE (CIRCUIT_NO NOT IN (SELECT CIRCUIT_NO FROM TCGACDS.CIRCUIT_HEAD) OR CIRCUIT_NO IS NULL) AND STRUCTURE IS NOT NULL

UNION

SELECT '1.10-Invalid substation no or substation no value is null in input DER file' AS Validations, COUNT(*) AS COUNT, 'WARNING' AS Remarks FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE (SUBSTATION_NO NOT IN (SELECT SUBSTATION_NO FROM TCGACDS.SUBSTATION) OR SUBSTATION_NO IS NULL) AND STRUCTURE IS NOT NULL

UNION

SELECT '1.21-ISVC not found in ods030 table or isvc value is null in input DER file' AS Validations, COUNT(*) AS COUNT, 'WARNING' AS Remarks FROM 
TCGACDS.ECM001_DER_INTERCONN A WHERE   STRUCTURE IS NOT NULL AND  (NOT exists (
SELECT ISVC_NUM FROM TCGACDS.ODS030_METER_DTLS B where  A.ISVC_NUM=B.ISVC_NUM )OR A.ISVC_NUM IS NULL)

UNION

SELECT '1.22-Tech type not present in inverter lookup table or tech type value is null in input DER file' AS Validations, COUNT(*) AS COUNT, 'WARNING' AS Remarks FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE TECHNOLOGY_TYPE NOT IN (SELECT T.GCM_TECHNOLOGY_TYPE FROM TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP I ,
TCGACDS.GCM_DER_TECHNOLOGY_TYPES_LOOK_UP T WHERE I.TECHNOLOGY_TYPE = T.DER_SOURCE_TECH_TYPE ) AND STRUCTURE IS NOT NULL

UNION

SELECT '1.23-Tech type not present in techtype lookup  or tech type value is null in input DER file' AS Validations, COUNT(*) AS COUNT, 'WARNING' AS Remarks FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE TECHNOLOGY_TYPE NOT IN (SELECT GCM_TECHNOLOGY_TYPE FROM TCGACDS.GCM_DER_TEchnology_types_look_up)and  structure is not null

UNION

SELECT '1.24-Tech type in the DER file that is inverter based but inverter record missing in the inverter file' AS Validations, COUNT(*) AS COUNT, 'WARNING' AS Remarks FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE TECHNOLOGY_TYPE IN (SELECT TECHNOLOGY_TYPE FROM GCM_DER_TECHTYPE_INV_LOOK_UP WHERE INVERTER = 'YES') 
AND DER_PROJECT_ID NOT IN (SELECT DER_PROJECT_ID FROM GCM_DER_INVERTER_DATA);