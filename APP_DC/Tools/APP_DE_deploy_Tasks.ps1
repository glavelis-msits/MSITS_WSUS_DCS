$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path        
$servers = "$ScriptDir\APP_Runonce.txt"
$sourcePath_WSUS_Update_check_xml = "$ScriptDir\APP_Run_Once_Patch_Update.xml"
$destPath_WSUS_Update_check_xml = "C:\temp\wsus"


# Copy APP_Run_Once_Patch_Update_xml
Get-Content $servers| ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -Force
    }

#Create Scheduled Task APP_Run_Once_Patch_Update
Get-Content $servers| ForEach-Object {
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy unrestricted -force ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\APP_Run_Once_Patch_Update.xml' | Out-String) -TaskName "APP_Run_Once_Patch_Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }
