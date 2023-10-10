param($FormInput)
#Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
$fileName = $myJson.logfile
$filepath = "C:\inetpub\wwwroot\$fileName"
"InProgress" | Out-File -FilePath $filepath
Write-Host $filepath
Write-Host $fileName
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
       "Failed" | Out-File -FilePath $filepath

    }
     	elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"	
        "Failed" | Out-File -FilePath $filepath
	}
	elseif($ipdetail.IPAddress -contains $ip){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided ipaddress $ip is already in use`n"
        "Failed" | Out-File -FilePath $filepath
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Provided network $Network is invalid`n"
        "Failed" | Out-File -FilePath $filepath
	}

    else {

       $ovaConfig = Get-OvfConfiguration -Ovf $ovaPath

       $ovaConfig.ToHashTable()

       $ovaConfig = @{
  
         
          "vami.ipv4.NetWorker_Virtual_Edition" = $myJson.networkerdata.ipv4

          "vami.gatewayv4.NetWorker_Virtual_Edition" = $myJson.networkerdata.gateway
          
          "vami.NTP.NetWorker_Virtual_Edition" = $myJson.networkerdata.ntp

          "vami.DNS.NetWorker_Virtual_Edition" = $myJson.networkerdata.dns              
       
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
                 "Failed" | Out-File -FilePath $filepath
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
                "Failed" | Out-File -FilePath $filepath
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
             "Success" | Out-File -FilePath $filepath
            
       }

       else
       {
           Write-Log "E:\Workspace\UIAutomation\Log Files\Networkerlog.txt" "[ERROR] Networker Deployment is failed"
           "Failed" | Out-File -FilePath $filepath
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
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

     Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[INFO] esxiServer $esxiServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue

    if ($checkOva) {

       Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[ERROR] Provided VMName $VMName already exists`n"
       "Failed" | Out-File -FilePath $filepath

    }
        elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"	
        "Failed" | Out-File -FilePath $filepath

	}
	elseif($ipdetail.IPAddress -contains $ip){
	Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[ERROR] Provided ipaddress $ip is already in use`n"
        "Failed" | Out-File -FilePath $filepath
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[ERROR] Provided network $Network is invalid`n"
        "Failed" | Out-File -FilePath $filepath
	}

    else {
      Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[INFO] Initiating Networker Deployment"
      $OVFTOOL_BIN_PATH="C:\Users\crauser\Downloads\VMware-ovftool-4.4.3-18663434-win.x86_64\ovftool\ovftool.exe"
      $NETWORKER_OVA=$myJson.networkerdata.ovaPath

      # ESXi
      $DEPLOYMENT_TARGET_ADDRESS=$esxiServer
      $DEPLOYMENT_TARGET_USERNAME=$username
      $DEPLOYMENT_TARGET_PASSWORD=$password
      $NETWORKER_NAME=$myJson.networkerdata.VMName
      $NETWORKER_IP=$ip
      $NETWORKER_HOSTNAME=$myJson.networkerdata.fqdn
      $NETWORKER_GW=$myJson.networkerdata.gateway
      $NETWORKER_NETWORK=$myJson.networkerdata.Network
      $NETWORKER_DATASTORE=$myJson.networkerdata.Datastore
      $NETWORKER_USERNAME="root"
      $NETWORKER_DEPLOYMENT_SIZE=$myJson.networkerdata.DeploymentOption
      $NETWORKER_DNS= $myJson.networkerdata.dns
      $NETWORKER_NTP= $myJson.networkerdata.ntp
      $NETWORKER_TIMEZONE=$myJson.networkerdata.timezone
      $NETWORKER_DDIP=$myJson.networkerdata.ddip
      $NETWORKER_DDBoostUseExistingUsername="No"
      $NETWORKER_DDBoostUsername=""
      $NETWORKER_vCenterFQDN=$myJson.vcenterdata.vCenterServer
      $NETWORKER_vCenterusername=$myJson.vcenterdata.username

      ### DO NOT EDIT BEYOND HERE ###

      & "${OVFTOOL_BIN_PATH}" `
      --X:injectOvfEnv `
      --powerOn `
      --acceptAllEulas `
      --noSSLVerify `
      --sourceType=OVA `
      --allowExtraConfig `
      --diskMode=thin `
      --name="${NETWORKER_NAME}" `
      --net:"VM Network"="${NETWORKER_NETWORK}" `
      --datastore="${NETWORKER_DATASTORE}" `
      --prop:vami.ipv4.NetWorker_Virtual_Edition=${NETWORKER_IP} `
      --prop:vami.FQDN.NetWorker_Virtual_Edition=${NETWORKER_HOSTNAME} `
      --prop:vami.gatewayv4.NetWorker_Virtual_Edition=$NETWORKER_GW `
      --prop:vami.NTP.NetWorker_Virtual_Edition=${NETWORKER_NTP} `
      --prop:vami.DNS.NetWorker_Virtual_Edition=${NETWORKER_DNS} `
      --prop:vami.NVEtimezone.NetWorker_Virtual_Edition=${NETWORKER_TIMEZONE} `
      --prop:vami.DDIP.NetWorker_Virtual_Edition=${NETWORKER_DDIP} `
      --prop:vami.DDBoostUseExistingUser.NetWorker_Virtual_Edition=${NETWORKER_DDBoostUseExistingUsername} `
      --prop:vami.DDBoostUsername.NetWorker_Virtual_Edition=${NETWORKER_DDBoostUsername} `
      --prop:vami.vCenterFQDN.NetWorker_Virtual_Edition=${NETWORKER_vCenterFQDN} `
      --prop:vami.vCenterUsername.NetWorker_Virtual_Edition=${NETWORKER_vCenterusername} `
      "${NETWORKER_OVA}" `
      "vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/"

       $checkdeploy = Get-VM -Name $VMName -ErrorAction SilentlyContinue
       if($checkdeploy) {
       sleep -s 180
       Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[INFO] NetWorker Proxy Deployment is successfull" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[INFO] $vms"
               "Success" | Out-File -FilePath $filepath
      }
       else{
          
          Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[ERROR] NetWorker Proxy Deployment is failed"
          "Failed" | Out-File -FilePath $filepath
       }
   }
         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

             Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[INFO] $esxiServer successfully disconnected`n"
        }
        else {
             Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[INFO] The connection to $esxiServer is still open!`n"
  }

}
}
#sleep -s 30
#Remove-Item -Path $filepath -Confirm:$false -Force
}
catch{
      $exception = $_.Exception.Message
      Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxylog.txt" "[ERROR] $exception" 
      "Failed" | Out-File -FilePath $filepath
       sleep -s 30
      Remove-Item -Path $filepath -Confirm:$false -Force
}
