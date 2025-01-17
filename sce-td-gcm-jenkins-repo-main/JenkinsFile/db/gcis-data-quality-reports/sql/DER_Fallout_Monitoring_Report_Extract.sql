SET ECHO OFF
SET WRAP OFF
SET LINESIZE 200
SET FEEDBACK OFF
column DER_PROJECT_ID heading "DER_ID" format  A10
column TECHNOLOGY_TYPE heading "TECH_TYPE" format A12
column Remarks heading "Remarks" format A8
column CIRCUIT_NO heading "CIRCT_NO" format A8
column SUBSTATION_NO heading "SUB_NO" format A6
column Validations heading "Validations" format A102
column STRUCTURE heading "STR#" format A7
column NAMEPLATES heading "NAMEPLATES" format A10

ALTER SESSION SET CURRENT_SCHEMA = TCGACDS;
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE , Remarks, CIRCUIT_NO, SUBSTATION_NO, Validations, STRUCTURE, NAMEPLATES FROM (
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE , 'FAIL' AS Remarks, CIRCUIT_NO, SUBSTATION_NO, '1.06-DER Dropped as structure value is missing in input DER file' AS Validations, 
STRUCTURE, NAME_PLATE_CAPACITY AS NAMEPLATES FROM ECM001_DER_INTERCONN WHERE  STRUCTURE IS NULL
UNION
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE , 'FAIL' AS Remarks, CIRCUIT_NO, SUBSTATION_NO, '1.07-DER Dropped as structure of the DER without xfmr' AS Validations, STRUCTURE, NAME_PLATE_CAPACITY AS 
NAMEPLATES FROM TCGACDS.ECM001_DER_INTERCONN WHERE STRUCTURE NOT IN (SELECT STRUCTURE_NUMBER FROM TCGACDS.GCM_V_TRANSFORMER)and  structure is not null
UNION
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE , 'WARNING' AS Remarks, CIRCUIT_NO, SUBSTATION_NO, '1.09-Invalid circuit no or circuit no value is null in input DER file' AS Validations, STRUCTURE, NAME_PLATE_CAPACITY AS NAMEPLATES FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE (CIRCUIT_NO NOT IN (SELECT CIRCUIT_NO FROM TCGACDS.CIRCUIT_HEAD) OR CIRCUIT_NO IS NULL) AND STRUCTURE IS NOT NULL
UNION
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE , 'WARNING' AS Remarks, CIRCUIT_NO, SUBSTATION_NO, '1.10-Invalid substation no or substation no value is null in input DER file' AS Validations, STRUCTURE, NAME_PLATE_CAPACITY AS NAMEPLATES FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE (SUBSTATION_NO NOT IN (SELECT SUBSTATION_NO FROM TCGACDS.SUBSTATION) OR SUBSTATION_NO IS NULL) AND STRUCTURE IS NOT NULL
UNION
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE , 'WARNING' AS Remarks, CIRCUIT_NO, SUBSTATION_NO, '1.21-ISVC not found in ods030 table or isvc value is null in input DER file' AS Validations, STRUCTURE, NAME_PLATE_CAPACITY AS NAMEPLATES FROM 
TCGACDS.ECM001_DER_INTERCONN A WHERE   STRUCTURE IS NOT NULL AND  (NOT exists (
SELECT ISVC_NUM FROM TCGACDS.ODS030_METER_DTLS B where  A.ISVC_NUM=B.ISVC_NUM )OR A.ISVC_NUM IS NULL)
UNION
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE , 'WARNING' AS Remarks, CIRCUIT_NO, SUBSTATION_NO, '1.22-Tech type not present in inverter lookup table or tech type value is null in input DER file' AS Validations, STRUCTURE, NAME_PLATE_CAPACITY AS NAMEPLATES FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE TECHNOLOGY_TYPE NOT IN (SELECT T.GCM_TECHNOLOGY_TYPE FROM TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP I ,
TCGACDS.GCM_DER_TECHNOLOGY_TYPES_LOOK_UP T WHERE I.TECHNOLOGY_TYPE = T.DER_SOURCE_TECH_TYPE ) AND STRUCTURE IS NOT NULL
UNION
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE , 'WARNING' AS Remarks, CIRCUIT_NO, SUBSTATION_NO, '1.23-Tech type not present in techtype lookup  or tech type value is null in input DER file' AS Validations, STRUCTURE, NAME_PLATE_CAPACITY AS NAMEPLATES FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE TECHNOLOGY_TYPE NOT IN (SELECT GCM_TECHNOLOGY_TYPE FROM TCGACDS.GCM_DER_TEchnology_types_look_up)and  structure is not null
UNION
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE , 'WARNING' AS Remarks, CIRCUIT_NO, SUBSTATION_NO, '1.24-Tech type in the DER file that is inverter based but inverter record missing in the inverter file' AS Validations, STRUCTURE, NAME_PLATE_CAPACITY AS NAMEPLATES FROM 
TCGACDS.ECM001_DER_INTERCONN WHERE TECHNOLOGY_TYPE IN (SELECT TECHNOLOGY_TYPE FROM GCM_DER_TECHTYPE_INV_LOOK_UP WHERE INVERTER = 'YES') 
AND DER_PROJECT_ID NOT IN (SELECT DER_PROJECT_ID FROM GCM_DER_INVERTER_DATA))ORDER BY VALIDATIONS ASC;