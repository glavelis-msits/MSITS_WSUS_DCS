#Determine Script Path
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
 
Write-Host "Current script directory is $ScriptDir"

#Remote Install WUpdate
Invoke-WUJob -ComputerName mst04trmmm1-1.mmsrg.net -Script {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ipmo PSWindowsUpdate -Force | Out-File C:\temp\PSWindowsUpdate_installation.log } -Confirm:$false -Verbose -RunNow

#Local install WUpdate
Install-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-File "C:\temp\wsus_logs\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -force

#Set executionpolicy
Set-ExecutionPolicy Bypass -Scope Process ; Install-WindowsUpdate -AcceptAll -Install | Out-File "C:\temp\wsus_logs\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -force

########################
#Set Trusted Hosts
winrm set winrm/config/client ‘@{TrustedHosts="mst04trmmm1-1,pdb04trmmm1-1}’

Get-Item WSMan:\localhost\Client\TrustedHosts

Set-Item WSMan:\localhost\Client\TrustedHosts -Value 'mst04trmmm1-1.mmsrg.net,pdb04trmmm1-1'

Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*'
####################

Clear-Host

#############################
Invoke-WUJob -ComputerName bmo04trmmm1-1.mmsrg.net -Script {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Start-Sleep -Seconds 10; Install-Module -Name PSWindowsUpdate –Force | Out-File C:\temp\PSWindowsUpdate_installation.log } -Confirm:$false -Verbose -RunNow

Invoke-WUJob -ComputerName bmo04trmmm1-1.mmsrg.net -Script {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Set-ExecutionPolicy Bypass -Scope Process -Force; Start-Sleep -Seconds 10; Install-Module -Name PSWindowsUpdate –Force | Out-File C:\temp\PSWindowsUpdate_installation.log } -Confirm:$false -Verbose -RunNow

Invoke-WUJob -ComputerName bmo04trmmm1-1.mmsrg.net -Script {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Set-ExecutionPolicy Bypass -Scope Process -Force; Start-Sleep -Seconds 10; ipmo PSWindowsUpdate -Force | Out-File C:\temp\PSWindowsUpdate_installation.log } -Confirm:$false -Verbose -RunNow
##########################

#Checkmk Hostname
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

#Server source
$computer = Get-Content E:\Scripts\serverlist.txt

#Deprecated
#Invoke-WUInstall -ComputerName $computer -Script {Get-WindowsUpdate -Install -AcceptAll | Out-File C:\temp\wsus_logs\PSWindowsUpdate.log  -Confirm:$false -Verbose –RunNow }

#Install Available updates w/o reboot
#Invoke-WUJob -ComputerName $computer -Script {Install-WindowsUpdate -AcceptAll | Out-File C:\temp\wsus_logs\PSWindowsUpdate.log } -RunNow -Confirm:$false


#Install Available updates with reboot
Invoke-WUJob -ComputerName $computer -Script {Install-WindowsUpdate -AcceptAll -AutoReboot | Out-File C:\temp\wsus_logs\PSWindowsUpdate.log } -RunNow -Confirm:$false
Invoke-WUJob -ComputerName $computer -Script {Install-WindowsUpdate -AcceptAll -AutoReboot | Out-File "C:\temp\wsus_logs\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -force} -RunNow -Confirm:$false

Install-WindowsUpdate -ComputerName BDH04TRMMM1-1.mmsrg.net -MicrosoftUpdate -AcceptAll -IgnoreReboot -SendReport –PSWUSettings @{SmtpServer="smtprelay.media-saturn.com";From="wsus_updater@media-saturn.com";To="glavelis@media-saturn.com";Port=25} -Verbose
Invoke-WUJob -ComputerName $computer -Script {Install-WindowsUpdate -AcceptAll - IgnoreReboot -SendReport –PSWUSettings @{SmtpServer="smtprelay.media-saturn.com";From="wsus_updater@media-saturn.com";To="glavelis@media-saturn.com";Port=25} -Verbose }




# Copy PSwindowsUpdate Module to target Hosts - with Creds
$sourcePath = "E:\Scripts\PSWindowsUpdate"
$destPath = "C:\windows\system32\WindowsPowershell\v1.0\Modules"
Get-Content E:\Scripts\serverlist.txt| foreach {
    $Session = New-PSSession -ComputerName "$_" -Credential (Get-Credential mmsrg\adm-glavelis);
    copy-item -Path $sourcePath -Destination $destPath -recurse -ToSession $Session -Force
    }

# Copy PSwindowsUpdate Module to target Hosts - with Creds
$sourcePath = "E:\Scripts\PSWindowsUpdate"
$destPath = "C:\Program Files\WindowsPowerShell\Modules"
Get-Content E:\Scripts\serverlist.txt| foreach {
    $Session = New-PSSession -ComputerName "$_" -Credential (Get-Credential mmsrg\adm-glavelis);
    copy-item -Path $sourcePath -Destination $destPath -recurse -ToSession $Session -Force
    }


# Copy PSwindowsUpdate Module to target Hosts - w/o Creds
$sourcePath = "E:\Scripts\PSWindowsUpdate"
$destPath = "C:\windows\system32\WindowsPowershell\v1.0\Modules"
Get-Content E:\Scripts\serverlist.txt| foreach {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath -Destination $destPath -recurse -ToSession $Session -Force
    }

    # Copy PSwindowsUpdate Module to target Hosts - w/o Creds
$sourcePath = "E:\Scripts\PSWindowsUpdate"
$destPath = "C:\Program Files\WindowsPowerShell\Modules"
Get-Content E:\Scripts\serverlist.txt| foreach {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath -Destination $destPath -recurse -ToSession $Session -Force
    }


#CheckMK Maintenance Call
Invoke-WebRequest "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=downtime%20due%20to%20planned%20reboot,%20via%20Serverreboot.exe&_down_from_now=From+now+for&_down_minutes=15&host=$checkmkHost"

#Get CheckMK ID locally
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

#Get CheckMK ID remotely
$checkmkHost = Invoke-Command -ComputerName TST04TRMMM1-1.mmsrg.net {(Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject}