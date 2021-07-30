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
$Title = 'MSITS TRM Store Server WSUS Report'

# Create Serverlist
function TRMserverlist {
    $de_trm = Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=TRM,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties IPv4Address | FT DNSHostName -A -HideTableHeaders | Out-File "$ScriptDir\TRM_DE_ServerList_temp_2.txt" -force ;
    $b = Get-Content -Path $ScriptDir\TRM_DE_ServerList_temp_2.txt ;
    @(ForEach ($a in $b) {$a.Replace(' ', '')}) > $ScriptDir\TRM_DE_ServerList_temp_1.txt ;
    Get-Content "$ScriptDir\TRM_DE_ServerList_temp_1.txt" | Select-Object -Skip 1 | Out-File "$ScriptDir\TRM_DE_ServerList_final.txt" -force ;
    rm "$ScriptDir\TRM_DE_ServerList_temp_2.txt" -Force;
    rm "$ScriptDir\TRM_DE_ServerList_temp_1.txt" -Force;
}

#


####################################################################################################################################################################


Clear-Host
Write-Host "================ $Title ================"

$PrevErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'silentlycontinue'

############ Automatic list extraction #############################
#TRMserverlist
#$smp= Get-Content "$ScriptDir\TRM_DE_ServerList_final.txt"  

############ Manual list  #############################
$smp= Get-Content "$ScriptDir\TRM_DE_ServerList_temp.txt"

$infoObject=@()
$results=@()
foreach($s in $smp)
{
$s
$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
$infoObject = New-Object PSObject
$p=Test-Connection -ComputerName $s -BufferSize 16  -Count 1 -Quiet 
$checkmkHost = Invoke-Command -ComputerName $s {(Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject}
$rebootpending = ((Get-WURebootStatus -ComputerName $s -Confirm:$false).RebootRequired)

$powercycle_path = "\\$s\c$\tasks\TRM_weekly_powercycle.ps1"								# Reboot Script verification
$powercycle = if (Test-Path $powercycle_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

$wsupdrb_path = "\\$s\c$\tasks\TRM_wsus_local_update_reboot.ps1"    				# WSUS Update Script verification
$wsupdrb = if (Test-Path $wsupdrb_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "TRM WSUS Weekly Update"}).State}

$wsustaskrb = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "TRM_weekly_powercycle"}).State}

$psversioncheck = Invoke-Command -ComputerName $s {$PSVersionTable.PSVersion.Major}

$bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $s -ErrorAction Continue).LastBootUpTime
$CurrentDate = Get-Date
$uptime = $CurrentDate - $bootuptime

$infoObject|Add-Member -MemberType NoteProperty -Name "Hostname"  -value $s
$infoObject|Add-Member -MemberType NoteProperty -Name "CheckMK ID"  -value $checkmkHost
$infoObject|Add-Member -MemberType NoteProperty -Name "Reachable"  -value $p
$infoObject|Add-Member -MemberType NoteProperty -Name "Uptime Days"  -value $uptime.Days
$infoObject|Add-Member -MemberType NoteProperty -Name "Uptime Hours"  -value $uptime.Hours
$infoObject|Add-Member -MemberType NoteProperty -Name "Reboot Pending" -Value $rebootpending
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update script" -Value $wsupdrb
$infoObject|Add-Member -MemberType NoteProperty -Name "Reboot Script" -Value $powercycle
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update Task" -Value $wsustask
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Reboot Task" -Value $wsustaskrb
$infoObject|Add-Member -MemberType NoteProperty -Name "Powershell version" -Value $psversioncheck

$results+=$infoObject
}


$results|Export-csv "$ScriptDir\temp_TRM.csv" -NoTypeInformation 
Import-CSV "$ScriptDir\temp_TRM.csv" | ConvertTo-Html -Head $css  | Out-File "$ScriptDir\TRM_Report-$(get-date -f dd-MM-yyyy).html" 
rm "$ScriptDir\temp_TRM.csv"
rm "$ScriptDir\TRM_DE_ServerList_final.txt"