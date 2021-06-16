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
Function Serverreboot {
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=Planned%downtime&_down_from_now=From+now+for&_down_minutes=120&host=$checkmkHost"

Start-Sleep -Seconds 30

Shutdown -r -t 180 /c "Powershell 5.1 Upgrade reconfiguration."

}

function appde-start-services {
$services = 'bwengine', 'tibemsd', 'TIBHawkAgentESB-PRD-D01', 'Solid2'

    foreach ($service in $services)
    {
        if ((Get-Service $service).Status -eq "Stopped")
        {
		Start-Service -Name $service
		Write-Host "Service $service is starting" -ForegroundColor Red
        
        }
		else
		{ Write-Host "Service $service is running" -ForegroundColor Green 
    }

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


function appde-start-nssm-services {
$services = 'PPX_Controller', 'StoreAgent', 'wildfly'

    foreach ($service in $services)
    {
        if ((Get-Service $service).Status -eq "Stopped")
        {
		nssm start $service
		Write-Host "Service $service is starting" -ForegroundColor Red
        
        }
		else
		{ Write-Host "Service $service is running" -ForegroundColor Green 
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




appde-stop-services
Start-Sleep -Seconds 120
appde-stop-nssm-services
Start-Sleep -Seconds 120
Serverreboot
