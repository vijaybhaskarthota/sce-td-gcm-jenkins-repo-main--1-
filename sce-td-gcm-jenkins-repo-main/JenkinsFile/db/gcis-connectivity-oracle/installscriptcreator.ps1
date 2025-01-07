# exesequence = Sequences,Tables,Index,Functions,Views,MaterializedViews,Procedures,Packages,Triggers,Type,Grant
# Extracting Build Variables
$num_of_commit= $ENV:NUM_OF_COMMIT
$action= $ENV:ACTION
Write-Host "Number of Commits	:"  $num_of_commit
Write-Host "Build Action		:"  $action
Write-Host "SQL_COMPILE_FILE    :"  $ENV:SQL_COMPILE_FILE

# Generating diff file
$diff_file= $ENV:WORKSPACE+"\CICD\diff.log"
git.exe diff --name-only HEAD~$num_of_commit HEAD > $diff_file

$diff_file= ".\CICD\diff.log"
$diff_seq_file = ".\CICD\diffseq.log"
$InstallScriptFile = ".\CICD\installscript.sql"
Select-String '^.*Database/Sequences.*' $diff_file|%{$_.Matches.Value} > $diff_seq_file
Select-String '^.*Database/Tables.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Index.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Functions.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/MaterializedViews.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Views.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Procedures.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Packages.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Triggers.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Type.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Grant.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Scheduler.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file

$ObjectCount = (Get-Content $diff_seq_file|Measure-Object -Line).Lines 
if ($ObjectCount -gt 0) {
    Write-Host "Creating Install Script. Total Deployable File/Object Count in this Git Commit : $ObjectCount"                            
    Get-Content $diff_seq_file | ForEach-Object {gc $_; ""} | out-file $InstallScriptFile
    @("/* Install Script */", "set echo on", "set define off") +  (Get-Content $InstallScriptFile) | Set-Content $InstallScriptFile
    (Get-Content $ENV:SQL_COMPILE_FILE) | Add-Content $InstallScriptFile
    Add-Content $InstallScriptFile "`nset echo off"
}
else {
    Write-Host "Skipping Install Script Creation. Total Deployable File/Object Count in this Git Commit : $ObjectCount"                            
}  


