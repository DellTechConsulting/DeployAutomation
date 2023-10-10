param($FormInput)
#Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
$deploymentType = $myJson.deploymentType
$filepath = "E:\Workspace\UIAutomation\Statusfiles\CRDeploymentStatus.txt"
Function Write-Log {
 
  [CmdletBinding()]
   
  Param ([Parameter(Mandatory=$true)][string]$LogFilePath, [Parameter(Mandatory=$true)][string]$Message)
   
  Process{
    #Add Message to Log File with timestamp
    "$([datetime]::Now) : $Message" | Out-File -FilePath $LogFilePath -append;
   
    #Write the log message to the screen
    #Write-host $([datetime]::Now) $Message
  }
}
try{
if($deploymentType -eq "vCenter"){
$vCenterServer = $myJson.vcenterdata.vCenter
$username = $myJson.vcenterdata.username
$password = $myJson.vcenterdata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$rootpass = "changeme"
$lockbox = $myJson.crdata.lockboxpassword
$Mongopass = $myJson.crdata.MongoDbpassword
$crsopass = $myJson.crdata.crsopassword
$ip = $myJson.crdata.ip_cr
$VMName = $myJson.crdata.VMName
$port = ":14777"
$baseuri = "https://$ip$port"
#Write-Log "E:\Workspace\UIAutomation\DeploymentStatus.txt" "$VMName InProgress`n"
"InProgress" | Out-File -FilePath $filepath

if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] Successfully connected to $vCenterServer`n" 

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($checkOva) {

	   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $VMName already exists`n" 
           "Failed" | Out-File -FilePath $filepath

    }

    else {

       $ovaConfig = Get-OvfConfiguration -Ovf $myJson.crdata.ovaPath

       $ovaConfig.ToHashTable()

       $ovaConfig = @{
  
         
          "vami.fqdn.brs" = $myJson.crdata.fqdn

          "vami.DNS.brs" = $myJson.crdata.DNS
          
          "vami.NTP.brs" = $myJson.crdata.NTP                 
       
          "vami.gateway.brs" = $myJson.crdata.gateway                               
   
          "vami.netmask0.brs" = $myJson.crdata.netmask
    
          "vami.timezone.brs" = $myJson.crdata.timezone                
         
          "vami.ip0.brs" = $myJson.crdata.ip_cr                  
        
          "NetworkMapping.eth0 Network" = $myJson.crdata.Network
        }

       if($myJson.crdata.hostData.type -eq "cluster"){
         $esxiHost = Get-Cluster -Name $myJson.crdata.hostData.value | Get-VMHost | Get-Random
         $deployOva = Import-vApp -Source $myJson.crdata.ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myJson.crdata.Datastore -DiskStorageFormat $myJson.crdata.DiskStorageFormat -Location $myJson.crdata.hostData.value
       }
       else
       {
        $esxiHost = $myJson.crdata.hostData.value
        $deployOva = Import-vApp -Source $myJson.crdata.ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myJson.crdata.Datastore -DiskStorageFormat $myJson.crdata.DiskStorageFormat
       }
       if($deployOva.PowerState -eq "PoweredOff")
       {
       Start-VM -VM $VMName
       sleep -s 60
	   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] CR Deployment is successful" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] $vms"
       Copy-VMGuestFile -Destination '/home/admin/' -Source 'E:\Workspace\UIAutomation\CRS Exp Files\deploy.exp' -LocalToGuest -GuestUser admin -GuestPassword $rootpass -VM $VMName
       $Command = "expect deploy.exp $rootpass $lockbox $Mongopass $crsopass"
       Invoke-VMScript -ScriptType Bash -ScriptText $Command -VM $VMName -GuestUser admin -GuestPassword $rootpass -ErrorAction SilentlyContinue
       Sleep -s 10
       }
       else
       {
	   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] CR Deployment is failed"
       }
       $req = Invoke-WebRequest -uri $baseuri -SkipCertificateCheck -ErrorAction SilentlyContinue
       $statuscode = "$($req.StatusCode)"
	   #CR Authentication
	   if($statuscode -eq "200")
	   {
		  Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] CR Deployment is Successful"
          "Successful" | Out-File -FilePath $filepath
	   }
		  else
		      {
			   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] CR Deployment is failed"
			  }
         }
         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

			Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] $vCenterServer successfully disconnected`n"
        }
        else {
			 Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] The connection to $vCenterServer is still open!`n"
  }

}

}
else{
$esxiServer = $myJson.esxidata.esxiServer
$username = $myJson.esxidata.username
$password = $myJson.esxidata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$rootpass = "changeme"
$lockbox = $myJson.crdata.lockboxpassword
$Mongopass = $myJson.crdata.MongoDbpassword
$crsopass = $myJson.crdata.crsopassword
$ip = $myJson.crdata.ip_cr
$port = ":14777"
$baseuri = "https://$ip$port"
$VMName = $myJson.crdata.VMName
"InProgress" | Out-File -FilePath $filepath
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {
	Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] $esxiServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($checkOva) {

	   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $VMName already exists`n"
           "Failed" | Out-File -FilePath $filepath
	   

    }

    else {

      $OVFTOOL_BIN_PATH="C:\Users\crauser\Downloads\VMware-ovftool-4.4.3-18663434-win.x86_64\ovftool\ovftool.exe"
      $CR_OVA=$myJson.crdata.ovaPath

      # ESXi
      $DEPLOYMENT_TARGET_ADDRESS=$esxiServer
      $DEPLOYMENT_TARGET_USERNAME=$username
      $DEPLOYMENT_TARGET_PASSWORD=$password
      $CR_NAME=$VMName
      $CR_IP=$ip
      $CR_HOSTNAME=$myJson.crdata.fqdn
      $CR_GW=$myJson.crdata.gateway
      $CR_Netmask=$myJson.crdata.netmask
      #$CR_DNS="192.168.30.1"
      #$CR_DNS_DOMAIN="primp-industries.com"
      #$CR_NTP="pool.ntp.org"
      $CR_NETWORK=$myJson.crdata.Network
      $CR_DATASTORE=$myJson.crdata.Datastore
      $CR_USERNAME="admin"
      $CR_DEPLOYMENT_SIZE=$myJson.crdata.DeploymentOption

      ### DO NOT EDIT BEYOND HERE ###

      & "${OVFTOOL_BIN_PATH}" `
      --X:injectOvfEnv `
      --powerOn `
      --acceptAllEulas `
      --noSSLVerify `
      --sourceType=OVA `
      --allowExtraConfig `
      --diskMode=thin `
      --name="${CR_NAME}" `
      --net:"VM Network"="${CR_NETWORK}" `
      --datastore="${CR_DATASTORE}" `
      --prop:vami.ip0.brs=${CR_IP} `
      --prop:vami.netmask0.brs=$CR_Netmask `
      --prop:vami.fqdn.brs=${CR_HOSTNAME} `
      --prop:vami.gateway.brs=$CR_GW `
      --prop:vami.NTP.brs=${CR_NTP} `
      "${CR_OVA}" `
      "vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/"

       #Start-VM -VM $VMName
       sleep -s 60
       Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] CR Deployment is successful" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] $vms"
       Copy-VMGuestFile -Destination '/home/admin/' -Source 'E:\Workspace\UIAutomation\CRS Exp Files\deploy.exp' -LocalToGuest -GuestUser admin -GuestPassword $rootpass -VM $VMName
       $Command = "expect deploy.exp $rootpass $lockbox $Mongopass $crsopass"
       Invoke-VMScript -ScriptType Bash -ScriptText $Command -VM $VMName -GuestUser admin -GuestPassword $rootpass -ErrorAction SilentlyContinue
       Sleep -s 10
       $req = Invoke-WebRequest -uri $baseuri -SkipCertificateCheck -ErrorAction SilentlyContinue
       $statuscode = "$($req.StatusCode)"
	   #CR Authentication
	   if($statuscode -eq "200")
	   {
		  Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] CR Deployment is Successful"
                  "Successful" | Out-File -FilePath $filepath
	   }
		  else
		      {
			   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] CR Deployment is failed"
			  }
		}
         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

			Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] $esxiServer successfully disconnected`n"
        }
        else {
			 Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] The connection to $esxiServer is still open!`n"
  }
}
}
}
catch{
      $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $exception"
       "Failed" | Out-File -FilePath $filepath
}
