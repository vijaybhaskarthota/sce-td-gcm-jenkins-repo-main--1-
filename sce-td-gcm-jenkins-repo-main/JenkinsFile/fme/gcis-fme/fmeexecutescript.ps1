#dir env:
<#
$FME_URL='https://aywcsgcm06.sce.eix.com'
$FME_TOKEN='aa854e34d09eb2206e54cb456d1dac79f579dc56'
#$ACTION="DOWNLOAD"
$ACTION="PUBLISH"
$ENVIRONMENT="BF"
#>

$FME_URL=$ENV:FME_URL
$FME_TOKEN=$ENV:FME_TOKEN
$ACTION=$ENV:ACTION
$ENVIRONMENT=$ENV:ENVIRONMENT
$FME_REPOSITORES="\\iewvdjnk01\Buildserver\FME\repositories\$ENVIRONMENT"
Write-Host "FME_URL:$FME_URL,FME_TOKEN:$FME_TOKEN,ACTION:$ACTION, ENVIRONMENT:$ENVIRONMENT"
$headers = @{
  'Authorization' = "fmetoken token=$FME_TOKEN"
  'Accept' = 'application/json'
}
#Publish Steps
$headers.Add("Content-Disposition", "attachment; filename=$fmw_name")
$headers.Add("Content-Type", 'application/octet-stream')
Write-Host "Progressing with Workspace Upload"
# Get-ChildItem "$FME_REPOSITORES" | ForEach-Object {
#   $repo_name=$_.Name
#   (Get-ChildItem $_.FullName  -Recurse -Include *.fmw) | ForEach-Object {
#     $fmw_name=$_.Name
#     Write-Host "Processing Repository: $repo_name        Workspace: $fmw_name"
#     $headers.Remove("Content-Disposition")
#     $headers.Add("Content-Disposition", "attachment; filename=$fmw_name")
#     try {
#         $Result=Invoke-WebRequest -UseBasicParsing -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items" -Method Post -Headers $headers -InFile "$FME_REPOSITORES\$repo_name\${fmw_name}"
#         Write-Host "        Status Code:" $Result.StatusCode "StatusDescription Code:" $Result.StatusDescription        
#       }
#       catch {
#         Write-Host "        Exception Status Code:" $_.Exception.Response.StatusCode "Exception Message:" $_.Exception.Message
#         if ($_.Exception.Response.StatusCode -eq "Conflict")
#         {
#           #code to replace the file on the server     
#           $Result=Invoke-WebRequest -UseBasicParsing -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items/$fmw_name" -Method Put -Headers $headers -InFile "$FME_REPOSITORES\$repo_name\${fmw_name}"
#           Write-Host "        Retry(Replace) Status Code:" $Result.StatusCode "Retry(Replace) StatusDescription Code:" $Result.StatusDescription        
#         }
#       }
#     Write-Host "Processing Repository: $repo_name        Workspace: $fmw_name   Complete"
#   } 
#   Write-Host "Processing of the Repository:" $repo_name "is complete"
# }
