#Powershell Paramter definition
param (
   [Parameter(Mandatory=$true)]
   [string[]]$ServerList    #List of servers to be validated
)
#add a function to check the ssl connectivity to server:port from a serverlist
function CheckSSLConnectivity {
   param (
       [Parameter(Mandatory=$true)]
       [string[]]$ServerList,
       [Parameter(Mandatory=$true)]
       [string]$Hostname,
       [Parameter(Mandatory=$true)]
       [string]$Port
   )
   try {
        Write-Host "CheckSSLConnectivity:ServerList:$ServerList Host:$Hostname Port:$Port"
        Invoke-Command -ComputerName $ServerList -UseSSL -ScriptBlock { 
            param($Hostname,$Port)
            try {
                $result = Test-NetConnection -ComputerName $Hostname -Port $Port -ErrorAction Stop
                if ($result.TcpTestSucceeded) {
                    Write-Host "CheckSSLConnectivity:Network connectivity test succeeded for $Hostname on port $Port" -fore Green
                } else {
                    Write-Host "CheckSSLConnectivity:Network connectivity test failed for $Hostname on port $Port" -fore Red
                }
            } catch {
                Write-Host "CheckSSLConnectivity:Error: Failed to test network connection to $Hostname on port $Port. $_" -fore Red
            }
            #Get-Process $Processes  | Select-Object Name, Id,StartTime| Sort-Object Id -Descending | Format-Table -AutoSize 
        } -ArgumentList $Hostname,$Port
    } 
    catch {
        Write-Host "CheckSSLConnectivity:Error: Failed to check SSL Connectivity status for $Hostname on port $Port. $_" -fore Red
    }
}
function CheckServerTimeSync {
   param (
       [Parameter(Mandatory=$true)]
       [string[]]$ServerList
   )
   $localTime = Get-Date
   foreach ($server in $ServerList) {
       try {
           $remoteTime = Invoke-Command -ComputerName $server -UseSSL -ScriptBlock { Get-Date } -ErrorAction Stop
           $timeDifference = New-TimeSpan -Start $localTime -End $remoteTime

           if ($timeDifference.TotalMinutes -gt 2) {
               Write-Host "CheckServerTimeSync:Warning: Time difference between local computer and $server is more than 2 minutes." -fore Red
           } else {
               Write-Host "CheckServerTimeSync:Time sync check passed for $server. Time Difference is $timeDifference" -fore Green
           }
       } catch {
           Write-Host "CheckServerTimeSync:Error: Failed to check time sync for $server. $_" -fore Red
       }
   }
}
function CheckServiceStatus {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ServerList,
        
        [Parameter(Mandatory=$true)]
        [string[]]$Services
    )
    try {
        Write-Host "CheckServiceStatus:ServerList:$ServerList Services:$Services"
        Invoke-Command -ComputerName $ServerList -UseSSL -ScriptBlock { 
            param($Services)
            $serviceInfo = @()
            Get-Service | Where-Object { $_.DisplayName -like "$Services" } | ForEach-Object {
                $service = $_
                $status = $service.Status
                $name = $service.Name
                $displayname = $service.DisplayName
                #$processId = $service.Id
                $wmiObj = Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -eq "$name" } -ErrorAction SilentlyContinue
                $processId = $wmiObj.processId
                $StartMode = $wmiObj.StartMode              
                $process = Get-Process | Where-Object { $_.Id -eq $processId } -ErrorAction SilentlyContinue
                $processName = if ($process) { $process.ProcessName } else { "N/A" }
                $startTime = if ($process) { $process.StartTime } else { "N/A" }
        
                $serviceInfo += New-Object PSObject -Property @{
                    ServiceName = $name
                    ServiceDisplayName = $displayname
                    Status      = $status
                    ProcessID   = $processId
                    ProcessName = $processName
                    StartTime   = $startTime
                    StartMode   = $StartMode
                }
            }
        
            # Output the service information in a table
            $serviceInfo | Format-Table -Property ServiceDisplayName, Status, ProcessID, ProcessName, StartTime , StartMode -AutoSize
        } -ArgumentList $Services
    }
    catch {
        Write-Host "CheckServiceStatus:Error: Failed to check Service status. $_" -fore Red
    }
}

function ServicesRestart {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ServerList,
        
        [Parameter(Mandatory=$true)]
        [string[]]$Services
    )
    try {
        Write-Host "ServicesRestart:ServerList:$ServerList Services:$Services"
        Write-Host "ServicesRestart:ServerList:$ServerList Services:$Services Current status of the Services Before Restart"
        CheckServiceStatus -ServerList $ServerList -Services $Services
        #Restart Logic
        Invoke-Command -ComputerName $ServerList -UseSSL -ScriptBlock { 
            param($Services)
            Get-Service | Where-Object { $_.DisplayName -like "$Services" } | ForEach-Object {
                $service = $_
                $name = $service.Name
                Write-Host "ServicesRestart:Restarting Servcie $name"
                Restart-Service -Name "$name" -Force
                Write-Host "ServicesRestart:Restarting Servcie $name complete"
            }
        } -ArgumentList $Services
        Write-Host "ServicesRestart:ServerList:$ServerList Services:$Services Current status of the Services After Restart"
        CheckServiceStatus -ServerList $ServerList -Services $Services
    }
    catch {
        Write-Host "ServicesRestart:ServerList:$ServerList Services:$Services Failed to restart the services $_" -fore Red
    }
}
function CheckAndResetProxy {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ServerList
    )

    try {
        Write-Host "CheckAndResetProxy:ServerList:$ServerList"
        Invoke-Command -ComputerName $ServerList -UseSSL -ScriptBlock { 
            $proxy = [Environment]::GetEnvironmentVariable("HTTPS_PROXY", "Machine")
            if ($null -ne $proxy) {
                Write-Host "CheckAndResetProxy:HTTPS_PROXY is set to $proxy. Resetting..."
                [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $null, "Machine")
                Write-Host "CheckAndResetProxy:HTTPS_PROXY has been reset."
            } else {
                Write-Host "CheckAndResetProxy:HTTPS_PROXY is not set."
            }
        }
    } catch {
        Write-Host "CheckAndResetProxy:Error: Failed to check or reset HTTPS_PROXY. $_" -fore Red
    }
}
function CheckProcessStatus {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ServerList,
        
        [Parameter(Mandatory=$true)]
        [string[]]$Processes
    )
    try {
        Write-Host "CheckProcessStatus:ServerList:$ServerList Processes:$Processes"
        Invoke-Command -ComputerName $ServerList -UseSSL -ScriptBlock { 
            param($Processes)
            Get-Process $Processes  | Select-Object Name, Id,StartTime| Sort-Object Id -Descending | Format-Table -AutoSize } -ArgumentList $Processes
    } catch {
        Write-Host "CheckProcessStatus:Error: Failed to check Process status. $_" -fore Red
    }
}

$ExitCode = 0
try{
    Write-Host "Processing Servers in ServerList:$ServerList Satrting"
    if ($env:CheckFMEServerStatus -eq "true") {
        # Checking FME Server Timesync from GCM DevSecOps Server
        CheckServerTimeSync -ServerList $ServerList
        # Checking FME Server for HTTPS_PROXY and resetting it
        CheckAndResetProxy -ServerList $ServerList
        # Checking FME Server Services Status 
        CheckServiceStatus -ServerList $ServerList -Services 'FME*'
        # Checking FME Server Process Status 
        CheckProcessStatus -ServerList $ServerList -Processes '*FME*'
    }
    if ($env:CheckFMEServerConnectivity -eq "true") {
        CheckSSLConnectivity -ServerList $ServerList -Hostname spring.gmdevops.sce.com -Port 443
        CheckSSLConnectivity -ServerList $ServerList -Hostname 172.28.154.40 -Port 445
        CheckSSLConnectivity -ServerList $ServerList -Hostname 172.16.88.29 -Port 445
        CheckSSLConnectivity -ServerList $ServerList -Hostname 172.28.143.26 -Port 8443
        CheckSSLConnectivity -ServerList $ServerList -Hostname 172.28.143.26 -Port 443
        CheckSSLConnectivity -ServerList $ServerList -Hostname 172.16.88.29 -Port 445
    } 
    if ($env:FMEServerReStart -eq "true") {
        # Restart FME Server Componenets 
        ServicesRestart -ServerList $ServerList -Services 'FME*'
    } 
    
    Write-Host "Processing Servers in ServerList:$ServerList Complete"
}
catch{
    Write-Host "Code:" $_.Exception.Response.StatusCode.value__ -fore Red
    Write-Host "Description:" $_.Exception.Response.StatusDescription -fore Red
    Write-Host "Response Content:" $_.Exception.Response.Content -fore Red
    $ExitCode = -1
}

Invoke-Command -ComputerName $ServerList -UseSSL -ScriptBlock { Get-Date } -ErrorAction Stop
# Sample code for uploading a file to remote server from Jenkins Server
Copy-Item –Path JenkinsFile/fme/gcm-fme-infrastructure-validation/gcmservervalidation.ps1 –Destination 'C:\winrmtest' –ToSession (New-PSSession –ComputerName iewvdnex01.sce.eix.com)
# Sample code for downloading a file to Jenkins server from remote Server
Copy-Item –Path C:\winrmtest\gcmservervalidation.ps1 –Destination 'C:\winrmtest' –FromSession (New-PSSession –ComputerName iewvdnex01.sce.eix.com)
Write-Host "Exit code:" $ExitCode
Exit $ExitCode