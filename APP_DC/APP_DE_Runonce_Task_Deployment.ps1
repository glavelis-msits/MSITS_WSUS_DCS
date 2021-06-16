Clear-Host
Write-Verbose "MSITS Decentral APP-DC Powershell 5.1 deployment"
### Vars ###
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path                             #Execution directory discovery 
$source_psinstall = "$ScriptDir\APP_DE_Runonce.ps1"  									#Local WSUS update script path
$dest_tasks = "C:\tasks"                                          						#WSUS update path destination
$sourcePath_Runonce_xml = "$ScriptDir\APP_Run_Once.xml" 								#Runonce Task local xml path
$servers = "E:\Scripts\MSITS_WSUS_DCS\APP_DC\APPlication_Deployment_serverlist.txt"		#Server List


#Create Destination Folders
	
Get-Content $servers| ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;

copy-item -Path $sourcePath_Runonce_xml -Destination $dest_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue ;
copy-item -Path $source_psinstall -Destination $dest_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue ;

	
	}
	
##### SCHEDULED TASK CREATION #####
#Task APP_DE_runonce
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\tasks\APP_Run_Once.xml' | Out-String) -TaskName "APP_Run_Once" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" -Force}
    } 