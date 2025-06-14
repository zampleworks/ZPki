<#PSScriptInfo

.VERSION 0.3.4.0

.GUID cfd4c1ac-acaa-4f4c-b82e-04af0744dab9

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
This script uses the ZPki module to install and configure
a standalone subordinate CA.
#>

[CmdletBinding()]
Param()

$ErrorActionPreference = "Stop"

#Requires -RunAsAdministrator
#Requires -Version 4

Import-Module ZPki

# FQDN for AIA & CDP Web site 
$HttpFqdn = "pki.zampleworks.com"

# We expect a root CA certificate file in the current directory which will be published to ADDS. Check for the file and
# verify that it is a valid root CA cert. Also try to find a CRL file to publish.

$RootCertFile = Get-childItem | Where-Object { $_ -match ".*\.(crt|cer)$" }
If(($RootCertFile | Measure-Object | Select-Object -ExpandProperty Count) -ne 1) {
    Write-Error "Please copy the root CA certificate file to this directory. It will be published to ADDS stores. Please don't put multiple cert files in this directory. cwd: [$(Get-Location)]"
}
$RootCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $RootCertFile
If($RootCert.Subject -ne $RootCert.Issuer) {
    Write-Error ("Found a certificate file, but it is not a root CA certificate. Subject: {0}, issuer: {1}, file: {2}" -f $RootCert.Subject, $RootCert.Issuer, $RootCertFile.FullName)
}

Write-Progress -Activity "Installing ADCS tools and DNS Server tools.."

# AD tools are used for lookup of domain/forest names, and check Enterprise Admin rights.
# DNS tools are used to register DNS record for HTTP AIA/CDP

Install-WindowsFeature RSAT-Ad-Tools | Out-Null
Install-WindowsFeature RSAT-DNS-Server | Out-Null

Write-Progress -Activity "Gathering AD Forest info"

$AdForestDns = Get-ADForest -Current LocalComputer | Select-Object -ExpandProperty RootDomain
$RootDomain = Get-ADDomain $AdForestDns -Server $AdForestDns
$RootDomainNbName = $RootDomain.NetBIOSName
$EaGroup = "$RootDomainNbName\Enterprise Admins"
$EnterpriseAdmin = (whoami -groups | Where-Object { $_ -like "*$EaGroup*" } | Measure-Object | Select-Object -ExpandProperty Count) -eq $True

If(-Not $EnterpriseAdmin) {
    Write-Error "You must be a member of $EaGroup to install an Enterprise Root CA."
}

# Check if DNS record for HTTP CDP/AIA exists. If not, try to create it.

Write-Verbose "Checking for DNS record.."

$DnsRec = Resolve-DnsName $HttpFqdn -ErrorAction SilentlyContinue
If($Null -eq $DnsRec) {
    Write-Progress -Activity "Creating DNS record for HTTP"
    Try {
        $RoutableIpv4 = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $Null } | Select-Object -First 1
        #$RoutableIpv6 = Get-NetIPConfiguration | Where-Object { $_.IPv6DefaultGateway -ne $Null } | Select-Object -First 1
        
        Write-Verbose "Adding DNS record for $HttpFqdn.."
        If($RoutableIpv4) {
            Add-DnsServerResourceRecordA -Name "$HttpFqdn." -IPv4Address $RoutableIpv4.IPv4Address.IPAddress -ZoneName $AdForestDns -ComputerName $AdForestDns
        }
    } Catch {
        Write-Warning "DNS registration failed. Will proceed with installation."
        Write-Warning $_.Exception.Message
    }
}

Publish-ZPkiCaDsFile -PublishFile '.\ZampleWorks CA v1.crt' -CertType RootCA -Verbose
Publish-ZPkiCaDsFile -PublishFile '.\ZampleWorks CA v1.crl' -CdpContainer 'ZampleWorks CA v1' -CdpObject 'ZampleWorks CA v1'

Write-Progress -Activity "Running CA installation script"
Install-ZPkiCa -CaType EnterpriseSubordinateCA -CaCommonName "ZampleWorks Sub CA v1" -EnableBasicConstraints -BasicConstraintsIsCritical -IncludeAllIssuancePolicy -CpsOid "1.3.6.1.4.1.53997.509.1.1" -CpsUrl "http://$HttpFqdn/Docs/cps.txt" -CaCertValidityPeriodUnits 10 -Verbose

Read-Host "Pending Root CA signing. Copy signed certificate file to the current directory ($(Get-Location)) and hit enter to proceed."

Write-Progress -Activity "Running CA post config"
Set-ZPkiCaPostInstallConfig -InstallWebCdp -HttpCdpFqdn $HttpFqdn -RestartCertSvc

Write-Progress -Activity "Updating CA CDP/AIA information"
Set-ZPkiCaUrlConfig -ClearCDPs -ClearAIAs
Set-ZPkiCaUrlConfig -HttpCdpFqdn $HttpFqdn -AddFileCdp
Set-ZPkiCaUrlConfig -HttpAiaFqdn $HttpFqdn

Write-Progress -Activity "Generating content for AIA/CDP Web site"
New-ZPkiRepoIndex -Sourcepath C:\ADCS\Web\Repository\ -IndexFile C:\ADCS\Web\index.html -CssFiles "style.css"
New-ZPkiRepoCssFile -CssFile C:\ADCS\Web\style.css

# SIG # Begin signature block
# MIIcxwYJKoZIhvcNAQcCoIIcuDCCHLQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUozHXdd/jKArJTkNhumKcS0n+
# lTGgghcNMIIEBjCCA6ygAwIBAgITMQAAAEuY5/IiSrSMPQAAAAAASzAKBggqhkjO
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
# DjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSds3gf1LCK5njTU1n+5qUl
# 2jTq6zANBgkqhkiG9w0BAQEFAASCAQBKOX4tVMZG+ngPdzj3tubPDzfxV5I8xoLQ
# 3hf89sNRldoih6OV+FWNOytLVkAHCPLJUA4PSoDD5zqKW+IMBGG2hvJwGt98H9P3
# KnNSVcC07/JitD1Pt8TRKessRebQmxvM/WnDfllktCGVv2y2aL13D2jip2BJShzh
# rQaCa2mRjjAJzQ1T2WOeU8hsszZuS76jSxC+b8qMMEBQST8o8X0dZ+pNWpzh23SJ
# 7aqT12pDDaq30kf9eJdJ23ypiPg+TzPIzUmTWmp9pH73vtav+bgXYqSNuywXaAXX
# Mn+naBdRy0Pi2RE6eD9RpIQsO0TYQ3d9MnmXUsIFwS7jPDQk5oyroYIDIDCCAxwG
# CSqGSIb3DQEJBjGCAw0wggMJAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoT
# DkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJT
# QTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQC65mvFq6f5WHxvnpBOMzBDAN
# BglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZI
# hvcNAQkFMQ8XDTI1MDUwNTExMDcyMFowLwYJKoZIhvcNAQkEMSIEICqBXP99wnrG
# nrVbiOxcCa7oJN6BctpowFKkOO8tJM9MMA0GCSqGSIb3DQEBAQUABIICAIRA2UDe
# ocPDhezXKi765RNS8JMMYcOYYXBzDKFc+PJoaB//mnIRKPE2RipTkrQg9Ua5JzwD
# mxu4dxAac+E47+LwiIAXMPPQ+0Yy7BURM5UcwyF7BxdbIEPUpvQF3kYHia4sMtQF
# iLMCgacUs4Kfppqj+yHn0tAQCWWY0uXjZzdIm3er0eWQ2SpXppaVmy2yxNg2RpFa
# NZvDGJtFrZ1qO3MBWxRtGcOrHNvNjUofODhR85mj07YCGdysK8uS0VqRsRqv5Sj3
# bvXpNc+x7qR8y2H5DTnod3Rk9RcFI174nHcWKEkfuxIK3Zdz3QYJDfsiGlNJNtKf
# NzSnjbGlQoiRZ1ZKrz2wKbsOdkmBUVUvFb9oICrVYBPIQOz0AkOpP/75Ew9PaDlI
# Uw2Zj9N4f0PV/qTEBdHYUuUOj4cXbopydS+pvNGyNJ8nIKxVmzIt1g5i6+Hz6GbQ
# tBAytol7PjYopfvvizRZx6wUnymJvNDcEK6EnpmpTOqW9oYgFmlDU5xUjN2UvV1t
# MUK1OgFOZFRNLp/M+NHuFIOfqHYzQFTFwVRL0JGMrxb4XSpuYH7X9pjxWFoTsCvv
# EApuYgNXmniem+OcCSQHr1HqxBwCDDvv+LBrgYibhe1a7XrBluVhCnhQyDsNZnwq
# 21vXL80l8YGZwVzdN94ufGTFMJAIyrBYcUMD
# SIG # End signature block
