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
    $logFile = "${env:windir}\Logs\WSUSClientLogs\client_INSTALL_$(Get-Date -UFormat '+%Y-%m-%d_%H').log"
    Write-Output "$(get-date -UFormat '%Y/%m/%d-%H:%M:%S')#$($level)# $message" | Out-File -FilePath $logFile -Append
    Write-Host "$(get-date -UFormat '%Y/%m/%d-%H:%M:%S')#$($level)# $message" @colors
}

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

function Install-PSWindowsUpdateModule { 
    $URI = 'https://psg-prod-eastus.azureedge.net/packages/pswindowsupdate.2.2.0.2.nupkg'
    $fname = "$env:USERPROFILE\pswindowsupdate.2.2.0.2.zip"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Log "Downloading the PSWindowsUpdate module from `"$URI`"" -level INFO
    try {
        Invoke-WebRequest -Uri $URI -OutFile $fname -ErrorAction Stop
    } catch {
        Write-Log "Could not download the module" -level ERROR
        return "Could not download"
    }    
    if (!(Test-Path $PSHOME\Modules\PSWindowsUpdate)) {
        Write-Log "Creating `"$PSHOME\Modules\PSWindowsUpdate`" where we'll store the module" -level INFO
        try {
            $null = mkdir $PSHOME\Modules\PSWindowsUpdate -Force
        } catch {
            Write-Log "Failed to create the module directory!" -level ERROR
            return "Could not create module directory"
        }
    }
    $Error.Clear()
    Write-Log "Extracting the module package to the `"$PSHOME\Modules\PSWindowsUpdate`" directory" -level INFO
    $shell = New-Object -ComObject shell.Application
    try {
        # the last parameter is optional, specifies options to the copy/extract operation.
        # 16 means "answer yes to all" for any dialog box that is displayed/overwrite existing.
        # source: https://docs.microsoft.com/en-us/windows/win32/shell/folder-copyhere
        $shell.NameSpace("$PSHOME\Modules\PSWindowsUpdate").CopyHere($shell.NameSpace($fname).Items(),16)
    } catch [System.Management.Automation.RuntimeException] {
        Write-Log "Failed to extract the package! The last error was: $($Error[0])" -level ERROR
        return "Could not extract!?"
    }
    return 0
}

function Check-WSUSModule {
    $installed = $false
    Write-Log "Checking for PSWindowsUpdate module..."
    foreach ($dir in $($env:PSModulePath -split ';')) {
        if (Test-Path "$dir\PSWindowsUpdate") { Write-Log "Found PSWindowsUpdate in `"$dir`"" -level SUCCESS; $installed = $true }
    }
    return $installed
}

# check if we should skip any updates, depending on the server role
function Get-Exclusions {
    param (
        [string]$role,
        [string]$ExclusionsFilePath = "\\server\wsusinfoshare\$role-exclusions.csv"
    )

    try {
        $exclusions = Get-Content $ExclusionsFilePath -ErrorAction Stop
    } catch [System.Management.Automation.ParameterBindingException] {
        Write-Log "ParameterBindingException`tPlease check the arguments for the Get-Exclusions function!" -level ERROR
        Write-Log "We will not have any exceptions when installing WSUS updates" -level WARNING
    } catch [System.UnauthorizedAccessException] {
        Write-Log "UnauthorizedAccessException`tGot ACCESS DENIED to $ExclusionsFilePath!" -level ERROR
        Write-Log "We will not have any exceptions when installing WSUS updates" -level WARNING
    } catch [System.Management.Automation.ItemNotFoundException] {
        Write-Log "ERROR:ItemNotFoundException`tThe file we're searching for is out for a quick smoke :(" -level ERROR
        Write-Log "We will not have any exceptions when installing WSUS updates" -level WARNING
    }

    return $exclusions
}

function Install-WSUSUpdates {
    Import-Module PSWindowsUpdate -Force

    # TODO: make this installs all available updates
    Get-WUList -NotUpdateID Get-Exclusions -AcceptAll -Install -IgnoreRebootRequired
}
if (! (Get-ElevationStatus)) {
    Write-Log "Not running in an elevated session!" -level ERROR
    exit
}

if (! (Check-WSUSModule)) {
    $result = Install-PSWindowsUpdateModule
    if ($result -eq 0) {
        Write-Log "Succesfully installed the PSWindowsUpdate module." -level SUCCESS
    } else {
        Write-Log "Could not install the PSWindowsUpdate module!: $result" -level ERROR
        exit
    }
}

Install-WSUSUpdates
