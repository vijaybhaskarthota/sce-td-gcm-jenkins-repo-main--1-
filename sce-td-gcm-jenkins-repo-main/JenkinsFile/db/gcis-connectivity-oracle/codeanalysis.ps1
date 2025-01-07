# code for code analysis
$TDT = $NULL 
try {
	$TDT = New-Object -ComObject 'Toad.ToadAutoObject'   # Start TDT  
        #$ENV:WORKSPACE = "C:\GitRepo\gcis-connectivity-oracle"                       # For local VS code Testing
        # Generating diff file
        $diff_file= $ENV:WORKSPACE+"\CICD\diff.log"
        $OutputFolder = $ENV:WORKSPACE + '/output'
        If(!(test-path $OutputFolder))
           {	New-Item -ItemType Directory -Force -Path $OutputFolder	} 

        $TDT.CodeAnalysis.ReportName   = "CodeAnalysisReport"                          # Report Name Title
        $TDT.CodeAnalysis.OutputFolder = $OutputFolder                                 # Local Output folder Name
        $TDT.CodeAnalysis.ReportFormats.IncludeHTML = $TRUE                            # Include All CA Report formats

        $filters = @(".pkb", ".pks", ".prc",".fnc",".trg") 
        Get-Content $diff_file |Select-String -pattern $filters| ForEach-Object {$TDT.CodeAnalysis.Files.Add("$ENV:WORKSPACE/$_")}
        # Get File Count
        $CodeAnalysisFileCount = $TDT.CodeAnalysis.Files.Count()
        if ($CodeAnalysisFileCount -gt 0) {
                Write-Host "Running CodeAnalysis.Files.Count : $CodeAnalysisFileCount"             
                # Execute Code Analysis  
                $TDT.CodeAnalysis.Execute()
        }
        else {
                Write-Host "Skipping CodeAnalysis.Files.Count : $CodeAnalysisFileCount"                            
        }       
}

finally {
  
        # Get Logfile Text and write to file
        $TDT.Debug.Logfile.GetText() | Out-File -FilePath ".\CICD\CA_Logfile.txt" -Force    
        # Get Logfile Filename
        $DebugFile = $TDT.Debug.Logfile.Filename()
        # Get Exception Log Filename
        $ExceptionLogFile = $TDT.Debug.ExceptionLog.Filename()
	 # Get Exception Log - Last Error and write to file
        $TDT.Debug.ExceptionLog.GetLastError()     | Out-File -FilePath ".\CICD\CA_LastError.txt" -Force
	 # Get Exception Log - Last Call Stack and write to file      
        $TDT.Debug.ExceptionLog.GetLastCallStack() | Out-File -FilePath ".\CICD\CA_LastCallStack.txt" -Force
	 # Get Exception Log - Last Call Last Report and write to file            
        $TDT.Debug.ExceptionLog.GetLastReport()    | Out-File -FilePath ".\CICD\CA_LastReport.txt" -Force
        # Get Exception Log - Full Report and write to file                 
        $TDT.Debug.ExceptionLog.GetFullReport()    | Out-File -FilePath ".\CICD\CA_FullReport.txt" -Force
        $TDT.Quit()                                 # Stop TDT
}