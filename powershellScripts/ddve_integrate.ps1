param($FormInput)
Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
$ip=$myJson.dd_crdata.cr_ip
$cruser=$myJson.dd_crdata.cruser
$crpass=$myJson.dd_crdata.crpassword
$nickname=$myJson.dd_crdata.storagename
$hostname=$myJson.dd_crdata.ddhostname
$hostuser=$myJson.dd_crdata.ddhostUsername
$hostpass=$myJson.dd_crdata.ddhostPassword
$tag=$myJson.dd_crdata.tags

####################################################################################################
$port = ":14777"
$baseuri = "https://$ip$port"
$loginuri = "$baseuri/cr/v7/login"
$storageuri = "$baseuri/cr/v7/storage"
$req = Invoke-WebRequest -uri $baseuri -SkipCertificateCheck
$statuscode = "$($req.StatusCode)"
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
if($statuscode -eq "200")
{
	      $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
          $headers.Add("Accept", "application/json")
          $headers.Add("Content-Type", "application/json")
          $crdata = [PSCustomObject]@{

                   username = $cruser
                   password = $crpass
          } 
          $creds = $crdata | ConvertTo-Json
          $response = Invoke-RestMethod $loginuri -Method 'POST' -Headers $headers -Body $creds -SkipCertificateCheck
          $response | ConvertTo-Json
          $mytoken= $response.accessToken
          #DDVE Integration to CyberRecovery
          $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
          $headers.Add("Content-Type", "application/json")
          $headers.Add("Accept", "application/json")
          $headers.Add("X-CR-AUTH-TOKEN", $mytoken)

          $body = "{
          `n  `"nickname`": `"$nickname`",
          `n  `"hostinfo`": {
          `n    `"hostname`": `"$hostname`",
          `n    `"hostUsername`": `"$hostuser`",
          `n    `"hostPassword`": `"$hostpass`",
          `n    `"sshPort`": 22
          `n  },
          `n  `"tags`": [
          `n    `"$tag`"
          `n  ]
          `n}"

          $response = Invoke-RestMethod $storageuri -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
          $response | ConvertTo-Json
         Write-Log "E:\Workspace\UIAutomation\Log Files\DDVE_integratelog.txt" "[INFO] DDVE successfully integrated with Cyber Recovery"
 } 
		  else
		      {
			   Write-Log "E:\Workspace\UIAutomation\Log Files\DDVE_integratelog.txt" "[ERROR] DDVE is unreachable"
			  }
}

catch{
      $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\DDVE_integratelog.txt" "[ERROR] $exception" 
}