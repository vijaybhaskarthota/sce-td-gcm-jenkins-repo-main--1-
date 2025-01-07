from spring_config import ClientConfigurationBuilder
from spring_config.client import SpringConfigClient
import truststore
import configparser
import json
import jpype
import jpype.imports
from jpype.types import *

truststore.inject_into_ssl()
config = configparser.ConfigParser()
config.read('.\\utilities\\ToolsConfig.properties') #get the sample file from Managed files in Jenkins https://jenkins.gmdevops.sce.com/manage/configfiles/editConfig?id=ToolsConfig.properties
url=config.get("ConfigServer", "url")
app=config.get("ConfigServer", "app")
user=config.get("ConfigServer", "user")
password=config.get("ConfigServer", "password")
profile=config.get("ConfigServer", "profile")
branch=config.get("ConfigServer", "branch")
cp=config.get("ConfigServer", "classpath")
print(url,app,user,"****",profile,branch,cp)

jpype.startJVM(classpath=[cp])
from com.sce.util import EncryptorBean
from java.sql import Connection
from java.sql import DatabaseMetaData
from java.lang import Class
from java.sql import DriverManager
from java.sql import ResultSet
from java.sql import SQLException

encryptorBean=EncryptorBean()
config = (
        ClientConfigurationBuilder()
        .app_name(app)
        .address(url)
        .authentication((encryptorBean.stringEncryptor().decrypt(user),encryptorBean.stringEncryptor().decrypt(password)))
        .profile(profile)
        .branch(branch)
        .build()
    )
c = (SpringConfigClient(config))
print("environment:",c.get_attribute("spring.boot.admin.client.instance.metadata.tags.environment"))
db_driver = encryptorBean.stringEncryptor().decrypt(c.get_attribute("spring.datasource.driver-class-name"))
db_url = encryptorBean.stringEncryptor().decrypt(c.get_attribute("spring.datasource.url"))
username = encryptorBean.stringEncryptor().decrypt(c.get_attribute("spring.datasource.username"))
password = encryptorBean.stringEncryptor().decrypt(c.get_attribute("spring.datasource.password"))
print("DB Details:",db_driver,db_url,username,"****")
Class.forName ("oracle.jdbc.driver.OracleDriver")
conn = DriverManager.getConnection (db_url,username,password)
metaData = conn.getMetaData()
procedure_name = "GCM_P_GET_SUB_I_CONN"
#procedure_name = "GCM_P_CHANGED_I_SUBCONN_INFO"
procedures = metaData.getProcedures(None,"TCGACDS",procedure_name);
while (procedures.next()) : 
    print("Catalog name:",procedures.getString("PROCEDURE_CAT"),",Schema name:",procedures.getString("PROCEDURE_SCHEM"),",Procedure name:",procedures.getString("PROCEDURE_NAME"),",Type of the procedure:",procedures.getShort("PROCEDURE_TYPE"),",Specific name of the procedure:",procedures.getString("SPECIFIC_NAME"))
procedure_col = metaData.getProcedureColumns(None,"TCGACDS",procedure_name,None)
while (procedure_col.next()) : 
    print("Schema name:",procedure_col.getString("PROCEDURE_SCHEM"),"Procedure name:",procedure_col.getString("PROCEDURE_NAME"),",Column name:",procedure_col.getString("COLUMN_NAME"),",Column Type:",procedure_col.getString("TYPE_NAME"),",Specific name of the column:",procedure_col.getString("SPECIFIC_NAME"),",ORDINAL_POSITION:",procedure_col.getInt("ORDINAL_POSITION"))
