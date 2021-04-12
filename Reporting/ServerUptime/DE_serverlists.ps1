
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

function ServerList-DE_APP {

$latest_app_de_path = "$ScriptDir\DE_serverlists_reports"
$latest_app_de_list = (Get-ChildItem -Path $latest_app_de_path -filter *APP* | Sort-Object LastAccessTime -Descending | Select-Object -First 1).Name
$latest_app_de_list_output = Get-Content $latest_app_de_path\$latest_app_de_list
$latest_app_de_list_output  | Select-Object -Skip 3 | Out-File $latest_app_de_path\"clean_"$latest_app_de_list

}

function ServerList-DE_DBA {

$latest_dba_de_path = "$ScriptDir\DE_serverlists_reports"
$latest_dba_de_list = (Get-ChildItem -Path $latest_dba_de_path -filter *DBA* | Sort-Object LastAccessTime -Descending | Select-Object -First 1).Name
$latest_dba_de_list_output = Get-Content $latest_dba_de_path\$latest_dba_de_list
$latest_dba_de_list_output  | Select-Object -Skip 3 | Out-File $latest_dba_de_path\"clean_"$latest_dba_de_list

}


function ServerList-DE_TRM {

$latest_trm_de_path = "$ScriptDir\DE_serverlists_reports"
$latest_trm_de_list = (Get-ChildItem -Path $latest_trm_de_path -filter *TRM* | Sort-Object LastAccessTime -Descending | Select-Object -First 1).Name
$latest_trm_de_list_output = Get-Content $latest_trm_de_path\$latest_trm_de_list
$latest_trm_de_list_output  | Select-Object -Skip 3 | Out-File $latest_trm_de_path\"clean_"$latest_trm_de_list

}


function Show-Menu {
    param (
        [string]$Title = 'MSITS AD Server List Creation'
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
    $de_appdc | Out-File "$ScriptDir\DE_serverlists_reports\$(get-date -f dd-MM-yyyy)-APP_DC_ServerList.txt" -force ;
    ServerList-DE_APP
    } '2' {
    $de_dba = Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=DBA,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties IPv4Address | FT DNSHostName -A ;
    $de_dba | Out-File "$ScriptDir\DE_serverlists_reports\$(get-date -f dd-MM-yyyy)-DBA_ServerList.txt" -force;
    ServerList-DE_DBA
     } '3' {
    $de_trm = Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=TRM,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties IPv4Address | FT DNSHostName -A ;
    $de_trm | Out-File "$ScriptDir\DE_serverlists_reports\$(get-date -f dd-MM-yyyy)-TRM_ServerList.txt" -force;
    ServerList-DE_TRM
    }
    }
    pause
 }
 until ($selection -eq 'q')
 stop-process -Id $PID