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
$fileName = $myJson.logfile
$filepath = "C:\inetpub\wwwroot\$fileName"
"InProgress" | Out-File -FilePath $filepath
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
try{
if ($LoginCredentials) {

  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false

  $MyServer = Connect-VIServer -Server $esxiServer -Protocol https -Credential $LoginCredentials

  if ($MyServer) {

       $Command = "Install-WindowsFeature DNS"
       $res=Invoke-VMScript -ScriptType PowerShell -ScriptText $Command -VM $winname -GuestUser $winusername -GuestPassword $winpassword 
       Write-Output $res
       #$vmrestart=Get-VM $winname | Restart-VMGuest
       "Success" | Out-File -FilePath $filepath
    }
      else{
          Write-Log "E:\Workspace\UIAutomation\Log Files\DNSLog.txt" "Unable to enable the DNS`n" 
         "Failed" | Out-File -FilePath $filepath
       }
    else{
       Write-Log "E:\Workspace\UIAutomation\Log Files\DNSLog.txt" "Unable to connect to the server $esxiServer`n" 
       "Failed" | Out-File -FilePath $filepath
    }
    }
sleep -s 30
Remove-Item -Path $filepath -Confirm:$false -Force
}
catch{
       $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\DNSLog.txt" "[ERROR] $exception"
       "Failed" | Out-File -FilePath $filepath
       sleep -s 30
       Remove-Item -Path $filepath -Confirm:$false -Force
}