-- This report validates Production M2S data quality
-- Last Modified date: 9/15/2021
----------------------------------------------------------------------------------------------

column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10

select '1.ISVC in M2S with missing transformer from ODS contains XFMR in GESW' as category, count(DEVICE_LOC_ISVC ),'Info' as Comments
--'ISVC present in M2S DS layer with missing transformer but corresponding STR from ODS030 contains a XFMR in GESW' as EXCEPTION_CATEGORY 
FROM TCGACDS.Gcm_M2s_Association M2S 
where M2S.Transformer_Id is  null AND EXISTS
    (Select 1 From TCGACDS.Ods030_Meter_Dtls ods 
    Where ODS.Isvc_Num=M2S.DEVICE_LOC_ISVC AND  EXISTS 
        (Select 2 from TCGACDS.GCM_V_M2G_TRANSFORMER_SCIM GSW WHERE GSW.Structure_Number=ODS.Serv_Connect_Id))
        and EFFECTIVE_DTTM>=sysdate-(SELECT CONFIG_VALUE FROM TCGACDS.GCM_CONFIG_VALUES WHERE CONFIG_KEY='M2S_QUALITY_DASH_INTERVAL')
UNION   

select '2.ISVC in M2S with missing transformer doesnt match with GESW' as category, count(DEVICE_LOC_ISVC ),'Info' as Comments
--SELECT DEVICE_LOC_ISVC,TRANSFORMER_ID, STRUCT_NO, CIRCUIT_NAME, EFFECTIVE_DTTM, 
--'ISVC present in M2S DS layer where tansformer structure doesn''t match with GESW' as EXCEPTION_CATEGORY 
FROM TCGACDS.GCM_M2S_ASSOCIATION M2S WHERE NOT EXISTS(SELECT 1 FROM TCGACDS.GCM_V_M2G_TRANSFORMER_SCIM GSW
                    WHERE GSW.ID=M2S.TRANSFORMER_ID AND  NVL(GSW.STRUCTURE_NUMBER,0)=NVL(M2S.STRUCT_NO,0) ) 
                    and EFFECTIVE_DTTM>=sysdate-(SELECT CONFIG_VALUE FROM TCGACDS.GCM_CONFIG_VALUES WHERE CONFIG_KEY='M2S_QUALITY_DASH_INTERVAL')
UNION

select '3.ISVC in M2S with missing curcuit doesnt match with GESW' as category, count(DEVICE_LOC_ISVC ),'Info' as Comments
--SELECT DEVICE_LOC_ISVC,TRANSFORMER_ID, STRUCT_NO, CIRCUIT_NAME, EFFECTIVE_DTTM, 
--'ISVC present in M2S DS layer where tansformer curcuit detail doesn''t match with GESW' as EXCEPTION_CATEGORY 
FROM TCGACDS.GCM_M2S_ASSOCIATION M2S WHERE NOT EXISTS (SELECT 1 FROM tcgacds.GCM_V_M2G_TRANSFORMER_SCIM GSW
WHERE GSW.ID=M2S.TRANSFORMER_ID AND  GSW.CIRCUIT_NAME1=M2S.CIRCUIT_NAME) and 
EFFECTIVE_DTTM>=sysdate-(SELECT CONFIG_VALUE FROM TCGACDS.GCM_CONFIG_VALUES WHERE CONFIG_KEY='M2S_QUALITY_DASH_INTERVAL');