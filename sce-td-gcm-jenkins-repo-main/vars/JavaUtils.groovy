def call()
{

}

def codeQLScan(){
      withCodeQL(codeql: 'CodeQL') {
            def serviceName= readMavenPom().getArtifactId()
            def command = "\"mvn clean compile -DskipTests\""
            def repository = ("${GIT_URL}".tokenize('/.')[-3]) + "/" +("${GIT_URL}".tokenize('/.')[-2])
            def jvm_options = "\"-Djavax.net.ssl.trustStore=E:\\BuildServer\\jenkins_truststore\\cacerts\""
            echo "codeQLScan: service name : - ${serviceName}, build command :  ${command}, repository: ${repository}"

            echo "codeQLScan: database creation- starting"
            bat "codeql database create  codeql-dbs${serviceName} --overwrite --language=java --command=${command}"
            echo "codeQLScan: database creation- Completed"

            echo "codeQLScan: database analysis- starting"
            bat "codeql database analyze codeql-dbs${serviceName} --sarif-category=java --format=sarif-latest --output=codeql-dbs${serviceName}-java.sarif --sarif-add-baseline-file-info --verbosity=errors"
            echo "codeQLScan: database analysis- Completed"

            withCredentials([usernamePassword(credentialsId: 'git-svc-acct', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'git_user')]) {
                  bat 'set'
                  echo "codeQLScan: gitHub upload result- starting"
                  bat "codeql github upload-results --repository=${repository} --ref=refs/heads/${GIT_BRANCH} --commit=${GIT_COMMIT} --sarif=codeql-dbs${serviceName}-java.sarif -J=${jvm_options} --verbosity=errors"
                  echo "codeQLScan: gitHub upload result- completed"
            }
      }

}

def executeJavaBuild() {
      bat 'set'
            withSonarQubeEnv(installationName: 'EnterpriseDevops-SonarQubeServer', credentialsId: 'EnterpriseDevops-SonarToken') {
                  withMaven(jdk: 'jdk11', maven: 'Maven', mavenSettingsConfig: '0c532131-ab08-411a-bba0-690f45d054e1', mavenSettingsFilePath: 'settings.xml', options: [jacocoPublisher(disabled: true),junitPublisher(healthScaleFactor: 1.0)]) {
                        echo 'codeQLScan: Starting'
                        codeQLScan()
                        echo 'codeQLScan: completed'
                        
                    echo 'Step ::: Octane SonarQube Report listener'
                    addALMOctaneSonarQubeListener pushCoverage: true, pushVulnerabilities:true, sonarToken:"${env.SONAR_AUTH_TOKEN}", sonarServerUrl:"${env.SONAR_HOST_URL}" 

                    echo 'Step :::Clean,Deploy,Dependency-check,Sonar commands - Starting'
                    bat "mvn clean deploy dependency-check:check sonar:sonar -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_AUTH_TOKEN} -Dsonar.analysis.buildNumber=${BUILD_NUMBER} -Dsonar.analysis.jobName=${JOB_NAME}  --s settings.xml"
                    echo 'Step :::Clean,Deploy,Dependency-check,Sonar commands - Completed'

                    collectBranchesToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', filter: '', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', workspaceId: '2001'
                    
                    echo 'Step ::: Executing Code Coverage Analysis - Starting'
                    props = readMavenPom().getProperties()
                    exclusionPattern = props.entrySet().findAll{entry -> entry.key.startsWith('jacoco-exclusion')}.collect{it.value}.join(',')
                    echo "exclusionPattern = ${exclusionPattern}"
                    jacoco( execPattern: '**/target/jacoco.exec', exclusionPattern: exclusionPattern)
                    publishCodeCoverage jacocoPathPattern: '**/target/site/*/jacoco.xml', lcovPathPattern: '**/coverage/lcov.info'
                    publishCoverage adapters: [jacocoAdapter(mergeToOneReport: true, path: '**/target/site/*/jacoco.xml')], sourceFileResolver: sourceFiles('NEVER_STORE')
                    echo 'Step ::: Executing Code Coverage Analysis - Completed'
                    
                    echo 'Step ::: Octane command to Collect Pull Requests - Starting'
                    collectPullRequestsToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', sourceBranchFilter: '', targetBranchFilter: '', workspaceId: '2001'
                    echo 'Step ::: Octane command to Collect Pull Requests - Completed'

                    echo 'Step ::: Publishng Dependecy Check Analysis Results'
                    dependencyCheckPublisher pattern: ''
                  }
            }
}

def executeJavaReleaseBuild(){
      bat 'set'
      withCredentials([usernamePassword(credentialsId: 'git-svc-acct', passwordVariable: 'gitPassword', usernameVariable: 'gitUsername')]){
      withSonarQubeEnv(installationName: 'EnterpriseDevops-SonarQubeServer', credentialsId: 'EnterpriseDevops-SonarToken') {
      withMaven(jdk: 'jdk11', maven: 'Maven', mavenSettingsConfig: '0c532131-ab08-411a-bba0-690f45d054e1', mavenSettingsFilePath: 'settings.xml', options: [jacocoPublisher(disabled: true),junitPublisher(healthScaleFactor: 1.0)]) {
            echo 'codeQLScan: Starting'
            codeQLScan()
            echo 'codeQLScan: completed'            
            
            echo 'Step ::: Octane SonarQube Coverage check'
            addALMOctaneSonarQubeListener pushCoverage: true, pushVulnerabilities:true, sonarToken:"${env.SONAR_AUTH_TOKEN}", sonarServerUrl:"${env.SONAR_HOST_URL}"
            
            echo 'Step ::: Executing Release clean'
			bat "mvn release:clean"
			echo 'Step ::: End of step Release clean' 

            echo 'Step ::: Executing Prepare,Sonar commands'
            bat "mvn -Dusername=${gitUserName} -Dpassword=${gitPassword} --s settings.xml -Darguments=\"-DreleaseVersion=${releaseVersion} -DdevelopmentVersion=${developerVersion}\" release:prepare -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_AUTH_TOKEN} -Dsonar.analysis.buildNumber=${BUILD_NUMBER} -Dsonar.analysis.jobName=${JOB_NAME} sonar:sonar"
            echo 'Step ::: End of step Prepare,Sonar commands-Completed'
            
            echo 'Step ::: Executing perform, skipping test execution and dependency check'
            bat "mvn -Dusername=${gitUserName} -Dpassword=${gitPassword} --s settings.xml -Darguments=\"-Dmaven.test.skip=true -Ddependency-check.skip=true\" release:perform"
            echo 'Step ::: End of step Perform commands-Completed'
            
            collectBranchesToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', filter: '', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', workspaceId: '2001'

            echo 'Step ::: Executing Code Coverage Analysis - Starting'
            props = readMavenPom().getProperties()
            exclusionPattern = props.entrySet().findAll{entry -> entry.key.startsWith('jacoco-exclusion')}.collect{it.value}.join(',')
            echo "exclusionPattern = ${exclusionPattern}"
            jacoco( execPattern: '**/target/jacoco.exec', exclusionPattern: exclusionPattern)
            publishCodeCoverage jacocoPathPattern: '**/target/site/*/jacoco.xml', lcovPathPattern: '**/coverage/lcov.info'
            publishCoverage adapters: [jacocoAdapter(mergeToOneReport: true, path: '**/target/site/*/jacoco.xml')], sourceFileResolver: sourceFiles('NEVER_STORE')
            echo 'Step ::: Executing Code Coverage Analysis - Completed'

            echo 'Step ::: Octane command to Collect All Pull Requests - Starting'
            collectPullRequestsToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', sourceBranchFilter: '', targetBranchFilter: '', workspaceId: '2001'
            echo 'Step ::: Octane command to Collect All Pull Requests - Completed'

            echo 'Step ::: Publishng Dependecy Check Analysis Results'
            dependencyCheckPublisher pattern: 'dependency-check-report.xml'
}  }  }  }


def executeJavaBuildConfigServer(){
      bat 'set'
      withChecks(name: 'JenkinsBuild', includeStage: true){
      withCredentials([string(credentialsId: "configserver-password", variable: 'spring.cloud.config.password'),
                        string(credentialsId: "nvd-api-key", variable: 'nvdApiKey')]) {
      withSonarQubeEnv(installationName: 'EnterpriseDevops-SonarQubeServer', credentialsId: 'EnterpriseDevops-SonarToken') {
      withMaven(jdk: 'jdk17', maven: 'Maven', mavenSettingsConfig: '0c532131-ab08-411a-bba0-690f45d054e1', mavenSettingsFilePath: 'settings.xml', options: [jacocoPublisher(disabled: true),junitPublisher(healthScaleFactor: 1.0)]) {
            echo 'codeQLScan: Starting'
            codeQLScan()
            echo 'codeQLScan: completed'
            
            echo 'Step ::: Octane SonarQube Report listener'
            addALMOctaneSonarQubeListener pushCoverage: true, pushVulnerabilities:true, sonarToken:"${env.SONAR_AUTH_TOKEN}", sonarServerUrl:"${env.SONAR_HOST_URL}" 

            def sarifReportPaths="codeql-dbs${readMavenPom().getArtifactId()}-java.sarif"
            echo "sarifReportPaths = ${sarifReportPaths}"

            echo 'Step :::Clean,Deploy,Dependency-check,Sonar commands - Starting'
            bat "mvn clean deploy dependency-check:check -DnvdApiKey=${nvdApiKey} javadoc:javadoc sonar:sonar -Dspring.cloud.bootstrap.enabled=true -Dspring.profiles.active=${env.spring_profiles_active} -Dspring.cloud.config.username=${env.config_server_uname} -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_AUTH_TOKEN} -Dsonar.analysis.buildNumber=${BUILD_NUMBER} -Dsonar.analysis.jobName=${JOB_NAME} -Dsonar.sarifReportPaths=${sarifReportPaths} -s settings.xml"
            echo 'Step :::Clean,Deploy,Dependency-check,Sonar commands - Completed'

            collectBranchesToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', filter: '', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', workspaceId: '2001'
            
            echo 'Step ::: Executing Code Coverage Analysis - Starting'
            props = readMavenPom().getProperties()
            exclusionPattern = props.entrySet().findAll{entry -> entry.key.startsWith('jacoco-exclusion')}.collect{it.value}.join(',')
            echo "exclusionPattern = ${exclusionPattern}"
            jacoco( execPattern: '**/target/jacoco.exec', exclusionPattern: exclusionPattern)
            //publishCodeCoverage jacocoPathPattern: '**/target/site/*/jacoco.xml', lcovPathPattern: '**/coverage/lcov.info'
            //publishCoverage adapters: [jacocoAdapter(mergeToOneReport: true, path: '**/target/site/*/jacoco.xml')], sourceFileResolver: sourceFiles('NEVER_STORE')
            recordCoverage(tools: [[pattern: '**/target/site/*/jacoco.xml']])
            echo 'Step ::: Executing Code Coverage Analysis - Completed'
            
            echo 'Step ::: Octane command to Collect Pull Requests - Starting'
            collectPullRequestsToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', sourceBranchFilter: '', targetBranchFilter: '', workspaceId: '2001'
            echo 'Step ::: Octane command to Collect Pull Requests - Completed'

            echo 'Step ::: Publishng Dependecy Check Analysis Results'
            dependencyCheckPublisher pattern: ''
	}
	}
	}   
}
}

def executeJavaReleaseBuildConfigServer(){
      bat 'set'
      withCredentials([usernamePassword(credentialsId: 'git-svc-acct', passwordVariable: 'gitPassword', usernameVariable: 'gitUsername'),string(credentialsId: "configserver-password", variable: 'spring.cloud.config.password')]){
      withSonarQubeEnv(installationName: 'EnterpriseDevops-SonarQubeServer', credentialsId: 'EnterpriseDevops-SonarToken') {
      withMaven(jdk: 'jdk17', maven: 'Maven', mavenSettingsConfig: '0c532131-ab08-411a-bba0-690f45d054e1', mavenSettingsFilePath: 'settings.xml', options: [jacocoPublisher(disabled: true),junitPublisher(healthScaleFactor: 1.0)]) {
           	echo 'codeQL scan started'
            codeQLScan()
            echo 'codeQL scan completed'
			
            echo 'Step ::: Octane SonarQube Coverage check'
            addALMOctaneSonarQubeListener pushCoverage: true, pushVulnerabilities:true, sonarToken:"${env.SONAR_AUTH_TOKEN}", sonarServerUrl:"${env.SONAR_HOST_URL}" 
			
            echo 'Step ::: Executing Release clean'
            bat "mvn release:clean"
            echo 'Step ::: End of step Release clean'
			
		echo 'Step ::: Executing Release prepare,Sonar commands'
            bat "mvn -Dusername=${gitUserName} -Dpassword=${gitPassword} --s settings.xml -Darguments=\"-Dspring.cloud.bootstrap.enabled=true -Dspring.cloud.config.username=${env.config_server_uname} -Dspring.profiles.active=${env.spring_profiles_active} -DreleaseVersion=${releaseVersion} -DdevelopmentVersion=${developerVersion}\" release:prepare -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_AUTH_TOKEN} -Dsonar.analysis.buildNumber=${BUILD_NUMBER} -Dsonar.analysis.jobName=${JOB_NAME} sonar:sonar"
            echo 'Step ::: End of step Prepare,Sonar commands-Completed'
            
            echo 'Step ::: Executing perform, skipping test execution and dependency check'
            bat "mvn -Dusername=${gitUserName} -Dpassword=${gitPassword} --s settings.xml -Darguments=\"-Ddependency-check.skip=true -Dmaven.test.skip=true\" release:perform"
            echo 'Step ::: End of step Perform commands-Completed'

            collectBranchesToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', filter: '', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', workspaceId: '2001'

            echo 'Step ::: Executing Code Coverage Analysis - Starting'
            props = readMavenPom().getProperties()
            exclusionPattern = props.entrySet().findAll{entry -> entry.key.startsWith('jacoco-exclusion')}.collect{it.value}.join(',')
            echo "exclusionPattern = ${exclusionPattern}"
            jacoco( execPattern: '**/target/jacoco.exec', exclusionPattern: exclusionPattern)
            // publishCodeCoverage jacocoPathPattern: '**/target/site/*/jacoco.xml', lcovPathPattern: '**/coverage/lcov.info'
            // publishCoverage adapters: [jacocoAdapter(mergeToOneReport: true, path: '**/target/site/*/jacoco.xml')], sourceFileResolver: sourceFiles('NEVER_STORE')
            recordCoverage(tools: [[pattern: '**/target/site/*/jacoco.xml']])
            echo 'Step ::: Executing Code Coverage Analysis - Completed'

            echo 'Step ::: Octane command to Collect All Pull Requests - Starting'
            collectPullRequestsToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', sourceBranchFilter: '', targetBranchFilter: '', workspaceId: '2001'
            echo 'Step ::: Octane command to Collect All Pull Requests - Completed'

            echo 'Step ::: Publishng Dependecy Check Analysis Results'
            dependencyCheckPublisher pattern: ''
      }
      }
      }
}


def executeJavaBuildForConfigServer(){
      bat 'set'
      withCredentials([string(credentialsId: 'Vault-Password', variable: 'passwordvault.client.pass.value'),usernamePassword(credentialsId: 'git-svc-acct', passwordVariable: 'spring.cloud.config.server.git.password', usernameVariable: 'spring.cloud.config.server.git.username')]) {
            withSonarQubeEnv(installationName: 'EnterpriseDevops-SonarQubeServer', credentialsId: 'EnterpriseDevops-SonarToken') {
                  withMaven(jdk: 'jdk11', maven: 'Maven', mavenSettingsConfig: '0c532131-ab08-411a-bba0-690f45d054e1', mavenSettingsFilePath: 'settings.xml', options: [jacocoPublisher(disabled: true),junitPublisher(healthScaleFactor: 1.0)]) {
                        
                        echo 'codeQLScan: Starting'
                        codeQLScan()
                        echo 'codeQLScan: completed'                        
                        
                        echo 'Step ::: Octane SonarQube Report listener'
                        addALMOctaneSonarQubeListener pushCoverage: true, pushVulnerabilities:true, sonarToken:"${env.SONAR_AUTH_TOKEN}", sonarServerUrl:"${env.SONAR_HOST_URL}" 

                        echo 'Step :::Clean,Deploy,Dependency-check,Sonar commands - Starting'
                        bat "mvn clean deploy dependency-check:check sonar:sonar -Dpasswordvault.client.id.value=${env.vault_id} -Dpasswordvault.client.url=${env.vault_url} -Dspring.cloud.config.server.git.uri=${env.GIT_URL} -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_AUTH_TOKEN} -Dsonar.analysis.buildNumber=${BUILD_NUMBER} -Dsonar.analysis.jobName=${JOB_NAME}  -s settings.xml"
                        echo 'Step :::Clean,Deploy,Dependency-check,Sonar commands - Completed'
                        collectBranchesToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', filter: '', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', workspaceId: '2001'
                        
                        echo 'Step ::: Executing Code Coverage Analysis - Starting'
                        props = readMavenPom().getProperties()
                        exclusionPattern = props.entrySet().findAll{entry -> entry.key.startsWith('jacoco-exclusion')}.collect{it.value}.join(',')
                        echo "exclusionPattern = ${exclusionPattern}"
                        jacoco( execPattern: '**/target/jacoco.exec', exclusionPattern: exclusionPattern)
                        //publishCodeCoverage jacocoPathPattern: '**/target/site/*/jacoco.xml', lcovPathPattern: '**/coverage/lcov.info'
                        //publishCoverage adapters: [jacocoAdapter(mergeToOneReport: true, path: '**/target/site/*/jacoco.xml')], sourceFileResolver: sourceFiles('NEVER_STORE')
                        recordCoverage(tools: [[pattern: '**/target/site/*/jacoco.xml']])
                        echo 'Step ::: Executing Code Coverage Analysis - Completed'

                        echo 'Step ::: Octane command to Collect Pull Requests - Starting'
                        collectPullRequestsToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', sourceBranchFilter: '', targetBranchFilter: '', workspaceId: '2001'
                        echo 'Step ::: Octane command to Collect Pull Requests - Completed'

                        echo 'Step ::: Publishng Dependecy Check Analysis Results'
                        dependencyCheckPublisher pattern: ''
}   }  }  }


def executeJavaReleaseBuildForConfigServer(){
      bat 'set'
      withCredentials([string(credentialsId: 'Vault-Password', variable: 'passwordvault.client.pass.value'), usernamePassword(credentialsId: 'git-svc-acct', passwordVariable: 'spring.cloud.config.server.git.password', usernameVariable: 'spring.cloud.config.server.git.username'), usernamePassword(credentialsId: 'git-svc-acct', passwordVariable: 'gitPassword', usernameVariable: 'gitUsername')]) {
      withSonarQubeEnv(installationName: 'EnterpriseDevops-SonarQubeServer', credentialsId: 'EnterpriseDevops-SonarToken') {
      withMaven(jdk: 'jdk11', maven: 'Maven', mavenSettingsConfig: '0c532131-ab08-411a-bba0-690f45d054e1', mavenSettingsFilePath: 'settings.xml', options: [jacocoPublisher(disabled: true),junitPublisher(healthScaleFactor: 1.0)]){

            echo 'codeQLScan: Starting'
            codeQLScan()
            echo 'codeQLScan: completed'            

            echo 'Step ::: Octane SonarQube Coverage check'
            addALMOctaneSonarQubeListener pushCoverage: true, pushVulnerabilities:true, sonarToken:"${env.SONAR_AUTH_TOKEN}", sonarServerUrl:"${env.SONAR_HOST_URL}" 
			
			echo 'Step ::: Executing Release clean'
			bat "mvn release:clean"
			echo 'Step ::: End of step Release clean'
			
            echo 'Step ::: Executing Prepare,Dependency-check,Sonar commands'
            bat "mvn -Dusername=${gitUserName} -Dpassword=${gitPassword} --s settings.xml -Darguments=\"-DreleaseVersion=${releaseVersion} -DdevelopmentVersion=${developerVersion} -Dpasswordvault.client.url=${env.vault_url} -Dpasswordvault.client.id.value=${env.vault_id} -Dspring.cloud.config.server.git.uri=${env.GIT_URL}\" release:prepare -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_AUTH_TOKEN} -Dsonar.analysis.buildNumber=${BUILD_NUMBER} -Dsonar.analysis.jobName=${JOB_NAME} dependency-check:check sonar:sonar"
            echo 'Step ::: Executing Prepare,Dependency-check,Sonar commands-Completed'

            echo 'Step ::: Executing perform command'
            bat "mvn -Dusername=${gitUserName} -Dpassword=${gitPassword} --s settings.xml -Darguments=\"-Dmaven.test.skip=true -Ddependency-check.skip=true\" release:perform" 
            echo 'Step ::: Executing perform command-Completed'
            echo 'Step ::: End of step Prepare,Perform,Dependency-check,Sonar commands-Completed'
            collectBranchesToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', filter: '', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', workspaceId: '2001'

            echo 'Step ::: Executing Code Coverage Analysis - Starting'
            props = readMavenPom().getProperties()
            exclusionPattern = props.entrySet().findAll{entry -> entry.key.startsWith('jacoco-exclusion')}.collect{it.value}.join(',')
            echo "exclusionPattern = ${exclusionPattern}"
            jacoco( execPattern: '**/target/jacoco.exec', exclusionPattern: exclusionPattern)
            //publishCodeCoverage jacocoPathPattern: '**/target/site/*/jacoco.xml', lcovPathPattern: '**/coverage/lcov.info'
            //publishCoverage adapters: [jacocoAdapter(mergeToOneReport: true, path: '**/target/site/*/jacoco.xml')], sourceFileResolver: sourceFiles('NEVER_STORE')
            recordCoverage(tools: [[pattern: '**/target/site/*/jacoco.xml']])
            echo 'Step ::: Executing Code Coverage Analysis - Completed'

            echo 'Step ::: Octane command to Collect All Pull Requests - Starting'
            collectPullRequestsToAlmOctane configurationId: 'cb826be3-f417-4ac7-81e5-eb62239438f0', credentialsId: 'git-svc-acct', repositoryUrl: "${GIT_URL}", scmTool: 'github_cloud', sourceBranchFilter: '', targetBranchFilter: '', workspaceId: '2001'
            echo 'Step ::: Octane command to Collect All Pull Requests - Completed'

            echo 'Step ::: Publishng Dependecy Check Analysis Results'
            dependencyCheckPublisher pattern: 'dependency-check-report.xml'
}  }   }    }
// releaseNum should be in format R(versionNumber) eg: R6.1
// executeEnv should be in capital eg: DEV
// branchName output should match our job name for java
def executeAllServicePROD(){
 echo "JavaUtils:executeAllServicePROD:  Executing /GCM/Java/sce-td-gcm-distribution-connectivity/master"
 def jobResult_DC = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-distribution-connectivity/master", parameters: [booleanParam(name: 'NexusReleasePackage', value: "false"),booleanParam(name: 'DeployFromNexus', value: "true"),booleanParam(name: 'SkipTests', value: "true")]
 echo "JavaUtils:executeAllServicePROD:  Executing /GCM/Java/sce-td-gcm-meter-to-grid/master/"
 def jobResult_M2G = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-meter-to-grid/master/", parameters: [booleanParam(name: 'NexusReleasePackage', value: "false"),booleanParam(name: 'DeployFromNexus', value: "true"),booleanParam(name: 'SkipTests', value: "true")]
 echo "JavaUtils:executeAllServicePROD:  Executing /GCM/Java/sce-td-gcm-structure-feeder-info/main/"
 def jobResult_SFI = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-structure-feeder-info/main/", parameters: [booleanParam(name: 'NexusReleasePackage', value: "false"),booleanParam(name: 'DeployFromNexus', value: "true"),booleanParam(name: 'SkipTests', value: "true")]
 echo "JavaUtils:executeAllServicePROD:  Executing /GCM/Java/sce-td-gcm-substation-changed-list/main/"
 def jobResult_SCL = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-substation-changed-list/main/", parameters: [booleanParam(name: 'NexusReleasePackage', value: "false"),booleanParam(name: 'DeployFromNexus', value: "true"),booleanParam(name: 'SkipTests', value: "true")]
 echo "JavaUtils:executeAllServicePROD:  Executing /GCM/Java/sce-td-gcm-substation-hierarchy/master"
 def jobResult_SH = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-substation-hierarchy/master", parameters: [booleanParam(name: 'NexusReleasePackage', value: "false"),booleanParam(name: 'DeployFromNexus', value: "true"),booleanParam(name: 'SkipTests', value: "true")]
 echo "JavaUtils:executeAllServicePROD:  Executing /GCM/Java/sce-td-gcm-substation-internal/master"
 def jobResult_SI = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-substation-internal/master", parameters: [booleanParam(name: 'NexusReleasePackage', value: "false"),booleanParam(name: 'DeployFromNexus', value: "true"),booleanParam(name: 'SkipTests', value: "true")]
 echo "JavaUtils:executeAllServicePROD:  Executing /GCM/Java/sce-td-gcm-dvt/main"
 def jobResult_DVT = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-dvt/main", parameters: [booleanParam(name: 'NexusReleasePackage', value: "false"),booleanParam(name: 'DeployFromNexus', value: "true"),booleanParam(name: 'SkipTests', value: "true")]
}

def executeAllServiceNonProdBuilds(String branchName,Boolean deployFromNexus, Boolean releasePackage,Boolean skipTest){
 def jobResult_DC = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-distribution-connectivity/${branchName}", parameters: [booleanParam(name: 'NexusReleasePackage', value: "${releasePackage}"),booleanParam(name: 'DeployFromNexus', value: "${deployFromNexus}"),booleanParam(name: 'SkipTests', value: "${skipTest}")]
 def jobResult_M2G = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-meter-to-grid/${branchName}", parameters: [booleanParam(name: 'NexusReleasePackage', value: "${releasePackage}"),booleanParam(name: 'DeployFromNexus', value: "${deployFromNexus}"),booleanParam(name: 'SkipTests', value: "${skipTest}")]
 def jobResult_SFI = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-structure-feeder-info/${branchName}", parameters: [booleanParam(name: 'NexusReleasePackage', value: "${releasePackage}"),booleanParam(name: 'DeployFromNexus', value: "${deployFromNexus}"),booleanParam(name: 'SkipTests', value: "${skipTest}")]
 def jobResult_SCL = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-substation-changed-list/${branchName}", parameters: [booleanParam(name: 'NexusReleasePackage', value: "${releasePackage}"),booleanParam(name: 'DeployFromNexus', value: "${deployFromNexus}"),booleanParam(name: 'SkipTests', value: "${skipTest}")]
 def jobResult_SH = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-substation-hierarchy/${branchName}", parameters: [booleanParam(name: 'NexusReleasePackage', value: "${releasePackage}"),booleanParam(name: 'DeployFromNexus', value: "${deployFromNexus}"),booleanParam(name: 'SkipTests', value: "${skipTest}")]
 def jobResult_SI = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-substation-internal/${branchName}", parameters: [booleanParam(name: 'NexusReleasePackage', value: "${releasePackage}"),booleanParam(name: 'DeployFromNexus', value: "${deployFromNexus}"),booleanParam(name: 'SkipTests', value: "${skipTest}")]
 def jobResult_DVT = build propagate: false, wait: false,job: "/GCM/Java/sce-td-gcm-dvt/${branchName}", parameters: [booleanParam(name: 'NexusReleasePackage', value: "${releasePackage}"),booleanParam(name: 'DeployFromNexus', value: "${deployFromNexus}"),booleanParam(name: 'SkipTests', value: "${skipTest}")]
}