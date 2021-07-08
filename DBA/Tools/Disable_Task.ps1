$servers = get-content "E:\Scripts\MSITS_WSUS_DCS\DBA\Tools\serverlist.txt"
foreach ($server in $servers)
{
  Disable-ScheduledTask -CimSession $server -TaskName "DBA_DE_W1_Test_WSUS_Monthly_Update" -EA Continue
}
