Clear-Host
Write-Verbose "MSITS Decentral APP-DC Powershell 5.1 deployment"
### Vars ###
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path                             #Execution directory discovery
#$sourcePath_PSWU = "$ScriptDir\PSWindowsUpdate"                                         #Local PSWU Module path
#$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"                           #PSWU Module destination
$source_psinstall = "$ScriptDir\DBA_Powershell_installation_reboot_dism.ps1"  						#Local WSUS update script path
$dest_tasks = "C:\tasks"  
$sourcePath_DBA_DE_1313_sql = "E:\Scripts\MSITS_WSUS_DCS\DBA\Assets\1313.sql" 												#1313 sql sourcepath
$destPath_DBA_DE_1313_sql = "C:\tasks"     																#1313 sql destinationpath
$sourcePath_DBA_DE_1414_sql = "E:\Scripts\MSITS_WSUS_DCS\DBA\Assets\1414.sql" 												#1414 sql sourcepath
$destPath_DBA_DE_1414_sql = "C:\tasks"                                      						#WSUS update path destination
$sourcePath_Runonce_xml = "$ScriptDir\DBA_Run_Once_Powershell.xml" 						#Runonce Task local xml path
$dest_wsus = "C:\temp\wsus"                                           					#Scheduled Task Destination 
#$servers = "E:\Scripts\MSITS_WSUS_DCS\APP_DC\APPlication_Deployment_serverlist.txt"		#Server List
$servers = "$ScriptDir\Powershell_deployment.txt"		#Server List
$sourcepowershell51 = "E:\Scripts\app_repo\Win8.1AndW2K12R2-KB3191564-x64.msu"
$destinationpowershell51 = "C:\tasks\Win8.1AndW2K12R2-KB3191564-x64.msu"
$dba_post_check = "$ScriptDir\DBA_post_reboot_actions.ps1"
$dba_post_check_xml = "$ScriptDir\DBA Bootup check.xml"

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
$Session = New-PSSession -ComputerName "$_" ;

#Create C:\tasks folder
  <#   Invoke-Command -ComputerName "$_" -ScriptBlock {
    New-Item -ItemType Directory -Force -Path "C:\tasks";} #>
	
	
	# Copy WPF 51 Update
if (Test-Path "\\$_\C$\tasks\Win8.1AndW2K12R2-KB3191564-x64.msu" -PathType leaf) 
{write-host "Win8.1AndW2K12R2-KB3191564-x64.msu already Exists!!!!!!"-ForegroundColor Green} 
else
{copy-item -Path $sourcepowershell51 -Destination $dest_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;
    
# Copy PSwindowsUpdate update script   
$app_de_wsus_upd = "\\$_\C$\tasks\DBA_Powershell_installation_reboot_dism.ps1"
if (Test-Path $app_de_wsus_upd -PathType leaf) 
{write-host "Powershell Installation script Exists" -ForegroundColor Green  } 
else
{copy-item -Path $source_psinstall -Destination $dest_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy APP_DE Runonce xml
if (Test-Path "C:\tasks\Win8.1AndW2K12R2-KB3191564-x64.msu" -PathType leaf) 
{"Powershell Installation script Exists" } 
else
{copy-item -Path $sourcePath_Runonce_xml -Destination $dest_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;
	

#Copy DBA post reboot check script
if (Test-Path "C:\tasks\Win8.1AndW2K12R2-KB3191564-x64.msu" -PathType leaf) 
{"Powershell Installation script Exists" } 
else
{copy-item -Path $dba_post_check -Destination $dest_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue};

#Copy DBA post reboot check xml
if (Test-Path "C:\tasks\Win8.1AndW2K12R2-KB3191564-x64.msu" -PathType leaf) 
{"Powershell Installation script Exists" } 
else
{copy-item -Path $dba_post_check_xml -Destination $dest_wsus -recurse -ToSession $Session -ErrorAction SilentlyContinue};

# Copy 1313 SQL script	
$DBA_DE_1313_sql_path = "\\$_\C$\tasks\1313.sql"
if (Test-Path $DBA_DE_1313_sql_path -PathType leaf) 
{"1313 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1313_sql -Destination $destPath_DBA_DE_1313_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

# Copy 1414 SQL script	
$DBA_DE_1414_sql_path = "\\$_\C$\tasks\1414.sql"
if (Test-Path $DBA_DE_1414_sql_path -PathType leaf) 
{"1414 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1414_sql -Destination $destPath_DBA_DE_1414_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;
}

##### SCHEDULED TASK CREATION #####
#Task APP_DE_runonce
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\tasks\DBA_Run_Once_Powershell.xml' | Out-String) -TaskName "DBA_Run_Once_Powershell" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" –Force}
    } 
	
# DBA post boot action
Get-Content $servers| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy Unrestricted -Force ; Register-ScheduledTask -Xml (Get-Content "C:\temp\wsus\DBA Bootup check.xml" | Out-String) -TaskName "DBA Bootup check" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy -Password "isRIvx0Vbu5V61nEnq56" -Force}
}