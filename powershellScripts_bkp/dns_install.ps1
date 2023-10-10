param($FormInput)
#Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
$esxiServer = $myJson.vmwaredata.server
$username = $myJson.vmwaredata.username
$password = $myJson.vmwaredata.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
$winname= $myJson.dnsdata.VMName
$winusername= $myJson.dnsdata.username
$winpassword= $myJson.dnsdata.password
$SecurePassword1 = $winpassword | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $winusername, $SecurePassword1
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

       $Command = "Install-WindowsFeature DNS"
       $res=Invoke-VMScript -ScriptType PowerShell -ScriptText $Command -VM $winname -GuestUser $winusername -GuestPassword $winpassword 
       Write-Output $res
       #$vmrestart=Get-VM $winname | Restart-VMGuest
       #Write-Output $vmrestart
    }
    else{
    }
    }