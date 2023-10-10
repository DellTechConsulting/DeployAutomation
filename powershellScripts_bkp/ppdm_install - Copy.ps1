param($FormInput)
Write-Host $FormInput
##################################################
Import-Module 'Microsoft.PowerShell.Security'
$vCenterServer = $myJson.vcenterdata.vCenter
$username = $myJson.vcenterdata.username
$password = $myJson.vcenterdata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$rootpass = "changeme"
$ip = $myJson.ppdmdata.ipv4

if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

    Write-Verbose "$vCenterServer successfully connected`n"

    $checkOva = Get-VM -Name $myJson.ppdmdata.VMName -ErrorAction SilentlyContinue

    if ($checkOva) {

       Write-Output "$myJson.ppdmdata.VMName already exists`n"

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
          $esxiHost = Get-Cluster -Name $myJson.avedata.hostData.value | Get-VMHost | Get-Random
       }
       else
       {
         $esxiHost = $myJson.avedata.hostData.value
       }

       $deployOva = Import-vApp -Source $myJson.ppdmdata.ovaPath -OvfConfiguration $ovaConfig -Name $myJson.ppdmdata.VMName -VMHost $esxiHost -Location "Cluster" -InventoryLocation $myJson.ppdmdata.datacenter -Datastore $myJson.ppdmdata.Datastore -DiskStorageFormat $myJson.ppdmdata.DiskStorageFormat
       #Start-VM -VM $myJson.ppdmdata.ovaName
       if($deployOva.PowerState -eq "PoweredOff")
       {
       Start-VM -VM $myJson.ppdmdata.VMName
       sleep -s 650
try{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")

$body = @"
{
    `"username`": `"admin`",
	   `"password`": `"admin`"
}
"@
$response = Invoke-RestMethod "https://$($ip):8443/api/v2/login" -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json
$mytoken = $response.access_token
Write-Output $response
}
catch{
 $response = "Error"
}
if($response -ne "Error"){
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("authorization", $mytoken)
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")

$body = @"
{
    `"accepted`": true
}
"@

$response1 = Invoke-RestMethod "https://$($ip):8443/api/v2/eulas/data-manager" -Method 'PATCH' -Headers $headers -Body $body -SkipCertificateCheck
$response1| ConvertTo-Json
Write-Output $response1

##Get the Configurations

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("authorization", $mytoken)

$response2 = Invoke-RestMethod "https://$($ip):8443/api/v2/configurations" -Method 'GET' -Headers $headers -SkipCertificateCheck
$response2 | ConvertTo-Json
Write-Output $response2

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
Write-Output $response3
       }
       else
       {
       Write-Output "PPDM Deployment is failed"
       } 
       }
       else{
       Write-Output "Unable to login with defualt credentials"
       }
         Disconnect-VIServer -Server $MyServer -confirm:$false
       }

         if (!($global:DefaultVIServers.Count)) {

            Write-Verbose "$vCenterServer successfully disconnected`n"
        }
        else {
             Write-Output "The connection to $vCenterServer is still open!`n"
  }

}
}
