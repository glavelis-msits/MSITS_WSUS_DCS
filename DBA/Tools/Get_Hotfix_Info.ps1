
Function Get-MSHotfix  
{  
    $outputs = Invoke-Expression "wmic qfe list"  
    $outputs = $outputs[1..($outputs.length)]  
      
      
    foreach ($output in $Outputs) {  
        if ($output) {  
            $output = $output -replace 'Security Update','Security-Update'  
            $output = $output -replace 'NT AUTHORITY','NT-AUTHORITY'  
            $output = $output -replace '\s+',' '  
            $parts = $output -split ' ' 
            if ($parts[5] -like "*/*/*") {  
                $Dateis = [datetime]::ParseExact($parts[5], '%M/%d/yyyy',[Globalization.cultureinfo]::GetCultureInfo("en-US").DateTimeFormat)  
            } else {  
                $Dateis = get-date([DateTime][Convert]::ToInt64("$parts[5]", 16)) -Format '%M/%d/yyyy'  
            }  
            New-Object -Type PSObject -Property @{  
                KBArticle = [string]$parts[0]  
                Computername = [string]$parts[1]  
                Description = [string]$parts[2]  
                FixComments = [string]$parts[6]  
                HotFixID = [string]$parts[3]  
                InstalledOn = Get-Date($Dateis)-format "dddd d MMMM yyyy"  
                InstalledBy = [string]$parts[4]  
                InstallDate = [string]$parts[7]  
                Name = [string]$parts[8]  
                ServicePackInEffect = [string]$parts[9]  
                Status = [string]$parts[10]  
            }  
        }  
    }  
} 

<# $A = Get-Content -Path "E:\Scripts\MSITS_WSUS_DCS\DBA\Tools\serverlist.txt"
$A | ForEach-Object Get-MSHotfix|Where-Object {($_.HotfixID -like "KB4524244") -or ($_.HotfixID -like "KB4520724")}|Out-GridView #>

$servers = "E:\Scripts\MSITS_WSUS_DCS\DBA\Tools\serverlist.txt"
 Get-Content $servers| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {
   Get-MSHotfix -ComputerName "$_" |Where-Object {($_.HotFixID -like "KB5003638")-or ($_.HotFixID -like "KB5001078")}   |Select-Object -Property Computername, HotFixID, InstalledOn, InstalledBy|Out-GridView
    }}; 