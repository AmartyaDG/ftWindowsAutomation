<#
.Synopsis 
This code will perform RDR configuration and mirroring on all available disks
on a server with AUL installed.
It will perform following tasks to achieve RDR and mirroring.

1. Use RDRScan.exe to get information of slots and disks.
2. Use ftsysAssist.exe to configure RDR disks.
3. Use ftsysAssist.exe to mirror RDR logical disks.
#>

Function rdrconfig
{
 try{
    #copy all lun/disk information of all slots using RdrScan.exe
    $cmd_getLun = C:\win-automation-amartya\RdrScan.exe show  > lun_info.txt
    #run cmd to get information on disks available in server
    #$cmd_getLun 
    $lun_file_path = "lun_info.txt"
    $rdrAssistPath = 'C:\Program Files\ftSys\management\ftSysRdrAssist.exe'
    $cmd_create = "create /t"
    $cmd_end = "/r"
 #   try{
 ###############################
 # Code block for RDR create   
 ###############################   
    #Write-Output "Disk info 10 slot"

    #Get info of all disks in slot 10/40/x
    $slot_10 = Get-ChildItem -Path $lun_file_path| Select-String -Pattern ': 10/40'
    $slot_info10 = $slot_10.Line.Split(":")
    #Write-Host $slot_info10
    $pattern = "DeviceId" #This pattern needs to be omitted from array as it gets in as part on the extended string
    $pattern_slot0 = "10/40/1/0" # Needs to omit this slot as this is boot disk
    $slot_array = @() #Create empty array for storing disk slots
    Write-Output ""
    Write-Output "----------------------------------------------------------------------"
    Write-Output "Start RDR configuration for disk slots - 10/40/x (Excluding boot disk)"
    Write-Output "----------------------------------------------------------------------"
    Write-Output ""
    foreach ($slot10 in $slot_info10) {
            if ($slot10 -notmatch $pattern ) # omitting pattern in slot info
                {
                    #$slot_array += $slot10
                    if ($slot10 -notmatch $pattern_slot0) #omitting boot disk
                    {
                        $slot_array += $slot10 #increment array to next index
                        Write-Output "Creating RDR virtual disk"
                        $slot10
                        #Run ftsysRDRAssist.exe for RDR configuration
                        &$rdrAssistPath create /t $slot10.Trim() /r
                        #sleep for 10 secs to complete operation
                        Start-Sleep -Seconds 10
                   }
                    #$rdrAssistPath
                
            }
        
    }

########################################################
#below code for mirroring
########################################################

#update array with only 10/40 slot disk numbers
    $slot_10_array = @()
        foreach ($slot10 in $slot_info10) {
                if ($slot10 -notmatch $pattern ){
                    $slot_10_array += $slot10
                }
        }
 #       Write-Host $_.Exception.Message       
#}

    #Get all slot information for 11/40/x
    $slot_11 = Get-ChildItem -Path $lun_file_path| Select-String -Pattern ': 11/40'
    $slot_info11 = $slot_11.Line.Split(":")
    #Write-Host $slot_info10
    $pattern = "DeviceId" #this pattern needs to be omitted as it gets copied in the array as part of string
    $incr = 0
    #Write-Output $slot_array[0]
    Write-Output ""
    Write-Output "------------------------------------------"
    Write-Output "Starting to mirror 10/40/x - 11/40/x slots"
    Write-Output "------------------------------------------"
    Write-Output ""
    foreach ($slot11 in $slot_info11) {
        if ($slot11 -notmatch $pattern ) #Omitting "DeviceId" from array
            {
                    $slot_array_11 += $slot11
                    Write-Output "add RDR disk slot " $slot_10_array[$incr] "as source and disk slot" $slot11 "destination"
                    $sourceDisk =$slot_10_array[$incr].Trim()
                    #Execute ftsysRDRAssist.exe for mirroring {slot 10/40/0 - 11/40/0.....10/40/n - 11/40/n}
                    &$rdrAssistPath mirror /s $sourceDisk /t $slot11.Trim() /r
                    #sleep for 10 secs to complete operation
                    Start-Sleep -Seconds 10
                    #$temp[$i]
                    $incr++              
        }
        
    }
    
  }catch{
        Write-Host $_.Exception.Message 
 }
}
 
Function cleanup
{
    try{
        rm -force lun_info.txt -confirm:$false
        rm -force c:\W2K16_13.0.3605Test.iso -confirm:$false
        Write-Host "Cleanup activities completed"
        }catch{
        Write-Host $_.Exception.Message
        }

}
#Function Call
rdrconfig
cleanup