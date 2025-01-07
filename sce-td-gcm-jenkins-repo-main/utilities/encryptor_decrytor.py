import configparser
import jpype
import jpype.imports
from jpype.types import *
from py4j.java_gateway import JavaGateway

config = configparser.ConfigParser()
config.read('.\\utilities\\ToolsConfig.properties') #get the sample file from Managed files in Jenkins https://jenkins.gmdevops.sce.com/manage/configfiles/editConfig?id=ToolsConfig.properties
cp=config.get("ConfigServer", "classpath")
# jpype.addClassPath("C:\\Program Files\\Java\\jdk1.8.0_331\\lib")
# jpype.addClassPath('C:\\Users\\singhak\\.m2\\repository\\com\\sce\\framework\\gcm-framework\\1.3.8/gcm-framework-1.3.8.jar')
# jpype.addClassPath('C:\\Program Files\\SmartBear\\ReadyAPI-3.42.1\\bin\\ext\\ojdbc8.jar')
# jpype.addClassPath('C:\\Users\\singhak\\.m2\\repository\\org\\jasypt\\jasypt\\1.9.3\\jasypt-1.9.3.jar')
print("CP:",cp,"\nDefaultJVMPath:",jpype.getDefaultJVMPath(),"\nJVMStarted:",jpype.isJVMStarted(),"\nJPYPE CP:",jpype.getClassPath(env=True))
#jpype.startJVM(classpath=[cp])
#jpype.startJVM(classpath="C:/Program Files/Java/jdk1.8.0_331/lib")
#jpype.startJVM(jpype.getDefaultJVMPath(),"-Djava.class.path=C:/Users/singhak/.m2/repository/com/sce/framework/gcm-framework/1.3.8/gcm-framework-1.3.8.jar")
#jpype.startJVM(jpype.getDefaultJVMPath(),"-Djava.class.path=C:/Program Files/Java/jdk1.8.0_331/lib")
#jpype.startJVM(classpath="")
print("CP:",cp,"\nDefaultJVMPath:",jpype.getDefaultJVMPath(),"\nJVMStarted:",jpype.isJVMStarted(),"\nJPYPE CP:",jpype.getClassPath(env=True))
from py4j.java_gateway import JavaGateway
gg=JavaGateway.launch_gateway(classpath="C:/Users/singhak/AppData/Local/Packages/PythonSoftwareFoundation.Python.3.11_qbz5n2kfra8p0/LocalCache/local-packages/share/py4j/py4j0.10.9.7.jar;C:/Users/singhak/.m2/repository/com/sce/framework/gcm-framework/1.3.8/gcm-framework-1.3.8.jar")
encryptorBean = gg.jvm.com.sce.util.EncryptorBean()
#result = myclass_instance.my_method()

#from com.sce.util import EncryptorBean
encryptorBean=EncryptorBean()
encrypt_string = input("Enter the string to be Encrypted :")
print("Original String:",encrypt_string,",Encrypted Sting:",encryptorBean.stringEncryptor().encrypt(encrypt_string))
decrypt_string = input("Enter the string to be Decrypted :")
print("Original String:",decrypt_string,",Encrypted String:",encryptorBean.stringEncryptor().decrypt(decrypt_string))