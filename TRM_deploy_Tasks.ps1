$servers = "E:\Scripts\MSITS_WSUS_DCS\FQDNList.txt"
$sourcePath_WSUS_Update_check_xml = "E:\Scripts\MSITS_WSUS_DCS\TRM_WSUS_Weekly_Update.xml"
$destPath_WSUS_Update_check_xml = "C:\temp\wsus"
$sourcePath_TRM_weekly_powercycle_xml = "E:\Scripts\MSITS_WSUS_DCS\TRM_weekly_powercycle.xml"
$destPath_TRM_weekly_powercycle_xml = "C:\temp\wsus"

<# # Copy TRM_WSUS_Weekly_Update_xml
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -Force
    }
	
# Copy TRM_weekly_powercycle_xml
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_TRM_weekly_powercycle_xml -Destination $destPath_TRM_weekly_powercycle_xml -recurse -ToSession $Session -Force
    }
 #>
#Create Scheduled Task TRM_WSUS_Weekly_Update
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_WSUS_Weekly_Update.xml' | Out-String) -TaskName "TRM WSUS Weekly Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }

#Create Scheduled Task TRM_weekly_powercycle
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\TRM_weekly_powercycle.xml' | Out-String) -TaskName "TRM_weekly_powercycle" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }