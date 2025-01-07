# Code for Comparing DB Schemas
$TDT = $NULL 
try {
     $TDT = New-Object -ComObject 'Toad.ToadAutoObject'   # Start TDT  
     $SourceConnectStr = $env:SRC_DB_CRED_USR + '/' + $env:SRC_DB_CRED_PSW + $env:SRC_DB_CONN_STR
     $TargetConnectStr = $env:TGT_DB_CRED_USR + '/' + $env:TGT_DB_CRED_PSW + $env:TGT_DB_CONN_STR
     Write-Host "compareTables:Connect Source String:" $SourceConnectStr	"Connect Target String:" $TargetConnectStr	
     
     # Make Connections to Source/Target Database
  	$Source = $TDT.Connections.NewConnection($SourceConnectStr)  # Source DB credentials    
     $Target = $TDT.Connections.NewConnection($TargetConnectStr)  # Source DB credentials    
     Write-Host "compareTables:Connect to Source/Target DB Successful"
     
     
     # Setting Source Connection Information
     $TDT.CompareMultipleTables.SourceConnection = 'TCGACDS'+$env:SRC_DB_CONN_STR                             # Set Source Connection info  

     $TDT.CompareMultipleTables.SourceSchema     = 'TCGACDS'                      # Set Source Schema
     # Setting Target Connection Information
     $TDT.CompareMultipleTables.TargetConnection = 'TCGACDS'+$env:TGT_DB_CONN_STR                              # Set Target Connection info
    $TDT.CompareMultipleTables.TargetSchema     = 'TCGACDS'                      # Set Target Schema

    #$TDT.CompareMultipleTables.TableMappings.Add('GCM_SCIM_SUBSTATION=GCM_SCIM_SUBSTATION');
    $TDT.CompareMultipleTables.SyncFolder = $ENV:WORKSPACE+"\JenkinsFile\gcis-data-table-compare\sql-output\"
    $TDT.CompareMultipleTables.ColumnMatchMode = 3
    $TDT.CompareMultipleTables.TableMatchMode = 1
    $TDT.CompareMultipleTables.ErrorMode = 1
    $TDT.CompareMultipleTables.SyncMode = 1
     # Run Schema Compare
     Write-Host "compareTables:Comparing Tables"
     $TDT.CompareMultipleTables.Execute()
     Write-Host "compareTables:Comparing Tables Complete"


     

}
finally {
  
  	 # Get Logfile Text and write to file
     $TDT.Debug.Logfile.GetText() | Out-File -FilePath ".\JenkinsFile\gcis-data-schema-compare\sql-trace\ES_Logfile.txt" -Force    
     # Get Logfile Filename
     $DebugFile = $TDT.Debug.Logfile.Filename()
     # Get Exception Log Filename
     $ExceptionLogFile = $TDT.Debug.ExceptionLog.Filename()
     write-host "DebugFile" $DebugFile "ExceptionLogFile" $ExceptionLogFile
	 # Get Exception Log - Last Error and write to file
     $TDT.Debug.ExceptionLog.GetLastError()     | Out-File -FilePath ".\JenkinsFile\gcis-data-schema-compare\sql-trace\ES_LastError.txt" -Force
	 # Get Exception Log - Last Call Stack and write to file      
     $TDT.Debug.ExceptionLog.GetLastCallStack() | Out-File -FilePath ".\JenkinsFile\gcis-data-schema-compare\sql-trace\ES_LastCallStack.txt" -Force
	 # Get Exception Log - Last Call Last Report and write to file            
     $TDT.Debug.ExceptionLog.GetLastReport()    | Out-File -FilePath ".\JenkinsFile\gcis-data-schema-compare\sql-trace\ES_LastReport.txt" -Force
     # Get Exception Log - Full Report and write to file                 
     $TDT.Debug.ExceptionLog.GetFullReport()    | Out-File -FilePath ".\JenkinsFile\gcis-data-schema-compare\sql-trace\ES_FullReport.txt" -Force
     $TDT.Quit()                                 # Stop TDT
}