function ServiceRestart {
    param (
        [string[]]$ServerList
    )
    try {
        Write-Host "ServerList:$ServerList"
        Write-Host "Services:$Services"
        Invoke-Command -ComputerName $ServerList -UseSSL -ScriptBlock { 
            param($Services)
            Get-Service | Where-Object { $_.DisplayName -like "$Services" } | ForEach-Object {
                $service = $_
                $name = $service.Name
                $status=$service.Status
                Write-Output "Service '$name' is '$status' in  '$($env:COMPUTERNAME)'"
                If($status -eq "Stopped"){
                    Start-Service -Name $name
                    $service=Get-Service -Name $name
                    $status=$service.Status
                    Write-Output "Service '$name' is '$status' in  '$($env:COMPUTERNAME)'"
                }
            }
        } -ArgumentList $Services
    }
    catch {
        Write-Host "Failed to restart the services" -fore Red
    }
}    

#Method Starting
param (
   [string[]]$ServerList    
)
try{ 
    Write-Host "Processing Servers in ServerList:$ServerList Started"
    ServiceRestart -ServerList $ServerList
    Write-Host "Processing Servers in ServerList:$ServerList Completed"
} catch {
    Write-Host "Processing Servers in ServerList:$ServerList Failed"
}