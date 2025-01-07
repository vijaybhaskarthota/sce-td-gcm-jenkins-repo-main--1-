import truststore
import configparser
import json
import jpype
import jpype.imports
from jpype.types import *
from arcgis.gis import GIS
from arcgis.geocoding import geocode


truststore.inject_into_ssl()
config = configparser.ConfigParser()
config.read('.\\utilities\\ToolsConfig.properties') #get the sample file from Managed files in Jenkins https://jenkins.gmdevops.sce.com/manage/configfiles/editConfig?id=ToolsConfig.propertiesurl=config.get("ArcGIS", "url")
user=config.get("ArcGIS", "user")
password=config.get("ArcGIS", "pass")
print(url,user,"****")
