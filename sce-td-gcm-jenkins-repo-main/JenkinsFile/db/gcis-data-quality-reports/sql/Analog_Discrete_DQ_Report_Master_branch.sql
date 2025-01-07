SET LINESIZE 180
SET FEEDBACK OFF
column Category heading "Category" Format a53
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a8

select '1.1:Total no. of EMS substations:' AS Category, count(distinct Sub.mrid)  as count, 'Info' as Comments
 from 
TCGACDS.GCM_SCIM_Substation Sub
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
UNION
select '1.2:No. of EMS substations having Analog objects:' AS Category, count(distinct Sub.mrid)  as count, 'Info' as Comments 
from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null
UNION
select '1.3:No. of EMS substations with no Analog objects:' AS Category, count(distinct Sub.mrid)  as count, 'Info' as Comments from 
TCGACDS.GCM_SCIM_Substation Sub
left join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is  null
UNION
select '1.4:No. of Analog obejcts across substations:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments
  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null
UNION
select '1.5:Analog obejcts having val for name:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments
  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null and An.name is not null
UNION
select '1.6:Analog obejcts having val for positiveflowin:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null and An.positiveFlowIn is not null
UNION
select '1.7:Analog obejcts having val for description:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null and An.description is not null
UNION
select '1.8:Analog obejcts having val for phases:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null and An.phases is not null
UNION
select '1.9:Analog obejcts having val for measurementType:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null and An.measurementType is not null
UNION
select '2.0:Analog obejcts having val for unitSymbol:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null and An.unitSymbol is not null
UNION
select '2.1:Analog obejcts having val for unitMultiplier:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null and An.unitMultiplier is not null
UNION
select '2.2:Analog obejcts having val for terminalId:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null and An.terminalId is not null
UNION
select '2.3:Analog obejcts having val for equipmentId:' AS Category, count(distinct An.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_ANALOG An
on Sub.mrid = An.gcm_substation_id
and Sub.gcm_jobid = An.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and An.gcm_substation_id is not null and An.equipmentId is not null
UNION
select '2.4:No. of EMS substations having Discrete objects:' AS Category, count(distinct Sub.mrid)  as count, 'Info' as Comments
  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.mrid = Di.gcm_substation_id
and Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is not null
UNION
select '2.5:No. of EMS substations with no Discrete objects:' AS Category, count(distinct Sub.mrid)  as count, 'Info' as Comments
  from 
TCGACDS.GCM_SCIM_Substation Sub
left join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.mrid = Di.gcm_substation_id
and Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is  null
UNION
select '2.6:No. of Discrete obejcts across substations' AS Category, count(distinct Di.mrid)  as count, 'Info' as Comments
from 
TCGACDS.GCM_SCIM_Substation Sub
left join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is not null
UNION
select '2.7:Discrete obejcts having val for name' AS Category, count(distinct Di.mrid)  as count, 'Info' as Comments
 from 
TCGACDS.GCM_SCIM_Substation Sub
left join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.mrid = Di.gcm_substation_id
and Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is not null and Di.name is not null
UNION
select '2.8:Discrete obejcts having val for unitSymbol' AS Category, count(distinct Di.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.mrid = Di.gcm_substation_id
and Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is not null and Di.unitSymbol is not null
UNION
select '2.9:Discrete obejcts having val for terminalId' AS Category, count(distinct Di.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.mrid = Di.gcm_substation_id
and Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is not null and Di.terminalId is not null
UNION
select  '3.0:Discrete obejcts having val for equipmentId' AS Category, count(distinct Di.mrid)  as count, 'Info' as Comments from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.mrid = Di.gcm_substation_id
and Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is not null and Di.equipmentId is not null
UNION
select '3.1:Discrete obejcts having val for description' AS Category, count(distinct Di.mrid)  as count, 'Info' as Comments from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.mrid = Di.gcm_substation_id
and Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is not null and Di.description is not null
UNION
select '3.2:Discrete obejcts having val for measurementType' AS Category, count(distinct Di.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.mrid = Di.gcm_substation_id
and Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is not null and Di.measurementType is not null
UNION
select '3.3:Discrete obejcts having val for unitMultiplier' AS Category, count(distinct Di.mrid)  as count, 'Info' as Comments  from 
TCGACDS.GCM_SCIM_Substation Sub
left outer join TCGACDS.GCM_SCIM_DISCRETE Di
on Sub.mrid = Di.gcm_substation_id
and Sub.gcm_jobid = Di.gcm_jobid
where Sub.GCM_SOR = 'EMS' and
Sub.TYP IN ('B-BANK','DISTRIBUTION') 
and Sub.gcm_jobid = (Select JOBID from TCGACDS.GCM_PROCESS_STATUS where activejobid  = 'Y')
and Di.gcm_substation_id is not null and Di.unitMultiplier is not null


