-- This report validates DER from source to final and explains the reasons for the DERs.
-- Last Modified date: 10/11/2021
-----------------------------------------------------------


column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10
-----------------

select '1-DER record in agg file#' as Category, count(DER_PROJECT_ID) as count, 'Info' as Comments FROM TCGACDS.ECM001_DER_INTERCONN ECM
UNION
select '1-Distinct DER in agg file#' as Category, count(DISTINCT DER_PROJECT_ID) as count, 'Info' as Comments FROM TCGACDS.ECM001_DER_INTERCONN ECM

UNION

-- total in ECM but not in  GESW  -- 382484 / 388804
select '1.1-DER in agg file, Not in GESW#' as Category, count(DISTINCT DER_PROJECT_ID) as count, 'Info' as Comments  FROM TCGACDS.ECM001_DER_INTERCONN ECM
where DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)

UNION
--Total projects in DER final  --381104 /387568
 ---this query is relevant to adms code
 
SELECT '1.2-SecondaryDER_in_aggfile_in_Connectivity#', count(DISTINCT ECMDS.DER_PROJECT_ID ) as count, 'Info' as Comments FROM TCGACDS.GCM_CONN_DER_DS ECMDS 

UNION
SELECT '1.21-DER_in_aggfile_with_STR_Null#', count(DISTINCT ECM.DER_PROJECT_ID ) as count, 'Info' as Comments FROM TCGACDS.ECM001_DER_INTERCONN ECM
where ECM.STRUCTURE IS NULL

UNION
----with sync machine consideration
SELECT '1.3-Secondary DER Dropped#' as Category, COUNT(DISTINCT DER_PROJECT_ID) as count,
CASE WHEN COUNT(Distinct DER_PROJECT_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  FROM 
(
(select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM
where STRUCTURE IS NOT NULL AND DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null ) )
MINUS 
( SELECT Distinct EcmDS.DER_PROJECT_ID  FROM TCGACDS.GCM_CONN_DER_DS EcmDS 
UNION SELECT DISTINCT SMDS.DER_PROJECT_ID FROM TCGACDS.GCM_CONN_DER_SYNC_MACHINE_DS SMDS)
)


UNION

select '1.4-DER_Linked_to_Invalid_STR#' as Category, COUNT (DISTINCT DER_PROJECT_ID) as count, 'DQ Issue' as Comments  from TCGACDS.ECM001_DER_INTERCONN EDI
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
  UNION                                                     

select '1.5-DER Linked XMFR not in NET9#' as Category, COUNT (DISTINCT DER_PROJECT_ID) as count, 'DQ Issue' as Comments from TCGACDS.ECM001_DER_INTERCONN EDI
       where  exists (select 1 from TCGACDS.GCM_V_TRANSFORMER T where 
       FEATURE_NAME in ('OH_TRANSFORMER','UG_TRANSFORMER')
       and EDI.STRUCTURE=T.STRUCTURE_NUMBER and id not in (select FEATURE_IDENTIFIER from TCGACDS.NET_9_REF$ ))
       and DER_PROJECT_ID NOT IN
                                     (  SELECT DISTINCT LINE_DEVICE_NO
                                        FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL)

UNION

select '1.6-DER Linked to MultipleMeter#' as Category, COUNT (DISTINCT DER_PROJECT_ID) as count, 'DQ Issue' as Comments  from TCGACDS.ECM001_DER_INTERCONN EDI
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
SELECT  '1.70-Total GESW project with line device#' as Category, COUNT (distinct line_device_no ) as count, 'Info' as Comments FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL
UNION                                                      
SELECT  '1.71-Total GESW project without line device#' as Category, COUNT (* ) as count, 'Info' as Comments FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO IS  NULL

UNION
SELECT  '1.72:GESW DER with M3I_Object_Id as unset:' as Category, COUNT(*), ':DQ23304' as Comments
FROM TCGACDS.LINE_SUB WHERE M3I_OBJECT_ID like '%unset%'

UNION 

SELECT  '1.73:DER-STR relation mismatch b/DER file vs GESW:' as Category, COUNT(*), ':DQ35016' as Comments from (

select * from TCGACDS.LINE_SUB a join TCGACDS.ecm001_der_interconn b on a.line_device_no=b.der_project_id
and a.structure_number<>b.structure )

UNION

SELECT  '1.8-Total GESW project matching with hadoop#' as Category, COUNT (distinct line_device_no ) as count, 'Info' as Comments   FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL
                                                       and LINE_SUB.LINE_DEVICE_NO  IN (      
                                                     select DER_PROJECT_ID from TCGACDS.ECM001_DER_INTERCONN EDI )----537, 297
UNION    

SELECT  '1.9 Total GESW project not matching with hadoop#' as Category, COUNT (distinct line_device_no ) as count, 'Info' as Comments  FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL
                                                       and LINE_SUB.LINE_DEVICE_NO NOT IN (      
                                                       select DER_PROJECT_ID from TCGACDS.ECM001_DER_INTERCONN EDI )
                                                    
UNION                                                
SELECT  '2.0-GESW project not matching w/hadoop,kva zero#' as Category, COUNT (distinct line_device_no ) as count, 'DQ Issue' as Comments   FROM   TCGACDS.LINE_SUB
                                        WHERE      LINE_SUB.TYPE <> 'CSUB'
                                               AND LINE_SUB.LINE_DEVICE_NO
                                                       IS NOT NULL
                                                       and LINE_SUB.LINE_DEVICE_NO NOT IN (      
                                                       select DER_PROJECT_ID from TCGACDS.ECM001_DER_INTERCONN EDI )
                                                       and TOTAL_KVA ='0'
UNION

SELECT '3.0-DER with incorrect project status' as Category, COUNT(*), CASE WHEN COUNT(Distinct DER_PROJECT_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments 
FROM TCGACDS.ECM001_DER_INTERCONN WHERE PROJECT_STATUS NOT IN ('PTO ISSUED', 'PENDING PTO','PENDING')

UNION
SELECT '3.1-DER with Application Date null' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE Application_date is null

UNION
SELECT '3.2-DER with PTO Date null' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE PTO_DATE is null

UNION
SELECT '3.3-Danumatic DER with name plate null' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE NAME_PLATE_CAPACITY is null

UNION 

SELECT '3.4-DER w/leading zero missing for CircuitNo' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE LENGTH(CIRCUIT_NO) <5

UNION
SELECT '3.5-DER w/leading zero missing for SubstationNo' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE LENGTH(SUBSTATION_NO) <4

UNION

SELECT '3.6- DER with new or invalid TARIFF wrt prod' as Category, COUNT(*), 'Info' as Comments
FROM TCGACDS.ECM001_DER_INTERCONN WHERE TARIFF NOT IN ('RULE 21 X','WDAT','NEM','RULE 21','QF','RULE 21 NX');