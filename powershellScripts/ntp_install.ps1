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
$fileName = $myJson.logfile
$filepath = "C:\inetpub\wwwroot\$fileName"
"InProgress" | Out-File -FilePath $filepath
sleep -s 180
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
       $Command = "New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name $ntpname -Value 1 -Type DWord"
       $res = Invoke-VMScript -ScriptType PowerShell -ScriptText $Command -VM $vmname -GuestUser $user -GuestPassword $pass
       if($res){
       $vmrestart=Get-VM $vmname | Restart-VMGuest
       Write-Log "E:\Workspace\UIAutomation\Log Files\NTPLog.txt" "Enabled the NTP and Restarted the VM`n" 
       "Success" | Out-File -FilePath $filepath
       }
       else{
          Write-Log "E:\Workspace\UIAutomation\Log Files\NTPLog.txt" "Unable to enable the NTP`n" 
         "Failed" | Out-File -FilePath $filepath
       }
       
    }
    else{
       Write-Log "E:\Workspace\UIAutomation\Log Files\NTPLog.txt" "Unable to connect to the server $esxiServer`n" 
       "Failed" | Out-File -FilePath $filepath
    }
    }
sleep -s 30
Remove-Item -Path $filepath -Confirm:$false -Force
}
catch{
       $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\NTPLog.txt" "[ERROR] $exception"
       "Failed" | Out-File -FilePath $filepath
       sleep -s 30
       Remove-Item -Path $filepath -Confirm:$false -Force
}