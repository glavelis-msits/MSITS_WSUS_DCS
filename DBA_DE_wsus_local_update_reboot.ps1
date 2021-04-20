#Retrieve CheckMK Host ID
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

#Hostname
$FQDN = ([System.Net.Dns]::GetHostByName($ComputerName)).HostName

#Put the Host in Maintenance Mode in CheckMK for 45mins and message "WSUS-patching planned downtime"
Clear-Host
Write-Host "========== Entering CheckMK Maintenance Mode   ============="
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=45&host=$checkmkHost"

#Wait for the Webrequest to take effect
Start-Sleep -Seconds 60

#Start services shutdown
#Tibco Hawk Agent
 Write-Host "================ Shutting down Hawk Agent  ================"
Get-Process | Where-Object { $_.Name -eq "hawkagent_ESB-PRD-D01" } | Stop-Process -force
#Tibco BW-Engine
 Write-Host "================ Shutting down BW Engine   ================"
Get-Process | Where-Object { $_.ProcessName -eq "tibemsd" } | Stop-Process -force
#Wildfly
 Write-Host "================ Shutting down Wildfly     ================"
Get-Process | Where-Object { $_.Name -eq "nssm" } | Stop-Process -force

 Write-Host "================ Shutting down Solid 1313  ================"
solsql "tcp 1313" TA_MON_ITSMT 3SpvPrt4 C:\tasks\1313.sql | Out-File C:\temp\wsus\wsus_logs\$FQDN-$(get-date -f dd-MM-yyyy)-SolDB_1313_log.txt

#Wait for SolidDB 1313 to shutdown
Start-Sleep -Seconds 30

 Write-Host "================ Shutting down Solid 1414 ================"
solsql "tcp 1414" TA_MON_ITSMT 3SpvPrt4 C:\tasks\1414.sql | Out-File C:\temp\wsus\wsus_logs\$FQDN-$(get-date -f dd-MM-yyyy)-SolDB_1414_log.txt

#Wait for SolidDB 1414 to shutdown
Start-Sleep -Seconds 30


#Run Patch install
Write-Host "================    WSUS update begin      ================"

Install-WindowsUpdate -AcceptAll -Install -AutoReboot  | Out-File "C:\temp\wsus\wsus_logs\$FQDN-$(get-date -f dd-MM-yyyy)-WindowsUpdate.log" -force

#Purge logs older than 180 day(s)
$Path = "C:\temp\wsus\wsus_logs"
$Daysback = "-180"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item