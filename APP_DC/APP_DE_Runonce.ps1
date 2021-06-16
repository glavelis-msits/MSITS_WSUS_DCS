
#Retrieve CheckMK Host ID
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

#Hostname
$FQDN = ([System.Net.Dns]::GetHostByName($ComputerName)).HostName

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


#Put the Host in Maintenance Mode in CheckMK for 45mins and message "WSUS-patching planned downtime"
#Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=45&host=$checkmkHost"
#Put the Host in Maintenance Mode in CheckMK for 120mins and message "WSUS-patching planned downtime"
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=120&host=$checkmkHost"

#Wait for the Webrequest to take effect
Start-Sleep -Seconds 60

#Start services shutdown
appde-stop-services 
Start-Sleep -Seconds 120

appde-stop-nssm-services 
Start-Sleep -Seconds 120

#Run Patch install
shutdown.exe /r /t 30 /c "Scheduled reboot"

