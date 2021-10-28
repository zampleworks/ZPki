<#
  .SYNOPSIS
  This script will install the ZPki module. By default it installs into the current users's 
  profile. Use the -Systemwide switch to install for all users.
#>
[CmdletBinding(SupportsShouldProcess,
        ConfirmImpact = 'High')]
Param(
    [switch]
    $SystemWide
)

$Module = "ZPki"

$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot

Try {
    Write-Verbose "Unblocking files.."
    Get-ChildItem -Recurse -Filter * | Unblock-File -Confirm:$false
} Catch {
    Write-Warning "Could not unblock files. You may need to run the unblock command manually: `nGet-ChildItem -Recurse -Filter * | Unblock-File -Confirm:`$false -Verbose"
}

$PsmPaths = $env:PSModulePath -split ";"

$UserModulesDir = $PsmPaths | Where-Object { $_ -like "*$HOME*" } | Select-Object -First 1
$SystemModulesDir = $PsmPaths | Where-Object { $_ -like "*$env:ProgramFiles*" } | Select-Object -First 1

If($SystemWide) {
    $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList ([Security.Principal.WindowsIdentity]::GetCurrent())
    If(-Not $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "Installing system-wide requires admin privileges! Run the script again as admin to install system wide."
    }
    $ModulesDir = $SystemModulesDir
} Else {
    $ModulesDir = $UserModulesDir
}

If((Test-Path "$SystemModulesDir\ZPki") -and (Test-Path "$UserModulesDir\ZPki")) {
    Write-Warning "The ZPki module is installed both system-wide and in the current user's profile. Both should be upgraded to avoid confusion."
    Write-Warning "System wide install path: $SystemModulesDir\ZPki"
    Write-Warning "Current user install path: $UserModulesDir\ZPki"
}

$ZModuleDir = "$ModulesDir\$Module"

If(Test-Path $ZModuleDir) {
    If(-Not $PSCmdlet.ShouldProcess("ZPki", "Remove previous installation")) {
        Write-Verbose "You chose not to proceed. exiting installation"
        return
    }
}

Try {
    If(Test-Path $ZModuleDir) {
        rm $ZModuleDir -Recurse -Force
    }

    If(-Not (Test-Path $ModulesDir -PathType Container)) {
        mkdir $ModulesDir | Out-Null
    }

    cp .\ZPki $ModulesDir -Recurse | Out-Null
    
    If($SystemWide) {
        Write-Verbose "Done installing $Module module system wide!"
    } Else {
        Write-Verbose "Done installing $Module module to current user's profile!"
    }
    Pop-Location
} Catch {
    Pop-Location
    Write-Host $_.Exception.Message -ForegroundColor red
    $_.Exception
    Read-Host "press play on tape"
}
# SIG # Begin signature block
# MIIT5AYJKoZIhvcNAQcCoIIT1TCCE9ECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/7lNBIePXELN9eLbnlkXrAXL
# /Feggg8aMIIE3zCCA8egAwIBAgITfAAAAmjyAgtI2ylKrQAAAAACaDANBgkqhkiG
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
# KoZIhvcNAQkEMRYEFERvVqmYboJjMfqL8MaL/eHHhdgmMA0GCSqGSIb3DQEBAQUA
# BIIBALWlZyRTAvPJVDzH9K9xUV607aasUCZgJAO+mYq7YMfRRF+K1jEv44px90fL
# 8AJHRBHSLLAwmrP0wGSGJM/V/QQ7PyXKD4YlTyE2R9FAZTsDbOga98YLS48xlUF5
# dHGTkkN8Oxn4U6g/edGuqoB4fcaSiesJKMMu4N92a6mIKdiufW9rUlekvnbW9FmM
# H6hM2z5J9M3m3me0KxNBDJShOBGRvPACE1/tSapfvXKOfgIkExWnZOojGIDT/LF3
# W7hIGor2CwijRuy1zQGAHF06IL1kvGh9RbasMYMm+PxP8Tkcm5vCk7icNYPMP2Q6
# cpyhT3VR+z8kmxLVjeFUME0I8I2hggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkC
# AQEwgYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBB
# c3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglg
# hkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcN
# AQkFMQ8XDTIxMTAyMjA4NTcxNFowLwYJKoZIhvcNAQkEMSIEINpHt5XEQKN5gnl6
# CK3ZrqZl4Eb0OlCf6rbc04Dod5eoMA0GCSqGSIb3DQEBAQUABIIBAIT2Rf7QPxyD
# cEknaoX+TSYQHRiSP6ptClzeghmORFAjplVHfgbRzthUpQW8wJGAjo6HaplIY73C
# Miwu85QdX9o8CwHR1swo7Pmf3stJYsAs/YXXWFg5M88qmKC2Wkc71/3+dKh61Ebl
# K//dZivY4JyU7TvqThDxa5DEu+6mULhk5QiL3AFG1iXZovfDbxSshk+8tb1wuFge
# Q/fjNc5qPqhuLkZyL2Pfi6zGt1aKIOeRBF99UnPDFhzjoqMUSq2zYNWrj5/chnub
# NaJJn/2S//oR1tVQ6ndPr0L2xDpn/6DeZDs2zH6bYtIaG5vloWERMBBe2g/w1wJV
# M+QYe6PmPoQ=
# SIG # End signature block
