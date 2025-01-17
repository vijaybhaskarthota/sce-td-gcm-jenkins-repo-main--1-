SET SERVEROUTPUT ON ;
DECLARE 
V_COUNT NUMBER;
V_CNT NUMBER;
V_DATE VARCHAR2(200 BYTE);
BEGIN
SELECT MAX((SUBSTR(START_TIME, 1, Instr(START_TIME, ' ', -1, 2) -1))) INTO  V_DATE FROM TCGACDS.GCM_SUBSTATION_GEOSPATIAL_FILE_STATUS;
SELECT COUNT(1) INTO V_COUNT FROM TCGACDS.GCM_SUBSTATION_GEOSPATIAL_FILE_STATUS WHERE STATUS ='COMPLETED' AND FILE_TYPE='GML' AND (SUBSTR(START_TIME, 1, Instr(START_TIME, ' ', -1, 2) -1)) =V_DATE;
--DBMS_OUTPUT.PUT_LINE(V_COUNT);
IF V_COUNT<> 0 
THEN 
DBMS_OUTPUT.PUT_LINE('GML DATA LOAD SUCCESSFUL '||V_COUNT||' '||V_DATE);
ELSE
DBMS_OUTPUT.PUT_LINE('GML DATA LOAD NEED TO VALIDATE '||V_COUNT||' '||V_DATE);
END IF ;
END ;

/

DECLARE 
V_COUNT NUMBER;
V_CNT NUMBER;
V_DATE VARCHAR2(200 BYTE);
BEGIN
SELECT MAX((SUBSTR(START_TIME, 1, Instr(START_TIME, ' ', -1, 2) -1))) INTO  V_DATE FROM TCGACDS.GCM_SUBSTATION_GEOSPATIAL_FILE_STATUS;
SELECT COUNT(1) INTO V_COUNT FROM TCGACDS.GCM_SUBSTATION_GEOSPATIAL_FILE_STATUS WHERE STATUS ='COMPLETED' AND FILE_TYPE='GeoJson' AND (SUBSTR(START_TIME, 1, Instr(START_TIME, ' ', -1, 2) -1)) =V_DATE;
--DBMS_OUTPUT.PUT_LINE(V_COUNT);
IF V_COUNT<> 0 
THEN 
DBMS_OUTPUT.PUT_LINE('GeoJson DATA LOAD SUCCESSFUL '||V_COUNT||' '||V_DATE);
ELSE
DBMS_OUTPUT.PUT_LINE('GeoJson DATA LOAD NEED TO VALIDATE '||V_COUNT||' '||V_DATE);
END IF ;
END ;
/