﻿Clear-Host
#Vars
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$sourcePath_PSWU = "$ScriptDir\PSWindowsUpdate"
$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"
$sourcePath_wsus_local_update_noreboot = "$ScriptDir\TRM_wsus_local_update_reboot.ps1"
$destPath_wsus_local_update_noreboot = "C:\tasks"
$sourcePath_WSUS_Update_check_xml = "$ScriptDir\WSUS_Update_check.xml"
$destPath_WSUS_Update_check_xml = "C:\temp\wsus"
#$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

$servers = Get-Content "$ScriptDir\serverlist.txt"


Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {
New-Item -ItemType Directory -Force -Path C:\tasks;
New-Item -ItemType Directory -Force -Path C:\temp\wsus;
New-Item -ItemType Directory -Force -Path C:\temp\wsus\wsus_logs;

}
    }

# Copy PSwindowsUpdate Module
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -Force
    }
	
# Copy PSWU update script	
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -Force
    }

# Copy Task Schedule xml	
Get-Content $servers| ForEach-Object-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -Force
    }
	
#Create Scheduled Task
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy Bypass -Scope Process ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\WSUS_Update_check.xml' | Out-String) -TaskName "WSUS Weekly Update check" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }

    