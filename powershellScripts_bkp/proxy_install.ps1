param($FormInput)
#Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
$deploymentType = $myJson.deploymentType
filepath = "E:\Workspace\UIAutomation\Ave_ProxyDeploymentStatus.txt"
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
if($deploymentType -eq "vCenter"){
$vCenterServer = $myJson.vcenterdata.vCenter
$username = $myJson.vcenterdata.username
$password = $myJson.vcenterdata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$VMName = $myJson.proxydata.VMName
$ovaPath=$myJson.proxydata.ovaPath
$myDatastore= $myJson.proxydata.Datastore
$DiskStorageFormat= $myJson.proxydata.DiskStorageFormat
$ip = $myJson.proxydata.ipv4
$Network= $myJson.proxydata.Network
$Netmask= $myJson.proxydata.netmask
"InProgress" | Out-File -FilePath $filepath
try
{
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] vCenter $vCenterServer successfully connected`n"
    
    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue

    if ($checkOva) {

       Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided VMName $VMName already exists`n"

    }
        elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"	
	}
	elseif($ipdetail.IPAddress -contains $ip){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided ipaddress $ip is already in use`n"
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided network $Network is invalid`n"
	}

    else {

       $ovaConfig = Get-OvfConfiguration -Ovf $ovaPath

       $ovaConfig.ToHashTable()

       $ovaConfig = @{
           
          "NetworkMapping.eth0 Network" = $Network
         
          "vami.ip0.Avamar_Virtual_Machine_Combined_Proxy" = $myJson.proxydata.ipv4

          "vami.netmask0.Avamar_Virtual_Machine_Combined_Proxy" = $myJson.proxydata.netmask

          "vami.gateway.Avamar_Virtual_Machine_Combined_Proxy" = $myJson.proxydata.gateway
          
          "vami.ntp.Avamar_Virtual_Machine_Combined_Proxy" = $myJson.proxydata.NTP


       }
       if($myJson.proxydata.hostData.type -eq "cluster"){
         $clusterdetail = Get-Cluster -ErrorAction SilentlyContinue
         $clustervalue = $myJson.proxydata.hostData.value
	 if($clusterdetail.Name -contains $clustervalue){
        Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] Initiating Avamar_proxy Deployment"
       $esxiHost = Get-Cluster -Name $myJson.proxydata.hostData.value | Get-VMHost | Get-Random
       $deployOva = Import-vApp -Source $ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myDatastore -DiskStorageFormat $DiskStorageFormat
         }
          else{
		 Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided cluster name $clustervalue is invalid`n"
               }
       }
       else
       {
         $esxidetail= Get-VMHost -ErrorAction SilentlyContinue
         $esxivalue = $myJson.proxydata.hostData.value
	 if($esxidetail.Name -contains $esxivalue){
         $esxiHost = $myJson.proxydata.hostData.value
         Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] Initiating Avamar_proxy Deployment"
         $deployOva = Import-vApp -Source $ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myDatastore -DiskStorageFormat $DiskStorageFormat
         }
               else{
		   Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided Esxi value $esxivalue is invalid`n"
		}        
         }
        
       Write-Host $esxiHost
       if($deployOva.PowerState -eq "PoweredOff")
       {
       Start-VM -VM $VMName
       sleep -s 120
       Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] Avamar_Proxy Deployment is successfull" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] $vms"
        Successful" | Out-File -FilePath $filepath
       }

       else
       {
         Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Avamar_Proxy Deployment is failed"
       }

         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

            Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] $vCenterServer successfully disconnected`n"
        }
        else {
             Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] The connection to $vCenterServer is still open!`n"
  }

}
}
}
}
catch{
      $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] $exception" 
      "Failed" | Out-File -FilePath $filepath
}

else
{
$esxiServer = $myJson.esxidata.esxiServer
$username = $myJson.esxidata.username
$password = $myJson.esxidata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$VMName = $myJson.proxydata.VMName
$ovaPath=$myJson.proxydata.ovaPath
$esxiHost= $myJson.proxydata.esxiHost
$myDatastore= $myJson.proxydata.Datastore
$DiskStorageFormat= $myJson.proxydata.DiskStorageFormat
$ip = $myJson.proxydata.ipv4
$Network= $myJson.proxydata.Network
$Netmask= $myJson.proxydata.netmask
"InProgress" | Out-File -FilePath $filepath
try
{
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] esxiServer $esxiServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue

    if ($checkOva) {

       Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided VMName $VMName already exists`n"

    }
        elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"
	}
	elseif($ipdetail.IPAddress -contains $ip){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided ipaddress $ip is already in use`n"
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Provided network $Network is invalid`n"
	}
    else {

      Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] Initiating Avamar_proxy Deployment"
      $OVFTOOL_BIN_PATH="C:\Users\crauser\Downloads\VMware-ovftool-4.4.3-18663434-win.x86_64\ovftool\ovftool.exe"
      $FAH_OVA=$myJson.proxydata.ovaPath

      # ESXi
      $DEPLOYMENT_TARGET_ADDRESS=$esxiServer
      $DEPLOYMENT_TARGET_USERNAME=$username
      $DEPLOYMENT_TARGET_PASSWORD=$password
      $FAH_NAME=$myJson.proxydata.VMName
      $FAH_IP=$ip
      $FAH_HOSTNAME=$myJson.proxydata.fqdn
      $FAH_GW=$myJson.proxydata.gateway
      $FAH_NETWORK=$myJson.proxydata.Network
      $FAH_DATASTORE=$myJson.proxydata.Datastore
      $FAH_NETMASK= $myJson.proxydata.netmask
      $FAH_NTP= $myJson.proxydata.NTP
      $FAH_DEPLOYMENT_SIZE=$myJson.proxydata.DeploymentOption
      

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
      --datastore="${FAH_DATASTORE}" `
      --prop:vami.ip0.Avamar_Virtual_Machine_Combined_Proxy=${FAH_IP} `
      --prop:vami.gateway.Avamar_Virtual_Machine_Combined_Proxy=$FAH_GW `
      --prop:vami.ntp.Avamar_Virtual_Machine_Combined_Proxy=${FAH_NTP} `
      --prop:vami.netmask0.Avamar_Virtual_Machine_Combined_Proxy=${FAH_NETMASK} `
      "${FAH_OVA}" `
      "vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/"

      sleep -s 120
      $checkdeploy = Get-VM -Name $VMName -ErrorAction SilentlyContinue
      if ($checkdeploy) {

         Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] Avamar_Proxy Deployment is successfull" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] $vms"
            Successful" | Out-File -FilePath $filepath

    }
        else
        {
         Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] Avamar_Proxy Deployment is failed"
        
        }
    }

         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

            Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] $esxiServer successfully disconnected`n"
        }
        else {
             Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[INFO] The connection to $esxiServer is still open!`n"
  }

}

}
}
catch{
      $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\Ave_proxylog.txt" "[ERROR] $exception" 
       "Failed" | Out-File -FilePath $filepath
}