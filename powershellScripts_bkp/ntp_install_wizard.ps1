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
$vmname=$myJson.ntpdata.VMName
$user=$myJson.ntpdata.username
$pass=$myJson.ntpdata.password
$ntpname=$myJson.ntpdata.NTPName
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {
       $Command = "New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name $ntpname -Value 1 -Type DWord"
       $res = Invoke-VMScript -ScriptType PowerShell -ScriptText $Command -VM $vmname -GuestUser $user -GuestPassword $pass
       if($res){
       Write-Output "Enabled the NTP and Restarting the VM"
       $vmrestart=Get-VM $vmname | Restart-VMGuest
       }
       else{
         Write-Output "Unable to enable the NTP"
       }
       
    }
    else{
       Write-Output "Unable to connect to the server $esxiServer"
    }
    }