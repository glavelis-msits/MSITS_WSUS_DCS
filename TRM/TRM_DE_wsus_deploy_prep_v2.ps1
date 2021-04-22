Clear-Host
#Vars
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$sourcePath_PSWU = "$ScriptDir\PSWindowsUpdate"
$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"
$sourcePath_wsus_local_update_noreboot = "$ScriptDir\TRM_wsus_local_update_reboot.ps1"
$destPath_wsus_local_update_noreboot = "C:\tasks"
$sourcePath_WSUS_Update_check_xml = "$ScriptDir\TRM_WSUS_Weekly_Update.xml"
$destPath_WSUS_Update_check_xml = "C:\temp\wsus"
$sourcePath_TRM_weekly_powercycle_xml = "$ScriptDir\TRM_weekly_powercycle.xml"
$destPath_TRM_weekly_powercycle_xml = "C:\temp\wsus"
$sourcePath_TRM_weekly_powercycle = "$ScriptDir\TRM_weekly_powercycle.ps1"
$destPath_TRM_weekly_powercycle = "C:\tasks"
#$servers = "$ScriptDir\FQDNList.txt"
$latest_trm_de_path = "$ScriptDir\Reporting\ServerUptime\DE_serverlists_reports"            #Server List path
$latest_trm_de_list = (Get-ChildItem -Path $latest_trm_de_path -filter *clean*TRM* | Sort-Object LastAccessTime -Descending | Select-Object -First 1).Name # Select the latest TRM list
#$servers = "$latest_trm_de_path\$latest_trm_de_list"
$servers = "$ScriptDir\TRM_DE_temp.txt"


#Create Destination Folders
Get-Content $servers| ForEach-Object {
Invoke-Command -ComputerName "$_" -ScriptBlock {
$Path="C:\tasks"
    if (!(Test-Path $Path))
    {
    New-Item -ItemType Directory -Force -Path C:\tasks
    }
    else
    {
    write-host "Tasks folder already exists" -ForegroundColor Green 
    } ;

$Path="C:\temp\wsus"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus
}
else
{
write-host "WSUS folder already exists" -ForegroundColor Green 
} ;

$Path="C:\temp\wsus\wsus_logs"
if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus\wsus_logs
}
else
{
write-host "WSUS logs folder already exists" -ForegroundColor Green 
} ;


}
    }


Get-Content $servers | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
# Copy PSwindowsUpdate Module
$Path="C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"

if (!(Test-Path $Path))
{
copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -ErrorAction SilentlyContinue
}
else
{
write-host "PSwindowsUpdate Module already exists" -ForegroundColor Green 
} ;
	
# Copy PSwindowsUpdate update script 	
$trm_de_wsus_upd = "C:\tasks\TRM_wsus_local_update_reboot.ps1"
if (Test-Path $trm_de_wsus_upd -PathType leaf) 
{"WSUS update script Exists" } 
else
{copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

# Copy TRM_WSUS_Weekly_Update_xml
$trm_de_update_xml = "C:\temp\wsus\TRM_WSUS_Weekly_Update.xml"
if (Test-Path $trm_de_update_xml -PathType leaf) 
{"Update Task xml exists"  } 
else
{copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;
}


# Copy TRM_weekly_powercycle script	
$trm_de_reboot_path = "C:\tasks\TRM_weekly_powercycle.ps1"
if (Test-Path $trm_de_reboot_path -PathType leaf) 
{"Server reboot script exists" } 
else	
{copy-item -Path $sourcePath_TRM_weekly_powercycle -Destination $destPath_TRM_weekly_powercycle -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;
	
# Copy TRM_weekly_powercycle_xml
$trm_de_reboot_xml = "C:\temp\wsus\TRM_weekly_powercycle.xml"
if (Test-Path $trm_de_reboot_xml -PathType leaf) 
{"Server reboot Task xml exists"  } 
else
{copy-item -Path $sourcePath_TRM_weekly_powercycle_xml -Destination $destPath_TRM_weekly_powercycle_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


#Create Scheduled Task TRM_WSUS_Weekly_Update
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_WSUS_Weekly_Update.xml' | Out-String) -TaskName "TRM WSUS Weekly Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }

#Create Scheduled Task TRM_weekly_powercycle
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_weekly_powercycle.xml' | Out-String) -TaskName "TRM_weekly_powercycle" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }