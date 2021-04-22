#Retrieve CheckMK Host ID
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

#Put the Host in Maintenance Mode in CheckMK for 45mins and message "WSUS-patching planned downtime"
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=45&host=$checkmkHost"

#Wait for the Webrequest to take effect
Start-Sleep -Seconds 60

#Start services shutdown
#Tibco Hawk Agent
Get-Process | Where-Object { $_.Name -eq "hawkagent_ESB-PRD-D01" } | Stop-Process -force
#Tibco BW-Engine
Get-Process | Where-Object { $_.ProcessName -eq "tibemsd" } | Stop-Process -force
#Wildfly
Get-Process | Where-Object { $_.Name -eq "nssm" } | Stop-Process -force
#Solid
Get-Process | Where-Object { $_.Name -eq "solid" } | Stop-Process -force

#Wait for SolidDB to shutdown
Start-Sleep -Seconds 30

#Reboot the Server
shutdown.exe /r /t 30