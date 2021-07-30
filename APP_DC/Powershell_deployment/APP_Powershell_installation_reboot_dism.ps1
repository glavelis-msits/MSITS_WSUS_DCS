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



Function DeployPowershell51 {
$File = "C:\tasks\Win8.1AndW2K12R2-KB3191564-x64.msu"
C:\Windows\System32\wusa.exe $File /extract:"C:\Temp\"
sleep 5 # extracting isn't instant, so need to wait for it to complete, otherwise next line will return no results.
$cabs = Get-Childitem "C:\Temp\*.cab" # Luckily the CABs are ordered alphabetically, so in the correct order to install.
Foreach ($cab in $cabs){
Dism.exe /online /add-package /packagepath:$cab
}
}

function appde-stop-services {
$services = 'bwengine', 'tibemsd', 'TIBHawkAgentESB-PRD-D01', 'Solid2'

    foreach ($service in $services)
    {
        if ((Get-Service $service).Status -eq "Running")
        {
		Stop-Service -Name $service
		Write-Host "Service $service is stopped" -ForegroundColor Green
        
        }
		else
		{ Write-Host "Service $service is still running" -ForegroundColor Red
    }

}
}

function appde-stop-nssm-services {
$services = 'PPX_Controller', 'StoreAgent', 'wildfly'

    foreach ($service in $services)
    {
        if ((Get-Service $service).Status -eq "Running")
        {
		nssm stop $service
		Write-Host "Service $service is stopped" -ForegroundColor Green
        
        }
		else
		{ Write-Host "Service $service is still running" -ForegroundColor Red
    }

}
}

$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=45&host=$checkmkHost"

appde-stop-services
Start-Sleep -Seconds 120
appde-stop-nssm-services
Start-Sleep -Seconds 120

shutdown -r -t 200

DeployPowershell51
