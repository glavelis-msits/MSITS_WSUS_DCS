
<# function Test-Partner-Connectivity {

Foreach($computer in $ComputerName)

{

  if(!(Test-Connection -Cn $computer -BufferSize 16 -Count 1 -ea 0 -quiet))

  {

   “Problem connecting to $computer”

   “Flushing DNS”

   ipconfig /flushdns | out-null

   “Registering DNS”

   ipconfig /registerdns | out-null

  “doing a NSLookup for $computer”

   nslookup $computer

   “Re-pinging $computer”

     if(!(Test-Connection -Cn $computer -BufferSize 16 -Count 1 -ea 0 -quiet))

      {“Problem still exists in connecting to $computer” Exit}

       ELSE {“Resolved problem connecting to $computer”}  #end if

   } # end if

} # end foreach

} #>

#Test-Partner-Connectivity

function appde-stop-nssm-services {
$computerservices = 'PPX_Controller', 'StoreAgent', 'wildfly'

    foreach ($computerservice in $computerservices)
    {
        if ((Get-Service $computerservice).Status -eq "Running")
        {
		nssm stop $computerservice
		Write-Host "Service $computerservice is stopped" -ForegroundColor Green
        
        }
		else
		{ Write-Host "Service $computerservice is still running" -ForegroundColor Red
    }

}
}

function appde-stop-services {
$computerservices = 'bwengine', 'tibemsd', 'TIBHawkAgentESB-PRD-D01', 'Solid2'

    foreach ($computerservice in $computerservices)
    {
        if ((Get-Service $computerservice).Status -eq "Running")
        {
		Stop-Service -Name $computerservice
		Write-Host "Service $computerservice is stopped" -ForegroundColor Green
        
        }
		else
		{ Write-Host "Service $computerservice is still running" -ForegroundColor Red
    }

}
}


#Start services shutdown
appde-stop-services 
Start-Sleep -Seconds 120

appde-stop-nssm-services 
Start-Sleep -Seconds 120

#Reboot Server
shutdown -r -t 60