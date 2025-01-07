#Write-Host "INPUT Branch					:" $ENV:GIT_BRANCH
#Write-Host "Git Commit						:" $ENV:GIT_COMMIT
#dir env:
# Code for Comparing DB vs Git 

$TDT = $NULL 
try {
      #Creating Install script from Git Code
      Write-Host "compareDBvsGit:Creating Install Script from Git Code"
      $gitInstallScriptFile = $ENV:WORKSPACE+"\CICD\git_installscript.sql"
      $gitInstallScriptFile_withoutGrant = $ENV:WORKSPACE+"\CICD\git_installscript_withoutGrant.sql"
      $schemaCleanupScriptFile = $ENV:WORKSPACE+"\CICD\schema_cleanup.sql"
      Get-Content .\Resources\Database\Sequences\*.* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Tables\*.* -Exclude ALTER*,Alter* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Tables\*.* -Include ALTER*,Alter* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Index\*.* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Views\*.* -Include 000_GCM_V_CONNECTIVITY* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Packages\*.* -Include 000_GCM_PK_GLOBAL_VARIABLE*, GCM_PK_GLOBAL_VARIABLE* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Procedures\*.* -Include GCM_P_EXCEPTION_LOG* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Packages\*.* -Include 000_GCM_PKG_CONNECTIVITY*,000_GCM_PKG_BR_UTILITY* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Views\*.* -Include GCM_V_SUB_HIER_PLANNING* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Packages\*.* -Include 000_GCM_PKG_SCIM_DIST_METER_TO_GRID* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Type\*.* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Packages\*.* -Include 000_GCM_PKG_M2S*,000_GCM_PKG_SUB_HIERARCHY*,000_GCM_PKG_CONNECTIVITY_SVC* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Functions\*.* -Exclude GET_MRID_TOOL* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Views\*.* -Include GCM_V_LOCATION_OBJS*, GCM_V_STRUC_LAT_LONG*| Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\MaterializedViews\*.* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Views\*.* -Exclude 000_GCM_V_CONNECTIVITY*, GCM_V_LOCATION_OBJS*, GCM_V_STRUC_LAT_LONG*| Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Functions\*.* -Include GET_MRID_TOOL* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Packages\*.* -Include 000_GCM_PK_RAPTOR_GLOBAL_VARIABLE*, 000_GCM_PKG_STRUCTURE_FEEDER_INFO_SERVICE*,000_GCM_PKG_R3_RAPTOR*,000_GCM_PKG_SUB_I_CONN* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Procedures\*.* -Exclude GCM_P_EXCEPTION_LOG* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Packages\*.* -Exclude 000_GCM_PK_RAPTOR_GLOBAL_VARIABLE*, 000_GCM_PKG_SUB_I_CONN*, 000_GCM_PKG_R3_RAPTOR*, GCM_PK_GLOBAL_VARIABLE*, 000_GCM_PK_GLOBAL_VARIABLE*, 000_GCM_PKG_BR_UTILITY*, 000_GCM_PKG_CONNECTIVITY*,000_GCM_PKG_SCIM_DIST_METER_TO_GRID*,000_GCM_PKG_M2S*,000_GCM_PKG_STRUCTURE_FEEDER_INFO_SERVICE*,000_GCM_PKG_SUB_HIERARCHY*,000_GCM_PKG_CONNECTIVITY_SVC* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Triggers\*.* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Grant\*.* | Add-Content $gitInstallScriptFile
      Get-Content .\Resources\Database\Scheduler\*.* | Add-Content $gitInstallScriptFile
      Get-Content .\CICD\Compile.sql | Add-Content $gitInstallScriptFile
      
      #adding 1st and last lines to installscript
      @("/* Install Script */", "set echo on") +  (Get-Content $gitInstallScriptFile) | Set-Content $gitInstallScriptFile
      Add-Content $gitInstallScriptFile "`nset echo off"
      Write-Host "compareDBvsGit:Creating Install Script from Git Code Complete" $gitInstallScriptFile
      Get-Content $gitInstallScriptFile | Where-Object {$_ -notmatch "GRANT"} | Set-Content $gitInstallScriptFile_withoutGrant
      ((Get-Content -path $gitInstallScriptFile_withoutGrant -Raw) -replace 'TCGACDS_AGL','TCGACDS') | Set-Content $gitInstallScriptFile_withoutGrant
      Write-Host "compareDBvsGit:Creating Install Script from Git Code Complete - without GRANT" $gitInstallScriptFile_withoutGrant    
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
      $Devops = $TDT.Connections.NewConnection($DevopsConnectStr)  # Source DB credentials    
      
      #Code for Devops Schema Cleanup
      $CleanupScript               = $TDT.Scripts.Add()                                   # Set $Script Variable for Add function
      $CleanupScript.Connection    = $Devops                                              # Set Source connection info   	
      $CleanupScript.IncludeOutput = $TRUE      
      Write-Host "compareDBvsGit:Dropping all Objects in Devops DB"
      $CleanupScript.InputFile     = $schemaCleanupScriptFile
      $OutputLogFile = $CleanupScript.InputFile + "output.log"
      $CleanupScript.OutputFile    = $OutputLogFile
      $CleanupScript.Execute()
      Write-Host "compareDBvsGit: Error Count:" $CleanupScript.ErrorCount.ToString() " Execution Time :" $CleanupScript.ExecutionTime  " Max rows :" $CleanupScript.MaxRows.ToString()
      Write-Host "compareDBvsGit:Dropping all Objects in Devops DB Complete"

      #Code for Populating Devops Schema
      $Script               = $TDT.Scripts.Add()                                   # Set $Script Variable for Add function
      $Script.Connection    = $Devops                                              # Set Source connection info   	
      $Script.IncludeOutput = $TRUE      
      Write-Host "compareDBvsGit:Poulating Devops DB with Git Content:" $gitInstallScriptFile_withoutGrant	
      $Script.InputFile     = $gitInstallScriptFile_withoutGrant
      $OutputLogFile = $Script.InputFile + "output.log"
      $Script.OutputFile = $OutputLogFile
      Write-Host "compareDBvsGit:Running SQL Script in Devops DB" 
      E:/Oracle19/product/19.0.0/client_1/bin/sqlplus $DevopsConnectStr "@$gitInstallScriptFile_withoutGrant" -silent | out-file $OutputLogFile
      #(gc "@.\CICD\CICD\git_installscript_withoutGrant.sql") | ? {$_.trim() -ne "" } | set-content "@.\CICD\CICD\git_installscript_withoutGrant_EmptyLines.sql"
      #Write-Host "compareDBvsGit:Trimmed the New Lines in Install Script" 
      #E:/Oracle19/product/19.0.0/client_1/bin/sqlplus $DevopsConnectStr "@$git_installscript_withoutGrant" -silent | out-file $OutputLogFile
      #E:/Oracle19/product/19.0.0/client_1/bin/sqlplus $DevopsConnectStr "@.\CICD\CICD\git_installscript_withoutGrant_EmptyLines.sql" -silent | out-file $OutputLogFile
      
      #$Script.Execute()
      #Write-Host "compareDBvsGit: Error Count:" $Script.ErrorCount.ToString() " Execution Time :" $Script.ExecutionTime " Max rows :" $Script.MaxRows.ToString()
      Write-Host "compareDBvsGit:Running SQL Script in Devops DB Complete" 
      #$ScriptOutput = $Script.OutputText                                           # Output results to a Variable
      Write-Host "compareDBvsGit:Input SQL File for Devops DB Install:" + $Script.InputFile
      Write-Host "compareDBvsGit:Output SQL Log File for Devops DB install:" + $OutputLogFile
      #Write-Output $ScriptOutput > $OutputLogFile

      Write-Host "compareDBvsGit:Poulating Devops DB with Git Content Complete"



      # Set Schema Compare Parameters
      $TDT.CompareSchemas.StorageOptions.IncludeAll()                              # Include all Storage Options
      $TDT.CompareSchemas.TypeOptions.IncludeAll()                                 # Include all Type Options
      #$TDT.CompareSchemas.ObjectTypes.IncludeAll()                                 # Include all Object Types

      $TDT.CompareSchemas.DifferenceLimit = 50000                    
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
      $TDT.CompareSchemas.Target.Connection = $Devops                              # Set Target Connection info
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

