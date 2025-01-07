--- Validate Feature table and connectivity consistency,substation network
----FOr test case to pass we should have zero count for all below count o/p   
-- Last Modified date: 01/18/2022
-----------------------------------------------------------


column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10
-----------------


Select '1.1-Cnt of SUB_CONNECT_POINT id not in net_2_ref$#' as Category, count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments   
from tcgacds.SUBSTATION_CONNECT_POINT FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_2_ref$ ref where 
ref.feature_identifier = FTR_TAB.id
) 

UNION


Select '1.2-Cnt of SUBSTATION_BUS id not in net_2_ref$#' as Category, count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments   
from tcgacds.SUBSTATION_BUS FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_2_ref$ ref where 
ref.feature_identifier = FTR_TAB.id
) 

UNION



Select '1.3-Cnt of CIRCUIT_BREAKER id not in net_2_ref$#' as Category, count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments   
from tcgacds.CIRCUIT_BREAKER FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_2_ref$ ref where 
ref.feature_identifier = FTR_TAB.id
) 

UNION



Select '1.4-Cnt of SUB_TRANSFORMER id not in net_2_ref$#' as Category, count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments   
from tcgacds.SUBSTATION_TRANSFORMER FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_2_ref$ ref where 
ref.feature_identifier = FTR_TAB.id
) 

UNION


Select '1.5-Cnt of TRANS_HYPERNODE id not in net_2_ref$#' as Category, count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments   
from tcgacds.TRANS_HYPERNODE FTR_TAB
where 
not exists(
Select (1) from TCGACDS.net_2_ref$ ref where 
ref.feature_identifier = FTR_TAB.id
) 

UNION



--- Validate connectivity model(node link and ref),substation network
Select '1.6-Cnt of net_2_ref$ id not in net_2_node$#' as Category, count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments   
from TCGACDS.net_2_ref$ ref 
where 
not exists(
Select (1) from TCGACDS.net_2_node$ node where 
node.node_id = ref.element_id
)
and ref.element_type = 'N'


UNION

Select '1.7-Cnt of net_2_ref$ id not in net_2_link$#' as Category, count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments   
from TCGACDS.net_2_ref$ ref 
where 
not exists(
Select (1) from TCGACDS.net_2_link$ link where 
link.link_id = ref.feature_identifier
) 

UNION



Select '1.8-Cnt of net_2_link$ id not in net_2_node$#' as Category, count(*) as count, CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments 
 from TCGACDS.net_2_link$ lk where not exists
(
Select 1 from TCGACDS.net_2_node$ nd where lk.START_NODE_ID	= nd.NODE_ID
or lk.END_NODE_ID = nd.NODE_ID
);

