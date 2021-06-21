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

#Vars
$servers= Get-Content "$ScriptDir\DBA_DE_W1_Test.txt"

#Write-Host "Current script directory is $ScriptDir"

function Get-UpTimeAllServer {


$result=@()

Foreach ($s in $servers) {

Try {
$rebootpending = ((Get-WURebootStatus -ComputerName $s -Confirm:$false).RebootRequired)
$checkmkHost = Invoke-Command -ComputerName $s {(Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject}
$up=(Get-CimInstance -ClassName win32_operatingsystem -ComputerName $s -ErrorAction Stop).LastBootUpTime 
$uptime=((Get-Date) - $up)

<# #Reboot Script
$app_powercycle_path = "\\$s\c$\tasks\APP_DE_reboot.ps1"
$app_powercycle = if (Test-Path $app_powercycle_path -PathType leaf) 
{"Exists"}
else
{"Missing"} #>

#Update Script
$app_wsupdrb_path = "\\$s\c$\tasks\DBA_DE_wsus_local_update_reboot.ps1"
$app_wsupdrb = if (Test-Path $app_wsupdrb_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

#Verify Task existense
$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "DBA_DE_W1_Test_WSUS_Monthly_Update"}).State}

#PSVersion
$psversioncheck = Invoke-Command -ComputerName $s {$PSVersionTable.PSVersion.Major}

#Create List
$result+=New-Object -TypeName PSObject -Property ([ordered]@{
'Server'=$s
'CheckMK ID'=$checkmkHost
'LastBootUpTime'=$up
'Days'=$uptime.Days
#'Hours'=$uptime.Hours
#'Minutes'=$uptime.Minutes
#'Seconds'=$uptime.Seconds
#'Reboot scr' = $app_powercycle #Reboot Script presence
'Upd scr' = $app_wsupdrb # Update Script presence
'WSUS T' = $wsustask #WSUS Task presence
#'Reboot T' = $wsustask2 #Reboot Task Presence
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
#Get-UpTimeAllServer
Get-UpTimeAllServer | Out-File "$ScriptDir\logs\$(get-date -f dd-MM-yyyy)-DBA_DE_W1_Test.log" -force
#Get-UpTimeAllServer |  ConvertTo-Html | Out-File "$ScriptDir\logs\$(get-date -f dd-MM-yyyy)-ServerUptime.html" -force
#Get-UpTimeAllServer | Export-Csv -Path "$ScriptDir\logs\$(get-date -f dd-MM-yyyy)-ServerUptime.csv" -Encoding ascii -NoTypeInformation

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');