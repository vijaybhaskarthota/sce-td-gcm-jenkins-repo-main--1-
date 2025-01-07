--This report validates THR data
-- Last Modified Date: 10/28/2021
--------------------------------------------------------------------------------------------------
column Category heading "Category" Format a53
column COUNT heading "COUNT" Format a10
column Comments heading "Comments" Format a7


--records from mop-up file
SELECT '1.Records from mop-up file' as Category, COUNT(*) as COUNT, 'Info' as Comments FROM TCGACDS.ECM001_THR_TRANS_LOAD_SETTINGS  -- 2606

UNION

----PT Equipment present in EMS that does not have THR data 
--1000
Select '2.PT Equipment present in EMS with no THR data' as Category, COUNT(*) as COUNT, 'Info' as Comments from (   
SELECT DISTINCT PT.MRID,ID.NAME,PT.GCM_SUBSTATION_ID
      FROM TCGACDS.GCM_SCIM_POWERTRANSFORMER  PT
           LEFT JOIN TCGACDS.GCM_SCIM_POWERTRANSFORMERIDENTIFIER ID
               ON     PT.MRID = ID.POWERTRANSFORMERID
                  AND PT.GCM_JOBID = ID.GCM_JOBID
          LEFT JOIN
           (SELECT EQUIP_NUMBER,
                   PERCENT_Z_NUM,
                   OA_DESC,
                   FA_FIRSTSTAGE_DESC,
                   FA_SECONDSTAGE_DESC,
                   NORMALMVA_NUM,
                   NORMALAMPS_NUM,
                   NWMMVA_NUM,
                   NWMAMPS_NUM,
                   PLLMVA_NUM,
                   PLLAMPS_NUM,
                   PLL_PCT,
                   N1LTELLMVA_NUM,
                   N1LTELLAMPS_NUM,
                   N1LTELLHRS_NUM,
                   N1LTELL_PCT,
                   N1STELLMVA_NUM,
                   N1STELLAMPS_NUM,
                   N1STELLHRS_NUM,
                   N1STELL_PCT,
                   TCA_DATE,
                   YR_BUILT_DESC,
                   REMARKS_DESC,
                   ROW_NUMBER ()
                       OVER (PARTITION BY EQUIP_NUMBER ORDER BY EQUIP_NUMBER)    AS RN
              FROM TCGACDS.ECM001_THR_TRANS_LOAD_SETTINGS) THR
               ON ID.NAME = THR.EQUIP_NUMBER
     WHERE NVL (THR.RN, 1) = 1 AND PT.GCM_JOBID = (SELECT jobid FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID = 'Y') and THR.EQUIP_NUMBER is NULL )
     
UNION

---Present in THR but Equipment not present in EMS   -- 621
Select '3.Present in THR but Equipment not present in EMS' as Category, COUNT(*) as COUNT, 'Info' as Comments from (
SELECT PT.MRID,ID.NAME,PT.GCM_SUBSTATION_ID,THR.EQUIP_NUMBER
      FROM TCGACDS.GCM_SCIM_POWERTRANSFORMER  PT
           LEFT JOIN TCGACDS.GCM_SCIM_POWERTRANSFORMERIDENTIFIER ID
               ON     PT.MRID = ID.POWERTRANSFORMERID
                  AND PT.GCM_JOBID = ID.GCM_JOBID
          RIGHT JOIN
           (SELECT EQUIP_NUMBER,
                   PERCENT_Z_NUM,
                   OA_DESC,
                   FA_FIRSTSTAGE_DESC,
                   FA_SECONDSTAGE_DESC,
                   NORMALMVA_NUM,
                   NORMALAMPS_NUM,
                   NWMMVA_NUM,
                   NWMAMPS_NUM,
                   PLLMVA_NUM,
                   PLLAMPS_NUM,
                   PLL_PCT,
                   N1LTELLMVA_NUM,
                   N1LTELLAMPS_NUM,
                   N1LTELLHRS_NUM,
                   N1LTELL_PCT,
                   N1STELLMVA_NUM,
                   N1STELLAMPS_NUM,
                   N1STELLHRS_NUM,
                   N1STELL_PCT,
                   TCA_DATE,
                   YR_BUILT_DESC,
                   REMARKS_DESC,
                   ROW_NUMBER ()
                       OVER (PARTITION BY EQUIP_NUMBER ORDER BY EQUIP_NUMBER)    AS RN
              FROM TCGACDS.ECM001_THR_TRANS_LOAD_SETTINGS) THR
               ON ID.NAME = THR.EQUIP_NUMBER
     WHERE NVL (THR.RN, 1) = 1 and PT.MRID is NULL )
     
     
UNION

---THR data available for Substation PT from EMS  --1249

SELECT '4.THR data available for Substation PT from EMS' as Category, COUNT(DISTINCT EQUIP_NUMBER) as COUNT, 'Info' as Comments 
 FROM TCGACDS.ECM001_THR_TRANS_LOAD_SETTINGS THR INNER JOIN TCGACDS.GCM_SCIM_POWERTRANSFORMERIDENTIFIER PTID 
ON THR.EQUIP_NUMBER = PTID.NAME


UNION

--- Number of Substations updated with THR data
--509
Select '5.Number of Substations updated with THR data' as Category, COUNT(*) as COUNT, 'Info' as Comments FROM (
  select NAME from TCGACDS.GCM_SCIM_SUBSTATION where GCM_JOBID = (SELECT jobid FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID = 'Y') and GCM_SUBSTATION_ID in   
(SELECT PT.GCM_SUBSTATION_ID
      FROM TCGACDS.GCM_SCIM_POWERTRANSFORMER  PT
           LEFT JOIN TCGACDS.GCM_SCIM_POWERTRANSFORMERIDENTIFIER ID
               ON     PT.MRID = ID.POWERTRANSFORMERID
                  AND PT.GCM_JOBID = ID.GCM_JOBID
           INNER JOIN
           (SELECT EQUIP_NUMBER,
                   PERCENT_Z_NUM,
                   OA_DESC,
                   FA_FIRSTSTAGE_DESC,
                   FA_SECONDSTAGE_DESC,
                   NORMALMVA_NUM,
                   NORMALAMPS_NUM,
                   NWMMVA_NUM,
                   NWMAMPS_NUM,
                   PLLMVA_NUM,
                   PLLAMPS_NUM,
                   PLL_PCT,
                   N1LTELLMVA_NUM,
                   N1LTELLAMPS_NUM,
                   N1LTELLHRS_NUM,
                   N1LTELL_PCT,
                   N1STELLMVA_NUM,
                   N1STELLAMPS_NUM,
                   N1STELLHRS_NUM,
                   N1STELL_PCT,
                   TCA_DATE,
                   YR_BUILT_DESC,
                   REMARKS_DESC,
                   ROW_NUMBER ()
                       OVER (PARTITION BY EQUIP_NUMBER ORDER BY EQUIP_NUMBER)    AS RN
              FROM TCGACDS.ECM001_THR_TRANS_LOAD_SETTINGS) THR
               ON ID.NAME = THR.EQUIP_NUMBER
     WHERE NVL (THR.RN, 1) = 1 AND PT.GCM_JOBID = (SELECT jobid FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID = 'Y')) )