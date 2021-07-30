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
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject
function Write-Log {
    param (
        $message,
        [ValidateSet('INFO','WARNING','ERROR')]
        $level = 'INFO'
    )
    $MsgColors = @{'INFO' = 'Gray';'WARNING' = 'Yellow';'ERROR' = 'Red'}
 
    Write-Output "$(get-date -UFormat '%Y/%m/%d-%H:%M:%S')#$($level)# $message" | Out-File -FilePath "C:\temp\wsus\$($env:COMPUTERNAME)_$(get-date -format "dd-MMM-yyyy")_WSUS_errors.log" -Append
    Write-Host "$(get-date -UFormat '%Y/%m/%d-%H:%M:%S')#$($level)# $message" -ForegroundColor $MsgColors[$level]
}

Write-Verbose "MSITS Decentral APP-DC Powershell 5.1 deployment"
<# Function DeployPowershell51 {

try {
    wusa.exe 'C:\tasks\Win8.1AndW2K12R2-KB3191564-x64.msu' /quiet /noreboot
} catch {
    write-log "PS upgraded"
}
Start-Sleep -Seconds 60

Shutdown -r -t 180 /c "Powershell 5.1 Upgrade reconfiguration."

} #>

Function DeployPowershell51 {
$File = "C:\tasks\Win8.1AndW2K12R2-KB3191564-x64.msu"
                    C:\Windows\System32\wusa.exe $File /extract:"C:\Temp\"
                    sleep 5 # extracting isn't instant, so need to wait for it to complete, otherwise next line will return no results.
                    $cabs = Get-Childitem "C:\Temp\*.cab" # Luckily the CABs are ordered alphabetically, so in the correct order to install.
                    Foreach ($cab in $cabs){
                        Dism.exe /online /add-package /packagepath:$cab
                        }
						
						}

#### GMS/WWS Service management #####

function appde-stop-nssm-services {
$computerservices = 'PPX_Controller', 'StoreAgent', 'wildfly'

    foreach ($computerservice in $computerservices)
    {
        if ((Get-Service $computerservice).Status -eq "Running")
        {
		try {nssm stop $computerservice} 
		catch { Write-Log "Service $computerservice is stopped" -level Info}
		}
		else
		{ Write-Log "Service $computerservice is still running" -level Info
    }

}
}


function appde-stop-services {
$computerservices = 'bwengine', 'tibemsd', 'TIBHawkAgentESB-PRD-D01', 'Solid2'

    foreach ($computerservice in $computerservices)
    {
        if ((Get-Service $computerservice).Status -eq "Running")
        {
		try {
			Stop-Service -Name $computerservice -Force
        } catch {
			Write-Log "Failed to stop $computerservice" -Level Error
		}
        }
		else
		{
		Write-Log "Service $computerservice is still running" -Level Error
		#if (get-process "OutletServices_PP-OutletServices_PP.exe" -ErrorAction SilentlyContinue) {Stop-Process OutletServices_PP-OutletServices_PP.exe}
    }

}
}

#Put the Host in Maintenance Mode in CheckMK for 45mins and message "WSUS-patching planned downtime"
Write-Log "Setting maintenance mode for server" -LEvel Info
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=90&host=$checkmkHost"

#Wait for the Webrequest to take effect
Start-Sleep -Seconds 60

#Start services shutdown
appde-stop-services
Start-Sleep -Seconds 120
appde-stop-nssm-services
Start-Sleep -Seconds 120
DeployPowershell51 -AsJob

#Reboot the Server if not rebooted by update module after 45 mins.
Start-Sleep -Seconds 200

#Reboot Server
Restart-Computer
