def call()
{

}
//Searchs the sce-td-gcm-jenkins-repo files in @script folder and provides the full path
def getFilePath(String fileName) 
{
    echo "getFilePath:fileName:${fileName},Script Folder:${env.WORKSPACE}@script"
    dir("${env.WORKSPACE}@script") {
        def files = findFiles(glob: "**/${fileName}")
        echo "getFilePath:fileName:${fileName},Script Folder:${env.WORKSPACE}@script,No of Matching files:${files.size()},files:${files}"
        return "${env.WORKSPACE}@script\\${files[0].path}"
    }
}
//Creates list for workspaces to be installed or rolled back
def createFMEWSList()
{
    //bat 'set'
    //Make output directory
    powershell  label: 'Create Output Directory', 
                script: 'mkdir -p output -ErrorAction Ignore'
    //Create Install List
    powershell  label: 'FME Install List Creation', 
                script: '''git.exe diff --name-only HEAD~$ENV:NUM_OF_COMMIT HEAD > output/FMECommitList.log
                        Select-String '^.*/*.fmw' output/FMECommitList.log|%{$_.Matches.Value} > output/FMECommitListfiltererd.log
                        $ObjectCount = (Get-Content output/FMECommitListfiltererd.log|Measure-Object -Line).Lines 
                        if ($ObjectCount -gt 0) {
                            Write-Host "Creating Install Script. Total Deployable File/Object Count in this Git Commit:$ObjectCount"                            
                            Copy-Item "output/FMECommitListfiltererd.log" -Destination "output/FMEInstallListfinal.log"
                        }
                        else {
                                Write-Host "Skipping Install Script Creation. Total Deployable File/Object Count in this Git Commit:$ObjectCount"                            
                        }'''
    //Create Rollback List
    powershell  label: 'FME Rollback List Creation', 
                script: '''git.exe ls-tree -r HEAD~$ENV:NUM_OF_COMMIT --name-only > output/FMEPreviousStateList.log
                        $ObjectCount = (Get-Content output/FMECommitListfiltererd.log|Measure-Object -Line).Lines 
                        if ($ObjectCount -gt 0) {
                            New-Item output/FMERollbackListfinal.log -Force -ErrorAction Ignore
                            Write-Host "Creating Rollback Script. Total Deployable File/Object Count in this Git Commit:$ObjectCount"                            
                            Get-Content output/FMECommitListfiltererd.log | ForEach-Object {
                                if (Select-String output/FMEPreviousStateList.log -Pattern "$_" ) {
                                    Write-Host "Match Found $_ . Previous version of this exists in the previous commit"
                                    Add-Content output/FMERollbackListfinal.log $_
                                    New-Item output/$_ -ItemType File -Force
                                    git checkout HEAD~$ENV:NUM_OF_COMMIT $_
                                    Write-Host "Git Checkout for old version complete"
                                    Copy-Item $_ -Destination output/$_
                                    Write-Host "Copied Checked out file to output folder complete"
                                    git checkout HEAD $_
                                    Write-Host "Git Checkout the latest version. Restoring the working directory"
                                }
                                else{
                                    Write-Host "Match Not Found $_ .Previous version of this file does not exist in the previous commit"   
                                }
                            } 
                            if ( (Get-Content output/FMERollbackListfinal.log|Measure-Object -Line).Lines -eq 0) {
                                Remove-Item output/FMERollbackListfinal.log
                                Write-Host "Skipping Rollback Script Creation. Total Deployable File/Object Count in this Git Commit:0"
                            }
                        }
                        else {
                                Write-Host "Skipping Rollback Script Creation. Total Deployable File/Object Count in this Git Commit: $ObjectCount"                            
                        }'''
    //archiving the lists
    archiveArtifacts artifacts: 'output/*.log,output/**/*.fmw', followSymlinks: false  
}
//Install FME Workspaces Script
def installFMEWS()
{
    echo "FMEUtil.installFMEWS:Started"
    powershell  label: 'FME Install FME Workspaces', 
                script: '''if (Get-Item -Path output/FMEInstallListfinal.log -ErrorAction Ignore){
                            $ObjectCount = (Get-Content output/FMEInstallListfinal.log|Measure-Object -Line).Lines 
                            if($ObjectCount -gt 0){
                                Write-Host "FMEUtil.installFMEWS:Progressing with Install FME Workspaces. Total Deployable File/Object Count in this Git Commit:$ObjectCount"                            
                                Get-Content output/FMEInstallListfinal.log | ForEach-Object {
                                    Write-Host "FMEUtil.installFMEWS:Processing FME Workspace:$_"
                                    $WS=Get-Item $_
                                    $repo_name=$WS.Directory.Name
                                    $ws_name=$WS.Name
                                    $ws_fullpath=$WS.FullName
                                    $FME_URL=$ENV:FME_URL
                                    $FME_TOKEN=$ENV:FME_TOKEN
                                    Write-Host "FMEUtil.installFMEWS:Processing WS Started:Repository Name:$repo_name,Workspace Name:$ws_name,WS Full path:$ws_fullpath,FME URL:$FME_URL,FME Token:$FME_TOKEN"
                                    $headers = @{
                                                  'Authorization' = "fmetoken token=$FME_TOKEN"
                                                  'Accept' = 'application/json'
                                                  'Content-Disposition' = "attachment; filename=$ws_name"
                                                  'Content-Type' = 'application/octet-stream'
                                                }
                                    try {
                                      $Result=Invoke-WebRequest -UseBasicParsing -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items" -Method Post -Headers $headers -InFile "$ws_fullpath"
                                      Write-Host "FMEUtil.installFMEWS:Status Code:" $Result.StatusCode "StatusDescription Code:" $Result.StatusDescription        
                                    }
                                    catch {
                                      Write-Host "FMEUtil.installFMEWS:Exception Status Code:" $_.Exception.Response.StatusCode "Exception Message:" $_.Exception.Message
                                      if ($_.Exception.Response.StatusCode -eq "Conflict"){
                                        #code to replace the file on the server     
                                        $Result=Invoke-WebRequest -UseBasicParsing -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items/$ws_name" -Method Put -Headers $headers -InFile "$ws_fullpath"
                                        Write-Host "FMEUtil.installFMEWS:Retry(Replace) Status Code:" $Result.StatusCode "Retry(Replace) StatusDescription Code:" $Result.StatusDescription        
                                      }
                                    }
                                    Write-Host "FMEUtil.installFMEWS:Processing WS Completed:Repository Name:$repo_name,Workspace Name:$ws_name,WS Full path:$ws_fullpath,FME URL:$FME_URL,FME Token:$FME_TOKEN"
                                }
                            }
                            else{
                                Write-Host "FMEUtil.installFMEWS:Skipping Install FME Workspaces. Total Deployable File/Object Count in this Git Commit:$ObjectCount"                            
                            }
                        }
                        else {
                                Write-Host "FMEUtil.installFMEWS:Skipping Install FME Workspaces. output/FMEInstallListfinal.log does not exist"                            
                        }'''     
    echo "FMEUtil.installFMEWS:Completed"
}
//Rollback FME Workspaces Script
def rollbackFMEWS()
{
    echo "FMEUtil.rollbackFMEWS:Started"
    powershell  label: 'FME Rollback FME Workspaces', 
                script: '''if (Get-Item -Path output/FMERollbackListfinal.log -ErrorAction Ignore){
                        $ObjectCount = (Get-Content output/FMERollbackListfinal.log|Measure-Object -Line).Lines 
                        if($ObjectCount -gt 0){
                            Write-Host "FMEUtil.rollbackFMEWS:Progressing with Install FME Workspaces. Total Deployable File/Object Count in this Git Commit:$ObjectCount"                            
                            Get-Content output/FMERollbackListfinal.log | ForEach-Object {
                                Write-Host "FMEUtil.rollbackFMEWS:Processing FME Workspace:$_"
                                $WS=Get-Item output/$_
                                $repo_name=$WS.Directory.Name
                                $ws_name=$WS.Name
                                $ws_fullpath=$WS.FullName
                                $FME_URL=$ENV:FME_URL
                                $FME_TOKEN=$ENV:FME_TOKEN
                                Write-Host "FMEUtil.rollbackFMEWS:Processing WS Started:Repository Name:$repo_name,Workspace Name:$ws_name,WS Full path:$ws_fullpath,FME URL:$FME_URL,FME Token:$FME_TOKEN"
                                $headers = @{
                                              'Authorization' = "fmetoken token=$FME_TOKEN"
                                              'Accept' = 'application/json'
                                              'Content-Disposition' = "attachment; filename=$ws_name"
                                              'Content-Type' = 'application/octet-stream'
                                            }
                                try {
                                  $Result=Invoke-WebRequest -UseBasicParsing -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items" -Method Post -Headers $headers -InFile "$ws_fullpath"
                                  Write-Host "FMEUtil.rollbackFMEWS:Status Code:" $Result.StatusCode "StatusDescription Code:" $Result.StatusDescription        
                                }
                                catch {
                                  Write-Host "FMEUtil.rollbackFMEWS:Exception Status Code:" $_.Exception.Response.StatusCode "Exception Message:" $_.Exception.Message
                                  if ($_.Exception.Response.StatusCode -eq "Conflict"){
                                    #code to replace the file on the server     
                                    $Result=Invoke-WebRequest -UseBasicParsing -Uri "$FME_URL/fmerest/v3/repositories/$repo_name/items/$ws_name" -Method Put -Headers $headers -InFile "$ws_fullpath"
                                    Write-Host "FMEUtil.rollbackFMEWS:Retry(Replace) Status Code:" $Result.StatusCode "Retry(Replace) StatusDescription Code:" $Result.StatusDescription        
                                  }
                                }
                                Write-Host "FMEUtil.rollbackFMEWS:Processing WS Completed:Repository Name:$repo_name,Workspace Name:$ws_name,WS Full path:$ws_fullpath,FME URL:$FME_URL,FME Token:$FME_TOKEN"
                            }
                        }
                        else{
                            Write-Host "FMEUtil.rollbackFMEWS:Skipping Rollback FME Workspaces. Total Deployable File/Object Count in this Git Commit:$ObjectCount"                            
                        }
                    }
                    else {
                            Write-Host "FMEUtil.rollbackFMEWS:Skipping Rollback FME Workspaces. output/FMEInstallListfinal.log does not exist"                            
                    }'''     
    echo "FMEUtil.rollbackFMEWS:Completed"
}

// Fetch Environment Details
def getFMEEnvironmentDetails(String env) {
def fme_props = loadProperties("FME")
echo "getFMEEnvironmentDetails-Started"
def FME_URL_DETAIL
def FME_TOKEN_DETAIL
    switch("${env}") {            
         case 'DEV': 
            FME_URL_DETAIL = "${fme_props['fme.server.url.dev']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.dev']}"
            break; 
         case 'ST': 
            FME_URL_DETAIL = "${fme_props['fme.server.url.st']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.st']}"
            break; 
        case 'PT': 
            FME_URL_DETAIL = "${fme_props['fme.server.url.pt']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.pt']}"
            break;        
        case 'REGR':
            FME_URL_DETAIL = "${fme_props['fme.server.url.reg']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.reg']}"
            break;     
        case 'BF':
            FME_URL_DETAIL = "${fme_props['fme.server.url.bf']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.bf']}"
            break;     
        case 'PROD':
            FME_URL_DETAIL = "${fme_props['fme.server.url.prod']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.prod']}"
            break;     
      }
    def fme_details= ["FMETOKEN": "${FME_TOKEN_DETAIL}","FMEURL":"${FME_URL_DETAIL}"]
    echo "getFMEEnvironmentDetails-Completed"
    return  fme_details 
}

// List All Tokens for Environment.
def listAllTokens(String ENVIRONMENT){
  echo "listAllToken:Environment:${ENVIRONMENT}:Starting"
  def fmedetails =  getFMEEnvironmentDetails("${ENVIRONMENT}")
  def FME_TOKEN="${fmedetails['FMETOKEN']}"
  def FME_URL="${fmedetails['FMEURL']}"
  try{
  def jobStatus = httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]], outputFile: 'listAllFMETokenResult', url: "${FME_URL}/fmerest/v3/tokens?limit=-1&offset=-1", wrapAsMultipart: false
  def jobStatusObj = readJSON text: "${jobStatus.content}"
  echo "listAllToken:Environment:${ENVIRONMENT}:Completed. Total Token count: ${jobStatusObj['totalCount']}"  
  //echo "listAllToken-.Total Token list: ${jobStatusObj['items']}"
  return jobStatusObj
  }catch (Exception excep){
  echo "listAllTokens-Exception"
  throw (excep)
  }
}

def retrieveFMERepository(String ENVIRONEMNT) {
    echo "FMEUtills.retriveFMERepository:ENVIRONMENT: ${ENVIRONMENT}"
    def fmedetails =  getFMEEnvironmentDetails("${ENVIRONMENT}")
    def FME_TOKEN="${fmedetails['FMETOKEN']}"
    def FME_URL="${fmedetails['FMEURL']}" 
    def httpResponse = httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]], outputFile: 'result', httpMode: 'GET', url: "${FME_URL}/fmerest/v3/repositories?limit=-1&offset=-1", wrapAsMultipart: false
    def jsonResponse = readJSON text: "${httpResponse.content}"
    echo "retriveFMERepository:${jsonResponse}"
    def List = jsonResponse["items"]["name"].collect()
    def RepositoryList = [] as ArrayList
    for (item in List) {
            RepositoryList.add("${item}")
    }
    echo "retriveFMERepository:Repositry List:${RepositoryList}"
    return RepositoryList
}

def retrieveFMEWorkspace(String ENVIRONEMNT,String FME_REPOSITORY) {
    echo "FMEUtills.retriveFMERepository:ENVIRONMENT:${ENVIRONMENT},FME_REPOSITORY:${FME_REPOSITORY}"
    def fmedetails =  getFMEEnvironmentDetails("${ENVIRONMENT}")
    def FME_TOKEN="${fmedetails['FMETOKEN']}"
    def FME_URL="${fmedetails['FMEURL']}" 
    //  https://aywcdgcm02.sce.eix.com/fmerest/v3/repositories/Samples/items?type=WORKSPACE
    def httpResponse = httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]], outputFile: 'result', httpMode: 'GET', url: "${FME_URL}/fmerest/v3/repositories/${FME_REPOSITORY}/items?type=WORKSPACE", wrapAsMultipart: false
    def jsonResponse = readJSON text: "${httpResponse.content}"
    echo "retriveFMEWorkspace:${jsonResponse}"
    def List = jsonResponse["items"]["name"].collect()
    def WorkspaceList = [] as ArrayList
    for (item in List) {
            WorkspaceList.add("${item}")
    }
    echo "retriveFMEWorkspace:Workspace List:${WorkspaceList}"
    return WorkspaceList
}

// Update a particular token in given environment.
def updateToken(String ENVIRONMENT,Map tokenToUpdate){
  echo "updateToken:Processing Token expiring within 7 days: name:${tokenToUpdate['name']},type:${tokenToUpdate['type']},user:${tokenToUpdate['user']},expirationDate:${tokenToUpdate['expirationDate']},description:${tokenToUpdate['description']} Started"    
  def fmedetails =  getFMEEnvironmentDetails("${ENVIRONMENT}")
  def FME_TOKEN="${fmedetails['FMETOKEN']}"
  def FME_URL="${fmedetails['FMEURL']}" 
  try {
    def tokenName = URLEncoder.encode("${tokenToUpdate['name']}","UTF-8").replace("+", "%20")
    def url= "${FME_URL}/fmerest/v3/tokens/${tokenToUpdate['user']}/${tokenName}" 
    def body="{\"expirationTimeout\":31536000}"
    def fme_tokenResult = httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]],httpMode: 'PUT',requestBody: "${body}", url:"${url}", wrapAsMultipart: true
    def tokenUpdateResult= readJSON text: "${fme_tokenResult.content}"
    echo "updateToken:tokenUpdateResult: ${tokenUpdateResult} fme_tokenResult:${fme_tokenResult},${fme_tokenResult.status}"
    if("${fme_tokenResult.status}"!=("204")){
        office365ConnectorSend color: '#FF0000', message: "FME Token Extension Failed for token name:${tokenToUpdate['name']},type:${tokenToUpdate['type']},user:${tokenToUpdate['user']},expirationDate:${tokenToUpdate['expirationDate']},description:${tokenToUpdate['description']}", status: 'Failure', webhookUrl: 'https://edisonintl.webhook.office.com/webhookb2/630eb4c3-e34b-45d7-a316-1948c49a2e3a@5b2a8fee-4c95-4bdc-8aae-196f8aacb1b6/JenkinsCI/344bf5a79c4a40aab31a313806126cbf/a3a8382e-c883-4ff6-8f7a-fe0862721a83'
         throw (new Exception("updateToken-FME Job Failed."))
    }
    else{
        fme_tokenResult = httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]],httpMode: 'GET', url:"${url}", wrapAsMultipart: false
        def UpdatedToken= readJSON text: "${fme_tokenResult.content}"
        echo "UpdatedToken: ${UpdatedToken} fme_tokenResult:${fme_tokenResult}"
        office365ConnectorSend color: '#00FF00', message: "FME Token Renewal Successful for token  name:${UpdatedToken['name']},type:${UpdatedToken['type']},user:${UpdatedToken['user']},expirationDate:${UpdatedToken['expirationDate']},description:${UpdatedToken['description']}", status: 'Success', webhookUrl: 'https://edisonintl.webhook.office.com/webhookb2/630eb4c3-e34b-45d7-a316-1948c49a2e3a@5b2a8fee-4c95-4bdc-8aae-196f8aacb1b6/JenkinsCI/344bf5a79c4a40aab31a313806126cbf/a3a8382e-c883-4ff6-8f7a-fe0862721a83'
        return UpdatedToken
    }
  }catch (Exception excep){
    echo "updateToken-Exceptions"
    throw (excep)
  }
  }

// Submit FME job Synchronously
def executeFME(String ENVIRONMENT,  String FME_REPOSITORY, String FME_WORKSPACE, String FME_PublishedParameters) throws Exception{
  echo "executeFME-Starting"
  def fmedetails =  getFMEEnvironmentDetails("${ENVIRONMENT}")
  def FME_TOKEN="${fmedetails['FMETOKEN']}"
  def FME_URL="${fmedetails['FMEURL']}" 
  echo "executeFME-Synchronous url- ${FME_URL}/fmerest/v3/transformations/transact/${FME_REPOSITORY}/${FME_WORKSPACE}"
  if(FME_PublishedParameters==""){
      FME_PublishedParameters="{}"
  }
  try {
    echo "Making synchronous call to fme"
    def jobSubmissionResult = httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]], outputFile: 'result', httpMode: 'POST',requestBody: "${FME_PublishedParameters}", url: "${FME_URL}/fmerest/v3/transformations/transact/${FME_REPOSITORY}/${FME_WORKSPACE}", wrapAsMultipart: false
    echo "executeFME-FME: jobSubmissionResult: ${jobSubmissionResult}"
    def jobResult= readJSON text: "${jobSubmissionResult.content}"    
    downloadFMELog("${ENVIRONMENT}","${jobResult['id']}","${FME_REPOSITORY}_${FME_WORKSPACE}")

    if("${jobResult['status']}"!=("SUCCESS")){
      throw (new Exception("executeFME-FME Job Failed. FME_JOB_ID :  ${jobResult['id']} , FME_JOB_LOG \n: ${jobLogOutput}"))
    }
    echo "executeFME-Completed"
    return jobResult
  }catch (Exception excep){
    echo "executeFME-Exceptions :: ${excep}"
    throw (excep)
  }
}

// Check Status of FME job 
def checkJobStatus(String ENVIRONMENT,String JOBID){
  echo "CheckJobStatus-Starting"
  def fmedetails =  getFMEEnvironmentDetails("${ENVIRONMENT}")
  def FME_TOKEN="${fmedetails['FMETOKEN']}"
  def FME_URL="${fmedetails['FMEURL']}"
  echo "CheckJobStatus- ${FME_URL}/fmerest/v3/transformations/jobs/id/${JOBID}"
  try{
  def jobStatus = httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]], outputFile: 'result', url: "${FME_URL}/fmerest/v3/transformations/jobs/id/${JOBID}", wrapAsMultipart: false

  def jobStatusObj = readJSON text: "${jobStatus.content}"
  echo "CheckJobStatus-Completed"
  echo "CheckJobStatus-  ${jobStatusObj['result']['status']}"
  return "${jobStatusObj['result']['status']}"
  }catch (Exception excep){
  echo "checkJobStatus-Exception"
  throw (excep)
  }
}

// Download FME job log
def downloadFMELog(String ENVIRONMENT,String JOBID, String NAME){
  echo "downloadFMELog-Starting"
  def fmedetails =  getFMEEnvironmentDetails("${ENVIRONMENT}")
  def FME_TOKEN="${fmedetails['FMETOKEN']}"
  def FME_URL="${fmedetails['FMEURL']}"

  echo "downloadFMELog- ${FME_URL}/fmerest/v3/transformations/jobs/id/${JOBID}/log?accept=contents"
  try{
  writeFile file: "${NAME}_${JOBID}_Logs.txt", text: httpRequest( acceptType: 'APPLICATION_JSON', consoleLogResponseBody: false, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]], outputFile: 'result', url: "${FME_URL}/fmerest/v3/transformations/jobs/id/${JOBID}/log?accept=contents", wrapAsMultipart: false).content
  echo "downloadFMELog-Completed"
  }catch (Exception excep){
  echo "downloadFMELog-Exception"
  throw (excep)
  }
}

// Check if FME job is in executing status.
def checkIfJobIsRunning( String ENVIRONEMNT, String FME_REPOSITORY, String FME_WORKSPACE){
  echo "checkIfJobIsRunning-Starting"
  def isExecuting=false
  def fmedetails =  getFMEEnvironmentDetails("${ENVIRONMENT}")
  def FME_TOKEN="${fmedetails['FMETOKEN']}"
  def FME_URL="${fmedetails['FMEURL']}" 
  echo "checkIfJobIsRunning- ${FME_URL}/fmerest/v3/transformations/jobs/queued?repository=${FME_REPOSITORY}&workspace=${FME_WORKSPACE}"
  try{
  def queuedStatus = httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]], outputFile: 'result', url: "${FME_URL}/fmerest/v3/transformations/jobs/queued?repository=${FME_REPOSITORY}&workspace=${FME_WORKSPACE}", wrapAsMultipart: false
  def runningStatus= httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]], outputFile: 'result', url: "${FME_URL}/fmerest/v3/transformations/jobs/running?repository=${FME_REPOSITORY}&workspace=${FME_WORKSPACE}", wrapAsMultipart: false

  def queuedResponse = readJSON text: "${queuedStatus.content}"
  def runningResponse = readJSON text: "${runningStatus.content}"
  def totalqueuedCount = "${queuedResponse['totalCount']}"
  def queuedWorkspaceList= "${queuedResponse['items']['workspace']}" 
  def totalrunningCount = "${runningResponse['totalCount']}"
  def runningWorkspaceList= "${runningResponse['items']['workspace']}"

  echo "checkIfJobIsRunning- ${queuedStatus}"
  echo "checkIfJobIsRunning- ${runningStatus}"
  echo "checkIfJobIsRunning- totalqueuedCount : ${totalqueuedCount}" 
  echo "checkIfJobIsRunning- queuedWorkspaceList : ${queuedWorkspaceList}"
  echo "checkIfJobIsRunning- totalrunningCount : ${totalrunningCount}"
  echo "checkIfJobIsRunning- runningWorkspaceList : ${runningWorkspaceList}"

  if( (totalqueuedCount != 0 && ("${env.FME_WORKSPACE}" in queuedWorkspaceList)) ||
   (totalrunningCount != 0 && ("${env.FME_WORKSPACE}" in runningWorkspaceList))
   ){
    isExecuting =true
  }
  echo "checkIfJobIsRunning-Execution Status : ${isExecuting}"
  echo "checkIfJobIsRunning-Completed"
  return isExecuting
  }catch (Exception excep){
  echo "checkIfJobIsRunning-Exception"
  throw (excep)
  }
}

// Retrieve Published Parameters for FME job
def retrieveFMEPublishedParameters(String ENVIRONMENT, String FME_REPOSITORY, String FME_WORKSPACE){
  echo "FMEUtills.retriveFMERepository:ENVIRONMENT:${ENVIRONMENT},FME_REPOSITORY:${FME_REPOSITORY}, FME_WORKSPACE:${FME_WORKSPACE}"
  def fmedetails =  getFMEEnvironmentDetails("${ENVIRONMENT}")
  def FME_TOKEN="${fmedetails['FMETOKEN']}"
  def FME_URL="${fmedetails['FMEURL']}" 
  def publishedParametersOutput ="none"
  
// https://aywcdgcm02.sce.eix.com/fmerest/v3/repositories/Samples/items/austinDownload.fmw/parameters
  def httpResponse =  httpRequest acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', customHeaders: [[maskValue: true, name: 'Authorization', value: "fmetoken token=${FME_TOKEN}"]], outputFile: 'result', httpMode: 'GET', url: "${FME_URL}/fmerest/v3/repositories/${FME_REPOSITORY}/items/${FME_WORKSPACE}/parameters", wrapAsMultipart: false
  def jsonResponse = readJSON text: "${httpResponse.content}"  
  echo "retriveFMEWorkspace:${jsonResponse}"  
  def workspaceList = [] as ArrayList
  for(item in jsonResponse){
    def entry=[
      name : item.name,
      value: item.defaultValue
    ]
    workspaceList.add(entry) 
  }
  if(!workspaceList.isEmpty()){
    def publishedParametersMap = [publishedParameters:workspaceList]
    def  publishedParametersJson= new groovy.json.JsonBuilder(publishedParametersMap)
    publishedParametersOutput = publishedParametersJson.toPrettyString()
    echo "publishParameterOutput is set to: ${publishedParametersOutput}"
  }
  return publishedParametersOutput
}

def getFMEJobDetails(String env,Map fme_props) {
    echo "in getFMEURL"
    def FME_URL_DETAIL
    def FME_TOKEN_DETAIL
    switch("${env}") {            
         case 'DEV': 
            FME_URL_DETAIL = "${fme_props['fme.server.url.dev']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.dev']}"
            break; 
         case 'ST': 
            FME_URL_DETAIL = "${fme_props['fme.server.url.st']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.st']}"
            break; 
        case 'PT': 
            FME_URL_DETAIL = "${fme_props['fme.server.url.pt']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.pt']}"
            break;        
        case 'REGR':
            FME_URL_DETAIL = "${fme_props['fme.server.url.reg']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.reg']}"
            break;     
        case 'BF':
            FME_URL_DETAIL = "${fme_props['fme.server.url.bf']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.bf']}"
            break;     
        case 'PROD':
            FME_URL_DETAIL = "${fme_props['fme.server.url.prod']}"
            FME_TOKEN_DETAIL = "${fme_props['fme.server.token.prod']}"
            break;     
      }
    def fme_details= ["FMETOKEN": "${FME_TOKEN_DETAIL}","FMEURL":"${FME_URL_DETAIL}"]
    echo "in fme_details : ${fme_details}"
    return  fme_details 
}

// possible used in download upload fme
def getNumberOfQueuedFMEJobs(String ENVIRONMENT, String FME_REPOSITORY, String FME_WORKSPACE, Map fme_props){ 
echo "Inside queued fme"
def fmeDetails= getFMEJobDetails("${ENVIRONMENT}",fme_props) 
echo "fme details contains:  ${fmeDetails}"
echo "fme Token is: ${fmeDetails['FMETOKEN']}" 
def FME_TOKEN="${fmeDetails['FMETOKEN']}"
echo "FME_TOKEN is 1: ${FME_TOKEN}" 
def FME_URL="${fmeDetails['FMEURL']}"               
echo "fme url is: ${fmeDetails['FMEURL']}"                
echo "FME_URL is 1: ${FME_URL}"   

def status= "${FME_URL}/fmerest/v3/transformations/jobs/queued?repository=${FME_REPOSITORY}&workspace=${FME_WORKSPACE}&fmetoken=${FME_TOKEN}"
def jobstatus=httpRequest consoleLogResponseBody: true,  url: "${status}", wrapAsMultipart: false   
def reponseContent ="${jobstatus.content}"
echo "Reponse Content in String is: ${reponseContent}"
def response= readJSON file: '', text: "${reponseContent}"
echo "Reponse Content in JSON is: ${response}"
echo "totalCount is :   ${response.totalCount}"
return "${response.totalCount}"
}

