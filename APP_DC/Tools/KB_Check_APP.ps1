# Create Serverlist
function APPserverlist {
$ScriptDir = "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149"

Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04APPMM*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPMM_DE_ServerList_temp.txt" -force ;
$content_mm = Get-Content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPMM_DE_ServerList_temp.txt" ;
$content_mm | Foreach {$_.TrimEnd()} |  Set-Content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPMM_DE_ServerList.txt" ;
Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,DC=mmsrg,DC=net" -Properties dnshostname | Where-Object { $_.DNSHostName -like "*04APPSE*.mmsrg.net"} | Sort-Object DNSHostName -Descending |ft DNSHostName -A -HideTableHeaders| Out-File "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPSE_DE_ServerList_temp.txt" -force ;
$content_se = Get-Content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPSE_DE_ServerList_temp.txt" ;
$content_se | Foreach {$_.TrimEnd()} |  Set-Content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPSE_DE_ServerList.txt" ;
rm "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPMM_DE_ServerList_temp.txt"
rm "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPSE_DE_ServerList_temp.txt"

# Build the file list
$outfile = "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\temp\merged.txt"
foreach ($file in $ScriptDir )
{

Get-ChildItem -Path "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149" -Filter "*.txt" | Get-Content | select -Skip 1 | Out-File -FilePath $outfile -Encoding ascii -Append;
   
}

Get-Content $outfile | ? {$_.trim() -ne "" } | set-content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\merged_final.txt"
$stream = [IO.File]::OpenWrite('E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\merged_final.txt')
$stream.SetLength($stream.Length - 1)
$stream.Close()
$stream.Dispose()
rm $outfile
rm "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPMM_DE_ServerList.txt"
rm "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\APPSE_DE_ServerList.txt"
}

APPserverlist


$A = Get-Content -Path "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\merged_final.txt"
$A | ForEach-Object { if (!(Get-HotFix -Id KB3080149 -ComputerName $_))
         { Add-Content $_ -Path "E:\Scripts\MSITS_WSUS_DCS\APP_DC\reporting\KB3080149\Missing-KB3080149.txt"}}






####################################################################################################################################################################

