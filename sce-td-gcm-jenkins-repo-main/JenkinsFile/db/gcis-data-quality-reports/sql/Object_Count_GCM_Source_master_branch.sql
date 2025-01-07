--Validate Feature table and connectivity stats to compare GCM vs ODS
-- Last Modified date: 03/06/2023
-----------------------------------------------------------


column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10
-----------------


Select  '1.1-Cnt of AUTOMATIC_RECLOSER#' as Category, 
count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'stats'ELSE 'Passed' END as Comments
from TCGACDS.AUTOMATIC_RECLOSER  FTR_TAB


UNION

Select '1.2-Cnt of BRANCH_LINE_FUSE #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments
from TCGACDS.BRANCH_LINE_FUSE  FTR_TAB



UNION

Select '1.3-Cnt of CAPACITOR_BANK#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments
from TCGACDS.CAPACITOR_BANK  FTR_TAB


UNION

Select '1.4-Cnt of CIRCUIT_HEAD#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments
from TCGACDS.CIRCUIT_HEAD  FTR_TAB


UNION

Select '1.5-Cnt of DIST_HYPERNODE#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments

from TCGACDS.DISTRIBUTION_HYPERNODE  FTR_TAB


UNION

Select '1.6-Cnt of ELBOW#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.ELBOW  FTR_TAB

UNION

Select '1.7-Cnt of ENDBELL#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments  from TCGACDS.ENDBELL  FTR_TAB

UNION

Select '1.8-Cnt of FAULT_INDICATOR' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.FAULT_INDICATOR  FTR_TAB


UNION

Select '1.9-Cnt of FAULT_INTERRUPTER' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.FAULT_INTERRUPTER  FTR_TAB


UNION

Select  '2.1-Cnt of FEED_POINT#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.FEED_POINT  FTR_TAB

UNION

Select '2.2-Cnt of FUSED_CUTOUT#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.FUSED_CUTOUT  FTR_TAB


UNION

Select  '2.3-Cnt of GROUND_BANK#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.GROUND_BANK  FTR_TAB


UNION

Select  '2.4-Cnt of IBANK #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.IBANK  FTR_TAB


UNION

Select '2.5-Cnt of JUNCTION_BAR #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.JUNCTION_BAR  FTR_TAB



UNION

Select '2.6-Cnt of JUNCTION_BAR_PIN#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments  from TCGACDS.JUNCTION_BAR_PIN  FTR_TAB


UNION


Select '2.7-Cnt of LINE_SUB#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments  from TCGACDS.LINE_SUB  FTR_TAB

UNION

Select '2.8-Cnt of NETCOM_MONITOR#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.NETCOM_MONITOR  FTR_TAB

UNION


Select '2.9-Cnt of NETWORK_PROTECTOR#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.NETWORK_PROTECTOR  FTR_TAB

UNION

Select '3.1-Cnt of OHPrimaryConductor#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.OH_PRIMARY_CONDUCTOR  FTR_TAB

UNION

Select '3.2-Cnt of OH_SWITCH#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.OH_SWITCH  FTR_TAB

UNION

Select '3.3-Cnt of OH_TRANSFORMER#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.OH_TRANSFORMER  FTR_TAB


UNION

Select '3.4-Cnt of OH_TRANSFORMER_LOC#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.OH_TRANSFORMER_LOCATION  FTR_TAB

UNION

Select '3.5-Cnt of PE_GEAR_SWITCH#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.PE_GEAR_SWITCH  FTR_TAB

UNION

Select '3.6-Cnt of PEGearSwitchPin#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.PE_GEAR_SWITCH_PIN  FTR_TAB


UNION

Select '3.7-Cnt of POTHEAD#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.POTHEAD  FTR_TAB


UNION

Select  '3.8-Cnt of PRIMARY_METER#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments  from TCGACDS.PRIMARY_METER  FTR_TAB

UNION

Select '3.9-Cnt of SubConnectPoint#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.SUBSTATION_CONNECT_POINT  FTR_TAB


UNION

Select '4.1-Cnt of TAP#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.TAP  FTR_TAB

UNION

Select '4.2-Cnt of TIE_CABLE #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.TIE_CABLE  FTR_TAB

UNION

Select '4.3-Cnt of UG_BUS #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.UG_BUS  FTR_TAB

UNION

Select '4.4-Cnt of UGPrimaryCondcutor id#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.UG_PRIMARY_CONDUCTOR  FTR_TAB


UNION

Select '4.5-Cnt of UG_SWITCH #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.UG_SWITCH  FTR_TAB

UNION

Select '4.6-Cnt of UG_SWITCH_PIN #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.UG_SWITCH_PIN  FTR_TAB

UNION

Select '4.7-Cnt of UG_TRANSFORMER #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.UG_TRANSFORMER  FTR_TAB

UNION

Select '4.8-Cnt of VacFaultInterupter#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.VAC_FAULT_INTERRUPTER  FTR_TAB

UNION

Select '4.9-Cnt of VOLTAGE_REGULATOR #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.VOLTAGE_REGULATOR  FTR_TAB

UNION

--- Validate connectivity model(node link and ref),Dist COnn network
Select '5.1-Cnt of net_9_ref$  #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.net_9_ref$ ref 

UNION

Select '5.2-Cnt of net_9_ref$ featureid#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.net_9_ref$ ref 

UNION

Select '5.3-Cnt of net_9_link$ node #' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'stats'
ELSE 'Passed' END as Comments from TCGACDS.net_9_link$ lk 

UNION

Select '6.1-Cnt of SUB_CONNECT_POINT#' as Category, count(*) as count, 'Stats' as Comments   
from tcgacds.SUBSTATION_CONNECT_POINT FTR_TAB


UNION

Select '6.2-Cnt of SUBSTATION_BUS#' as Category, count(*) as count, 'Stats' as Comments     
from tcgacds.SUBSTATION_BUS FTR_TAB
 

UNION

Select '6.3-Cnt of CIRCUIT_BREAKER#' as Category, count(*) as count, 'Stats' as Comments  
from tcgacds.CIRCUIT_BREAKER FTR_TAB

UNION

Select '6.4-Cnt of SUB_TRANSFORMER#' as Category, count(*) as count, 'Stats' as Comments 
from tcgacds.SUBSTATION_TRANSFORMER FTR_TAB


UNION


Select '6.5-Cnt of TRANS_HYPERNODE#' as Category, count(*) as count, 'Stats' as Comments
from tcgacds.TRANS_HYPERNODE FTR_TAB
 

UNION

--- Validate connectivity model(node link and ref),substation network
Select '6.6-Cnt of net_2_ref$#' as Category, count(*) as count, 'Stats' as Comments  
from TCGACDS.net_2_ref$ ref 


UNION

Select '6.7-Cnt of net_2_ref$#' as Category, count(*) as count, 'Stats' as Comments   
from TCGACDS.net_2_ref$ ref 
 

UNION

Select '6.8-Cnt of net_2_link$#' as Category, count(*) as count, 'Stats' as Comments 
 from TCGACDS.net_2_link$ lk ;