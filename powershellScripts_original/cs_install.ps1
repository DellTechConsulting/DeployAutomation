param($FormInput)
##################################################
#Write-Host $FormInput
$myJson = $FormInput | ConvertFrom-Json
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
$fileName = $myJson.logfile
$filepath = "C:\inetpub\wwwroot\$fileName"
"InProgress" | Out-File -FilePath $filepath
Write-Host $filepath
if($myJson.deploymentType -eq "vCenter"){
$vCenterServer = $myJson.vcenterdata.vCenter
$username = $myJson.vcenterdata.username
$password = $myJson.vcenterdata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$VMName = $myJson.csdata.VMName
try{
if ($LoginCredentials) {
  $ip = $myJson.csdata.ip_cs
  $baseuri = "https://$ip"
  $currentpass = $myJson.csdata.defaultadminpass
  $changepass = $myJson.csdata.newadminpass
  $csuser = "admin"
  $SecureCSoldPassword = $currentpass | ConvertTo-SecureString -AsPlainText -Force
  $SecureCSnewPassword = $changepass | ConvertTo-SecureString -AsPlainText -Force
  $CSoldLoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $csuser, $SecureCSoldPassword
  $CSnewLoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $csuser, $SecureCSnewPassword
  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false
  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

	Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] vCenter $vCenterServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($checkOva) {

	   Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[ERROR] $VMName already exists`n"
           "Failed" | Out-File -FilePath $filepath

    }

    else {

       $ovaConfig = Get-OvfConfiguration -Ovf  $myJson.csdata.ovaPath

       $ovaConfig.ToHashTable()

       $ovaConfig = @{

          "NetworkMapping.eth3 Network" = $myJson.csdata.Network3                     

          "NetworkMapping.eth1 Network" = $myJson.csdata.Network1    
         
          "vami.fqdn.brs" = $myJson.csdata.fqdn
          
          "DeploymentOption" = $myJson.csdata.DeploymentOption                  
   
          "NetworkMapping.eth2 Network" = $myJson.csdata.Network2    
       
          "vami.gateway.brs" = $myJson.csdata.gateway                               
   
          "vami.netmask0.brs" = $myJson.csdata.netmask0
          
          "vami.DNS.brs" = $myJson.csdata.DNS
          
          "vami.NTP.brs" = $myJson.csdata.NTP 
    
          "vami.timezone.brs" = $myJson.csdata.timezone                
         
          "vami.ip0.brs" = $ip                  
        
          "NetworkMapping.eth0 Network" = $myJson.csdata.Network0

       }
       if($myJson.csdata.hostData.type -eq "cluster"){
         $esxiHost = Get-Cluster -Name $myJson.csdata.hostData.value | Get-VMHost | Get-Random
       }
       else
       {
        $esxiHost = $myJson.csdata.hostData.value
       }
       $deployOva = Import-vApp -Source $myJson.csdata.ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myJson.csdata.Datastore -DiskStorageFormat $myJson.csdata.DiskStorageFormat
       Start-VM -VM $VMName
       sleep -s 90
       Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] CS Deployment is successful" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] $vms"
	   $sessionID = New-SSHSession -ComputerName $ip -Credential $CSoldLoginCredentials -Force -ErrorAction SilentlyContinue #Connect Over SSH with Old Crdentials
	   if($sessionID.Connected -eq "True")
	   {
       try{
       Set-Location C:\Python311
       python.exe E:\Workspace\UIAutomation\Scripts\ssh_paramiko.py $ip $currentpass $changepass
       }
       catch{
          Write-Output ""
       }
       }
       else
       {
		 Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[ERROR] CS Deployment is failed"
                 "Failed" | Out-File -FilePath $filepath
       }
	   $sessionID = New-SSHSession -ComputerName $ip -Credential $CSnewLoginCredentials -Force -ErrorAction SilentlyContinue #Connect Over SSH with New Crdentials
	   if($sessionID.Connected -eq "True")
	   {
		Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] CS Deployment is completed"
                "Success" | Out-File -FilePath $filepath
	   }
	   else{
		Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[WARNING] CS Deployment is completed but password hasn't changed"
                "Failed" | Out-File -FilePath $filepath
	   }

    }

    Disconnect-VIServer -Server $MyServer -confirm:$false

  }

  if (!($global:DefaultVIServers.Count)) {

	Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] $vCenterServer successfully disconnected`n"

  }

  else {

    Write-Output "The connection to $vCenterServer is still open!`n"
	Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] The connection to $vCenterServer is still open!`n"

  }

}
}
catch{
      $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[ERROR] $exception"
       "Failed" | Out-File -FilePath $filepath
        sleep -s 30
        Remove-Item -Path $filepath -Confirm:$false -Force

}
}
else{
$esxiServer = $myJson.esxidata.esxiServer
$username = $myJson.esxidata.username
$password = $myJson.esxidata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$VMName = $myJson.csdata.VMName
#"InProgress" | Out-File -FilePath $filepath
try{
if ($LoginCredentials) {
  $ip = $myJson.csdata.ip_cs
  $currentpass = $myJson.csdata.defaultadminpass
  $changepass = $myJson.csdata.newadminpass
  $csuser = "admin"
  $SecureCSoldPassword = $currentpass | ConvertTo-SecureString -AsPlainText -Force
  $SecureCSnewPassword = $changepass | ConvertTo-SecureString -AsPlainText -Force
  $CSoldLoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $csuser, $SecureCSoldPassword
  $CSnewLoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $csuser, $SecureCSnewPassword
  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false
  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

	Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] $Successfully connected to Esxi Host`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($checkOva) {

	   Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[ERROR] $VMName already exists`n"
           "Failed" | Out-File -FilePath $filepath

    }

    else {

      $OVFTOOL_BIN_PATH="C:\Users\crauser\Downloads\VMware-ovftool-4.5.0-20459872-win.x86_64\ovftool\ovftool.exe"
      $FAH_OVA=$myJson.csdata.ovaPath

      # ESXi
      $DEPLOYMENT_TARGET_ADDRESS=$esxiServer
      $DEPLOYMENT_TARGET_USERNAME=$username
      $DEPLOYMENT_TARGET_PASSWORD=$password
      $FAH_CPU_COUNT="4"
      $FAH_NAME=$VMName
      $FAH_DeploymentOption=$myJson.csdata.DeploymentOption
      $FAH_IP=$ip
      $FAH_HOSTNAME=$myJson.csdata.fqdn
      $FAH_GW=$myJson.csdata.gateway
      $FAH_Netmask=$myJson.csdata.netmask0
      $FAH_DNS=$myJson.csdata.DNS
      #$FAH_DNS_DOMAIN="primp-industries.com"
      $FAH_NTP=$myJson.csdata.NTP
      $FAH_OS_PASSWORD=$myJson.csdata.defaultadminpass
      $FAH_NETWORK0=$myJson.csdata.Network0
      $FAH_DATASTORE=$myJson.csdata.Datastore
      $FAH_USERNAME="admin"
      $FAH_DEPLOYMENT_SIZE=$myJson.csdata.DeploymentOption
      $FAH_timezone=$myJson.csdata.timezone
      Write-Host $FAH_IP $FAH_NETWORK $FAH_DATASTORE $FAH_HOSTNAME  
      ### DO NOT EDIT BEYOND HERE ###

      & "${OVFTOOL_BIN_PATH}" `
      --X:injectOvfEnv `
      --acceptAllEulas `
      --noSSLVerify `
      --sourceType=OVA `
      --allowExtraConfig `
      --diskMode=thin `
      --X:waitForIp `
      --powerOn `
      --name="${FAH_NAME}" `
      --deploymentOption="${FAH_DeploymentOption}" `
      --net:"eth0 Network"="${FAH_NETWORK0}" `
      --net:"eth1 Network"="VM Network" `
      --net:"eth2 Network"="VM Network" `
      --net:"eth3 Network"="VM Network" `
      --datastore="${FAH_DATASTORE}" `
      --prop:vami.ip0.brs="${FAH_IP}" `
      --prop:vami.netmask0.brs="${FAH_Netmask}" `
      --prop:vami.fqdn.brs="${FAH_HOSTNAME}" `
      --prop:vami.gateway.brs="${FAH_GW}" `
      --prop:vami.NTP.brs="${FAH_NTP}" `
      --prop:vami.DNS.brs="${FAH_DNS}" `
      --prop:vami.timezone.brs="${FAH_timezone}" `
      "E:\\CR_Automation_Files\\dellemc-cyber-sense-8.2.0-1.23_15.ova" `
      "vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/"
      # Start-VM -VM $myJson.csdata.ovaName
       sleep -s 90
       Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] CS Deployment is successful" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] $vms"
       $sessionID = New-SSHSession -ComputerName $ip -Credential $CSoldLoginCredentials -Force -ErrorAction SilentlyContinue #Connect Over SSH with Old Crdentials
	   if($sessionID.Connected -eq "True")
	   {
       try{
       Set-Location C:\Python311
       python.exe C:\Users\crauser\Documents\CS\ssh_paramiko.py $ip $currentpass $changepass
       }
       catch{
          Write-Output ""
       }
       }
       else
       {
		 Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[ERROR] CS Deployment is failed"
                 "Failed" | Out-File -FilePath $filepath
       }
	   $sessionID = New-SSHSession -ComputerName $ip -Credential $CSnewLoginCredentials -Force -ErrorAction SilentlyContinue #Connect Over SSH with New Crdentials
	   if($sessionID.Connected -eq "True")
	   {
		Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] CS Deployment is completed"
                "Success" | Out-File -FilePath $filepath
	   }
	   else{
		Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[WARNING] CS Deployment is completed but password hasn't changed"
                "Failed" | Out-File -FilePath $filepath
	   }

    }
	}
	
    Disconnect-VIServer -Server $MyServer -confirm:$false

  }

  if (!($global:DefaultVIServers.Count)) {

	Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] $esxiServer successfully disconnected`n"

  }

  else {
	Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[INFO] The connection to $esxiServer is still open!`n"

  }
}

catch{
      $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\CSLog.txt" "[ERROR] $exception"
       "Failed" | Out-File -FilePath $filepath
       sleep -s 30
       Remove-Item -Path $filepath -Confirm:$false -Force
       
}
}
#sleep -s 30
#Remove-Item -Path $filepath -Confirm:$false -Force