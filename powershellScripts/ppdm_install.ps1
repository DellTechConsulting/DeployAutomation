param($FormInput)
#Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
$deploymentType = $myJson.deploymentType
#$filepath = "C:\inetpub\wwwroot\PPDMDeploymentStatus.txt"
#"InProgress" | Out-File -FilePath $filepath

$fileName = $myJson.logfile
$filepath = "C:\inetpub\wwwroot\$fileName"
"InProgress" | Out-File -FilePath $filepath
Write-Host $filepath

$VMName = $myJson.ppdmdata.VMName
Import-Module 'Microsoft.PowerShell.Security'
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
Function ppdminstall {
sleep -s 650
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")

$body = @"
{
    `"username`": `"admin`",
	   `"password`": `"admin`"
}
"@
#$response = Invoke-RestMethod "https://$($ip):8443/api/v2/login" -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response = Invoke-RestMethod "https://$($ip)/api/v2/login" -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json
$mytoken = $response.access_token
#Write-Output $response

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("authorization", $mytoken)
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")

$body = @"
{
    `"accepted`": true
}
"@

#$response1 = Invoke-RestMethod "https://$($ip):8443/api/v2/eulas/data-manager" -Method 'PATCH' -Headers $headers -Body $body -SkipCertificateCheck
$response1 = Invoke-RestMethod "https://$($ip)/api/v2/eulas/data-manager" -Method 'PATCH' -Headers $headers -Body $body -SkipCertificateCheck
$response1| ConvertTo-Json
#Write-Output $response1

##Get the Configurations

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("authorization", $mytoken)

#$response2 = Invoke-RestMethod "https://$($ip):8443/api/v2/configurations" -Method 'GET' -Headers $headers -SkipCertificateCheck
$response2 = Invoke-RestMethod "https://$($ip)/api/v2/configurations" -Method 'GET' -Headers $headers -SkipCertificateCheck
$response2 | ConvertTo-Json
#Write-Output $response2

##Installation
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("authorization", $mytoken)
$headers.Add("Content-Type", "application/json")
$id = $response2.content.id
$network = $response2.content[0].networks | ConvertTo-Json
$applicationpass = $myJson.ppdmdata.applicationUserPassword
$timezone = $myJson.ppdmdata.timeZone
$lockphrase = $myJson.ppdmdata.defaultLockboxpassphrase
$newlock = $myJson.ppdmdata.newLockboxpassphrase
$ospass = $myJson.ppdmdata.defaultRootpassword
$osnewpass = $myJson.ppdmdata.newRootPassword
$adminpass = $myJson.ppdmdata.defaultAdminpassword
$adminnewpass = $myJson.ppdmdata.newAdminPassword

$body = @"
{
    `"id`": `"$id`",
    `"applicationUserPassword`": `"$applicationpass`",
    `"networks`": $network,
    `"ntpServers`": [],
    `"timeZone`": `"$timezone`",
    `"lockbox`": {
        `"passphrase`": `"$lockphrase`",
        `"newPassphrase`": `"$newlock`"
    },
    `"osUsers`": [
        {
            `"userName`": `"root`",
            `"password`": `"$ospass`",
            `"newPassword`": `"$osnewpass`",
            `"numberOfDaysToExpire`": 123
        },
        {
            `"userName`": `"admin`",
            `"password`": `"$adminpass`",
            `"newPassword`": `"$adminnewpass`",
            `"numberOfDaysToExpire`": 123
        }
    ],
    `"gettingStartedCompleted`": true,
    `"enable_firewall`": false,
    `"deployedPlatform`": `"VMWARE`"
}
"@
$port = ":8443"
$responseid = $response2.content.id
$baseuri = "https://$ip$port"
$det = "/api/v2/configurations/"
$config = "$baseuri$det"
$loginuri = "$config$id"
$response3 = Invoke-RestMethod $loginuri -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
$response3 | ConvertTo-Json
#Write-Output $response3 
"Success" | Out-File -FilePath $filepath   
}

try{
if($deploymentType -eq "vCenter"){
$vCenterServer = $myJson.vcenterdata.vCenter
$username = $myJson.vcenterdata.username
$password = $myJson.vcenterdata.password
#Write-Output $password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
#$rootpass = "changeme"
$ip = $myJson.ppdmdata.ipv4
#"InProgress" | Out-File -FilePath $filepath
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Log "E:\Workspace\UIAutomation\Log Files\PPDMLog.txt" "[INFO] vCenter $vCenterServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($checkOva) {

	   Write-Log "E:\Workspace\UIAutomation\Log Files\PPDMLog.txt" "[ERROR] $VMName already exists`n"
           "Failed" | Out-File -FilePath $filepath

    }

    else {

       $ovaConfig = Get-OvfConfiguration -Ovf $myJson.ppdmdata.ovaPath

       $ovaConfig.ToHashTable()

       $ovaConfig = @{
  
         
          "vami.fqdn.brs" = $myJson.ppdmdata.fqdn

          "vami.DNS.brs" = $myJson.ppdmdata.dns
          
          "vami.NTP.brs" = $myJson.ppdmdata.ntp
       
          "vami.gateway.brs" = $myJson.ppdmdata.gateway                               
   
          "vami.netmask0.brs" = $myJson.ppdmdata.netmask
    
          "vami.timezone.brs" = $myJson.ppdmdata.timezone                
         
          "vami.ip0.brs" = $ip                  
        
          "NetworkMapping.eth0 Network" = $myJson.ppdmdata.Network

       }
       if($myJson.ppdmdata.hostData.type -eq "cluster"){
          $esxiHost = Get-Cluster -Name $myJson.ppdmdata.hostData.value | Get-VMHost | Get-Random
       }
       else
       {
         $esxiHost = $myJson.ppdmdata.hostData.value
       }

       $deployOva = Import-vApp -Source $myJson.ppdmdata.ovaPath -OvfConfiguration $ovaConfig -Name $VMName -VMHost $esxiHost -Location "Cluster" -InventoryLocation $myJson.ppdmdata.datacenter -Datastore $myJson.ppdmdata.Datastore -DiskStorageFormat $myJson.ppdmdata.DiskStorageFormat
       Start-VM -VM $VMName
	   Write-Log "E:\Workspace\UIAutomation\Log Files\PPDMLog.txt" "[INFO] PPDM Deployment is successful" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\PPDMLog.txt" "[INFO] $vms"
       ppdminstall
	   }

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
$ip = $myJson.ppdmdata.ipv4
"InProgress" | Out-File -FilePath $filepath
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

	Write-Log "E:\Workspace\UIAutomation\Log Files\PPDMLog.txt" "[INFO] $esxiServer successfully connected`n"

    $checkOva = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if ($checkOva) {

	   Write-Log "E:\Workspace\UIAutomation\Log Files\PPDMLog.txt" "[ERROR] $VMName already exists`n"
           "Failed" | Out-File -FilePath $filepath

    }

    else {

      $OVFTOOL_BIN_PATH="C:\Users\crauser\Downloads\VMware-ovftool-4.4.3-18663434-win.x86_64\ovftool\ovftool.exe"
      $PPDM_OVA=$myJson.ppdmdata.ovaPath

      # ESXi
      $DEPLOYMENT_TARGET_ADDRESS=$esxiServer
      $DEPLOYMENT_TARGET_USERNAME=$username
      $DEPLOYMENT_TARGET_PASSWORD=$password
      $PPDM_NAME=$VMName
      $PPDM_IP=$ip
      $PPDM_HOSTNAME=$myJson.ppdmdata.fqdn
      $PPDM_GW=$myJson.ppdmdata.gateway
      $PPDM_Netmask=$myJson.ppdmdata.netmask
      $PPDM_DNS=$myJson.ppdmdata.dns
      $PPDM_NTP=$myJson.ppdmdata.ntp
      $PPDM_NETWORK=$myJson.ppdmdata.Network
      $PPDM_DATASTORE=$myJson.ppdmdata.Datastore

      ### DO NOT EDIT BEYOND HERE ###

      & "${OVFTOOL_BIN_PATH}" `
      --X:injectOvfEnv `
      --powerOn `
      --acceptAllEulas `
      --noSSLVerify `
      --sourceType=OVA `
      --allowExtraConfig `
      --diskMode=thin `
      --name="${PPDM_NAME}" `
      --net:"VM Network"="${PPDM_NETWORK}" `
      --datastore="${PPDM_DATASTORE}" `
      --prop:vami.ip0.brs=${PPDM_IP} `
      --prop:vami.netmask0.brs=$PPDM_Netmask `
      --prop:vami.fqdn.brs=${PPDM_HOSTNAME} `
      --prop:vami.gateway.brs=$PPDM_GW `
      --prop:vami.NTP.brs=${PPDM_NTP} `
      --prop:vami.DNS.brs=${PPDM_DNS} `
      "${PPDM_OVA}" `
      "vi://${DEPLOYMENT_TARGET_USERNAME}:${DEPLOYMENT_TARGET_PASSWORD}@${DEPLOYMENT_TARGET_ADDRESS}/"
       #Start-VM -VM $VMName
	   Write-Log "E:\Workspace\UIAutomation\Log Files\PPDMLog.txt" "[INFO] PPDM Deployment is successful" 
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
       Write-Log "E:\Workspace\UIAutomation\Log Files\PPDMLog.txt" "[INFO] $vms"
       ppdminstall
}
    }
}
}
sleep -s 30
Remove-Item -Path $filepath -Confirm:$false -Force
}
catch{
      $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\CRLog.txt" "[ERROR] $exception"
      "Failed" | Out-File -FilePath $filepath 
	  sleep -s 30
      Remove-Item -Path $filepath -Confirm:$false -Force
}