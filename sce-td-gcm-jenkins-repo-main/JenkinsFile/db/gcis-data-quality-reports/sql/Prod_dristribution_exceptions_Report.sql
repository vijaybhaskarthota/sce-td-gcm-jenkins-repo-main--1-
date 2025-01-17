-- This report validates production distribution exeception
-- Last Modified date: 4/19/2023
----------------------------------------------------------------------------------------------

select '1.Total Key column value in GCM#' as Category, count (distinct KEY_COL_VALUE) as COUNT, 'Info' as Comments FROM
(SELECT GE.KEY_COL_VALUE
FROM TCGACDS.GCM2020_EXCEPTION GE INNER JOIN TCGACDS.GCM_ERROR_CATALOG GEC
ON GE.ERROR_CODE = GEC.ERROR_CODE INNER JOIN TCGACDS.GCM_SERVICE_CATALOG GSC
ON GE.SERVICE_ID=GSC.SERVICE_ID
WHERE GEC.ACTOR = 'IT'
AND GE.SERVICE_ID IN (1003,1010,1006,1004,1008,1007)
AND GE.DATE_TIME_STAMP>(SELECT SYSDATE-CONFIG_VALUE FROM TCGACDS.GCM_CONFIG_VALUES
WHERE GCM_CONFIG_VALUES.CONFIG_KEY='FATAL_ERROR_REPORT_MIN_DATE'))
UNION
select '2.Total Key column value not in GCM#' as Category, count (distinct KEY_COL_VALUE) as COUNT, 'Info' as Comments FROM
(SELECT GE.KEY_COL_VALUE
FROM TCGACDS.GCM2020_EXCEPTION GE,TCGACDS.GCM_SERVICE_CATALOG GSC WHERE GE.ERROR_CODE NOT LIKE '%GCM%'
AND GE.SERVICE_ID=GSC.SERVICE_ID
AND GE.DATE_TIME_STAMP>(SELECT SYSDATE-CONFIG_VALUE FROM TCGACDS.GCM_CONFIG_VALUES
WHERE GCM_CONFIG_VALUES.CONFIG_KEY='FATAL_ERROR_REPORT_MIN_DATE')
AND GE.SERVICE_ID IN (1003,1010,1006,1004,1008,1007));