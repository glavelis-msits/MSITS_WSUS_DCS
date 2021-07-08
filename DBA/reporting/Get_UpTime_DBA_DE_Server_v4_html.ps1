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
$content_mm = Get-Content "$ScriptDir\DBAMM_DE_ServerList_temp.txt" ;
$content_mm | Foreach {$_.TrimEnd()} |  Set-Content "$ScriptDir\DBAMM_DE_ServerList.txt" ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "$ScriptDir\DBASE_DE_ServerList_temp.txt" -force ;
$content_se = Get-Content "$ScriptDir\DBASE_DE_ServerList_temp.txt" ;
$content_se | Foreach {$_.TrimEnd()} |  Set-Content "$ScriptDir\DBASE_DE_ServerList.txt" ;
rm "$ScriptDir\DBAMM_DE_ServerList_temp.txt"
rm "$ScriptDir\DBASE_DE_ServerList_temp.txt"

# Build the file list
$outfile = "$ScriptDir\temp\merged.txt"
foreach ($file in $ScriptDir)
{

Get-ChildItem -Path $ScriptDir -Filter "*.txt" | Get-Content | select -Skip 1 | Out-File -FilePath $outfile -Encoding ascii -DBAend;
   
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

#
<# function Get-UpTimeAllServer {

#$servers= Get-Content "$ScriptDir\FQDNList.txt"
$servers= Get-Content "$ScriptDir\merged_final.txt" 
#$servers= Get-Content $latest_DBA_de_path\$latest_DBA_de_list


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
$DBA_powercycle_path = "\\$s\c$\tasks\DBA_DE_reboot.ps1"
$DBA_powercycle = if (Test-Path $DBA_powercycle_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

#PSVersion
$psversioncheck = Invoke-Command -ComputerName $s {$PSVersionTable.PSVersion.Major}

# WSUS Update Script
$DBA_wsupdrb_path = "\\$s\c$\tasks\DBA_DE_wsus_local_update_reboot.ps1"
$DBA_wsupdrb = if (Test-Path $DBA_wsupdrb_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

# WSUS Update Scheduled Task
$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "DBA_DE_reboot"}).State}
# Reboot Scheduled Task 
$wsustask2 = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "DBA_DE_Test_Group_WSUS_Monthly_Update"}).State}

$result+=New-Object -TypeName PSObject -Property ([ordered]@{
############## Report Options (comment-out what is not needed) ##############
  'Server'=$s                             # Server FQDN
  'CheckMK ID'=$checkmkHost               # CheckMK Host ID
  #'LastBootUpTime'=$up                    # Last recorded bootuptime
  'Days'=$uptime.Days                     # Uptime Days
  'Hours'=$uptime.Hours                   # Uptime Hours
  #'Minutes'=$uptime.Minutes               # Uptime minutes
  #'Seconds'=$uptime.Seconds               # Uptime seconds
  'Reboot scr' = $DBA_powercycle          # Reboot Script presence
  'Upd scr' = $DBA_wsupdrb                # WSUS Update Script presence
  'WSUS T' = $wsustask                    # WSUS Update Scheduled Task presence
  'Reboot T' = $wsustask2                 # Reboot Scheduled Task Presence
  #'Pending' = $rebootpending              # Reboot pending
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

} #>

####################################################################################################################################################################


Clear-Host
Write-Host "================ $Title ================"

$PrevErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'silentlycontinue'

DBAserverlist


$smp= Get-Content "$ScriptDir\merged_final.txt"  # Automatic list extraction 
#$smp= Get-Content "$ScriptDir\DBAlication_Deployment_serverlist.txt"

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

$DBA_powercycle_path = "\\$s\c$\tasks\DBA_DE_reboot.ps1"								# Reboot Script verification
$DBA_powercycle = if (Test-Path $DBA_powercycle_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

$DBA_wsupdrb_path = "\\$s\c$\tasks\DBA_DE_wsus_local_update_reboot.ps1"    				# WSUS Update Script verification
$DBA_wsupdrb = if (Test-Path $DBA_wsupdrb_path -PathType leaf) 
{"Exists"}
else
{"Missing"}

$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "DBA_DE_Test_Group_WSUS_Monthly_Update"}).State}

$wsustaskrb = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "DBA_DE_reboot"}).State}

$Boottime= Get-WmiObject win32_operatingsystem 
$b=($boottime| select @{LABEL= "LastBootUpTime";EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}).Lastbootuptime


$psversioncheck = Invoke-Command -ComputerName $s {$PSVersionTable.PSVersion.Major}

$up={ 
   Try {((Get-CimInstance -ClassName win32_operatingsystem -ComputerName $s -ErrorAction Stop).LastBootUpTime)
    } Catch {
        # Do nothing
    }}
$uptime=((Get-Date) - $up)

$infoObject|Add-Member -MemberType NoteProperty -Name "Hostname"  -value $s
$infoObject|Add-Member -MemberType NoteProperty -Name "CheckMK ID"  -value $checkmkHost
$infoObject|Add-Member -MemberType NoteProperty -Name "Reachable"  -value $p
$infoObject|Add-Member -MemberType NoteProperty -Name "Uptime Days"  -value $uptime.Days
$infoObject|Add-Member -MemberType NoteProperty -Name "Uptime Hours"  -value $uptime.Hours
$infoObject|Add-Member -MemberType NoteProperty -Name "Reboot Pending" -Value $rebootpending
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update script" -Value $DBA_wsupdrb
$infoObject|Add-Member -MemberType NoteProperty -Name "Reboot Script" -Value $DBA_powercycle
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update Task" -Value $wsustask
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Reboot Task" -Value $wsustaskrb
$infoObject|Add-Member -MemberType NoteProperty -Name "Powershell version" -Value $psversioncheck

$results+=$infoObject
}

<# ########################## Start Report Generation  ##########################
#$reportstart = (Get-Date)                                        																					# Get Start Time
DBAserverlist                                                                                              	# Create Servelist
#Get-UpTimeAllServer                                                                                       	# Debug Mode
Get-UpTimeAllServer | Out-File "$ScriptDir\logs\$(get-date -f dd-MM-yyyy)-DBA_DE_ServerReport.log" -force  	# Output Report
rm "$ScriptDir\merged_final.txt" -force                                                          	# Remove list (upkeep)
#$reportend = (Get-Date) 																					                                          # Get End Time
#"Elapsed Time: $(($reportend-$reportstart).totalminutes) minutes"                    											# Echo Time elapsed
#Write-Host -NoNewLine 'Press any key to continue...';                                                     
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); #>

$results|Export-csv "$ScriptDir\temp_DBA.csv" -NoTypeInformation 
Import-CSV "$ScriptDir\temp_DBA.csv" | ConvertTo-Html -Head $css  | Out-File "$ScriptDir\DBADC_DE_Report-$(get-date -f dd-MM-yyyy).html" 
rm "$ScriptDir\temp_DBA.csv"
rm "$ScriptDir\merged_final.txt"