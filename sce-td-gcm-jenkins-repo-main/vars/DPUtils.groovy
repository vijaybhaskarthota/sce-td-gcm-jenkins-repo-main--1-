def dp_props
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
        echo "getFilePath:Full fileName with path:${env.WORKSPACE}@script\\${files[0].path}"
        return "${env.WORKSPACE}@script\\${files[0].path}"        
    }
}
def codeQLScanDP(){
      withCodeQL(codeql: 'CodeQL') {
            def serviceName= ("${GIT_URL}".tokenize('/.')[-2])
            //def command = "\"mvn clean compile -DskipTests\""
            def repository = ("${GIT_URL}".tokenize('/.')[-3]) + "/" +("${GIT_URL}".tokenize('/.')[-2])
            def jvm_options = "\"-Djavax.net.ssl.trustStore=E:\\BuildServer\\jenkins_truststore\\cacerts\""
            echo "codeQLScan: service name : - ${serviceName}, repository: ${repository}"

            echo "codeQLScan: database creation- starting"
            bat "codeql database create  codeql-dbs${serviceName} --overwrite --language=javascript"
            echo "codeQLScan: database creation- Completed"

            echo "codeQLScan: database analysis- starting"
            bat "codeql database analyze codeql-dbs${serviceName} --sarif-category=javascript --format=sarif-latest --output=codeql-dbs${serviceName}-javascript.sarif --sarif-add-baseline-file-info --verbosity=errors"
            echo "codeQLScan: database analysis- Completed"

            withCredentials([usernamePassword(credentialsId: 'git-svc-acct', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'git_user')]) {
                  bat 'set'
                  echo "codeQLScan: gitHub upload result- starting"
                  bat "codeql github upload-results --repository=${repository} --ref=refs/heads/${GIT_BRANCH} --commit=${GIT_COMMIT} --sarif=codeql-dbs${serviceName}-javascript.sarif -J=${jvm_options} --verbosity=errors"                  
                  echo "codeQLScan: gitHub upload result- completed"
            }
      }

}
def deploy() {
    // echo "dp_plan_mapping:${env.dp_plan_mapping}"       
    // if("${env.dp_plan_mapping}" == "NONE"){
    //     echo "No Plan mapping file available"
    // }
    // else{
    //     env.dp_plan_mapping_file = "${getFilePath(env.dp_plan_mapping)}"
    //     echo "${env.dp_plan_mapping} : ${env.dp_plan_mapping_file}"       
    // }
    powershell label: 'Executing install/Rollback Products/APIs', script: "${getFilePath("deployProducts.ps1")}"
}
def enable_gcm_outage() {
    powershell label: 'Enable GCM Outage', script: "${getFilePath("deployProducts.ps1")}"
}
def remove_gcm_outage() {
    powershell label: 'Remove GCM Outage', script: "${getFilePath("deployProducts.ps1")}"
}