-- This report validates Voltage Regulator Data quality for circuit from source to final and explains the reasons for different fallout
-- Last Modified date: 9/24/2021
----------------------------------------------------------------------------------------------

column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10

------step 1 to 6 substation internal connectivity---------
---------Number of Circuits having regulator in EMS
select '1-SSI:Circuit With Regulator from EMS#' as Category, count (DISTINCT CIRCUIT_NAME) as count, 'Info' as Comments from (
select REPLACE (NAME,' REGULATOR') as CIRCUIT_NAME from TCGACDS.GCM_SCIM_DISCONNECTOR
where name like '% REGULATOR' and REPLACE (NAME,' REGULATOR') in (Select CIRCUIT_NAME from TCGACDS.CIRCUIT_HEAD)
and GCM_JOBID=(SELECT JOBID FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID='Y') )

UNION
----------Number of EMS Circuits having Disc/Line Regulator Info matching in DVVC
select '2-SSI:Circuit matching Regulator Setting from DVVC#' as Category, count (DISTINCT CIRCUIT_NAME) as Count,'Info' as Comments  from (
select DISTINCT SUBSTR(DESCRIPTION,1,INSTR(SUBSTR(DESCRIPTION,1,INSTR(DESCRIPTION,'KV',-1)-1),' ',-1)-1) as CIRCUIT_NAME from
TCGACDS.GCM_SCIM_LINEREGULATOR where GCM_JOBID=(SELECT JOBID FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID='Y') 
and TYP is not null and CONFIGURATION is not null  )

UNION
---------Number of EMS Circuits having Disconnectors which do not have VREG Info from DVVC
SELECT '3-SSI:Circuit having regulator,noSetting from DVVC' as Category, count (DISTINCT CIRCUIT_NAME) as Count, 'Info' as Comments from (
select NAME, REPLACE (NAME,' REGULATOR') as CIRCUIT_NAME from TCGACDS.GCM_SCIM_DISCONNECTOR DIS LEFT join TCGACDS.GCM_VREG_LINE_DATA VREG
on REPLACE (NAME,' REGULATOR')=VREG.CIRCUIT_NAME where VREG.CIRCUIT_NAME is null and dis.name like '% REGULATOR' and REPLACE (NAME,' REGULATOR') in (Select CIRCUIT_NAME from TCGACDS.CIRCUIT_HEAD)
and GCM_JOBID=(SELECT JOBID FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID='Y' ))

UNION
--------- Number of DVVC circuits which do not have regulator Info in SI Connectivity
SELECT '4-SSI:Circuit wSetting From DVVC not in EMS#' as Category, count (DISTINCT CIRCUIT_NAME) as Count, 'DQ issue' as Comments from (
select DISTINCT CIRCUIT_NAME from TCGACDS.GCM_VREG_LINE_DATA where CIRCUIT_NAME not in
(select DISTINCT SUBSTR(DESCRIPTION,1,INSTR(SUBSTR(DESCRIPTION,1,INSTR(DESCRIPTION,'KV',-1)-1),' ',-1)-1) as NAME from TCGACDS.GCM_SCIM_LINEREGULATOR 
where GCM_JOBID=(SELECT JOBID FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID='Y')
and TYP is not null and CONFIGURATION is not null)  
)

UNION
---------Number of EMS Circuits having Disconnectors which do not have Regulator Equipment in SAP.
SELECT '5-SSI:Circuit having regulator from EMS not in SAP#' as Category, count (DISTINCT CIRCUIT_NAME) as count, 'DQ Issue' as Comments from (
select REPLACE (NAME,' REGULATOR') as CIRCUIT_NAME from TCGACDS.GCM_SCIM_DISCONNECTOR
where name like '% REGULATOR' and REPLACE (NAME,' REGULATOR') in (Select CIRCUIT_NAME from TCGACDS.CIRCUIT_HEAD)
and GCM_JOBID=(SELECT JOBID FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID='Y')
and REPLACE (NAME,' REGULATOR') not in (select SUBSTR(DESCRIPTION,1,INSTR(SUBSTR(DESCRIPTION,1,INSTR(DESCRIPTION,'KV',-1)-1),' ',-1)-1) as NAME from TCGACDS.ODS011_SAP_EQUIP where OBJECT_TYPE in ('ES_REGL') and DESCRIPTION like '%KV REGULATOR % PH' 
and SYSTEM_STATUS not like '%DLFL%' and SYSTEM_STATUS not like '%INAC%' and 
SUBSTR(DESCRIPTION,1,INSTR(SUBSTR(DESCRIPTION,1,INSTR(DESCRIPTION,'KV',-1)-1),' ',-1)-1) in
(Select CIRCUIT_NAME from TCGACDS.CIRCUIT_HEAD))
)

UNION
---Number of Circuits related to Regulator Equipment from SAP which do not have Disconnector Info in EMS
SELECT '6-SSI:Circuit having regulator from SAP not in EMS#' as Category, count (DISTINCT CIRCUIT_NAME) as Count, 'Info' as comments from (
select DISTINCT SUBSTR(DESCRIPTION,1,INSTR(SUBSTR(DESCRIPTION,1,INSTR(DESCRIPTION,'KV',-1)-1),' ',-1)-1) as CIRCUIT_NAME
from TCGACDS.ODS011_SAP_EQUIP where OBJECT_TYPE in ('ES_REGL') and DESCRIPTION like '%KV REGULATOR % PH' 
and SYSTEM_STATUS not like '%DLFL%' and SYSTEM_STATUS not like '%INAC%'
and SUBSTR(DESCRIPTION,1,INSTR(SUBSTR(DESCRIPTION,1,INSTR(DESCRIPTION,'KV',-1)-1),' ',-1)-1) not
in (select REPLACE (NAME,' REGULATOR') as CIRCUIT_NAME from TCGACDS.GCM_SCIM_DISCONNECTOR
where name like '% REGULATOR' and REPLACE (NAME,' REGULATOR') in (Select CIRCUIT_NAME from TCGACDS.CIRCUIT_HEAD)
and GCM_JOBID=(SELECT JOBID FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID='Y')) )

UNION
-----------step 7 to 7.4 circuit connectivity regulator info---------
---number of regulator from GESW--------
select '7-Ckt_Conn:Regulator from GESW#' as Category, count(DISTINCT M3I_OBJECT_ID) as COUNT, 'Info' as Comments
from TCGACDS.VOLTAGE_REGULATOR_LOCATION

UNION
----number of regulator having regulator having regulator from DVCC

SELECT '7.1-Ckt_Conn:Regulator matching DVVC#' as Category, COUNT(DISTINCT LINE_DEVICE_NO ) as COUNT, 'Info' as Comments FROM 
(
select DISTINCT VREG.CIRCUIT_NAME1,VREG.LINE_DEVICE_NO,VREG.STRUCTURE_NUMBER,VREG.M3I_OBJECT_ID,DVVC.STRUCTURE_NUMBER as DVVC_STRUCTURE_NUMBER,
DVVC.REGULATOR_NUMBER from TCGACDS.VOLTAGE_REGULATOR_LOCATION VREG
INNER JOIN
(SELECT DISTINCT STRUCTURE_NUMBER,REGULATOR_NUMBER from TCGACDS.GCM_VREG_DATA) DVVC
ON VREG.STRUCTURE_NUMBER=DVVC.STRUCTURE_NUMBER
where VREG.M3I_OBJECT_ID in (select M3I_OBJECT_ID from TCGACDS.GCM_VOLTAGE_REGULATOR_SETTING_DS)
)

UNION
----number of regulator having regulator  setting from DVCC but not in connectivity (DS table)
SELECT '7.2-Ckt_Conn:Regulator from DVVC but dropped#' as Category, COUNT(DISTINCT LINE_DEVICE_NO ) as COUNT, 'Info' as Comments FROM (
select DISTINCT VREG.CIRCUIT_NAME1,VREG.LINE_DEVICE_NO,VREG.STRUCTURE_NUMBER,VREG.M3I_OBJECT_ID,DVVC.STRUCTURE_NUMBER as DVVC_STRUCTURE_NUMBER,
DVVC.REGULATOR_NUMBER from TCGACDS.VOLTAGE_REGULATOR_LOCATION VREG
INNER JOIN
(SELECT DISTINCT STRUCTURE_NUMBER,REGULATOR_NUMBER from TCGACDS.GCM_VREG_DATA) DVVC
ON VREG.STRUCTURE_NUMBER=DVVC.STRUCTURE_NUMBER
where VREG.M3I_OBJECT_ID not in (select M3I_OBJECT_ID from TCGACDS.GCM_VOLTAGE_REGULATOR_SETTING_DS)
and VREG.CIRCUIT_NAME1 in (select CIRCUIT_NAME from TCGACDS.CIRCUIT_HEAD where CIRCT_STAT_CD='I') )

UNION
---number of voltage regulator from GESW but no regulator setting from DVVC

SELECT '7.3-Ckt_Conn:Regulator no setting DVVC#' as Category, COUNT(DISTINCT LINE_DEVICE_NO ) as COUNT, 'Info' as Comments FROM 
(
select DISTINCT VREG.CIRCUIT_NAME1,VREG.LINE_DEVICE_NO,VREG.STRUCTURE_NUMBER,VREG.M3I_OBJECT_ID,DVVC.STRUCTURE_NUMBER,DVVC.REGULATOR_NUMBER
from TCGACDS.VOLTAGE_REGULATOR_LOCATION VREG
LEFT JOIN
(SELECT DISTINCT STRUCTURE_NUMBER,REGULATOR_NUMBER from TCGACDS.GCM_VREG_DATA) DVVC
ON VREG.STRUCTURE_NUMBER=DVVC.STRUCTURE_NUMBER
where DVVC.STRUCTURE_NUMBER is null ) 

UNION
------number of voltage regulator object missing from  GESW  but regulator settings from DVVC

SELECT '7.4-Ckt_Conn:Regulator from DVVC not matching GESW' as Category, COUNT(DVVC_STRUCTURE_NUMBER) as Count, 'Info' as Comments FROM (
select DISTINCT VREG.CIRCUIT_NAME1,VREG.LINE_DEVICE_NO,VREG.STRUCTURE_NUMBER,VREG.M3I_OBJECT_ID,
DVVC.STRUCTURE_NUMBER as DVVC_STRUCTURE_NUMBER,DVVC.REGULATOR_NUMBER,DVVC.PHASE
from TCGACDS.VOLTAGE_REGULATOR_LOCATION VREG
RIGHT JOIN
(SELECT DISTINCT STRUCTURE_NUMBER,REGULATOR_NUMBER,PHASE from TCGACDS.GCM_VREG_DATA) DVVC
ON VREG.STRUCTURE_NUMBER=DVVC.STRUCTURE_NUMBER
where DVVC.STRUCTURE_NUMBER is not null and VREG.STRUCTURE_NUMBER is Null );

