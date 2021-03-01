$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path


$servers = get-content "$ScriptDir\FQDNList.txt"
foreach ($server in $servers)
{
  Unregister-ScheduledTask -CimSession $server -TaskName "TRM WSUS Weekly Update" -Confirm:$false
}