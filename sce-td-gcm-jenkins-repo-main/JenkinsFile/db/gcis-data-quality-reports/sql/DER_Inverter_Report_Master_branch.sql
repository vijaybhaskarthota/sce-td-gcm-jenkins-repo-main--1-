-- This report validates DER Inverter from source to final and explains the reasons for the DER Inverters.
-- Last Modified date: 9/10/2021
----------------------------------------------------------------------------------------------

column Category heading "Category" Format a54
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a7 
--
-- Total DER projects from Hadoop --389322
( select '1.Total DER projects from Hadoop#' as Category, count(*) as COUNT, 'Info' as Comments  from (
select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM ) )

Union
--No. of DER projects from Hadoop excluding which are common with GESW projects  -- 388804
( select '1a.DER projects from Hadoop excluding GESW#' as Category,   count(*) as COUNT, 'Info' as Comments  from 
( select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM where
DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null) ) )

Union
--Common of Hadoop and GESW --518
( select  '1b.DER projects common in Hadoop and GESW#' as Category,   count(*) as COUNT, 'Info' as Comments  from (
 select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM where
DER_PROJECT_ID in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null) ) )

Union
--No. of projects Common of Hadoop and GESW having inverter Data  --138
(select '1c.DERPrj common in Hadoop and GESW having InvData#' as Category, count(*) as COUNT, 'Info' as Comments from ( select distinct ECM.DER_PROJECT_ID From
TCGACDS.ECM001_DER_INTERCONN ECM
inner join TCGACDS.Gcm_Der_Inverter_Data Idata
on ECM.DER_PROJECT_ID = Idata.DER_PROJECT_ID
where ECM.DER_PROJECT_ID in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)
and Idata.Technology_Type in (select TECHNOLOGY_TYPE from TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP where INVERTER='YES') ) )


Union

--Count of DER# for which Invdata recieved --344691
Select '2.DER with InvData Received#' as Category,  count(distinct Idata.DER_PROJECT_ID) as COUNT, 'Info' as Comments
from TCGACDS.Gcm_Der_Inverter_Data Idata
where Idata.Technology_Type in (select TECHNOLOGY_TYPE from TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP where INVERTER='YES')



UNION

-- Count of DER from hadoop src table to which inv data is linked
--319885
(select '3.DER from ECM001 table linked to InvData#' as Category, 
count (distinct ECM.DER_PROJECT_ID) as COUNT , 'Info' as Comments               
from TCGACDS.ECM001_DER_INTERCONN ECM  
left join TCGACDS.GCM_DER_INVERTER_DATA IData 
on ECM.DER_PROJECT_ID = IData.DER_PROJECT_ID
join TCGACDS.GCM_DER_TEchnology_types_look_up Tlookup
on ECM.TECHNOLOGY_TYPE = Tlookup.GCM_TECHNOLOGY_TYPE
and IData.TECHNOLOGY_TYPE = Tlookup.DER_SOURCE_TECH_TYPE
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP Invlookup
on Tlookup.DER_SOURCE_TECH_TYPE = Invlookup.TECHNOLOGY_TYPE
where IData.DER_PROJECT_ID is not null
and Invlookup.inverter = 'YES')


UNION
----No. of DER projects present in DER Final table (or populated in service)
----Note: Only DER with Inverter data or DERs with no Inverter / SM data will be populated in DER Final table. i.e. DERs with SM data will not be present in DER Final table.
--select  'No. of DER projects present in DER Final table (or populated in service)' as Category, count(distinct DER_PROJECT_ID) as Count
--FROM TCGACDS.GCM_CONN_DER_DS DER_DS;  --387054 

--No. of DER proejcts (from above) having inverter data --280820

( select '4.Expected Inverter DER connected to DERSCIM final#' as Category, count (distinct DER_DS.DER_PROJECT_ID) as COUNT , 'Info' as Comments               
from TCGACDS.GCM_CONN_DER_DS DER_DS  
left join TCGACDS.GCM_DER_INVERTER_DATA IData 
on DER_DS.DER_PROJECT_ID = IData.DER_PROJECT_ID
join TCGACDS.GCM_DER_TEchnology_types_look_up Tlookup
on DER_DS.TECHNOLOGY_TYPE = Tlookup.GCM_TECHNOLOGY_TYPE
and IData.TECHNOLOGY_TYPE = Tlookup.DER_SOURCE_TECH_TYPE
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP Invlookup
on Tlookup.DER_SOURCE_TECH_TYPE = Invlookup.TECHNOLOGY_TYPE
where IData.DER_PROJECT_ID is not null
and Invlookup.inverter = 'YES')


Union
--No. of DER projects present in DER Inverter Final table  --280828

( select '4a. Actual DER inverter in Inverter SCIM table#' as Category, count(distinct DER_PROJECT_ID) as COUNT , 'Info' as Comments
from TCGACDS.Gcm_Conn_Der_Inverter_Ds INVDS where asset_type = 'INVERTER' )

Union

--0 --DER inverter dropped in Inverter SCIM table
(select '4b. DER inverter dropped in Inverter SCIM table#' as Category, count(*) as COUNT, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments 
  from (
select Distinct DER_DS.DER_PROJECT_ID             
from TCGACDS.GCM_CONN_DER_DS DER_DS  
left join TCGACDS.GCM_DER_INVERTER_DATA IData 
on DER_DS.DER_PROJECT_ID = IData.DER_PROJECT_ID
join TCGACDS.GCM_DER_TEchnology_types_look_up Tlookup
on DER_DS.TECHNOLOGY_TYPE = Tlookup.GCM_TECHNOLOGY_TYPE
and IData.TECHNOLOGY_TYPE = Tlookup.DER_SOURCE_TECH_TYPE
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP Invlookup
on Tlookup.DER_SOURCE_TECH_TYPE = Invlookup.TECHNOLOGY_TYPE
where IData.DER_PROJECT_ID is not null
and Invlookup.inverter = 'YES'
Minus
select distinct DER_PROJECT_ID
from TCGACDS.Gcm_Conn_Der_Inverter_Ds INVDS where asset_type = 'INVERTER' ) )


Union
--No. of DER with Inverter data should not have been present in DER Inverter final table  --8
-- NG Fuel CELL tech type classified incorrectly. It should be Inverter. 
( select '4c.Additional DER inverter in Inverter SCIM table#' as Category, count(*) as COUNT, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from (
select distinct DER_PROJECT_ID from TCGACDS.Gcm_Conn_Der_Inverter_Ds INVDS where asset_type = 'INVERTER'
Minus 
select distinct DER_DS.DER_PROJECT_ID                 
from TCGACDS.GCM_CONN_DER_DS DER_DS  
left join TCGACDS.GCM_DER_INVERTER_DATA IData 
on DER_DS.DER_PROJECT_ID = IData.DER_PROJECT_ID
join TCGACDS.GCM_DER_TEchnology_types_look_up Tlookup
on DER_DS.TECHNOLOGY_TYPE = Tlookup.GCM_TECHNOLOGY_TYPE
and IData.TECHNOLOGY_TYPE = Tlookup.DER_SOURCE_TECH_TYPE
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP Invlookup
on Tlookup.DER_SOURCE_TECH_TYPE = Invlookup.TECHNOLOGY_TYPE
where IData.DER_PROJECT_ID is not null
and Invlookup.inverter = 'YES' ) )


Union
--No. of DER projects having inverter data but not in Hadoop --24679
( select '5.DER inverter not in Hadoop#' as Category, count(*) as COUNT ,
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from (
select DISTINCT DER_PROJECT_ID from TCGACDS.Gcm_Der_Inverter_Data
where Technology_Type in (select TECHNOLOGY_TYPE from TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP where INVERTER='YES')
Minus
select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM ) )


Union
--Out of 24679, No. of projects from GESW --22
( select '5a.DER inverter not in Hadoop but GESW#' as Category, count(*) as COUNT,
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from (
select DISTINCT DER_PROJECT_ID from TCGACDS.Gcm_Der_Inverter_Data
where Technology_Type in (select TECHNOLOGY_TYPE from TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP where INVERTER='YES')
Minus
select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM )
where DER_PROJECT_ID  in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null) )


Union
--Remaining No. of projects having inverter data but not in Hadoop as well in GESW --24657
( select '5b.DER inverter not in Hadoop and GESW#' as Category, count(*) as COUNT, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from (
select DISTINCT DER_PROJECT_ID from TCGACDS.Gcm_Der_Inverter_Data
where Technology_Type in (select TECHNOLOGY_TYPE from TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP where INVERTER='YES')
Minus
select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM )
where DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null) );