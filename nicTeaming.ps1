<#  
.Synopsis 
This code will perform NIC Teaming on .68, .59 and .61 subnets

For teaming NetLbfo module and for apadter informations Get-NetIPAddress module has been used.

What the program does:
1. Check for any existing team
2. If found delete
3. Get information of all existing ethernets with IPv4 address
4. Filter out subnet (68x, 61x, 59x) and associated Ethernets.
5. Create Teams  
#>  

Function createTeam
{
    $SleepBetweenTeamChanges = 5  ##  sleep time in seconds
    Write-Host "Start creating teams..............."

    $ethernet_info = @(Get-NetIPAddress -AddressFamily IPv4) # Get all available Ethernet info
    $ipAddress = @($ethernet_info.IPAddress)                 # array of all ip addresses  present in server
    $interfaceAlias = @($ethernet_info.InterfaceAlias)       # array of all ethernets present in server
    $nic_hash = @{}                                          #create new empty hashtable with Key=Ip, Value = Ethernet
        for ($i = 0; $i -lt $ipAddress.Count; $i++)
            {
                $nic_hash[$ipAddress[$i]] = $interfaceAlias[$i] # new hashtable with key=IP, Value=Ethernet
        } 
    $68_subnet = @($nic_hash.Keys | Select-String -Pattern '192.168.68') #filter out .68x subnet IPs.
    $61_subnet = @($nic_hash.Keys | Select-String -Pattern '192.168.61') #filter out .61x subnet IPs.
    $59_subnet = @($nic_hash.Keys | Select-String -Pattern '192.168.59') #filter out .59x subnet IPs.
    if ( $68_subnet.Length -gt 1)            # check more than one .68 subnet IP is available
    {
        $NIC1 = $68_subnet[0]
        $NIC2 = $68_subnet[1]
        New-NetLbfoTeam -Name "68-nic" -TeamMembers $nic_hash."$NIC1", $nic_hash."$NIC2" -Confirm:$false | Out-Null #Create Team
        sleep $SleepBetweenTeamChanges 
        if ($? -eq $false)   {
               #$msg = "ERROR: Team creation for $tn failed on try $teamCreatedTryCount ."
               Write-Error -msgS E -msgText "Failed to create New-NetLbfoTeam"
               continue
            }<#else {
                    Write-Host "Successfull!!"
                    Get-NetLbfoTeam
                    $SleepBetweenTeamChanges
                   }#>

     }

     if ( $61_subnet.Length -gt 1) # check more than one .68 subnet IP is available
    {
        $NIC1 = $61_subnet[0]
        $NIC2 = $61_subnet[1]
        New-NetLbfoTeam -Name "61-nic" -TeamMembers $nic_hash."$NIC1", $nic_hash."$NIC2" -Confirm:$false | Out-Null #Creates new team for .61 subnet
        sleep $SleepBetweenTeamChanges 
        if ($? -eq $false)   {
               #$msg = "ERROR: Team creation for $tn failed on try $teamCreatedTryCount ."
               Write-Error -msgS E -msgText "Failed to create New-NetLbfoTeam"
               continue
            }<#else {
                    Write-Host "Successfull!!"
                    Get-NetLbfoTeam
                    $SleepBetweenTeamChanges
                   }#>

     }

     if ( $59_subnet.Length -gt 1) # check more than one .68 subnet IP is available
    {
        $NIC1 = $59_subnet[0]
        $NIC2 = $59_subnet[1]
        New-NetLbfoTeam -Name "59-nic" -TeamMembers $nic_hash."$NIC1", $nic_hash."$NIC2" -Confirm:$false | Out-Null #Create Team
        sleep $SleepBetweenTeamChanges 
        if ($? -eq $false)   {
               #$msg = "ERROR: Team creation for $tn failed on try $teamCreatedTryCount ."
               Write-Error -msgS E -msgText "Failed to create New-NetLbfoTeam"
               continue
            }<#else {
                    Write-Host "Successfull!!"
                    Get-NetLbfoTeam
                    $SleepBetweenTeamChanges
                   }#>

     }

     Write-Host "List of newly created teams below:"
     Get-NetLbfoTeam
     $SleepBetweenTeamChanges

}

Function removeExistingTeam
{
    
    $SleepBetweenTeamChanges = 5  ##  sleep time in seconds
    $cc = Get-NetLbfoTeam
    Write-Verbose "Just got Teams.."
    $currentTeams = @(Get-NetLbfoTeam) #if any team already present, then need to remove
       Write-Host "Name: " $currentTeams.Name
       Write-Host "Members: " $currentTeams.Members
       if ($currentTeams.Count -eq 0)   {
          Write-Host "There are no LBFO teams to remove."
          Write-Host "Start Creating Teams............"
       }
       else   {
          Write-Host "Start Deleting Teams............"
          foreach($team in $currentTeams) {
              Remove-NetLbfoTeam -Name $team.Name -Confirm:$false
              sleep $SleepBetweenTeamChanges
          }
          sleep $SleepBetweenTeamChanges 
          $cc = Get-NetLbfoTeam
          if ( $cc -ne $null)   {
             Write-Host "ERROR: Remove-NetLbfoTeam FAILED to remove all teams on first try."
             sleep $SleepBetweenTeamChanges
             foreach($team in $currentTeams) {
                 Remove-NetLbfoTeam -Name $team.Name -Confirm:$false
                 sleep $SleepBetweenTeamChanges
             }
             sleep $SleepBetweenTeamChanges 
             $cc2 = Get-NetLbfoTeam
             if ( $cc2 -ne $null)   {
                Write-Host "ERROR: Remove-NetLbfoTeam FAILED to remove all teams 2nd try."
             }
          }
       }
       sleep $SleepBetweenTeamChanges
       Write-Host "Deleted all existing teams"
       Write-Host ""
       #Call Function createTeam
       createTeam
}

#Function Call
removeExistingTeam