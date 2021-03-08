#Retrieve CheckMK Host ID
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

#Put the Host in Maintenance Mode in CheckMK for 15mins and message "Weekly planned maintenance reboot"
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=Weekly%planned%maintenance%reboot&_down_from_now=From+now+for&_down_minutes=15&host=$checkmkHost"

#Wait for the Webrequest to take effect
Start-Sleep -Seconds 60

#Reboot Server
Restart-Computer