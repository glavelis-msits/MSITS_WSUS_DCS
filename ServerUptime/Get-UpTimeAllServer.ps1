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

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
 
#Write-Host "Current script directory is $ScriptDir"

function Get-UpTimeAllServer {

$servers= Get-Content "$ScriptDir\serverlist.txt"
$result=@()

Foreach ($s in $servers) {

Try {
$rebootpending = ((Get-WURebootStatus -ComputerName $s -Confirm:$false).RebootRequired)
$checkmkHost = Invoke-Command -ComputerName $s {(Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject}
$up=(Get-CimInstance -ClassName win32_operatingsystem -ComputerName $s -ErrorAction Stop).LastBootUpTime 
$uptime=((Get-Date) - $up)
$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -like "WSUS*"}).State}
$result+=New-Object -TypeName PSObject -Property ([ordered]@{
'Server'=$s
'CheckMK ID'=$checkmkHost
'LastBootUpTime'=$up
'Days'=$uptime.Days
'Hours'=$uptime.Hours
#'Minutes'=$uptime.Minutes
#'Seconds'=$uptime.Seconds
'WSUS Task' = $wsustask
'Reboot pending' = $rebootpending
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

 Get-UpTimeAllServer #| Out-File "E:\Scripts\ServerUptime\logs\$(get-date -f dd-MM-yyyy)-ServerUptime.log" -force

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');