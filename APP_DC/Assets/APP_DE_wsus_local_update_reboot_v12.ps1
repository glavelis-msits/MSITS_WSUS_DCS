#Retrieve CheckMK Host ID
$checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject
#Error action
$ErrorActionPreference = 'Stop'
#Hostname
$FQDN = ([System.Net.Dns]::GetHostByName($ComputerName)).HostName
# Determine Partner Server
$ComputerName = $FQDN -replace  'APPMM', 'DBAMM'

function Test-Partner-Connectivity {

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

}

Test-Partner-Connectivity

<# #Partner Check
$computercriptBlock = {

    $VerbosePreference = $using:VerbosePreference
    function Test-RegistryKey {
        [OutputType('bool')]
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Key
        )
    
        $ErrorActionPreference = 'Stop'

        if (Get-Item -Path $Key -ErrorAction Ignore) {
            $true
        }
    }

    function Test-RegistryValue {
        [OutputType('bool')]
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Key,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Value
        )
    
        $ErrorActionPreference = 'Stop'

        if (Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) {
            $true
        }
    }

    function Test-RegistryValueNotNull {
        [OutputType('bool')]
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Key,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Value
        )
    
        $ErrorActionPreference = 'Stop'

        if (($regVal = Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) -and $regVal.($Value)) {
            $true
        }
    }

    # Added "test-path" to each test that did not leverage a custom function from above since
    # an exception is thrown when Get-ItemProperty or Get-ChildItem are passed a nonexistant key path
    $tests = @(
        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }
        { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress' }
        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' }
        { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending' }
        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting' }
        { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations' }
        { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations2' }
        { 
            # Added test to check first if key exists, using "ErrorAction ignore" will incorrectly return $true
            'HKLM:\SOFTWARE\Microsoft\Updates' | Where-Object { test-path $_ -PathType Container } | ForEach-Object {            
                (Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0 
            }
        }
        { Test-RegistryValue -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Value 'DVDRebootSignal' }
        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttemps' }
        { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain' }
        { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'AvoidSpnSet' }
        {
            # Added test to check first if keys exists, if not each group will return $Null
            # May need to evaluate what it means if one or both of these keys do not exist
            ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' | Where-Object { test-path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } ) -ne 
            ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' | Where-Object { Test-Path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } )
        }
        {
            # Added test to check first if key exists
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending' | Where-Object { 
                (Test-Path $_) -and (Get-ChildItem -Path $_) } | ForEach-Object { $true }
        }
    )

    foreach ($test in $tests) {
        Write-Verbose "Running scriptblock: [$($test.ToString())]"
        if (& $test) {
            $true
            break
        }
    }
}

foreach ($computer in $ComputerName) {
    try {
        $connParams = @{
            'ComputerName' = $computer
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $connParams.Credential = $Credential
        }

        $output = @{
            ComputerName    = $computer
            IsPendingReboot = $false
        }

        $psRemotingSession = New-PSSession @connParams
        
        if (-not ($output.IsPendingReboot = Invoke-Command -Session $psRemotingSession -ScriptBlock $computercriptBlock)) {
            $output.IsPendingReboot = $false
        }
        [pscustomobject]$output
    } catch {
        Write-Error -Message $_.Exception.Message
    } finally {
        if (Get-Variable -Name 'psRemotingSession' -ErrorAction Ignore) {
            $psRemotingSession | Remove-PSSession
        }
    }
}

if(!$output.IsPendingReboot) 
{ Write-Host "Reboot is not pending for $computer" }

else { Write-Host "Reboot is pending for $computer" Exit } #>




#### GMS/WWS Service management #####

function appde-start-services {
$computerervices = 'bwengine', 'tibemsd', 'TIBHawkAgentESB-PRD-D01', 'Solid2'

    foreach ($computerervice in $computerervices)
    {
        if ((Get-Service $computerervice).Status -eq "Stopped")
        {
		Start-Service -Name $computerervice
		Write-Host "Service $computerervice is starting" -ForegroundColor Red
        
        }
		else
		{ Write-Host "Service $computerervice is running" -ForegroundColor Green 
    }

}
}


function appde-stop-services {
$computerervices = 'bwengine', 'tibemsd', 'TIBHawkAgentESB-PRD-D01', 'Solid2'

    foreach ($computerervice in $computerervices)
    {
        if ((Get-Service $computerervice).Status -eq "Running")
        {
		Stop-Service -Name $computerervice
		Write-Host "Service $computerervice is stopped" -ForegroundColor Green
        
        }
		else
		{ Write-Host "Service $computerervice is still running" -ForegroundColor Red
    }

}
}


function appde-start-nssm-services {
$computerervices = 'PPX_Controller', 'StoreAgent', 'wildfly'

    foreach ($computerervice in $computerervices)
    {
        if ((Get-Service $computerervice).Status -eq "Stopped")
        {
		nssm start $computerervice
		Write-Host "Service $computerervice is starting" -ForegroundColor Red
        
        }
		else
		{ Write-Host "Service $computerervice is running" -ForegroundColor Green 
    }

}
}


function appde-stop-nssm-services {
$computerervices = 'PPX_Controller', 'StoreAgent', 'wildfly'

    foreach ($computerervice in $computerervices)
    {
        if ((Get-Service $computerervice).Status -eq "Running")
        {
		nssm stop $computerervice
		Write-Host "Service $computerervice is stopped" -ForegroundColor Green
        
        }
		else
		{ Write-Host "Service $computerervice is still running" -ForegroundColor Red
    }

}
}




#Put the Host in Maintenance Mode in CheckMK for 45mins and message "WSUS-patching planned downtime"
#Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=45&host=$checkmkHost"
#Put the Host in Maintenance Mode in CheckMK for 90mins and message "WSUS-patching planned downtime"
Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=90&host=$checkmkHost"

#Wait for the Webrequest to take effect
Start-Sleep -Seconds 60

#Start services shutdown
appde-stop-services 
Start-Sleep -Seconds 120

appde-stop-nssm-services 
Start-Sleep -Seconds 120


#Run Patch install
Install-WindowsUpdate -AcceptAll -Install -AutoReboot  | Out-File "C:\temp\wsus\wsus_logs\$FQDN-$(get-date -f dd-MM-yyyy)-WindowsUpdate.log" -force

#Purge logs older than 180 day(s)
$Pathlog = "C:\temp\wsus\wsus_logs"
$Daysback = "-180"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Pathlog | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item