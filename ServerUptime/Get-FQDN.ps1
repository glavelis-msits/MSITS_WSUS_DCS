$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

function Get-FQDN ($ComputerName)
{
    try
    {
        $FQDN = ([System.Net.Dns]::GetHostByName($ComputerName)).HostName
    }
    catch
    {
        $FQDN = "$ComputerName not found"
    }
    return $FQDN
}
#
Get-Content $ScriptDir\serverlist.txt | ForEach-Object -Begin {
    New-Item -Path $ScriptDir\FQDNList.txt -ItemType File -Force | Out-Null
} -Process {
    Add-Content -Path $ScriptDir\FQDNList.txt -Value (Get-FQDN $_)
}