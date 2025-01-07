set serveroutput on
Declare
V_QUERY VARCHAR2(1000);
Begin
For Rec In (Select Owner,Replace(Object_Type,'BODY','') As Object_Type, Object_Name, Status
From   Dba_Objects Where  Status = 'INVALID' and owner='TCGACDS' 
AND OBJECT_TYPE<>'INDEX'
Order By Owner, Object_Type, Object_Name )Loop
BEGIN
V_Query:='ALTER '||Rec.Object_Type||' '||Rec.Object_Name||' COMPILE';
Execute Immediate V_Query;
--Dbms_Output.Put_Line(V_Query);
Exception
When Others Then
--Dbms_Output.Put_Line('EXCEPTION '||V_Query);
Continue;
END;
End Loop;
END;
/
