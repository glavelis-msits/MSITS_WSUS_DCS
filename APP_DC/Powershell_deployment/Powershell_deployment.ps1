Clear-Host
Write-Verbose "MSITS Decentral APP-DC Powershell 5.1 deployment"

$computers = get-content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\APPlication_Deployment_serverlist.txt"
$source = "E:\Scripts\app_repo\Win8.1AndW2K12R2-KB3191564-x64.msu"
$destination = "c$\temp"
foreach ($computer in $computers) {
  <#   if (test-path -Path \\$computer\$destination) {
    Copy-Item $source -Destination \\$computer\$destination
} else {
    "\\$computer\$destination is not reachable or does not exist"
} #>

$source = "E:\Scripts\app_repo\Win8.1AndW2K12R2-KB3191564-x64.msu"
if (Test-Path $source -PathType leaf) 
{"Win8.1AndW2K12R2-KB3191564-x64.msu already Exists" } 
else
{copy-item -Path $source -Destination $destination -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


$computer
$checkmkHost = Invoke-Command -ComputerName $computer -ScriptBlock {(Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject}

Invoke-Command -ComputerName $computer -ScriptBlock {Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WMP51-upgrade%planned%downtime&_down_from_now=From+now+for&_down_minutes=60&host=$checkmkHost"}

Invoke-Command -ComputerName $computer -ScriptBlock {
#Start services shutdown
#Tibco Hawk Agent
Get-Process | Where-Object { $_.Name -eq "hawkagent_ESB-PRD-D01" } | Stop-Process -force
#Tibco BW-Engine
Get-Process | Where-Object { $_.ProcessName -eq "tibemsd" } | Stop-Process -force
#Wildfly
Get-Process | Where-Object { $_.Name -eq "nssm" } | Stop-Process -force
#Solid
Get-Process | Where-Object { $_.Name -eq "solid" } | Stop-Process -force

#Start-Process 'wusa.exe' -ArgumentList 'C:\temp\Win8.1AndW2K12R2-KB3191564-x64.msu', '/quiet', '/norestart'
Invoke-Command -ComputerName $computer {wusa.exe 'C:\temp\Win8.1AndW2K12R2-KB3191564-x64.msu' /quiet /norestart}

#Start-Sleep -Seconds 60#

Shutdown -r -t 120
	}

}