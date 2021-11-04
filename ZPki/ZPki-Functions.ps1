<#PSScriptInfo

.VERSION 0.1.7978.18230

.GUID c5309bd6-c9e1-44de-a259-de7d3601ab18

.AUTHOR Anders Runesson

.COMPANYNAME ZampleWorks

.COPYRIGHT (c) Anders Runesson

.TAGS

.LICENSEURI

.PROJECTURI https://github.com/zampleworks/ZPki

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#> 




















<#

.DESCRIPTION
Private functions for ZPki module

#>


Function Get-HttpUri {
    Param(
        $HostFQDN
        ,$Path
        ,$Document
    )
    If($null -ne $Path) {
        $Path = $Path.Trim('/')
    } Else {
        $Path = ""
    }
    If($Path.Length -gt 0) {
        $Path = "/$Path/"
    } Else {
        $Path = "/"
    }
    Write-Output "http://$($HostFQDN)$($Path)$($Document)"
}


Function Get-LdapUri {
    Param(
        [switch]
        $IsAIA
    )

    If($IsAIA) {
        Write-Output "ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11"
    } Else {
        Write-Output "ldap:///CN=%7%8,CN=%7,CN=CDP,CN=Public Key Services,CN=Services,%6%10"
    }
}

Function Get-FileUri {
    Param(
        $Path,

        [switch]
        $IsAIA
    )

    If($IsAIA) {
        Write-Output "file:///$Path\%3%4.crt"
    } Else {
        Write-Output "file:///$Path\%7%8%9.crl"
    }
}

Function New-ADCSPath {
    [CmdletBinding(ConfirmImpact='Medium', SupportsShouldProcess=$true)]
    Param(
        [string]
        $PathName,
        [string]
        $Path
    )

    If(-Not (Test-Path $Path -PathType Any) -And ($PSCmdlet.ShouldProcess($PathName, "Create ADCS directory"))) {
        Write-Verbose "Creating ADCS Directory [$PathName] at [$Path]"
        New-Item $Path -ItemType Directory | Out-Null
    } Elseif(Test-Path $Path -PathType Leaf) {
        Write-Error "ADCS Directory exists, but is a file. Cannot continue. [$PathName]: [$Path]"
    }
}

Function Get-CaPolicyFileTemplate {
    Param(
        [Parameter(Mandatory=$True)]
        $CAType
    )
    If($CAType -like "*root*") {
        Get-Content .\CAPolicy-root.inf
    } Else {
        Get-Content .\CAPolicy-sub.inf
    }
}

Function Get-CaPolicyHeaderSection {
    Write-Output "[Version]`r`nSignature=`"`$Windows NT`$`" `r`n"
}

Function Get-CaPolicyCertSrvSection {
    Param(
        $Keylength,
        $CACertValidityPeriod,
        $CACertValidityPeriodUnits,
        $CRLPeriod,
        $CRLPeriodUnits,
        $DeltaPeriod,
        $DeltaPeriodUnits,
        $LoadDefaultTemplates,
        $AltSignatureAlgorithm,
        $ForceUTF8,
        $ClockSkewMinutes,
        $EnableKeyCounting
    )

    $ldt = [int] $LoadDefaultTemplates
    $asa = [int] $AltSignatureAlgorithm
    $futf = [int] $ForceUTF8
    $ekc = [int] $EnableKeyCounting

    Write-Output (("[Certsrv_Server]",
        "RenewalKeyLength = $Keylength",
        "RenewalValidityPeriod = $CACertValidityPeriod",
        "RenewalValidityPeriodUnits = $CACertValidityPeriodUnits",
        "CRLPeriod = $CRLPeriod",
        "CRLPeriodUnits = $CRLPeriodUnits",
        "CRLDeltaPeriod = $DeltaPeriod",
        "CRLDeltaPeriodUnits =  $DeltaPeriodUnits",
        "LoadDefaultTemplates = $ldt",
        "AlternateSignatureAlgorithm = $asa",
        "ForceUTF8 = $futf".
        "ClockSkewMinutes = $ClockSkewMinutes",
        "EnableKeyCounting = $ekc") -join "`r`n")
}

Function Get-CaPolicyPolicySection {
    Param(
        $PolicyName,
        $PolicyOid,
        $PolicyNotice,
        $PolicyUrl
    )

    If([string]::IsNullOrWhiteSpace($PolicyName)) {
        Write-Error "Get-CaPolicyPolicySection(): Policy name cannot be empty."
    }
    If([string]::IsNullOrWhiteSpace($PolicyOid)) {
        Write-Error "Get-CaPolicyPolicySection(): Policy OID cannot be empty. Policy name: [$PolicyName]"
    }
    If([string]::IsNullOrWhiteSpace($PolicyName) -And [string]::IsNullOrWhiteSpace($PolicyNotice) -and [string]::IsNullOrWhiteSpace($PolicyUrl)) {
        Write-Error "Get-CaPolicyPolicySection(): Policy Notice and Url cannot both be empty. Policy name: [$PolicyName]"
    }

    $Section = ""
    $Section = "[$PolicyName]`r`nOID=$PolicyOid`r`n"
    If(-Not [string]::IsNullOrWhiteSpace($PolicyNotice)) {
        $Section = "$($Section)Notice=$PolicyNotice`r`n"
    }
    If(-Not [string]::IsNullOrWhiteSpace($PolicyUrl)) {
        $Section = "$($Section)URL=$PolicyUrl`r`n"
    }

    Write-Output $Section
}

Function Get-CaPolicyPolicyExtensionsSection {
    Param(
        [string]
        $Sections
    )

    If(-Not [string]::IsNullOrWhiteSpace($Sections)) {
        Write-Output "[PolicyStatementExtension] `r`n Policies=$Sections`r`n"
    }
}

Function Get-CaPolicyBasicConstraintsSection {
    Param(
        [string]
        $PathLength,
        [bool]
        $Critical
    )

    $Crit = If($Critical) { "Yes" } Else { "No" }
    $Pl = ""
    If($PathLength -ne "None") {
        $Pl = "PathLength = $PathLength"
    }

    Write-Output (("[BasicConstraintsExtension]",
    $Pl,
    "Critical = $Crit`r`n") -join "`r`n")
}

Function Get-CaPolicyEkuSection {
    Param(
        [string[]]
        $Oids,

        [switch]
        $Critical
    )

    $Crit = If($Critical) { "Yes" } Else { "No" }
    Write-Output (( & {
        Write-Output "[EnhancedKeyUsageExtension]"
        Write-Output "Critical = $Crit"

        Foreach($e in $Oids) {
            Write-Output "OID = $e"
        }

        Write-Output "`r`n"
    }) -join "`r`n")
}

Function New-AdcsBackupDir {
    [CmdletBinding(ConfirmImpact="Medium", SupportsShouldProcess=$true)]
    Param(
        [string]
        $Path,
        [string]
        $Name
    )

    $FullPath = "$Path\$Name"

    Write-Verbose "Creating $FullPath"

    If(Test-Path $FullPath -PathType Leaf) {
	    Write-Error "Target directory [$FullPath] already exists, but is a file. Please remove the file or use a different path."
    }

    If(-Not (Test-Path $FullPath) -And ($PSCmdlet.ShouldProcess($FullPath, "Create backup directory"))) {
	    mkdir $FullPath | Out-Null
    }

    If(-Not (Test-Path $FullPath)) {
	    Write-Error "Failed to create target directory [$FullPath]."
    }
}

Function Test-IsAdmin {
    [CmdletBinding()]
    Param()
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    Write-Output $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
# SIG # Begin signature block
# MIIT5AYJKoZIhvcNAQcCoIIT1TCCE9ECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCLno2G8h3d9gioOQIBYEP83o
# tEiggg8aMIIE3zCCA8egAwIBAgITfAAAAmjyAgtI2ylKrQAAAAACaDANBgkqhkiG
# 9w0BAQsFADBIMQswCQYDVQQGEwJTRTEUMBIGA1UEChMLWmFtcGxlV29ya3MxIzAh
# BgNVBAMTGlphbXBsZVdvcmtzIEludGVybmFsIENBIHYyMB4XDTIxMDkyOTA2Mjcw
# OFoXDTIyMDkyOTA2MjcwOFowGjEYMBYGA1UEAxMPQW5kZXJzIFJ1bmVzc29uMIIB
# IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA43cRjTpmPHXHWfn/Oq9Z8k33
# xbkjrktUJeWwJXsHBvH3DM2+16PPCqZFpXP0bJnV7onGhS+NAKehFJnbxVOLlYCo
# z0NG9VKDI/rfEisD1HB9a7+LtEhftNDtiFGqTh9uFS1CZuxvqIMHiWewkA5UfKhm
# 1MenvUqoVZZn13C0NBaa12UYwXln5eAtvSs0/K8rTdVtealeDlDpdJSSan43alPR
# SGTMLoc/DSCQzem+vknA0ZyB4utrXlfeGNfLcWkuaikvNj/MqrM4kLRDt7QST4oV
# wo0PmiLbRpwo/5IWSHHu+HqEzqvPlkcGdWYY9EzvvMtUAJTK/ImNfqRKtay/JQID
# AQABo4IB7jCCAeowPgYJKwYBBAGCNxUHBDEwLwYnKwYBBAGCNxUIhb31ToL5uhOG
# vZceh8eaKYeL30SBZIb4qhWEotFXAgFkAgEFMBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MA4GA1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBTokeZxlUoFftQbUXtU5+kX10Ec5DAfBgNVHSMEGDAWgBQw8yN9GudA
# 5sz7JBn9MTgHRI8vQzBeBgNVHR8EVzBVMFOgUaBPhk1odHRwOi8vcGtpLm9wLnph
# bXBsZXdvcmtzLmNvbS9SZXBvc2l0b3J5L1phbXBsZVdvcmtzJTIwSW50ZXJuYWwl
# MjBDQSUyMHYyLmNybDBpBggrBgEFBQcBAQRdMFswWQYIKwYBBQUHMAKGTWh0dHA6
# Ly9wa2kub3AuemFtcGxld29ya3MuY29tL1JlcG9zaXRvcnkvWmFtcGxlV29ya3Ml
# MjBJbnRlcm5hbCUyMENBJTIwdjIuY3J0MFsGA1UdEQRUMFKgLwYKKwYBBAGCNxQC
# A6AhDB9BbmRlcnMuUnVuZXNzb25AemFtcGxld29ya3MuY29tgR9BbmRlcnMuUnVu
# ZXNzb25AemFtcGxld29ya3MuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQCNNt/29ETr
# AvXUUq8lTQkrDoFA6ljS+6iXZvQvfVuk4iLL63a4vNSImgqKAWvi6soT/vhNMqys
# Xj2gC1TzP0fo9G0dgsg26qwg6URz9H5WAD28Hoi/XVVGWklJD42CSfjLWzICoxJt
# m6D+WbqoofINMuX4Vaqxo1Yg6sDxZqs3fnReOf5rLAumDIZpvezHnrHHUb6kl91h
# xUvG7yM0wt0sG3ZDxWY5giuUQxNO3sY6OjB+Cv7Ty7aNmIoelUgHsJ+Z5reWNG2o
# 5Y22BqBGZYSNzRySduHEL8/GCaKFfosE8NFSu6guZvVji/Y7tTAwYlbn42EFrtZq
# 8FVopb7RpF3RMIIE/jCCA+agAwIBAgIQDUJK4L46iP9gQCHOFADw3TANBgkqhkiG
# 9w0BAQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEy
# IEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENBMB4XDTIxMDEwMTAwMDAwMFoXDTMx
# MDEwNjAwMDAwMFowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAMLmYYRnxYr1DQikRcpja1HXOhFCvQp1dU2U
# tAxQtSYQ/h3Ib5FrDJbnGlxI70Tlv5thzRWRYlq4/2cLnGP9NmqB+in43Stwhd4C
# GPN4bbx9+cdtCT2+anaH6Yq9+IRdHnbJ5MZ2djpT0dHTWjaPxqPhLxs6t2HWc+xO
# bTOKfF1FLUuxUOZBOjdWhtyTI433UCXoZObd048vV7WHIOsOjizVI9r0TXhG4wOD
# MSlKXAwxikqMiMX3MFr5FK8VX2xDSQn9JiNT9o1j6BqrW7EdMMKbaYK02/xWVLwf
# oYervnpbCiAvSwnJlaeNsvrWY4tOpXIc7p96AXP4Gdb+DUmEvQECAwEAAaOCAbgw
# ggG0MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoG
# CCsGAQUFBwMIMEEGA1UdIAQ6MDgwNgYJYIZIAYb9bAcBMCkwJwYIKwYBBQUHAgEW
# G2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAfBgNVHSMEGDAWgBT0tuEgHf4p
# rtLkYaWyoiWyyBc1bjAdBgNVHQ4EFgQUNkSGjqS6sGa+vCgtHUQ23eNqerwwcQYD
# VR0fBGowaDAyoDCgLoYsaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNz
# dXJlZC10cy5jcmwwMqAwoC6GLGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEy
# LWFzc3VyZWQtdHMuY3JsMIGFBggrBgEFBQcBAQR5MHcwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBPBggrBgEFBQcwAoZDaHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRFRpbWVzdGFtcGlu
# Z0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAQEASBzctemaI7znGucgDo5nRv1CclF0
# CiNHo6uS0iXEcFm+FKDlJ4GlTRQVGQd58NEEw4bZO73+RAJmTe1ppA/2uHDPYuj1
# UUp4eTZ6J7fz51Kfk6ftQ55757TdQSKJ+4eiRgNO/PT+t2R3Y18jUmmDgvoaU+2Q
# zI2hF3MN9PNlOXBL85zWenvaDLw9MtAby/Vh/HUIAHa8gQ74wOFcz8QRcucbZEnY
# Ipp1FUL1LTI4gdr0YKK6tFL7XOBhJCVPst/JKahzQ1HavWPWH1ub9y4bTxMd90oN
# cX6Xt/Q/hOvB46NJofrOp79Wz7pZdmGJX36ntI5nePk2mOHLKNpbh6aKLzCCBTEw
# ggQZoAMCAQICEAqhJdbWMht+QeQF2jaXwhUwDQYJKoZIhvcNAQELBQAwZTELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENB
# MB4XDTE2MDEwNzEyMDAwMFoXDTMxMDEwNzEyMDAwMFowcjELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGlu
# ZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL3QMu5LzY9/3am6
# gpnFOVQoV7YjSsQOB0UzURB90Pl9TWh+57ag9I2ziOSXv2MhkJi/E7xX08PhfgjW
# ahQAOPcuHjvuzKb2Mln+X2U/4Jvr40ZHBhpVfgsnfsCi9aDg3iI/Dv9+lfvzo7oi
# PhisEeTwmQNtO4V8CdPuXciaC1TjqAlxa+DPIhAPdc9xck4Krd9AOly3UeGheRTG
# TSQjMF287DxgaqwvB8z98OpH2YhQXv1mblZhJymJhFHmgudGUP2UKiyn5HU+upgP
# hH+fMRTWrdXyZMt7HgXQhBlyF/EXBu89zdZN7wZC/aJTKk+FHcQdPK/P2qwQ9d2s
# rOlW/5MCAwEAAaOCAc4wggHKMB0GA1UdDgQWBBT0tuEgHf4prtLkYaWyoiWyyBc1
# bjAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzASBgNVHRMBAf8ECDAG
# AQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB5Bggr
# BgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDov
# L2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6
# oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNybDBQBgNVHSAESTBHMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcC
# ARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzALBglghkgBhv1sBwEwDQYJ
# KoZIhvcNAQELBQADggEBAHGVEulRh1Zpze/d2nyqY3qzeM8GN0CE70uEv8rPAwL9
# xafDDiBCLK938ysfDCFaKrcFNB1qrpn4J6JmvwmqYN92pDqTD/iy0dh8GWLoXoIl
# HsS6HHssIeLWWywUNUMEaLLbdQLgcseY1jxk5R9IEBhfiThhTWJGJIdjjJFSLK8p
# ieV4H9YLFKWA1xJHcLN11ZOFk362kmf7U2GJqPVrlsD0WGkNfMgBsbkodbeZY4Ui
# jGHKeZR+WfyMD+NvtQEmtmyl7odRIeRYYJu6DC0rbaLEfrvEJStHAgh8Sa4TtuF8
# QkIoxhhWz0E0tmZdtnR79VYzIi8iNrJLokqV2PWmjlIxggQ0MIIEMAIBATBfMEgx
# CzAJBgNVBAYTAlNFMRQwEgYDVQQKEwtaYW1wbGVXb3JrczEjMCEGA1UEAxMaWmFt
# cGxlV29ya3MgSW50ZXJuYWwgQ0EgdjICE3wAAAJo8gILSNspSq0AAAAAAmgwCQYF
# Kw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJ
# KoZIhvcNAQkEMRYEFM6elX70dCeDrVOjpgusxQHIRXReMA0GCSqGSIb3DQEBAQUA
# BIIBABTReggRtcGZRYz5E+LgqlyPj8WJMSxBcDENCFVoXa00eGoGAc17EgbfLfch
# Mn7qllvq5vI32alI8sjP6EUtg/TlNFkxQo1Xe/yvtW4cInfzA8NRQcsNyq7Ys2mN
# KQ44CL0v7z4L8FFiYRyP7xYJOTI63Hds0E/MmNjsTFzInvNpV4o+riNpNztFTJUe
# H+uyhT/yh5X6Qz9kCzt/BCxSn6eCJ2qrfPpJ8JAqG7Lh3ietdZc31MMVb3bOLZ0x
# i6EPDROCIw5WEJQLZxwVKUXPzOwghfwB3fRlQDKD5CXO5ghUWtGztb9NY4zHcSRu
# wVwQ6Gs7KhImvMGf/gaSTW17iUehggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkC
# AQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBB
# c3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglg
# hkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcN
# AQkFMQ8XDTIxMTEwNDA5MjAxOVowLwYJKoZIhvcNAQkEMSIEIFsTtMfp7k7GFIUT
# rjrqtgBPtekLo4svwOkjzwGEeQEWMA0GCSqGSIb3DQEBAQUABIIBAAuaSlkCurwS
# Ftb0iPl0DdUOfXT5rgNPr8LMQb+zzb3Fne70vqyg9PIyYA1qJbQGWiaMVcpgFcas
# zBuEiv8XAPSGgglf5kfQDvWPhPpHUkv30quaFBKQZQ4aRz8gv+NhARYq6OjWxa9K
# TJkmTfgWgFCFCLWVL8xtn8wEOhm0Yz0le+mdUw7LVOFsp9I1cix9Rq+loTsbKKIS
# jlO0gP0JqnvaKTIj76FrP0Xp7VZnR07GjWf1oI40B/NX4B93TEp0eYFtLCgFx8ff
# UspKE9EtJqtk96vnZOpzLvH1uYEf/52sshyRo5mfwwKUFk4ISnMAXoJaWxQcEs6A
# XBvGp69j8G0=
# SIG # End signature block
