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
$Title = 'MSITS APP-DC Store Server WSUS Report'

# Create Serverlist
function APPserverlist {

Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04APPMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\APPMM_DE_ServerList_temp.txt" -force ;
$content_mm = Get-Content "$ScriptDir\APPMM_DE_ServerList_temp.txt" ;
$content_mm | Foreach {$_.TrimEnd()} |  Set-Content "$ScriptDir\APPMM_DE_ServerList.txt" ;
Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04APPSE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\APPSE_DE_ServerList_temp.txt" -force ;
$content_se = Get-Content "$ScriptDir\APPSE_DE_ServerList_temp.txt" ;
$content_se | Foreach {$_.TrimEnd()} |  Set-Content "$ScriptDir\APPSE_DE_ServerList.txt" ;
rm "$ScriptDir\APPMM_DE_ServerList_temp.txt"
rm "$ScriptDir\APPSE_DE_ServerList_temp.txt"

# Build the file list
$outfile = "$ScriptDir\temp\merged.txt"
foreach ($file in $ScriptDir)
{

Get-ChildItem -Path $ScriptDir -Filter "*.txt" | Get-Content | select -Skip 1 | Out-File -FilePath $outfile -Encoding ascii -Append;
   
}

Get-Content $outfile | ? {$_.trim() -ne "" } | set-content "$ScriptDir\merged_final.txt"
$stream = [IO.File]::OpenWrite('$ScriptDir\merged_final.txt')
$stream.SetLength($stream.Length - 1)
$stream.Close()
$stream.Dispose()
rm $outfile
rm "$ScriptDir\APPMM_DE_ServerList.txt"
rm "$ScriptDir\APPSE_DE_ServerList.txt"
}



####################################################################################################################################################################


Clear-Host
Write-Host "================ $Title ================"

$PrevErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'silentlycontinue'

#### Automatic List generation #####
<# APPserverlist
$smp= Get-Content "$ScriptDir\merged_final.txt"  # Automatic list extraction  #>

#### Manual List setting ####
$smp= Get-Content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\APPlication_Deployment_serverlist.txt"

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

$APP_powercycle_path = "\\$s\c$\tasks\APP_DE_reboot.ps1"								# Reboot Script verification
$APP_powercycle = if (Test-Path $APP_powercycle_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

$APP_wsupdrb_path = "\\$s\c$\tasks\APP_DE_wsus_local_update_reboot_v12.ps1"    				# WSUS Update Script verification
$app_wsupdrb = if (Test-Path $APP_wsupdrb_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "APP_DE_Test_Group_WSUS_Monthly_Update"}).State}

$wsustaskrb = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "APP_DE_Run Once Update script"}).State}

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
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update script" -Value $app_wsupdrb
#$infoObject|Add-Member -MemberType NoteProperty -Name "Reboot Script" -Value $app_powercycle
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update Task" -Value $wsustask
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Reboot Task" -Value $wsustaskrb
$infoObject|Add-Member -MemberType NoteProperty -Name "Powershell version" -Value $psversioncheck

$results+=$infoObject
}


$results|Export-csv "$ScriptDir\temp_APP.csv" -NoTypeInformation 
Import-CSV "$ScriptDir\temp_APP.csv" | ConvertTo-Html -Head $css  | Out-File "$ScriptDir\APPDC_DE_Report-$(get-date -f dd-MM-yyyy).html" 
rm "$ScriptDir\temp_APP.csv"
rm "$ScriptDir\merged_final.txt"