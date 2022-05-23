<#PSScriptInfo

.VERSION 0.1.8178.1006

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
# MIIYGQYJKoZIhvcNAQcCoIIYCjCCGAYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqOpdQp14dt/2+2VCWcZYP2yL
# CWSgghJfMIIE3zCCA8egAwIBAgITfAAAAmjyAgtI2ylKrQAAAAACaDANBgkqhkiG
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
# 8FVopb7RpF3RMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG
# 9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVz
# dGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUD
# xPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1AT
# CyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW
# 1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS
# 8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jB
# ZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCY
# Jn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucf
# WmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLc
# GEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNF
# YLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI
# +RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjAS
# vUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8C
# AQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX
# 44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggr
# BgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDag
# NIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RH
# NC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3
# DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJL
# Kftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgW
# valWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2M
# vGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSu
# mScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJ
# xLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un
# 8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SV
# e+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4
# k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJ
# Dwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr
# 5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBsYw
# ggSuoAMCAQICEAp6SoieyZlCkAZjOE2Gl50wDQYJKoZIhvcNAQELBQAwYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAe
# Fw0yMjAzMjkwMDAwMDBaFw0zMzAzMTQyMzU5NTlaMEwxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5EaWdpQ2VydCwgSW5jLjEkMCIGA1UEAxMbRGlnaUNlcnQgVGltZXN0
# YW1wIDIwMjIgLSAyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAuSqW
# I6ZcvF/WSfAVghj0M+7MXGzj4CUu0jHkPECu+6vE43hdflw26vUljUOjges4Y/k8
# iGnePNIwUQ0xB7pGbumjS0joiUF/DbLW+YTxmD4LvwqEEnFsoWImAdPOw2z9rDt+
# 3Cocqb0wxhbY2rzrsvGD0Z/NCcW5QWpFQiNBWvhg02UsPn5evZan8Pyx9PQoz0J5
# HzvHkwdoaOVENFJfD1De1FksRHTAMkcZW+KYLo/Qyj//xmfPPJOVToTpdhiYmREU
# xSsMoDPbTSSF6IKU4S8D7n+FAsmG4dUYFLcERfPgOL2ivXpxmOwV5/0u7NKbAIqs
# HY07gGj+0FmYJs7g7a5/KC7CnuALS8gI0TK7g/ojPNn/0oy790Mj3+fDWgVifnAs
# 5SuyPWPqyK6BIGtDich+X7Aa3Rm9n3RBCq+5jgnTdKEvsFR2wZBPlOyGYf/bES+S
# AzDOMLeLD11Es0MdI1DNkdcvnfv8zbHBp8QOxO9APhk6AtQxqWmgSfl14ZvoaORq
# DI/r5LEhe4ZnWH5/H+gr5BSyFtaBocraMJBr7m91wLA2JrIIO/+9vn9sExjfxm2k
# eUmti39hhwVo99Rw40KV6J67m0uy4rZBPeevpxooya1hsKBBGBlO7UebYZXtPgth
# Wuo+epiSUc0/yUTngIspQnL3ebLdhOon7v59emsCAwEAAaOCAYswggGHMA4GA1Ud
# DwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6
# FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUjWS3iSH+VlhEhGGn6m8cNo/d
# rw0wWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCB
# kAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNy
# dDANBgkqhkiG9w0BAQsFAAOCAgEADS0jdKbR9fjqS5k/AeT2DOSvFp3Zs4yXgimc
# Q28BLas4tXARv4QZiz9d5YZPvpM63io5WjlO2IRZpbwbmKrobO/RSGkZOFvPiTkd
# cHDZTt8jImzV3/ZZy6HC6kx2yqHcoSuWuJtVqRprfdH1AglPgtalc4jEmIDf7kmV
# t7PMxafuDuHvHjiKn+8RyTFKWLbfOHzL+lz35FO/bgp8ftfemNUpZYkPopzAZfQB
# ImXH6l50pls1klB89Bemh2RPPkaJFmMga8vye9A140pwSKm25x1gvQQiFSVwBnKp
# RDtpRxHT7unHoD5PELkwNuTzqmkJqIt+ZKJllBH7bjLx9bs4rc3AkxHVMnhKSzcq
# TPNc3LaFwLtwMFV41pj+VG1/calIGnjdRncuG3rAM4r4SiiMEqhzzy350yPynhng
# DZQooOvbGlGglYKOKGukzp123qlzqkhqWUOuX+r4DwZCnd8GaJb+KqB0W2Nm3mss
# uHiqTXBt8CzxBxV+NbTmtQyimaXXFWs1DoXW4CzM4AwkuHxSCx6ZfO/IyMWMWGmv
# qz3hz8x9Fa4Uv4px38qXsdhH6hyF4EVOEhwUKVjMb9N/y77BDkpvIJyu2XMyWQjn
# LZKhGhH+MpimXSuX4IvTnMxttQ2uR2M4RxdbbxPaahBuH0m3RFu0CAqHWlkEdhGh
# p3cCExwxggUkMIIFIAIBATBfMEgxCzAJBgNVBAYTAlNFMRQwEgYDVQQKEwtaYW1w
# bGVXb3JrczEjMCEGA1UEAxMaWmFtcGxlV29ya3MgSW50ZXJuYWwgQ0EgdjICE3wA
# AAJo8gILSNspSq0AAAAAAmgwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFZWJdo+l2Ag1qqOOKcQ
# qWmATQ5WMA0GCSqGSIb3DQEBAQUABIIBAAs7JDa9oN/yJSqLxO0KbHlNjitwmU1F
# bscogGrCv0cWRVa9YM51lOWdDXdQH8x3e6rRKMXKGRIbERUiLaY0Yn4fvPuq5Llg
# gndMB4G2N9bBeR9ucJ82KHiHeh3OJLg3/RV8xgwUBHLUBTFsD2ygycN939eAlhXR
# Tpi+JFOeUOAEpb0mTsdW2YpCoFeoW0x7GGOPIghw9fzC7TKN4ZLygrVTuqkHUsLm
# iFOZVezEN6FFIhP31EsaPQIkmWUNtzsu5MQNoQnQvDWuOjJKCMh+aq3kpFLZHfRx
# tBWZy63SQE/RiqeHF7JDjKZyl+HO+pPsMLbWN6k/rpxKVEGIPtkqkzShggMgMIID
# HAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQg
# UlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAKekqInsmZQpAGYzhNhped
# MA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkq
# hkiG9w0BCQUxDxcNMjIwNTIzMDgxNjAwWjAvBgkqhkiG9w0BCQQxIgQgDftqg31J
# 7yBzBJqYnWms9UF8cvFrATPIBAr9FYjguiIwDQYJKoZIhvcNAQEBBQAEggIAcr7g
# 2hB780/1UVJo7d5I63pjI3LKJ/f/m7ibwEyQ3rODBNeNJfVf97u1TKaYqwG6nAoC
# jcPyJF53fZWAb1lwadBV27AQo6SrLjUda39uV6adNHV0bEMxM1bA5OaVwx0yMf4T
# 2VssVhc/Oa3X7OB641nLN2ceFkDo4KoBok2UWu3jKEZp2iRUKtKmyTXARg28CrHW
# lxf2WNYwSdzUSfPamkx1WEhWCo28l5tDwgnp3Ym7xUI95cRqoEKmCpzZ+4N51EUr
# V7GVvQxyao4HGG6GibdjhDHaSa8ttltxuRomXbKwxZ9YiUe4xnYIfiztgbNudPws
# vCNkVVgO3H5Beka+xghi/7OFRmGb/6AJpdl14mmiyOlspuT/5FFvNnIyKG3rzhYZ
# 7fc+0MqR7L8FSMs+8fwJ/cUKFJsDdHZFPzrbBo5e42RGgfTAPM+0hX/w9GnVNc8D
# nDAUkZSFAw2vWyJD+Be9kDIkCgl41flyHx0lYAabwDbP3VXsZxge4Dk0t6CK/iFP
# Ik9vmGoWvPCM0TGQRgv5EFUSbmx/ykb7ZmpaijzxcbyCf0EWAZ9Vjcbvgs8KCZiB
# o/X+w5CXzp555xbELClgK7Bab55wyJxb0GG0yUPzVrsyYtaDvsW8kSNLbRc99wZ7
# keVzPpD2FPHnl+M53zOLTSh3A4YdCNQF6LPTKdk=
# SIG # End signature block
