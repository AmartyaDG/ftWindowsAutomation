<#  
.Synopsis 
This code will perform following functionalities to achieve AUL installation in an automated process.

1. Disable firewall
2. Edit security policies for a password less login for seemless AUL installation
3. Mount share of AUL iso
4. Copy aul iso into C:\ drive of windows server
5. Install AUL
#>  

Function disable_firewall 
{
    #System cmd for disabling firewall
    $cmd = Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    try {
        #run cmd to disable firewall
        $cmd
    }catch{
        Write-Host $_.Exception.Message       
        }
}

Function edit_security_policy
{
    try{
        #exports the current security config settings in c:\ drive custom filename secpool.cfg
        secedit /export /cfg c:\secpol.cfg
        #editing password complexity settings in exported file
        (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
        #updating password setting for blank password entry
        (gc C:\secpol.cfg).replace("MACHINE\System\CurrentControlSet\Control\Lsa\LimitBlankPasswordUse=4,1", "MACHINE\System\CurrentControlSet\Control\Lsa\LimitBlankPasswordUse=4,0") | Out-File C:\secpol.cfg
        #updating security policy in registry settings
        secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
        #Cleanup
        rm -force c:\secpol.cfg -confirm:$false
        }catch{
            Write-Host $_.Exception.Message
            }
}

Function edit_passwd
{
    #Batch file path
    $cmdlet = "C:\win-automation-amartya\no_passwd.bat"
  try{
     #execute cmd
     Start-Process $cmdlet
    }catch{
        Write-Host $_.Exception.Message
        }
}

Function mount_share
{
    try{
        Write-Host "Mounting ISO location to drive Z:\"
        #mount share
        net use z: \\134.111.87.198\test1\Stratus_India\ftServer\ftWindows /u:syseng syseng
        Write-Host "Location \\134.111.87.198\test1\Stratus_India\ftServer\ftWindows successfully mounted on drive Z:\"

      }catch{
      Write-Host $_.Exception.Message
    }
    try{
        Write-Host "ISO is being copied to C:\"
        #copy iso
        copy z:\13.0\W2K16_13.0.3605Test.iso c:\
        Write-Host "Copied Successfully"
    }catch{
     Write-Host $_.Exception.Message
    }
}

Function install_Aul
{
    try{
        #mount copied ISO
        $mount_ftISO = Mount-DiskImage C:\W2K16_13.0.3605Test.iso -PassThru
        #drive letter of mounted ISO
        $driveLetter = ($mount_ftISO | Get-Volume).DriveLetter
        #update batch file with proper drive letter
        #(gc C:\win-automation-amartya\iso_install.bat).replace("@", $driveLetter) | Out-File C:\win-automation-amartya\iso_install.bat
        #specify batch file path
        #$cmdlet = "C:\win-automation-amartya\iso_install.bat"
        #start installation
        Write-Host "Starting AUL Installation...."
        $cmdlet = "$driveLetter"+":\bin\setup.bat"
        $cmdlet2 =  " autobv"
        Write-Host "passing silent installation command:" $cmdlet $cmdlet2
        Start-Process $cmdlet $cmdlet2
    }catch{
     Write-Host $_.Exception.Message
    }
}


#Function Calls
disable_firewall
edit_security_policy
edit_passwd
mount_share
install_Aul