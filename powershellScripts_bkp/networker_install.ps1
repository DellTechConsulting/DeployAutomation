param($FormInput)
#Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
$filepath = "E:\Workspace\UIAutomation\NetworkerDeploymentStatus.txt"
$deploymentType = $myJson.deploymentType
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
"InProgress" | Out-File -FilePath $filepath
try
{
if($deploymentType -eq "vCenter"){
$vCenterServer = $myJson.vcenterdata.vCenter
$username = $myJson.vcenterdata.username
$password = $myJson.vcenterdata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$VMName = $myJson.networkerdata.VMName
$ovaPath=$myJson.networkerdata.ovaPath
#$esxiHost= $myJson.networkerdata.esxiHost
$myDatastore= $myJson.networkerdata.Datastore
$DiskStorageFormat= $myJson.networkerdata.DiskStorageFormat
$ip = $myJson.networkerdata.ipv4
$Network= $myJson.networkerdata.Network

if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] vCenter $vCenterServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue
    if ($checkOva) {

       Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided VMName $VMName already exists`n"

    }
     	elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"	
	}
	elseif($ipdetail.IPAddress -contains $ip){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided ipaddress $ip is already in use`n"
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided network $Network is invalid`n"
	}

    else {

       $ovaConfig = Get-OvfConfiguration -Ovf $ovaPath

       $ovaConfig.ToHashTable()

       $ovaConfig = @{
  
         
          "vami.ipv4.NetWorker_Virtual_Edition" = $myJson.networkerdata.ipv4

          "vami.gatewayv4.NetWorker_Virtual_Edition" = $myJson.networkerdata.gateway
          
          "vami.NTP.NetWorker_Virtual_Edition" = $myJson.networkerdata.NTP

          "vami.DNS.NetWorker_Virtual_Edition" = $myJson.networkerdata.DNS              
       
          "vami.FQDN.NetWorker_Virtual_Edition" = $myJson.networkerdata.fqdn                             
   
          "vami.NVEtimezone.NetWorker_Virtual_Edition" = $myJson.networkerdata.timezone 

          "vami.DDIP.NetWorker_Virtual_Edition" = $myJson.networkerdata.ddip
          
          "vami.DDBoostUseExistingUser.NetWorker_Virtual_Edition" = "No"               
         
          "vami.DDBoostUsername.NetWorker_Virtual_Edition" = ""                
        
          "NetworkMapping.eth0 Network" = $myJson.networkerdata.Network

          "vami.vCenterFQDN.NetWorker_Virtual_Edition" = $myJson.vcenterdata.vCenterServer 

          "vami.vCenterUsername.NetWorker_Virtual_Edition" = $myJson.vcenterdata.username 

       }
       if($myJson.networkerdata.hostData.type -eq "cluster"){
         $clusterdetail = Get-Cluster -ErrorAction SilentlyContinue
         $clustervalue = $myJson.networkerdata.hostData.value
         Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] Initiating Networker Deployment"
	 if($clusterdetail.Name -contains $clustervalue){
       $esxiHost = Get-Cluster -Name $myJson.networkerdata.hostData.value | Get-VMHost | Get-Random
       $deployOva = Import-vApp -Source $ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myDatastore -DiskStorageFormat $DiskStorageFormat
         }
            else{
		 Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided cluster name $clustervalue is invalid`n"
               }
       }
       else
       {
         $esxidetail= Get-VMHost -ErrorAction SilentlyContinue
         $esxivalue = $myJson.networkerdata.hostData.value
	 if($esxidetail.Name -contains $esxivalue){
         $esxiHost = $myJson.networkerdata.hostData.value
         Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] Initiating Networker Deployment"
         $deployOva = Import-vApp -Source $ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myDatastore -DiskStorageFormat $DiskStorageFormat
        }
        else{
		Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided Esxi value $esxivalue is invalid`n"
		}
       }
       if($deployOva.PowerState -eq "PoweredOff")
       {
       Start-VM -VM $VMName
       sleep -s 120
       Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] Networker Deployment is successfull" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] $vms"
             "Successful" | Out-File -FilePath $filepath
       }

       else
       {
           Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Networker Deployment is failed"
       }
  }

         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

            Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] $vCenterServer successfully disconnected`n"
        }
        else {
             Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] The connection to $vCenterServer is still open!`n"
  }

}
}

else
{
$esxiServer = $myJson.esxidata.esxiServer
$username = $myJson.esxidata.username
$password = $myJson.esxidata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$VMName = $myJson.networkerdata.VMName
$ovaPath=$myJson.networkerdata.ovaPath
$esxiHost= $myJson.networkerdata.esxiHost
$myDatastore= $myJson.networkerdata.Datastore
$DiskStorageFormat= $myJson.networkerdata.DiskStorageFormat
$ip = $myJson.networkerdata.ipv4
$Network= $myJson.networkerdata.Network
"InProgress" | Out-File -FilePath $filepath
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

     Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] esxiServer $esxiServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue

    if ($checkOva) {

       Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided VMName $VMName already exists`n"

    }
        elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"	
	}
	elseif($ipdetail.IPAddress -contains $ip){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided ipaddress $ip is already in use`n"
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided network $Network is invalid`n"
	}

    else {
      Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] Initiating Networker Deployment"
      $OVFTOOL_BIN_PATH="C:\Users\crauser\Downloads\VMware-ovftool-4.4.3-18663434-win.x86_64\ovftool\ovftool.exe"
      $FAH_OVA=$myJson.networkerdata.ovaPath

      # ESXi
      $DEPLOYMENT_TARGET_ADDRESS=$esxiServer
      $DEPLOYMENT_TARGET_USERNAME=$username
      $DEPLOYMENT_TARGET_PASSWORD=$password
      $FAH_NAME=$myJson.networkerdata.VMName
      $FAH_IP=$ip
      $FAH_HOSTNAME=$myJson.networkerdata.fqdn
      $FAH_GW=$myJson.networkerdata.gateway
      $FAH_NETWORK=$myJson.networkerdata.Network
      $FAH_DATASTORE=$myJson.networkerdata.Datastore
      $FAH_USERNAME="root"
      $FAH_DEPLOYMENT_SIZE=$myJson.networkerdata.DeploymentOption
      $FAH_DNS= $myJson.networkerdata.DNS
      $FAH_NTP= $myJson.networkerdata.NTP
      $FAH_TIMEZONE=$myJson.networkerdata.timezone
      $FAH_DDIP=$myJson.networkerdata.ddip
      $FAH_DDBoostUseExistingUsername="No"
      $FAH_DDBoostUsername=""
      $FAH_vCenterFQDN=$myJson.vcenterdata.vCenterServer
      $FAH_vCenterusername=$myJson.vcenterdata.username

      ### DO NOT EDIT BEYOND HERE ###

      & "${OVFTOOL_BIN_PATH}" `
      --X:injectOvfEnv `
      --powerOn `
      --acceptAllEulas `
      --noSSLVerify `
      --sourceType=OVA `
      --allowExtraConfig `
      --diskMode=thin `
      --name="${FAH_NAME}" `
      --net:"VM Network"="${FAH_NETWORK}" `
      --datastore="${FAH_DATASTORE}" `
      --prop:vami.ipv4.NetWorker_Virtual_Edition=${FAH_IP} `
      --prop:vami.FQDN.NetWorker_Virtual_Edition=${FAH_HOSTNAME} `
      --prop:vami.gatewayv4.NetWorker_Virtual_Edition=$FAH_GW `
      --prop:vami.NTP.NetWorker_Virtual_Edition=${FAH_NTP} `
      --prop:vami.DNS.NetWorker_Virtual_Edition=${FAH_DNS} `
      --prop:vami.NVEtimezone.NetWorker_Virtual_Edition=${FAH_TIMEZONE} `
      --prop:vami.DDIP.NetWorker_Virtual_Edition=${FAH_DDIP} `
      --prop:vami.DDBoostUseExistingUser.NetWorker_Virtual_Edition=${FAH_DDBoostUseExistingUsername} `
      --prop:vami.DDBoostUsername.NetWorker_Virtual_Edition=${FAH_DDBoostUsername} `
      --prop:vami.vCenterFQDN.NetWorker_Virtual_Edition=${FAH_vCenterFQDN} `
      --prop:vami.vCenterUsername.NetWorker_Virtual_Edition=${FAH_vCenterusername} `
      "${FAH_OVA}" `
      "vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/"

    
       $checkdeploy = Get-VM -Name $VMName -ErrorAction SilentlyContinue
       if($checkdeploy) {
       sleep -s 120
       Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] Networker Deployment is successfull" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] $vms"
               "Successful" | Out-File -FilePath $filepath
      }
       else{
          Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Networker Deployment is failed"
       }
   }
         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

             Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] $esxiServer successfully disconnected`n"
        }
        else {
             Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[INFO] The connection to $esxiServer is still open!`n"
  }

}
}
}
catch{
      $exception = $_.Exception.Message
      Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] $exception" 
      "Failed" | Out-File -FilePath $filepath
}
