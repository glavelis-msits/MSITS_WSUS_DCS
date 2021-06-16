Clear-Host
Write-Verbose "MSITS Decentral APP-DC WSUS Prerequisites deployment"
### Vars ###
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path                                	#Execution directory discovery
$sourcePath_PSWU = "$ScriptDir\PSWindowsUpdate"                                            	#Local PSWU Module path
$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"                              	#PSWU Module destination
$sourcePath_wsus_local_update_noreboot = "$ScriptDir\APP_DE_wsus_local_update_reboot.ps1"  	#Local WSUS update script path
$taskfolder = "C:\tasks"                                          							#WSUS update path destination
$sourcepath_wsus_patch_update_runonce_xml = "$ScriptDir\APP_Run_Once_Patch_Update.xml" 		#Scheduled Update Task local xml path
$sourcePath_Runonce_xml = "$ScriptDir\APP_Run_Once.xml" 									#Runonce Task local xml path
$sourcePath_APP_DE_powercycle = "$ScriptDir\APP_DE_reboot.ps1"   							#Local Powercycle script path
$sourcePath_APP_DE_reboot_xml = "$ScriptDir\APP_DE_reboot.xml" 								#Scheduled Reboot Task local xml path
$wsusfolder = "C:\temp\wsus"																#WSUS folder path
$wsuslogfolder = "C:\temp\wsus\wsus_logs"													#WSUS update logs folder

###########################################################################################################################################
<#     Server list creation 
For a predefined list, uncomment the first servers var.
For an automatic AD server list extraction , uncheck the second servers var 
and all subsequent vars (don't forget to comment out the first server var) #>


$servers = "$ScriptDir\APP_Runonce_copy_settings_wo_task_creation.txt"								#Server List
#$servers = $latest_app_de_list                                                             #Server List (new)
#$latest_app_de_path = "$ScriptDir\Reporting\ServerUptime\DE_serverlists_reports"           #Server List path
#$latest_app_de_list = (Get-ChildItem -Path $latest_app_de_path -filter *clean*APP* | Sort-Object LastAccessTime -Descending | Select-Object -First 1).Name # Select the latest APP/DC list

###########################################################################################################################################

#$pw = Get-Content "\\ing04wsus01p\wsus_crd\svc-tac.txt"                                     #
#$pws = ConvertTo-SecureString -String $pw -AsPlainText -Force                               #SVC-TaskAutomateCopy pass encryption
#$svctac = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pws)) #

###########################################################################################################################################

#Create Destination Folders

Get-Content $servers| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {
    New-Item -ItemType Directory -Force -Path "C:\temp\wsus"
    }};
	
Get-Content $servers| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {
    New-Item -ItemType Directory -Force -Path "C:\tasks"
    }};
	
Get-Content $servers| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {
    New-Item -ItemType Directory -Force -Path "C:\temp\wsus\wsus_logs"
    }};

# Copy PSWindowsUpdate Module
Get-Content $servers | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
$Path="C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"

if (!(Test-Path $Path))
{
write-host "PSwindowsUpdate Module already exists" -ForegroundColor Green 
}
else
{
copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -ErrorAction SilentlyContinue
} ;

   
# Copy PSwindowsUpdate update script   
$app_de_wsus_upd = "C:\tasks\APP_DE_wsus_local_update_reboot.ps1"
if (Test-Path $app_de_wsus_upd -PathType leaf) 
{"WSUS update script Exists" } 
else
{copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $taskfolder -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy APP_DE Schedule Task xml
$app_de_wsus_task_xml = "C:\temp\wsus\APP_Run_Once_Patch_Update.xml"
if (Test-Path $app_de_wsus_task_xml -PathType leaf) 
{"WSUS update Task schedule xml exists"  }
else
{copy-item -Path $sourcepath_wsus_patch_update_runonce_xml -Destination $wsusfolder -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

# Copy APP_DE Runonce xml
$app_de_wsus_task_xml = "C:\temp\wsus\APP_Run_Once.xml"
if (Test-Path $app_de_wsus_task_xml -PathType leaf) 
{"WSUS update Task schedule xml exists"  }
else
{copy-item -Path $sourcePath_Runonce_xml -Destination $wsusfolder -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

# Copy APP_DE_reboot script	
$app_de_reboot_path = "C:\tasks\APP_DE_reboot.ps1"
if (Test-Path $app_de_reboot_path -PathType leaf) 
{"Server reboot script exists" } 
else
{copy-item -Path $sourcePath_APP_DE_powercycle -Destination $taskfolder -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

}

##### SCHEDULED TASK CREATION #####
#APP_DE_WSUS_Monthly_Update
<# Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\APP_DE_Test_Group_WSUS_Monthly_Update.xml' | Out-String) -TaskName "APP_DE_Test_Group_WSUS_Monthly_Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password $svctac –Force}
    } #>

#Task APP_DE_reboot
<# Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\APP_DE_reboot.xml' | Out-String) -TaskName "APP_DE_reboot" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" –Force}
    } 
	
#Task APP_DE_runonce
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\APP_Run_Once_Patch_Update.xml' | Out-String) -TaskName "APP_Runonce" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" –Force}
    }  #>