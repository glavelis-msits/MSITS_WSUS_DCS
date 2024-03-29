param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit
}

'Running with Elevated Admin privileges'



Set-ExecutionPolicy Unrestricted -Force ;

function solid_checks {
$solid = Get-Service solid
$solid.WaitForStatus('Running','00:05:00')
if ($solid.Status -ne 'Running') 
  { Write-Warning 'Solid is not running !!!' }

else

{ Write-Host "Solid is running!" -ForegroundColor Green }


$solid0 = Get-Service solid0
$solid0.WaitForStatus('Running','00:05:00')
if ($solid0.Status -ne 'Running') 
  { Write-Warning 'Solid0 is not running !!!' }

else

{ Write-Host "Solid0 is running!" -ForegroundColor Green }

$solid262 = Get-Service solid262
$solid262.WaitForStatus('Running','00:05:00')
if ($solid262.Status -ne 'Running') 
  { Write-Warning 'Solid262 is not running!!!' }

else

{ Write-Host "Solid262 is running!" -ForegroundColor Green }

}



function fqdn {
$FQDN = ([System.Net.Dns]::GetHostByName($ComputerName)).HostName
if($FQDN -like '*DBAMM*') {
     $FQDN -replace  'DBAMM', 'APPMM'
} elseif ($FQDN -like '*DBASE*')
{
      $FQDN -replace 'DBASE', 'APPSE'
}
  else {$FQDN -replace 'DBAWH', 'APPWH'
  }
}


$comp = fqdn

Start-Sleep -Seconds 60

solid_checks

Start-Sleep -Seconds 60

Invoke-Command -ComputerName $comp -ScriptBlock {Get-Service -Name "wildfly" | Restart-Service}
