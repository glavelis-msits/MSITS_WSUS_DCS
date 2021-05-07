param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit
}

'Running with Elevated Admin privileges'

Clear-Host
#Vars
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$local_PSWU_path = "$ScriptDir\PSWindowsUpdate"
$remote_PSWU_path = "C:\Program Files\WindowsPowerShell\Modules"
$sourcePath_wsus_local_update_noreboot = "$ScriptDir\TRM_wsus_local_update_reboot.ps1"
$remote_taskspath = "C:\tasks"
#$sourcePath_WSUS_Update_check_xml = "$ScriptDir\TRM_WSUS_Weekly_Update.xml"
$remote_wsuspath = "C:\temp\wsus"
$local_TRM_weekly_powercycle_xml = "$ScriptDir\TRM_weekly_powercycle.xml"
$local_TRM_weekly_powercycle = "$ScriptDir\TRM_weekly_powercycle.ps1"
$local_TRM_runonce_powercycle_xml = "$ScriptDir\TRM_Run_Once_TRM_DE_Triggered_Deploy_No_Task.xml"
$servers = "$ScriptDir\TRM_DE_trigger.txt"
$pw = Get-Content "\\ing04wsus01p\wsus_crd\svc-tac.txt"                                     #
$pws = ConvertTo-SecureString -String $pw -AsPlainText -Force                               #SVC-TaskAutomateCopy pass encryption
$svctac = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pws)) #

function TRMDeploy {

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
<# Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $local_PSWU_path -Destination $remote_PSWU_path -recurse -ToSession $Session -Force
    }; #>
	
<# $Path="C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"

if (!(Test-Path $Path))
{
write-host "PSwindowsUpdate Module already exists" -ForegroundColor Green 

}
else
{
copy-item -Path $local_PSWU_path -Destination $remote_PSWU_path -recurse -ToSession $Session -ErrorAction SilentlyContinue
} } #>
	
# Copy PSwindowsUpdate update script 
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $remote_taskspath -recurse -ToSession $Session -Force
    };
	
<# $trm_de_wsus_upd = "C:\tasks\TRM_wsus_local_update_reboot.ps1"
if (Test-Path $trm_de_wsus_upd -PathType leaf) 
{"WSUS update script Exists" } 
else
{copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $remote_taskspath -recurse -ToSession $Session -ErrorAction SilentlyContinue} ; #>

# Copy TRM_weekly_powercycle script	
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $local_TRM_weekly_powercycle -Destination $remote_taskspath -recurse -ToSession $Session -Force
    };
<# $trm_de_reboot_path = "C:\tasks\TRM_weekly_powercycle.ps1"
if (Test-Path $trm_de_reboot_path -PathType leaf) 
{"Server reboot script exists" } 
else	
{copy-item -Path $local_TRM_weekly_powercycle -Destination $remote_taskspath -recurse -ToSession $Session -ErrorAction SilentlyContinue} ; #>
	
# Copy TRM_weekly_powercycle_xml
<# $trm_de_reboot_xml = "C:\temp\wsus\TRM_weekly_powercycle.xml"
if (Test-Path $trm_de_reboot_xml -PathType leaf) 
{"TRM_weekly_powercycle xml exists"  } 
else
{copy-item -Path $local_TRM_weekly_powercycle_xml -Destination $remote_wsuspath -recurse -ToSession $Session -ErrorAction SilentlyContinue} ; #>

# Copy TRM_weekly_powercycle_xml
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $local_TRM_weekly_powercycle_xml -Destination $remote_wsuspath -recurse -ToSession $Session -Force
    }


<# # Copy TRM_Run_Once_TRM_DE_Triggered_Deploy_No_Task
$trm_de_reboot_once_xml = "C:\temp\wsus\TRM_Run_Once_TRM_DE_Triggered_Deploy_No_Task.xml"
if (Test-Path $trm_de_reboot_once_xml -PathType leaf) 
{"TRM_Run_Once_TRM_DE_Triggered_Deploy_No_Task xml exists"  } 
else
{copy-item -Path $local_TRM_runonce_powercycle_xml -Destination $remote_wsuspath -recurse -ToSession $Session -ErrorAction SilentlyContinue} ; #>

# Copy TRM_Run_Once_TRM_DE_Triggered_Deploy_No_Task
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $local_TRM_runonce_powercycle_xml -Destination $remote_wsuspath -recurse -ToSession $Session -Force
    }

#Create Scheduled Task TRM_weekly_powercycle
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_weekly_powercycle.xml' | Out-String) -TaskName "TRM_weekly_powercycle" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" -force }
    }
	

	
#Create Scheduled Task TRM_update_Runonce
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_Run_Once_TRM_DE_Triggered_Deploy_No_Task.xml' | Out-String) -TaskName "TRM_Run_Once_TRM_DE_Triggered_Deploy_No_Task" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" -force }
    }

	}}
	
	
TRMDeploy | Out-File "$ScriptDir\reporting\$(get-date -f dd-MM-yyyy)-TRM_DE_Triggered_report.log" -force
	
