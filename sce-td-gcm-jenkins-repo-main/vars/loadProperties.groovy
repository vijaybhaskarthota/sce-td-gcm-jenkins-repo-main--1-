//config_type Supported Values 'DB' , 'FME' , 'JAVA' , 'DP','RELEASE'
def call(String config_type = 'DB') {
    echo "loadProperties:Loading Properites File with Config Type ${config_type}"
//    configFileProvider([configFile(fileId: 'GCM_DB_CONFIG', targetLocation: 'GCM_DB_CONFIG', variable: 'GCM_DB_CONFIG'), configFile(fileId: 'GCM_FME_CONFIG', targetLocation: 'GCM_FME_CONFIG', variable: 'GCM_FME_CONFIG'), configFile(fileId: 'GCM_JAVA_CONFIG', targetLocation: 'GCM_JAVA_CONFIG', variable: 'GCM_JAVA_CONFIG'),configFile(fileId: 'GCM_RELEASE_CONFIG', targetLocation: 'GCM_RELEASE_CONFIG', variable: 'GCM_RELEASE_CONFIG'),configFile(fileId: 'c35ac6ee-c941-4a50-97a3-392e6ac56533', targetLocation: 'DependencyCheckSuppression.xml', variable: 'DependencyCheckSuppression')]) {
    script{
/*      Sample Code to print all properties for debugging
        for (element in db_props) {
            echo "loadProperties:DB:${element.key} ${element.value}"
        }
*/
        if("${config_type}"=='DB'){            
            configFileProvider([configFile(fileId: 'GCM_DB_CONFIG', targetLocation: 'GCM_DB_CONFIG', variable: 'GCM_DB_CONFIG')]) {
                def db_props = readProperties file: "$GCM_DB_CONFIG"
                echo "loadProperties:Returning db_props. file ID:GCM_DB_CONFIG targetLocation:GCM_DB_CONFIG."
                return db_props  
            }
        }
        else if("${config_type}"=='FME'){
            configFileProvider([configFile(fileId: 'GCM_FME_CONFIG', targetLocation: 'GCM_FME_CONFIG', variable: 'GCM_FME_CONFIG')]) {
                def fme_props = readProperties file: "$GCM_FME_CONFIG"
                echo "loadProperties:Returning fme_props. file ID:GCM_FME_CONFIG targetLocation:GCM_FME_CONFIG."
                return fme_props
            }
        }
        else if("${config_type}"=='JAVA'){
            configFileProvider([configFile(fileId: 'GCM_JAVA_CONFIG', targetLocation: 'GCM_JAVA_CONFIG', variable: 'GCM_JAVA_CONFIG'),configFile(fileId: 'c35ac6ee-c941-4a50-97a3-392e6ac56533', targetLocation: 'DependencyCheckSuppression.xml', variable: 'DependencyCheckSuppression')]) {
                def java_props = readProperties file: "$GCM_JAVA_CONFIG" 
                echo "loadProperties:Returning java_props. file ID:GCM_JAVA_CONFIG targetLocation:GCM_JAVA_CONFIG."
                return java_props
            }
        } 
        else if("${config_type}"=='MSP'){
            configFileProvider([configFile(fileId: 'MSP_CONFIG', targetLocation: 'MSP_CONFIG', variable: 'MSP_CONFIG'),configFile(fileId: 'c35ac6ee-c941-4a50-97a3-392e6ac56533', targetLocation: 'DependencyCheckSuppression.xml', variable: 'DependencyCheckSuppression')]) {
                def msp_props = readProperties file: "$MSP_CONFIG" 
                echo "loadProperties:Returning msp_props. file ID:MSP_CONFIG targetLocation:MSP_CONFIG."
                return msp_props
            }
        }   
        else if("${config_type}"=='DP'){
            configFileProvider([configFile(fileId: 'GCM_DP_CONFIG', targetLocation: 'GCM_DP_CONFIG', variable: 'GCM_DP_CONFIG')]) {
                def dp_props = readProperties file: "$GCM_DP_CONFIG" 
                echo "loadProperties:Returning dp_props. file ID:GCM_DP_CONFIG targetLocation:GCM_DP_CONFIG."
                return dp_props
            }
        }    
        else if("${config_type}"=='RELEASE'){
            configFileProvider([configFile(fileId: 'GCM_RELEASE_CONFIG', targetLocation: 'GCM_RELEASE_CONFIG', variable: 'GCM_RELEASE_CONFIG')]) {
                def release_props = readProperties file: "$GCM_RELEASE_CONFIG" 
                echo "loadProperties:Returning release_props. file ID:GCM_RELEASE_CONFIG targetLocation:GCM_RELEASE_CONFIG."
                return release_props
            }
        }    
        else if("${config_type}"=='RAPTOR'){
            configFileProvider([configFile(fileId: 'GCM_RAPTOR_CONFIG', targetLocation: 'GCM_RAPTOR_CONFIG', variable: 'GCM_RAPTOR_CONFIG')]) {
                def raptor_props = readProperties file: "$GCM_RAPTOR_CONFIG" 
                echo "loadProperties:Returning raptor_props. file ID:GCM_RAPTOR_CONFIG targetLocation:GCM_RAPTOR_CONFIG."
                return raptor_props
            }
        }
        else if("${config_type}"=='PerfTest'){
            configFileProvider([configFile(fileId: 'GCM_TEST_CONFIG', targetLocation: 'GCM_TEST_CONFIG', variable: 'GCM_TEST_CONFIG')]) {
                def test_props = readProperties file: "$GCM_TEST_CONFIG" 
                echo "loadProperties:Returning test_props. file ID:GCM_TEST_CONFIG targetLocation:GCM_TEST_CONFIG."
                return test_props
            }
        }
        else{
                echo "loadProperties:Invalid Config Type"
        }  
    }
}
