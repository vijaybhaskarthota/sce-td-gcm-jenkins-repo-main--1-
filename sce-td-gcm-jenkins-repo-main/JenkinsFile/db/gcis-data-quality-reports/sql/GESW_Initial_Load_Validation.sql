

SET SERVEROUTPUT ON;
DECLARE
V_JOBID VARCHAR2(250 BYTE);
V_CURRENT_JOB  VARCHAR2(20 BYTE);
V_SUCCESS VARCHAR2(20 BYTE);
BEGIN

SELECT MAX(JOBID) INTO  V_JOBID FROM TCGACDS.GCM_SUB_DIST_JOB_STATUS ORDER BY 1 DESC;
SELECT CURRENT_JOB ,SUCCESS  INTO V_CURRENT_JOB ,V_SUCCESS FROM TCGACDS.GCM_SUB_DIST_JOB_STATUS WHERE JOBID=V_JOBID;
IF V_CURRENT_JOB='N' AND V_SUCCESS='Y' THEN
DBMS_OUTPUT.PUT_LINE('GESW INITIAL LOAD  SUCCESSFUL ' );
ELSE 
DBMS_OUTPUT.PUT_LINE('GESW INITIAL LOAD  NEED TO VALIDATE ');
END IF ;
END ;
/

DECLARE 
V_COUNT NUMBER;
BEGIN
 SELECT COUNT(*) INTO V_COUNT FROM(SELECT * FROM TCGACDS.SUBSTATION WHERE TO_NUMBER(SUBSTR(LOW_VOLTAGE,0,(LENGTH(LOW_VOLTAGE)-2))) <=
    (SELECT CONFIG_VALUE FROM TCGACDS.GCM_CONFIG_VALUES WHERE CONFIG_KEY = 'B-BANK_MIN_HIGH_VOLTAGE')
AND TO_NUMBER(SUBSTR(HIGH_VOLTAGE,0,(LENGTH(HIGH_VOLTAGE)-2))) <=
    (SELECT CONFIG_VALUE FROM TCGACDS.GCM_CONFIG_VALUES WHERE CONFIG_KEY = 'B-BANK_MIN_HIGH_VOLTAGE')
AND SUBST_STAT_CD='I' AND SUBST_ID NOT IN (SELECT SUBSTATION_ID FROM TCGACDS.GCM_SUB_I_CONN_SUBSTATIONS WHERE SOR='GESW')
AND SUBSTATION_NO NOT IN (SELECT SUBSTATION_NUMBER FROM TCGACDS.GCM_SUB_I_CONN_SUBSTATIONS WHERE SOR='EMS' AND SUBSTATION_NUMBER IS NOT NULL)
AND NAME NOT IN (SELECT NAME FROM TCGACDS.GCM_SUB_I_CONN_SUBSTATIONS WHERE SOR='EMS'));
 IF V_COUNT =0
 THEN
DBMS_OUTPUT.PUT_LINE('GESW vs All List DATA SHOULD BE ZERO SUCCESSFUL |'|| V_COUNT);
ELSE 
DBMS_OUTPUT.PUT_LINE('GESW vs All List DATA SHOULD BE ZERO NEED TO VALIDATE |'|| V_COUNT); 
END IF;
END;
/
DECLARE 
V_COUNT NUMBER;
BEGIN
 SELECT COUNT(*) INTO V_COUNT FROM(SELECT * FROM TCGACDS.GCM_SUB_I_CONN_SUBSTATIONS WHERE SOR='GESW' AND SUBSTATION_ID NOT IN 
    (SELECT SUBST_ID FROM TCGACDS.SUBSTATION WHERE TO_NUMBER(SUBSTR(LOW_VOLTAGE,0,(LENGTH(LOW_VOLTAGE)-2))) <=
        (SELECT CONFIG_VALUE FROM TCGACDS.GCM_CONFIG_VALUES WHERE CONFIG_KEY = 'B-BANK_MIN_HIGH_VOLTAGE')
    AND TO_NUMBER(SUBSTR(HIGH_VOLTAGE,0,(LENGTH(HIGH_VOLTAGE)-2))) <=
        (SELECT CONFIG_VALUE FROM TCGACDS.GCM_CONFIG_VALUES WHERE CONFIG_KEY = 'B-BANK_MIN_HIGH_VOLTAGE')
    AND SUBST_STAT_CD='I'));
 IF V_COUNT =0
 THEN
DBMS_OUTPUT.PUT_LINE('All List vs GESW DATA SHOULD BE ZERO SUCCESSFUL |'|| V_COUNT);
ELSE 
DBMS_OUTPUT.PUT_LINE('All List vs GESW DATA SHOULD BE ZERO NEED TO VALIDATE |'|| V_COUNT); 
END IF;
END;
/