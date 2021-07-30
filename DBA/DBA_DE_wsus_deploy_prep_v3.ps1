Clear-Host
Write-Verbose "MSITS Decentral DBA WSUS Prerequisites deployment"
### Vars ###
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path                                				#Execution directory discovery
$sourcePath_PSWU = "$ScriptDir\PSWindowsUpdate"                                            				#Local PSWU Module path
$destPath_PSWU = "C:\Program Files\WindowsPowerShell\Modules"                              				#PSWU Module destination
$sourcePath_wsus_local_update_noreboot = "$ScriptDir\Assets\DBA_DE_wsus_local_update_reboot_v12.ps1"  	#Local WSUS update script path
$destPath_wsus_local_update_noreboot = "C:\tasks"                                          				#WSUS update path destination
$sourcePath_W1_WSUS_Update_check_xml = "$ScriptDir\Assets\DBA_DE_W1_Test_WSUS_Monthly_Update.xml" 		#Scheduled Update Task local xml path
$sourcePath_W2_WSUS_Update_check_xml = "$ScriptDir\Assets\DBA_DE_W2_Test_WSUS_Monthly_Update.xml" 		#Scheduled Update Task local xml path
$sourcePath_W3_WSUS_Update_check_xml = "$ScriptDir\Assets\DBA_DE_W3_Test_WSUS_Monthly_Update.xml" 		#Scheduled Update Task local xml path
$sourcePath_W4_WSUS_Update_check_xml = "$ScriptDir\Assets\DBA_DE_W4_Test_WSUS_Monthly_Update.xml" 		#Scheduled Update Task local xml path
$sourcePath_Pilot_WSUS_Update_check_xml = "$ScriptDir\Assets\DBA_Run_Once_Update_script.xml" 			#Scheduled Update Task local xml path
$destPath_WSUS_Update_check_xml = "C:\temp\wsus"                                           				#Scheduled Task Destination 
$sourcePath_DBA_DE_1313_sql = "$ScriptDir\Assets\1313.sql" 												#1313 sql sourcepath
$destPath_DBA_DE_1313_sql = "C:\tasks"     																#1313 sql destinationpath
$sourcePath_DBA_DE_1414_sql = "$ScriptDir\Assets\1414.sql" 												#1414 sql sourcepath
$destPath_DBA_DE_1414_sql = "C:\tasks"     																#1414 sql destinationpath
$servers_w1 = "$ScriptDir\Waves\DBA_DE_W1_Test.txt"														#Wave 1 (Test Group) list path
$servers_w2 = "$ScriptDir\Waves\DBA_DE_W2.txt"															#Wave 2 list path
$servers_w3 = "$ScriptDir\Waves\DBA_DE_W3.txt"															#Wave 3 list path
$servers_w4 = "$ScriptDir\Waves\DBA_DE_W4.txt"															#Wave 4 list path
$servers_pilot = "$ScriptDir\Waves\DBA_DE_Pilot.txt"													#Pilot Group (also manual deployment Group)

$pw = Get-Content "\\ing04wsus01p\wsus_crd\svc-tac.txt"                                     			#
$pws = ConvertTo-SecureString -String $pw -AsPlainText -Force                               			#SVC-TaskAutomateCopy pass encryption
$svctac = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pws)) #




#Create Destination Folders
function foldercreation_w1 {
Get-Content $servers_w1| ForEach-Object {
Invoke-Command -ComputerName "$_" -ScriptBlock {
    $Path="C:\tasks"
    if (!(Test-Path $Path))
    {
    New-Item -ItemType Directory -Force -Path C:\tasks
    }
    else
    {
    write-host "Tasks folder already exists" -ForegroundColor Green 
    } ;

    $Path="C:\temp\wsus"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus
}
else
{
write-host "WSUS folder already exists" -ForegroundColor Green 
} ;

$Path="C:\temp\wsus\wsus_logs"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus\wsus_logs
}
else
{
write-host "WSUS logs folder already exists" -ForegroundColor Green 
} ;


}
    }
}

function foldercreation_w2 {
Get-Content $servers_w2| ForEach-Object {
Invoke-Command -ComputerName "$_" -ScriptBlock {
    $Path="C:\tasks"
    if (!(Test-Path $Path))
    {
    New-Item -ItemType Directory -Force -Path C:\tasks
    }
    else
    {
    write-host "Tasks folder already exists" -ForegroundColor Green 
    } ;

    $Path="C:\temp\wsus"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus
}
else
{
write-host "WSUS folder already exists" -ForegroundColor Green 
} ;

$Path="C:\temp\wsus\wsus_logs"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus\wsus_logs
}
else
{
write-host "WSUS logs folder already exists" -ForegroundColor Green 
} ;


}
    }
}

function foldercreation_w3 {
Get-Content $servers_w3| ForEach-Object {
Invoke-Command -ComputerName "$_" -ScriptBlock {
    $Path="C:\tasks"
    if (!(Test-Path $Path))
    {
    New-Item -ItemType Directory -Force -Path C:\tasks
    }
    else
    {
    write-host "Tasks folder already exists" -ForegroundColor Green 
    } ;

    $Path="C:\temp\wsus"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus
}
else
{
write-host "WSUS folder already exists" -ForegroundColor Green 
} ;

$Path="C:\temp\wsus\wsus_logs"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus\wsus_logs
}
else
{
write-host "WSUS logs folder already exists" -ForegroundColor Green 
} ;


}
    }
}

function foldercreation_w4 {
Get-Content $servers_w4| ForEach-Object {
Invoke-Command -ComputerName "$_" -ScriptBlock {
    $Path="C:\tasks"
    if (!(Test-Path $Path))
    {
    New-Item -ItemType Directory -Force -Path C:\tasks
    }
    else
    {
    write-host "Tasks folder already exists" -ForegroundColor Green 
    } ;

    $Path="C:\temp\wsus"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus
}
else
{
write-host "WSUS folder already exists" -ForegroundColor Green 
} ;

$Path="C:\temp\wsus\wsus_logs"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus\wsus_logs
}
else
{
write-host "WSUS logs folder already exists" -ForegroundColor Green 
} ;


}
    }
}

function foldercreation_pilot {
Get-Content $servers_pilot| ForEach-Object {
Invoke-Command -ComputerName "$_" -ScriptBlock {
    $Path="C:\tasks"
    if (!(Test-Path $Path))
    {
    New-Item -ItemType Directory -Force -Path C:\tasks
    }
    else
    {
    write-host "Tasks folder already exists" -ForegroundColor Green 
    } ;

    $Path="C:\temp\wsus"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus
}
else
{
write-host "WSUS folder already exists" -ForegroundColor Green 
} ;

$Path="C:\temp\wsus\wsus_logs"

if (!(Test-Path $Path))
{
New-Item -ItemType Directory -Force -Path C:\temp\wsus\wsus_logs
}
else
{
write-host "WSUS logs folder already exists" -ForegroundColor Green 
} ;


}
    }
}

function w1testwsusdeploy {
Get-Content $servers_w1 | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
# Copy PSwindowsUpdate Module
$Path="C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"

if (!(Test-Path $Path))
{
copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -ErrorAction SilentlyContinue
}
else
{
write-host "PSwindowsUpdate Module already exists" -ForegroundColor Green 
} ;

# Copy PSwindowsUpdate update script   
$DBA_DE_wsus_upd = "C:\tasks\DBA_DE_wsus_local_update_reboot_v12.ps1"
if (Test-Path $DBA_DE_wsus_upd -PathType leaf) 
{"WSUS update script Exists" } 
else
{copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


<# # Force PSwindowsUpdate Module Copy
Get-Content $servers_w1 | ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -Force
} #>

# Copy DBA_DE Schedule Task xml
$DBA_DE_wsus_task_xml = "C:\temp\wsus\DBA_DE_W1_Test_WSUS_Monthly_Update.xml"
if (Test-Path $DBA_DE_wsus_task_xml -PathType leaf) 
{"WSUS update Task schedule xml exists"  }
else
{copy-item -Path $sourcePath_W1_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy 1313 SQL script	
$DBA_DE_1313_sql_path = "C:\tasks\1313.sql"
if (Test-Path $DBA_DE_1313_sql_path -PathType leaf) 
{"1313 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1313_sql -Destination $destPath_DBA_DE_1313_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy 1414 SQL script	
$DBA_DE_1414_sql_path = "C:\tasks\1414.sql"
if (Test-Path $DBA_DE_1414_sql_path -PathType leaf) 
{"1414 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1414_sql -Destination $destPath_DBA_DE_1414_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


}

##### SCHEDULED TASK CREATION #####
#DBA_DE_WSUS_Monthly_Update
Get-Content $servers_w1| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy Unrestricted -Force ; Register-ScheduledTask -Xml (Get-Content "C:\temp\wsus\DBA_DE_W1_Test_WSUS_Monthly_Update.xml" | Out-String) -TaskName "DBA_DE_W1_Test_WSUS_Monthly_Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy -Password "isRIvx0Vbu5V61nEnq56" –Force}
    }



} 	

function w2wsusdeploy {
Get-Content $servers_w2 | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
# Copy PSwindowsUpdate Module
$Path="C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"

if (!(Test-Path $Path))
{
copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -ErrorAction SilentlyContinue
}
else
{
write-host "PSwindowsUpdate Module already exists" -ForegroundColor Green 
} ;


# Copy PSwindowsUpdate update script   
$DBA_DE_wsus_upd = "C:\tasks\DBA_DE_wsus_local_update_reboot_v12.ps1"
if (Test-Path $DBA_DE_wsus_upd -PathType leaf) 
{"WSUS update script Exists" } 
else
{copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

<# # Force PSwindowsUpdate Module Copy
Get-Content $servers_w2 | ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -Force
} #>

# Copy DBA_DE Schedule Task xml
$DBA_DE_wsus_task_xml = "C:\temp\wsus\DBA_DE_W2_Test_WSUS_Monthly_Update.xml"
if (Test-Path $DBA_DE_wsus_task_xml -PathType leaf) 
{"WSUS update Task schedule xml exists"  }
else
{copy-item -Path $sourcePath_W2_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy 1313 SQL script	
$DBA_DE_1313_sql_path = "C:\tasks\1313.sql"
if (Test-Path $DBA_DE_1313_sql_path -PathType leaf) 
{"1313 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1313_sql -Destination $destPath_DBA_DE_1313_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

# Copy 1414 SQL script	
$DBA_DE_1414_sql_path = "C:\tasks\1414.sql"
if (Test-Path $DBA_DE_1414_sql_path -PathType leaf) 
{"1414 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1414_sql -Destination $destPath_DBA_DE_1414_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy DBA_DE_reboot_xml	
$DBA_DE_reboot_xml = "C:\temp\wsus\DBA_DE_reboot.xml"
if (Test-Path $DBA_DE_reboot_xml -PathType leaf) 
{"Reboot Task xml exists"  } 
else
{copy-item -Path $sourcePath_DBA_DE_reboot_xml -Destination $destPath_DBA_DE_reboot_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ; #>

}

##### SCHEDULED TASK CREATION #####
#DBA_DE_WSUS_Monthly_Update
Get-Content $servers_w2| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy Unrestricted -Force ; Register-ScheduledTask -Xml (Get-Content "C:\temp\wsus\DBA_DE_W2_Test_WSUS_Monthly_Update.xml" | Out-String) -TaskName "DBA_DE_W2_Test_WSUS_Monthly_Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy -Password "isRIvx0Vbu5V61nEnq56" –Force}    
}



}

function w3wsusdeploy {
Get-Content $servers_w3 | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
# Copy PSwindowsUpdate Module
$Path="C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"

if (!(Test-Path $Path))
{
copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -ErrorAction SilentlyContinue
}
else
{
write-host "PSwindowsUpdate Module already exists" -ForegroundColor Green 
} ;


# Copy PSwindowsUpdate update script   
$DBA_DE_wsus_upd = "C:\tasks\DBA_DE_wsus_local_update_reboot_v12.ps1"
if (Test-Path $DBA_DE_wsus_upd -PathType leaf) 
{"WSUS update script Exists" } 
else
{copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

<# # Force PSwindowsUpdate Module Copy
Get-Content $servers_w3 | ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -Force
} #>

# Copy DBA_DE Schedule Task xml
$DBA_DE_wsus_task_xml = "C:\temp\wsus\DBA_DE_W3_Test_WSUS_Monthly_Update.xml"
if (Test-Path $DBA_DE_wsus_task_xml -PathType leaf) 
{"WSUS update Task schedule xml exists"  }
else
{copy-item -Path $sourcePath_W3_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy 1313 SQL script	
$DBA_DE_1313_sql_path = "C:\tasks\1313.sql"
if (Test-Path $DBA_DE_1313_sql_path -PathType leaf) 
{"1313 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1313_sql -Destination $destPath_DBA_DE_1313_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

# Copy 1414 SQL script	
$DBA_DE_1414_sql_path = "C:\tasks\1414.sql"
if (Test-Path $DBA_DE_1414_sql_path -PathType leaf) 
{"1414 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1414_sql -Destination $destPath_DBA_DE_1414_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy DBA_DE_reboot_xml	
$DBA_DE_reboot_xml = "C:\temp\wsus\DBA_DE_reboot.xml"
if (Test-Path $DBA_DE_reboot_xml -PathType leaf) 
{"Reboot Task xml exists"  } 
else
{copy-item -Path $sourcePath_DBA_DE_reboot_xml -Destination $destPath_DBA_DE_reboot_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ; #>

}

##### SCHEDULED TASK CREATION #####
#DBA_DE_WSUS_Monthly_Update
Get-Content $servers_w3| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy Unrestricted -Force ; Register-ScheduledTask -Xml (Get-Content "C:\temp\wsus\DBA_DE_W3_Test_WSUS_Monthly_Update.xml" | Out-String) -TaskName "DBA_DE_W3_Test_WSUS_Monthly_Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy -Password "isRIvx0Vbu5V61nEnq56" –Force}
}


}

function w4wsusdeploy {
Get-Content $servers_w4 | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
# Copy PSwindowsUpdate Module
$Path="C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"

if (!(Test-Path $Path))
{
copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -ErrorAction SilentlyContinue
}
else
{
write-host "PSwindowsUpdate Module already exists" -ForegroundColor Green 
} ;


# Copy PSwindowsUpdate update script   
$DBA_DE_wsus_upd = "C:\tasks\DBA_DE_wsus_local_update_reboot_v12.ps1"
if (Test-Path $DBA_DE_wsus_upd -PathType leaf) 
{"WSUS update script Exists" } 
else
{copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

<# # Force PSwindowsUpdate Module Copy
Get-Content $servers_w4 | ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -Force
} #>

# Copy DBA_DE Schedule Task xml
$DBA_DE_wsus_task_xml = "C:\temp\wsus\DBA_DE_W4_Test_WSUS_Monthly_Update.xml"
if (Test-Path $DBA_DE_wsus_task_xml -PathType leaf) 
{"WSUS update Task schedule xml exists"  }
else
{copy-item -Path $sourcePath_W4_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy 1313 SQL script	
$DBA_DE_1313_sql_path = "C:\tasks\1313.sql"
if (Test-Path $DBA_DE_1313_sql_path -PathType leaf) 
{"1313 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1313_sql -Destination $destPath_DBA_DE_1313_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

# Copy 1414 SQL script	
$DBA_DE_1414_sql_path = "C:\tasks\1414.sql"
if (Test-Path $DBA_DE_1414_sql_path -PathType leaf) 
{"1414 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1414_sql -Destination $destPath_DBA_DE_1414_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

}

##### SCHEDULED TASK CREATION #####
#DBA_DE_WSUS_Monthly_Update
Get-Content $servers_w4| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy Unrestricted -Force ; Register-ScheduledTask -Xml (Get-Content "C:\temp\wsus\DBA_DE_W4_Test_WSUS_Monthly_Update.xml" | Out-String) -TaskName "DBA_DE_W4_Test_WSUS_Monthly_Update" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy -Password "isRIvx0Vbu5V61nEnq56" –Force}
}

} 

function pilot_wsusdeploy {
Get-Content $servers_pilot | ForEach-Object {
$Session = New-PSSession -ComputerName "$_" ;
# Copy PSwindowsUpdate Module
$Path="C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"

if (!(Test-Path $Path))
{
copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -ErrorAction SilentlyContinue
}
else
{
write-host "PSwindowsUpdate Module already exists" -ForegroundColor Green 
} ;


# Copy PSwindowsUpdate update script   
$DBA_DE_wsus_upd = "C:\tasks\DBA_DE_wsus_local_update_reboot_v12.ps1"
if (Test-Path $DBA_DE_wsus_upd -PathType leaf) 
{"WSUS update script Exists" } 
else
{copy-item -Path $sourcePath_wsus_local_update_noreboot -Destination $destPath_wsus_local_update_noreboot -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

<# # Force PSwindowsUpdate Module Copy
Get-Content $servers_w4 | ForEach-Object {
    $Session = New-PSSession -ComputerName "$_" ;
    copy-item -Path $sourcePath_PSWU -Destination $destPath_PSWU -recurse -ToSession $Session -Force
} #>

# Copy DBA_DE Schedule Task xml
$DBA_DE_wsus_task_xml = "C:\temp\wsus\DBA_Run_Once_Update_script.xml"
if (Test-Path $DBA_DE_wsus_task_xml -PathType leaf) 
{"WSUS update Task schedule xml exists"  }
else
{copy-item -Path $sourcePath_Pilot_WSUS_Update_check_xml -Destination $destPath_WSUS_Update_check_xml -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;


# Copy 1313 SQL script	
$DBA_DE_1313_sql_path = "C:\tasks\1313.sql"
if (Test-Path $DBA_DE_1313_sql_path -PathType leaf) 
{"1313 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1313_sql -Destination $destPath_DBA_DE_1313_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

# Copy 1414 SQL script	
$DBA_DE_1414_sql_path = "C:\tasks\1414.sql"
if (Test-Path $DBA_DE_1414_sql_path -PathType leaf) 
{"1414 SQL script exists" } 
else
{copy-item -Path $sourcePath_DBA_DE_1414_sql -Destination $destPath_DBA_DE_1414_sql -recurse -ToSession $Session -ErrorAction SilentlyContinue} ;

}

##### SCHEDULED TASK CREATION #####
#DBA_DE_WSUS_Monthly_Update
Get-Content $servers_pilot| ForEach-Object {
    Invoke-Command -ComputerName "$_" -ScriptBlock {Set-ExecutionPolicy Unrestricted -Force ; Register-ScheduledTask -Xml (Get-Content "C:\temp\wsus\DBA_Run_Once_Update_script.xml" | Out-String) -TaskName "DBA_Run_Once_Update_script" -TaskPath "\" -User mmsrg\SVC-TaskAutomateCopy -Password "isRIvx0Vbu5V61nEnq56" -Force}
}
}



function Show-Menu {
    param (
        [string]$Title = "MSITS Store Server DE DBA Task deployment"
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press "1" to deploy DBA W1 Test Group."
    Write-Host "2: Press "2" to deploy DBS W2 Group."
    Write-Host "3: Press "3" to deploy DBA W3 Group."
	Write-Host "4: Press "4" to deploy DBA W4 Group."
	Write-Host "5: Press "5" to deploy DBA Pilot Group."
    Write-Host "Q: Press "Q" to quit."
}



do
{
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    "1" {
	foldercreation_w1;
    w1testwsusdeploy
    } "2" {
	foldercreation_w2;
    w2wsusdeploy
    } "3" {
	foldercreation_w3;
    w3wsusdeploy
    }  "4" {
	foldercreation_w4;
    w4wsusdeploy
    }  "5" {
	foldercreation_pilot;
    pilot_wsusdeploy
    }
    }
    pause
}
until ($selection -eq "q")
stop-process -Id $PID