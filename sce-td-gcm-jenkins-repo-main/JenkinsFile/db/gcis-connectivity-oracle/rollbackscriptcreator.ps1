# exesequence = Sequences,Tables,Index,Functions,Views,MaterializedViews,Procedures,Packages,Triggers,Type,Grant
$num_of_commit= $ENV:NUM_OF_COMMIT
$action= $ENV:ACTION
Write-Host "Number of Commits	:"  $num_of_commit
Write-Host "Build Action		:"  $action
Write-Host "SQL_COMPILE_FILE    :"  $ENV:SQL_COMPILE_FILE

$diff_file= ".\CICD\diff.log"
$diff_seq_file = ".\CICD\diffseq.log"
$RollbackScriptFile = ".\CICD\rollbackscript.sql"
# Generating all previous Jenkin commit files
$previous_file= ".\CICD\previousfile.log"

git.exe ls-tree -r HEAD~$num_of_commit --name-only > $previous_file

Select-String '^.*Database/Sequences.*' $diff_file|%{$_.Matches.Value} > $diff_seq_file
Select-String '^.*Database/Tables.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Index.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Functions.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Views.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/MaterializedViews.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Procedures.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Packages.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Triggers.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Type.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Grant.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file
Select-String '^.*Database/Scheduler.*' $diff_file|%{$_.Matches.Value} >> $diff_seq_file


$ObjectCount = (Get-Content $diff_seq_file|Measure-Object -Line).Lines 
if ($ObjectCount -gt 0) {
    Write-Host "Creating Rollback Script. Total Deployable File/Object Count in this Git Commit : $ObjectCount"                            
    #Get-Content $diff_seq_file | ForEach-Object {gc $_; ""} | out-file $RollbackScriptFile

    Get-Content $diff_seq_file | ForEach-Object {
        if (Select-String $previous_file -Pattern "$_" ) {
            git show HEAD~${num_of_commit}:$_; ""
        }} | out-file $RollbackScriptFile
    
    #git show HEAD~2:Resources/Database/Procedures/GCM_SP_ETL_AUDIT_SSPH_SCIMCLASS_TRANS.prc
    @("/* Rollback Script */", "set echo on") +  (Get-Content $RollbackScriptFile) | Set-Content $RollbackScriptFile
    (Get-Content $ENV:SQL_COMPILE_FILE) | Add-Content $RollbackScriptFile
    Add-Content $RollbackScriptFile "`nset echo off"
    

}
else {
    Write-Host "Skipping Rollback Script Creation. Total Deployable File/Object Count in this Git Commit : $ObjectCount"                            
} 

