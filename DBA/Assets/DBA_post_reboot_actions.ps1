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

function fqdn {
$FQDN = ([System.Net.Dns]::GetHostByName($ComputerName)).HostName
if($FQDN -like '*DBAMM*') {
     $FQDN -replace  'DBAMM', 'APPMM'
} else {
      $FQDN -replace 'DBASE', 'APPSE'
}

}

$comp = fqdn

Get-Process -ComputerName $comp | Where-Object { $_.Name -eq "nssm" } #| Stop-Process -force ;

Start-Sleep -Seconds 60

Get-Process -ComputerName $comp | Where-Object { $_.Name -eq "nssm" } #| Start-Process -force

<# $p = Get-Process -Name "nssm"
Stop-Process -InputObject $p
Get-Process | Where-Object {$_.HasExited} #>
