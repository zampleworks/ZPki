<#
  .SYNOPSIS
  This script uses the ZPki module to install and configure
  a standalone subordinate CA.

  .NOTES
  Author anders !A!T! runesson D"O"T info
#>

[CmdletBinding()]
Param()

$ErrorActionPreference = "Stop"

#Requires -RunAsAdministrator
#Requires -Version 4
#Requires -Modules ZPki

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
        $RoutableIpv6 = Get-NetIPConfiguration | Where-Object { $_.IPv6DefaultGateway -ne $Null } | Select-Object -First 1
        
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
