<#PSScriptInfo

.VERSION 0.1.9.3

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
# MIIczAYJKoZIhvcNAQcCoIIcvTCCHLkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtL+OEd2iUXeOO5KnUaP5mc7+
# JnKgghcSMIIEBzCCA6ygAwIBAgITMQAAAAaig5eyJWRoJAAAAAAABjAKBggqhkjO
# PQQDAjBIMQswCQYDVQQGEwJTRTEUMBIGA1UEChMLWmFtcGxlV29ya3MxIzAhBgNV
# BAMTGlphbXBsZVdvcmtzIEludGVybmFsIENBIHYzMB4XDTIyMDYyMzE3MTgwMloX
# DTIzMDYyMzE3MTgwMlowGjEYMBYGA1UEAxMPQW5kZXJzIFJ1bmVzc29uMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA570cFxi6rW2B1kjF7vdfpfsyUC0g
# cztkNGOsWdQQWSyyIOQa7Pj/iva9qJOpXgGCKVmI5JVD0h3UHdDBuTrsYZ2qNZiK
# XQpa3y+oWDjFnxUwuW6mPGv2L98tG3G1reINcPPfJIblHc3UqqrjzgKMpx8wijXC
# 0+zKaRb8gp8argwqv1dVEZkEGjSoi86YauRALWBI0Z2FplzgLSDcFYMFeEzka20v
# U42sO3POrdP+BN6Woiv87h04BepcFdkoYtbuzJDCfA2wgwc9A0DnDbHCgjbtmkcR
# GckJOzXh7SNypex++DHvQTCKgn2GZkmsx5Nudpz09aEYjWRClu45Oj2fOQIDAQAB
# o4IB1jCCAdIwPgYJKwYBBAGCNxUHBDEwLwYnKwYBBAGCNxUIhb31ToL5uhOGvZce
# h8eaKYeL30SBZIb4qhWEotFXAgFlAgECMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4G
# A1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1Ud
# DgQWBBTfjZA5S5YyR9Zc/wnR940dXISNvjAfBgNVHSMEGDAWgBTcnJy/9vjUCSFq
# nt0GjbrUATwUNjBiBggrBgEFBQcBAQRWMFQwUgYIKwYBBQUHMAKGRmh0dHA6Ly9w
# a2kub3Auendrcy54eXovUmVwb3NpdG9yeS9aYW1wbGVXb3JrcyUyMEludGVybmFs
# JTIwQ0ElMjB2My5jcnQwWwYDVR0RBFQwUqAvBgorBgEEAYI3FAIDoCEMH0FuZGVy
# cy5SdW5lc3NvbkB6YW1wbGV3b3Jrcy5jb22BH0FuZGVycy5SdW5lc3NvbkB6YW1w
# bGV3b3Jrcy5jb20wTQYJKwYBBAGCNxkCBEAwPqA8BgorBgEEAYI3GQIBoC4ELFMt
# MS01LTIxLTE2OTAwNzU1NC01NjE1NTU1ODMtMzQ2NTg3MDA2NS0xNTE2MAoGCCqG
# SM49BAMCA0kAMEYCIQCEN3STU0FB2cY6DaISc5cb5G7YOJ/4wyDBRBfWatnIaQIh
# AJfalg8eOYZUmEFuN4ZerSzIXP0hOc6kzFjRK35jg0OBMIIFjTCCBHWgAwIBAgIQ
# DpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwODAx
# MDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQD
# ExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aa
# za57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllV
# cq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT
# +CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd
# 463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+
# EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92k
# J7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5j
# rubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7
# f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJU
# KSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/Y+wh
# X8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQAB
# o4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5n
# P+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0P
# AQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+MDww
# OqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJ
# RFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUAA4IB
# AQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSId229
# GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n096wwepqLsl7Uz9FD
# RJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxAGTVG
# amlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9vytsgjTVgHAIDyyCw
# rFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW/VvR
# XKwYw02fc7cBqZ9Xql4o4rmUMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBsAwggSooAMCAQICEAxNaXJLlPo8Kko9KQeAPVowDQYJKoZIhvcNAQEL
# BQAwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQTAeFw0yMjA5MjEwMDAwMDBaFw0zMzExMjEyMzU5NTlaMEYxCzAJBgNV
# BAYTAlVTMREwDwYDVQQKEwhEaWdpQ2VydDEkMCIGA1UEAxMbRGlnaUNlcnQgVGlt
# ZXN0YW1wIDIwMjIgLSAyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# z+ylJjrGqfJru43BDZrboegUhXQzGias0BxVHh42bbySVQxh9J0Jdz0Vlggva2Sk
# /QaDFteRkjgcMQKW+3KxlzpVrzPsYYrppijbkGNcvYlT4DotjIdCriak5Lt4eLl6
# FuFWxsC6ZFO7KhbnUEi7iGkMiMbxvuAvfTuxylONQIMe58tySSgeTIAehVbnhe3y
# YbyqOgd99qtu5Wbd4lz1L+2N1E2VhGjjgMtqedHSEJFGKes+JvK0jM1MuWbIu6pQ
# OA3ljJRdGVq/9XtAbm8WqJqclUeGhXk+DF5mjBoKJL6cqtKctvdPbnjEKD+jHA9Q
# Bje6CNk1prUe2nhYHTno+EyREJZ+TeHdwq2lfvgtGx/sK0YYoxn2Off1wU9xLokD
# EaJLu5i/+k/kezbvBkTkVf826uV8MefzwlLE5hZ7Wn6lJXPbwGqZIS1j5Vn1TS+Q
# Hye30qsU5Thmh1EIa/tTQznQZPpWz+D0CuYUbWR4u5j9lMNzIfMvwi4g14Gs0/EH
# 1OG92V1LbjGUKYvmQaRllMBY5eUuKZCmt2Fk+tkgbBhRYLqmgQ8JJVPxvzvpqwcO
# agc5YhnJ1oV/E9mNec9ixezhe7nMZxMHmsF47caIyLBuMnnHC1mDjcbu9Sx8e47L
# ZInxscS451NeX1XSfRkpWQNO+l3qRXMchH7XzuLUOncCAwEAAaOCAYswggGHMA4G
# A1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUF
# BwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAW
# gBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUYore0GH8jzEU7ZcLzT0q
# lBTfUpwwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNy
# bDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NB
# LmNydDANBgkqhkiG9w0BAQsFAAOCAgEAVaoqGvNG83hXNzD8deNP1oUj8fz5lTmb
# Jeb3coqYw3fUZPwV+zbCSVEseIhjVQlGOQD8adTKmyn7oz/AyQCbEx2wmIncePLN
# fIXNU52vYuJhZqMUKkWHSphCK1D8G7WeCDAJ+uQt1wmJefkJ5ojOfRu4aqKbwVNg
# CeijuJ3XrR8cuOyYQfD2DoD75P/fnRCn6wC6X0qPGjpStOq/CUkVNTZZmg9U0rIb
# f35eCa12VIp0bcrSBWcrduv/mLImlTgZiEQU5QpZomvnIj5EIdI/HMCb7XxIstiS
# DJFPPGaUr10CU+ue4p7k0x+GAWScAMLpWnR1DT3heYi/HAGXyRkjgNc2Wl+WFrFj
# DMZGQDvOXTXUWT5Dmhiuw8nLw/ubE19qtcfg8wXDWd8nYiveQclTuf80EGf2JjKY
# e/5cQpSBlIKdrAqLxksVStOYkEVgM4DgI974A6T2RUflzrgDQkfoQTZxd639ouiX
# dE4u2h4djFrIHprVwvDGIqhPm73YHJpRxC+a9l+nJ5e6li6FV8Bg53hWf2rvwpWa
# SxECyIKcyRoFfLpxtU56mWz06J7UWpjIn7+NuxhcQ/XQKujiYu54BNu90ftbCqhw
# fvCXhHjjCANdRyxjqCU4lwHSPzra5eX25pvcfizM/xdMTQCi2NYBDriL7ubgclWJ
# LCcZYfZ3AYwxggUkMIIFIAIBATBfMEgxCzAJBgNVBAYTAlNFMRQwEgYDVQQKEwta
# YW1wbGVXb3JrczEjMCEGA1UEAxMaWmFtcGxlV29ya3MgSW50ZXJuYWwgQ0EgdjMC
# EzEAAAAGooOXsiVkaCQAAAAAAAYwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFBA7e0DWd2TD5q/2
# sfEd50K1kD08MA0GCSqGSIb3DQEBAQUABIIBALVd92fnglVIu7w65VCja1B7uMps
# WJHIS9YfnIYO8EPW9h/GtSG0UTtijRSznyVUI+vImpRxi42oHVIXY95AX11fXgvm
# QtDVocQIuMJOC2DBMVZrrvQr46Pje1N68OGgFTh68xOdZYIIs9DgVaH3iUlMYaam
# 4Jx2gPaHiQL6TnvvyDU/3Jd4J2uTYkNuU/C2jE1UqYr6JsCQTKG6Dd32XMuHFCE9
# x0RlC7HWc+HQeqx7B1+zpHjM+bTOs4W265RLJKJ3KnRkVtFgByxWTuEm7PsjksVw
# W3s2whrBGrfh4Kn+7cffc1G5O7RV/TvoB5WtUB4nFK6aGBnUKw+rEA2kWsGhggMg
# MIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQg
# RzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAMTWlyS5T6PCpKPSkH
# gD1aMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAc
# BgkqhkiG9w0BCQUxDxcNMjMwMTEzMDkzNjA1WjAvBgkqhkiG9w0BCQQxIgQgIukY
# arJimuRGhYXkawsxV00j2Sj7n+YpBD1YpRDYXcAwDQYJKoZIhvcNAQEBBQAEggIA
# FSkIhM6/k+RbSdI8OB70g8SPp0okz5dfTIL3eF3xtMRpr6mhwLRK6nr5uBcwl2aV
# vDBsXVdPis+q/yC6MOOfWBOAgzEvrZji8lvtliRWNndI/08nGSoAqcuWeDHadpKA
# 7s91UVEoEw8V8iN1nRsT/HiuqoI+tdlEGOJGhiaK4ExFeHpvJN0Y83aD/8TtALPj
# 47gHtr61hlGnSJ5oIGxwJD6EqNO2tgIsKHvfN0LC5hXrJfXmxyjfxJZJiQ/RF8GU
# hobqlcxJb/q6Ha8kRRBQJulfxECe7zjKgnTMLp3YtokKImaEluILL1bZZGfGGBjx
# 5Zw1JpGPRfziN0q+Ykz8R3p505+Lk7UmKnKH6dZ9dk24wM7zT6TdmyaGAjeVdznb
# q3u0jcVudtZ30zeM8NEwxrOErbexyDs20ULP5S+UiTaTp6tqMrSraVL/w4NR47rl
# 7oEE497I0xOJb/1LUKdUhG9/4YgzpBdVtWFZp7lJYN3KplkfzYl8Q7WsW2Sxk36P
# 17mizMs7hDELkf4wu8Sf4bP4MFJsDn/7uymcqMusjTbngrl+Oya/iguYvAr07AGI
# x6/3n3eu0i9t193c7itQAin69srovC7wdFbs41X38/ZSP7/vEhZDKaJYTqCEAP0G
# 9HaVt0MNKeCi1gsEvTGHJ72JZLU6Ep2WCnhdI8EhFE4=
# SIG # End signature block
