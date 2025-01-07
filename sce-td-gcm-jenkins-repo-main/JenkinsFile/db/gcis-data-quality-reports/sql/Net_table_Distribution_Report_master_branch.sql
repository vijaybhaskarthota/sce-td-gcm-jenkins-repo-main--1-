--Validate Feature table and connectivity consistency,Dist network
--FOr test case to pass we should have zero count for all below count o/p  
-- Last Modified date: 01/18/2022
-----------------------------------------------------------


column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10
-----------------


Select  '1.1-Cnt of AUTOMATIC_RECLOSER id not in net_9_ref$#' as Category, count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments
from tcgacds.AUTOMATIC_RECLOSER  FTR_TAB
where not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)


UNION

Select '1.2-Cnt of BRANCH_LINE_FUSE id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments
from tcgacds.BRANCH_LINE_FUSE  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)


UNION

Select '1.3-Cnt of CAPACITOR_BANK id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments
from tcgacds.CAPACITOR_BANK  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '1.4-Cnt of CIRCUIT_HEAD id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments
from tcgacds.CIRCUIT_HEAD  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '1.5-Cnt of DIST_HYPERNODE id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments

from tcgacds.DISTRIBUTION_HYPERNODE  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '1.6-Cnt of ELBOW id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.ELBOW  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '1.7-Cnt of ENDBELL id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from tcgacds.ENDBELL  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '1.8-Cnt of FAULT_INDICATOR id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.FAULT_INDICATOR  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '1.9-Cnt of FAULT_INTERRUPTER id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.FAULT_INTERRUPTER  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)


UNION

Select  '2.1-Cnt of FEED_POINT id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.FEED_POINT  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '2.2-Cnt of FUSED_CUTOUT id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.FUSED_CUTOUT  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)


UNION

Select  '2.3-Cnt of GROUND_BANK id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.GROUND_BANK  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select  '2.4-Cnt of IBANK id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.IBANK  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)


UNION

Select '2.5-Cnt of JUNCTION_BAR id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.JUNCTION_BAR  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)


UNION

Select '2.6-Cnt of JUNCTION_BAR_PIN id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from tcgacds.JUNCTION_BAR_PIN  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION


Select '2.7-Cnt of LINE_SUB id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from tcgacds.LINE_SUB  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '2.8-Cnt of NETCOM_MONITOR id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.NETCOM_MONITOR  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION


Select '2.9-Cnt of NETWORK_PROTECTOR id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.NETWORK_PROTECTOR  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '3.1-Cnt of OHPrimaryConductor id not in net_9_ref$#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.OH_PRIMARY_CONDUCTOR  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '3.2-Cnt of OH_SWITCH id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.OH_SWITCH  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '3.3-Cnt of OH_TRANSFORMER id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.OH_TRANSFORMER  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)


UNION

Select '3.4-Cnt of OH_TRANSFORMER_LOC id not in net_9_ref$#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.OH_TRANSFORMER_LOCATION  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '3.5-Cnt of PE_GEAR_SWITCH id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.PE_GEAR_SWITCH  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '3.6-Cnt of PEGearSwitchPin id not in net_9_ref$#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.PE_GEAR_SWITCH_PIN  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)


UNION

Select '3.7-Cnt of POTHEAD id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.POTHEAD  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select  '3.8-Cnt of PRIMARY_METER id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments  from tcgacds.PRIMARY_METER  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '3.9-Cnt of SubConnectPoint id not in net_9_ref$#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.SUBSTATION_CONNECT_POINT  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '4.1-Cnt of TAP id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.TAP  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '4.2-Cnt of TIE_CABLE id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.TIE_CABLE  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '4.3-Cnt of UG_BUS id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.UG_BUS  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '4.4-Cnt of UGPrimaryCondcutor id not in net_9_ref$#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.UG_PRIMARY_CONDUCTOR  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)


UNION

Select '4.5-Cnt of UG_SWITCH id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.UG_SWITCH  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '4.6-Cnt of UG_SWITCH_PIN id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.UG_SWITCH_PIN  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '4.7-Cnt of UG_TRANSFORMER id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.UG_TRANSFORMER  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '4.8-Cnt of VacFaultInterupter id not in net_9_ref$#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.VAC_FAULT_INTERRUPTER  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

Select '4.9-Cnt of VOLTAGE_REGULATOR id not in net_9_ref$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from tcgacds.VOLTAGE_REGULATOR  FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_9_ref$ ref where 
ref.feature_identifier =   FTR_TAB.id
)

UNION

--- Validate connectivity model(node link and ref),Dist COnn network
Select '5.1-Cnt of net_9_ref$ id not in net_9_node$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.net_9_ref$ ref 
where 
not exists(
Select (1) from TCGACDS.net_9_node$ node where 
node.node_id = ref.element_id
)
and ref.element_type = 'N'

UNION

Select '5.2-Cnt of net_9_ref$ featureid not in net_9_link$#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.net_9_ref$ ref 
where 
not exists(
Select (1) from TCGACDS.net_9_link$ link where 
link.link_id = ref.feature_identifier
)
and ref.element_type = 'L'

UNION

Select '5.3-Cnt of net_9_link$ nodeid not in net_9_node$ #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'
ELSE 'Passed' END as Comments from TCGACDS.net_9_link$ lk where not exists
(
Select 1 from TCGACDS.net_9_node$ nd where lk.START_NODE_ID = nd.NODE_ID
or lk.END_NODE_ID = nd.NODE_ID
)