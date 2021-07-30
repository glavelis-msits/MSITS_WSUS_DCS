$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   

   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   

   $newProcess.Verb = "runas";
   

   [System.Diagnostics.Process]::Start($newProcess);
   
   exit
   }

Clear-Host

Write-Verbose "MSITS Decentral APP-DC Powershell 5.1 deployment"

$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

Function DeployPowershell51 {
$File = "C:\tasks\Win8.1AndW2K12R2-KB3191564-x64.msu"
C:\Windows\System32\wusa.exe $File /extract:"C:\Temp\"
sleep 5 # extracting isn't instant, so need to wait for it to complete, otherwise next line will return no results.
$cabs = Get-Childitem "C:\Temp\*.cab" # Luckily the CABs are ordered alphabetically, so in the correct order to install.
Foreach ($cab in $cabs){
Dism.exe /online /add-package /packagepath:$cab
}
}

#Put the Host in Maintenance Mode in CheckMK for 45mins and message "PS Upgrade downtime"
Clear-Host
Write-Host "========== Entering CheckMK Maintenance Mode   ============="
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=45&host=$checkmkHost"

#Wait for the Webrequest to take effect
Start-Sleep -Seconds 60

#Start services shutdown
#Tibco Hawk Agent
 Write-Host "================ Shutting down Hawk Agent  ================"
Get-Process | Where-Object { $_.Name -eq "hawkagent_ESB-PRD-D01" } | Stop-Process -force
#Tibco BW-Engine
 Write-Host "================ Shutting down BW Engine   ================"
Get-Process | Where-Object { $_.ProcessName -eq "tibemsd" } | Stop-Process -force
#Wildfly
 Write-Host "================ Shutting down Wildfly     ================"
Get-Process | Where-Object { $_.Name -eq "nssm" } | Stop-Process -force

 Write-Host "================ Shutting down Solid 1313  ================"
solsql "tcp 1313" TA_MON_ITSMT $soldbpass C:\tasks\1313.sql | Out-File C:\temp\wsus\$FQDN-$(get-date -f dd-MM-yyyy)-SolDB_1313_log.txt

#Wait for SolidDB 1313 to shutdown
Start-Sleep -Seconds 30

 Write-Host "================ Shutting down Solid 1414 ================"
solsql "tcp 1414" TA_MON_ITSMT $soldbpass C:\tasks\1414.sql | Out-File C:\temp\wsus\$FQDN-$(get-date -f dd-MM-yyyy)-SolDB_1414_log.txt

#Wait for SolidDB 1414 to shutdown
Start-Sleep -Seconds 30


shutdown -r -t 200

DeployPowershell51

