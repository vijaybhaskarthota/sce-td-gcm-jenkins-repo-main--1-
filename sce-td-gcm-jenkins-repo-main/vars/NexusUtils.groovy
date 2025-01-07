import groovy.json.JsonSlurper
import groovy.json.JsonParserType
def call()
{

}
def retriveNexusArtifact(String repository,String ArtifactVersion) {
    ArtifactGroupID = readMavenPom().getGroupId()   
    ArtifactID = readMavenPom().getArtifactId()
    DeployVersion = readMavenPom().getVersion()
    echo "retriveNexusArtifact:Artifact ID:${ArtifactID},Artifact GroupID:${ArtifactGroupID},ArtifactVersion:${ArtifactVersion}"    
    nexus_URL="https://nexus.gmdevops.sce.com/service/rest/v1/search/assets?sort=version&direction=desc&repository=${repository}&maven.groupId=${ArtifactGroupID}&maven.artifactId=${ArtifactID}&maven.extension=war"
    def response = httpRequest authentication: 'Nexus-admin',url: "${nexus_URL}"
    echo "retriveNexusArtifact:Retrieving Artifact List:Response Code:${response.status}"
    def JsonResponse = new JsonSlurper().parseText(response.content)
    def downloadURL=(JsonResponse.items.find{it.maven2.version == ArtifactVersion}).downloadUrl
    JsonResponse = null
    //def localPath="${WORKSPACE}\\target\\${ArtifactID}-${ArtifactVersion}.war"
    def localPath=""
    if (repository == "sce-releases"){
        localPath="${WORKSPACE}\\target\\${ArtifactID}##${ArtifactVersion}.war"
    } else {
        localPath="${WORKSPACE}\\target\\${ArtifactID}##${DeployVersion}.war"
    }
    echo "retriveNexusArtifact:Retrieving Artifact:Download URL:${downloadURL},localPath:${localPath}"
    def resp = httpRequest authentication: 'Nexus-admin',httpMode: 'GET'  ,outputFile: "${localPath}", url: "${downloadURL}", wrapAsMultipart: false
    echo "retriveNexusArtifact:Retrieving Artifact:Response Code:${resp.status}"
}

def retriveNexusArtifactVersions(String repository) {
    ArtifactGroupID = readMavenPom().getGroupId()   
    ArtifactID = readMavenPom().getArtifactId()
    echo "retriveNexusArtifactVersions:Artifact ID:${ArtifactID},Artifact GroupID:${ArtifactGroupID}"  
    withCredentials([usernameColonPassword(credentialsId: 'Nexus-admin', variable: 'credential')]) {
        nexus_URL="https://nexus.gmdevops.sce.com/service/rest/v1/search/assets?sort=version&direction=desc&repository=${repository}&maven.groupId=${ArtifactGroupID}&maven.artifactId=${ArtifactID}&maven.extension=war"
        echo "retriveNexusArtifactVersions:Nexus Repository URL:${nexus_URL}"
        def connection = new URL(nexus_URL).openConnection() as HttpURLConnection
        def auth = ("${credential}".bytes.encodeBase64()).toString()
        connection.setRequestProperty( 'Accept', 'application/json' )
        connection.setRequestProperty("Authorization", "Basic ${auth}")
        if ( connection.responseCode == 200 ) {
            def JsonResponse = new JsonSlurper().parseText(connection.inputStream.text)
            def List = JsonResponse["items"]["maven2"]["version"].collect()
            def NexusArtifactsVersionList = [] as ArrayList
            for (item in List) {
                    NexusArtifactsVersionList.add("${item}")
            }
            echo "retriveNexusArtifactVersions:Repository:${repository},ArtifactGroupID:${ArtifactGroupID},ArtifactID:${ArtifactID},Version Array List${NexusArtifactsVersionList}"
            return NexusArtifactsVersionList
        } else {
            echo "retriveNexusArtifactVersions:Response Code Failure:${connection.responseCode},Response Text:${connection.inputStream.text}"
        }
    }
}