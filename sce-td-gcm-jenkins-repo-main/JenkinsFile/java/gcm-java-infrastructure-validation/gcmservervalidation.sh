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
echo Final Validation Return Code:$return_code
exit $return_code