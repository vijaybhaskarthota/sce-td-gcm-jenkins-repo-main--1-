-- This report is about Circuits- Circuit Type - ICA flag data quality
-- Last Modified date:06/30/2022
-----------------------------------------------------------

column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10


---GCM circuits not in Circuit Head
select '1.1:Circuits not in Circuit Head:' AS Category, count(primary_ckt) as count, 'Info' as Comments 
from TCGACDS.GCM_CONN_DATA_STORE where ASSET_TYPE='CIRCUIT_HEAD' and
primary_ckt not in (Select Circuit_Name from TCGACDS.Circuit_Head)

UNION

--Total Number of Circuits in GCM Connectivity --- 4436
Select '1.2:Circuits in GCM Connectivity:' AS Category, count(CIRCUIT_NAME) as count, 'Info' as Comments 
 from TCGACDS.Circuit_Head where
Circuit_Name in (select primary_ckt from TCGACDS.GCM_CONN_DATA_STORE where ASSET_TYPE='CIRCUIT_HEAD')
and CIRCT_STAT_CD = 'I'

UNION


---Total Number of Circuits having ICA flag as Null in GCM connectivity  ---0
Select '1.3:Circuits w ICA flag as Null in GCM:' AS Category, count(*) as count, 'Info' as Comments 
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and CDS.CIRCUIT_TYPE not in ('D','B','C','F','G','H','X')
AND CDS.ICA_active is NULL

UNION

---Total Number of Circuits having Circuit Type - A and ICA flag as Y in GCM connectivity  ---169
Select '1.4:Circuits w CktTyp as A and ICA Flag as Y:' AS Category, count(*) as count, 'Info' as Comments 
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and CDS.CIRCUIT_TYPE = 'A'
AND CDS.ICA_active='Y'

UNION

---Total Number of Circuits having Circuit Type - A and ICA flag as N in GCM connectivity  ---32
Select '1.5:Circuits w CktTyp as A and ICA Flag as N:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and CDS.CIRCUIT_TYPE = 'A'
AND CDS.ICA_active='N'

UNION

---Total Number of Circuits having Circuit type D and ICA flag is Active in GCM connectivity  ---4057
Select '1.6:Circuits w CktTyp as D and ICA Flag as Y:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='D'
AND CDS.ICA_active='Y'

UNION

---Total Number of Circuits having Circuit type D and ICA flag is InActive in GCM connectivity  ---8
Select '1.7:Circuits w CktTyp as D and ICA Flag as N:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='D'
AND CDS.ICA_active='N'

UNION

---Total Number of Circuits having Circuit type B and ICA flag is InActive in GCM connectivity  ---21
Select '1.8:Circuits w CktTyp as B and ICA Flag as Y:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='B'
AND CDS.ICA_active='N'


UNION

---Total Number of Circuits having Circuit type B and ICA flag is Active in GCM connectivity  --- 0
Select '1.9:Circuits w CktTyp as B and ICA Flag as N:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='B'
AND CDS.ICA_active='Y'


UNION

---Total Number of Circuits having Circuit type C and ICA flag is InActive in GCM connectivity  --- 112
Select  '2.1:Circuits w CktTyp as C and ICA Flag as N:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='C'
AND CDS.ICA_active='N'

UNION

---Total Number of Circuits having Circuit type C and ICA flag is Active in GCM connectivity  --- 0
Select '2.2:Circuits w CktTyp as C and ICA Flag as Y:' AS Category, count(*) as count, 'Info' as Comments
  from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='C'
AND CDS.ICA_active='Y'

UNION

---Total Number of Circuits having Circuit type F and ICA flag is InActive in GCM connectivity  --- 20
Select '2.3:Circuits w CktTyp as F and ICA Flag as N:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='F'
AND CDS.ICA_active='N'

UNION

---Total Number of Circuits having Circuit type F and ICA flag is Active in GCM connectivity  --- 0
Select '2.4:Circuits w CktTyp as F and ICA Flag as Y:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='F'
AND CDS.ICA_active='Y'

UNION


---Total Number of Circuits having Circuit type G and ICA flag is InActive in GCM connectivity  --- 3
Select '2.5:Circuits w CktTyp as G and ICA Flag as N:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='G'
AND CDS.ICA_active='N'

UNION

---Total Number of Circuits having Circuit type G and ICA flag is Active in GCM connectivity  --- 0
Select '2.6:Circuits w CktTyp as G and ICA Flag as Y:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='G'
AND CDS.ICA_active='Y'

UNION

---Total Number of Circuits having Circuit type H and ICA flag is InActive in GCM connectivity  --- 6
Select '2.7:Circuits w CktTyp as H and ICA Flag as N:' AS Category, count(*) as count, 'Info' as Comments
from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='H'
AND CDS.ICA_active='N'

UNION

---Total Number of Circuits having Circuit type H and ICA flag is Active in GCM connectivity  --- 0
Select '2.8:Circuits w CktTyp as H and ICA Flag as Y:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='H'
AND CDS.ICA_active='Y'

UNION

---Total Number of Circuits having Circuit type X and ICA flag is InActive in GCM connectivity  --- 12
Select '2.9:Circuits w CktTyp as X and ICA Flag as N:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='X'
AND CDS.ICA_active='N'

UNION

---Total Number of Circuits having Circuit type X and ICA flag is Active in GCM connectivity  --- 0
Select '3.1:Circuits w CktTyp as X and ICA Flag as Y:' AS Category, count(*) as count, 'Info' as Comments
 from TCGACDS.Circuit_Head CH 
inner join TCGACDS.GCM_CONN_DATA_STORE CDS ON
Ch.Circuit_Name=Cds.Primary_Ckt where Cds.Asset_Type='CIRCUIT_HEAD' and Ch.Circuit_Type='X'
AND CDS.ICA_active='Y'

