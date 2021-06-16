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

#Determine running dir
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
 
#Create Serverlist
$de_trm = Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=TRM,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties IPv4Address | FT DNSHostName -A -HideTableHeaders | Out-File "$ScriptDir\TRM_DE_ServerList_temp_2.txt" -force ;
$b = Get-Content -Path $ScriptDir\TRM_DE_ServerList_temp_2.txt ;
@(ForEach ($a in $b) {$a.Replace(' ', '')}) > $ScriptDir\TRM_DE_ServerList_temp_1.txt ;
Get-Content "$ScriptDir\TRM_DE_ServerList_temp_1.txt" | Select-Object -Skip 1 | Out-File "$ScriptDir\TRM_DE_ServerList_temp.txt" -force ;
rm "$ScriptDir\TRM_DE_ServerList_temp_2.txt" -Force;
rm "$ScriptDir\TRM_DE_ServerList_temp_1.txt" -Force;

function Get-UpTimeAllServer {

#$servers= Get-Content "$ScriptDir\FQDNList.txt"
$servers= Get-Content "$ScriptDir\TRM_DE_ServerList_temp.txt" 
#$servers= Get-Content $latest_trm_de_path\$latest_trm_de_list
$result=@()

Foreach ($s in $servers) {

Try {
$rebootpending = ((Get-WURebootStatus -ComputerName $s -Confirm:$false).RebootRequired)
$checkmkHost = Invoke-Command -ComputerName $s {(Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject}

$up=(Get-CimInstance -ClassName win32_operatingsystem -ComputerName $s -ErrorAction Stop).LastBootUpTime 

$uptime=((Get-Date) - $up)

$trm_powercycle_path = "\\$s\c$\tasks\TRM_weekly_powercycle.ps1"

$trm_powercycle = if (Test-Path $trm_powercycle_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

#PSVersion
$psversioncheck = Invoke-Command -ComputerName $s {$PSVersionTable.PSVersion.Major}

$trm_wsupdrb_path = "\\$s\c$\tasks\TRM_wsus_local_update_reboot.ps1"

$trm_wsupdrb = if (Test-Path $trm_wsupdrb_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "TRM WSUS Weekly Update"}).State}

$wsustask2 = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "TRM_weekly_powercycle"}).State}

$result+=New-Object -TypeName PSObject -Property ([ordered]@{
  'Server'=$s
  'CheckMK ID'=$checkmkHost
  #'LastBootUpTime'=$up
  'Days'=$uptime.Days
  'Hours'=$uptime.Hours
  #'Minutes'=$uptime.Minutes
  #'Seconds'=$uptime.Seconds
  'Reboot scr' = $trm_powercycle #Reboot Script presence
  'Upd scr' = $trm_wsupdrb # Update Script presence
  'WSUS T' = $wsustask #WSUS Task presence
  'Reboot T' = $wsustask2 #Reboot Task Presence
  'Pending' = $rebootpending #Reboot pending
  'PS Ver' = $psversioncheck #PS Version
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

#Get-UpTimeAllServer #Debug Mode
#Get-UpTimeAllServer | Out-File "$ScriptDir\logs\$(get-date -f dd-MM-yyyy)-TRM_DE_ServerInfo.log" -force
Get-UpTimeAllServer |  ConvertTo-Html | Out-File "$ScriptDir\logs\$(get-date -f dd-MM-yyyy)-ServerUptime.html" -force
#Get-UpTimeAllServer | Export-Csv -Path "$ScriptDir\logs\$(get-date -f dd-MM-yyyy)-ServerUptime.csv" -Encoding ascii -NoTypeInformation

#rm "$ScriptDir\TRM_DE_ServerList_temp.txt" -force
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');