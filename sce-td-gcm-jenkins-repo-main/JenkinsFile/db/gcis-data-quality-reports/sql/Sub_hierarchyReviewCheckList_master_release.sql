-- This report validates SSPH and highlights manual review action needs
-- Last Modified date:1/18/2022
-----------------------------------------------------------

column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10

--Count of node with sub type null in final
select '1.0:Sub without sub type:' as Category, Count(*) as Count, ':Info' as Comments FROM 
TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where sub_type is null
UNION
---count of new node in new stag with sub_type null
select '1.1:New Sub without sub type:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments 
FROM (
select sub_name, sub_id, sub_type from TCGACDS.GCM_SUB_HIER_FAC_META_STG where sub_type is null
MINUS
select sub_name, sub_id, sub_type from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where sub_type is null)
UNION

-- count of sub with sub no null in the final
select '2.0:Sub without sub no:' as Category, Count(*) as Count, ':Info' as Comments FROM (
select sub_name, sub_id, sub_no from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where sub_no is null)
UNION

---count of new node in stage with sub no null
select '2.1:New Sub without sub no:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, sub_no from TCGACDS.GCM_SUB_HIER_FAC_META_STG where sub_no is null
MINUS
select sub_name, sub_id, sub_no from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where sub_no is null)
UNION
--count of sub with primary voltage null in the final
select '3.0:Sub without prim volt:' as Category, Count(*) as Count, ':Info' as Comments FROM (
select sub_name, sub_id, PRIM_VOLTAGE from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and PRIM_VOLTAGE is null
)
UNION
---count of new sub without primary voltage
select '3.1:New Sub without prim volt:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, PRIM_VOLTAGE from TCGACDS.GCM_SUB_HIER_FAC_META_STG where node_category <>'CIRCUIT' and PRIM_VOLTAGE is null

MINUS
select sub_name, sub_id, PRIM_VOLTAGE from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and PRIM_VOLTAGE is null

)
UNION
--count of sub with secondary voltage null
select '3.2:Sub without sec volt:' as Category, Count(*) as Count, ':Info' as Comments FROM (
select sub_name, sub_id, SEC_VOLTAGE from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and SEC_VOLTAGE is null
)
UNION
---count of new sub without SEC_VOLTAGE voltage
select '3.3:New Sub without sec volt:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, SEC_VOLTAGE from TCGACDS.GCM_SUB_HIER_FAC_META_STG where node_category <>'CIRCUIT' and SEC_VOLTAGE is null
MINUS
select sub_name, sub_id, SEC_VOLTAGE from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and SEC_VOLTAGE is null
)

UNION
--count of sub with STATIC_SEC_VOLT static voltage null
select '3.4:Sub without sec static volt:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, STATIC_SEC_VOLT from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and STATIC_SEC_VOLT is null
)

UNION
---count of new sub without SEC_VOLTAGE voltage
select '3.5:New Sub without sec static volt:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, STATIC_SEC_VOLT from TCGACDS.GCM_SUB_HIER_FAC_META_STG where node_category <>'CIRCUIT' and STATIC_SEC_VOLT is null
MINUS
select sub_name, sub_id, STATIC_SEC_VOLT from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and STATIC_SEC_VOLT is null
)
UNION
--count of sub with primary static voltage null [ question- need analysis how static available when primary voltage null]
select '3.6:Sub without prim static volt:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, STATIC_PRIM_VOLT from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and STATIC_PRIM_VOLT is null
)
UNION
---count of new sub without SEC_VOLTAGE voltage [ question- need analysis how static available when primary voltage null]

select '3.7:New Sub without prim static volt:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, STATIC_PRIM_VOLT from TCGACDS.GCM_SUB_HIER_FAC_META_STG where node_category <>'CIRCUIT' and STATIC_PRIM_VOLT is null
MINUS
select sub_name, sub_id, STATIC_PRIM_VOLT from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and STATIC_PRIM_VOLT is null
)
UNION
----count of substation with in service date is null
select '4.0:Sub without in service date:' as Category, Count(*) as Count, ':Info' as Comments FROM (
select sub_name, sub_id, IN_SERVICE_DATE from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and IN_SERVICE_DATE is null
)
UNION
--count of new substation with in service date null
select '4.1:New Sub without in service date:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, IN_SERVICE_DATE from TCGACDS.GCM_SUB_HIER_FAC_META_STG where node_category <>'CIRCUIT' and IN_SERVICE_DATE is null
minus
select sub_name, sub_id, IN_SERVICE_DATE from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and IN_SERVICE_DATE is null
)
UNION
--- count of subs in final with lat/long null
select '5.0:Sub without in lat long:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, LATITUDE,LONGITUDE from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL 
where node_category <>'CIRCUIT' and LATITUDE is null and LONGITUDE is null )

--UNION
------lat long present in source missing in final if any
--
--select * from tcgacds.el_substation a where  not exists
--(select b.sub_id from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL b where a.sce_substation_id=b.sub_id and b.node_category <>'CIRCUIT' )
--and a.LATITUDE is null and b.LONGITUDE is null)

UNION
--new sub with lat long null  [ need analysis]
select '5.1:NewSub without in lat long:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id, LATITUDE,LONGITUDE from TCGACDS.GCM_SUB_HIER_FAC_META_STG where node_category <>'CIRCUIT' and LATITUDE is null and LONGITUDE is null
minus
select sub_name, sub_id, LATITUDE,LONGITUDE from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and LATITUDE is null and LONGITUDE is null
)

UNION

-- count of node without inclusion date in the final

select '5.2:Sub without inclusion date:' as Category, Count(*) as Count, ':Info' as Comments FROM (
select sub_name, sub_id,HIER_INCLUSION_DATE from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and HIER_INCLUSION_DATE is null)
UNION
---count of sub with master key null
select '5.3:Sub without master key:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select sub_name, sub_id,MASTER_KEY from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category <>'CIRCUIT' and MASTER_KEY is null)
UNION
--Count of abank in stage not defined admin hierarchy 
select '5.4:Abank without AOR defined:' as Category, Count(*) as Count, ':Info' as Comments FROM (
select * from TCGACDS.GCM_SUB_HIER_FAC_META_STG WHERE BANK_TYPE ='A-BANK' AND NODE_CATEGORY <>'CIRCUIT' AND SUB_NO NOT IN (
select SUB_NO from TCGACDS.GCM_SUB_HIER_ADMN_FINAL )
)
UNION
--count of new abank not defined in admin hierarchy
select '5.5:NewAbank without AOR defined:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select SUB_NAME, SUB_NO from TCGACDS.GCM_SUB_HIER_FAC_META_STG
WHERE BANK_TYPE ='A-BANK' AND NODE_CATEGORY <>'CIRCUIT' AND SUB_NO NOT IN (
select SUB_NO from TCGACDS.GCM_SUB_HIER_ADMN_FINAL )

MINUS

select SUB_NAME, SUB_NO from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL
WHERE BANK_TYPE ='A-BANK' AND NODE_CATEGORY <>'CIRCUIT' AND SUB_NO NOT IN (
select SUB_NO from TCGACDS.GCM_SUB_HIER_ADMN_FINAL )
)

UNION
---count of pole top sub not in service config
select '5.6:POLE TOP w/o defined service config:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select SUB_NAME, SUB_NO from TCGACDS.GCM_SUB_HIER_FAC_META_STG where NODE_CATEGORY <>'CIRCUIT' 
and sub_name like '%P.T.' and  SUB_NAME NOT IN (
select sub_name from TCGACDS.GCM_SUB_HIER_CNFG_MANUAL_REVIEW )
)

UNION
---- sub with sub no null in master key final
select '5.7:Sub without sub no in master key:' as Category, Count(*) as Count, ':Info' as Comments FROM (
select *  from TCGACDS.GCM_SUB_HIER_MASTER_KEY_REGISTRY_FINAL WHERE INCLUDE_HIER ='TRUE' AND SUB_NO IS NULL
)
UNION
--- New master key for review
select '5.8:New master key for review:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select * from TCGACDS.GCM_SUB_HIER_MASTER_KEY_REGISTRY_STG WHERE REVIEW_FLAG = 'TRUE' 
)

UNION
--- Duplicate master key

select '5.9:Sub with more than 1 master key:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select * from TCGACDS.GCM_SUB_HIER_MASTER_KEY_REGISTRY_STG where sub_name in (
select Sub_name from (
select a.Sub_name, a.LASTMODIFIED_SOR , count(distinct a.MASTER_KEY) from TCGACDS.GCM_SUB_HIER_MASTER_KEY_REGISTRY_STG A
inner join TCGACDS.GCM_SUB_HIER_MASTER_KEY_REGISTRY_STG B on a.Sub_name=b.sub_name and a.SUB_NO=b.SUB_NO
and a.SECTION=b.SECTION and ROUND(a.STD_PRIM_VOLT - b.STD_PRIM_VOLT) <3.1
group by a.Sub_name, a.LASTMODIFIED_SOR having count(distinct a.MASTER_KEY)>1 )) 
)

UNION
-- Any node in the published hierarchy and missing inclusion date
select '6.0:Sub published w/o inclusion date:' as Category, Count(*) as Count, CASE WHEN COUNT(*) > 0 THEN ':Review'
ELSE ':Passed' END as Comments FROM (
select * from TCGACDS.GCM_SUB_HIER_MASTER_KEY_REGISTRY_FINAL WHERE REVIEW_FLAG = 'TRUE' and HIER_INCLUSION_DATE is null and INCLUDE_HIER ='TRUE'
)
UNION
----circuit in gesw not in ssph  stg
select '6.1:Circuit in GESW not in SSPH:' as Category, Count(*) as Count, ':Info' as Comments FROM (
select * from tcgacds.circuit_head where circt_id not in (
select SUB_ID from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category ='CIRCUIT')
)

----circuit in ssph not in circuit
UNION

select '6.2:Circuit in SSPH not in GESW:' as Category, Count(*) as Count, ':Info' as Comments FROM (
select sub_id as ckt_id, sub_name as circuit_name, REFERENCE_SOR  from TCGACDS.GCM_SUB_HIER_FAC_META_FINAL where node_category ='CIRCUIT' and sub_id not in (
select circt_id from tcgacds.circuit_head )
);


