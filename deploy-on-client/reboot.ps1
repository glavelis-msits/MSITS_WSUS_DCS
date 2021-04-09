# This script is deployed on "clients", and will check if the current machine it's running on is 
# a DB server, an APP server, TeRMinal server, and reboot accordingly.
# It should be launched by a scheduled task, between 4-6 AM.
[cmdletbinding()]
param(
    [parameter(HelpMessage = "Force reboot regardless of time of launch?")]
    [switch]$force = $false
)

#region variables
#hours interval when it is safe to proceed with reboot checks and action
$safetoRebootStart, $safetoRebootEnd = @(4, 6)

#endregion variables

#region functions
# Is we admin? Can't do anything without admin (and elevated) permissions
function Get-ElevationStatus {
    $CurrentWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $CurrentPrincipal = new-object System.Security.Principal.WindowsPrincipal($CurrentWindowsID)

    if (-not $CurrentPrincipal.IsInRole(([System.Security.Principal.SecurityIdentifier]("S-1-5-32-544")).Translate([System.Security.Principal.NTAccount]).Value)) {
        return $false
    }
    else {
        return $true
    }
}

function Check-Partner {

    # check the hostname of our current computer, to see if we have a partner,
    # if the partner has a reboot pending.
    # If we are DBA, have a reboot pending and our APP partner has a reboot pending, 
    # we leave the APP reboot first.
    $safetoReboot = $false

    $computername = 'BLL04DBAMM1-1'
    $null = $computername -match "(?<pre>.*?)DBA(?<post>.*?)$"
    $partner = "$($Matches['pre'])APP$($Matches['post'])"

    # if we don't need to reboot, we don't need to reboot :)
    $chatDirectory = "${env:SystemDrive}\share\WSUSReboot\"
    if (! (Test-Path $chatDirectory)) { mkdir $chatDirectory }
    $rebootRequired = Get-WURebootStatus
    $rebootRequired 
    $rebootRequired | Export-Csv $chatDirectory\rebootrequired.csv -Delimiter ',' -Force
    if ($rebootRequired) {
        # Check if partner needs to reboot
        Import-Csv \\$partner\c$\Temp\WSUS\rebootRequired.csv -
    }
}

# logging function with colored output
function Write-Log {
    param (
        $message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        $level = 'INFO'
    )
    switch ($level) {
        'INFO' { $colors = @{ ForegroundColor = 'White'; BackgroundColor = 'Black' } }
        'WARNING' { $colors = @{ ForegroundColor = 'Yellow'; BackgroundColor = 'Black' } }
        'ERROR' { $colors = @{ ForegroundColor = 'Red'; BackgroundColor = 'Black' } }
        'SUCCESS' { $colors = @{ ForegroundColor = 'Green'; BackgroundColor = 'Black' } }
    }
    if (! (Test-Path $env:windir\WSUSClientLogs\)) { $null = New-Item -ItemType Directory -Path $env:windir\Logs\WSUSClientLogs\ -Force }
    $logFile = "${env:windir}\Logs\WSUSClientLogs\client_REBOOT_$(Get-Date -UFormat '+%Y-%m-%d_%H').log"
    Write-Output "$(get-date -UFormat '%Y/%m/%d-%H:%M:%S')#$($level)# $message" | Out-File -FilePath $logFile -Append
    Write-Host "$(get-date -UFormat '%Y/%m/%d-%H:%M:%S')#$($level)# $message" @colors
}

function Set-CheckMKMaintenace {
    param(
        # default maintenance period in minutes
        [int]$maintDurationMinutes = 15
    )

    $checkMKServer = 'ffm04mannws13p'

    # try to find checkmk host object for this server
    try {
        $checkmkHost = (Get-ItemProperty -path 'HKLM:\SOFTWARE\WoW6432Node\Microsoft\RebootByMGS' -ErrorAction Stop).CheckMKObject
    } catch [System.Management.Automation.ItemNotFoundException] {
        Write-Log "Could not find a CheckMK hostname for this server!" -level WARNING
    }

    # if we have found a CheckMK host object for this server, we can continue and create maintenance period
    if ($checkmkHost) {
        Invoke-WebRequest -Uri "https://$checkMKServer/INFMON01/check_mk/view.py?_do_confirm=Yes&_do_actions=yes&_transid=-1&view_name=hoststatus&site=&_ack_sticky=on&_ack_otify=off&output_format=JSON&_username=automation&_secret=504804f8-7ef3-47bc-90dc-553bee370d86&_down_comment=Weekly%planned%maintenance%reboot&_down_from_now=From+now+for&_down_minutes=$($maintDurationMinutes)&host=$($checkmkHost)"
    }
}

function Get-ProcessOutput {
    param (
        [string]$exe,
        [string]$arguments
    )
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $exe
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $arguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $result = New-Object psobject -Property @{
        stdOut = $stdout
        stdErr = $stderr
        exitCode = $p.ExitCode
    }

    return $result
}

function Stop-SolidDB {
    Write-Log "Attempting to stop the Solid DB service(s)" -level INFO
    # >>> 
    $result = Get-ProcessOutput -exe "solsql.exe" -arguments "sudo shutdown"
    if ($result -ne 0) {
        Write-Log "Something went wrong when attempting to turn off SolidDB" -level ERROR
    } else {
        Write-Log "SolidDB was turned off succesfully." -level SUCCESS
    }
}

function Stop-Services {
    param (
        $srvRole
    )

    switch ($srvRole) {
        "DBA" {
            Stop-SolidDB
        }
        "APP" {

        }
        "TRM" {

        }
        default { Write-Log "Undocumented server role, not stopping any services" -level INFO}
    }
}
#endregion functions

# main script block
# Besides logging, I appreciate a transcript
Start-Transcript -Path $env:USERPROFILE\WSUSClient_Transcript_$(Get-Date -UFormat '+%Y-%m-%d_%H-%M-%S').log
if (! (Get-ElevationStatus)) {
    Write-Log "Please run this in an elevated session!`nBye!" -level ERROR
    Exit
} else {
    Write-Log "We are running in an elevated session. We can proceed." -level SUCCESS
}

$now = Get-Date
if (! (($now.Hour -ge $safetoRebootStart) -and ($now.Hour -le $safetoRebootEnd))) {
    Write-Log "We should only try to reboot between $safetoRebootStart and $safetoRebootEnd" -level ERROR
    exit
}

$cleanShutdown = Stop-Services 

if ($force) {
    Write-Log "Got a `"FORCE`" parameter. Rebooting now!!" -level INFO
    #Restart-Computer -Force
}
Stop-Transcript
