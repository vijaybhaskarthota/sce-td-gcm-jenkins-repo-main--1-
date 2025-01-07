-- This report validates ELBOW and LOADBREAK SWITCH stats for monitoring the cyme issue.
-- Last Modified date:6/2/2022
-----------------------------------------------------------

column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
---column Comments heading "Comment" Format a10
-----------------

select '1.0 #Circuit having loadbreak switch' as category, COUNT from (
select COUNT (distinct CIRCUIT_NAME1) as COUNT from tcgacds.elbow where load_break ='YES')

union
select '1.1 #Circuit having Elbow' as category, COUNT from (
select COUNT (distinct CIRCUIT_NAME1) as COUNT from tcgacds.elbow where load_break ='NO')
union
select '1.2 #Circuit having Elbow and loadbreak' as category, COUNT (distinct CIRCUIT_NAME1) as COUNT from (
select CIRCUIT_NAME1, COUNT(*) as LOADBREAKCOUNT from tcgacds.elbow where load_break ='NO' and 
CIRCUIT_NAME1 in (select CIRCUIT_NAME1 from tcgacds.elbow where load_break ='YES') group by CIRCUIT_NAME1)
union
select '1.3 #Circuit having Elbow but no loadbreak' as category, COUNT (distinct CIRCUIT_NAME1) as COUNT from (
select CIRCUIT_NAME1, COUNT(*) as LOADBREAKCOUNT from tcgacds.elbow where load_break ='NO' and 
CIRCUIT_NAME1 NOT in (select CIRCUIT_NAME1 from tcgacds.elbow where load_break ='YES') group by CIRCUIT_NAME1);

