#!/bin/bash
#test_connectivity param 1 is server and param 2 is port and return 0(success) and 1 (failure)
test_connectivity()
{
    echo Testing connectivity with Server:$1 and port:$2
    nc -z -v $1 $2
    return $?
}
test_splunk_process()
{
    /sbin/service SplunkForwarder status
    # return $#
    return $?
}
test_tomcat_process()
{
    ps -ef | grep tomcat|grep -v grep
    tomcat_process_user=$(ps -ef | grep tomcat|grep -v grep|awk '{print $1}')
    echo Tomcat Process User:$tomcat_process_user
    if [ "$tomcat_process_user" == "tomcat" ] 
    then
        echo Tomcat Process is running with tomcat user
        return 0
    else
        echo Tomcat Process is NOT running with tomcat user
        return 1
    fi
}
test_group_membership()
{
    USER=tomcat
    GROUP=tomcat
    if id -nG "$USER" | grep -c "$GROUP"
    then
        echo User:$USER belongs to Group:$GROUP
        return 0
    else
        echo User:$USER does not belong to Group:$GROUP
        return 1
    fi
}
# This script takes two arguments: a url and a java truststore file
# It uses openssl and keytool commands to extract and compare the certificates
# It prints "Valid" if the certificates match, and "Invalid" otherwise
#test_validate_certificate()
#{
#url=$1
#truststore=$2

# Extract the server certificate from the url
#server_cert=$(openssl s_client -showcerts -connect $url:443 </dev/null 2>/dev/null | openssl x509 -outform PEM)

# Extract the trusted certificate from the truststore file
#trusted_cert=$(keytool -list -rfc -keystore $truststore -storepass changeit | sed -n '/Owner: CN='$url'/,/^$/p')

# Compare the certificates and print the result
#if [ "$server_cert" == "$trusted_cert" ]; then
# echo "Valid"
#else
# echo "Invalid"
# fi
#}

#validate_certificate param 1 is url and param 2 is truststore password
test_validate_certificate()
{
   echo Validating certificate from URL:$1
   #extract the host and port from the url
    host=$(echo $1 | cut -d'/' -f3 | cut -d':' -f1)
    port=$(echo $1 | cut -d'/' -f3 | cut -d':' -f2)
    #get the certificate from the url using openssl
    cert=$(openssl s_client -connect $host:$port 2>/dev/null </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')
    #save the certificate to a temporary file
    tmpfile=$(mktemp)
    echo "$cert" > $tmpfile
    #import the certificate to a new keystore using keytool
    keytool -import -v -trustcacerts -alias $host -file $tmpfile -keystore tmpkeystore.jks -storepass $2 -noprompt
    #verify the certificate against the default truststore using keytool
    #keytool -list -v -keystore tmpkeystore.jks -storepass $2 | grep "Certificate is valid"
    #all the certificates is present in default keystore(tmpkeystore) , command for listing all the certificates in tempkeystore
    keytool -list -v -keystore tmpkeystore.jks -storepass $2
    #get the list of aliases from the keystore
    aliases=$(keytool -list -keystore $keystore -storepass $storepass | grep 'Alias name:' | cut -d' ' -f3)
    #loop through each alias
    for alias in $aliases; do
    #get the certificate file for the alias
    certfile=$(mktemp)
    keytool -exportcert -alias $alias -keystore $keystore -storepass $storepass -rfc -file $certfile
    #print the certificate details
    echo "Certificate details for alias: $alias"
    openssl x509 -in $certfile -noout -text
   #check the validity of the certificate and send a notification if it expires in a month
   openssl x509 -enddate -noout -in $certfile -checkend 2592000 | grep -q 'Certificate will expire' && notify-send "Certificate for alias $alias will expire in 30 days or less"
}
#make sslconnection to target server in spring.gmdevops.sce.com ,find out the cacerts in the linuxservers to make connection with openssl to target server(spring.gmdevops.sce.com)
#find ssl command to make connection to target server using trustore in the host (dev server)
#locate the truststore for the devserver(host server)
return_code=0
test_connectivity spring.gmdevops.sce.com 443
return_code=$(($return_code + $?))
test_connectivity iewvdjnk01.sce.eix.com 443
return_code=$(($return_code + $?))
test_connectivity iewvdjnk01.sce.eix.com 8443
return_code=$(($return_code + $?))
test_connectivity iewvdnex01.sce.eix.com 443
return_code=$(($return_code + $?))
test_connectivity iewvdnex01.sce.eix.com 8443
return_code=$(($return_code + $?))
#echo ***********Testing connectivity Status:$?
test_splunk_process
return_code=$(($return_code + $?))
#echo ***********Splunk Running Status:$?
test_tomcat_process
return_code=$(($return_code + $?))
#echo ***********Tomcat Process Owner Status:$?
test_group_membership
return_code=$(($return_code + $?))
#echo ***********Group Membership Status:$?
test_validate_certificate https://iewvdjnk01.sce.eix.com:443 changeit
return_code=$(($return_code + $?))
#echo ***********Validate Certificate Status:$?
echo Final Validation Return Code:$return_code
exit $return_code