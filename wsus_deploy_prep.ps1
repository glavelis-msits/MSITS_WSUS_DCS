Clear-Host
#Vars
$sourcePath_PSWU = "E:\Scripts\PSWindowsUpdate"
$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"
$sourcePath_wsus_local_update_noreboot = "E:\Scripts\WSUS\wsus_local_update_noreboot.ps1"
$destPath_wsus_local_update_noreboot = "C:\tasks"
$sourcePath_WSUS_Update_check_xml = "E:\Scripts\WSUS\WSUS_Update_check.xml"
$destPath_WSUS_Update_check_xml = "C:\temp\wsus"
$chweckmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject
$servers = Get-Content E:\Scripts\serverlist.txt

Get-Content E:\Scripts\serverlist.txt| foreach {
    $Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {
New-Item -ItemType Directory -Force -Path C:\tasks;
New-Item -ItemType Directory -Force -Path C:\temp\wsus;
New-Item -ItemType Directory -Force -Path C:\temp\wsus\wsus_logs;

}
    }

# Copy PSwindowsUpdate Module
Get-Content E:\Scripts\serverlist.txt| foreach {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -Force
    }
	
# Copy PSWU update script	
Get-Content E:\Scripts\serverlist.txt| foreach {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -Force
    }

# Copy Task Schedule xml	
Get-Content E:\Scripts\serverlist.txt| foreach {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -Force
    }
	
#Create Scheduled Task
Get-Content E:\Scripts\serverlist.txt| foreach {
    $Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy Bypass -Scope Process ; Register-ScheduledTask -xml (Get-Content 'C:\temp\wsus\WSUS_Update_check.xml' | Out-String) -TaskName "WSUS Weekly Update check" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy  -Password isRIvx0Vbu5V61nEnq56 –Force}
    }

    