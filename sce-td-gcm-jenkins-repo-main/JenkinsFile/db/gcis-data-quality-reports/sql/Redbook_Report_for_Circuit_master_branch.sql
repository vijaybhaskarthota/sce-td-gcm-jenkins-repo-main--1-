--This report validate report validates Redbook data loaded in SRC Vs Final for the Circuit.
-- Last Modified Date: 9/14/2021
    --Update comments: 9/14
    --1. Cosmatic updates
    --2. Added extra query and validation on circuit status in queries
    
--------------------------------------------------------------------------------------------------
column Category heading "Category" Format a53
column COUNT heading "COUNT" Format a10
column Comments heading "Comments" Format a7

--- REDBOOK data count for network type circuit in stg
select '1.REDBOOK data count for network type circuit in stg' as Category, COUNT(*) as COUNT, 'Info' as Comments
from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL --4466
UNION
select '2.DQ Check - CAPE_BUS NULL in STG' as Category, COUNT(*) as COUNT, 'Info' as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS   NULL --4466
UNION
select '3.REDBOOK data count for type ckt in setting' as Category, COUNT(*) as COUNT,
'Info' as Comments from TCGACDS.GCM_REDBOOK_BB_SETTING WHERE JOBID =
( SELECT JOBID FROM TCGACDS.GCM_REDBOOK_AUDIT WHERE ACTIVE_JOB_ID = 'Y') and network_type = 'CIRCUIT' and CAPE_BUS IS NOT NULL 
UNION
select '4.REDBOOK data Distinct count for type ckt in setting' as Category, COUNT(distinct network_id ) as COUNT,
'Info' as Comments from TCGACDS.GCM_REDBOOK_BB_SETTING WHERE JOBID =
( SELECT JOBID FROM TCGACDS.GCM_REDBOOK_AUDIT WHERE ACTIVE_JOB_ID = 'Y') and network_type = 'CIRCUIT' and CAPE_BUS IS NOT NULL 

UNION
select '5.DQ Check - CAPE_BUS NULL in setting' as Category, COUNT(distinct network_id) as COUNT,
'Info' as Comments from TCGACDS.GCM_REDBOOK_BB_SETTING WHERE JOBID =
( SELECT JOBID FROM TCGACDS.GCM_REDBOOK_AUDIT WHERE ACTIVE_JOB_ID = 'Y') and network_type = 'CIRCUIT' and CAPE_BUS IS  NULL 

UNION

select '6.Total Circuit with cape bus null in final' as category, count(distinct m3i_object_id) as COUNT,
'Info' as Comments
from TCGACDS.GCM_CONN_DATA_STORE where asset_type = 'REDBOOK' and cape_bus is  null

UNION

select '7.Total Circuit with redbook/cape bus in final' as category, count(*) as COUNT, 
'Info' as Comments from TCGACDS.GCM_CONN_DATA_STORE where
asset_type = 'REDBOOK' and cape_bus is  NOT null
UNION

select '8.Total Distinct Ckt with redbook/cape bus in final' as category, count(distinct m3i_object_id) as COUNT,
'Info' as Comments from TCGACDS.GCM_CONN_DATA_STORE where
asset_type = 'REDBOOK' and cape_bus is  NOT null

UNION

select '8a.Circuit in redbook setting but not in circuit head' as Category, count(Distinct NETWORK_ID) as COUNT,
 CASE WHEN COUNT(Distinct NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_BB_SETTING WHERE JOBID =
( SELECT JOBID FROM TCGACDS.GCM_REDBOOK_AUDIT WHERE ACTIVE_JOB_ID = 'Y') and network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL 
and SUBSTR(Network_id, 0, INSTR(Network_id, '_')-1)  NOT  IN (SELECT CIRCUIT_NAME FROM TCGACDS.CIRCUIT_HEAD)

UNION

select '8b.Circt in redbook setting,but F stat in circt head' as Category, count(Distinct NETWORK_ID) as COUNT,
 CASE WHEN COUNT(Distinct NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_BB_SETTING WHERE JOBID =
( SELECT JOBID FROM TCGACDS.GCM_REDBOOK_AUDIT WHERE ACTIVE_JOB_ID = 'Y') and network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL 
and SUBSTR(Network_id, 0, INSTR(Network_id, '_')-1) IN (SELECT CIRCUIT_NAME FROM TCGACDS.CIRCUIT_HEAD where circt_stat_cd = 'F')

UNION

select '8c.CIRCUIT dropped in redbook final', count(*) as COUNT,
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments FROM (
select Distinct NETWORK_ID  from TCGACDS.GCM_REDBOOK_BB_SETTING WHERE JOBID =
( SELECT JOBID FROM TCGACDS.GCM_REDBOOK_AUDIT WHERE ACTIVE_JOB_ID = 'Y') and network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL 
and SUBSTR(Network_id, 0, INSTR(Network_id, '_')-1) IN (SELECT CIRCUIT_NAME FROM TCGACDS.CIRCUIT_HEAD where circt_stat_cd <> 'F')
MINUS
select  distinct m3i_object_id from TCGACDS.GCM_CONN_DATA_STORE where
asset_type = 'REDBOOK' and cape_bus is  NOT null );


--------------------------- NULL CHECK------------
select 'REDBOOK DATA WITH BUS_VOLTAGE NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and BUS_VOLTAGE IS NULL
UNION
select  'REDBOOK DATA WITH LLL_MVA NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and LLL_MVA IS NULL
UNION
select  'REDBOOK DATA WITH LG_MVA NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and LG_MVA IS NULL
UNION
select  'REDBOOK DATA WITH LLG_MVA NULL' as Category,  COUNT(NETWORK_ID) as COUNT ,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and LLG_MVA IS NULL
UNION
select  'REDBOOK DATA WITH POS_SEQ_IMP_PU NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and POS_SEQ_IMP_PU IS NULL
UNION
select  'REDBOOK DATA WITH NEG_SEQ_IMP_PU NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and NEG_SEQ_IMP_PU IS NULL
UNION
select  'REDBOOK DATA WITH ZERO_SEQ_IMP_PU NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and ZERO_SEQ_IMP_PU IS NULL

UNION
select  'REDBOOK DATA WITH LLL_AMPS NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and LLL_AMPS IS NULL
UNION
select 'REDBOOK DATA WITH LG_AMPS NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and LG_AMPS IS NULL
UNION
select 'REDBOOK DATA WITH LLG_AMPS NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and LLG_AMPS IS NULL
UNION
select  'REDBOOK DATA WITH BANK_NO NULL' as Category,  COUNT(NETWORK_ID) as COUNT,
 CASE WHEN COUNT( NETWORK_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.GCM_REDBOOK_STAGING 
where  network_type = 'CIRCUIT' and CAPE_BUS IS NOT  NULL  and BANK_NO IS NULL;
