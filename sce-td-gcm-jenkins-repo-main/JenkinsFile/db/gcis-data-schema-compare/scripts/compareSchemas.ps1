# Code for Comparing DB Schemas
$TDT = $NULL 
try {
     $TDT = New-Object -ComObject 'Toad.ToadAutoObject'   # Start TDT  
     $SourceConnectStr = $env:SRC_DB_CRED_USR + '/' + $env:SRC_DB_CRED_PSW + $env:SRC_DB_CONN_STR
     $TargetConnectStr = $env:TGT_DB_CRED_USR + '/' + $env:TGT_DB_CRED_PSW + $env:TGT_DB_CONN_STR
     Write-Host "compareSchemas:Connect Source String:" $SourceConnectStr	"Connect Target String:" $TargetConnectStr	
     
     # Make Connections to Source/Target Database
  	$Source = $TDT.Connections.NewConnection($SourceConnectStr)  # Source DB credentials    
     $Target = $TDT.Connections.NewConnection($TargetConnectStr)  # Source DB credentials    
     Write-Host "compareSchemas:Connect to Source/Target DB Successful"
     
     # Set Schema Compare Parameters
     $TDT.CompareSchemas.StorageOptions.IncludeAll()                              # Include all Storage Options
     $TDT.CompareSchemas.TypeOptions.IncludeAll()                                 # Include all Type Options
     #$TDT.CompareSchemas.ObjectTypes.IncludeAll()                                 # Include all Object Types
     $TDT.CompareSchemas.DifferenceLimit = 100000                    
     $TDT.CompareSchemas.IncludeComments = $true
     $TDT.CompareSchemas.IncludeComments_Dependencies = $true
     $TDT.CompareSchemas.IncludeSchemaName = $true 
     $TDT.CompareSchemas.ObjectNameFilterByNOT = $true
     $TDT.CompareSchemas.ObjectNameFilterByCase = $true
     $TDT.CompareSchemas.ObjectNameFilters = "MDR%$;SYS_%$;MDNT_%$"
     
     $TDT.CompareSchemas.ObjectTypes.Indexes = $true
     $TDT.CompareSchemas.ObjectTypes.MaterializedViews = $true
     $TDT.CompareSchemas.ObjectTypes.Packages = $true
     $TDT.CompareSchemas.ObjectTypes.PackageBodies = $true
     $TDT.CompareSchemas.ObjectTypes.Procedures = $true
     $TDT.CompareSchemas.ObjectTypes.Sequences = $true
     $TDT.CompareSchemas.ObjectTypes.SynonymsPrivate = $true
     $TDT.CompareSchemas.ObjectTypes.SynonymsPublic = $true  
     $TDT.CompareSchemas.ObjectTypes.Tables = $true
     $TDT.CompareSchemas.ObjectTypes.Views = $true
     $TDT.CompareSchemas.ObjectTypes.SynonymsPublic = $true  
     $TDT.CompareSchemas.ObjectTypes.Sequences = $true
     $TDT.CompareSchemas.ObjectTypes.SynonymsPrivate = $true
     $TDT.CompareSchemas.ObjectTypes.SynonymsPublic = $true  
      
     # Setting Source Connection Information
     $TDT.CompareSchemas.Source.Connection = $Source                              # Set Source Connection info      
     $TDT.CompareSchemas.Source.Schema     = 'TCGACDS'                      # Set Source Schema
     # Setting Target Connection Information
     $TDT.CompareSchemas.Target.Connection = $Target                              # Set Target Connection info
     $TDT.CompareSchemas.Target.Schema     = 'TCGACDS'                      # Set Target Schema


     # Run Schema Compare
     Write-Host "compareSchemas:Comparing Schemas"
     $TDT.CompareSchemas.Execute()
     Write-Host "compareSchemas:Comparing Schemas Complete"

     # Get CompareSchema output scripts
     $DifferenceCount = $TDT.CompareSchemas.GetDifferenceCount()   
     $Script_filename = $ENV:WORKSPACE+"\JenkinsFile\db\gcis-data-schema-compare\sql-output\compareSchemas_SynchronizationScript.sql"
     $DifferenceDetailsCSV_filename = $ENV:WORKSPACE+"\JenkinsFile\db\gcis-data-schema-compare\sql-output\compareSchemas_DifferenceDetailsCSV.csv"
     $DifferenceDetailsHTML_filename = $ENV:WORKSPACE+"\JenkinsFile\db\gcis-data-schema-compare\sql-output\compareSchemas_DifferenceDetailsHTML.html"
     $DifferenceDetailsTXT_filename = $ENV:WORKSPACE+"\JenkinsFile\db\gcis-data-schema-compare\sql-output\compareSchemas_DifferenceDetailsTXT.txt"
     $DifferenceSummaryHTML_filename = $ENV:WORKSPACE+"\JenkinsFile\db\gcis-data-schema-compare\sql-output\compareSchemas_DifferenceSummaryHTML.html"
     
     Write-Host "compareSchemas:Total Number of Differences DB vs GIT :" $DifferenceCount.ToString()
     Set-Content -Path $Script_filename -Value $TDT.CompareSchemas.GetScript()
     Set-Content -Path $DifferenceDetailsCSV_filename -Value $TDT.CompareSchemas.GetDifferenceDetailsCSV()
     Set-Content -Path $DifferenceDetailsHTML_filename -Value $TDT.CompareSchemas.GetDifferenceDetailsHTML()
     Set-Content -Path $DifferenceDetailsTXT_filename -Value $TDT.CompareSchemas.GetDifferenceDetailsTXT()
     Set-Content -Path $DifferenceSummaryHTML_filename -Value $TDT.CompareSchemas.GetDifferenceSummaryHTML()
}
finally {
  
  	 # Get Logfile Text and write to file
     $TDT.Debug.Logfile.GetText() | Out-File -FilePath ".\JenkinsFile\db\gcis-data-schema-compare\sql-trace\ES_Logfile.txt" -Force    
     # Get Logfile Filename
     $DebugFile = $TDT.Debug.Logfile.Filename()
     # Get Exception Log Filename
     $ExceptionLogFile = $TDT.Debug.ExceptionLog.Filename()
     write-host "DebugFile" $DebugFile "ExceptionLogFile" $ExceptionLogFile
	 # Get Exception Log - Last Error and write to file
     $TDT.Debug.ExceptionLog.GetLastError()     | Out-File -FilePath ".\JenkinsFile\db\gcis-data-schema-compare\sql-trace\ES_LastError.txt" -Force
	 # Get Exception Log - Last Call Stack and write to file      
     $TDT.Debug.ExceptionLog.GetLastCallStack() | Out-File -FilePath ".\JenkinsFile\db\gcis-data-schema-compare\sql-trace\ES_LastCallStack.txt" -Force
	 # Get Exception Log - Last Call Last Report and write to file            
     $TDT.Debug.ExceptionLog.GetLastReport()    | Out-File -FilePath ".\JenkinsFile\db\gcis-data-schema-compare\sql-trace\ES_LastReport.txt" -Force
     # Get Exception Log - Full Report and write to file                 
     $TDT.Debug.ExceptionLog.GetFullReport()    | Out-File -FilePath ".\JenkinsFile\db\gcis-data-schema-compare\sql-trace\ES_FullReport.txt" -Force
     $TDT.Quit()                                 # Stop TDT
}