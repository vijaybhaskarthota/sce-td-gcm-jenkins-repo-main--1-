-- Validation on GCM2020_Exception and Error_catalog table
-- Created on: 01-21-2022
----------------------------------------------------------

column Category heading "Category" Format a51
column COUNT heading "COUNT" Format a9
column Comments heading "Comment" Format a10
-----------------

-- Count of rows from Exception table with 'table_name' as empty
 select '1.1-Cnt of rows with col "table_name" empty#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments
from TCGACDS.gcm2020_exception where table_name is null 
and to_char(error_desc) not like '%FATAL%' and to_char(error_desc) not like '%ORA-%'

UNION

-- Count of rows from Exception table with 'Key_Col_Name' as empty
select '1.2-Cnt of rows with col "Key_Col_Name" empty#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments
 from TCGACDS.gcm2020_exception where Key_Col_Name is null 
and to_char(error_desc) not like '%FATAL%'

UNION
-- Count of rows from Exception table with 'Key_Col_Value' as empty
select '1.3-Cnt of rows with col "Key_Col_Value" empty#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments
 from TCGACDS.gcm2020_exception where Key_Col_Value is null 
and to_char(error_desc) not like '%FATAL%' and to_char(error_desc) not like '%ORA-%'

UNION

-- Count of distict error code with  'Key_Col_Value' as empty
select '1.3a-Cnt unique errCodes w/col "KeyColValue" empty#' as Category, count(distinct error_code) as count, 
CASE WHEN count(distinct error_code) > 0 THEN 'Failed'ELSE 'Passed' END as Comments
 from TCGACDS.gcm2020_exception where Key_Col_Value is null 
and to_char(error_desc) not like '%FATAL%' and to_char(error_desc) not like '%ORA-%'

UNION

-- same error code differnt err msg should be 0
select '1.4-Cnt of rows w/same errCode, different errMsg#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments from (
select error_code, count( long_desc) from TCGACDS.gcm_error_catalog
group by error_code having count(long_desc) > 1 )

UNION

---- same error code different track should be 0 i.e each error code should be unique across tracks

select '1.5-Cnt of rows w/same errCode, different track#' as Category, count(*) as count, 
CASE WHEN COUNT(*) > 0 THEN 'Failed'ELSE 'Passed' END as Comments
 from (select error_code, count( track) from TCGACDS.gcm_error_catalog
group by error_code having count(track) > 1 )

UNION

-- all err code present in gcm exception table should exist in error catalog, exception fatal and ora
 
select '1.6-Cnt of rows errCode in Excp tble not in ErrCat#' as Category, count( error_code) as count, 
CASE WHEN count( error_code) > 0 THEN 'Failed'ELSE 'Passed' END as Comments from 
( select distinct error_code
from TCGACDS.gcm2020_exception Ex
where to_char(error_desc) not like '%FATAL%' and to_char(error_desc) not like '%ORA-%'
Minus
select error_code from TCGACDS.gcm_error_catalog Er )

--OR -below query-- any query can be used 

--select '1.6-Cnt of rows errCode in Excp tble not in ErrCat#' as Category, count(distinct error_code) as count, 
--CASE WHEN count(distinct error_code) > 0 THEN 'Failed'ELSE 'Passed' END as Comments
-- from TCGACDS.gcm2020_exception Ex
--where to_char(error_desc) not like '%FATAL%' and to_char(error_desc) not like '%ORA-%'
--and not exists (select 1 from TCGACDS.gcm_error_catalog Er where Er.error_code = Ex.error_code )


UNION

-- error catalog table should be defeined with only valid error codes and not garbage.

select '1.7-Cnt of rows in ErrCatalog w/invalid errCode#' as Category, count( error_code) as count, 
CASE WHEN count( error_code) > 0 THEN 'Failed'ELSE 'Passed' END as Comments from TCGACDS.gcm_error_catalog
where regexp_like(error_code,'[^-a-zA-Z0-9 ]')
