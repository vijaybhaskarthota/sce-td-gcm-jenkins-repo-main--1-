#
# PowerShell script to invoke FME REST service with error handling
#
# Alejandro Quesada
#
# 9/26/2019

$ExitCode = 0

$resp = try{
   $x=Invoke-WebRequest -Method Get -Uri "https://st-gcm-fme.sce.eix.com/fmejobsubmitter/GCM_R3_Workspace/GCM_FMW_ASPEN_PROCESSOR.fmw?SourceDataset_ORACLE_NONSPATIAL=ayxap05-scan.sce.com%3A1526%5Cl997_cyme&opt_showresult=false&opt_servicemode=sync&token=737c3a7609a407145d2f0cdbda9d26ff78c78740" -ea stop -TimeoutSec 86400
    Write-Host $x -fore green	
}
catch{
   Write-Host "Testing Output" $x -fore green
   Write-Host "`nUnable to call the HTTP endpoint" -fore red
   Write-Host "Code:" $_.Exception.Response.StatusCode.value__ -fore red
   Write-Host "Description:" $_.Exception.Response.StatusDescription -fore red
   Write-Host "Response Content:" $_.Exception.Response.Content -fore red
   Write-Host $_ -fore red
   $ExitCode = -1
}

Write-Host "Testing Output" $resp -fore green
Write-Host "Exit code:" $ExitCode
Exit $ExitCode