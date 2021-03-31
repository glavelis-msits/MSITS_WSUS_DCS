$servers = "E:\Scripts\MSITS_WSUS_DCS\FQDNList.txt"
$sourcePath_WSUS_Update_check_xml = "E:\Scripts\MSITS_WSUS_DCS\APP_DE_WSUS_Monthly_Update.xml"
$destPath_WSUS_Update_check_xml = "C:\temp\wsus"
#$sourcePath_TRM_weekly_powercycle_xml = "E:\Scripts\MSITS_WSUS_DCS\TRM_weekly_powercycle.xml"
#$destPath_TRM_weekly_powercycle_xml = "C:\temp\wsus"

# Copy APP_DE_WSUS_Monthly_Update_xml
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -Force
    }

#Create Scheduled Task APP_DE_WSUS_Monthly_Update
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\APP_DE_WSUS_Monthly_Update.xml' | Out-String) -TaskName "APP_DE_WSUS_Monthly_Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }
