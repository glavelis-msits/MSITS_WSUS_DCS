Clear-Host
#Vars
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$sourcePath_WSUS_Update_check_xml = "E:\Scripts\MSITS_WSUS_DCS\TRM\Assets\TRM_WSUS_weekly_TEST_SVC_WSUS.xml"
$destination_wsus = "C:\temp\wsus"
$servers = "$ScriptDir\TRM_DE_ServerList_temp.txt"



# Copy WSUS_Update_xml
Get-Content $servers | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destination_wsus -recurse -ToSession $Session -ErrorAction SilentlyContinue
};

#Create Scheduled Task TRM_WSUS_Weekly_Update
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_WSUS_weekly_TEST_SVC_WSUS.xml' | Out-String) -TaskName "TRM_WEEKLY_TEST_SVC_WSUS" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password "isRIvx0Vbu5V61nEnq56" –Force}
    }
