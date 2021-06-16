
<# $servers = "E:\Scripts\MSITS_WSUS_DCS\APP_DC\stores.txt"	
Get-Content $servers| ForEach-Object { #>
<# 
    #$Session = New-PSSession -ComputerName "$_" ;
	Invoke-Command -ComputerName "$_" -ScriptBlock {Shutdown -r -t 0}
    }  #>
<# $Session = New-PSSession -ComputerName "$_" ; #>
<# $checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject

Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=120&host=$checkmkHost"
Start-Sleep -Seconds 15 #>
<# 

$RebootList = Get-Content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\stores.txt"
foreach( $Rsrv in $RebootList )
{
Write-host "Issuing remote reboot command to $Rsrv"
# Command to force reboot the remote server
(gwmi Win32_OperatingSystem -ComputerName $Rsrv).Win32Shutdown(6)
}
 #>


 	
cls

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


$servers = Get-content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\stores.txt"

Foreach($server in $servers)

{

#ping $server

#$before = Get-Service -ComputerName $server

Write-host "Restarting $server" -ForegroundColor Green

shutdown /m \\$server /r /t 0 /c "Forced reboot"

#ping $server -n 50#

#$after = Get-Service -ComputerName $server

#diff $before $after -Property Name, Status

#Read-Host "Press Enter to continue…" | Out-Null

}