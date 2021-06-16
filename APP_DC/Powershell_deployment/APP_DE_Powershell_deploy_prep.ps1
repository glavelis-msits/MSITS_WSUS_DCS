Clear-Host
Write-Verbose "MSITS Decentral APP-DC Powershell 5.1 deployment"
### Vars ###
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path                             #Execution directory discovery
$sourcePath_PSWU = "$ScriptDir\PSWindowsUpdate"                                         #Local PSWU Module path
$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"                           #PSWU Module destination
$source_psinstall = "$ScriptDir\APP_Powershell_installation.ps1"  						#Local WSUS update script path
$dest_tasks = "C:\tasks"                                          						#WSUS update path destination
$sourcePath_Runonce_xml = "$ScriptDir\APP_Run_Once_Powershell.xml" 						#Runonce Task local xml path
$dest_wsus = "C:\temp\wsus"                                           					#Scheduled Task Destination 
$servers = "E:\Scripts\MSITS_WSUS_DCS\APP_DC\APPlication_Deployment_serverlist.txt"		#Server List
$sourcepowershell51 = "E:\Scripts\app_repo\Win8.1AndW2K12R2-KB3191564-x64.msu"
$destinationpowershell51 = "C:\temp\Win8.1AndW2K12R2-KB3191564-x64.msu"


#Create Destination Folders
	
Get-Content $servers| ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;

#Create C:\tasks folder
    <# Invoke-Command -ComputerName "$_" -ScriptBlock {
    New-Item -ItemType Directory -Force -Path "C:\tasks";} #>
	
	
	# Copy WPF 51 Update
	if (Test-Path $destinationpowershell51 -PathType leaf) 
{"Win8.1AndW2K12R2-KB3191564-x64.msu already Exists"  } 
else
{copy-item -Path $sourcepowershell51 -Destination $dest_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;
    
# Copy PSwindowsUpdate update script   
$app_de_wsus_upd = "C:\tasks\APP_Powershell_installation.ps1"
if (Test-Path $app_de_wsus_upd -PathType leaf) 
{"Powershell Installation script Exists" } 
else
{copy-item -Path $source_psinstall -Destination $dest_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy APP_DE Runonce xml
$app_de_wsus_task_xml = "C:\tasks\APP_Run_Once_Powershell.xml"
if (Test-Path $app_de_wsus_task_xml -PathType leaf) 
{"WSUS update Task schedule xml exists" }
else
{copy-item -Path $sourcePath_Runonce_xml -Destination $dest_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;
	
	}
	


##### SCHEDULED TASK CREATION #####
#Task APP_DE_runonce
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\tasks\APP_Run_Once_Powershell.xml' | Out-String) -TaskName "APP_Run_Once_Powershell" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" –Force}
    } 