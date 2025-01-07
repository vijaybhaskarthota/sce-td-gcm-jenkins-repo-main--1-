-- This report validates Synch Machine from source to final and explains the reasons for the Synch Machines.
-- Last Modified date: 10/27/2021
-- Update Comments: 
    --9/14: Added query for Synch Machine attributes Null data check
    --10/27:Replaced query for 'Synch Machine attributes Null data check'
----------------------------------------------------------------------------------------------

column Category heading "Category" Format a54
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a7 

-- Total DER projects from Hadoop --389322
( select '1.Total DER projects from Hadoop' as Category, count(*) as COUNT, 'Info' as Comments  from (
select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM ) )

UNION
--No. of DER projects from Hadoop excluding which are common with GESW projects  -- 388804
( select '1a.DER projects from Hadoop excluding GESW' as Category,   count(*) as COUNT, 'Info' as Comments  from 
( select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM where
DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null) ) )

UNION
--Common of Hadoop and GESW --518
( select  '1b.DER projects common in Hadoop and GESW' as Category,   count(*) as COUNT, 'Info' as Comments  from (
 select distinct DER_PROJECT_ID FROM TCGACDS.ECM001_DER_INTERCONN ECM where
DER_PROJECT_ID in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null) ) )

UNION
-- Expected SM in SM final - coming from hadoop minus GESW
--711
 ( select '2.Expected Synch Machine in SM SCIM final' as Category, count(distinct DER_PROJECT_ID) as COUNT, 'Info' as Comments  from ( Select distinct ECM.DER_PROJECT_ID , 
 CASE WHEN TL.DER_SOURCE_TECH_TYPE is NULL THEN 'SM' 
 WHEN CL.NON_INVERTER is NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.NON_INVERTER is NOT NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.INVERTER is NOT NULL THEN 'IV' END as IVORSM
 FROM TCGACDS.ECM001_DER_INTERCONN ECM 
left join TCGACDS.GCM_DER_TEchnology_types_look_up TL
on ECM.technology_type = TL.gcm_technology_type
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP CL
on TL.DER_SOURCE_TECH_TYPE = CL.technology_type
left join TCGACDS.Gcm_Der_Inverter_Data Idata
on ECM.DER_PROJECT_ID = Idata.DER_PROJECT_ID and TL.DER_SOURCE_TECH_TYPE = Idata.technology_type and CL.technology_type = Idata.technology_type 
where ECM.DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)
--and ECM.DER_PROJECT_ID = 'GFID7161'
)
where IVORSM = 'SM' )

UNION




-- out of 711, having SM data -- SM data may be null but entry present in Inv DAta table for proj and tech type
--18
 ( select '2a. Expected Synch Machine, having SM data' as Category, count(distinct DER_PROJECT_ID) as COUNT, 'Info' as Comments from ( Select distinct ECM.DER_PROJECT_ID , 
 CASE WHEN TL.DER_SOURCE_TECH_TYPE is NULL THEN 'SM' 
 WHEN CL.NON_INVERTER is NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.NON_INVERTER is NOT NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.INVERTER is NOT NULL THEN 'IV' END as IVORSM
 FROM TCGACDS.ECM001_DER_INTERCONN ECM 
left join TCGACDS.GCM_DER_TEchnology_types_look_up TL
on ECM.technology_type = TL.gcm_technology_type
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP CL
on TL.DER_SOURCE_TECH_TYPE = CL.technology_type 
left join TCGACDS.Gcm_Der_Inverter_Data Idata
--on ECM.DER_PROJECT_ID = Idata.DER_PROJECT_ID and TL.DER_SOURCE_TECH_TYPE = Idata.technology_type and CL.technology_type = Idata.technology_type 
on ECM.DER_PROJECT_ID = Idata.DER_PROJECT_ID 
and ECM.technology_type = TL.gcm_technology_type
and TL.DER_SOURCE_TECH_TYPE = CL.technology_type 
and CL.technology_type = Idata.technology_type
where ECM.DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)
--and ECM.DER_PROJECT_ID = 'GFID7161'
and Idata.DER_PROJECT_ID is not null
)
where IVORSM = 'SM' )

UNION

-- NOt having SM data but still modeled as SM
--693

( select '2b. Expected Synch Machine, not having SM data' as Category, count(distinct DER_PROJECT_ID)  as COUNT, 'Info' as Comments from (
 select distinct DER_PROJECT_ID from ( Select distinct ECM.DER_PROJECT_ID , 
 CASE WHEN TL.DER_SOURCE_TECH_TYPE is NULL THEN 'SM' 
 WHEN CL.NON_INVERTER is NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.NON_INVERTER is NOT NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.INVERTER is NOT NULL THEN 'IV' END as IVORSM
 FROM TCGACDS.ECM001_DER_INTERCONN ECM 
left join TCGACDS.GCM_DER_TEchnology_types_look_up TL
on ECM.technology_type = TL.gcm_technology_type
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP CL
on TL.DER_SOURCE_TECH_TYPE = CL.technology_type
left join TCGACDS.Gcm_Der_Inverter_Data Idata
on ECM.DER_PROJECT_ID = Idata.DER_PROJECT_ID and TL.DER_SOURCE_TECH_TYPE = Idata.technology_type and CL.technology_type = Idata.technology_type 
where ECM.DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)

)
where IVORSM = 'SM'

Minus

select distinct DER_PROJECT_ID from ( Select distinct ECM.DER_PROJECT_ID , 
 CASE WHEN TL.DER_SOURCE_TECH_TYPE is NULL THEN 'SM' 
 WHEN CL.NON_INVERTER is NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.NON_INVERTER is NOT NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.INVERTER is NOT NULL THEN 'IV' END as IVORSM
 FROM TCGACDS.ECM001_DER_INTERCONN ECM 
left join TCGACDS.GCM_DER_TEchnology_types_look_up TL
on ECM.technology_type = TL.gcm_technology_type
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP CL
on TL.DER_SOURCE_TECH_TYPE = CL.technology_type 
left join TCGACDS.Gcm_Der_Inverter_Data Idata
--on ECM.DER_PROJECT_ID = Idata.DER_PROJECT_ID and TL.DER_SOURCE_TECH_TYPE = Idata.technology_type and CL.technology_type = Idata.technology_type 
on ECM.DER_PROJECT_ID = Idata.DER_PROJECT_ID 
and ECM.technology_type = TL.gcm_technology_type
and TL.DER_SOURCE_TECH_TYPE = CL.technology_type 
and CL.technology_type = Idata.technology_type
where ECM.DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)
and Idata.DER_PROJECT_ID is not null
)
where IVORSM = 'SM' ) )


UNION


-- Linked to Invalid STR
--76

( select  '2c.Synch Machine Dropped due to Invalid Structure' as Category, count(DER_PROJECT_ID)  as COUNT, 
CASE WHEN count(DER_PROJECT_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from (
 select distinct DER_PROJECT_ID, STRUCTURE, IVORSM from ( Select distinct ECM.DER_PROJECT_ID , ECM.STRUCTURE, 
 CASE WHEN TL.DER_SOURCE_TECH_TYPE is NULL THEN 'SM' 
 WHEN CL.NON_INVERTER is NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.NON_INVERTER is NOT NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.INVERTER is NOT NULL THEN 'IV' END as IVORSM
 FROM TCGACDS.ECM001_DER_INTERCONN ECM 
left join TCGACDS.GCM_DER_TEchnology_types_look_up TL
on ECM.technology_type = TL.gcm_technology_type
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP CL
on TL.DER_SOURCE_TECH_TYPE = CL.technology_type
where ECM.DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)
--and ECM.DER_PROJECT_ID = 'GFID7161'
) TAB  left join TCGACDS.GCM_V_TRANSFORMER T   
on TAB.STRUCTURE=T.STRUCTURE_NUMBER and T.FEATURE_NAME in ('OH_TRANSFORMER','UG_TRANSFORMER')
where T.STRUCTURE_NUMBER is NULL
and TAB.IVORSM = 'SM' ) )

UNION

--Not in Net9
--0
( select '2d.Synch Machine Linked XMFR Not in NET9' as Category, count(DER_PROJECT_ID)  as COUNT, 
CASE WHEN count(DER_PROJECT_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments   from ( 
select distinct DER_PROJECT_ID, STRUCTURE, IVORSM from ( Select distinct ECM.DER_PROJECT_ID , ECM.STRUCTURE, 
 CASE WHEN TL.DER_SOURCE_TECH_TYPE is NULL THEN 'SM' 
 WHEN CL.NON_INVERTER is NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.NON_INVERTER is NOT NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.INVERTER is NOT NULL THEN 'IV' END as IVORSM
 FROM TCGACDS.ECM001_DER_INTERCONN ECM 
left join TCGACDS.GCM_DER_TEchnology_types_look_up TL
on ECM.technology_type = TL.gcm_technology_type
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP CL
on TL.DER_SOURCE_TECH_TYPE = CL.technology_type
where ECM.DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)
--and ECM.DER_PROJECT_ID = 'GFID7161'
) TAB  left join TCGACDS.GCM_V_TRANSFORMER T   
on TAB.STRUCTURE=T.STRUCTURE_NUMBER and T.FEATURE_NAME in ('OH_TRANSFORMER','UG_TRANSFORMER')
where T.STRUCTURE_NUMBER is NOT NULL
and TAB.IVORSM = 'SM'
and T.id not in (select FEATURE_IDENTIFIER from TCGACDS.NET_9_REF$)
) )

UNION
--Multiple meter
--1
( select '2e.Synch Machine linked to Multiple Meter' as Category, count(DER_PROJECT_ID)  as COUNT, 
CASE WHEN count(DER_PROJECT_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from ( 
 select distinct DER_PROJECT_ID, STRUCTURE, ISVC_NUM, IVORSM from ( Select distinct ECM.DER_PROJECT_ID , ECM.STRUCTURE, ECM.ISVC_NUM,
 CASE WHEN TL.DER_SOURCE_TECH_TYPE is NULL THEN 'SM' 
 WHEN CL.NON_INVERTER is NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.NON_INVERTER is NOT NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.INVERTER is NOT NULL THEN 'IV' END as IVORSM
 FROM TCGACDS.ECM001_DER_INTERCONN ECM 
left join TCGACDS.GCM_DER_TEchnology_types_look_up TL
on ECM.technology_type = TL.gcm_technology_type
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP CL
on TL.DER_SOURCE_TECH_TYPE = CL.technology_type
where ECM.DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)
--and ECM.DER_PROJECT_ID = 'GFID7161'
) TAB  left join TCGACDS.GCM_V_TRANSFORMER T   
on TAB.STRUCTURE=T.STRUCTURE_NUMBER and T.FEATURE_NAME in ('OH_TRANSFORMER','UG_TRANSFORMER')
where T.STRUCTURE_NUMBER is NOT NULL
and TAB.IVORSM = 'SM'
and TAB.ISVC_NUM  in (select USAGEPOINT_NUMBER FROM (
       select USAGEPOINT_NUMBER,  COUNT(METER_MRID) from TCGACDS.GCM_V_SCIM_DIST_USAGEPOINT_DS
       GROUP BY USAGEPOINT_NUMBER HAVING   COUNT(METER_MRID)>1)  )
) )

UNION

--Other dropped due to Fuel cell - manual check
-- Other dropped  --82 /0
( select '2f. Synch Machine dropped due to other Reasons' as Category, count(distinct DER_PROJECT_ID )  as COUNT, 
CASE WHEN count(distinct DER_PROJECT_ID ) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from
( 
select distinct DER_PROJECT_ID  from (
 select distinct DER_PROJECT_ID,TECHNOLOGY_TYPE,  STRUCTURE,ISVC_NUM,  IVORSM from ( Select distinct ECM.DER_PROJECT_ID , ECM.TECHNOLOGY_TYPE, ECM.STRUCTURE,  ECM.ISVC_NUM,
 CASE WHEN TL.DER_SOURCE_TECH_TYPE is NULL THEN 'SM' 
 WHEN CL.NON_INVERTER is NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.NON_INVERTER is NOT NULL and CL.INVERTER is NULL THEN 'SM'
 WHEN CL.INVERTER is NOT NULL THEN 'IV' END as IVORSM
 FROM TCGACDS.ECM001_DER_INTERCONN ECM 
left join TCGACDS.GCM_DER_TEchnology_types_look_up TL
on ECM.technology_type = TL.gcm_technology_type
left join TCGACDS.GCM_DER_TECHTYPE_INV_LOOK_UP CL
on TL.DER_SOURCE_TECH_TYPE = CL.technology_type
where ECM.DER_PROJECT_ID not in (select LINE_DEVICE_NO from TCGACDS.LINE_SUB where TYPE <> 'CSUB' and LINE_DEVICE_NO is not null)
--and ECM.DER_PROJECT_ID = 'GFID7161'
) TAB  left join TCGACDS.GCM_V_TRANSFORMER T   
on TAB.STRUCTURE=T.STRUCTURE_NUMBER and T.FEATURE_NAME in ('OH_TRANSFORMER','UG_TRANSFORMER')
where T.STRUCTURE_NUMBER is NOT NULL
and TAB.IVORSM = 'SM'   
and T.id in (select FEATURE_IDENTIFIER from TCGACDS.NET_9_REF$)
and TAB.ISVC_NUM not in (select USAGEPOINT_NUMBER FROM (
       select USAGEPOINT_NUMBER,  COUNT(METER_MRID) from TCGACDS.GCM_V_SCIM_DIST_USAGEPOINT_DS
       GROUP BY USAGEPOINT_NUMBER HAVING   COUNT(METER_MRID)>1)  )
)
Minus
select distinct DER_PROJECT_ID 
from TCGACDS.GCM_CONN_DER_SYNC_MACHINE_DS SMDS where asset_type = 'SYNCHRONOUS_MACHINE'
) )

UNION


-- actual in SM final
--552
( select '3. Actual Synch Machine in SM SCIM final' as Category, count(distinct DER_PROJECT_ID) as COUNT, 'Info' as Comments
from TCGACDS.GCM_CONN_DER_SYNC_MACHINE_DS SMDS where asset_type = 'SYNCHRONOUS_MACHINE' );


--==================================================================================================

-- Synch Machine attributes Null data  check

( select 'SM Data with subTransientReactancePer as NULL' as Category, count(distinct SMDS.DER_PROJECT_ID) as COUNT, 
 CASE WHEN count(distinct SMDS.DER_PROJECT_ID) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments 
from TCGACDS.GCM_CONN_DER_SYNC_MACHINE_DS SMDS
inner join TCGACDS.GCM_DER_INVERTER_DATA Idata
on SMDS.der_project_id = Idata.der_project_id 
where Idata.der_sub_transient_reactance_percentage is null);