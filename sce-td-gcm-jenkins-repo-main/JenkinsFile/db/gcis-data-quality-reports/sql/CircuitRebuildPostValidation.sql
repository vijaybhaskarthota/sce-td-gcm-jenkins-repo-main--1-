SELECT 'Circuits Population XML and GML 'as comments, case when count(1)>0 then 'UNPROCESSED' else 'COMPLETED' end as status, count(1) as count FROM TCGACDS.GCM_GEOSPATIAL_FILE_STATUS WHERE ELEMENT_TYPE='CIRCUIT' AND STATUS IN ('IN-PROGRESS','UNPROCESSED')
AND IS_PAYLOAD_POPULATED='Y';