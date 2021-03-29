#Hostname
$FQDN = ([System.Net.Dns]::GetHostByName($ComputerName)).HostName

#Vars 
$Path = "C:\temp\wsus\wsus_logs"
$Daysback = "-180"
$CurrentDate = Get-Date
$from = "wsus-update@mediamarktsaturn.com"
$to = "glavelis@mediamarktsaturn.com"


#Retrieve CheckMK Host ID
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject



#Put Host in Maintenance Mode in CheckMK for 45mins and message "WSUS-patching planned downtime"
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=45&host=$checkmkHost"

#Wait for Webrequest to take effect
Start-Sleep -Seconds 60

#Run Patch install
$wsusinstall = Install-WindowsUpdate -AcceptAll -Install 

#Convert report to html
$wsusinstall | ConvertTo-Html -body "<H2>$FQDN Patch Update Report</H2>" | Out-File "$Path\$FQDN-$(get-date -f dd-MM-yyyy)-WindowsUpdate.html" -force

#Select latest log file
$latest = Get-ChildItem -Path  $Path  | Sort-Object LastAccessTime -Descending | Select-Object -First 1

$body = [System.IO.File]::ReadAllText("$Path\$latest")
$MailMessage = @{ 
    To = $to
    From = $from
    Subject = "$FQDN Update Report" 
    Body = "$body" 
    Smtpserver = 'smtprelay.media-saturn.com'
    ErrorAction = "SilentlyContinue" 
}
Send-MailMessage @MailMessage -bodyashtml


#Purge logs older than 180 day(s)

$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item