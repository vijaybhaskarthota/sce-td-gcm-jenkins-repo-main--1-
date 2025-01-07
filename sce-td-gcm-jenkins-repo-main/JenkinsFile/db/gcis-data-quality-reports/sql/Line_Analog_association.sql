SET LINESIZE 180
SET FEEDBACK OFF
column Category heading "Category" Format a51
column COUNT heading "COUNT" Format 99999999999999999999
column Comments heading "Comment" Format a10

alter session set current_schema=tcgacds;

select '1.1:Total number of analogs received from source EMS:' AS Category, count(*)  as count, 'Info' as Comments
from 
TCGACDS.Ems_Analog
union
select '1.2:Total number of analogs processed in SCIM layer:' AS Category, count(distinct MRID)  as count, 'Info' as Comments
from 
TCGACDS.GCM_SCIM_ANALOG
union
select '1.3:Total number of analogs linked to external lines:' AS Category, count(distinct analog_id)  as count, 'Info' as Comments
from 
TCGACDS.EMS_ANALOG where MEASUREMENT_POWERSYSTEMRESOURC 
in (select aclinesegmentid from TCGACDS.GCM_SCIM_ACLINESEGMENTIDENTIFIER LI JOIN
tcgacds.gcm_scim_line L on LI.NAME =L.LINEID )
and analog_id in (
select MRID from TCGACDS.GCM_SCIM_ANALOG WHERE GCM_SUBSTATION_ID IS NOT NULL )
UNION
select '1.4:Total number of analogs linked to internal lines:' AS Category, count(distinct analog_id)  as count, 'Info' as Comments
from 
TCGACDS.EMS_ANALOG where MEASUREMENT_POWERSYSTEMRESOURC 
not in (select aclinesegmentid from TCGACDS.GCM_SCIM_ACLINESEGMENTIDENTIFIER LI JOIN
tcgacds.gcm_scim_line L on LI.NAME =L.LINEID AND L.GCM_JOBID=Li.Gcm_Jobid
WHERE L.GCM_JOBID=(SELECT JOBID FROM TCGACDS.GCM_PROCESS_STATUS WHERE ACTIVEJOBID='Y') )

UNION
select '1.5:Total number of internal analogs published by GCM:' AS Category, count(distinct MRID)  as count, 'Info' as Comments
from 
TCGACDS.GCM_SCIM_ANALOG WHERE GCM_SUBSTATION_ID IS NOT NULL
UNION
select '1.6:Fallout of analog linked to internal:'  AS Category,count(*) as count, 'DQ Issue' as Comments
from 
TCGACDS.GCM_V_SUB_I_ANALOG WHERE GCM_SUBSTATION_ID IS  NULL 
and  EQUIPMENTID NOT in (
select aclinesegmentid from TCGACDS.GCM_SCIM_ACLINESEGMENTIDENTIFIER LI JOIN
tcgacds.gcm_scim_line L on LI.NAME =L.LINEID )
union
select '1.7:Fallout of analog linked to internal because ACLinesegment not present in EMS_NAME table:' AS Category, count(*)  as count, 'DQ Issue' as Comments
from 
TCGACDS.GCM_V_SUB_I_ANALOG WHERE GCM_SUBSTATION_ID IS  NULL 
and  EQUIPMENTID NOT in (
select aclinesegmentid from TCGACDS.GCM_SCIM_ACLINESEGMENTIDENTIFIER LI JOIN
tcgacds.gcm_scim_line L on LI.NAME =L.LINEID )
AND EQUIPMENTID IN (SELECT ACLINESEGMENT_ID FROM TCGACDS.EMS_ACLNSGMNT AC
JOIN TCGACDS.EMS_NAME NAM ON NAM.NAME_ID=AC.IDENTIFIEDOBJECT_NAME_RESOURCE)
union
select '1.8:Total number of external analogs published by GCM:' AS Category, count(DISTINCT MRID)  as count, 'Info' as Comments
from 
TCGACDS.GCM_V_SUB_I_ANALOG WHERE GCM_SUBSTATION_ID IS not NULL
and  EQUIPMENTID in (
select aclinesegmentid from TCGACDS.GCM_SCIM_ACLINESEGMENTIDENTIFIER LI JOIN
tcgacds.gcm_scim_line L on LI.NAME =L.LINEID )
union
select '1.9:Fallout of analog linked to external lines:' AS Category, count(DISTINCT MRID)  as count, 'Info' as Comments
from 
TCGACDS.GCM_V_SUB_I_ANALOG WHERE GCM_SUBSTATION_ID IS NULL 
and  EQUIPMENTID in (
select aclinesegmentid from TCGACDS.GCM_SCIM_ACLINESEGMENTIDENTIFIER LI JOIN
tcgacds.gcm_scim_line L on LI.NAME =L.LINEID );

