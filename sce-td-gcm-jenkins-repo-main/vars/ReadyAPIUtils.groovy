def executeTestJob(String serviceName, String env,String jobName,boolean securityTest) {
    echo "executeReadyAPITest:executeTestJob:Executing Test for serviceName ${serviceName} and Environment ${env} and execute SercurityTest ${securityTest}"
    def jobResult=build propagate: false,job: "${jobName}", parameters: [string(name: 'GCM_ENV', value: "${env}"),string(name: 'Test_Suite', value: "Sanity"),booleanParam(name: 'Security_Test', value: "${securityTest}")]
    echo "executeReadyAPITest:executeTestJob: ${jobResult.currentResult} : ${jobResult.number} "
    copyArtifacts fingerprintArtifacts: true, projectName: "${jobName}", selector: specific("${jobResult.number}"), target: "./TestResults/${serviceName}"
    publishHTML(target:[allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "TestResults/${serviceName}/TestReports", reportFiles: 'index.html', reportName: "${serviceName}_ReadyAPI Test Report", reportTitles: "${serviceName}_ReadyAPI Test Report"]) 
    junit allowEmptyResults: true, keepLongStdio: true, skipMarkingBuildUnstable: true, skipPublishingChecks: true, testDataPublishers: [attachments()], testResults: "TestResults/${serviceName}/TestReports/*.xml"
    echo 'Test Completed'
}
def executeTestJobsAllTogether(String env, String branch, boolean securityTest) {
    
    def jobResult=build propagate: false,wait: false, job: "/GCM/Test/sce-td-gcm-substation-internal-multiEnv-test/${branch}", parameters: [string(name: 'GCM_ENV', value: "${env}"),string(name: 'Test_Suite', value: "Sanity"),booleanParam(name: 'Security_Test', value: "${securityTest}")]
    jobResult=build propagate: false,wait: false, job: "/GCM/Test/sce-td-gcm-substation-hierarchy-multiEnv-test/${branch}", parameters: [string(name: 'GCM_ENV', value: "${env}"),string(name: 'Test_Suite', value: "Sanity"),booleanParam(name: 'Security_Test', value: "${securityTest}")]
    jobResult=build propagate: false, wait: false, job: "/GCM/Test/sce-td-gcm-distribution-connectivity-multiEnv-test/${branch}", parameters: [string(name: 'GCM_ENV', value: "${env}"),string(name: 'Test_Suite', value: "Sanity"),booleanParam(name: 'Security_Test', value: "${securityTest}")]
    jobResult=build propagate: false, wait: false, job: "/GCM/Test/sce-td-gcm-M2G-multiEnv-test/${branch}", parameters: [string(name: 'GCM_ENV', value: "${env}"),string(name: 'Test_Suite', value: "Sanity"),booleanParam(name: 'Security_Test', value: "${securityTest}")]
    jobResult=build propagate: false, wait: false, job: "/GCM/Test/sce-td-gcm-Structure-to-Feeder-multiEnv-test/${branch}", parameters: [string(name: 'GCM_ENV', value: "${env}"),string(name: 'Test_Suite', value: "Sanity"),booleanParam(name: 'Security_Test', value: "${securityTest}")]
    jobResult=build propagate: false, wait: false, job: "/GCM/Test/sce-td-gcm-substation-internal-changelist-multiEnv-test/${branch}", parameters: [string(name: 'GCM_ENV', value: "${env}"),string(name: 'Test_Suite', value: "Sanity"),booleanParam(name: 'Security_Test', value: "${securityTest}")]
    echo 'Test Pipelines submitted'
}

def branch =''
def getbranch(String env){
    if(env.contains("PROD")){
        branch = "master"
    }else{
        branch ="Non-Prod"
    }
}
//serviceName Supported Values 'ALL','SI','SSPH','DC','M2G','SFI','SCL'
//env Supported Values 'DEV_NON_AGL','DEV_AGL','ST_NON_AGL','ST_AGL','PT','REGR','BF','PROD'
// Ex Usage:  executeReadyAPITest('SI','ST_NON_AGL')  

def executeReadyAPITest(String serviceName, String env, boolean executeSecurityTest) {
    getbranch(env)
    echo "executeReadyAPITest:Executing Test for serviceName ${serviceName} and Environment ${env} and Branch ${branch} and execute Security Test ${executeSecurityTest}"

    switch("${serviceName}") {  
        case 'SI': 
            executeTestJob("${serviceName}","${env}","/GCM/Test/sce-td-gcm-substation-internal-multiEnv-test/${branch}",executeSecurityTest )
            break; 
        case 'SSPH': 
            executeTestJob("${serviceName}","${env}","/GCM/Test/sce-td-gcm-substation-hierarchy-multiEnv-test/${branch}" ,executeSecurityTest)
            break; 
        case 'DC': 
            executeTestJob("${serviceName}","${env}","/GCM/Test/sce-td-gcm-distribution-connectivity-multiEnv-test/${branch}" ,executeSecurityTest)
            break; 
        case 'M2G': 
            executeTestJob("${serviceName}","${env}","/GCM/Test/sce-td-gcm-M2G-multiEnv-test/${branch}" ,executeSecurityTest)
            break;
        case 'SFI': 
            executeTestJob("${serviceName}","${env}","/GCM/Test/sce-td-gcm-Structure-to-Feeder-multiEnv-test/${branch}",executeSecurityTest )
            break; 
        case 'SCL': 
            executeTestJob("${serviceName}","${env}","/GCM/Test/sce-td-gcm-substation-internal-changelist-multiEnv-test/${branch}",executeSecurityTest )
            break;            
        case 'ALL':
            executeTestJob("SI","${env}","/GCM/Test/sce-td-gcm-substation-internal-multiEnv-test/${branch}" ,executeSecurityTest)
            executeTestJob("SSPH","${env}","/GCM/Test/sce-td-gcm-substation-hierarchy-multiEnv-test/${branch}" ,executeSecurityTest)
            executeTestJob("DC","${env}","/GCM/Test/sce-td-gcm-distribution-connectivity-multiEnv-test/${branch}" ,executeSecurityTest)
            executeTestJob("M2G","${env}","/GCM/Test/sce-td-gcm-M2G-multiEnv-test/${branch}" ,executeSecurityTest)
            executeTestJob("SFI","${env}","/GCM/Test/sce-td-gcm-Structure-to-Feeder-multiEnv-test/${branch}" ,executeSecurityTest)
            executeTestJob("SCL","${env}","/GCM/Test/sce-td-gcm-substation-internal-changelist-multiEnv-test/${branch}" ,executeSecurityTest)
            break;
        case 'ALL-Together':    
            executeTestJobsAllTogether("${env}", "${branch}", executeSecurityTest) 
            break;
      }
      archiveArtifacts artifacts: "TestResults/**/*.*", followSymlinks: false
}