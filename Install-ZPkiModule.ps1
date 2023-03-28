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

If([System.Environment]::OSVersion.Platform -eq "Windows") {
    $PsmPaths = $env:PSModulePath -split ";"
} Else {
    $PsmPaths = $env:PSModulePath -split ":"
}

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
        Remove-Item $ZModuleDir -Recurse -Force
    }

    If(-Not (Test-Path $ModulesDir -PathType Container)) {
        mkdir $ModulesDir | Out-Null
    }

    Copy-Item -Path .\ZPki -Destination $ModulesDir -Recurse | Out-Null
    
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
# MIIc9gYJKoZIhvcNAQcCoIIc5zCCHOMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdCrQn+4bcGrYprVRqO8uJSSo
# yl6gghc8MIIEBzCCA6ygAwIBAgITMQAAAAaig5eyJWRoJAAAAAAABjAKBggqhkjO
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
# AJfalg8eOYZUmEFuN4ZerSzIXP0hOc6kzFjRK35jg0OBMIIFsTCCBJmgAwIBAgIQ
# ASQK+x44C4oW8UtxnfTTwDANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwNjA5
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
# o4IBXjCCAVowDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5n
# P+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHkGCCsGAQUFBwEBBG0wazAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAC
# hjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwIAYDVR0gBBkwFzAIBgZn
# gQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBDAUAA4IBAQCaFgKlAe+B+w20
# WLJ4ragjGdlzN9pgnlHXy/gvQLmjH3xATjM+kDzniQF1hehiex1W4HG63l7GN7x5
# XGIATfhJelFNBjLzxdIAKicg6okuFTngLD74dXwsgkFhNQ8j0O01ldKIlSlDy+Cm
# WBB8U46fRckgNxTA7Rm6fnc50lSWx6YR3zQz9nVSQkscnY2W1ZVsRxIUJF8mQfoa
# Rr3esOWRRwOsGAjLy9tmiX8rnGW/vjdOvi3znUrDzMxHXsiVla3Ry7sqBiD5P3Lq
# NutFcpJ6KXsUAzz7TdZIcXoQEYoIdM1sGwRc0oqVA3ZRUFPWLvdKRsOuECxxTLCH
# tic3RGBEMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0B
# AQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVk
# IFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYD
# VQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lD
# ZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKR
# N6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZz
# lm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1Oco
# LevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH
# 92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRA
# p8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+g
# GkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU
# 8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/
# FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwj
# jVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQ
# EgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUae
# tdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAw
# HQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LS
# cV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYy
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5j
# cmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEB
# CwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftw
# ig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalW
# zxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQm
# h2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScb
# qyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLaf
# zYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbD
# Qc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0K
# XzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm
# 8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9
# gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8a
# pIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBsYwggSu
# oAMCAQICEAp6SoieyZlCkAZjOE2Gl50wDQYJKoZIhvcNAQELBQAwYzELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2Vy
# dCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAeFw0y
# MjAzMjkwMDAwMDBaFw0zMzAzMTQyMzU5NTlaMEwxCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5EaWdpQ2VydCwgSW5jLjEkMCIGA1UEAxMbRGlnaUNlcnQgVGltZXN0YW1w
# IDIwMjIgLSAyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAuSqWI6Zc
# vF/WSfAVghj0M+7MXGzj4CUu0jHkPECu+6vE43hdflw26vUljUOjges4Y/k8iGne
# PNIwUQ0xB7pGbumjS0joiUF/DbLW+YTxmD4LvwqEEnFsoWImAdPOw2z9rDt+3Coc
# qb0wxhbY2rzrsvGD0Z/NCcW5QWpFQiNBWvhg02UsPn5evZan8Pyx9PQoz0J5HzvH
# kwdoaOVENFJfD1De1FksRHTAMkcZW+KYLo/Qyj//xmfPPJOVToTpdhiYmREUxSsM
# oDPbTSSF6IKU4S8D7n+FAsmG4dUYFLcERfPgOL2ivXpxmOwV5/0u7NKbAIqsHY07
# gGj+0FmYJs7g7a5/KC7CnuALS8gI0TK7g/ojPNn/0oy790Mj3+fDWgVifnAs5Suy
# PWPqyK6BIGtDich+X7Aa3Rm9n3RBCq+5jgnTdKEvsFR2wZBPlOyGYf/bES+SAzDO
# MLeLD11Es0MdI1DNkdcvnfv8zbHBp8QOxO9APhk6AtQxqWmgSfl14ZvoaORqDI/r
# 5LEhe4ZnWH5/H+gr5BSyFtaBocraMJBr7m91wLA2JrIIO/+9vn9sExjfxm2keUmt
# i39hhwVo99Rw40KV6J67m0uy4rZBPeevpxooya1hsKBBGBlO7UebYZXtPgthWuo+
# epiSUc0/yUTngIspQnL3ebLdhOon7v59emsCAwEAAaOCAYswggGHMA4GA1UdDwEB
# /wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAG
# A1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6Ftlt
# TYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUjWS3iSH+VlhEhGGn6m8cNo/drw0w
# WgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYI
# KwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0
# LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDAN
# BgkqhkiG9w0BAQsFAAOCAgEADS0jdKbR9fjqS5k/AeT2DOSvFp3Zs4yXgimcQ28B
# Las4tXARv4QZiz9d5YZPvpM63io5WjlO2IRZpbwbmKrobO/RSGkZOFvPiTkdcHDZ
# Tt8jImzV3/ZZy6HC6kx2yqHcoSuWuJtVqRprfdH1AglPgtalc4jEmIDf7kmVt7PM
# xafuDuHvHjiKn+8RyTFKWLbfOHzL+lz35FO/bgp8ftfemNUpZYkPopzAZfQBImXH
# 6l50pls1klB89Bemh2RPPkaJFmMga8vye9A140pwSKm25x1gvQQiFSVwBnKpRDtp
# RxHT7unHoD5PELkwNuTzqmkJqIt+ZKJllBH7bjLx9bs4rc3AkxHVMnhKSzcqTPNc
# 3LaFwLtwMFV41pj+VG1/calIGnjdRncuG3rAM4r4SiiMEqhzzy350yPynhngDZQo
# oOvbGlGglYKOKGukzp123qlzqkhqWUOuX+r4DwZCnd8GaJb+KqB0W2Nm3mssuHiq
# TXBt8CzxBxV+NbTmtQyimaXXFWs1DoXW4CzM4AwkuHxSCx6ZfO/IyMWMWGmvqz3h
# z8x9Fa4Uv4px38qXsdhH6hyF4EVOEhwUKVjMb9N/y77BDkpvIJyu2XMyWQjnLZKh
# GhH+MpimXSuX4IvTnMxttQ2uR2M4RxdbbxPaahBuH0m3RFu0CAqHWlkEdhGhp3cC
# ExwxggUkMIIFIAIBATBfMEgxCzAJBgNVBAYTAlNFMRQwEgYDVQQKEwtaYW1wbGVX
# b3JrczEjMCEGA1UEAxMaWmFtcGxlV29ya3MgSW50ZXJuYWwgQ0EgdjMCEzEAAAAG
# ooOXsiVkaCQAAAAAAAYwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKA
# AKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFEkwWGb3ZdX09mk5c9w4/wGK
# qfeHMA0GCSqGSIb3DQEBAQUABIIBANIoA399WAytn5VdKLRI376mx6Jywe3R4jGa
# D206OMPJlhM/SB5bX5CPh6n2NRnbk4X6vjeZqoYPvT1UDMXPKJ6IUxkIFcXYn4tU
# 0jMyrYIvEtjn6QtKOE3XJahKUxSI0KriLBuYRxMjw6a1J0hsLIFQAXYC9wdBCfZ5
# V38tRVnlqmY6kPhtpGxZaXXCGWP5be2ug/EUgnEjalSICoRorL64RRZfx1LxuhsO
# oINhG/cNdLufGBERKIaM0FKHozQ80e3edbVGW2SaD6HHJy6bgCVqwdZN8I3IKPPU
# AAJdPxxNqaPDYdqKV1eVuVQHnzrFUV7MbHHL3crRpuCJ9u53+0ShggMgMIIDHAYJ
# KoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNB
# NDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAKekqInsmZQpAGYzhNhpedMA0G
# CWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG
# 9w0BCQUxDxcNMjIwNjI5MTIyNTE1WjAvBgkqhkiG9w0BCQQxIgQg25CNSmvdKe4y
# myYJ7sx3WjmCy6nJerCBXs/k7QEh1PEwDQYJKoZIhvcNAQEBBQAEggIAAxLL8BJW
# 4YbW0sBQW7xPc+eWaAVKRfc+ysSVv51Dzj7A0bNd+b8rKaLkjcb+jEJAHJLvsve6
# nRz9s1RCPtMIhOIvtyqjV/3pG0XuJCYqvjLpgYzdFCfn04Bd7PhnJUkYW3BX0wut
# EYWjknmIag3AlHlc9OvNh7q0VxxYfDIZR/v2SlPoESZITqrD6F1I2Sk1u8E3gV62
# MmggD0A6+GZvuYuKxqUPmAtHeV+cTFzde0OBGvAeQIr5Xb17hbGFGHHhqw/JimXV
# B/b50BItUidjaJj1g60YBr1eWe8SYb5g2EeaEYr4+mWspp4GzAJgJ8sfPE1oD9H6
# CbUy8vg/kecJ/zISpWKL4FfNgmWYRBu8Wi5VWKz16kl1oEfhg2B3aueiuua286kb
# MNab/n/eVwOIy6uRnN9Ylgrvm9f7Pj+v1ct7VXw/8yQhKdg3g6mrHmTWhJzRP3v6
# bFv4HoK6bwt4UWnqMgDl/pWjbziPJnC3IHGoq62DIUheaMEovd4te4TB8vHPuZe0
# gtpSxpXQOJ+1IKYZQvwusmzOs6BRroZ/YU65RfpIssmh8kxIGi6ebVB2HcNh7kos
# tlLLSiizdK+EPDfbyDEJIUnFib3m/GhaFTrG2EhbNMh+MRj91JtzlYf5Lk+Iu/bo
# Kfh8jV56NBnxkEQZjZAh53aSnMpXQEy941s=
# SIG # End signature block
