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
$Title = 'MSITS DBA-DC Store Server WSUS Report'

# Create Serverlist
function DBAserverlist {

Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -force ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=AT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=BE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=CH,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=ES,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=GR,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=HK,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=HU,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=IT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=LU,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=NL,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=PL,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=PT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=RB,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=RO,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=SE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=TR,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;

$content_mm = Get-Content "$ScriptDir\DBAMM_DE_ServerList_temp.txt" ;
$content_mm | Foreach {$_.TrimEnd()} |  Set-Content "$ScriptDir\DBAMM_DE_ServerList.txt" ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBASE_DE_ServerList_temp.txt" -force ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=AT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=BE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=CH,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=ES,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=GR,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=HK,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=HU,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=IT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=LU,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=NL,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=PL,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=PT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=RB,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=RO,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=SE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=TR,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBAMM_DE_ServerList_temp.txt" -Append ;
$content_se = Get-Content "$ScriptDir\DBASE_DE_ServerList_temp.txt" ;
$content_se | Foreach {$_.TrimEnd()} |  Set-Content "$ScriptDir\DBASE_DE_ServerList.txt" ;
rm "$ScriptDir\DBAMM_DE_ServerList_temp.txt"
rm "$ScriptDir\DBASE_DE_ServerList_temp.txt"

# Build the file list
$outfile = "$ScriptDir\temp\merged.txt"
foreach ($file in $ScriptDir)
{

Get-ChildItem -Path $ScriptDir -Filter "*.txt" | Get-Content | select -Skip 1 | Out-File -FilePath $outfile -Encoding ascii;
   
}

Get-Content $outfile | ? {$_.trim() -ne "" } | set-content "$ScriptDir\merged_final.txt"
$stream = [IO.File]::OpenWrite('$ScriptDir\merged_final.txt')
$stream.SetLength($stream.Length - 1)
$stream.Close()
$stream.Dispose()
rm $outfile
rm "$ScriptDir\DBAMM_DE_ServerList.txt"
rm "$ScriptDir\DBASE_DE_ServerList.txt"
}


Clear-Host
Write-Host "================ $Title ================"

$PrevErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'silentlycontinue'

# Automatic Server list generation
<# DBAserverlist
$smp= Get-Content "$ScriptDir\merged_final.txt"  # Automatic list extraction  #>

# Manual server list selection
$smp= Get-Content "E:\Scripts\MSITS_WSUS_DCS\DBA\Waves\DBA_DE_Pilot.txt"

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

# Server online status
$p=Test-Connection -ComputerName $s -BufferSize 16  -Count 1 -Quiet 

# CheckMK Host ID
$checkmkHost = Invoke-Command -ComputerName $s {(Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject}

# WSUS Reboot pending status
$rebootpending = ((Get-WURebootStatus -ComputerName $s -Confirm:$false).RebootRequired)

# Reboot script
$DBA_powercycle_path = "\\$s\c$\tasks\DBA_DE_reboot.ps1"																						# Reboot Script verification
$DBA_powercycle = if (Test-Path $DBA_powercycle_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

# WSUS Update Script
$DBA_wsupdrb_path = "\\$s\c$\tasks\DBA_DE_wsus_local_update_reboot_v12.ps1"    																	# WSUS Update Script verification
$DBA_wsupdrb = if (Test-Path $DBA_wsupdrb_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

# Task Runonce
$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "DBA_Run_Once_Update_script"}).State}

#Task reboot
$wsustaskrb = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "DBA_DE_reboot"}).State}


# Powershell version check
$psversioncheck = Invoke-Command -ComputerName $s {$PSVersionTable.PSVersion.Major}

# Server Uptime
	
$bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $s -ErrorAction Continue).LastBootUpTime
$CurrentDate = Get-Date
$uptime = $CurrentDate - $bootuptime

#T able items creation
$infoObject|Add-Member -MemberType NoteProperty -Name "Hostname"  -value $s
$infoObject|Add-Member -MemberType NoteProperty -Name "CheckMK ID"  -value $checkmkHost
$infoObject|Add-Member -MemberType NoteProperty -Name "Reachable"  -value $p
$infoObject|Add-Member -MemberType NoteProperty -Name "Uptime Days"  -value $uptime.Days
$infoObject|Add-Member -MemberType NoteProperty -Name "Uptime Hours"  -value $uptime.Hours
$infoObject|Add-Member -MemberType NoteProperty -Name "Reboot Pending" -Value $rebootpending
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update script" -Value $DBA_wsupdrb
#$infoObject|Add-Member -MemberType NoteProperty -Name "Reboot Script" -Value $DBA_powercycle
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update Task" -Value $wsustask
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Reboot Task" -Value $wsustaskrb
$infoObject|Add-Member -MemberType NoteProperty -Name "Powershell version" -Value $psversioncheck

$results+=$infoObject
}

########################## Start Report Generation  ##########################

$results|Export-csv "$ScriptDir\temp_DBA.csv" -NoTypeInformation 
Import-CSV "$ScriptDir\temp_DBA.csv" | ConvertTo-Html -Head $css  | Out-File "$ScriptDir\DBADC_DE_Report-$(get-date -f dd-MM-yyyy).html" 
rm "$ScriptDir\temp_DBA.csv"
rm "$ScriptDir\merged_final.txt"