<#  
.Synopsis 
This code will perform QATools installation for ftWindows

What the program does:
1. Check for ftWindows version from  - C:\Program Files\ftSys\management\logs\ftSysServer.log
2. Download qatools installter for specific version from - 134.111.87.198\test1\projects\windows\ 
3. Install qatools
4. Verfiy installation
#>  


Function checkFTversion
{
    $ftServerLog =  Get-Content -Path "C:\Program Files\ftSys\management\logs\ftSysServer.log" | Select -Index 0 #Get the first line of logfile
    $splitWords = $ftServerLog.split(" ") #split up all words from line considering space as delimiter
    $match = "13.0.0.0"                   #match with version string
    foreach ($word in $splitWords){       #Loop through words till version match is found
        if ($word -contains $match){      #Match version
            downloadInstaller($word)      #Call downloadInstaller function, passing version number as arg 
        }
    }
}

Function downloadInstaller([string]$arg)
{
    if($arg -contains "13.0.0.0"){   #check version arg
        copy \\134.111.87.198\test1\projects\windows\13.0\QAToolsInstaller\qatools-win.13.0.exe c:\ #start copying installer in C:\
        if ($? -eq $false)   {  #Check successful copy
            $msg = "ERROR: File copy failed"
            Write-Host $msg
        }else{
             Write-Host "QATools installer file copied successfully......"
        }
    }
installQatools
}

Function installQatools
{
    $pathvargs = {Start-Process "C:\qatools-win.13.0.exe" -ArgumentList /VERYSILENT -Wait -PassThru} #silent install QATools
    Invoke-Command -ScriptBlock $pathvargs              #Invoke installer
    if ($? -eq $false)   {                              #verify successful installation
            $msg = "ERROR: File copy failed"
            Write-Host $msg
        }else{
            Write-Host "QATools installation is successful...."
        }
}

#Function Call
checkFTversion

