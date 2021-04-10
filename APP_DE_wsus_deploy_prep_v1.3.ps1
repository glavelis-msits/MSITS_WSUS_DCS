Clear-Host
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
$app_de_wsus_upd = "C:\tasks\APP_DE_wsus_local_update_reboot.ps1"
if (Test-Path $app_de_wsus_upd -PathType leaf) 
{"WSUS update script Exists" } 
else
{copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy APP_DE Schedule Task xml
$app_de_wsus_task_xml = "C:\temp\wsus\APP_DE_Test_Group_WSUS_Monthly_Update.xml"
if (Test-Path $app_de_wsus_task_xml -PathType leaf) 
{"WSUS update Task schedule xml exists"  }
else
{copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy APP_DE_reboot script	
$app_de_reboot_path = "C:\tasks\APP_DE_reboot.ps1"
if (Test-Path $app_de_reboot_path -PathType leaf) 
{"Server reboot script exists" } 
else
{copy-item -Path $sourcePath_APP_DE_powercycle -Destination $destPath_APP_DE_powercycle -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy APP_DE_reboot_xml	
$app_de_reboot_xml = "C:\temp\wsus\APP_DE_reboot.xml"
if (Test-Path $app_de_reboot_xml -PathType leaf) 
{"Reboot Task xml exists"  } 
else
{copy-item -Path $sourcePath_APP_DE_reboot_xml -Destination $destPath_APP_DE_reboot_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

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