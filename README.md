# MSITS_WSUS_DCS
 Decentral Store WSUS Automation Repo
- PSWindowsUpdate |
WSUS Update Module
- ServerUptime |
Server Info collection script
- WSUS_Update_check.xml |
Automated Task export

Steps to take:
Create folder structure
    C:\tasks
    C:\temp\wsus
    C:\wsus\wsus_logs

Deploy WSUS Update module (Path C:\Program Files\WindowsPowerShell\Modules)

Run deploy_prep (Maintenance mode added)

Create deployment lists

Graceful shutdown of SolidDB Server

Run Update

#######################
DE TRMs are updated every Sunday at 04:00 and rebooted every Monday at 04:00
DE App/DC - DBA Server Test Group Created
Test Group DE App/DC Servers will be Updated on every first Tuesday of the Month at 04:00 CET
Test Group DE DBA Servers will be Updated on every first Thursday of the Month at 04:00 CET

ToDo:
Create SolidDB Service account (DBA Servers)


Scripts:
APP/DC Specific:
APP_DE_wsus_deploy_prep_v1.3.ps1
APP_DE_deploy_Tasks.ps1
APP_DE_reboot.ps1
APP_DE_reboot.xml
APP_DE_wsus_local_update_reboot.ps1
APP_DE_WSUS_Monthly_Update.xml

TRM_DE Specific:
TRM_deploy_Tasks.ps1
TRM_weekly_powercycle.ps1
TRM_weekly_powercycle.xml
TRM_wsus_deploy_prep.ps1
TRM_wsus_local_update_no_reboot_w_report.ps1
TRM_wsus_local_update_reboot.ps1
TRM_WSUS_Weekly_Update.xml

DBA_DE Specific:

General purpose:
Reboot_scheduler    
Task_removal
Reporting\ServerUptime\Get_UpTime_APP_DE_Server.ps1
Reporting\ServerUptime\Get-FQDN.ps1
Reporting\ServerUptime\Get-UpTime_TRM_DE_Server.ps1
Reporting\ServerUptime\serverlist.txt
Reporting\ServerUptime\FQDNList.txt
Reporting\AD\DE_serverlists.ps1