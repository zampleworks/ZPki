[CmdletBinding()]
Param()

$ErrorActionPreference = "Stop"

Import-Module .\ZPki.psm1

Write-Progress -Activity "Installing ADCS tools and DNS Server tools.."

Install-WindowsFeature RSAT-Ad-Tools | Out-Null
Install-WindowsFeature RSAT-DNS-Server | Out-Null

Write-Progress -Activity "Gathering AD Forest info"

$AdForestDns = Get-ADForest -Current LocalComputer | Select -ExpandProperty RootDomain
$RootDomain = Get-ADDomain $AdForestDns -Server $AdForestDns
$RootDomainNbName = $RootDomain.NetBIOSName
$EaGroup = "$RootDomainNbName\Enterprise Admins"
$EnterpriseAdmin = (whoami -groups | Where-Object { $_ -like "*$EaGroup*" } | Measure-Object | Select -ExpandProperty Count) -eq $True

If(-Not $EnterpriseAdmin) {
    Write-Error "You must be a member of $EaGroup to install an Enterprise Root CA."
}

Write-Progress -Activity "Creating DNS record for HTTP"

$HttpFqdn = "pki.$AdForestDns"

$RoutableIpv4 = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $Null } | Select -First 1
$RoutableIpv6 = Get-NetIPConfiguration | Where-Object { $_.IPv6DefaultGateway -ne $Null } | Select -First 1

If($RoutableIpv4) {
    Add-DnsServerResourceRecordA -Name "$HttpFqdn." -IPv4Address $RoutableIpv4.IPv4Address.IPAddress -ZoneName $AdForestDns -ComputerName $AdForestDns
}

Write-Progress -Activity "Running CA installation script"
Install-ZPkiCa -CaType EnterpriseRootCA -EnableBasicConstraints -BasicConstraintsIsCritical -IncludeAllIssuancePolicy

Write-Progress -Activity "Running CA post config"
Set-ZPkiCaPostInstallConfig -InstallWebCdp -HttpCdpFqdn $HttpFqdn -RestartCertSvc

Write-Progress -Activity "Updating CA CDP/AIA information"
Set-ZPkiCaUrlConfig -ClearCDPs -ClearAIAs
Set-ZPkiCaUrlConfig -HttpCdpFqdn $HttpFqdn -AddFileCdp
Set-ZPkiCaUrlConfig -HttpAiaFqdn $HttpFqdn

Write-Progress -Activity "Generating content for AIA/CDP Web site"
New-ZPkiRepoIndex -Sourcepath C:\ADCS\Web\Repository\ -IndexFile C:\ADCS\Web\index.html -CssFiles "style.css"
New-ZPkiRepoCssFile -CssFile C:\ADCS\Web\style.css
