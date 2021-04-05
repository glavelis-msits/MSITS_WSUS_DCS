# MSITS_WSUS_DCS
 Decentral Store WSUS Automation Repo
- PSWindowsUpdate |
WSUS Update Module
- ServerUptime |
Server Info collection script
- WSUS_Update_check.xml |
Automated Task export

Steps to be taken:
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
App - DBA Server Test Group Created
App Servers will be Updated on every first Tuesday of the Month at 04:00 CET
DBA Servers will be Updated on every first Thursday of the Month at 04:00 CET

ToDo:
Add PSVersion check (min 5.1)
Create SolidDB Service account (DBA Servers)