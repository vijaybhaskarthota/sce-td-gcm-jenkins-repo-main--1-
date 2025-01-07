-- This report validates DER from source to final and explains the reasons for the DERs.
-- Last Modified date: 03/14/2023
-----------------------------------------------------------


column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10
-----------------

select '1.01-DER-TECH from source#' as Category, count(*), 'Info' as Comments from (

select DER_PROJECT_ID,TECHNOLOGY_TYPE, count(*) as count, 'Info' as Comments FROM TCGACDS.ECM001_DER_INTERCONN ECM
group by DER_PROJECT_ID, TECHNOLOGY_TYPE )

UNION

select '1.02-DER-TECH as GENERATOR in final#' as Category, count(*), 'Info' as Comments from (
select DER_PROJECT_ID,TECHNOLOGY_TYPE, COUNT(*) from TCGACDS.GCM_CONN_DER_DS WHERE ASSET_TYPE ='GENERATOR' 
GROUP BY DER_PROJECT_ID,TECHNOLOGY_TYPE )

UNION

select '1.03-DER-TECH as SYNC MACHINE in final#' as Category, count(*), 'Info' as Comments from (
SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE FROM TCGACDS.GCM_CONN_DER_SYNC_MACHINE_DS
GROUP BY DER_PROJECT_ID,TECHNOLOGY_TYPE )


UNION

select '1.04-DER-TECH as LINE SUB in final#' as Category, count(*), 'Info' as Comments from (
select DER_PROJECT_ID,TECHNOLOGY_TYPE, COUNT(*)  from TCGACDS.GCM_CONN_DER_DS WHERE ASSET_TYPE ='ENERGY_SOURCE_LINE_SUB' 
AND DER_PROJECT_ID in (SELECT DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN )

GROUP BY DER_PROJECT_ID,TECHNOLOGY_TYPE )


UNION

SELECT '1.05-DER-TECH w/structure null from source#', count(*) as count, 'DQ84034' as Comments from (
SELECT  DER_PROJECT_ID, TECHNOLOGY_TYPE, COUNT(*) FROM TCGACDS.ECM001_DER_INTERCONN ECM
where ECM.STRUCTURE IS NULL and 
ECM.DER_PROJECT_ID NOT IN (  SELECT DISTINCT LINE_DEVICE_NO
                                        FROM   TCGACDS.LINE_SUB
                                        WHERE   LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL )                                            
                                                      
GROUP BY DER_PROJECT_ID, TECHNOLOGY_TYPE )


UNION

select '1.06-DER-TECH Linked_to_NON-XFMR_STR#' as Category, COUNT (*) as count, 'DQ18249' as Comments  from 
( 

SELECT DER_PROJECT_ID, TECHNOLOGY_TYPE, COUNT(*) FROM TCGACDS.ECM001_DER_INTERCONN EDI
       where not exists (select 1 from TCGACDS.GCM_V_TRANSFORMER T where 
       FEATURE_NAME in ('OH_TRANSFORMER','UG_TRANSFORMER')
       and EDI.STRUCTURE=T.STRUCTURE_NUMBER)
       and EDI.STRUCTURE IS NOT NULL
       and DER_PROJECT_ID NOT IN
                                     (  SELECT DISTINCT LINE_DEVICE_NO
                                        FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL)
                                                       GROUP BY DER_PROJECT_ID, TECHNOLOGY_TYPE
                                                       )
UNION
----with sync machine consideration
SELECT '1.07-DER-TECH Dropped in GCM#' as Category, COUNT(*) as count,
CASE WHEN COUNT(*) > 0 THEN 'Failed' ELSE 'Passed' END as Comments  FROM 

( select * from (

select DER_PROJECT_ID, TECHNOLOGY_TYPE FROM TCGACDS.ECM001_DER_INTERCONN ECM
where STRUCTURE IS NOT NULL 
AND DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null ) 
AND DER_PROJECT_ID NOT IN ( select  DER_PROJECT_ID from (
( SELECT EcmDS.DER_PROJECT_ID, TECHNOLOGY_TYPE  FROM TCGACDS.GCM_CONN_DER_DS EcmDS 
UNION SELECT DISTINCT SMDS.DER_PROJECT_ID, TECHNOLOGY_TYPE FROM TCGACDS.GCM_CONN_DER_SYNC_MACHINE_DS SMDS)
UNION SELECT DISTINCT DER_PROJECT_ID, TECHNOLOGY_TYPE FROM TCGACDS.ECM001_DER_INTERCONN EDI
       where STRUCTURE NOT IN (select STRUCTURE_NUMBER from TCGACDS.GCM_V_TRANSFORMER T where 
       FEATURE_NAME in ('OH_TRANSFORMER','UG_TRANSFORMER') )
       AND STRUCTURE IS NOT NULL 
       ))

))

UNION                                                     

select '1.20-DER Linked XMFR not in NET9#' as Category, COUNT (DISTINCT DER_PROJECT_ID) as count,
'DQ Issue' as Comments  FROM TCGACDS.ECM001_DER_INTERCONN
where structure in (       
       select structure_number from TCGACDS.GCM_V_TRANSFORMER T where 
       FEATURE_NAME in ('OH_TRANSFORMER','UG_TRANSFORMER')                          
       and id not in (select FEATURE_IDENTIFIER from TCGACDS.NET_9_REF$ ) )
       and DER_PROJECT_ID NOT IN
                                     (  SELECT DISTINCT LINE_DEVICE_NO
                                        FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL)

UNION

select '1.22-DER Linked to MultipleMeter at source#' as Category, COUNT (DISTINCT DER_PROJECT_ID) as count, 'DQ Issue' as Comments  from TCGACDS.ECM001_DER_INTERCONN EDI
       where  exists (select 1 from TCGACDS.GCM_V_TRANSFORMER T where 
       FEATURE_NAME in ('OH_TRANSFORMER','UG_TRANSFORMER')
       and EDI.STRUCTURE=T.STRUCTURE_NUMBER )
       and EDI.ISVC_NUM  in (select USAGEPOINT_NUMBER FROM (
       select USAGEPOINT_NUMBER,  COUNT(METER_MRID) from TCGACDS.GCM_SCIM_DIST_USAGEPOINT_DS
       GROUP BY USAGEPOINT_NUMBER HAVING   COUNT(METER_MRID)>1 )  )
       and DER_PROJECT_ID NOT IN
                                     (  SELECT DISTINCT LINE_DEVICE_NO
                                        FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL)

UNION                                                       
SELECT '1.23-Duplicate DER Generator#' as Category, COUNT (DISTINCT DER_PROJECT_ID) as count, 'Need Review' as Comments from (
select DER_PROJECT_ID from(
select DER_PROJECT_ID, TECHNOLOGY_TYPE, COUNT(*) FROM TCGACDS.GCM_CONN_DER_DS WHERE ASSET_TYPE='GENERATOR'
GROUP BY DER_PROJECT_ID, TECHNOLOGY_TYPE HAVING COUNT(*) >1) )

UNION

SELECT '1.24-DER Generator Cross Over#' as Category, COUNT (DISTINCT DER_PROJECT_ID) as count, 'Need Review' as Comments from (
select DER_PROJECT_ID from(
select DER_PROJECT_ID, PRIMARY_CKT, COUNT(DISTINCT PRIMARY_CKT) FROM TCGACDS.GCM_CONN_DER_DS WHERE ASSET_TYPE='GENERATOR'
GROUP BY DER_PROJECT_ID, PRIMARY_CKT HAVING COUNT(DISTINCT PRIMARY_CKT) >1 ) )

UNION

SELECT '1.25-Duplicate LINE SUB at source#' as Category, COUNT (DISTINCT LINE_DEVICE_NO) as count, 'DQ Issue' as Comments from (
select distinct LINE_DEVICE_NO from (
SELECT LINE_DEVICE_NO, COUNT(1) FROM TCGACDS.LINE_SUB WHERE TYPE<>'CSUB' 
GROUP BY LINE_DEVICE_NO  HAVING COUNT(DISTINCT STRUCTURE_NUMBER)>1)
)

UNION

SELECT '1.26-Duplicate LINE SUB final#' as Category, COUNT (DISTINCT DER_PROJECT_ID) as count, 'DQ Issue' as Comments from (
select DER_PROJECT_ID from(
select DER_PROJECT_ID, TECHNOLOGY_TYPE, COUNT(*) FROM TCGACDS.GCM_CONN_DER_DS WHERE ASSET_TYPE='ENERGY_SOURCE_LINE_SUB'
GROUP BY DER_PROJECT_ID, TECHNOLOGY_TYPE HAVING COUNT(*) >1) )

UNION

SELECT '1.27-DER LINE SUB Cross Over#' as Category, COUNT (DISTINCT DER_PROJECT_ID) as count, 'Need Review' as Comments from (
select DER_PROJECT_ID from(
select DER_PROJECT_ID, PRIMARY_CKT, COUNT(DISTINCT PRIMARY_CKT) FROM TCGACDS.GCM_CONN_DER_DS WHERE ASSET_TYPE='ENERGY_SOURCE_LINE_SUB'
GROUP BY DER_PROJECT_ID, PRIMARY_CKT HAVING COUNT(DISTINCT PRIMARY_CKT) >1 ) )

UNION 
SELECT  '1.30-Total GESW project with line device#' as Category, COUNT (distinct line_device_no ) as count, 'Info' as Comments FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL
UNION                                                      
SELECT  '1.31-Total GESW project without line device#' as Category, COUNT (* ) as count, 'Info' as Comments FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO IS  NULL

UNION
SELECT  '1.32:GESW DER with M3I_Object_Id as unset:' as Category, COUNT(*), ':DQ23304' as Comments
FROM TCGACDS.LINE_SUB WHERE M3I_OBJECT_ID like '%unset%'

UNION 

SELECT  '1.33:DER-STR relation mismatch b/DER file vs GESW:' as Category, COUNT(*), ':DQ35016' as Comments from (

select * from TCGACDS.LINE_SUB a join TCGACDS.ecm001_der_interconn b on a.line_device_no=b.der_project_id
and a.structure_number<>b.structure )

UNION

SELECT  '1.34-Total GESW project matching with hadoop#' as Category, COUNT (distinct line_device_no ) as count, 'Info' as Comments   FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL
                                                       and LINE_SUB.LINE_DEVICE_NO  IN (      
                                                     select DER_PROJECT_ID from TCGACDS.ECM001_DER_INTERCONN EDI )----537, 297
UNION    

SELECT  '1.35 Total GESW project not matching with hadoop#' as Category, COUNT (distinct line_device_no ) as count, 'Info' as Comments  FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL
                                                       and LINE_SUB.LINE_DEVICE_NO NOT IN (      
                                                       select DER_PROJECT_ID from TCGACDS.ECM001_DER_INTERCONN EDI )
                                                    
UNION                                                
SELECT  '1.36-GESW project not matching w/hadoop,kva zero#' as Category, COUNT (distinct line_device_no ) as count, 'DQ Issue' as Comments   FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL
                                                       and LINE_SUB.LINE_DEVICE_NO NOT IN (      
                                                       select DER_PROJECT_ID from TCGACDS.ECM001_DER_INTERCONN EDI )
                                                       and TOTAL_KVA ='0'
UNION

SELECT '1.40-DER with incorrect project status' as Category, COUNT(*), CASE WHEN COUNT(Distinct DER_PROJECT_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments 
FROM TCGACDS.ECM001_DER_INTERCONN WHERE PROJECT_STATUS NOT IN ('PTO ISSUED', 'PENDING PTO','PENDING')

UNION
SELECT '1.41-DER with Application Date null' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE Application_date is null

UNION
SELECT '1.42-DER with PTO Date null' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE PTO_DATE is null

UNION
SELECT '1.43-DER with name plate null' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE NAME_PLATE_CAPACITY is null

UNION 

SELECT '1.44-DER w/Circuit Invalid' as Category, COUNT(*), 'Info' as Comments
FROM (

SELECT COUNT(DER_PROJECT_ID) FROM TCGACDS.ECM001_DER_INTERCONN WHERE
(CIRCUIT_NO NOT IN (SELECT CIRCUIT_NO FROM TCGACDS.CIRCUIT_HEAD)
)
AND STRUCTURE IS NOT NULL )

UNION

SELECT '1.45-DER w/Circuit null' as Category, COUNT(*), 'Info' as Comments
FROM (
SELECT COUNT(DER_PROJECT_ID) FROM TCGACDS.ECM001_DER_INTERCONN WHERE
CIRCUIT_NO IS NULL)

UNION
SELECT '1.46-DER w/SubNo null' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE SUBSTATION_NO IS NULL AND STRUCTURE IS NOT NULL

UNION

SELECT '1.47-DER w/SubNo invalid' as Category, COUNT(*), 'Info' as Comments from (
SELECT COUNT(DER_PROJECT_ID) FROM TCGACDS.ECM001_DER_INTERCONN WHERE
(SUBSTATION_NO NOT IN (SELECT SUBSTATION_NO FROM TCGACDS.SUBSTATION)
)
AND STRUCTURE IS NOT NULL )


UNION

SELECT '1.48- DER with new or invalid TARIFF wrt prod' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE TARIFF NOT IN ('RULE 21 X','WDAT','NEM','RULE 21','QF','RULE 21 NX')

UNION

select '1.49- DER with Tech Type not in lookup#' as Category, count (*) as COUNT, 
'NeedReview' as Comments from (

select COUNT(DISTINCT DER_PROJECT_ID) from TCGACDS.ECM001_DER_INTERCONN where TECHNOLOGY_TYPE NOT IN (
select GCM_TECHNOLOGY_TYPE from TCGACDS.GCM_DER_TECHNOLOGY_TYPES_LOOK_UP) 
AND STRUCTURE IS NOT NULL );