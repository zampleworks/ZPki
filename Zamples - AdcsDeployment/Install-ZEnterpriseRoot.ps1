<#
  .SYNOPSIS
  This script uses the ZPki module to install and configure
  an Active Directory-integrated root ('Enterprise Root') CA.

  .NOTES
  Author anders !A!T! runesson D"O"T info
#>

[CmdletBinding()]
Param()

#Requires -RunAsAdministrator
#Requires -Version 4
#Requires -Modules ZPki

$ErrorActionPreference = "Stop"

Import-Module ZPki

# FQDN for AIA & CDP Web site 
$HttpFqdn = "pki.zampleworks.com"

Write-Progress -Activity "Installing ADCS tools and DNS Server tools.."

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

<#
 Automatically creating DNS record requires permission on DNS server and RPC access to DNS server.
#>
Write-Progress -Activity "Creating DNS record for HTTP"

$RoutableIpv4 = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $Null } | Select-Object -First 1
$RoutableIpv6 = Get-NetIPConfiguration | Where-Object { $_.IPv6DefaultGateway -ne $Null } | Select-Object -First 1

If($RoutableIpv4) {
    Add-DnsServerResourceRecordA -Name "$HttpFqdn." -IPv4Address $RoutableIpv4.IPv4Address.IPAddress -ZoneName $AdForestDns -ComputerName $AdForestDns
}

Write-Progress -Activity "Installing AIA/CDP web site"
New-ZPkiWebsite -HttpFqdn $HttpFqdn -Verbose

Write-Progress -Activity "Installing CA service"
Install-ZPkiCa -CaType EnterpriseRootCA -CryptoProvider "ECDSA_P256#Microsoft Software Key Storage Provider" -KeyLength 256

Write-Progress -Activity "Running CA post config"
Set-ZPkiCaPostInstallConfig

Write-Progress -Activity "Updating CA CDP/AIA information"
Set-ZPkiCaUrlConfig -ClearCDPs -ClearAIAs
Set-ZPkiCaUrlConfig -HttpCdpFqdn $HttpFqdn -AddFileCdp
Set-ZPkiCaUrlConfig -HttpAiaFqdn $HttpFqdn

Write-Progress -Activity "Generating content for AIA/CDP Web site"
New-ZPkiRepoIndex -Sourcepath C:\ADCS\Web\Repository\ -IndexFile C:\ADCS\Web\index.html -CssFiles "style.css"
New-ZPkiRepoCssFile -CssFile C:\ADCS\Web\style.css
