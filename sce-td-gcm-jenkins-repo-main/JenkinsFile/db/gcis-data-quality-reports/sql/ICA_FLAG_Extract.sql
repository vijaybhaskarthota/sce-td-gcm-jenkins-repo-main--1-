--This report is to get Circuits Extract with ICA Flag Info
--Last Modified: 06/30/2022

-------------------------------------------------------------------------

column PRIMARY_CKT heading "PRIMARY_CKT" Format a10
column CIRCT_ID heading "CIRCT_ID" Format a10
column CIRCUIT_TYPE heading "CIRCUIT_TYPE" Format a10
column ICA_active heading "ICA_active" Format a10
column PHASING heading "PHASING" Format a10


select DISTINCT B.PRIMARY_CKT, B.CIRCT_ID, B.CIRCUIT_TYPE, B.ICA_active, A.PHASING
from (

Select Opc.Circuit_Name1,OPC.ID,Opc.Phasing From Tcgacds.Net_9_Ref$ T2,Tcgacds.Oh_Primary_Conductor Opc Where
OPC.ID=T2.FEATURE_IDENTIFIER  and
T2.Element_Id In (
Select T1.Element_Id From Tcgacds.Net_9_Ref$ T1 Where T1.Feature_Table='CIRCUIT_HEAD') And Feature_Table Like '%OH_PRIMARY_CONDUCTOR%'
Union
Select Upc.Circuit_Name1,Upc.ID,Upc.Phasing From Tcgacds.Net_9_Ref$ T2,Tcgacds.UG_Primary_Conductor Upc Where
Upc.ID=T2.FEATURE_IDENTIFIER  and
T2.Element_Id In (
Select T1.ELEMENT_ID From Tcgacds.Net_9_Ref$ T1 where T1.FEATURE_TABLE='CIRCUIT_HEAD') 
and FEATURE_TABLE Like '%UG_PRIMARY_CONDUCTOR%'

) A inner join

TCGACDS.GCM_CONN_DATA_STORE B  on A.circuit_name1=B.primary_ckt and B.ICA_active='Y'