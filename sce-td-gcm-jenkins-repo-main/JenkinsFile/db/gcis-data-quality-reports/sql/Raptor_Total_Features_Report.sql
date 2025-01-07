-- This report validates Raptor Total Features count - Base table vs Service
-- Last Modified date: 4/25/2023
----------------------------------------------------------------------------------------------

select COALESCE(BT.CIRCUIT_NAME,SVC.CIRCUIT_NAME) CIRCUIT_NAME,
COALESCE(BT.Circuit_version,SVC.Circuit_version) Circuit_version,
COALESCE(BT.RAPTOR_RUN_DATE,SVC.RAPTOR_RUN_DATE) RAPTOR_RUN_DATE,
COALESCE(BT.FeatureName,SVC.FeatureName) FeatureName,
BT.FeatureCount BaseTable_FeatureCount, SVC.FeatureCount Service_FeatureCount
    from (
        select a.CIRCUIT_NAME, a.Circuit_version,a.RAPTOR_RUN_DATE, a.type, a.TotalCount,a.featurename,sum(a.count) as FeatureCount
        from (
            select a.CIRCUIT_NAME, a.Circuit_version,a.RAPTOR_RUN_DATE, x.type, x.TotalCount,
                case
                    when y.FeatureName in ('OH_PRIMARY_CONDUCTOR','TIE_CABLE','UG_BUS','UG_PRIMARY_CONDUCTOR') then 'ACLineSegment'
                    when y.FeatureName='CIRCUIT_BREAKER' then 'Breaker'
                    when y.FeatureName like '%LOCATION' then 'Cabinet'
                    when y.FeatureName='CAPACITOR_BANK' then 'CapacitorBank'
                    when y.FeatureName='NETCOM_MONITOR' then 'ComEquip'
                    when y.FeatureName='CONNECTIVITY_NODE' then 'ConnectivityNode'
                    when y.FeatureName in ('DER_INT','LINE_SUB') then 'Der-EnergyConsumer'
                    when y.FeatureName='ENDBELL' then 'Endbell'
                    when y.FeatureName in ('FEED_POINT','REDBOOK') then 'EnergySource'
                    when y.FeatureName='FAULT_INDICATOR' then 'FaultIndicator'
                    when y.FeatureName in ('BRANCH_LINE_FUSE','FUSED_CUTOUT') then 'Fuse'
                    when y.FeatureName in ('FAULT_INTERRUPTER','VAC_FAULT_INTERRUPTER') then 'InterrupterUnit'
                    when y.FeatureName='JUNCTION_BAR' then 'Junction'
                    when y.FeatureName='VOLTAGE_REGULATOR' then 'LineRegulator'
                    when y.FeatureName='ELBOW' then 'LoadBreakSwitch'
                    when y.FeatureName='NETWORK_PROTECTOR' then 'NetworkProtector'
                    when y.FeatureName='POTHEAD' then 'Pothead'
                    when y.FeatureName in ('GROUND_BANK_TRANSFORMER','LINE_SUB_TRANSFORMER','OH_TRANSFORMER_UNIT','UG_TRANSFORMER_UNIT') then 'PowerTransformer'
                    when y.FeatureName='AUTOMATIC_RECLOSER' then 'Recloser'
                    when y.FeatureName='STRUCTURE' then 'Structure'
                    when y.FeatureName in ('OH_SWITCH','PE_GEAR_SWITCH','TAP','UG_SWITCH') then 'Switch'
                    when y.FeatureName='TERMINAL' then 'Terminal'
                    when y.FeatureName in ('GROUND_BANK','IBANK','OH_TRANSFORMER','UG_TRANSFORMER') then 'TransformerBank'
                    when y.FeatureName='PRIMARY_METER' then 'UsagePoint'
                    else y.FeatureName
                end as FeatureName,
                y.Count from TCGACDS.GCM_RAPTOR_LOGS A, 
              XMLTABLE('/DistributionConnectivity/Statistics/Statistic' passing a.Logs_output
                columns 
                  Type VARCHAR2(1000) PATH 'Type',
                  TotalCount VARCHAR2(1000) PATH 'TotalCount',      
                  ResultsObject XMLTYPE PATH 'Results') x,
                      XMLTABLE('/Results/Stats' passing x.ResultsObject
                      columns 
                            FeatureName VARCHAR2(1000) PATH 'FeatureName',
                            Count VARCHAR2(1000) PATH 'Count')y,
                (select circuit_name,Max(raptor_run_date) Mraptor_run_date from TCGACDS.gcm_raptor_logs group by circuit_name) MR
                where A.circuit_name=MR.circuit_name and A.raptor_run_date=MR.Mraptor_run_date and x.type='BaseTableStats'
        ) A group by a.CIRCUIT_NAME, a.Circuit_version,a.RAPTOR_RUN_DATE, a.type, a.TotalCount,a.featurename
    ) BT full outer join (
        select a.CIRCUIT_NAME, a.Circuit_version,a.RAPTOR_RUN_DATE, a.type, a.TotalCount,a.featurename,sum(a.count) FeatureCount
        from (
            select a.CIRCUIT_NAME, a.Circuit_version,a.RAPTOR_RUN_DATE, x.type, x.TotalCount,
                case
                    when y.FeatureName in ('CompositeSwitch') then 'Switch'
                    when y.FeatureName in ('DERInterconnectionPoint','EnergyConsumer') then 'Der-EnergyConsumer'
                    else y.FeatureName
                end as FeatureName,
                y.Count from TCGACDS.GCM_RAPTOR_LOGS A, 
                XMLTABLE('/DistributionConnectivity/Statistics/Statistic' passing a.Logs_output
                columns 
                  Type VARCHAR2(1000) PATH 'Type',
                  TotalCount VARCHAR2(1000) PATH 'TotalCount',      
                  ResultsObject XMLTYPE PATH 'Results') x,
                      XMLTABLE('/Results/Stats' passing x.ResultsObject
                      columns 
                            FeatureName VARCHAR2(1000) PATH 'FeatureName',
                            Count VARCHAR2(1000) PATH 'Count')y,
                (select circuit_name,Max(raptor_run_date) Mraptor_run_date from TCGACDS.gcm_raptor_logs group by circuit_name) MR
                where A.circuit_name=MR.circuit_name and A.raptor_run_date=MR.Mraptor_run_date and x.type='SCIMStats'
        ) A group by a.CIRCUIT_NAME, a.Circuit_version,a.RAPTOR_RUN_DATE, a.type, a.TotalCount,a.featurename
    ) SVC on BT.CIRCUIT_NAME=SVC.CIRCUIT_NAME and BT.Circuit_version=SVC.Circuit_version and BT.RAPTOR_RUN_DATE=SVC.RAPTOR_RUN_DATE and BT.featurename=SVC.featurename
order by CIRCUIT_NAME,FeatureName