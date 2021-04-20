param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit
}

'Running with Elevated Admin privileges'

# Determine running dir
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

# Create Serverlist
function APPserverlist {
$de_app = Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=Domain Controllers,DC=mmsrg,DC=net" -Properties IPv4Address | FT DNSHostName -A -HideTableHeaders | Out-File "$ScriptDir\APP_DE_ServerList_temp_2.txt" -force ;
$b = Get-Content -Path $ScriptDir\APP_DE_ServerList_temp_2.txt ;
@(ForEach ($a in $b) {$a.Replace(' ', '')}) > $ScriptDir\APP_DE_ServerList_temp_1.txt ;
Get-Content "$ScriptDir\APP_DE_ServerList_temp_1.txt" | Select-Object -Skip 1 | Out-File "$ScriptDir\APP_DE_ServerList_temp.txt" -force ;
rm "$ScriptDir\APP_DE_ServerList_temp_2.txt" -Force;
rm "$ScriptDir\APP_DE_ServerList_temp_1.txt" -Force;
}

#
function Get-UpTimeAllServer {

#$servers= Get-Content "$ScriptDir\FQDNList.txt"
$servers= Get-Content "$ScriptDir\APP_DE_ServerList_temp.txt" 
#$servers= Get-Content $latest_APP_de_path\$latest_APP_de_list


$result=@()

Foreach ($s in $servers) {

Try {
# Reboot pending
$rebootpending = ((Get-WURebootStatus -ComputerName $s -Confirm:$false).RebootRequired)
# CheckMK Host ID
$checkmkHost = Invoke-Command -ComputerName $s {(Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject}

#Uptime Calculations
$up=(Get-CimInstance -ClassName win32_operatingsystem -ComputerName $s -ErrorAction Stop).LastBootUpTime 
$uptime=((Get-Date) - $up)

# Reboot Script
$APP_powercycle_path = "\\$s\c$\tasks\APP_DE_reboot.ps1"
$APP_powercycle = if (Test-Path $APP_powercycle_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

#PSVersion
$psversioncheck = Invoke-Command -ComputerName $s {$PSVersionTable.PSVersion.Major}

# WSUS Update Script
$APP_wsupdrb_path = "\\$s\c$\tasks\APP_DE_wsus_local_update_reboot.ps1"
$APP_wsupdrb = if (Test-Path $APP_wsupdrb_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

# WSUS Update Scheduled Task
$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "APP_DE_reboot"}).State}
# Reboot Scheduled Task 
$wsustask2 = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "APP_DE_Test_Group_WSUS_Monthly_Update"}).State}

$result+=New-Object -TypeName PSObject -Property ([ordered]@{
############## Report Options (comment-out what is not needed) ##############
  'Server'=$s                             # Server FQDN
  'CheckMK ID'=$checkmkHost               # CheckMK Host ID
  #'LastBootUpTime'=$up                    # Last recorded bootuptime
  'Days'=$uptime.Days                     # Uptime Days
  'Hours'=$uptime.Hours                   # Uptime Hours
  #'Minutes'=$uptime.Minutes               # Uptime minutes
  #'Seconds'=$uptime.Seconds               # Uptime seconds
  'Reboot scr' = $APP_powercycle          # Reboot Script presence
  'Upd scr' = $APP_wsupdrb                # WSUS Update Script presence
  'WSUS T' = $wsustask                    # WSUS Update Scheduled Task presence
  'Reboot T' = $wsustask2                 # Reboot Scheduled Task Presence
  'Pending' = $rebootpending              # Reboot pending
  'PS Ver' = $psversioncheck              # Powershell Version
})
}
Catch {

$result+=New-Object -TypeName PSObject -Property ([ordered]@{
'Server'=$s
'LastBootUpTime'='Server could not be reached'
})

}


}
Write-Output $result | Format-Table -AutoSize

}

########################## Start Report Generation  ##########################
$reportstart = (Get-Date) 																					# Get Start Time
APPserverlist                                                                                              	# Create Servelist
#Get-UpTimeAllServer                                                                                       	# Debug Mode
Get-UpTimeAllServer | Out-File "$ScriptDir\logs\$(get-date -f dd-MM-yyyy)-APP_DE_ServerReport.log" -force  	# Output Report
rm "$ScriptDir\APP_DE_ServerList_temp.txt" -force                                                          	# Remove list (upkeep)
$reportend = (Get-Date) 																					# Get End Time
"Elapsed Time: $(($reportend-$reportstart).totalminutes) minutes"  											# Echo Time elapsed
Write-Host -NoNewLine 'Press any key to continue...';                                                     
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');