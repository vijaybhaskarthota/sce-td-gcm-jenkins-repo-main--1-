#dir env:
# code for running the sql
$TDT = $NULL 
try {
	  $TDT = New-Object -ComObject 'Toad.ToadAutoObject'   # Start TDT  
    $ConnectStr = $env:DB_CRED_USR + '/' + $env:DB_CRED_PSW + $env:DB_CONN_STR
    $SQLFolder = $ENV:WORKSPACE+"\JenkinsFile\sce-td-gcm-circuit-rebuild\"
  	Write-Host "Connect String:" $ConnectStr
    # Make Connections to Source Database
  	$Source = $TDT.Connections.NewConnection($ConnectStr)  # Source DB credentials   
    # Setting Script Parameters (for Input SQL file)
    $Script               = $TDT.Scripts.Add()       # Set $Script Variable for Add function
  	$Script.Connection    = $Source                 # Set Source connection info   	
  	$Script.IncludeOutput = $TRUE                    # Set Include Output parameter to True
    #	$Script.MaxRows       = 100                    # Set Max Rows to display to 100
    #$Script.InputFile = $_.FullName                 # Input SQL File
    #$Script.InputFile = $SQLFolder+"DBQuery.sql"  
    $FolderPath= $ENV:WORKSPACE+ "\Output"
    #Check if Folder exists
    If(!(Test-Path -Path $FolderPath))
    {
      New-Item -ItemType Directory -Path $FolderPath
      Write-Host "Output folder created successfully!"
    }
    Else
    {
      Write-Host "Output Folder already exists!"
    }
    $OutputLogFile = $ENV:WORKSPACE+ "\Output\output.log"
    $Script.OutputFile = $OutputLogFile
    # Run Script Execute
    Write-Host "SQL plus starting"
    $InputCSVFile = $ENV:WORKSPACE+"\"+"CircuitName.csv"
    Write-Host $InputCSVFile
    $SQLDELETE="DELETE FROM GCM_INIT_PRIMARY_CIRCUIT WHERE BATCH_NO = 9999;"
    Write-Host $SQLDELETE
    $Script.InputText =$SQLDELETE
    $Script.Execute()
    $SQLCOMMIT="COMMIT;"
    #Import the contents of the CircuitName.csv file and store it in the $circuit_list variable.
    $circuit_list = Import-Csv $InputCSVFile
    If ($circuit_list -eq $null){
      Write-Host "Proceeding with All Circuit Insert"
      $SQLINSERTALL="INSERT INTO GCM_INIT_PRIMARY_CIRCUIT SELECT CIRCUIT_NAME,9999,null,null FROM CIRCUIT_HEAD;"
      Write-Host $SQLINSERTALL
      $Script.InputText =$SQLINSERTALL
      $Script.Execute()
      $SQLCOMMIT="COMMIT;"
    }
    Else {
      # Loop through all the records in the CSV
      foreach ($circuit in $circuit_list){
        Write-Host $circuit.CIRCUITNAME
        $SQLINSERT="INSERT INTO GCM_INIT_PRIMARY_CIRCUIT (PRIMARY_CKT,BATCH_NO) VALUES('" +$circuit.CIRCUITNAME+ "',9999);"
        Write-Host $SQLINSERT
        $Script.InputText =$SQLINSERT
        $Script.Execute()
        $SQLCOMMIT="COMMIT;"
      }
    }
    Write-Host $SQLCOMMIT
    $Script.InputText =$SQLCOMMIT
    $Script.Execute()
    Write-Host "SQL plus finished" 
    $ScriptOutput = $Script.OutputText   
    Write-Output $ScriptOutput > $OutputLogFile
}
finally {
  # Get Logfile Filename
  $DebugFile = $TDT.Debug.Logfile.Filename()
  # Get Exception Log Filename
  $ExceptionLogFile = $TDT.Debug.ExceptionLog.Filename()
  write-host "DebugFile" $DebugFile "ExceptionLogFile" $ExceptionLogFile
  $SQLOutputFolder = $ENV:WORKSPACE+"\Output"
  # Get Logfile Text and write to file 
  $TDT.Debug.Logfile.GetText() | Out-File -FilePath "$SQLOutputFolder\logfile.txt" -Force   
  # Get Exception Log - Last Error and write to file
  $TDT.Debug.ExceptionLog.GetLastError() | Out-File -FilePath "$SQLOutputFolder\lastError.txt" -Force
  # Get Exception Log - Last Call Stack and write to file      
  $TDT.Debug.ExceptionLog.GetLastCallStack() | Out-File -FilePath "$SQLOutputFolder\lastCallStack.txt" -Force
  # Get Exception Log - Last Call Last Report and write to file            
  $TDT.Debug.ExceptionLog.GetLastReport() | Out-File -FilePath "$SQLOutputFolder\lastReport.txt" -Force
  # Get Exception Log - Full Report and write to file                 
  $TDT.Debug.ExceptionLog.GetFullReport() | Out-File -FilePath "$SQLOutputFolder\fullReport.txt" -Force
  $TDT.Quit()                                 # Stop TDT
}