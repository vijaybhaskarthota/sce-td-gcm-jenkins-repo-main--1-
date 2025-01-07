# Read the config file and convert from JSON
$config = Get-Content -Path 'remoteExecuteConfig.json' | ConvertFrom-Json

$intermediateServer = $config.intermediateServer
$remoteServer = $config.server
$commands = @(
    #Sample Command to get Process Details
    #"Get-Process '*FME*' | Select-Object Name, Id,StartTime| Sort-Object Id -Descending | Format-Table -AutoSize",
    #Sample Command to get Service Details
    #"Get-Service '*FME*'| Sort-Object status -Descending | Format-Table -AutoSize"
    #Sample Command to get list of all files
    "Get-ChildItem -Path 'E:\GCM_Scripts\'"  
)
$DebugPreference = 'Continue'
# Get the credential from the config file
Write-Debug "Getting credentials from config file"
$securePassword = ConvertTo-SecureString -String $config.password -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $config.username, $securePassword
# Connect to the intermediate server
Write-Debug "Connecting to intermediate server $intermediateServer"
Invoke-Command -ComputerName $intermediateServer -Credential $credential -UseSSL -ScriptBlock {
    param($remoteServer, $commands, [PSCredential] $credential,$DebugPreference)
    Write-Debug "Executing commands on intermediate server $intermediateServer"
    
    # Sample code for downloading a file to Jenkins server from remote Server
    Copy-Item -Path 'E:\GCM_Scripts' -Destination 'E:\BuildServer\FME-Redwood' -FromSession (New-PSSession -ComputerName $remoteServer -Credential $credential -UseSSL) -Recurse

    # Connect from the intermediate server to the remote server
    Write-Debug "Connecting to remote server $remoteServer"
    Invoke-Command -ComputerName $remoteServer -Credential $credential -UseSSL -ScriptBlock {
        param($remoteServer, $commands,$debugPreference)
        foreach ($command in $commands) {
            Write-Debug "Executing command: $command on $remoteServer"
            Invoke-Expression $command
        }
    } -ArgumentList $remoteServer,$commands,$DebugPreference
} -ArgumentList $remoteServer, $commands, $credential,$DebugPreference


