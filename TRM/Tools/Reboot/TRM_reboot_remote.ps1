# Determine running dir
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$Title = 'MSITS DBA-DC Store Server WSUS Report'

function Maintenance_mode {
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }
[ServerCertificateValidationCallback]::Ignore()

$chkmkids= Get-Content "$ScriptDir\CheckMKIDs.txt"
foreach ($chkmkid in $chkmkids)
{

Invoke-WebRequest -Uri "https://ffm04mannws13p/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=WSUS-patching%planned%downtime&_down_from_now=From+now+for&_down_minutes=20&host=$chkmkid" -ErrorAction SilentlyContinue 
   
}
 
 }

 
  function Reboot_servers {

$server= Get-Content "$ScriptDir\Servers.txt"
 
Invoke-Command -ComputerName $server -filepath "$ScriptDir\TRM_reboot_wo_maintenance.ps1" -ErrorAction SilentlyContinue

  }
  

  
Maintenance_mode

Start-Sleep -Seconds 30

Reboot_servers






