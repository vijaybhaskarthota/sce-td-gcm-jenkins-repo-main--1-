#dir env:
Write-Host "deployProducts:dp_server:"$env:dp_server",dp_catalog:"$env:dp_catalog",dp_org:"$env:dp_org",dp_space:"$env:dp_space",dp_user:"$env:dp_user",dp_pass:*******,dp_credjson:"$env:dp_credjson",Action:"$env:ACTION",Num of Commit:"$env:NUM_OF_COMMIT",INPUT Branch:"$ENV:GIT_BRANCH",Git Commit:" $ENV:GIT_COMMIT",BUILD_URL:$ENV:BUILD_URL,dp_plan_mapping_file:$ENV:dp_plan_mapping_file"
#Setting Configurations for GCM API's
$API_ONLINE_FILE = "API_ONLINE_FILE.txt"
New-Item $API_ONLINE_FILE -ItemType File -Value "state: online" -ErrorAction Ignore
$API_OFFLINE_FILE = "API_OFFLINE_FILE.txt"
New-Item $API_OFFLINE_FILE -ItemType File -Value "state: offline" -ErrorAction Ignore
$API_LIST=@(
    "circuitlist:1.0.0"
    "distributioncircuitconnectivity:1.0.0"
    "metertogridhierarchy:1.0.0"
    "structurefeederinfo:1.0.0"
    "substationchangelist:1.0.0"
    "substationhierarchy:1.0.0"
    "substationinternalconnectivity:1.0.0"
)
$API_LIST_MNT=@(
    "circuitlistmnt:1.0.0"
    "distributioncircuitconnectivitymnt:1.0.0"
    "metertogridhierarchymnt:1.0.0"
    "structurefeederinfomnt:1.0.0"
    "substationchangelistmnt:1.0.0"
    "substationhierarchymnt:1.0.0"
    "substationinternalconnectivitymnt:1.0.0"
)
$API_LIST_STC=@(
    "circuitliststc:1.0.0"
    "distributioncircuitconnectivitymnt:1.0.0"
    "metertogridhierarchymnt:1.0.0"
    "structurefeederinfomnt:1.0.0"
    "substationchangelistmnt:1.0.0"
    "substationhierarchymnt:1.0.0"
    "substationinternalconnectivitymnt:1.0.0"
)
function DP_Login{ 
    Write-Host "deployProducts:DP_Login:Accepting License"
    echo N|E:\\BuildServer\\APIC\\apic --accept-license|Out-Null
    #Logging APIC version
    E:\\BuildServer\\APIC\\apic version
    Write-Host "deployProducts:DP_Login:Setting Toolkit Credentials"
    E:\\BuildServer\\APIC\\apic client-creds:set $env:dp_credjson
    Write-Host "deployProducts:DP_Login:Logging in to DP Server"
    E:\\BuildServer\\APIC\\apic login  --server $env:dp_server --username $env:dp_user --password $env:dp_pass --realm provider/sce
}
function DP_Logout{ 
    Write-Host "deployProducts:DP_Logout:Logging off from the server"
    E:\\BuildServer\\APIC\\apic logout --server $env:dp_server
}
function DP_InstallGCMProducts{ 
    DP_Login
    #Write-Host "deployProducts:DP_InstallGCMProducts:Logging the list of all Products"
    #E:\\BuildServer\\APIC\\apic products:list-all --server $env:dp_server --org $env:dp_org --scope space --space $env:dp_space --catalog $env:dp_catalog
    $DeploymentReference="#dp_server:$env:dp_server,dp_catalog:$env:dp_catalog,dp_org:$env:dp_org,dp_space:$env:dp_space,dp_user:$env:dp_user,dp_pass:*******,dp_credjson:$env:dp_credjson,Action:$env:ACTION,Num of Commit:$env:NUM_OF_COMMIT,INPUT Branch:$ENV:GIT_BRANCH,Git Commit: $ENV:GIT_COMMIT,BUILD_URL:$ENV:BUILD_URL"
    @("#Deployment Reference Start",$DeploymentReference,"#Deployment Reference End") +  (Get-Content assets-and-connectivity_1.0.0.yaml) | Set-Content assets-and-connectivity_1.0.0.yaml
    @("#Deployment Reference Start",$DeploymentReference,"#Deployment Reference End") +  (Get-Content assets-and-connectivity-mnt_1.0.0.yaml) | Set-Content assets-and-connectivity-mnt_1.0.0.yaml
    @("#Deployment Reference Start",$DeploymentReference,"#Deployment Reference End") +  (Get-Content assets-and-connectivity-stc_1.0.0.yaml) | Set-Content assets-and-connectivity-stc_1.0.0.yaml
    Write-Host "deployProducts:DP_InstallGCMProducts:Validating the Product assets-and-connectivity_1.0.0.yaml"
    E:\\BuildServer\\APIC\\apic validate assets-and-connectivity_1.0.0.yaml
    Write-Host "deployProducts:DP_InstallGCMProducts:Validating the Product assets-and-connectivity-mnt_1.0.0.yaml"
    E:\\BuildServer\\APIC\\apic validate assets-and-connectivity-mnt_1.0.0.yaml
    Write-Host "deployProducts:DP_InstallGCMProducts:Validating the Product assets-and-connectivity-stc_1.0.0.yaml"
    E:\\BuildServer\\APIC\\apic validate assets-and-connectivity-stc_1.0.0.yaml

    if ($env:dp_org -eq "stc") {
        Write-Host "deployProducts:DP_InstallGCMProducts:Deploying the Product assets-and-connectivity-stc_1.0.0.yaml"
        E:\\BuildServer\\APIC\\apic products publish assets-and-connectivity-stc_1.0.0.yaml --migrate_subscriptions --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space
        #E:\\BuildServer\\APIC\\apic products publish assets-and-connectivity-stc_1.0.0.yaml --migrate_subscriptions --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space --debug
    }
    else{
    Write-Host "deployProducts:DP_InstallGCMProducts:Deploying the Product assets-and-connectivity_1.0.0.yaml"
    E:\\BuildServer\\APIC\\apic products publish assets-and-connectivity_1.0.0.yaml --migrate_subscriptions --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space
    #E:\\BuildServer\\APIC\\apic products publish assets-and-connectivity_1.0.0.yaml --migrate_subscriptions --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space --debug
    }

    Write-Host "deployProducts:DP_InstallGCMProducts:Deploying the Product assets-and-connectivity-mnt_1.0.0.yaml"
    E:\\BuildServer\\APIC\\apic products publish assets-and-connectivity-mnt_1.0.0.yaml --migrate_subscriptions --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space
    #E:\\BuildServer\\APIC\\apic products publish assets-and-connectivity-mnt_1.0.0.yaml --migrate_subscriptions --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space --debug
    #Write-Host "deployProducts:DP_InstallGCMProducts:Logging the list of all Products after deployment"
    #E:\\BuildServer\\APIC\\apic products:list-all --server $env:dp_server --org $env:dp_org --scope space --space $env:dp_space --catalog $env:dp_catalog
    
    DP_Logout 
}
function DP_RollbackGCMProducts{ 
    Write-Host "deployProducts:DP_RollbackGCMProducts:"
    git checkout HEAD~$ENV:NUM_OF_COMMIT
    DP_Login
    $DeploymentReference="#dp_server:$env:dp_server,dp_catalog:$env:dp_catalog,dp_org:$env:dp_org,dp_space:$env:dp_space,dp_user:$env:dp_user,dp_pass:*******,dp_credjson:$env:dp_credjson,Action:$env:ACTION,Num of Commit:$env:NUM_OF_COMMIT,INPUT Branch:$ENV:GIT_BRANCH,Git Commit: $ENV:GIT_COMMIT,BUILD_URL:$ENV:BUILD_URL"
    @("#Deployment Reference Start",$DeploymentReference,"#Deployment Reference End") +  (Get-Content assets-and-connectivity_1.0.0.yaml) | Set-Content assets-and-connectivity_1.0.0.yaml
    @("#Deployment Reference Start",$DeploymentReference,"#Deployment Reference End") +  (Get-Content assets-and-connectivity-mnt_1.0.0.yaml) | Set-Content assets-and-connectivity-mnt_1.0.0.yaml
    @("#Deployment Reference Start",$DeploymentReference,"#Deployment Reference End") +  (Get-Content assets-and-connectivity-stc_1.0.0.yaml) | Set-Content assets-and-connectivity-stc_1.0.0.yaml
    Write-Host "deployProducts:DP_RollbackGCMProducts:Validating the Product assets-and-connectivity_1.0.0.yaml"
    E:\\BuildServer\\APIC\\apic validate assets-and-connectivity_1.0.0.yaml
    Write-Host "deployProducts:DP_RollbackGCMProducts:Validating the Product assets-and-connectivity-mnt_1.0.0.yaml"
    E:\\BuildServer\\APIC\\apic validate assets-and-connectivity-mnt_1.0.0.yaml
    Write-Host "deployProducts:DP_RollbackGCMProducts:Validating the Product assets-and-connectivity-stc_1.0.0.yaml"
    E:\\BuildServer\\APIC\\apic validate assets-and-connectivity-stc_1.0.0.yaml
    if ($env:dp_org -eq "stc") {
        Write-Host "deployProducts:DP_RollbackGCMProducts:Deploying the Product assets-and-connectivity-stc_1.0.0.yaml"
        E:\\BuildServer\\APIC\\apic products publish assets-and-connectivity-stc_1.0.0.yaml --migrate_subscriptions --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space
    }else{
        Write-Host "deployProducts:DP_RollbackGCMProducts:Deploying the Product assets-and-connectivity_1.0.0.yaml"
        E:\\BuildServer\\APIC\\apic products publish assets-and-connectivity_1.0.0.yaml --migrate_subscriptions --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space
    }
    Write-Host "deployProducts:DP_RollbackGCMProducts:Deploying the Product assets-and-connectivity-mnt_1.0.0.yaml"
    E:\\BuildServer\\APIC\\apic products publish assets-and-connectivity-mnt_1.0.0.yaml --migrate_subscriptions --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space
    DP_Logout
}
function DP_GetCurrentDeployedVersion{
    Write-Host "deployProducts:DP_GetCurrentDeployedVersion:"
    DP_Login
    E:\\BuildServer\\APIC\\apic products:get assets-and-connectivity:1.0.0 --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space
    E:\\BuildServer\\APIC\\apic products:get assets-and-connectivity-mnt:1.0.0 --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space
    E:\\BuildServer\\APIC\\apic products:get assets-and-connectivity-stc:1.0.0 --server $env:dp_server --org $env:dp_org --scope space --catalog $env:dp_catalog --space $env:dp_space
    DP_Logout
}
function DP_EnableGCMOutage{ 
    Write-Host "deployProducts:DP_EnableGCMOutage:"
    DP_Login
    
    if ($env:dp_org -eq "stc") {
        #Disbaling all the STC main URL's
        Write-Host "deployProducts:DP_EnableGCMOutage:Disabling the STC Main Service URL's"
        foreach ($API in $API_LIST_STC) {
            E:\\BuildServer\\APIC\\apic apis:update $API --server $env:dp_server --org $env:dp_org --space $env:dp_space --catalog $env:dp_catalog --scope space $API_OFFLINE_FILE|write-host
        }
    }
    else{
        #Disbaling all the STC main URL's
        Write-Host "deployProducts:DP_EnableGCMOutage:Disabling the Main Service URL's"
        foreach ($API in $API_LIST) {
            E:\\BuildServer\\APIC\\apic apis:update $API --server $env:dp_server --org $env:dp_org --space $env:dp_space --catalog $env:dp_catalog --scope space $API_OFFLINE_FILE|write-host
        }
    }    
    #Enabling all the MNT URL's
    Write-Host "deployProducts:DP_EnableGCMOutage:Enabling the Maintenance Service URL's"
    foreach ($API_MNT in $API_LIST_MNT) {
        E:\\BuildServer\\APIC\\apic apis:update $API_MNT --server $env:dp_server --org $env:dp_org --space $env:dp_space --catalog $env:dp_catalog --scope space $API_ONLINE_FILE|write-host
    }
    DP_Logout
}
function DP_RemoveGCMOutage{ 
    Write-Host "deployProducts:DP_RemoveGCMOutage:"
    DP_Login
    if ($env:dp_org -eq "stc") {
        #Disbaling all the STC main URL's
        Write-Host "deployProducts:DP_RemoveGCMOutage:Enabling the STC Main Service URL's"
        foreach ($API in $API_LIST_STC) {
            E:\\BuildServer\\APIC\\apic apis:update $API --server $env:dp_server --org $env:dp_org --space $env:dp_space --catalog $env:dp_catalog --scope space $API_ONLINE_FILE|write-host
        }
    }
    else{
        #Disbaling all the main URL's
        Write-Host "deployProducts:DP_RemoveGCMOutage:Enabling the Main Service URL's"
        foreach ($API in $API_LIST) {
            E:\\BuildServer\\APIC\\apic apis:update $API --server $env:dp_server --org $env:dp_org --space $env:dp_space --catalog $env:dp_catalog --scope space $API_ONLINE_FILE|write-host
        }
    }
    #Enabling all the MNT URL's
    Write-Host "deployProducts:DP_RemoveGCMOutage:Disabling the Maintenance Service URL's"
    foreach ($API_MNT in $API_LIST_MNT) {
        E:\\BuildServer\\APIC\\apic apis:update $API_MNT --server $env:dp_server --org $env:dp_org --space $env:dp_space --catalog $env:dp_catalog --scope space $API_OFFLINE_FILE|write-host
    }
    DP_Logout
}
switch($env:ACTION){
    "INSTALL" {
        Write-Host "deployProducts:INSTALL"
        DP_InstallGCMProducts
        break
    }
    "ROLLBACK" {
        Write-Host "deployProducts:ROLLBACK"
        DP_RollbackGCMProducts
        break
    }
    "ENABLE_GCM_OUTAGE" {
        Write-Host "deployProducts:ENABLE_GCM_OUTAGE"
        DP_EnableGCMOutage
        break 
    }
    "REMOVE_GCM_OUTAGE" {
        Write-Host "deployProducts:REMOVE_GCM_OUTAGE"
        DP_RemoveGCMOutage
        break
    }
    "GET_CURRENT_DEPLOYED_VERSION"{
        Write-Host "deployProducts:GET_CURRENT_DEPLOYED_VERSION"
        DP_GetCurrentDeployedVersion
        break
    }
 }