function TRMserverlist {
    $de_trm = Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=TRM,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties IPv4Address | FT DNSHostName -A -HideTableHeaders | Out-File "E:\Scripts\MSITS_WSUS_DCS\TRM\reporting\KB3080149\TRM_DE_ServerList_temp_2.txt" -force ;
    $b = Get-Content -Path "E:\Scripts\MSITS_WSUS_DCS\TRM\reporting\KB3080149\TRM_DE_ServerList_temp_2.txt" ;
    @(ForEach ($a in $b) {$a.Replace(' ', '')}) > "E:\Scripts\MSITS_WSUS_DCS\TRM\reporting\KB3080149\TRM_DE_ServerList_temp_1.txt" ;
    Get-Content "E:\Scripts\MSITS_WSUS_DCS\TRM\reporting\KB3080149\TRM_DE_ServerList_temp_1.txt" | Select-Object -Skip 1 | Out-File "E:\Scripts\MSITS_WSUS_DCS\TRM\reporting\KB3080149\TRM_DE_ServerList_final.txt" -force ;
    rm "E:\Scripts\MSITS_WSUS_DCS\TRM\reporting\KB3080149\TRM_DE_ServerList_temp_2.txt" -Force;
    rm "E:\Scripts\MSITS_WSUS_DCS\TRM\reporting\KB3080149\TRM_DE_ServerList_temp_1.txt" -Force;
}


TRMserverlist

         # Create Serverlist


$A = Get-Content -Path "E:\Scripts\MSITS_WSUS_DCS\TRM\reporting\KB3080149\TRM_DE_ServerList_final.txt"
$A | ForEach-Object { if (!(Get-HotFix -Id KB3080149 -ComputerName $_))
         { Add-Content $_ -Path "E:\Scripts\MSITS_WSUS_DCS\TRM\reporting\KB3080149\Missing-KB3080149.txt"}}