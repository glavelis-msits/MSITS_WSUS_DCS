
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


$pw = Get-Content "\\ing04wsus01p\wsus_crd\soldbdedba.txt" 
$pws = ConvertTo-SecureString -String $pw -AsPlainText -Force
$soldbpass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pws))

Clear-Host

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

#Reboot Server
shutdown -r -t 60