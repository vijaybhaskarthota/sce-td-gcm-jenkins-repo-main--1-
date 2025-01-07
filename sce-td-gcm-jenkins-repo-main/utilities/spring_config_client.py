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
print("Configurations:----------------------------\n",c.get_config(),"\n-----------------------------------------")
print("environment:",c.get_attribute("spring.boot.admin.client.instance.metadata.tags.environment"))
#print("datasource.driver-class-name:",encryptorBean.stringEncryptor().decrypt(c.get_attribute("spring.datasource.driver-class-name")))
#print("datasource.url:",encryptorBean.stringEncryptor().decrypt(c.get_attribute("spring.datasource.url")))
#print("datasoure.username:",encryptorBean.stringEncryptor().decrypt(c.get_attribute("spring.datasource.username")))
#print("datasoure.password:",encryptorBean.stringEncryptor().decrypt(c.get_attribute("spring.datasource.password")))
print("fme-dev-username:",encryptorBean.stringEncryptor().decrypt(c.get_attribute("fme-dev-username")))