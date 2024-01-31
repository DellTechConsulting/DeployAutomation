param($FormInput)
#Write-Host $FormInput
##################################################
$myJson = $FormInput | ConvertFrom-Json
$vCenterServer = $myJson.vcenterdetails.vCenter
$username = $myJson.vcenterdetails.username
$password = $myJson.vcenterdetails.password
$ErrorActionPreference = 'Stop'
$SecurePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$LoginCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePassword
if ($LoginCredentials) {
  #Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
  Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Confirm:$false
  $MyServer = Connect-VIServer -Server $vCenterServer -Protocol https -Credential $LoginCredentials
  if ($MyServer) {
  try{
    #Get Datastore details from Vcenter
    $datastoredetail = Get-Datastore
    $data = $datastoredetail.Name -Join "," | Out-File -FilePath "C:\inetpub\wwwroot\$($myJson.datastoreFile)"
    }
    catch{
    "false" | Out-File -FilePath "C:\inetpub\wwwroot\$($myJson.datastoreFile)"
    }
    try{
    #Get Network details from Vcenter
    $networkdetail = Get-VirtualNetwork
    $netdet = $networkdetail.Name -Join "," | Out-File -FilePath "C:\inetpub\wwwroot\$($myJson.networkFile)"
    }
    catch{
    "false" | Out-File -FilePath "C:\inetpub\wwwroot\$($myJson.networkFile)"
    }
    try{
    #Get Esxi details from Vcenter
    $esxi=Get-VMHost
    $esxidet=$esxi.Name -Join "," | Out-File -FilePath "C:\inetpub\wwwroot\$($myJson.esxiFile)"
    }
    catch
    {
    "false" | Out-File -FilePath "C:\inetpub\wwwroot\$($myJson.esxiFile)"
    }
    try{
    #Get Cluster details from Vcenter
    $clusterdetail = Get-Cluster
    $clusterdet = $clusterdetail.Name -Join "," | Out-File -FilePath "C:\inetpub\wwwroot\$($myJson.clusterFile)"
    }
    catch{
    "false" | Out-File -FilePath "C:\inetpub\wwwroot\$($myJson.clusterFile)"
    }
}
}