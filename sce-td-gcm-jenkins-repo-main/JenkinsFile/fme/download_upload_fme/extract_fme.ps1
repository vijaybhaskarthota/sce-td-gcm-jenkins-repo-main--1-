#dir env:
#$FME_URL='https://lywcpgcm02.sce.eix.com'
#$FME_TOKEN='ea75bd12f53050c40a29baa14bf13c6706fe226c'
<#
#$ACTION="DOWNLOAD"
$ACTION="PUBLISH"
$ENVIRONMENT="BF"
#>
$FME_URL=$env:FME_URL
$ACTION=$env:ACTION
$FME_TOKEN=$ENV:FME_TOKEN
$ENVIRONMENT=$ENV:ENVIRONMENT
$FME_REPOSITORES="E:\BuildServer\FME\repositories\"+$ENVIRONMENT
#$FME_WORKSPACE=$ENVIRONMENT:FME_WORKSPACE

Write-Host "FME_URL:$FME_URL,$ACTION"

               
#HTTP://<yourServerHost>/fmerest/v3/transformations/transact/Samples/austinDownload.fmw
# $FME_REPOSITORY="GCM_Demo"
# $FME_WORKSPACE="M2G_PROD_PAYLOAD_EXTRACTOR.fmw"

Write-Host "FME_URL:$FME_URL,PWD:$pwd,Repo Path:$FME_REPOSITORY"
$headers = @{
  'Authorization' = "fmetoken token=$FME_TOKEN"
  'Accept' = 'application/json'
  'Content-Type' = 'application/json'  
}


# $body = "{'publishedParameters': [{
#       "name": "BATCH_NO",
#       "value": "42"
#     }]}"
# $body = $FME_PublishedParameters
 # "{ 'ItemID':3661515, 'Name':'test'}"


# Move this power shell script functionality to Vars folder, 
# creating 3 function: trigger fme, status check FME, download fme logs. 
# Need to try calling non default function from Jenkin file directly otherwise will need to create 3 methods separately

Write-Host "Repo is $FME_REPOSITORES : "
if ($ACTION -eq "PUBLISH"){
  #Publish Steps
  #$headers.Add("Content-Disposition", "attachment; filename=$fmw_name")
  #$headers.Add("Content-Type", 'application/octet-stream')
  Write-Host "Progressing with Workspace Upload"
  Get-ChildItem "$FME_REPOSITORES" | ForEach-Object {
    $repo_name=$_.Name
    (Get-ChildItem $_.FullName  -Recurse -Include *.fmw) | ForEach-Object {
      $fmw_name=$_.Name
      Write-Host "Processing Repository: $repo_name        Workspace: $fmw_name"
      #$headers.Remove("Content-Disposition")
      $headers.Add("Content-Disposition", "attachment; filename=$fmw_name")
      $headers = @{
        'Authorization' = "fmetoken token=$FME_TOKEN"
        'Accept' = 'application/json'
        'Content-Disposition' = "attachment; filename=$ws_name"
        'Content-Type' = 'application/octet-stream' 
      }
      try {
          $Result=Invoke-WebRequest -UseBasicParsing -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items" -Method Post -Headers $headers -InFile "$FME_REPOSITORES\$repo_name\${fmw_name}"
           
          Write-Host "        Status Code:" $Result.StatusCode "StatusDescription Code:" $Result.StatusDescription        
        }
        catch {
          Write-Host "        Exception Status Code:" $_.Exception.Response.StatusCode "Exception Message:" $_.Exception.Message
          if ($_.Exception.Response.StatusCode -eq "Conflict")
          {
            #code to replace the file on the server     
            $Result=Invoke-WebRequest -UseBasicParsing -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items/$fmw_name" -Method Put -Headers $headers -InFile "$FME_REPOSITORES\$repo_name\${fmw_name}"
            Write-Host "        Retry(Replace) Status Code:" $Result.StatusCode "Retry(Replace) StatusDescription Code:" $Result.StatusDescription        
          }
        }
      Write-Host "Processing Repository: $repo_name        Workspace: $fmw_name   Complete"
    } 
    Write-Host "Processing of the Repository:" $repo_name "is complete"
  }
}
else {
    #Download Steps
    #Get All Repositories
    #https://aywcsgcm06.sce.eix.com/fmerest/v3/repositories?limit=-1&offset=-1
    $Result = Invoke-RestMethod -Uri "$FME_URL/fmerest/v3/repositories/?limit=-1&offset=-1" -Method Get -Headers $headers
    Write-Host "Total No. of Repositories in $ENVIRONMENT environment: "$Result.totalCount
     #Cleaning up the repositories folder recursively
    #Get-ChildItem C:\testdata -Recurse -Filter “mydata” | Remove-Item -Force -Recurse
    Get-ChildItem "$FME_REPOSITORES" -Recurse | Remove-Item -Force -Recurse
    #loop through all repositories iteratively to get all workspace names
    foreach ($item in $Result.items)
    {
      $repo_name=$item.name
      $Result = Invoke-RestMethod -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items?type=WORKSPACE" -Method Get -Headers $headers
      #$Result|ConvertTo-Json
      Write-Host "Total No. of Workspaces in the $repo_name Repository: "$Result.totalCount
      mkdir -p "$FME_REPOSITORES\$repo_name"
      foreach ($item in $Result.items)
      {
        $fmw_name=$item.name
        Write-Host "File Name:$FME_REPOSITORES\$repo_name\${fmw_name}"
        Write-Host $fmw_name  "$FME_URL/repositories/$repo_name/items/${fmw_name}?accept=contents"
        Invoke-WebRequest -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items/${fmw_name}?accept=contents" -Method Get -Headers $headers -OutFile "$FME_REPOSITORES\$repo_name\${fmw_name}"
      }
    } 
} 
