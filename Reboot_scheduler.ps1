#This script is set to reboot the given Server at 04:00 of the next day.
#To change this, simply change the AddDays and the AddHours values respectively.
#Example 1: To set a Server for reboot at 18:00 of the following day, put AddDays(1) and AddHours(18)
#Example 2: To set a Server for reboot at 18:00 today, put AddDays(0) and AddHours(18)


[string]$Title = 'MSITS Server Reboot Scheduler'
Clear-Host
    Write-Host "================ $Title ================"

$Server = Read-Host -Prompt 'Input server name to be rebooted:'

$Result = Invoke-Command -ComputerName $Server -ScriptBlock {

$ServerState = shutdown -r -t ([decimal]::round(((Get-Date).AddDays(1).Date.AddHours(4) - (Get-Date)).TotalSeconds))

Return $ServerState
}

$Result
Write-Host "Press any key to exit..."