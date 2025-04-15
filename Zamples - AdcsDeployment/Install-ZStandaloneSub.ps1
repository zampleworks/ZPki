<#PSScriptInfo

.VERSION 0.2.0.0

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
# MIIc7AYJKoZIhvcNAQcCoIIc3TCCHNkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB647ABl10JaTww
# pRFmf8ZkPgS3KEc3UKvlnbqqBZZEtaCCFw0wggQGMIIDrKADAgECAhMxAAAAS5jn
# 8iJKtIw9AAAAAABLMAoGCCqGSM49BAMCMEgxCzAJBgNVBAYTAlNFMRQwEgYDVQQK
# EwtaYW1wbGVXb3JrczEjMCEGA1UEAxMaWmFtcGxlV29ya3MgSW50ZXJuYWwgQ0Eg
# djMwHhcNMjUwNDAyMDcxNjIyWhcNMjYwNDAyMDcyNjIyWjAaMRgwFgYDVQQDEw9B
# bmRlcnMgUnVuZXNzb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDT
# sUPEug1GoD0ar/yoJT39X2h00X3JnWwGAvmvh9mI443ll1pSB6rb6j2zx0KIoeR1
# TQu9w6nty47dctGf6Ox4WVJgZj1boIWK+lG57C5PX7bbwD/gJ+qZbrnsj2qLvwpF
# gMsnMTwhDEKfPky/D2y6D++e8IzTbRWdS7JHPOxKuZtm+CwCyktMwcBuQWWZJMsS
# edUB8Gk5Tjk5RzCJzQFHvzmr9QR4uJL8dG2eIik0G0ktrTo5wMYeXn0BcavebBnp
# YNdBAev6yNm6/8I01indVuzBG729Ot8uGkkiI/KUCYmesO/65Bz2cEia3DwmBLof
# YhSG/7GJ+qWLWypeBTJPAgMBAAGjggHWMIIB0jA+BgkrBgEEAYI3FQcEMTAvBicr
# BgEEAYI3FQiFvfVOgvm6E4a9lx6Hx5oph4vfRIFkhviqFYSi0VcCAWUCAQcwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsGCSsGAQQBgjcVCgQO
# MAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFMIw8bu2T2Ry4uTZ2XKjXrPJF4hGMB8G
# A1UdIwQYMBaAFNycnL/2+NQJIWqe3QaNutQBPBQ2MGIGCCsGAQUFBwEBBFYwVDBS
# BggrBgEFBQcwAoZGaHR0cDovL3BraS5vcC56d2tzLnh5ei9SZXBvc2l0b3J5L1ph
# bXBsZVdvcmtzJTIwSW50ZXJuYWwlMjBDQSUyMHYzLmNydDBbBgNVHREEVDBSoC8G
# CisGAQQBgjcUAgOgIQwfQW5kZXJzLlJ1bmVzc29uQHphbXBsZXdvcmtzLmNvbYEf
# YW5kZXJzLnJ1bmVzc29uQHphbXBsZXdvcmtzLmNvbTBNBgkrBgEEAYI3GQIEQDA+
# oDwGCisGAQQBgjcZAgGgLgQsUy0xLTUtMjEtMTY5MDA3NTU0LTU2MTU1NTU4My0z
# NDY1ODcwMDY1LTE1MTYwCgYIKoZIzj0EAwIDSAAwRQIhAIRkLmTClm3OJndccyd2
# 14WZ0mXH3N68iZaTVxrzKGcaAiB+8mqDJvNMyUP/lSrSPWXDJzFzSYRnI2mvdAAV
# faOEJjCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEM
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zC
# pyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf
# 1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x
# 4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEio
# ZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7ax
# xLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZ
# OjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJ
# l2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz
# 2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH
# 4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb
# 5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ
# 9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuC
# MS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0g
# ADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs
# 7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq
# 3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/
# Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9
# /HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWoj
# ayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDCCBq4wggSWoAMC
# AQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTIyMDMy
# MzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoT
# DkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJT
# QTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQAD
# ggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5Mom2gsMyD
# +Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE2hHxc7Gz
# 7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWNlCnT2exp
# 39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFobjchu0Cs
# X7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhNef7Xj3OT
# rCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3VuJyWQmDo4
# EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtzQ87fSqEc
# azjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4OuGQq+nUo
# JEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5sjClTNfp
# mEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm4T72wnSy
# Px4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIztM2xAgMB
# AAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6FtltTYUv
# cyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAO
# BgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUHAQEE
# azBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYB
# BQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0
# ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcwCAYG
# Z4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmOwJO2b5ip
# RCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H6T5gyNgL
# 5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/R3f7cnQU
# 1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzvqLx1T7pa
# 96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/aesXmZgaNW
# hqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdmkfFynOlL
# AlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3EyTN3B14
# OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh3SP9HSjT
# x/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA3yAWTyf7
# YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8BPqC3jLf
# BInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsfgPrA8g4r
# 5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwgga8MIIEpKADAgECAhALrma8Wrp/lYfG
# +ekE4zMEMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0
# MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjQwOTI2MDAwMDAwWhcNMzUx
# MTI1MjM1OTU5WjBCMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxIDAe
# BgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDI0MIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAvmpzn/aVIauWMLpbbeZZo7Xo/ZEfGMSIO2qZ46XB/Qow
# IEMSvgjEdEZ3v4vrrTHleW1JWGErrjOL0J4L0HqVR1czSzvUQ5xF7z4IQmn7dHY7
# yijvoQ7ujm0u6yXF2v1CrzZopykD07/9fpAT4BxpT9vJoJqAsP8YuhRvflJ9YeHj
# es4fduksTHulntq9WelRWY++TFPxzZrbILRYynyEy7rS1lHQKFpXvo2GePfsMRhN
# f1F41nyEg5h7iOXv+vjX0K8RhUisfqw3TTLHj1uhS66YX2LZPxS4oaf33rp9Hlfq
# SBePejlYeEdU740GKQM7SaVSH3TbBL8R6HwX9QVpGnXPlKdE4fBIn5BBFnV+KwPx
# RNUNK6lYk2y1WSKour4hJN0SMkoaNV8hyyADiX1xuTxKaXN12HgR+8WulU2d6zhz
# XomJ2PleI9V2yfmfXSPGYanGgxzqI+ShoOGLomMd3mJt92nm7Mheng/TBeSA2z4I
# 78JpwGpTRHiT7yHqBiV2ngUIyCtd0pZ8zg3S7bk4QC4RrcnKJ3FbjyPAGogmoiZ3
# 3c1HG93Vp6lJ415ERcC7bFQMRbxqrMVANiav1k425zYyFMyLNyE1QulQSgDpW9rt
# vVcIH7WvG9sqYup9j8z9J1XqbBZPJ5XLln8mS8wWmdDLnBHXgYly/p1DhoQo5fkC
# AwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1Ud
# JQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG
# /WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQU
# n1csA3cOKBWQZqVjXu5Pkh92oFswWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRp
# bWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1
# NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAPa0eH3aZW+M4
# hBJH2UOR9hHbm04IHdEoT8/T3HuBSyZeq3jSi5GXeWP7xCKhVireKCnCs+8GZl2u
# VYFvQe+pPTScVJeCZSsMo1JCoZN2mMew/L4tpqVNbSpWO9QGFwfMEy60HofN6V51
# sMLMXNTLfhVqs+e8haupWiArSozyAmGH/6oMQAh078qRh6wvJNU6gnh5OruCP1QU
# AvVSu4kqVOcJVozZR5RRb/zPd++PGE3qF1P3xWvYViUJLsxtvge/mzA75oBfFZSb
# dakHJe2BVDGIGVNVjOp8sNt70+kEoMF+T6tptMUNlehSR7vM+C13v9+9ZOUKzfRU
# AYSyyEmYtsnpltD/GWX8eM70ls1V6QG/ZOB6b6Yum1HvIiulqJ1Elesj5TMHq8CW
# T/xrW7twipXTJ5/i5pkU5E16RSBAdOp12aw8IQhhA/vEbFkEiF2abhuFixUDobZa
# A0VhqAsMHOmaT3XThZDNi5U2zHKhUs5uHHdG6BoQau75KiNbh0c+hatSF+02kULk
# ftARjsyEpHKsF7u5zKRbt5oK5YGwFvgc4pEVUNytmB3BpIiowOIIuDgP5M9WArHY
# SAR16gc0dP2XdkMEP5eBsX7bf/MGN4K3HP50v/01ZHo/Z5lGLvNwQ7XHBx1yomzL
# P8lx4Q1zZKDyHcp4VQJLu2kWTsKsOqQxggU1MIIFMQIBATBfMEgxCzAJBgNVBAYT
# AlNFMRQwEgYDVQQKEwtaYW1wbGVXb3JrczEjMCEGA1UEAxMaWmFtcGxlV29ya3Mg
# SW50ZXJuYWwgQ0EgdjMCEzEAAABLmOfyIkq0jD0AAAAAAEswDQYJYIZIAWUDBAIB
# BQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG
# 9w0BCQQxIgQgPDHwBkA/9FHRaIt4y4YLj2lm/93ZJX0RlG0iQTzt7QYwDQYJKoZI
# hvcNAQEBBQAEggEANnZmDnVDC5pJHeBojzouAKxvhN4KrNzEpr/XsYWpUUZjJrIR
# jMTr3u1PpYgZVJfx1AJXC/nUhN7lVGpEeRh3b3hwmw7ANIG0ySQ2GClcAU2HarfV
# AzdDX5K2PW/DQdRBa3YM6ilJBkd5QYYZDPgRSMoALqF+TitHknpk53l83CuIQgHQ
# EVpZI6HsqMtnO9Dioz738hC5ghYArXomS89oOYZ88gLWxG+1em/exU3sTlPgu+Mk
# phM8ibVACpOXnGljz9/M54LsNh1fp5bDFh70tG0ixD6D1aBuCjmB7ZkngnrxPS77
# pjdZqbSjeLjRRBZYuKGSaHN/r95i1i2PomrAmKGCAyAwggMcBgkqhkiG9w0BCQYx
# ggMNMIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1
# NiBUaW1lU3RhbXBpbmcgQ0ECEAuuZrxaun+Vh8b56QTjMwQwDQYJYIZIAWUDBAIB
# BQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0y
# NTA0MDYxMDE5MTVaMC8GCSqGSIb3DQEJBDEiBCBuRa1xpARZ5cNTEDrMO0RqEalN
# vB/968o5k+yvZmtOYjANBgkqhkiG9w0BAQEFAASCAgACOzlC5VYZkDNOBy2S+/vn
# mSeAk2Lvug7MV6hLzbMkntAJ0UT3Tb4CHpZtTjBzHq/uJk9E+kl5Y5X4gEyK4aTb
# waE4cwxGTz1YL+9lm6H3eYgRaB2Pfu/scKUZL4kkI+TUWpy8/hk+8zcoYuJDhvXt
# JKkvoPe6GFTl24zNGpd292gN7VM/UWJJcB/TCjJFL3JhVaLTNMuN8jhpc32pjna/
# /TAb0X5mZCYvyg+9Zs2sBjWjakzkhn3GXEasvyjQ1JFBpKa+IfXR7uHvQs5hYSB8
# b+XJ9L5Kp6USHTRumpKu+FYJ/FYiBwA7ZCZTd4XVfjABgCjguX1k3SsLCb9gbOTd
# 3fiQyGQG+HVHMEOYsm0VWXy0DA3kVC3aB27e7xMpPpOMRn8sQbNc6orcpvxRKCAG
# G/n4iU/ACDsLH9U4dJGejQSZcCn9ilfhNjo92foAasCMx2F2A3c/HDmrrE13gYE6
# HdV8VC2+ukYEFvrfqvd/tT4zLBhhVAAL8dL7ajtO/rCxDJ8rhIALYXz5h+4Rpgbl
# Xf3XDJFIUi2QOv9sAp76R2Phfxmp1H2KKTB6MPYyR8kzsULMUTCWq/MrbUlHVVN+
# kLymU9ugIkqokd0ax+1qD5+LmME38dZYDa9FxRz6YOKZS3lRE4MG0UNKnSVgMYOL
# K+OcyKH9bpyjIWYm6+73iA==
# SIG # End signature block
