################################# Provide your own path wherever it is highlighted as provide path ######################
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

# Create Serverlist
function TRMserverlist {
Get-ADComputer -Filter 'dnshostname -like "*.mmsrg.net"' -SearchBase "OU=TRM,OU=DE,OU=Server,DC=mmsrg,DC=net" -Properties IPv4Address | Sort-Object DNSHostName -Descending | FT DNSHostName -A -HideTableHeaders | Out-File "$ScriptDir\TRM_DE_ServerList_temp_2.txt" -force ;
$b = Get-Content -Path $ScriptDir\TRM_DE_ServerList_temp_2.txt ;
@(ForEach ($a in $b) {$a.Replace(' ', '')}) > $ScriptDir\TRM_DE_ServerList_temp_1.txt ;
Get-Content "$ScriptDir\TRM_DE_ServerList_temp_1.txt" | Select-Object -Skip 1 | Out-File "$ScriptDir\TRM_DE_ServerList_temp.txt" -force ;
rm "$ScriptDir\TRM_DE_ServerList_temp_2.txt" -Force;
rm "$ScriptDir\TRM_DE_ServerList_temp_1.txt" -Force;
}


#TRMserverlist

# Server List selection
$smp= Get-Content "$ScriptDir\TRM_DE_trigger.txt" # Premade list
#$smp= Get-Content "$ScriptDir\TRM_DE_ServerList_temp.txt"  # Automatic list extraction 

$infoObject=@()
$results=@()
foreach($s in $smp)
{
$s
$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
$infoObject = New-Object PSObject
$p=Test-Connection -ComputerName $s -BufferSize 16  -Count 1 -Quiet 
$checkmkHost = Invoke-Command -ComputerName $s {(Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS').CheckMKObject}
$rebootpending = ((Get-WURebootStatus -ComputerName $s -Confirm:$false).RebootRequired)
#$description = Get-WmiObject -Class Win32_quickfixengineering -ComputerName $s|select -ExpandProperty Description  -last 1
$app_wsupdrb_path = "\\$s\c$\tasks\TRM_wsus_local_update_reboot.ps1"
$app_wsupdrb = if (Test-Path $app_wsupdrb_path -PathType leaf) 
{"Exists"}
else
{"Missing"}
$app_powercycle_path = "\\$s\c$\tasks\TRM_weekly_powercycle.ps1"
$app_powercycle = if (Test-Path $app_powercycle_path -PathType leaf) 
{"Exists"}
else
{"Missing"}
$wsustask = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "TRM WSUS Weekly Update"}).State}
$wsustaskrb = Invoke-Command -ComputerName $s {(Get-ScheduledTask | Where-Object {$_.TaskName -eq "TRM_weekly_powercycle"}).State}
$Boottime= Get-WmiObject win32_operatingsystem 
$b=($boottime| select @{LABEL= "LastBootUpTime";EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}).Lastbootuptime
$service=Get-WmiObject -ClassName Win32_Service -Filter "StartMode='Auto' AND State<>'Running'"
$psversioncheck = Invoke-Command -ComputerName $s {$PSVersionTable.PSVersion.Major}
$up=(Get-CimInstance -ClassName win32_operatingsystem -ComputerName $s -ErrorAction Stop).LastBootUpTime 
$uptime=((Get-Date) - $up)

$infoObject|Add-Member -MemberType NoteProperty -Name "Hostname"  -value $s
$infoObject|Add-Member -MemberType NoteProperty -Name "CheckMK ID"  -value $checkmkHost
$infoObject|Add-Member -MemberType NoteProperty -Name "Reachable"  -value $p
$infoObject|Add-Member -MemberType NoteProperty -Name "Uptime Days"  -value $uptime.Days
$infoObject|Add-Member -MemberType NoteProperty -Name "Uptime Hours"  -value $uptime.Hours
$infoObject|Add-Member -MemberType NoteProperty -Name "Reboot Pending" -Value $rebootpending
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update script" -Value $app_wsupdrb
$infoObject|Add-Member -MemberType NoteProperty -Name "Reboot Script" -Value $app_powercycle
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Update Task" -Value $wsustask
$infoObject|Add-Member -MemberType NoteProperty -Name "WSUS Reboot Task" -Value $wsustaskrb
$infoObject|Add-Member -MemberType NoteProperty -Name "Powershell version" -Value $psversioncheck

$results+=$infoObject
}



$results|Export-csv "$ScriptDir\reporting\temp_TRM.csv" -NoTypeInformation 
Import-CSV "$ScriptDir\reporting\temp_TRM.csv" | ConvertTo-Html -Head $css  | Out-File "$ScriptDir\reporting\TRM_DE_Report-$(get-date -f dd-MM-yyyy).html" 
#rm "$ScriptDir\temp_TRM.csv"
#rm "$ScriptDir\TRM_DE_ServerList_temp.txt"
##################### Sending Mail ############################

<# $smtpServer = "Provide SMTP server" 
  $smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
  $msg = New-Object Net.Mail.MailMessage 
  $msg.To.Add("provide to Address")
  #$msg.cc.add("") 
        $msg.From = "Provide from address" 
  $msg.Subject = "Patch Report $(Get-Date)"
        $msg.IsBodyHTML = $true 
        $msg.Body = get-content "provide html address\ser4.html"
        $msg.Attachments.Add( "provide html address\ser4.html")
  $smtp.Send($msg) 
        $body = "" #>

 
 
 