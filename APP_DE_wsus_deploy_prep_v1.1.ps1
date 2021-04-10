﻿Clear-Host
Write-Verbose "MSITS Decentral APP-DC WSUS Prerequisites deployment"
### Vars ###
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path                                	#Execution directory discovery
$sourcePath_PSWU = "$ScriptDir\PSWindowsUpdate"                                            	#Local PSWU Module path
$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"                              	#PSWU Module destination
$sourcePath_wsus_local_update_noreboot = "$ScriptDir\APP_DE_wsus_local_update_reboot.ps1"  	#Local WSUS update script path
$destPath_wsus_local_update_noreboot = "C:\tasks"                                          	#WSUS update path destination
$sourcePath_WSUS_Update_check_xml = "$ScriptDir\APP_DE_Test_Group_WSUS_Monthly_Update.xml" 	#Scheduled Update Task local xml path
$destPath_WSUS_Update_check_xml = "C:\temp\wsus"                                           	#Scheduled Task Destination 
$sourcePath_APP_DE_powercycle = "$ScriptDir\APP_DE_reboot.ps1"   							#Local Powercycle script path
$destPath_APP_DE_powercycle = "C:\tasks" 													#Powercycle script destination	
$sourcePath_APP_DE_reboot_xml = "$ScriptDir\APP_DE_reboot.xml" 								#Scheduled Reboot Task local xml path
$destPath_APP_DE_reboot_xml = "C:\temp\wsus"     											#Reboot Task xml destination
$servers = "$ScriptDir\FQDNList.txt"														#Server List
$taskfolder = "C:\tasks"																	#Tasks folder path
$wsusfolder = "C:\temp\wsus"																#WSUS folder path
$wsuslogfolder = "C:\temp\wsus\wsus_logs"													#WSUS update logs folder

#Create Destination Folders
Get-Content $servers| ForEach-Object {
Invoke-Command -ComputerName "$_" -ScriptBlock {

Write-Verbose "Creating Folder C:\tasks ..."
Try { New-Item -ItemType directory -Path $taskfolder -Force -ErrorAction SilentlyContinue }
Catch { Write-Host "Folder C:\tasks already exists " -ForegroundColor Green }

Write-Verbose "Creating Folder C:\temp\wsus ..."
Try { New-Item -ItemType directory -Path $wsusfolder -ErrorAction SilentlyContinue }
Catch { Write-Host "Folder C:\temp\wsus already exists " -ForegroundColor Green }

Write-Verbose "Creating Folder C:\temp\wsus\wsus_logs ..."
Try { New-Item -ItemType directory -Path $wsuslogfolder -ErrorAction SilentlyContinue }
Catch { Write-Host "Folder C:\temp\wsus\wsus_logs already exists " -ForegroundColor Green }

}
    }

# Copy PSwindowsUpdate Module
Get-Content $servers | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
Write-Verbose "Copying PSWindowsUpdate Module"
Try { copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -ErrorAction SilentlyContinue }
Catch { Write-Host "PSWindowsUpdate Module already exists - moving on... " -ForegroundColor Green }
   
# Copy PSwindowsUpdate update script   
Write-Verbose "Copying PSWindowsUpdate Script"
Try { copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -ErrorAction SilentlyContinue }
Catch { Write-Host "PSWindowsUpdate Script already exists - moving on... " -ForegroundColor Green }

# Copy APP_DE Schedule Task xml
Write-Verbose "Copying APP_DE Schedule Task xml"
Try { copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue }
Catch { Write-Host "APP_DE Schedule Task xml already exists - moving on... " -ForegroundColor Green }

# Copy APP_DE_reboot script	
Write-Verbose "Copying APP_DE_reboot script"
Try {copy-item -Path $sourcePath_APP_DE_powercycle -Destination $destPath_APP_DE_powercycle -recurse -ToSession $Session -ErrorAction SilentlyContinue }
Catch { Write-Host "APP_DE_reboot script already exists - moving on... " -ForegroundColor Green }

# Copy APP_DE_reboot_xml	
Write-Verbose "Copying APP_DE_reboot xml"
Try {copy-item -Path $sourcePath_APP_DE_reboot_xml -Destination $destPath_APP_DE_reboot_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue }
Catch { Write-Host "APP_DE_reboot xml already exists - moving on... " -ForegroundColor Green }


}

##### SCHEDULED TASK CREATION #####
#APP_DE_WSUS_Monthly_Update
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\APP_DE_Test_Group_WSUS_Monthly_Update.xml' | Out-String) -TaskName "APP_DE_Test_Group_WSUS_Monthly_Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }

#Task APP_DE_reboot
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\APP_DE_reboot.xml' | Out-String) -TaskName "APP_DE_reboot" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    } 