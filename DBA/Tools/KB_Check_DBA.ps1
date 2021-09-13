# Create Serverlist
function DBAserverlist {
$ScriptDir = 'E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149'

Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -force ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=AT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=BE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=CH,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=ES,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=GR,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=HK,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=HU,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=IT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=LU,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=NL,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=PL,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=PT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=RB,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=RO,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=SE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=TR,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBAMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;

$content_mm = Get-Content "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" ;
$content_mm | Foreach {$_.TrimEnd()} |  Set-Content "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList.txt" ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBASE_DE_ServerList_temp.txt" -force ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=AT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=BE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=CH,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=ES,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=GR,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=HK,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=HU,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=IT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=LU,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=NL,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=PL,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=PT,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=RB,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=RO,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=SE,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
Get-ADComputer -Filter * -SearchBase "OU=DBA,OU=TR,OU=Server,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04DBASE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt" -Append ;
$content_se = Get-Content "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBASE_DE_ServerList_temp.txt" ;
$content_se | Foreach {$_.TrimEnd()} |  Set-Content "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBASE_DE_ServerList.txt" ;
rm "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList_temp.txt"
rm "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBASE_DE_ServerList_temp.txt"

# Build the file list
$outfile = "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\temp\merged.txt"
foreach ($file in $ScriptDir)
{

Get-ChildItem -Path E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149 -Filter "*.txt" | Get-Content | select -Skip 1 | Out-File -FilePath $outfile -Encoding ascii;
   
}

Get-Content $outfile | ? {$_.trim() -ne "" } | set-content "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\merged_final.txt"
$stream = [IO.File]::OpenWrite('E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\merged_final.txt')
$stream.SetLength($stream.Length - 1)
$stream.Close()
$stream.Dispose()
rm $outfile
rm "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBAMM_DE_ServerList.txt"
rm "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\DBASE_DE_ServerList.txt"
}

DBAserverlist


$A = Get-Content -Path "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\merged_final.txt"
$A | ForEach-Object { if (!(Get-HotFix -Id KB3080149 -ComputerName $_))
         { Add-Content $_ -Path "E:\Scripts\MSITS_WSUS_DCS\DBA\reporting\KB3080149\Missing-KB3080149.txt"}}