#This script is set to reboot the given Server at 04:00 of the next day.
#To change this, simply change the AddDays and the AddHours values respectively.
#Example 1: To set a Server for reboot at 18:00 of the following day, put AddDays(1) and AddHours(18)
#Example 2: To set a Server for reboot at 18:00 today, put AddDays(0) and AddHours(18)
#It is also necessary to alter the New-JobTrigger -Once -At 03:50pm value (usually 10 minutes before the scheduled reboot)

[string]$Title = 'MSITS Server Reboot Scheduler'
Clear-Host
    Write-Host "================ $Title ================"

$Server = Read-Host -Prompt 'Input server name to be rebooted:'




$Result = Invoke-Command -ComputerName $Server -ScriptBlock {
 

$ServerState = shutdown -r -t ([decimal]::round(((Get-Date).AddDays(1).Date.AddHours(4) - (Get-Date)).TotalSeconds))

Return $ServerState
}

<#Invoke-Command -ComputerName $Server {
Register-ScheduledJob -Name "Host_Reboot_Maintenance_Mode" -ScriptBlock {$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject ;
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=Scheduled%Server%reboot&_down_from_now=From+now+for&_down_minutes=30&host=$checkmkHost"

} -Trigger (New-JobTrigger -Once -At 03:50pm)

}#>

Invoke-Command -Computername $Server -ScriptBlock {Get-ScheduledTask -TaskName "Host_Reboot_Maintenance_Mode*" ; $LASTEXITCODE}

if ($LASTEXITCODE = 0){
  write-host "Reboot Job already exists" -ForegroundColor Green 
} else {
    Invoke-Command -ComputerName $Server { Register-ScheduledJob -Name "Host_Reboot_Maintenance_Mode" -ScriptBlock {$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject ;
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=Scheduled%Server%reboot&_down_from_now=From+now+for&_down_minutes=30&host=$checkmkHost"

} -Trigger (New-JobTrigger -Once -At 03:50pm)
}
}


Start-Sleep -Seconds 10

Invoke-Command -ComputerName $Server {Get-ScheduledJob | FT Name, Enabled}

$Result
Write-Host "Press any key to exit..."



