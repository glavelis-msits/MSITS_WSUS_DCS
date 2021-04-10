
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

function Show-Menu {
    param (
        [string]$Title = 'AD Server List Creation'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to extract DE APP & DC Servers."
    Write-Host "2: Press '2' to extract DE DBA Servers."
    Write-Host "3: Press '3' to extract DE TRM Servers."
    Write-Host "Q: Press 'Q' to quit."
}


do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
    $de_appdc = Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=Domain Controllers,DC=mmsrg,DC=net" -Properties IPv4Address | FT DNSHostName -A;
    $de_appdc | Out-File "$ScriptDir\DE_serverlists_reports\$(get-date -f dd-MM-yyyy)-APP_DC_ServerList.txt" -force
    } '2' {
    $de_dba = Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=DBA,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties IPv4Address | FT DNSHostName -A ;
    $de_dba | Out-File "$ScriptDir\DE_serverlists_reports\$(get-date -f dd-MM-yyyy)-DBA_ServerList.txt" -force
     } '3' {
    $de_trm = Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=TRM,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties IPv4Address | FT DNSHostName -A ;
    $de_trm | Out-File "$ScriptDir\DE_serverlists_reports\$(get-date -f dd-MM-yyyy)-TRM_ServerList.txt" -force
    }
    }
    pause
 }
 until ($selection -eq 'q')