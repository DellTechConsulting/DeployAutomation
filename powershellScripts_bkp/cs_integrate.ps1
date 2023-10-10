param($FormInput)
##################################################
$myJson = $FormInput | ConvertFrom-Json
$crpass = $myJson.cs_crdata.crpassword
$cruser = $myJson.cs_crdata.cruser
$nickname = $myJson.cs_crdata.nickName
$hostname = $myJson.cs_crdata.cshostname
$hostuser = $myJson.cs_crdata.cshostUsername
$hostpass = $myJson.cs_crdata.cshostPassword
$osType = $myJson.cs_crdata.osType
$type = $myJson.cs_crdata.type
$tag = $myJson.cs_crdata.tags
$ip = $myJson.cs_crdata.cr_ip
$port = ":14777" 
$baseuri = "https://$ip$port"
$loginuri = "$baseuri/cr/v7/login"
$appuri = "$baseuri/cr/v5/apps"
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
`n  `"osType`": `"$osType`",
`n  `"type`": `"$type`",
`n  `"tags`": [
`n    `"$tag`"
`n  ]
`n}"

$response = Invoke-RestMethod $appuri -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json
Write-Log "E:\Workspace\UIAutomation\Log Files\CS_integratelog.txt" "[INFO] Cyber Sense sucessfully integrated  with Cyber Recovery"
}
else
{
  Write-Log "E:\Workspace\UIAutomation\Log Files\CS_integratelog.txt" "[ERROR] Cyber Sense is unreachable"
}
}
catch{
      $exception = $_.Exception.Message
       Write-Log "E:\Workspace\UIAutomation\Log Files\CS_integratelog.txt" "[ERROR] $exception" 
}