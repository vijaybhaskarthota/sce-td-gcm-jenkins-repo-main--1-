def call()
{

}
//Searchs the sce-td-gcm-jenkins-repo files in @script folder and provides the full path
def getFilePath(String fileName) 
{
    echo "getFilePath:fileName:${fileName},Script Folder:${env.WORKSPACE}@script"
    dir("${env.WORKSPACE}@script") {
        def jobname= env.JOB_NAME
        def patharray=jobname.split('/')
        def pipelinename=patharray[patharray.length-2]
        echo "${pipelinename}"
        def files = findFiles(glob: "**/${pipelinename}/${fileName}")
        echo "getFilePath:fileName:${fileName},Script Folder:${env.WORKSPACE}@script,No of Matching files:${files.size()},files:${files}"
        return "${env.WORKSPACE}@script\\${files[0].path}"
    }
}
// used in gcis-sql-execution
// used in circuit rebuild
def getDBConnectionDetails(String env,Map db_props){
    def db_props1 = loadProperties("DB")
    //echo "oracle url dev : ${db_props1['db.oracle.url.dev']}"
    def DB_CONN_STR
    def DB_CREDENTIALS
    switch("${env}") {            
         case 'DEV':
            DB_CONN_STR = "${db_props['db.oracle.url.dev']}"
            DB_CREDENTIALS = 'GCM-Non-ADMS-Dev-DB-TCGACDS-RW'             
            break; 
         case 'ST':
            DB_CONN_STR = "${db_props['db.oracle.url.st']}"
            DB_CREDENTIALS = 'GCM-Non-ADMS-ST-DB-TCGACDS-RW'
            break; 
        case 'PT':
            DB_CONN_STR = "${db_props['db.oracle.url.pt']}"
            DB_CREDENTIALS = 'GCM-PT-DB-TCGACDS-RW'
            break;        
        case 'REGR':
            DB_CONN_STR = "${db_props['db.oracle.url.reg']}"
            DB_CREDENTIALS = 'GCM-REG-DB-TCGACDS-RW'
            break;     
        case 'BF':
            DB_CONN_STR = "${db_props['db.oracle.url.bf']}"
            DB_CREDENTIALS = 'GCM-HF-DB-L982-TCGACDS-RW'
            break;     
        case 'PROD':
            DB_CONN_STR = "${db_props['db.oracle.url.prod']}"
            DB_CREDENTIALS = 'GCM-PROD-DB-TCGACDS-RW'
            break;  
    }
    def db_details= ["DBCRED":"${DB_CREDENTIALS}" ,"CONNSTR": "${DB_CONN_STR}"]
    return  db_details     
}

