$Servers = Get-content "E:\Scripts\MSITS_WSUS_DCS\APP_DC\Powershell_deployment\New_Powershell_deployment.txt"

Foreach ($Server in $Servers){
            $File = "E:\Scripts\app_repo\WWin8.1AndW2K12R2-KB3191564-x64.msu"
            $TestPath = Test-Path -PathType Container \\$server\c$\Temp
            $TestFile = Test-Path -PathType Leaf "\\$server\c$\Temp\WWin8.1AndW2K12R2-KB3191564-x64.msu"
                if ($TestPath -eq $false){
                    New-Item -Path "\\$server\c$\Temp" -ItemType Directory
                    }
                if ($TestFile -eq $false){
                    Copy-Item -Path $File -Destination "\\$server\c$\Temp\"
                    }
                    $WMF51InstallScriptBlock = {
                    $File = "C:\temp\WWin8.1AndW2K12R2-KB3191564-x64.msu"
                    C:\Windows\System32\wusa.exe $File /extract:"C:\Temp\"
                    sleep 15 													# extracting isn't instant, so need to wait for it to complete, otherwise next line will return no results.
                    $cabs = Get-Childitem "C:\Temp\*.cab" 						# Luckily the CABs are ordered alphabetically, so in the correct order to install.
                    Foreach ($cab in $cabs){
                        Dism.exe /online /add-package /packagepath:$cab
                        }
                    }
                    Invoke-Command -ComputerName $Server -ScriptBlock $WMF51InstallScriptBlock -AsJob
                }