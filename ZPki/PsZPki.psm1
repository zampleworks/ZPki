﻿#Requires -Version 4

. $PSScriptRoot\ZPki-Functions.ps1
. $PSScriptRoot\ZPki-External.ps1

Export-ModuleMember -Function Install-ZPkiCa
Export-ModuleMember -Function Install-ZPkiCaCertificate
Export-ModuleMember -Function New-ZPkiRepoIndex
Export-ModuleMember -Function New-ZPkiWebsite
Export-ModuleMember -Function Copy-ZPkiCertSrvFilesToRepo
Export-ModuleMember -Function Publish-ZPkiCaDsFile
Export-ModuleMember -Function Set-ZPkiCaPostInstallConfig
Export-ModuleMember -Function Set-ZPkiCaUrlConfig
Export-ModuleMember -Function New-ZPkiCaBackup
Export-ModuleMember -Function New-ZPkiRepoCssFile
Export-ModuleMember -Function New-ZPkiRandomPassword
Export-ModuleMember -Function Submit-ZPkiRequest
Export-ModuleMember -Function Get-ZPkiLocalCaConfigString
Export-ModuleMember -Function Remove-ZPkiAdIssuancePolicyGroupLink
Export-ModuleMember -Function Set-ZPkiAdIssuancePolicyGroupLink
Export-ModuleMember -Function Get-ZPkiAdIssuancePolicyGroupLinks
Export-ModuleMember -Function Get-ZPkiAdIssuancePolicy
Export-ModuleMember -Function Set-ZPkiAdAltSecurityIdentities
Export-ModuleMember -Function Install-ZPkiRsatComponents
# SIG # Begin signature block
# MIIYGQYJKoZIhvcNAQcCoIIYCjCCGAYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlcW01wv2LLedHybgQcc6Dd/I
# s6ugghJfMIIE3zCCA8egAwIBAgITfAAAAmjyAgtI2ylKrQAAAAACaDANBgkqhkiG
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFGtuk+tchbvm2v6g2ssP
# +4MBMYcmMA0GCSqGSIb3DQEBAQUABIIBAN0cfzF1rxWjNHH3YJDX4nL1FVm5d50X
# b5eKvIsW2Dv//qyRPnekehkLEO4XoJup7puSQrcdODFbckR7g2ObM+MVpurv1qpj
# ic6Dyg/1V4t5cMPVpaa0lbuoNDiHmw0KrTBQWJ3Uimm1rigdGPSJ8XXLvqwaD5SX
# RVXDG+lo7gD72EvzsXd230XM9/uwHJIio1Fracs0zm41K7kbekBmojXWLmcJtQ0X
# 1+n23nazyiOg4T24D8XuUdxEtDezDf1iwoSoZjhe6NFqM4VENECq9+ApsByTmPac
# NjaPH7+DvqmLCSuJ/QsITzd5+DLhffUcxXThtV4IWWX+Fq0zquCMXi+hggMgMIID
# HAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQg
# UlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAKekqInsmZQpAGYzhNhped
# MA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkq
# hkiG9w0BCQUxDxcNMjIwNTEyMDY1MTMzWjAvBgkqhkiG9w0BCQQxIgQgIW/hinr2
# 2w5j1EC8LGqmR5+EOqj53Ge2g6ybpZaGo3EwDQYJKoZIhvcNAQEBBQAEggIAhu5L
# qyXwMOYoT1dPF2lZ4pi5sqn+TTNUoIfWbd2ggjWzSVTwefMdOH8kxdxrYwy+1KZU
# 9WmIoALmYRngS8W4gGJ73/qepvQDbWsRgWDRTqBkLvOmvHNTKRa8pKkrNC+K37i+
# JQbA+g+InoEfG/VH5ADHK6xcHguUrhdo3tJxYNBRlN8lvvQhpVX3U2Y/YsWJt+7D
# w8dYkQhddQMsbKozLBEql9ucqSj4k8Sr1mSL+HJia9kEoR1GwRxcsF9BqFHKsHvd
# WUQ6SMZVeJyJdVf4juKYvnGuFwASm75DcQ4WAqzyH9OhVcqiM8N6g22e08AZFnhK
# RPR5uNR3WjryyL3MtHsAqOb4t6DKlHnRZlK9QhL+GbM+A23DjeetvAJYzUoYc+sG
# WLzI+PeW159Yzjc0iRNtdjdj/wXXEGeJlxJIR0CjmyceqZUvXNzWqM1NANikANzU
# OnCQGQCeior+Eo5a5SV0z7KqEOSxxxA34GTsQU+ehaUKB5XShiDUm3gdzzL87tQ3
# dQ+ojDaKX2Jpp6VXIC7JO5nPi+eIA3sYjUZe0bfTdu9+b/k2YruhaPlZH4LyONDo
# WV1XXCjhXlmosvN2HHCFmXmoZOWpwgCgl+KN6R1lh/kDzKtVsYQ3tp33mlfrxGWZ
# XkMw2SH5EXwwHx/GEaX6jd7rp0caB3v3ABXsX+4=
# SIG # End signature block
