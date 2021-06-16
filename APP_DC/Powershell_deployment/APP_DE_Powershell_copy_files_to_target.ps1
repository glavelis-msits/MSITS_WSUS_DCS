Clear-Host
Write-Verbose "MSITS Decentral APP-DC Powershell 5.1 deployment"
### Vars ###
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path                             #Execution directory discovery 
$source = "$ScriptDir\APP_Powershell_installation.ps1"  								#Local WSUS update script path
$destination = "C:\tasks"                                          						#WSUS update path destination
$source_xml = "$ScriptDir\APP_Run_Once_Powershell_01062021.xml" 						#Runonce Task local xml path
$servers = "$ScriptDir\Powershell_deployment.txt"										#Server List
$source_patch = "E:\Scripts\app_repo\Win8.1AndW2K12R2-KB3191564-x64.msu"



	
Get-Content $servers| ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;

##	Copy xml to target ##
copy-item -Path $source_xml -Destination $destination -recurse -ToSession $Session -ErrorAction SilentlyContinue ;

##	Copy execution script	##
copy-item -Path $source -Destination $destination -recurse -ToSession $Session -ErrorAction SilentlyContinue ;

##	Copy Powershell 5.1 KB to target	##
if (Test-Path $source_patch -PathType leaf) 
{"Win8.1AndW2K12R2-KB3191564-x64.msu already Exists" } 
else
{copy-item -Path $source_patch -Destination $destination -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

	}
	
##### SCHEDULED TASK CREATION #####
#Task APP_DE_runonce
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\tasks\APP_Run_Once_Powershell_01062021.xml' | Out-String) -TaskName "APP_Run_Once" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" -Force}
    } 
