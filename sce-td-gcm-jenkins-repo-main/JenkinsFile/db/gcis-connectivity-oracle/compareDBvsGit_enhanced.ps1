#Write-Host "INPUT Branch					:" $ENV:GIT_BRANCH
#Write-Host "Git Commit						:" $ENV:GIT_COMMIT
#dir env:
# Code for Comparing DB vs Git 
$TDT = $NULL 
try {
     #Creating Install script from Git Code
     Write-Host "compareDBvsGit:Creating Install Script from Git Code"
     $devopsFileList = $ENV:WORKSPACE+"\CICD\devopsFileList.log"
     $schemaCleanupScriptFile = $ENV:WORKSPACE+"\CICD\schema_cleanup.sql"
     $devopsDBlogFolder = $ENV:WORKSPACE+"\CICD\devopsDBlog\"
      Get-ChildItem .\Resources\Database\Sequences\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Tables\ -Filter *.* -Exclude ALTER*,Alter* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Tables\* -Filter *.* -Include ALTER*,Alter* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Index\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Functions\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Views\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\MaterializedViews\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Procedures\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Packages\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Triggers\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Type\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Grant\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\Resources\Database\Scheduler\ -Filter *.* | ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      Get-ChildItem .\CICD\ -Filter Compile.sql| ForEach-Object { $_.FullName } | Add-Content $devopsFileList
      
      $TDT = New-Object -ComObject 'Toad.ToadAutoObject'   # Start TDT  
      $SourceConnectStr = $env:DB_CRED_USR + '/' + $env:DB_CRED_PSW + $env:DB_CONN_STR
      $DevopsConnectStr = $env:DEVOPS_DB_CRED_USR + '/' + $env:DEVOPS_DB_CRED_PSW + $env:DEVOPS_DB_CONN_STR
      #$SourceConnectStr = 'TCGACDS_FLBK/Edison_9089@ayxp05-scan.sce.com:1526/L904_CYME'         #for local testing
      #$TargetConnectStr = 'TCGACDS_FLBK/Edison_9089@ayxp05-scan.sce.com:1526/L904_CYME'         #for local testing
      #$ENV:ACTION = "INSTALL"                                                             #for local testing
      #$ENV:WORKSPACE = "C:\GitRepo\gcis-connectivity-oracle"                              #for local testing
  	 Write-Host "compareDBvsGit:Connect Source String:" $SourceConnectStr	
      Write-Host "compareDBvsGit:Connect Devops String:" $DevopsConnectStr	

      # Make Connections to Source Database
  	 $Source = $TDT.Connections.NewConnection($SourceConnectStr)  # Source DB credentials    
      #$data = @('Zero','One','Two','Three')
      $Devops = @($TDT.Connections.NewConnection($DevopsConnectStr),$TDT.Connections.NewConnection($DevopsConnectStr),$TDT.Connections.NewConnection($DevopsConnectStr),$TDT.Connections.NewConnection($DevopsConnectStr))  # Devops DB credentials    
      
      #Code for Devops Schema Cleanup
      $CleanupScript               = $TDT.Scripts.Add()                                   # Set $Script Variable for Add function
      $CleanupScript.Connection    = $Devops[0]                                              # Set Source connection info   	
      $CleanupScript.IncludeOutput = $TRUE      
      Write-Host "compareDBvsGit:Dropping all Objects in Devops DB"
      $CleanupScript.InputFile     = $schemaCleanupScriptFile
      $OutputLogFile = $CleanupScript.InputFile + "output.log"
      $CleanupScript.OutputFile    = $OutputLogFile
      $CleanupScript.Execute()
      Write-Host "compareDBvsGit: Error Count:" $CleanupScript.ErrorCount.ToString() " Execution Time :" $CleanupScript.ExecutionTime  " Max rows :" $CleanupScript.MaxRows.ToString()
      Write-Host "compareDBvsGit:Dropping all Objects in Devops DB Complete"

      #Code for Populating Devops Schema
      $Files = Get-Content $devopsFileList
      Write-Host "compareDBvsGit:Poulating Devops DB with Git Content"
      foreach ($File in $Files)
      {
       $Script               = $TDT.Scripts.Add()
       $Script.Connection    = $Devops[$TDT.Scripts.Count() % 4]
       $Script.IncludeOutput = $TRUE
       if (-Not $Script.Connection.Connected()) {
          Write-Host "compareDBvsGit: Connection is Bad . Resetting it"
          $Devops[$TDT.Scripts.Count() % 4] = $TDT.Connections.NewConnection($DevopsConnectStr)
          $Script.Connection = $Devops[$TDT.Scripts.Count() % 4]
       }
       else {
          Write-Host "compareDBvsGit: Connection is Good"
       }
       #$Script.MaxRows       = $ScriptMaxRows
       ((Get-Content $File)| Where-Object {$_ -notmatch "GRANT"})| Set-Content $File
       ((Get-Content -path $File -Raw) -replace 'TCGACDS_AGL','TCGACDS') | Set-Content $File
       $Script.InputFile     = $File
       $Script.OutputFile    = $devopsDBlogFolder + (Split-Path $File -Parent|Split-Path -Leaf) +"."+ (Split-Path $File -Leaf)+".log"
       $Script.Execute()
       Write-Host "compareDBvsGit: Scripts Count" $TDT.Scripts.Count() " Error Count:" $Script.ErrorCount.ToString() " Execution Time:" $Script.ExecutionTime " Max rows:" $Script.MaxRows.ToString() " Script Infile:" $Script.InputFile " Script Outfile:" $Script.OutputFile" Script.OutputText:" $Script.OutputText
      }

      # Set Schema Compare Parameters
      $TDT.CompareSchemas.StorageOptions.IncludeAll()                              # Include all Storage Options
      $TDT.CompareSchemas.TypeOptions.IncludeAll()                                 # Include all Type Options
      #$TDT.CompareSchemas.ObjectTypes.IncludeAll()                                 # Include all Object Types

      $TDT.CompareSchemas.DifferenceLimit = 50000                    
      $TDT.CompareSchemas.IncludeComments = $true
      $TDT.CompareSchemas.IncludeComments_Dependencies = $true
      $TDT.CompareSchemas.IncludeSchemaName = $true 
   
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
      $TDT.CompareSchemas.Target.Connection = $Devops[0]                              # Set Target Connection info
      $TDT.CompareSchemas.Target.Schema     = 'TCGACDS'                      # Set Target Schema


     # Run Schema Compare
     Write-Host "compareDBvsGit:Comparing Schemas"
     $TDT.CompareSchemas.Execute()
     Write-Host "compareDBvsGit:Comparing Schemas Complete"


     # Get CompareSchema output scripts
     $DifferenceCount = $TDT.CompareSchemas.GetDifferenceCount()    
     #$SyncScript = $TDT.CompareSchemas.GetScript()                                    # Get Output and save to $Script variable
     #$DifferenceDetailsCSV = $TDT.CompareSchemas.GetDifferenceDetailsCSV()
     #$DifferenceDetailsHTML = $TDT.CompareSchemas.GetDifferenceDetailsHTML()
     #$DifferenceDetailsTXT = $TDT.CompareSchemas.GetDifferenceDetailsTXT()
     #$DifferenceSummaryHTML = $TDT.CompareSchemas.GetDifferenceSummaryHTML()
     
     $Script_filename = $ENV:WORKSPACE+"\CICD\DB_Git_SynchronizationScript.sql"
     $DifferenceDetailsCSV_filename = $ENV:WORKSPACE+"\CICD\DB_Git_DifferenceDetailsCSV.csv"
     $DifferenceDetailsHTML_filename = $ENV:WORKSPACE+"\CICD\DB_Git_DifferenceDetailsHTML.html"
     $DifferenceDetailsTXT_filename = $ENV:WORKSPACE+"\CICD\DB_Git_DifferenceDetailsTXT.txt"
     $DifferenceSummaryHTML_filename = $ENV:WORKSPACE+"\CICD\DB_Git_DifferenceSummaryHTML.html"
     
     Write-Host "compareDBvsGit:Total Number of Differences DB vs GIT :" $DifferenceCount.ToString()
     #Write-Output $DifferenceDetailsCSV > $DifferenceDetailsCSV_filename
     #Write-Output $DifferenceDetailsHTML > $DifferenceDetailsHTML_filename
     #Write-Output $DifferenceDetailsTXT > $DifferenceDetailsTXT_filename
     #Write-Output $DifferenceSummaryHTML > $DifferenceSummaryHTML_filename
     #Write-Output $SyncScript > $Script_filename
     Set-Content -Path $Script_filename -Value $TDT.CompareSchemas.GetScript()
     Set-Content -Path $DifferenceDetailsCSV_filename -Value $TDT.CompareSchemas.GetDifferenceDetailsCSV()
     Set-Content -Path $DifferenceDetailsHTML_filename -Value $TDT.CompareSchemas.GetDifferenceDetailsHTML()
     Set-Content -Path $DifferenceDetailsTXT_filename -Value $TDT.CompareSchemas.GetDifferenceDetailsTXT()
     Set-Content -Path $DifferenceSummaryHTML_filename -Value $TDT.CompareSchemas.GetDifferenceSummaryHTML()
}
finally {
  
  	 # Get Logfile Text and write to file
     $TDT.Debug.Logfile.GetText() | Out-File -FilePath ".\CICD\ES_Logfile.txt" -Force    
     # Get Logfile Filename
     $DebugFile = $TDT.Debug.Logfile.Filename()
     # Get Exception Log Filename
     $ExceptionLogFile = $TDT.Debug.ExceptionLog.Filename()
     write-host "DebugFile" $DebugFile "ExceptionLogFile" $ExceptionLogFile
	 # Get Exception Log - Last Error and write to file
     $TDT.Debug.ExceptionLog.GetLastError()     | Out-File -FilePath ".\CICD\ES_LastError.txt" -Force
	 # Get Exception Log - Last Call Stack and write to file      
     $TDT.Debug.ExceptionLog.GetLastCallStack() | Out-File -FilePath ".\CICD\ES_LastCallStack.txt" -Force
	 # Get Exception Log - Last Call Last Report and write to file            
     $TDT.Debug.ExceptionLog.GetLastReport()    | Out-File -FilePath ".\CICD\ES_LastReport.txt" -Force
     # Get Exception Log - Full Report and write to file                 
     $TDT.Debug.ExceptionLog.GetFullReport()    | Out-File -FilePath ".\CICD\ES_FullReport.txt" -Force
     $TDT.Quit()                                 # Stop TDT
}