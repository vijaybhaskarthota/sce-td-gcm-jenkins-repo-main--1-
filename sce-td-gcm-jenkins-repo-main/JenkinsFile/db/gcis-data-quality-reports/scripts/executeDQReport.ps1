#dir env:
$TDT = $NULL 
try {
		$TDT = New-Object -ComObject 'Toad.ToadAutoObject'   # Start TDT  
    $ConnectStr = $env:DB_CRED_USR + '/' + $env:DB_CRED_PSW + $env:DB_CONN_STR
    $SQLFolder = $ENV:WORKSPACE+"\JenkinsFile\\db\gcis-data-quality-reports\sql\"
    $SQLOutputFolder = $ENV:WORKSPACE+"\JenkinsFile\db\gcis-data-quality-reports\sql-output\"
  	Write-Host "Connect String:" $ConnectStr	"Environment:" $env:ENV "SQLFolder Script Folder:" $SQLFolder
    # Make Connections to Source Database
  	$Source = $TDT.Connections.NewConnection($ConnectStr)  # Source DB credentials    
    # Setting Script Parameters (for Input SQL file)
    $Script               = $TDT.Scripts.Add()                                   # Set $Script Variable for Add function
  	$Script.Connection    = $Source                                              # Set Source connection info   	
  	$Script.IncludeOutput = $TRUE                                                # Set Include Output parameter to True
    #	$Script.MaxRows       = 100                                               # Set Max Rows to display to 100
    #Get-ChildItem "$SQLFolder" | ForEach-Object {
      #$Script.InputFile = $_.FullName                                   # Input SQL File
      $Script.InputFile = $SQLFolder+$ENV:DQ_REPORT                                   # Input SQL File
      write-host "Executing Data Quality SQL Script" $Script.InputFile "Environment:" $env:ENV
      # Run Script Execute
      $Script.Execute()
      # Run Script to Generate HTML Report Format
      sqlplus -S -M "HTML ON" $ConnectStr "@$SQLFolder$ENV:DQ_REPORT" | out-file "$SQLOutputFolder$ENV:DQ_REPORT.html"
      Copy-Item "$SQLOutputFolder$ENV:DQ_REPORT.html" "$SQLOutputFolder$ENV:DQ_REPORT.xls"
      # Output results to variable
      $ScriptOutput = $Script.OutputText                                           # Output results to a Variable
      #$OutputLogFile = $SQLOutputFolder + $_.Name + "." + $env:ENV + ".output.log"
      $OutputLogFile = $SQLOutputFolder + $ENV:DQ_REPORT + "." + $env:ENV + ".output.log"
      Write-Host "Data Quality SQL Script: Input SQL File:" $Script.InputFile "Output SQL Log File:" $OutputLogFile
      Write-Output $ScriptOutput > $OutputLogFile
    #}
}
finally {
  $SQLTraceFolder = $ENV:WORKSPACE+"\JenkinsFile\db\gcis-data-quality-reports\sql-trace"
  	 # Get Logfile Text and write to file
     $TDT.Debug.Logfile.GetText() | Out-File -FilePath "$SQLTraceFolder\ES_Logfile.txt" -Force    
     # Get Logfile Filename
     $DebugFile = $TDT.Debug.Logfile.Filename()
     # Get Exception Log Filename
     $ExceptionLogFile = $TDT.Debug.ExceptionLog.Filename()
     write-host "DebugFile" $DebugFile "ExceptionLogFile" $ExceptionLogFile
	 # Get Exception Log - Last Error and write to file
     $TDT.Debug.ExceptionLog.GetLastError()     | Out-File -FilePath "$SQLTraceFolder\ES_LastError.txt" -Force
	 # Get Exception Log - Last Call Stack and write to file      
     $TDT.Debug.ExceptionLog.GetLastCallStack() | Out-File -FilePath "$SQLTraceFolder\ES_LastCallStack.txt" -Force
	 # Get Exception Log - Last Call Last Report and write to file            
     $TDT.Debug.ExceptionLog.GetLastReport()    | Out-File -FilePath "$SQLTraceFolder\ES_LastReport.txt" -Force
     # Get Exception Log - Full Report and write to file                 
     $TDT.Debug.ExceptionLog.GetFullReport()    | Out-File -FilePath "$SQLTraceFolder\ES_FullReport.txt" -Force
     $TDT.Quit()                                 # Stop TDT
}