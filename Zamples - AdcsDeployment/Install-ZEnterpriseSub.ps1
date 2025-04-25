<#PSScriptInfo

.VERSION 0.3.1.0

.GUID f392ef1a-42c2-4dd5-abd4-72746245d492

.AUTHOR Anders Runesson

.COMPANYNAME 

.COPYRIGHT (c) ZampleWorks

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#> 

#Requires -Module ZPki












<# 

.DESCRIPTION 
 Install script for ADCS 


.SYNOPSIS
This script uses the ZPki module to install and configure an Enterprise subordinate CA.

.DESCRIPTION
This script shows you how to install a subordinate AD-integrated CA.
This is an 'extra everything' script. It will (try to) register DNS
records for a HTTP CDP, install a web site on the local machine to
host CDP/AIA and generate the web site contents.

Procedure
1. Check access - you must have local admin and Enterprise Admin permissions
2. Install AD and DNS tools
This script will try to publish the Root CA certificate in AD
before configuring the local CA service. 

Prerequisites:
1. You must already have installed a root CA
2. You need the root CA certificate and CRL file available.

#>

[CmdletBinding()]
Param()

$ErrorActionPreference = "Stop"

#Requires -RunAsAdministrator
#Requires -Version 4

Import-Module ZPki 

# FQDN for AIA & CDP Web site 
$HttpFqdn = "pki.zampleworks.com"

$CaCommonName = "ZampleWorks PKI v1 Issuing CA 1"

$AdcsRootDir = "C:\ADCS"
$DbDir = "C:\ADCS\Db"
$DbLogDir = "C:\ADCS\DbLog"
$WebrootDir = "C:\ADCS\Web"
$RepoDir = "C:\ADCS\Web\Repository"

<###########################################################################
 #   Required section - install ADDS tools for AD info lookup
 #   AD tools are used for lookup of domain/forest names, and check Enterprise Admin rights.
 #   DNS tools are used to register DNS record for HTTP AIA/CDP (OPTIONAL)
 ###########################################################################>

Write-Progress -Activity "Installing ADDS tools and DNS Server tools.."

Install-WindowsFeature RSAT-DNS-Server | Out-Null

Write-Progress -Activity "Gathering AD Forest info"

$AdForestDns = Get-ZPkiAdForest | Select-Object -ExpandProperty RootDomain
$AdDomainDn = Get-ZPkiAdDomain | Select -ExpandProperty DistinguishedName
$CaDnSuffix = $AdDomainDn

$RootDomain = Get-ZPkiAdDomain -Domain $AdForestDns
$RootDomainSid = $RootDomain.domainsid
$RootDomainNbName = $RootDomain.NetBIOSName

$CurrentUserUpn = whoami /upn
$EaGroupObject = Find-ZPkiAdObject -SearchBase $RootDomain.distinguishedName -LdapFilter "(objectSid=$RootDomainSid-519)" -Properties member
$CurrentUserObject = Find-ZPkiAdObject -SearchBase $RootDomain.distinguishedName -LdapFilter "(userPrincipalName=$CurrentUserUpn)"
$EaMembers = $EaGroupObject.member
$CurrentUserDn = $CurrentUserObject.distinguishedName

$IsEnterpriseAdmin = $EaMembers -contains $CurrentUserDn

If(-Not $IsEnterpriseAdmin) {
    Write-Error "You must be a member of $EaGroup to install an Enterprise Root CA."
}

<###########################################################################
 #   Required section - install CA certificate for our directly superior CA.
 #   We expect a superior CA certificate file in the current directory which will be published to ADDS. Check for the file and
 #   verify that it is a valid CA cert. Also try to find a CRL file to publish.
 ###########################################################################>

$SigningCaCertFile = Get-childItem | Where-Object { $_.Name -match ".*\.(crt|cer)$" -and $_.Name -notlike "*.pem.*" } | Select-Object -ExpandProperty FullName

While(($SigningCaCertFile | Measure-Object | Select-Object -ExpandProperty Count) -ne 1) {
    Write-Warning "Please copy the signing CA certificate file to the current directory: $(Get-Location)"
    Read-Host "Press play on tape"
    $SigningCaCertFile = Get-childItem | Where-Object { $_.Name -match ".*\.(crt|cer)$" -and $_.Name -notlike "*.pem.*" } | Select-Object -ExpandProperty FullName
}

$SigningCaCertFile = $SigningCaCertFile | Select-Object -First 1

$SigningCaCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $SigningCaCertFile

Write-Verbose "Found cert for signing CA $($SigningCaCert.Subject)"

$SigningCaCrlFile = Get-childItem | Where-Object { $_ -match ".*\.crl$" } | Select-Object -expand FullName
While(($SigningCaCrlFile | Measure-Object | Select-Object -ExpandProperty Count) -ne 1) {
    Write-Warning "Please copy the superior CA CRL file to this directory. It will be published to ADDS stores. Please don't put multiple CRL files in this directory. cwd: [$(Get-Location)]"
    Read-Host "Press play on tape"
    $SigningCaCrlFile = Get-childItem | Where-Object { $_ -match ".*\.crl$" } | Select-Object -expand FullName
}
$SigningCaCrlFile = $SigningCaCrlFile | Select-Object -First 1

$SigningCaCert.Subject -match "CN=([^,]*),?.*" | Out-Null
$SigningCaCn = $Matches[1]

Publish-ZPkiCaDsFile -PublishFile $SigningCaCertFile -CertType RootCA -Verbose

# Publishing CRL in AD is only necessary if you use LDAP CDP. If needed, uncomment the following line.
# Publish-ZPkiCaDsFile -PublishFile $SigningCaCrlFile -CdpContainer $SigningCaCn -CdpObject $SigningCaCn -Verbose

<# 
    OPTIONAL SECTION - Register DNS record in AD DNS
    Check if DNS record for HTTP CDP/AIA exists. If not, try to create it.
#>

Write-Verbose "Checking for DNS record.."

$DnsRec = Resolve-DnsName $HttpFqdn -ErrorAction SilentlyContinue
If($Null -eq $DnsRec) {
    Write-Progress -Activity "Creating DNS record for HTTP"
    Try {
        $RoutableIpv4 = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $Null } | Select-Object -First 1
        # $RoutableIpv6 = Get-NetIPConfiguration | Where-Object { $_.IPv6DefaultGateway -ne $Null } | Select-Object -First 1
        
        Write-Verbose "Adding DNS record for $HttpFqdn.."
        If($RoutableIpv4) {
            Add-DnsServerResourceRecordA -Name "$HttpFqdn." -IPv4Address $RoutableIpv4.IPv4Address.IPAddress -ZoneName $AdForestDns -ComputerName $AdForestDns
        }
    } Catch {
        Write-Warning "DNS registration failed. Will proceed with installation."
        Write-Warning $_.Exception.Message
    }
}

# Website must be installed and configured now so CDP checking works, otherwise installing the signed CA certificate will fail.
Write-Progress -Activity "Installing AIA/CDP web site"
New-ZPkiWebsite -HttpFqdn $HttpFqdn -Verbose

Write-Progress -Activity "Installing CA service"
Install-ZPkiCa -CaType EnterpriseSubordinateCA -CaCommonName $CaCommonName -CaDnSuffix $CaDnSuffix -CpsOid "1.3.6.1.4.1.53997.509.1.1" -CpsUrl "http://$HttpFqdn/Docs/cps.txt" -CaCertValidityPeriodUnits 10 -CryptoProvider "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -IncludeAllIssuancePolicy -Verbose

# Copy CA certs and CRLs to repo directory
Copy-Item *.crt $RepoDir
Copy-Item *.cer $RepoDir
Copy-Item *.crl $RepoDir

$FoundCert = $False
Do {
    Read-Host "Pending CA certificate signing. Copy signed CA certificate file to $RepoDir and hit enter to proceed"
    Get-childItem $RepoDir | Where-Object { $_ -match ".*\.(crt|cer)$" } | ForEach-Object {
        $c = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $_.FullName
        $c.Subject -match "cn\s*=\s*([^,]*),?.*" | Out-Null
        $cn = $Matches[1] 
        If($cn -eq $CaCommonName) {
            $SignedCertFile = $_
            $SignedCert = $c
            $FoundCert = $True
        }
    }
} While(-Not $FoundCert)

If($SignedCertFile.Name -ne "$CaCommonName.crt") {
    $n = "$RepoDir\$CaCommonName.crt"
    Move-Item $SignedCertFile.FullName $n
    $SignedCertFile = Get-Item $n
}

$SignedCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $SignedCertFile

$CertValidates = $False
Do {
    $Chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    $CertValidates = $Chain.Build($SignedCert)
    If(-not $CertValidates) {
        Write-Warning "CA certificate failed validation. Ensure you copied the correct file, and that the revocation service is working and responding."
        Write-Warning "To check status of the revocation service, run 'certutil -verify -urlfetch $($SignedCertFile.FullName)' in a cmd window."
        Read-Host "Press play on tape"
    }
} While (-Not $CertValidates)

Install-ZPkiCaCertificate -CertFile $SignedCertFile.FullName -Verbose

Write-Progress -Activity "Running CA post config"
Set-ZPkiCaPostInstallConfig -CrlPeriod "Days" -CrlPeriodUnits 8 -CrlOverlap "Days" -CrlOverlapUnits 4

Write-Progress -Activity "Updating CA CDP/AIA information"
Set-ZPkiCaUrlConfig -ClearCDPs -ClearAIAs
Set-ZPkiCaUrlConfig -HttpCdpFqdn $HttpFqdn -AddFileCdp
Set-ZPkiCaUrlConfig -HttpAiaFqdn $HttpFqdn

Write-Progress -Activity "Generating content for AIA/CDP Web site"
New-ZPkiRepoIndex -Sourcepath $RepoDir -IndexFile "$WebrootDir\index.html" -CssFiles "style.css"
New-ZPkiRepoCssFile "$WebrootDir\style.css"

# SIG # Begin signature block
# MIIcxwYJKoZIhvcNAQcCoIIcuDCCHLQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUw4psR+5a4MXrXhL9x7ovODqO
# CyOgghcNMIIEBjCCA6ygAwIBAgITMQAAAEuY5/IiSrSMPQAAAAAASzAKBggqhkjO
# PQQDAjBIMQswCQYDVQQGEwJTRTEUMBIGA1UEChMLWmFtcGxlV29ya3MxIzAhBgNV
# BAMTGlphbXBsZVdvcmtzIEludGVybmFsIENBIHYzMB4XDTI1MDQwMjA3MTYyMloX
# DTI2MDQwMjA3MjYyMlowGjEYMBYGA1UEAxMPQW5kZXJzIFJ1bmVzc29uMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA07FDxLoNRqA9Gq/8qCU9/V9odNF9
# yZ1sBgL5r4fZiOON5ZdaUgeq2+o9s8dCiKHkdU0LvcOp7cuO3XLRn+jseFlSYGY9
# W6CFivpRuewuT1+228A/4CfqmW657I9qi78KRYDLJzE8IQxCnz5Mvw9sug/vnvCM
# 020VnUuyRzzsSrmbZvgsAspLTMHAbkFlmSTLEnnVAfBpOU45OUcwic0BR785q/UE
# eLiS/HRtniIpNBtJLa06OcDGHl59AXGr3mwZ6WDXQQHr+sjZuv/CNNYp3VbswRu9
# vTrfLhpJIiPylAmJnrDv+uQc9nBImtw8JgS6H2IUhv+xifqli1sqXgUyTwIDAQAB
# o4IB1jCCAdIwPgYJKwYBBAGCNxUHBDEwLwYnKwYBBAGCNxUIhb31ToL5uhOGvZce
# h8eaKYeL30SBZIb4qhWEotFXAgFlAgEHMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4G
# A1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1Ud
# DgQWBBTCMPG7tk9kcuLk2dlyo16zyReIRjAfBgNVHSMEGDAWgBTcnJy/9vjUCSFq
# nt0GjbrUATwUNjBiBggrBgEFBQcBAQRWMFQwUgYIKwYBBQUHMAKGRmh0dHA6Ly9w
# a2kub3Auendrcy54eXovUmVwb3NpdG9yeS9aYW1wbGVXb3JrcyUyMEludGVybmFs
# JTIwQ0ElMjB2My5jcnQwWwYDVR0RBFQwUqAvBgorBgEEAYI3FAIDoCEMH0FuZGVy
# cy5SdW5lc3NvbkB6YW1wbGV3b3Jrcy5jb22BH2FuZGVycy5ydW5lc3NvbkB6YW1w
# bGV3b3Jrcy5jb20wTQYJKwYBBAGCNxkCBEAwPqA8BgorBgEEAYI3GQIBoC4ELFMt
# MS01LTIxLTE2OTAwNzU1NC01NjE1NTU1ODMtMzQ2NTg3MDA2NS0xNTE2MAoGCCqG
# SM49BAMCA0gAMEUCIQCEZC5kwpZtziZ3XHMndteFmdJlx9zevImWk1ca8yhnGgIg
# fvJqgybzTMlD/5Uq0j1lwycxc0mEZyNpr3QAFX2jhCYwggWNMIIEdaADAgECAhAO
# mxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# JDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEw
# MDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMT
# GERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprN
# rnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVy
# r2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4
# IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13j
# rclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4Q
# kXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQn
# vKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu
# 5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/
# 8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQp
# JYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFf
# xCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGj
# ggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/
# 57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8B
# Af8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6
# oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEB
# AHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0a
# FPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNE
# m0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZq
# aVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCs
# WKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9Fc
# rBjDTZ9ztwGpn1eqXijiuZQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5b
# MA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5
# NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPB
# PXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/
# nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLc
# Z47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mf
# XazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3N
# Ng1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yem
# j052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g
# 3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD
# 4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDS
# LFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwM
# O1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU
# 7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0j
# BBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8E
# PDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# DQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPO
# vxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQ
# TGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWae
# LJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPBy
# oyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfB
# wWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8l
# Y5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/
# O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbb
# bxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3
# OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBl
# dkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt
# 1nz8MIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkqhkiG9w0BAQsF
# ADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVowQjELMAkGA1UE
# BhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdpQ2VydCBUaW1l
# c3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5qc5/2
# lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L660x5XltSVhh
# K64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLuslxdr9Qq82aKcp
# A9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7avVnpUVmPvkxT
# 8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl7/r419CvEYVI
# rH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+NBikDO0mlUh90
# 2wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVkiqLq+ISTdEjJK
# GjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5n10jxmGpxoMc
# 6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h6gYldp4FCMgr
# XdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNeREXAu2xUDEW8
# aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLqfY/M/SdV6mwW
# TyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIBhzAOBgNVHQ8B
# Af8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAg
# BgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZ
# bU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGalY17uT5IfdqBb
# MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAG
# CCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQw
# DQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tOCB3RKE/P09x7
# gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSXgmUrDKNSQqGT
# dpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPnvIWrqVogK0qM
# 8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM2UeUUW/8z3fv
# jxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlTVYzqfLDbe9Pp
# BKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ/xll/HjO9JbN
# VekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef4uaZFORNekUg
# QHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk9104WQzYuVNsxy
# oVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7ucykW7eaCuWB
# sBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZDBD+XgbF+23/z
# BjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3KeFUCS7tpFk7C
# rDqkMYIFJDCCBSACAQEwXzBIMQswCQYDVQQGEwJTRTEUMBIGA1UEChMLWmFtcGxl
# V29ya3MxIzAhBgNVBAMTGlphbXBsZVdvcmtzIEludGVybmFsIENBIHYzAhMxAAAA
# S5jn8iJKtIw9AAAAAABLMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKAC
# gAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsx
# DjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR7UyUHBDJ2zuyqL1xOQkg6
# 6dZyJTANBgkqhkiG9w0BAQEFAASCAQCEf7t0MGsZGxprsBqzQNaQYfKA/ymtwg80
# eL3XZCpdUOP5a1EZJQnb/X5g+riN8GO51raw7OOKkzDAp5wCYF5Cmv6PxKMkHjlT
# lZvNSHZo5LEhJCTHCQyYNHOVVrqf3BySNc8/alWvipxugA1g5UR3f0bZjAHS5sHN
# blEXqKHAszaeL6kyO7RdXF3+edRVGUi+dYopxuxP3KiPvKWDIvTl3bQ5BAJ5gJww
# LLWLGUKKmm9qX4FoI9gSkChFPJUE1KPibcgmr6fiuz1Pja0WfU0H633uXq8VXgq8
# EnPnzrIUSrcpID/9FlM4TSMHcy7NtjC4495GmKN4f7vKEx564PEQoYIDIDCCAxwG
# CSqGSIb3DQEJBjGCAw0wggMJAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoT
# DkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJT
# QTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQC65mvFq6f5WHxvnpBOMzBDAN
# BglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZI
# hvcNAQkFMQ8XDTI1MDQyNTA4MTIzM1owLwYJKoZIhvcNAQkEMSIEIIa2LGUmN8cz
# MHnu4frrZrUBLUWYqmfyuR5KqJBIPBTDMA0GCSqGSIb3DQEBAQUABIICADhdpalm
# vROdzJAj4a6xHgArF5C8YbZMFEZruTSZmDqd+9UCFCICcIi1JYDzryEziQatEGof
# ek/h4ub9xI5curJnKXJyGB2i8g/rpC0SL8117WNI7p0Re5gDx+u0LwoINycSWhrs
# KAzi7q0Oc6f9+sL/+tXT6YwsRQyucy8KCJ6pn7MkYUG4F/QeAVV83yghWVBsnDFs
# cF+9r6DRa8z7nWA1K0IY7IjrDGp+NLo2Z8h/9zTcqD3HOByB8tQFyMI2UHe0K6Qt
# +nXa/AsgXl5iWBYSI4h2See4607tAH//fNKwi1GP28wOewtR9+lI63tsnB+U2wIh
# f4P2z58TKmiuDcufl2ZYCONLNrh3cdYYZm9PwwnBhMVxSj7wQYYDT+td3I7JPGhz
# YFRn7t+9W3+Gxr4LqPQVC06U7wru6bu+rZW/+1/GOGD8slxQvDF+yVensQ/ru1ug
# Sb6D9IvEseERT/Cb6Sb1XcPc64SytFbKQFJmYbe9IRSRARwk0Rj4SLPJTnzfaJpE
# UrhqTgdAG5WiuOfhuPFX+3TahuckohNF/VL8aQ0mvQ9LiQr/QSDWepH2fA8saaLh
# 5PswBLueC7ZwP3zCBiwbWbtT35Epztj2NC+1OaxpQ8CWp0WtfbX0usWOY0CxQEMe
# Ob6mPQVASxxhT7l/vC6qj1nl8CKGA56M7wTf
# SIG # End signature block
