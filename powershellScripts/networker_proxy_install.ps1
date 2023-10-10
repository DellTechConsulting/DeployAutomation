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
$VMName = $myJson.nveproxydata.VMName
$ovaPath=$myJson.nveproxydata.ovaPath
$esxiHost= $myJson.nveproxydata.esxiHost
$myDatastore= $myJson.nveproxydata.myDatastore
$DiskStorageFormat= $myJson.nveproxydata.DiskStorageFormat
$ipv4 = $myJson.nveproxydata.ipv4
$Network= $myJson.nveproxydata.Network
$Netmask= $myJson.nveproxydata.netmask
$ntp= $myJson.nveproxydata.ntp
$dns= $myJson.nveproxydata.dns
$fqdn= $myJson.nveproxydata.fqdn
$gateway= $myJson.nveproxydata.gateway

if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] vCenter $vCenterServer successfully connected`n"
    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue

    if ($checkOva) {

       Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided VMName $VMName already exists`n"
       "Failed" | Out-File -FilePath $filepath
    }
        elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"	
        "Failed" | Out-File -FilePath $filepath
	}
	elseif($ipdetail.IPAddress -contains $ipv4){
	Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided ipaddress $ipv4 is already in use`n"
        "Failed" | Out-File -FilePath $filepath
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided network $Network is invalid`n"
        "Failed" | Out-File -FilePath $filepath
	}
    else {

       $ovaConfig = Get-OvfConfiguration -Ovf $ovaPath

       $ovaConfig.ToHashTable()

       $ovaConfig = @{
           
          "NetworkMapping.eth0 Network" = $Network
         
          "vami.ip0.vProxy" = $myJson.nveproxydata.ipv4

          "vami.netmask0.vProxy" = $myJson.nveproxydata.netmask

          "vami.gateway.vProxy" = $myJson.nveproxydata.gateway
          
          "vami.NTP.vProxy" = $myJson.nveproxydata.ntp

          "vami.DNS.vProxy" = $myJson.nveproxydata.dns

          "vami.fqdn.vProxy" =$myJson.nveproxydata.fqdn
          
          "vami.timezone.vProxy"= $myJson.nveproxydata.timezone

          "vami.adminpassword.vProxy"= $myJson.nveproxydata.adminpass

          "vami.rootpassword.vProxy"= $myjson.nveproxydata.rootpass


       }
         if($myJson.nveproxydata.hostData.type -eq "cluster"){
         $clusterdetail = Get-Cluster -ErrorAction SilentlyContinue
         $clustervalue = $myJson.nveproxydata.hostData.value
         Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] Initiating Networker Proxy Deployment"
	 if($clusterdetail.Name -contains $clustervalue){
       $esxiHost = Get-Cluster -Name $myJson.nveproxydata.hostData.value | Get-VMHost | Get-Random
       $deployOva = Import-vApp -Source $ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myDatastore -DiskStorageFormat $DiskStorageFormat
         }
            else{
		 Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided cluster name $clustervalue is invalid`n"
                 "Failed" | Out-File -FilePath $filepath
               }
       }
       else
       {
         $esxidetail= Get-VMHost -ErrorAction SilentlyContinue
         $esxivalue = $myJson.nveproxydata.hostData.value
	 if($esxidetail.Name -contains $esxivalue){
         $esxiHost = $myJson.nveproxydata.hostData.value
         Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] Initiating Networker Deployment"
         $deployOva = Import-vApp -Source $ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Datastore $myDatastore -DiskStorageFormat $DiskStorageFormat
        }
        else{
		Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided Esxi value $esxivalue is invalid`n"
                "Failed" | Out-File -FilePath $filepath
		}
       }
       if($deployOva.PowerState -eq "PoweredOff")
       {
       Start-VM -VM $VMName
       sleep -s 120
       Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] Networker Proxy Deployment is successfull" 
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
          Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] $vms"
             "Success" | Out-File -FilePath $filepath
            
       }
   else
       {
           Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Networker Proxy Deployment is failed"
           "Failed" | Out-File -FilePath $filepath
       }
  }

         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

            Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] $vCenterServer successfully disconnected`n"
        }
        else {
             Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] The connection to $vCenterServer is still open!`n"
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
$VMName = $myJson.nveproxydata.VMName
$ovaPath=$myJson.nveproxydata.ovaPath
$esxiHost= $myJson.nveproxydata.esxiHost
$myDatastore= $myJson.nveproxydata.myDatastore
$DiskStorageFormat= $myJson.nveproxydata.DiskStorageFormat
$ipv4 = $myJson.nveproxydata.ipv4
$Network= $myJson.nveproxydata.Network
$Netmask= $myJson.nveproxydata.netmask
$ntp= $myJson.nveproxydata.ntp
$dns= $myJson.nveproxydata.dns
$gateway= $myJson.nveproxydata.gateway

if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] esxiServer $esxiServer successfully connected`n"
    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    $datastoredetail = Get-Datastore -ErrorAction SilentlyContinue
    $ipdetail = Get-VM | Select @{N="IPAddress";E={@($_.guest.IPAddress[0])}} -ErrorAction SilentlyContinue
    $networkdetail = Get-VirtualNetwork -ErrorAction SilentlyContinue

    if ($checkOva) {

       Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided VMName $VMName already exists`n"
       "Failed" | Out-File -FilePath $filepath
    }
        elseif($datastoredetail.Name -notcontains $myDatastore){
	Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided datastore $myDatastore is invalid`n"	
        "Failed" | Out-File -FilePath $filepath

	}
	elseif($ipdetail.IPAddress -contains $ipv4){
	Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided ipaddress $ipv4 is already in use`n"
        "Failed" | Out-File -FilePath $filepath
	}
	elseif($networkdetail.Name -notcontains $Network){
	Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Provided network $Network is invalid`n"
        "Failed" | Out-File -FilePath $filepath
	}

    else {

      $OVFTOOL_BIN_PATH="C:\Users\crauser\Downloads\VMware-ovftool-4.4.3-18663434-win.x86_64\ovftool\ovftool.exe"
      $NVEPROXY_OVA=$myJson.nveproxydata.ovaPath

      # ESXi
      $DEPLOYMENT_TARGET_ADDRESS=$esxiServer
      $DEPLOYMENT_TARGET_USERNAME=$username
      $DEPLOYMENT_TARGET_PASSWORD=$password
      $NVEPROXY_NAME=$myJson.nveproxydata.VMName
      $NVEPROXY_IP=$ipv4
      $NVEPROXY_HOSTNAME=$myJson.nveproxydata.fqdn
      $NVEPROXY_GW=$myJson.nveproxydata.gateway
      $NVEPROXY_NETWORK=$myJson.nveproxydata.Network
      $NVEPROXY_DATASTORE=$myJson.nveproxydata.myDatastore
      $NVEPROXY_NETMASK= $myJson.nveproxydata.netmask
      $NVEPROXY_NTP= $myJson.nveproxydata.ntp
      $NVEPROXY_DNS= $myJson.nveproxydata.dns
      $NVEPROXY_TIMEZONE=$myJson.nveproxydata.timezone
      $NVEPROXY_NETWORK=$myJson.nveproxydata.Network
      $NVEPROXY_ADMINPASSWORD=$myJson.nveproxydata.adminpass
      $NVEPROXY_ROOTPASSWORD=$myJson.nveproxydata.rootpass

      ### DO NOT EDIT BEYOND HERE ###
      & "${OVFTOOL_BIN_PATH}" `
      --X:injectOvfEnv `
      --powerOn `
      --acceptAllEulas `
      --noSSLVerify `
      --sourceType=OVA `
      --allowExtraConfig `
      --diskMode=thin `
      --name="${NVEPROXY_NAME}" `
      --net:"VM Network"="${NVEPROXY_NETWORK}" `
      --datastore="${NVEPROXY_DATASTORE}" `
      --prop:vami.ip0.vProxy=${NVEPROXY_IP} `
      --prop:vami.gateway.vProxy=$NVEPROXY_GW `
      --prop:vami.fqdn.vProxy=${NVEPROXY_HOSTNAME} `
      --prop:vami.DNS.vProxy=${NVEPROXY_DNS} `
      --prop:vami.NTP.vProxy=${NVEPROXY_NTP} `
      --prop:vami.netmask0.vProxy=${NVEPROXY_NETMASK} `
      --prop:vami.timezone.vProxy=${NVEPROXY_TIMEZONE} `
      --prop:vami.adminpassword.vProxy=${NVEPROXY_ADMINPASSWORD} `
      --prop:vami.rootpassword.vProxy=${NVEPROXY_ROOTPASSWORD} `
      "${NVEPROXY_OVA}" `
      "vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/"

       $checkdeploy = Get-VM -Name $VMName -ErrorAction SilentlyContinue
       if($checkdeploy) {
       sleep -s 180
       Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] Networker Deployment is successfull" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] $vms"
               "Success" | Out-File -FilePath $filepath
      }
       else{
          
          Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] Networker Proxy Deployment is failed"
          "Failed" | Out-File -FilePath $filepath
       }
   }
         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

             Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] $esxiServer successfully disconnected`n"
        }
        else {
             Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[INFO] The connection to $esxiServer is still open!`n"
  }

}
}
#sleep -s 30
#Remove-Item -Path $filepath -Confirm:$false -Force
}
catch{
      $exception = $_.Exception.Message
      Write-Log "E:\Workspace\UIAutomation\Log Files\NetworkerProxyLog.txt" "[ERROR] $exception" 
      "Failed" | Out-File -FilePath $filepath
       sleep -s 30
      Remove-Item -Path $filepath -Confirm:$false -Force
}



