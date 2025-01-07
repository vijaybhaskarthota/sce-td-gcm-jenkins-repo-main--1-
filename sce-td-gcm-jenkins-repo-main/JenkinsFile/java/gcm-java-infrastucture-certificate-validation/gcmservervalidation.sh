#!/bin/bash
#test_connectivity param 1 is server and param 2 is port and return 0(success) and 1 (failure)
test_connectivity()
{
    echo Testing connectivity with Server:$1 and port:$2
    nc -z -v $1 $2
    return $?    
    # This method should accept 2 parameters
    # For begining 1 parameter will be dev server and 2 parameter will be jenkin server and hard code truststore(cacert file) path
    #locate the truststore for the server1(parameter 1)
    #ssl command to make connection to target server(parameter 2) using trustore
}
#validate_certificate param 1 is url and param 2 is truststore password
# Defining the test_validate_certificate function
test_validate_certificate()
{
  # Assign the parameters to variables
  server1=$1
  server2=$2

  # Hard code the truststore path
  truststore="E:\apps\tomcat9\latest\security" # Replace with the actual path of the truststore file

  # Check if the truststore file exists
  if [ ! -f "$truststore" ]; then
    echo "Truststore file not found: $truststore"
    exit 1
  fi

  # Extract the host and port from the server1 URL
  host=$(echo "$server1" | cut -d '/' -f 3 | cut -d ':' -f 1)
  port=$(echo "$server1" | cut -d '/' -f 3 | cut -d ':' -f 2)

  # Create an SSL connection to the server1 using the truststore
  openssl s_client -connect "$host:$port" -CAfile "$truststore" -quiet > /dev/null 2>&1

  # Check the exit code of the SSL connection
  if [ $? -eq 0 ]; then
    # The connection is successful
    echo "Connected to $server1"
  else
    # The connection is not successful
    echo "Failed to connect to $server1"
    exit 2
  fi

  # Create an SSL connection to the server2 using the truststore
  openssl s_client -connect "$server2:443" -CAfile "$truststore" -quiet > /dev/null 2>&1

  # Check the exit code of the SSL connection
  if [ $? -eq 0 ]; then
    # The connection is successful
    echo "Connected to $server2"
  else
    # The connection is not successful
    echo "Failed to connect to $server2"
    exit 3
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
test_validate_certificate https://aexcsgcm01.sce.com:8443  iewvdjnk01.sce.eix.com
return_code=$(($return_code + $?))
#echo ***********Validate Certificate Status:$?
echo Final Validation Return Code:$return_code
exit $return_code