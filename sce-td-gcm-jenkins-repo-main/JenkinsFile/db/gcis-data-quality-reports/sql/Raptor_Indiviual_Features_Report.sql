-- This report validates Total Features count - Base table vs Service
-- Last Modified date: 4/25/2023
--Indiviual Features count - Base table vs Service
--Total Features count - Base table vs Service
--DCC Raptor Total Features count - Base table vs Service
----------------------------------------------------------------------------------------------

select BT.CIRCUIT_NAME AS CIRCUIT_NAME, BT.Circuit_version AS Circuit_version, BT.RAPTOR_RUN_DATE AS RAPTOR_RUN_DATE, BT.TotalCount AS BaseTable_FeaturesCount, SVC.TotalCount AS Service_FeaturesCount
 from (select A.CIRCUIT_NAME, A.Circuit_version,A.RAPTOR_RUN_DATE, x.type, x.TotalCount 
         from TCGACDS.GCM_RAPTOR_LOGS A, 
              XMLTABLE('/DistributionConnectivity/Statistics/Statistic' passing a.Logs_output
               columns Type       VARCHAR2(1000) PATH 'Type',
                       TotalCount VARCHAR2(1000) PATH 'TotalCount') x,
              (select circuit_name,Max(raptor_run_date) Mraptor_run_date 
                 from TCGACDS.gcm_raptor_logs 
               group by circuit_name) MR
        where A.circuit_name    = MR.circuit_name 
          and A.raptor_run_date = MR.Mraptor_run_date
          and type              = 'BaseTableStats'
      ) BT, 
      (select A.CIRCUIT_NAME, A.Circuit_version,A.RAPTOR_RUN_DATE, x.type, x.TotalCount 
         from TCGACDS.GCM_RAPTOR_LOGS A, 
              XMLTABLE('/DistributionConnectivity/Statistics/Statistic' passing a.Logs_output
               columns Type       VARCHAR2(1000) PATH 'Type',
                       TotalCount VARCHAR2(1000) PATH 'TotalCount') x,
              (select circuit_name,Max(raptor_run_date) Mraptor_run_date 
                 from TCGACDS.gcm_raptor_logs 
               group by circuit_name) MR
        where A.circuit_name    = MR.circuit_name 
          and A.raptor_run_date = MR.Mraptor_run_date
          and type              = 'SCIMStats'
      ) SVC 
where BT.CIRCUIT_NAME    =  SVC.CIRCUIT_NAME 
  and BT.Circuit_version =  SVC.Circuit_version 
  and BT.RAPTOR_RUN_DATE =  SVC.RAPTOR_RUN_DATE
order by BT.CIRCUIT_NAME