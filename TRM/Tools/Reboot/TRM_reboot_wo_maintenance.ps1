
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

#Reboot Server
shutdown -r -t 60