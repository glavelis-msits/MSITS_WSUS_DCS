Clear-Host
#Vars
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$sourcePath_PSWU = "$ScriptDir\PSWindowsUpdate"
$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"
$sourcePath_wsus_local_update_noreboot = "$ScriptDir\Assets\TRM_wsus_local_update_reboot.ps1"
$destination_tasks = "C:\tasks"
$sourcePath_WSUS_Update_check_xml = "E:\Scripts\MSITS_WSUS_DCS\TRM\Assets\TRM_WSUS_Weekly_Update.xml"
$sourcePath_TRM_weekly_powercycle_xml = "E:\Scripts\MSITS_WSUS_DCS\TRM\Assets\TRM_weekly_powercycle.xml"
$destination_wsus = "C:\temp\wsus"
$sourcePath_TRM_weekly_powercycle = "E:\Scripts\MSITS_WSUS_DCS\TRM\Assets\TRM_weekly_powercycle.ps1"
$local_PSWU_path = "$ScriptDir\PSWindowsUpdate"
$remote_PSWU_path = "C:\Program Files\WindowsPowerShell\Modules"
#$servers = "$ScriptDir\FQDNList.txt"
#$latest_trm_de_path = "$ScriptDir\Reporting\ServerUptime\DE_serverlists_reports"            #Server List path
#$latest_trm_de_list = (Get-ChildItem -Path $latest_trm_de_path -filter *clean*TRM* | Sort-Object LastAccessTime -Descending | Select-Object -First 1).Name # Select the latest TRM list
#$servers = "$latest_trm_de_path\$latest_trm_de_list"
$servers = "$ScriptDir\TRM_DE_ServerList_temp.txt"


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


} }


# Copy PSwindowsUpdate Module	
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $local_PSWU_path -Destination $remote_PSWU_path -recurse -ToSession $Session -Force
    };
	
# Copy TRM_wsus_local_update_reboot.ps1
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destination_tasks -recurse -ToSession $Session -Force
    };

# Copy WSUS_Update_xml
Get-Content $servers | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destination_wsus -recurse -ToSession $Session -ErrorAction SilentlyContinue
};

# Copy TRM_weekly_powercycle.ps1
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
	copy-item -Path $sourcePath_TRM_weekly_powercycle -Destination $destination_tasks -recurse -ToSession $Session -ErrorAction SilentlyContinue
    };
	
# Copy TRM_weekly_powercycle_xml     
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
	copy-item -Path $sourcePath_TRM_weekly_powercycle_xml -Destination $destination_wsus -recurse -ToSession $Session -ErrorAction SilentlyContinue 
    };

#Create Scheduled Task TRM_WSUS_Weekly_Update
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_WSUS_Weekly_Update.xml' | Out-String) -TaskName "TRM WSUS Weekly Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" –Force}
    }

#Create Scheduled Task TRM_weekly_powercycle
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_weekly_powercycle.xml' | Out-String) -TaskName "TRM_weekly_powercycle" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56"–Force}
    }