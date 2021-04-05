Clear-Host
#Vars
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$sourcePath_PSWU = "$ScriptDir\PSWindowsUpdate"
$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"
$sourcePath_wsus_local_update_noreboot = "$ScriptDir\APP_DE_wsus_local_update_reboot.ps1"
$destPath_wsus_local_update_noreboot = "C:\tasks"
$sourcePath_WSUS_Update_check_xml = "$ScriptDir\APP_DE_Test_Group_WSUS_Monthly_Update.xml"
$destPath_WSUS_Update_check_xml = "C:\temp\wsus"
#$sourcePath_TRM_weekly_powercycle_xml = "$ScriptDir\TRM_weekly_powercycle.xml"
#$destPath_TRM_weekly_powercycle_xml = "C:\temp\wsus"
#$sourcePath_TRM_weekly_powercycle = "$ScriptDir\TRM_weekly_powercycle.ps1"
#$destPath_TRM_weekly_powercycle = "C:\tasks"
$servers = "$ScriptDir\FQDNList.txt"

#Create Destination Folders
Get-Content $servers| ForEach-Object {
Invoke-Command -ComputerName "$_" -ScriptBlock {
New-Item -ItemType Directory -Force -Path C:\tasks;
New-Item -ItemType Directory -Force -Path C:\temp\wsus;
New-Item -ItemType Directory -Force -Path C:\temp\wsus\wsus_logs;

}
    }

# Copy PSwindowsUpdate Module
Get-Content $servers | ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -Force
}
	
# Copy PSWU update script	
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -Force
    }

# Copy TRM_weekly_powercycle script	
<# Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_TRM_weekly_powercycle -Destination $destPath_TRM_weekly_powercycle -recurse -ToSession $Session -Force
    } #>

# Copy TRM_WSUS_Weekly_Update_xml
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -Force
    }
	
# Copy TRM_weekly_powercycle_xml
<# Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_TRM_weekly_powercycle_xml -Destination $destPath_TRM_weekly_powercycle_xml -recurse -ToSession $Session -Force
    } #>

#Create Scheduled Task APP_DE_WSUS_Monthly_Update
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\APP_DE_Test_Group_WSUS_Monthly_Update.xml' | Out-String) -TaskName "APP_DE_Test_Group_WSUS_Monthly_Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }

#Create Scheduled Task TRM_weekly_powercycle
<# Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_weekly_powercycle.xml' | Out-String) -TaskName "TRM_weekly_powercycle" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    } #>