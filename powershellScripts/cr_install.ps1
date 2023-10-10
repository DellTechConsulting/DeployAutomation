param($FormInput)
#Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
#$filepath = "C:\inetpub\wwwroot\CRDeploymentStatus.txt"
$jsonfile = "E:\Workspace\UIAutomation\winstatus\CRStatus.json"
#"InProgress" | Out-File -FilePath $filepath

$fileName = $myJson.logfile
$filepath = "C:\inetpub\wwwroot\$fileName"
"InProgress" | Out-File -FilePath $filepath
#Write-Host $filepath

#Reading the values locally
$deploymentType = $myJson.deploymentType
$rootpass = "changeme"
$lockbox = $myJson.crdata.lockboxpassword
$Mongopass = $myJson.crdata.MongoDbpassword
$crsopass = $myJson.crdata.crsopassword
$ip = $myJson.crdata.ip_cr
$VMName = $myJson.crdata.VMName
$port = ":14777"
$baseuri = "https://$ip$port"
$datastore = $myJson.crdata.Datastore
$network = $myJson.crdata.Network

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
Function JsonDetail {
 
  [CmdletBinding()]
   
  Param ([Parameter(Mandatory=$true)][string]$LogFilePath, [Parameter(Mandatory=$true)][string]$DeploymentOn, [Parameter(Mandatory=$true)][string]$Component, [Parameter(Mandatory=$true)][string]$Status)
   
  Process{  
  $jsondata = [PSCustomObject]@{

         DeploymentOn = $DeploymentOn
         Component = $Component
         Status = $Status
        }  
    $creds = $jsondata | ConvertTo-Json | Out-File -FilePath $LogFilePath
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
#Write-Log "E:\Workspace\UIAutomation\DeploymentStatus.txt" "$VMName InProgress`n"

if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] Successfully connected to $vCenterServer`n" 

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue

    if ($checkOva) {

	   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $VMName already exists`n" 
           "Failed" | Out-File -FilePath $filepath
           #For Windows Application
           JsonDetail "E:\Workspace\UIAutomation\winstatus\CRStatus.json" "Vcenter" "CyberRecovery" "Failed"
    }
    elseif($datastoredetail.Name -notcontains $datastore){
          Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $datastore is invalid`n" 
          "Failed" | Out-File -FilePath $filepath	
    }
    elseif($ipdetail.IPAddress -contains $ip){
          Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] Provided IPAddress $ip is already in use`n" 
          "Failed" | Out-File -FilePath $filepath
    }
    elseif($networkdetail.Name -notcontains $network){
	   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $network is invalid`n" 
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
         $clusterdetail = Get-Cluster -ErrorAction SilentlyContinue
         $clustervalue = $myJson.crdata.hostData.value
	 if($clusterdetail.Name -contains $clustervalue){
         $esxiHost = Get-Cluster -Name $myJson.crdata.hostData.value | Get-VMHost | Get-Random
         Write-Output "Initiating CR Deployment"
         $deployOva = Import-vApp -Source $myJson.crdata.ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myJson.crdata.Datastore -DiskStorageFormat $myJson.crdata.DiskStorageFormat -Location $myJson.crdata.hostData.value
		 
		 }
		 else{
	         Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] Provided Cluster detail $clustervalue is invalid`n" 
                "Failed" | Out-File -FilePath $filepath
		 }
       }
       else
       {
	    $esxidetail= Get-VMHost -ErrorAction SilentlyContinue
            $esxivalue = $myJson.crdata.hostData.value
		if($esxidetail.Name -contains $esxivalue){
        $esxiHost = $myJson.crdata.hostData.value
        Write-Output "Initiating CR Deployment"
        $deployOva = Import-vApp -Source $myJson.crdata.ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myJson.crdata.Datastore -DiskStorageFormat $myJson.crdata.DiskStorageFormat
		}
        else{
	        Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] Provided ESXi detail $esxivalue is invalid`n" 
                "Failed" | Out-File -FilePath $filepath
		}
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
           "Failed" | Out-File -FilePath $filepath
           #For Windows Application
           JsonDetail "E:\Workspace\UIAutomation\winstatus\CRStatus.json" "Vcenter" "CyberRecovery" "Failed"
       }
       $req = Invoke-WebRequest -uri $baseuri -SkipCertificateCheck -ErrorAction SilentlyContinue
       $statuscode = "$($req.StatusCode)"
	   #CR Authentication
	   if($statuscode -eq "200")
	   {
		  Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] CR Deployment is Successful"
                  "Success" | Out-File -FilePath $filepath
                  JsonDetail "E:\Workspace\UIAutomation\winstatus\CRStatus.json" "Vcenter" "CyberRecovery" "Success"
	   }
		  else
		      {
			   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] CR Deployment is failed"
                           "Failed" | Out-File -FilePath $filepath
                           JsonDetail "E:\Workspace\UIAutomation\winstatus\CRStatus.json" "Vcenter" "CyberRecovery" "Failed"
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
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {
	Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] $esxiServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue

    if ($checkOva) {

	   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $VMName already exists`n"
           "Failed" | Out-File -FilePath $filepath
           JsonDetail "E:\Workspace\UIAutomation\winstatus\CRStatus.json" "Vcenter" "CyberRecovery" "Failed"	   

    }
    elseif($datastoredetail.Name -notcontains $myJson.crdata.Datastore){
          Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $datastore is invalid`n" 
          "Failed" | Out-File -FilePath $filepath	
    }
    elseif($ipdetail.IPAddress -contains $ip){
          Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] Provided IPAddress $ip is already in use`n" 
          "Failed" | Out-File -FilePath $filepath
    }
    elseif($networkdetail.Name -notcontains $myJson.crdata.Network){
	   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $network is invalid`n" 
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
       Write-Host "Test Installation"
       Sleep -s 10
       $req = Invoke-WebRequest -uri $baseuri -SkipCertificateCheck -ErrorAction SilentlyContinue
       $statuscode = "$($req.StatusCode)"
	   #CR Authentication
	   if($statuscode -eq "200")
	   {
		  Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[INFO] CR Deployment is Successful"
                  "Success" | Out-File -FilePath $filepath
                  JsonDetail "E:\Workspace\UIAutomation\winstatus\CRStatus.json" "Vcenter" "CyberRecovery" "Success"

	   }
		  else
		      {
			   Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] CR Deployment is failed"
                            "Failed" | Out-File -FilePath $filepath
                            JsonDetail "E:\Workspace\UIAutomation\winstatus\CRStatus.json" "Vcenter" "CyberRecovery" "Failed" 
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
#sleep -s 30
#Remove-Item -Path $filepath -Confirm:$false -Force
}
catch{
      $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $exception"
       "Failed" | Out-File -FilePath $filepath
       JsonDetail "E:\Workspace\UIAutomation\winstatus\CRStatus.json" "Vcenter" "CyberRecovery" "Failed"
       sleep -s 30
       Remove-Item -Path $filepath -Confirm:$false -Force
}
