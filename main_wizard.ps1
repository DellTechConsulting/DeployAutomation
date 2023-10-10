param([String]$TestInput1, [String]$TestInput2)
Write-Host "Running..."

$FormInputArray = $TestInput2 -split "__"

function Get-CR-Install-Json($FormInput) {	
    $jsonBase = @{}    
    $deploymentType = ($FormInput[0] -split "=")[1]
    $jsonBase.Add("deploymentType", $deploymentType) 
    
    if ($deploymentType -like 'vCenter') {
        $vCenter = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $vcenterdata = @([pscustomobject]@{"vCenter" = $vCenter 
                "username"                           = $username
                "password"                           = $password                                   
            })
        $jsonBase.Add("vcenterdata", $vcenterdata)   

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $hostType = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $hostValue = ($FormInput[7] -split "=")[1].replace("%20", " ")

        $hostData = @([pscustomobject]@{"type" = $hostType
                "value"                        = $hostValue
            })
            
            
        $fqdn = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $ip_cr = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $netmask = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $DNS = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $NTP = ($FormInput[16] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[17] -split "=")[1].replace("%20", " ")
        $lockboxpassword = ($FormInput[18] -split "=")[1].replace("%20", " ")
        $MongoDbpassword = ($FormInput[19] -split "=")[1].replace("%20", " ")
	
        $crsopassword = ($FormInput[20] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[21] -split "=")[1].replace("%20", " ")

        $crdata = @([pscustomobject]@{"VMName" = $VMName 
                "ovaPath"                      = $ovaPath
                "hostData"                     = $hostData
                "fqdn"                         = $fqdn 
                "DiskStorageFormat"            = $DiskStorageFormat
                "Network"                      = $Network
                "ip_cr"                        = $ip_cr
                "netmask"                      = $netmask 
                "gateway"                      = $gateway
                "Datastore"                    = $Datastore
                "DNS"                          = $DNS
                "NTP"                          = $NTP 
                "timezone"                     = $timezone
                "lockboxpassword"              = $lockboxpassword
                "MongoDbpassword"              = $MongoDbpassword
                "crsopassword"                 = $crsopassword
                "result_generate"              = $result_generate                              
            })
            
        $jsonBase.Add("crdata", $crdata)
    }
    else {
        $esxiHost = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $esxidata = @([pscustomobject]@{"esxiServer" = $esxiHost
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("esxidata", $esxidata) 

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ") 
        $fqdn = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[7] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $ip_cr = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $netmask = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $DNS = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $NTP = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $lockboxpassword = ($FormInput[16] -split "=")[1].replace("%20", " ")
        $MongoDbpassword = ($FormInput[17] -split "=")[1].replace("%20", " ")
        $crsopassword = ($FormInput[18] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[19] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
        $crdata = @([pscustomobject]@{"VMName" = $VMName
                "ovaPath"                      = $ovaPath 
                "fqdn"                         = $fqdn
                "DiskStorageFormat"            = $DiskStorageFormat
                "Network"                      = $Network
                "ip_cr"                        = $ip_cr
                "netmask"                      = $netmask
                "gateway"                      = $gateway
                "Datastore"                    = $Datastore
                "DNS"                          = $DNS
                "NTP"                          = $NTP 
                "timezone"                     = $timezone
                "lockboxpassword"              = $lockboxpassword
                "MongoDbpassword"              = $MongoDbpassword
                "crsopassword"                 = $crsopassword                                
            })

        $jsonBase.Add("crdata", $crdata)
    }
    return ($jsonBase | ConvertTo-Json -Depth 10)
}

function Get-CS-Install-Json ($FormInput) {
    $jsonBase = @{}
    $deploymentType = ($FormInput[0] -split "=")[1]
    $jsonBase.Add("deploymentType", $deploymentType) 
    
    if ($deploymentType -like 'vCenter') {
        $vCenter = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $vcenterdata = @([pscustomobject]@{"vCenter" = $vCenter 
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("vcenterdata", $vcenterdata)

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $hostType = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $hostValue = ($FormInput[7] -split "=")[1].replace("%20", " ")

        $hostData = @([pscustomobject]@{"type" = $hostType
                "value"                        = $hostValue
            })
            
        $fqdn = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $Network0 = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $Network1 = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $Network2 = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $Network3 = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $netmask0 = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $DNS = ($FormInput[16] -split "=")[1].replace("%20", " ")
        $NTP = ($FormInput[17] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[18] -split "=")[1].replace("%20", " ")
        $DeploymentOption = ($FormInput[19] -split "=")[1].replace("%20", " ")
        $ip_cs = ($FormInput[20] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[21] -split "=")[1].replace("%20", " ")
        $defaultadminpass = ($FormInput[22] -split "=")[1].replace("%20", " ")
        $newadminpass = ($FormInput[23] -split "=")[1].replace("%20", " ")
	$result_generate = ($FormInput[24] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate

        $csdata = @([pscustomobject]@{"VMName" = $VMName 
                "ovaPath"                      = $ovaPath
                "hostData"                     = $hostData
                "fqdn"                         = $fqdn
                "DiskStorageFormat"            = $DiskStorageFormat
                "Network0"                     = $Network0
                "Network1"                     = $Network1
                "Network2"                     = $Network2
                "Network3"                     = $Network3
                "netmask0"                     = $netmask0 
                "gateway"                      = $gateway
                "DNS"                          = $DNS
                "NTP"                          = $NTP
                "Datastore"                    = $Datastore
                "DeploymentOption"             = $DeploymentOption
                "ip_cs"                        = $ip_cs
                "timezone"                     = $timezone
                "defaultadminpass"             = $defaultadminpass
                "newadminpass"                 = $newadminpass                                
            })
        $jsonBase.Add("csdata", $csdata)
    }
    else {
        $esxiHost = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $esxidata = @([pscustomobject]@{"esxiServer" = $esxiHost
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("esxidata", $esxidata) 

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $fqdn = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[7] -split "=")[1].replace("%20", " ")
        $Network0 = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $Network1 = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $Network2 = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $Network3 = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $netmask0 = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $DNS = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $NTP = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[16] -split "=")[1].replace("%20", " ")
        $DeploymentOption = ($FormInput[17] -split "=")[1].replace("%20", " ")
        $ip_cs = ($FormInput[18] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[19] -split "=")[1].replace("%20", " ")
        $defaultadminpass = ($FormInput[20] -split "=")[1].replace("%20", " ")
        $newadminpass = ($FormInput[21] -split "=")[1].replace("%20", " ")
	
        $result_generate = ($FormInput[22] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate

        $csdata = @([pscustomobject]@{"VMName" = $VMName 
                "ovaPath"                      = $ovaPath
                "fqdn"                         = $fqdn
                "DiskStorageFormat"            = $DiskStorageFormat
                "Network0"                     = $Network0
                "Network1"                     = $Network1
                "Network2"                     = $Network2
                "Network3"                     = $Network3
                "netmask0"                     = $netmask0 
                "gateway"                      = $gateway
                "DNS"                          = $DNS
                "NTP"                          = $NTP
                "Datastore"                    = $Datastore
                "DeploymentOption"             = $DeploymentOption
                "ip_cs"                        = $ip_cs
                "timezone"                     = $timezone
                "defaultadminpass"             = $defaultadminpass
                "newadminpass"                 = $newadminpass                                
            })

        $jsonBase.Add("csdata", $csdata)
    }

    return ($jsonBase | ConvertTo-Json -Depth 10)
}

function Get-CS-Integrate-Json ($FormInput) {
    $jsonBase = @{}

    $cr_ip = ($FormInput[0] -split "=")[1].replace("%20", " ")
    $cruser = ($FormInput[1] -split "=")[1].replace("%20", " ")
    $crpassword = ($FormInput[2] -split "=")[1].replace("%20", " ")
    $nickName = ($FormInput[3] -split "=")[1].replace("%20", " ")
    $cshostname = ($FormInput[4] -split "=")[1].replace("%20", " ")
    $cshostUsername = ($FormInput[5] -split "=")[1].replace("%20", " ")
    $cshostPassword = ($FormInput[6] -split "=")[1].replace("%20", " ")
    $osType = ($FormInput[7] -split "=")[1].replace("%20", " ")
    $type = ($FormInput[8] -split "=")[1].replace("%20", " ")
    $tags = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[10] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate

    $cs_crdata = @([pscustomobject]@{"cr_ip" = $cr_ip
            "cruser"                         = $cruser 
            "crpassword"                     = $crpassword
            "nickName"                       = $nickName
            "cshostname"                     = $cshostname 
            "cshostUsername"                 = $cshostUsername
            "cshostPassword"                 = $cshostPassword
            "osType"                         = $osType
            "type"                           = $type
            "tags"                           = $tags                                
        })
  
    $jsonBase.Add("cs_crdata", $cs_crdata)
    return ($jsonBase | ConvertTo-Json -Depth 10)
}

function Get-AVE-Install-Json ($FormInput) {
    $jsonBase = @{}

    $deploymentType = ($FormInput[0] -split "=")[1]
    $jsonBase.Add("deploymentType", $deploymentType) 
    
    if ($deploymentType -like 'vCenter') {
        $vCenter = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $vcenterdata = @([pscustomobject]@{"vCenter" = $vCenter 
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("vcenterdata", $vcenterdata)

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $hostType = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $hostValue = ($FormInput[7] -split "=")[1].replace("%20", " ")

        $hostData = @([pscustomobject]@{"type" = $hostType
                "value"                        = $hostValue
            })
            
        $fqdn = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $ip_prefix = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $ipv4 = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $primary_nameserver = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $ntpserver = ($FormInput[16] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[17] -split "=")[1].replace("%20", " ")
        $defaultrootpass = ($FormInput[18] -split "=")[1].replace("%20", " ")        
        $use_common_password = ($FormInput[19] -split "=")[1].replace("%20", " ")
        $common_password = ($FormInput[20] -split "=")[1].replace("%20", " ")
        $repl_password = ($FormInput[21] -split "=")[1].replace("%20", " ")
        $mcpass = ($FormInput[22] -split "=")[1].replace("%20", " ")
        $viewuserpass = ($FormInput[23] -split "=")[1].replace("%20", " ")
        $admin_password_os = ($FormInput[24] -split "=")[1].replace("%20", " ")
        $root_password_os = ($FormInput[25] -split "=")[1].replace("%20", " ")
        $keystore_passphrase = ($FormInput[26] -split "=")[1].replace("%20", " ")
        $avamar_rootpass = ($FormInput[27] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[28] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
        $avedata = @([pscustomobject]@{"VMName" = $VMName
                "ovaPath"                       = $ovaPath
                "hostData"                      = $hostData
                "fqdn"                          = $fqdn
                "DiskStorageFormat"             = $DiskStorageFormat
                "Network"                       = $Network
                "ip_prefix"                     = $ip_prefix
                "ipv4"                          = $ipv4
                "Datastore"                     = $Datastore
                "gateway"                       = $gateway
                "primary_nameserver"            = $primary_nameserver 
                "ntpserver"                     = $ntpserver
                "timezone"                      = $timezone
                "defaultrootpass"               = $defaultrootpass               
                "use_common_password"           = $use_common_password
                "common_password"               = $common_password
                "repl_password"                 = $repl_password
                "mcpass"                        = $mcpass
                "viewuserpass"                  = $viewuserpass
                "admin_password_os"             = $admin_password_os
                "root_password_os"              = $root_password_os
                "keystore_passphrase"           = $keystore_passphrase
                "avamar_rootpass"               = $avamar_rootpass
            })

        $jsonBase.Add("avedata", $avedata)
    }
    else {
        $esxiHost = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $esxidata = @([pscustomobject]@{"esxiServer" = $esxiHost
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("esxidata", $esxidata) 

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $fqdn = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[7] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $ip_prefix = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $ipv4 = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $primary_nameserver = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $ntpserver = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $defaultrootpass = ($FormInput[16] -split "=")[1].replace("%20", " ")       
        $use_common_password = ($FormInput[17] -split "=")[1].replace("%20", " ")
        $common_password = ($FormInput[18] -split "=")[1].replace("%20", " ")
        $repl_password = ($FormInput[19] -split "=")[1].replace("%20", " ")
        $mcpass = ($FormInput[20] -split "=")[1].replace("%20", " ")
        $viewuserpass = ($FormInput[21] -split "=")[1].replace("%20", " ")
        $admin_password_os = ($FormInput[22] -split "=")[1].replace("%20", " ")
        $root_password_os = ($FormInput[23] -split "=")[1].replace("%20", " ")
        $keystore_passphrase = ($FormInput[24] -split "=")[1].replace("%20", " ")
        $avamar_rootpass = ($FormInput[25] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[26] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
        $avedata = @([pscustomobject]@{"VMName" = $VMName
                "ovaPath"                       = $ovaPath
                "fqdn"                          = $fqdn
                "DiskStorageFormat"             = $DiskStorageFormat
                "Network"                       = $Network
                "ip_prefix"                     = $ip_prefix
                "ipv4"                          = $ipv4
                "Datastore"                     = $Datastore
                "gateway"                       = $gateway
                "primary_nameserver"            = $primary_nameserver 
                "ntpserver"                     = $ntpserver
                "timezone"                      = $timezone
                "defaultrootpass"               = $defaultrootpass                
                "use_common_password"           = $use_common_password
                "common_password"               = $common_password
                "repl_password"                 = $repl_password
                "mcpass"                        = $mcpass
                "viewuserpass"                  = $viewuserpass
                "admin_password_os"             = $admin_password_os
                "root_password_os"              = $root_password_os
                "keystore_passphrase"           = $keystore_passphrase
                "avamar_rootpass"               = $avamar_rootpass
            })

        $jsonBase.Add("avedata", $avedata)

    }
    
    return ($jsonBase | ConvertTo-Json -Depth 10)
}

function Get-AVE-Integrate-Json ($FormInput) {
    $jsonBase = @{}

    $cr_ip = ($FormInput[0] -split "=")[1].replace("%20", " ")
    $cruser = ($FormInput[1] -split "=")[1].replace("%20", " ")
    $crpassword = ($FormInput[2] -split "=")[1].replace("%20", " ")
    $nickName = ($FormInput[3] -split "=")[1].replace("%20", " ")
    $avehostname = ($FormInput[4] -split "=")[1].replace("%20", " ")
    $avehostUsername = ($FormInput[5] -split "=")[1].replace("%20", " ")
    $avehostPassword = ($FormInput[6] -split "=")[1].replace("%20", " ")
    $osType = ($FormInput[7] -split "=")[1].replace("%20", " ")
    $type = ($FormInput[8] -split "=")[1].replace("%20", " ")
    $tags = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[10] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
    $ave_crdata = @([pscustomobject]@{"cr_ip" = $cr_ip
            "cruser"                          = $cruser
            "crpassword"                      = $crpassword
            "nickName"                        = $nickName
            "avehostname"                     = $avehostname
            "avehostUsername"                 = $avehostUsername
            "avehostPassword"                 = $avehostPassword
            "osType"                          = $osType
            "type"                            = $type
            "tags"                            = $tags                             
        })

    $jsonBase.Add("ave_crdata", $ave_crdata)

    return ($jsonBase | ConvertTo-Json -Depth 10)
}

function Get-DDVE-Install-Json ($FormInput) {
    $jsonBase = @{}

    $ddip = ($FormInput[0] -split "=")[1].replace("%20", " ")
    $cred_username = ($FormInput[1] -split "=")[1].replace("%20", " ")
    $cred_password = ($FormInput[2] -split "=")[1].replace("%20", " ")
    $cr_name = ($FormInput[3] -split "=")[1].replace("%20", " ")
    $cr_role = ($FormInput[4] -split "=")[1].replace("%20", " ")
    $cr_password = ($FormInput[5] -split "=")[1].replace("%20", " ")
    $sec1_name = ($FormInput[6] -split "=")[1].replace("%20", " ")
    $sec1_role = ($FormInput[7] -split "=")[1].replace("%20", " ")
    $sec1_password = ($FormInput[8] -split "=")[1].replace("%20", " ")
    $sec2_name = ($FormInput[9] -split "=")[1].replace("%20", " ")
    $sec2_role = ($FormInput[10] -split "=")[1].replace("%20", " ")
    $sec2_password = ($FormInput[11] -split "=")[1].replace("%20", " ")
    $new_pphrase = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[13] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
    $ipaddressObj = @{"ddip" = $ddip }
    $jsonBase.Add("ipaddress", $ipaddressObj)

    $credentialsObj = @{"username" = $cred_username 
        "password"                 = $cred_password 
    }
    $jsonBase.Add("credentials", $credentialsObj)

    $cradminuserObj = @{
        "name"     = $cr_name
        "role"     = $cr_role
        "password" = $cr_password 
    }    
    $jsonBase.Add("cradminuser", $cradminuserObj)

    $secofficer1Obj = @{
        "name"     = $sec1_name
        "role"     = $sec1_role
        "password" = $sec1_password
    }    
    $jsonBase.Add("secofficer1", $secofficer1Obj)

    $secofficer2Obj = @{
        "name"     = $sec2_name 
        "role"     = $sec2_role 
        "password" = $sec2_password
    }    
    $jsonBase.Add("secofficer2", $secofficer2Obj)
    
    $pphrase_requestObj = @{"new_pphrase" = $new_pphrase }

    $systempphraseObj = @{"pphrase_request" = $pphrase_requestObj }

    $jsonBase.Add("systempphrase", $systempphraseObj)

    return ($jsonBase | ConvertTo-Json -Depth 10)
}

function Get-DDVE-Integrate-Json ($FormInput) {
    $jsonBase = @{}

    $cr_ip = ($FormInput[0] -split "=")[1].replace("%20", " ")
    $cruser = ($FormInput[1] -split "=")[1].replace("%20", " ")
    $crpassword = ($FormInput[2] -split "=")[1].replace("%20", " ")
    $storagename = ($FormInput[3] -split "=")[1].replace("%20", " ")
    $ddhostname = ($FormInput[4] -split "=")[1].replace("%20", " ")
    $ddhostUsername = ($FormInput[5] -split "=")[1].replace("%20", " ")
    $ddhostPassword = ($FormInput[6] -split "=")[1].replace("%20", " ")
    $tags = ($FormInput[7] -split "=")[1].replace("%20", " ")

    $dd_crdata = @([pscustomobject]@{"cr_ip" = $cr_ip 
            "cruser"                         = $cruser
            "crpassword"                     = $crpassword 
            "storagename"                    = $storagename
            "ddhostname"                     = $ddhostname 
            "ddhostUsername"                 = $ddhostUsername
            "ddhostPassword"                 = $ddhostPassword
            "tags"                           = $tags                        
        })
                                  
    $jsonBase.Add("dd_crdata", $dd_crdata)

    return ($jsonBase | ConvertTo-Json -Depth 10)
}


function Get-Networker-Install-Json ($FormInput) {
    $jsonBase = @{}

    $deploymentType = ($FormInput[0] -split "=")[1]
    $jsonBase.Add("deploymentType", $deploymentType) 
    
    if ($deploymentType -like 'vCenter') {
        $vCenter = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $vcenterdata = @([pscustomobject]@{"vCenter" = $vCenter 
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("vcenterdata", $vcenterdata)

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $hostType = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $hostValue = ($FormInput[7] -split "=")[1].replace("%20", " ")

        $hostData = @([pscustomobject]@{"type" = $hostType
                "value"                        = $hostValue
            })

        $fqdn = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $ddip = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $ipv4 = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $dns = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $ntp = ($FormInput[16] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[17] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[18] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate

        $networkerdata = @([pscustomobject]@{"VMName" = $VMName
                "ovaPath"                             = $ovaPath
                "hostData"                            = $hostData
                "fqdn"                                = $fqdn
                "DiskStorageFormat"                   = $DiskStorageFormat
                "Network"                             = $Network
                "ddip"                                = $ddip
                "ipv4"                                = $ipv4
                "Datastore"                           = $Datastore
                "gateway"                             = $gateway
                "dns"                                 = $dns 
                "ntp"                                 = $ntp
                "timezone"                            = $timezone
            })

        $jsonBase.Add("networkerdata", $networkerdata)
    }
    else {
        $esxiHost = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $esxidata = @([pscustomobject]@{"esxiServer" = $esxiHost
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("esxidata", $esxidata) 

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $fqdn = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[7] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $ddip = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $ipv4 = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $dns = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $ntp = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[16] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
        $networkerdata = @([pscustomobject]@{"VMName" = $VMName
                "ovaPath"                             = $ovaPath
                "fqdn"                                = $fqdn
                "DiskStorageFormat"                   = $DiskStorageFormat
                "Network"                             = $Network
                "ddip"                                = $ddip
                "ipv4"                                = $ipv4
                "Datastore"                           = $Datastore
                "gateway"                             = $gateway
                "dns"                                 = $dns 
                "ntp"                                 = $ntp
                "timezone"                            = $timezone
            })

        $jsonBase.Add("networkerdata", $networkerdata)

    }
    
    return ($jsonBase | ConvertTo-Json -Depth 10)
}

function Get-Proxy-Install-Json ($FormInput) {
    $jsonBase = @{}

    $deploymentType = ($FormInput[0] -split "=")[1]
    $jsonBase.Add("deploymentType", $deploymentType) 
    
    if ($deploymentType -like 'vCenter') {
        $vCenter = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $vcenterdata = @([pscustomobject]@{"vCenter" = $vCenter 
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("vcenterdata", $vcenterdata)

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $hostType = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $hostValue = ($FormInput[7] -split "=")[1].replace("%20", " ")

        $hostData = @([pscustomobject]@{"type" = $hostType
                "value"                        = $hostValue
            })

        $fqdn = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $netmask = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $ipv4 = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $ntp = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[16] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate

        $proxydata = @([pscustomobject]@{"VMName" = $VMName
                "ovaPath"                         = $ovaPath
                "hostData"                        = $hostData
                "fqdn"                            = $fqdn
                "DiskStorageFormat"               = $DiskStorageFormat
                "Network"                         = $Network
                "netmask"                         = $netmask
                "ipv4"                            = $ipv4
                "Datastore"                       = $Datastore
                "gateway"                         = $gateway
                "ntp"                             = $ntp
            })

        $jsonBase.Add("proxydata", $proxydata)
    }
    else {
        $esxiHost = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $esxidata = @([pscustomobject]@{"esxiServer" = $esxiHost
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("esxidata", $esxidata) 

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $fqdn = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[7] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $netmask = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $ipv4 = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $ntp = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[14] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
        $proxydata = @([pscustomobject]@{"VMName" = $VMName
                "ovaPath"                         = $ovaPath
                "fqdn"                            = $fqdn
                "DiskStorageFormat"               = $DiskStorageFormat
                "Network"                         = $Network
                "netmask"                         = $netmask
                "ipv4"                            = $ipv4
                "Datastore"                       = $Datastore
                "gateway"                         = $gateway
                "ntp"                             = $ntp
            })

        $jsonBase.Add("proxydata", $proxydata)

    }
    
    return ($jsonBase | ConvertTo-Json -Depth 10)
}

function Get-PPDM-Install-Json  ($FormInput) {
    $jsonBase = @{}

    $deploymentType = ($FormInput[0] -split "=")[1]
    $jsonBase.Add("deploymentType", $deploymentType) 
    
    if ($deploymentType -like 'vCenter') {
        $vCenter = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $vcenterdata = @([pscustomobject]@{"vCenter" = $vCenter 
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("vcenterdata", $vcenterdata)

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $hostType = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $hostValue = ($FormInput[7] -split "=")[1].replace("%20", " ")

        $hostData = @([pscustomobject]@{"type" = $hostType
                "value"                        = $hostValue
            })

        $fqdn = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $netmask = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $ipv4 = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $dns = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $ntp = ($FormInput[16] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[17] -split "=")[1].replace("%20", " ")
        $applicationUserPassword = ($FormInput[18] -split "=")[1].replace("%20", " ")
        $defaultLockboxpassphrase = ($FormInput[19] -split "=")[1].replace("%20", " ")
        $newLockboxpassphrase = ($FormInput[20] -split "=")[1].replace("%20", " ")
        $defaultRootpassword = ($FormInput[21] -split "=")[1].replace("%20", " ")
        $newRootPassword = ($FormInput[22] -split "=")[1].replace("%20", " ")
        $defaultAdminpassword = ($FormInput[23] -split "=")[1].replace("%20", " ")
        $newAdminPassword = ($FormInput[24] -split "=")[1].replace("%20", " ")

        $result_generate = ($FormInput[25] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
        $ppdmdata = @([pscustomobject]@{"VMName" = $VMName
                "ovaPath"                        = $ovaPath
                "hostData"                       = $hostData
                "fqdn"                           = $fqdn
                "DiskStorageFormat"              = $DiskStorageFormat
                "Network"                        = $Network
                "netmask"                        = $netmask
                "ipv4"                           = $ipv4
                "Datastore"                      = $Datastore
                "gateway"                        = $gateway
                "dns"                            = $dns
                "ntp"                            = $ntp
                "timezone"                       = $timezone
                "applicationUserPassword"        = $applicationUserPassword
                "defaultLockboxpassphrase"       = $defaultLockboxpassphrase
                "newLockboxpassphrase"           = $newLockboxpassphrase
                "defaultRootpassword"            = $defaultRootpassword
                "newRootPassword"                = $newRootPassword
                "defaultAdminpassword"           = $defaultAdminpassword
                "newAdminPassword"               = $newAdminPassword
            })

        $jsonBase.Add("ppdmdata", $ppdmdata)
    }
    else {
        $esxiHost = ($FormInput[1] -split "=")[1].replace("%20", " ")
        $username = ($FormInput[2] -split "=")[1].replace("%20", " ")
        $password = ($FormInput[3] -split "=")[1].replace("%20", " ")

        $esxidata = @([pscustomobject]@{"esxiServer" = $esxiHost
                "username"                           = $username
                "password"                           = $password
            })
        $jsonBase.Add("esxidata", $esxidata) 

        $VMName = ($FormInput[4] -split "=")[1].replace("%20", " ")
        $ovaPath = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $fqdn = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $DiskStorageFormat = ($FormInput[7] -split "=")[1].replace("%20", " ")
        $Network = ($FormInput[8] -split "=")[1].replace("%20", " ")
        $netmask = ($FormInput[9] -split "=")[1].replace("%20", " ")
        $ipv4 = ($FormInput[10] -split "=")[1].replace("%20", " ")
        $Datastore = ($FormInput[11] -split "=")[1].replace("%20", " ")
        $gateway = ($FormInput[12] -split "=")[1].replace("%20", " ")
        $dns = ($FormInput[13] -split "=")[1].replace("%20", " ")
        $ntp = ($FormInput[14] -split "=")[1].replace("%20", " ")
        $timezone = ($FormInput[15] -split "=")[1].replace("%20", " ")
        $applicationUserPassword = ($FormInput[16] -split "=")[1].replace("%20", " ")
        $defaultLockboxpassphrase = ($FormInput[17] -split "=")[1].replace("%20", " ")
        $newLockboxpassphrase = ($FormInput[18] -split "=")[1].replace("%20", " ")
        $defaultRootpassword = ($FormInput[19] -split "=")[1].replace("%20", " ")
        $newRootPassword = ($FormInput[20] -split "=")[1].replace("%20", " ")
        $defaultAdminpassword = ($FormInput[21] -split "=")[1].replace("%20", " ")
        $newAdminPassword = ($FormInput[22] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[23] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
        $ppdmdata = @([pscustomobject]@{"VMName" = $VMName
                "ovaPath"                        = $ovaPath
                "fqdn"                           = $fqdn
                "DiskStorageFormat"              = $DiskStorageFormat
                "Network"                        = $Network
                "netmask"                        = $netmask
                "ipv4"                           = $ipv4
                "Datastore"                      = $Datastore
                "gateway"                        = $gateway
                "dns"                            = $dns
                "ntp"                            = $ntp
                "timezone"                       = $timezone
                "applicationUserPassword"        = $applicationUserPassword
                "defaultLockboxpassphrase"       = $defaultLockboxpassphrase
                "newLockboxpassphrase"           = $newLockboxpassphrase
                "defaultRootpassword"            = $defaultRootpassword
                "newRootPassword"                = $newRootPassword
                "defaultAdminpassword"           = $defaultAdminpassword
                "newAdminPassword"               = $newAdminPassword
            })

        $jsonBase.Add("ppdmdata", $ppdmdata)

    }
    
    return ($jsonBase | ConvertTo-Json -Depth 10)
}


function Get-NTP-Install-Json ($FormInput) {
    $jsonBase = @{}

    $server = ($FormInput[0] -split "=")[1].replace("%20", " ")
    $username = ($FormInput[1] -split "=")[1].replace("%20", " ")
    $password = ($FormInput[2] -split "=")[1].replace("%20", " ")
    $winVMName = ($FormInput[3] -split "=")[1].replace("%20", " ")
    $winUsername = ($FormInput[4] -split "=")[1].replace("%20", " ")
    $winPassword = ($FormInput[5] -split "=")[1].replace("%20", " ")
    $ntpName = ($FormInput[6] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[7] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
    $vmwaredata = @([pscustomobject]@{"server" = $server 
            "username"                         = $username
            "password"                         = $password             
        })

    $ntpdata = @([pscustomobject]@{"VMName" = $winVMName 
            "username"                      = $winUsername
            "password"                      = $winPassword     
            "NTPName"                       = $ntpName         
        })


                                  
    $jsonBase.Add("vmwaredata", $vmwaredata)
    $jsonBase.Add("ntpdata", $ntpdata)

    return ($jsonBase | ConvertTo-Json -Depth 10)
}

function Get-DNS-Install-Json ($FormInput) {
    $jsonBase = @{}

    $server = ($FormInput[0] -split "=")[1].replace("%20", " ")
    $username = ($FormInput[1] -split "=")[1].replace("%20", " ")
    $password = ($FormInput[2] -split "=")[1].replace("%20", " ")
    $winVMName = ($FormInput[3] -split "=")[1].replace("%20", " ")
    $winUsername = ($FormInput[4] -split "=")[1].replace("%20", " ")
    $winPassword = ($FormInput[5] -split "=")[1].replace("%20", " ")
        $result_generate = ($FormInput[6] -split "=")[1].replace("%20", " ")
	Write-Host "TEST"
	Write-Host $result_generate
    $vmwaredata = @([pscustomobject]@{"server" = $server 
            "username"                         = $username
            "password"                         = $password             
        })

    $dnsdata = @([pscustomobject]@{"VMName" = $winVMName 
            "username"                      = $winUsername
            "password"                      = $winPassword      
        })
                              
    $jsonBase.Add("vmwaredata", $vmwaredata)
    $jsonBase.Add("dnsdata", $dnsdata)

    return ($jsonBase | ConvertTo-Json -Depth 10)
}

switch ($TestInput1) {
    "cr-install" {
        $crInputJson = Get-CR-Install-Json $FormInputArray
        .\powershellScripts\cr_install_wizard.ps1 -FormInput $crInputJson
        Break
    }
    "cs-install" {
        $csInstallInputJson = Get-CS-Install-Json $FormInputArray
        .\powershellScripts\cs_install_wizard.ps1 -FormInput $csInstallInputJson
        Break
    }
    "cs-integrate" {
        $csIntegrateInputJson = Get-CS-Integrate-Json $FormInputArray
        .\powershellScripts\cs_integrate.ps1 -FormInput $csIntegrateInputJson
        Break
    }
    "ave-install" {
        $aveInstallInputJson = Get-AVE-Install-Json $FormInputArray
        .\powershellScripts\ave_install_wizard.ps1 -FormInput $aveInstallInputJson
        Break
    }
    "ave-integrate" {
        $aveIntegrateInputJson = Get-AVE-Integrate-Json $FormInputArray
        .\powershellScripts\ave_integrate.ps1 -FormInput $aveIntegrateInputJson
        Break
    }
    "ddve-install" {
        $ddveInstallInputJson = Get-DDVE-Install-Json $FormInputArray
        .\powershellScripts\ddve_install_wizard.ps1 -FormInput $ddveInstallInputJson
        Break
    }
    "ddve-integrate" {
        $ddveIntegrateInputJson = Get-DDVE-Integrate-Json $FormInputArray
        .\powershellScripts\ddve_integrate.ps1 -FormInput $ddveIntegrateInputJson
        Break
    }
    "networker-install" {
        $networkerInstallInputJson = Get-Networker-Install-Json $FormInputArray
        .\powershellScripts\networker_install_wizard.ps1 -FormInput $networkerInstallInputJson
        Break
    }
    "proxy-install" {
        $proxyInstallInputJson = Get-Proxy-Install-Json $FormInputArray
        .\powershellScripts\proxy_install_wizard.ps1 -FormInput $proxyInstallInputJson
        Break
    }
    "ppdm-install" {
        $ppdmInstallInputJson = Get-PPDM-Install-Json $FormInputArray
        .\powershellScripts\ppdm_install_wizard.ps1 -FormInput $ppdmInstallInputJson
        Break
    }
    "ntp-install" {
        $ntpInstallInputJson = Get-NTP-Install-Json $FormInputArray
        .\powershellScripts\ntp_install_wizard.ps1 -FormInput $ntpInstallInputJson
        Break
    }
    "dns-install" {
        $dnsInstallInputJson = Get-DNS-Install-Json $FormInputArray
        .\powershellScripts\dns_install_wizard.ps1 -FormInput $dnsInstallInputJson
        Break
    }
    Default {
        Write-Host "No matching scripts found!"
        Break
    }
}