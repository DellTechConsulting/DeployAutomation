param($FormInput)
#Write-Host $FormInput
$myJson = $FormInput | ConvertFrom-Json
#$filepath = "C:\inetpub\wwwroot\DDVEDeploymentStatus.txt"
#"InProgress" | Out-File -FilePath $filepath

$fileName = $myJson.logfile
$filepath = "C:\inetpub\wwwroot\$fileName"
"InProgress" | Out-File -FilePath $filepath
Write-Host $filepath

#Write-Host $FormInput
##################################################
$ip=$myJson.ipaddress.ddip

$ddveusername=$myJson.credentials.username
$ddvepassword=$myJson.credentials.password

$cradminuser_Name=$myJson.cradminuser.name
$cradminuser_Role=$myJson.cradminuser.role
$cradminuser_Password=$myJson.cradminuser.password

$secofficer1_Name=$myJson.secofficer1.name
$secofficer1_Role=$myJson.secofficer1.role
$secofficer1_Password=$myJson.secofficer1.password

$secofficer2_Name=$myJson.secofficer2.name
$secofficer2_Role=$myJson.secofficer2.role
$secofficer2_Password=$myJson.secofficer2.password

$new_pphrase=$myJson.systempphrase.pphrase_request.new_pphrase

#Write-Host $ip $ddveusername $ddvepassword $cradminuser_Name $cradminuser_Role $cradminuser_Password $secofficer1_Name $secofficer1_Role $secofficer1_Password $secofficer2_Name $secofficer2_Role $secofficer2_Password $new_pphrase
#############################################################################################################################################################################################################################################
$test = $FormInput | ConvertFrom-Json

# DDVE Authentication
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
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$requestbody= $test.credentials | ConvertTo-Json
$body=$requestbody
$response = Invoke-RestMethod "https://$($ip):3009/rest/v1.0/auth" -Method 'POST' -Headers $headers -Body $body  -ResponseHeadersVariable Headers -SkipCertificateCheck 
$response | ConvertTo-Json
$mytoken= $Headers['X-DD-AUTH-TOKEN'][0]
write-output $mytoken
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] DDVE Authentication is successful" 
#"Success" | Out-File -FilePath $filepath
}
catch{

$StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
    $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] DDVE Authentication is failed" 
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception" 
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}

#Display System id in DDVE

try
{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")
$headers.Add("X-DD-AUTH-TOKEN", "$mytoken")
$response1 = Invoke-RestMethod "https://$($ip):3009/rest/v1.0/system" -Method 'GET' -Headers $headers -SkipCertificateCheck
$response1 | ConvertTo-Json
$systemid= $response1.uuid.Replace(':','%3A')
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Successfully get the system id information"
#"Success" | Out-File -FilePath $filepath
}
catch{

$StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
    $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}

# check the DDVE LISCENSE

try
{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("X-DD-AUTH-TOKEN", "$mytoken")
$response2 = Invoke-RestMethod "https://$($ip):3009/rest/v2.0/dd-systems/$($systemid)/licenses" -Method 'GET' -Headers $headers -SkipCertificateCheck
$response2 | ConvertTo-Json
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Successfully get the license information" 
#"Success" | Out-File -FilePath $filepath
}
catch{

$StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
    $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}

# create users in DDVE

try
{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("X-DD-AUTH-TOKEN", "$mytoken")
$body=$test.cradminuser | ConvertTo-Json
$response4 = Invoke-RestMethod "https://$($ip):3009/rest/v1.0/dd-systems/$($systemid)/users" -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response4 | ConvertTo-Json
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Successfully created cradmin user "
#"Success" | Out-File -FilePath $filepath
}
catch{

$StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
    $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}

# create secofficer1 in DDVE

try
{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("X-DD-AUTH-TOKEN", "$mytoken")
$body=$test.secofficer1 | ConvertTo-Json
$response4 = Invoke-RestMethod "https://$($ip):3009/rest/v1.0/dd-systems/$($systemid)/users" -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response4 | ConvertTo-Json

Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Successfully created secofficer1 user " 
#"Success" | Out-File -FilePath $filepath
}
catch{

$StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
    $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}

# login into DDVE with secofficer1 credentials

try
{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
#$requestbody= $test.secofficer1.name: | ConvertTo-Json
$username= $test.secofficer1.name
$password= $test.secofficer1.password
$body = "{
`n
`n    `"username`": `"$username`",
`n    `"password`": `"$password`"
`n
`n}"
$ip= $test.ipaddress.ddip
$response5 = Invoke-RestMethod "https://$($ip):3009/rest/v1.0/auth" -Method 'POST' -Headers $headers -Body $body  -ResponseHeadersVariable Headers -SkipCertificateCheck 
$response5 | ConvertTo-Json
$mytoken1= $Headers['X-DD-AUTH-TOKEN'][0]
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] DDVE Authentication is successful using secofficer1 credentials " 
#"Success" | Out-File -FilePath $filepath
}
catch{

$StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
    $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}

# create secofficer2 users in DDVE

try
{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("X-DD-AUTH-TOKEN", "$mytoken1")
$requestbody= $test.secofficer2 | ConvertTo-Json
$body=$requestbody
$response6 = Invoke-RestMethod "https://$($ip):3009/rest/v1.0/dd-systems/$($systemid)/users" -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response6 | ConvertTo-Json
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Successfully created ddve secofficer2 user " 
#"Success" | Out-File -FilePath $filepath
}
catch{

$StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
        $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}


#Enable system passphrase

try
{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")
$headers.Add("X-DD-AUTH-TOKEN", "$mytoken")
$requestbody= $new_pphrase | ConvertTo-Json
#$body=$requestbody
$body = "{
`n    `"operation`": `"set_pphrase`",
`n    `"pphrase_request`": {
`n        `"new_pphrase`": `"$new_pphrase`"
`n    }
`n}"
$response8 = Invoke-RestMethod "https://$($ip):3009/rest/v3.0/dd-systems/$($systemid)/systems" -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
$response8 | ConvertTo-Json
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Successfully enabled ddve system passphrase " 
#"Success" | Out-File -FilePath $filepath
}
catch{

$StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
    $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] Failed to enable ddve system passphrase "
    "Failed" | Out-File -FilePath $filepath 
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}

#Enable filesys encryption

try
{
$Command = "filesys encryption enable"
$Command1= "filesys restart"
$secpasswd = ConvertTo-SecureString $ddvepassword -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential($ddveusername, $secpasswd)
$sessionID = New-SSHSession -ComputerName $ip -Credential $Credentials -Force #Connect Over SSH
Invoke-SSHCommand -Index $sessionID.sessionid -Command $Command  # Invoke Command Over SSH
sleep -s 2
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Successfully enable ddve filesys encryption" 
Invoke-SSHCommand -Index $sessionID.sessionid -Command $Command1 
Sleep -s 2
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Successfully enable ddve filesys restart" 
#"Success" | Out-File -FilePath $filepath
}
catch{

    $StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
      $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] Failed to enable ddve filesys encryption" 
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}

# Enable DDboost

try
{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")
$headers.Add("X-DD-AUTH-TOKEN", "$mytoken")
$body = "{
`n    `"operation`": `"enable`",
`n    `"ddboost_options`": [
`n        {
`n            `"option`": `"distributed_segment_processing`",
`n            `"value`": `"enabled`"
`n        }
`n    ],
`n    `"ddboost_file_replication_options`": [
`n        {
`n            `"option`": `"low_bw_optim`",
`n            `"value`": `"enabled`"
`n        }
`n    ]
`n}"
                                      
$response3 = Invoke-RestMethod "https://$($ip):3009/rest/v1.0/dd-systems/$($systemid)/protocols/ddboost" -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
$response3 | ConvertTo-Json
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Successfully enabled ddve ddboost" 
#"Success" | Out-File -FilePath $filepath
}
catch{

$StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
    $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}


#Enable authorization policy security-officer

try
{
$Command = "user password aging set $username max-days-between-change 99999"
$Command1= "authorization policy set security-officer enabled"
$secpasswd = ConvertTo-SecureString $secofficer1_Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential($secofficer1_Name, $secpasswd)
$sessionID = New-SSHSession -ComputerName $ip -Credential $Credentials -Force   #Connect Over SSH
Invoke-SSHCommand -Index $sessionID.sessionid -Command $Command   # Invoke Command Over SSH
sleep -s 2
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Sucessfully enabled ddve user password aging" 
Invoke-SSHCommand -Index $sessionID.sessionid -Command $Command1
Sleep -s 2
Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[INFO] Sucessfully enabled ddve enable ddve authroization policy" 
"Success" | Out-File -FilePath $filepath
}
catch{

    $StatusCode = $_.Exception.Response.StatusCode
    $ErrorMessage = $_.ErrorDetails.Message
    Write-Error "$([int]$StatusCode) $($StatusCode) -$($ErrorMessage)"
     $exception = $_.Exception.Message
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] $exception"
    Write-Log "E:\Workspace\UIAutomation\Log Files\DDVElog.txt" "[ERROR] Failed to enable ddve authroization policy and user password aging"
    "Failed" | Out-File -FilePath $filepath
    sleep -s 30
    Remove-Item -Path $filepath -Confirm:$false -Force
    exit 1
}
sleep -s 30
Remove-Item -Path $filepath -Confirm:$false -Force






