param($FormInput)
Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
$deploymentType = $myJson.deploymentType
#$filepath = "C:\inetpub\wwwroot\AVEDeploymentStatus.txt"
#"InProgress" | Out-File -FilePath $filepath

$fileName = $myJson.logfile
$filepath = "C:\inetpub\wwwroot\$fileName"
"InProgress" | Out-File -FilePath $filepath
Write-Host $filepath

Function Write-Log {
 
  [CmdletBinding()]
   
  Param ([Parameter(Mandatory=$true)][string]$LogFilePath, [Parameter(Mandatory=$true)][string]$Message)
   
  Process{
    #Add Message to Log File with timestamp
    "$([datetime]::Now) : $Message" | Out-File -FilePath $LogFilePath -append;
   
    #Write the log message to the screen
    Write-host $([datetime]::Now) $Message
  }
}
#try
#{
if($deploymentType -eq "vCenter"){
$vCenterServer = $myJson.vcenterdata.vCenter
$username = $myJson.vcenterdata.username
$password = $myJson.vcenterdata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$VMName = $myJson.avedata.VMName
$Network = $myJson.avedata.Network
$ipv4=$myJson.avedata.ipv4
$prefix = $myJson.avedata.ip_prefix
$ipv4address = $ipv4 +"/" + $prefix
$gateway = $myJson.avedata.gateway
$fqdn = $myJson.avedata.fqdn
$primarynameserver = $myJson.avedata.primary_nameserver
$ntp = $myJson.avedata.ntpserver
$myDatastore=$myJson.avedata.Datastore
$DiskStorageFormat=$myJson.avedata.DiskStorageFormat
$ovaPath=$myJson.avedata.ovaPath
#$adminpass=$myJson.avedata.admin_password_os
$defaultrootpass=$myJson.avedata.defaultrootpass
$rootpass=$myJson.avedata.avamar_rootpass
$ErrorActionPreference = 'Stop'
$repl_password=$myJson.avedata.repl_password
$mcpass=$myJson.avedata.mcpass
$viewuserpass=$myJson.avedata.viewuserpass
$admin_password_os=$myJson.avedata.admin_password_os
$root_password_os=$myJson.avedata.root_password_os
$keystore_passphrase=$myJson.avedata.keystore_passphrase
$hfsaddr=$myJson.avedata.hfsaddr
$common_password=$myJson.avedata.common_password
$use_common_password=$myJson.avedata.use_common_password
$timezone_name=$myJson.avedata.timezone
Write-Host $ipv4address
if($use_common_password -eq "false"){
 $common_password="xyz"
}

if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] vCenter $vCenterServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue
    #Write-Output $ipdetail

    if ($checkOva) {

       Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided VMName $VMName already exists`n"
       "Failed" | Out-File -FilePath $filepath

    }
        elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"
        "Failed" | Out-File -FilePath $filepath	
	}
	elseif($ipdetail.IPAddress -contains $ipv4){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided ipaddress $ipv4 is already in use`n"
        "Failed" | Out-File -FilePath $filepath
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided network $Network is invalid`n"
        "Failed" | Out-File -FilePath $filepath
	}

    else {

       $ovaConfig = Get-OvfConfiguration -Ovf  $ovaPath

       $ovaConfig.ToHashTable()

       $ovaConfig = @{                 
        
          "NetworkMapping.eth0 Network" = "$Network"

       }
        if($myJson.avedata.hostData.type -eq "cluster"){
          $clusterdetail = Get-Cluster -ErrorAction SilentlyContinue
          $clustervalue = $myJson.avedata.hostData.value
	  if($clusterdetail.Name -contains $clustervalue){
          Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] Initiating Avamar Deployment"
        $esxiHost = Get-Cluster -Name $myJson.avedata.hostData.value | Get-VMHost | Get-Random
        $deployOva = Import-vApp -Source $ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myDatastore -DiskStorageFormat  $DiskStorageFormat
        }
          else{
		 Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided cluster name $clustervalue is invalid`n"
                 "Failed" | Out-File -FilePath $filepath
               }
       }
       else
       {
         $esxidetail= Get-VMHost -ErrorAction SilentlyContinue
         $esxivalue = $myJson.avedata.hostData.value
	 if($esxidetail.Name -contains $esxivalue){
          $esxiHost = $myJson.avedata.hostData.value
         Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] Initiating Avamar Deployment"
       $deployOva = Import-vApp -Source $ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myDatastore -DiskStorageFormat $DiskStorageFormat
        }
               else{
		   Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided Esxi value $esxivalue is invalid`n"
                   "Failed" | Out-File -FilePath $filepath
		}
       }
       Write-Host $esxiHost
       if($deployOva.PowerState -eq "PoweredOff")
       {
       New-HardDisk -VM $VMName -CapacityGB 250 -StorageFormat $DiskStorageFormat
       New-HardDisk -VM $VMName -CapacityGB 250 -StorageFormat $DiskStorageFormat
       Start-VM -VM $VMName
       sleep -s 90
       Copy-VMGuestFile -Destination '/root' -Source 'E:\Workspace\UIAutomation\CRS Exp Files\Netconfig_ave.exp' -LocalToGuest -GuestUser root -GuestPassword $defaultrootpass -VM $VMName
       $Command = "sudo expect Netconfig_ave.exp $ipv4address $gateway $fqdn $primarynameserver $ntp"
       $invoke_command=Invoke-VMScript -ScriptType Bash -ScriptText $Command -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
           if($invoke_command.ExitCode -eq "0")
           {
              Copy-VMGuestFile -Destination '/root' -Source 'E:\Workspace\UIAutomation\Ave config file\Installconfig_test.yaml' -LocalToGuest -GuestUser root -GuestPassword $defaultrootpass -VM $VMName
              
             $Command1 = "sed -i -e 's/repl_password:/repl_password: $repl_password/; s/rootpass:/rootpass: $rootpass/; s/mcpass:/mcpass: $mcpass/' Installconfig_test.yaml"
             $Command2 = "sed -i -e 's/viewuserpass:/viewuserpass: $viewuserpass/; s/admin_password_os:/admin_password_os: $admin_password_os/' Installconfig_test.yaml"
             $Command3 = "sed -i -e 's/root_password_os:/root_password_os: $root_password_os/; s/keystore_passphrase:/keystore_passphrase: $keystore_passphrase/' Installconfig_test.yaml"
             $Command4 = "sed -i -e 's/^common_password:/common_password: $common_password/' Installconfig_test.yaml"
             $Command5 = "sed -i -e 's/use_common_password:/use_common_password: $use_common_password/' Installconfig_test.yaml"
             $Command6 = "sed -i -e 's=timezone_name:=timezone_name: $timezone_name=' Installconfig_test.yaml"

             Invoke-VMScript -ScriptType Bash -ScriptText $Command1 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command2 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command3 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command4 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command5 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command6 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
              Write-Host "Initiating Avamar installation"
              $Command7= "/opt/emc-tools/0.20.0/bin/avi-cli $ipv4 --user root --password $defaultrootpass --port 7543 --userinput Installconfig_test.yaml --backtrace --install ave-config"
              $secpasswd = ConvertTo-SecureString $defaultrootpass -AsPlainText -Force
              $Credentials = New-Object System.Management.Automation.PSCredential("root", $secpasswd)
              Start-Sleep -s 120
              Get-SSHTrustedHost | Remove-SSHTrustedHost
              $sessionID = New-SSHSession -ComputerName $ipv4 -Credential $Credentials -AcceptKey #Connect Over SSH

              Invoke-SSHCommand -Index $sessionID.sessionid -Command $Command7 -ErrorAction SilentlyContinue  # Invoke Command Over SSH
              sleep -s 1800
              Copy-VMGuestFile -Destination '/home/admin' -Source 'E:\Workspace\UIAutomation\CRS Exp Files\sshconfig_ave.exp' -LocalToGuest -GuestUser admin -GuestPassword $admin_password_os -VM $VMName
              $Command= "expect sshconfig_ave.exp $root_password_os"
              $sshout = Invoke-VMScript -ScriptType Bash -ScriptText $Command -VM $VMName -GuestUser admin -GuestPassword $admin_password_os
              $Command8="rm -rf /root/Installconfig_test.yaml"
              $remove_file = Invoke-VMScript -ScriptType Bash -ScriptText $Command8 -VM $VMName -GuestUser root -GuestPassword $root_password_os -ErrorAction SilentlyContinue
              $Command9="rm -rf /root/ Netconfig_ave.exp"
              $remove_file1 = Invoke-VMScript -ScriptType Bash -ScriptText $Command9 -VM $VMName -GuestUser root -GuestPassword $root_password_os -ErrorAction SilentlyContinue
              $Command10="rm -rf /home/admin/sshconfig_ave.exp"
              $remove_file2 = Invoke-VMScript -ScriptType Bash -ScriptText $Command10 -VM $VMName -GuestUser admin -GuestPassword $admin_password_os -ErrorAction SilentlyContinue

          if($sshout.ExitCode -eq "0"){
              Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] Avamar Deployment is successfull" 
           get-vm -Name $VMName | % {
                $vm = Get-View $_.ID
                $vms = "" | Select-Object VMName, IPAddress, VMState, NumberOfCPU, TotalMemoryMB,Datastore
                $vms.VMName = $vm.Name
                $vms.IPAddress = $vm.guest.ipAddress
                $vms.VMState = $vm.summary.runtime.powerState
                $vms.NumberOfCPU = $vm.summary.config.numcpu
                $vms.TotalMemoryMB = $vm.summary.config.memorysizemb
                $vms.Datastore = [string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))
                }
       Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] $vms"
        "Success" | Out-File -FilePath $filepath			    
	}
			  
           else{
			    Write-Output ""
			  }
			  
           } 
           else{
             Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] failed to update ave configuration"
              "Failed" | Out-File -FilePath $filepath
               }
       sleep -s 60
       }
       else
       {
          Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Avamar Deployment is failed"
          "Failed" | Out-File -FilePath $filepath
       }

    }

    Disconnect-VIServer -Server $MyServer -confirm:$false

  }

  if (!($global:DefaultVIServers.Count)) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] $vCenterServer successfully disconnected`n"

  }

  else {

    Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] The connection to $vCenterServer is still open!`n"

  }

}
}

else
{
#$myJson = $FormInput | ConvertFrom-Json
$esxiServer = $myJson.esxidata.esxiServer
$username = $myJson.esxidata.username
$password = $myJson.esxidata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$VMName = $myJson.avedata.VMName
#$ipv4address = $myJson.avedata.ipwithprefix_ave
$ipv4=$myJson.avedata.ipv4
$prefix = $myJson.avedata.ip_prefix
$ipv4address = $ipv4 +"/" + $prefix
$gateway = $myJson.avedata.gateway
$fqdn = $myJson.avedata.fqdn
$primarynameserver = $myJson.avedata.primary_nameserver
$ntp = $myJson.avedata.ntpserver
$esxiHost= $myJson.avedata.esxiHost
$myDatastore=$myJson.avedata.Datastore
$DiskStorageFormat=$myJson.avedata.DiskStorageFormat
$ovaPath=$myJson.avedata.ovaPath
$defaultrootpass=$myJson.avedata.defaultrootpass
$rootpass=$myJson.avedata.avamar_rootpass
$ErrorActionPreference = 'Stop'
$repl_password=$myJson.avedata.repl_password
$mcpass=$myJson.avedata.mcpass
$viewuserpass=$myJson.avedata.viewuserpass
$admin_password_os=$myJson.avedata.admin_password_os
$root_password_os=$myJson.avedata.root_password_os
$keystore_passphrase=$myJson.avedata.keystore_passphrase
$hfsaddr=$myJson.avedata.hfsaddr
$common_password=$myJson.avedata.common_password
$use_common_password=$myJson.avedata.use_common_password
$timezone_name=$myJson.avedata.timezone
$Network = $myJson.avedata.Network
Write-Host $ipv4address 

if($use_common_password -eq "false"){
 $common_password="xyz"
}

if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] esxiServer $esxiServer successfully connected`n"

    $checkOva = Get-VM -Name $myJson.avedata.VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue
    Write-Host $networkdetail.Name
    if ($checkOva) {

       Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided VMName $VMName already exists`n"
        "Failed" | Out-File -FilePath $filepath

    }
        elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"
        "Failed" | Out-File -FilePath $filepath	
	}
	elseif($ipdetail.IPAddress -contains $ipv4){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided ipaddress $ipv4 is already in use`n"
        "Failed" | Out-File -FilePath $filepath
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Provided network $Network is invalid`n"
        "Failed" | Out-File -FilePath $filepath
	}

    else {
      Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] Initiating Avamar Deployment"
      $OVFTOOL_BIN_PATH="C:\Users\crauser\Downloads\VMware-ovftool-4.4.3-18663434-win.x86_64\ovftool\ovftool.exe"
      $FAH_OVA=$myJson.avedata.ovaPath

      # ESXi
      $DEPLOYMENT_TARGET_ADDRESS=$esxiServer
      $DEPLOYMENT_TARGET_USERNAME=$username
      $DEPLOYMENT_TARGET_PASSWORD=$password
      $FAH_NAME=$myJson.avedata.VMName
      $FAH_NETWORK=$myJson.avedata.Network
      $FAH_DATASTORE=$myJson.avedata.Datastore
      #$FAH_DEPLOYMENT_SIZE=$myJson.avedata.DeploymentOption

      ### DO NOT EDIT BEYOND HERE ###

      & "${OVFTOOL_BIN_PATH}" `
      --X:injectOvfEnv `
      --powerOn `
      --acceptAllEulas `
      --noSSLVerify `
      --sourceType=OVF `
      --allowExtraConfig `
      --diskMode=thin `
      --name="${FAH_NAME}" `
      --network="${FAH_NETWORK}" `
      --datastore="${FAH_DATASTORE}" `
      "${FAH_OVA}" `
      "vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/"

    
       #Start-VM -VM $myJson.crdata.ovaName
       New-HardDisk -VM $VMName -CapacityGB 250 -StorageFormat $DiskStorageFormat
       New-HardDisk -VM $VMName -CapacityGB 250 -StorageFormat $DiskStorageFormat
       #Start-VM -VM $VMName
       sleep -s 120
       Copy-VMGuestFile -Destination '/root' -Source 'E:\Workspace\UIAutomation\CRS Exp Files\Netconfig_ave.exp' -LocalToGuest -GuestUser root -GuestPassword $defaultrootpass -VM $VMName
       $Command = "sudo expect Netconfig_ave.exp $ipv4address $gateway $fqdn $primarynameserver $ntp"
       $invoke_command=Invoke-VMScript -ScriptType Bash -ScriptText $Command -VM $VMName -GuestUser root -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue

             Copy-VMGuestFile -Destination '/root' -Source 'E:\Workspace\UIAutomation\Ave config file\Installconfig_test.yaml' -LocalToGuest -GuestUser root -GuestPassword $defaultrootpass -VM $VMName
              
             $Command1 = "sed -i -e 's/repl_password:/repl_password: $repl_password/; s/rootpass:/rootpass: $rootpass/; s/mcpass:/mcpass: $mcpass/' Installconfig_test.yaml"
             $Command2 = "sed -i -e 's/viewuserpass:/viewuserpass: $viewuserpass/; s/admin_password_os:/admin_password_os: $admin_password_os/' Installconfig_test.yaml"
             $Command3 = "sed -i -e 's/root_password_os:/root_password_os: $root_password_os/; s/keystore_passphrase:/keystore_passphrase: $keystore_passphrase/' Installconfig_test.yaml"
             $Command4 = "sed -i -e 's/^common_password:/common_password: $common_password/' Installconfig_test.yaml"
             $Command5 = "sed -i -e 's/use_common_password:/use_common_password: $use_common_password/' Installconfig_test.yaml"
             $Command6 = "sed -i -e 's=timezone_name:=timezone_name: $timezone_name=' Installconfig_test.yaml"

             Invoke-VMScript -ScriptType Bash -ScriptText $Command1 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command2 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command3 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command4 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command5 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
             Invoke-VMScript -ScriptType Bash -ScriptText $Command6 -VM $VMName -GuestUser "root" -GuestPassword $defaultrootpass -ErrorAction SilentlyContinue
          
              $Command7= "/opt/emc-tools/0.20.0/bin/avi-cli $ipv4 --user root --password $defaultrootpass --port 7543 --userinput Installconfig_test.yaml --backtrace --install ave-config"
              $secpasswd = ConvertTo-SecureString $defaultrootpass -AsPlainText -Force
              $Credentials = New-Object System.Management.Automation.PSCredential("root", $secpasswd)
              Start-Sleep -s 60
              Get-SSHTrustedHost | Remove-SSHTrustedHost
              $sessionID = New-SSHSession -ComputerName $ipv4 -Credential $Credentials -AcceptKey #Connect Over SSH

              Invoke-SSHCommand -Index $sessionID.sessionid -Command $Command7 -ErrorAction SilentlyContinue  # Invoke Command Over SSH
              sleep -s 1500
              Copy-VMGuestFile -Destination '/home/admin' -Source 'E:\Workspace\UIAutomation\CRS Exp Files\sshconfig_ave.exp' -LocalToGuest -GuestUser admin -GuestPassword $admin_password_os -VM $VMName
              $Command= "expect sshconfig_ave.exp $root_password_os"
              $sshout = Invoke-VMScript -ScriptType Bash -ScriptText $Command -VM $VMName -GuestUser admin -GuestPassword $admin_password_os
              $Command8="rm -rf /root/Installconfig_test.yaml"
              $remove_file = Invoke-VMScript -ScriptType Bash -ScriptText $Command8 -VM $VMName -GuestUser root -GuestPassword $root_password_os -ErrorAction SilentlyContinue
              $Command9="rm -rf /root/ Netconfig_ave.exp"
              $remove_file1 = Invoke-VMScript -ScriptType Bash -ScriptText $Command9 -VM $VMName -GuestUser root -GuestPassword $root_password_os -ErrorAction SilentlyContinue
              $Command10="rm -rf /home/admin/sshconfig_ave.exp"
              $remove_file2 = Invoke-VMScript -ScriptType Bash -ScriptText $Command10 -VM $VMName -GuestUser admin -GuestPassword $admin_password_os -ErrorAction SilentlyContinue

	   #Avamar Authentication
       if($sshout.ExitCode -eq "0")
	   {
	      Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] Avamar Deployment is successfull" 
           get-vm -Name $VMName | % {
                $vm = Get-View $_.ID
                $vms = "" | Select-Object VMName, IPAddress, VMState, NumberOfCPU, TotalMemoryMB,Datastore
                $vms.VMName = $vm.Name
                $vms.IPAddress = $vm.guest.ipAddress
                $vms.VMState = $vm.summary.runtime.powerState
                $vms.NumberOfCPU = $vm.summary.config.numcpu
                $vms.TotalMemoryMB = $vm.summary.config.memorysizemb
                $vms.Datastore = [string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))
                }
       Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] $vms"
            "Success" | Out-File -FilePath $filepath
	   }
		  else
		      {
			   Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] Avamar Deployment is failed"
                           "Failed" | Out-File -FilePath $filepath
			  }
     }
         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

           Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] $esxiServer successfully disconnected`n"
        }
        else {
              Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[INFO] The connection to $esxiServer is still open!`n"
  }

}
}
sleep -s 30
Remove-Item -Path $filepath -Confirm:$false -Force
#}
#catch{
     # $exception = $_.Exception.Message
      # Write-Log "E:\Workspace\UIAutomation\Log Files\Avamarlog.txt" "[ERROR] $exception" 
#}
