<#
  .SYNOPSIS
  This script uses the ZPki module to install and configure an Enterprise subordinate CA.

  .DESCRIPTION
  This script shows you how to install a subordinate AD-integrated CA.
  This is an 'extra everything' script. It will (try to) register DNS
  records for a HTTP CDP, install a web site on the local machine to
  host CDP/AIA and generate the web site contents.

  Procedure
  1. Check access - you must have local admin and Enterprise Admin permissions
  2. Install AD and DNS tools
  This script will try to publish the Root CA certificate in AD
  before configuring the local CA service. 

  Prerequisites:
  1. You must already have installed a root CA
  2. You need the root CA certificate and CRL file available.

  .NOTES
  Author anders !Ä!T! runesson D"Ö"T info
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

$CaCommonName = "ZampleWorks PKI v1 Issuing CA 1"

$AdcsRootDir = "C:\ADCS"
$DbDir = "C:\ADCS\Db"
$DbLogDir = "C:\ADCS\DbLog"
$WebrootDir = "C:\ADCS\Web"
$RepoDir = "C:\ADCS\Web\Repository"

<###########################################################################
 #   Required section - install ADDS tools for AD info lookup
 #   AD tools are used for lookup of domain/forest names, and check Enterprise Admin rights.
 #   DNS tools are used to register DNS record for HTTP AIA/CDP (OPTIONAL)
 ###########################################################################>

Write-Progress -Activity "Installing ADDS tools and DNS Server tools.."

Install-WindowsFeature RSAT-DNS-Server | Out-Null

Write-Progress -Activity "Gathering AD Forest info"

$AdForestDns = Get-ZPkiAdForest | Select-Object -ExpandProperty RootDomain
$AdDomainDn = Get-ZPkiAdDomain | Select -ExpandProperty DistinguishedName
$CaDnSuffix = $AdDomainDn

$RootDomain = Get-ZPkiAdDomain -Domain $AdForestDns
$RootDomainSid = $RootDomain.domainsid
$RootDomainNbName = $RootDomain.NetBIOSName

$CurrentUserUpn = whoami /upn
$EaGroupObject = Find-ZPkiAdObject -SearchBase $RootDomain.distinguishedName -LdapFilter "(objectSid=$RootDomainSid-519)" -Properties member
$CurrentUserObject = Find-ZPkiAdObject -SearchBase $RootDomain.distinguishedName -LdapFilter "(userPrincipalName=$CurrentUserUpn)"
$EaMembers = $EaGroupObject.member
$CurrentUserDn = $CurrentUserObject.distinguishedName

$IsEnterpriseAdmin = $EaMembers -contains $CurrentUserDn

If(-Not $IsEnterpriseAdmin) {
    Write-Error "You must be a member of $EaGroup to install an Enterprise Root CA."
}

<###########################################################################
 #   Required section - install CA certificate for our directly superior CA.
 #   We expect a superior CA certificate file in the current directory which will be published to ADDS. Check for the file and
 #   verify that it is a valid CA cert. Also try to find a CRL file to publish.
 ###########################################################################>

$SigningCaCertFile = Get-childItem | Where-Object { $_.Name -match ".*\.(crt|cer)$" -and $_.Name -notlike "*.pem.*" } | Select-Object -ExpandProperty FullName

While(($SigningCaCertFile | Measure-Object | Select-Object -ExpandProperty Count) -ne 1) {
    Write-Warning "Please copy the signing CA certificate file to the current directory: $(Get-Location)"
    Read-Host "Press play on tape"
    $SigningCaCertFile = Get-childItem | Where-Object { $_.Name -match ".*\.(crt|cer)$" -and $_.Name -notlike "*.pem.*" } | Select-Object -ExpandProperty FullName
}

$SigningCaCertFile = $SigningCaCertFile | Select-Object -First 1

$SigningCaCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $SigningCaCertFile

Write-Verbose "Found cert for signing CA $($SigningCaCert.Subject)"

$SigningCaCrlFile = Get-childItem | Where-Object { $_ -match ".*\.crl$" } | Select-Object -expand FullName
While(($SigningCaCrlFile | Measure-Object | Select-Object -ExpandProperty Count) -ne 1) {
    Write-Warning "Please copy the superior CA CRL file to this directory. It will be published to ADDS stores. Please don't put multiple CRL files in this directory. cwd: [$(Get-Location)]"
    Read-Host "Press play on tape"
    $SigningCaCrlFile = Get-childItem | Where-Object { $_ -match ".*\.crl$" } | Select-Object -expand FullName
}
$SigningCaCrlFile = $SigningCaCrlFile | Select-Object -First 1

$SigningCaCert.Subject -match "CN=([^,]*),?.*" | Out-Null
$SigningCaCn = $Matches[1]

Publish-ZPkiCaDsFile -PublishFile $SigningCaCertFile -CertType RootCA -Verbose

# Publishing CRL in AD is only necessary if you use LDAP CDP. If needed, uncomment the following line.
# Publish-ZPkiCaDsFile -PublishFile $SigningCaCrlFile -CdpContainer $SigningCaCn -CdpObject $SigningCaCn -Verbose

<# 
    OPTIONAL SECTION - Register DNS record in AD DNS
    Check if DNS record for HTTP CDP/AIA exists. If not, try to create it.
#>

Write-Verbose "Checking for DNS record.."

$DnsRec = Resolve-DnsName $HttpFqdn -ErrorAction SilentlyContinue
If($Null -eq $DnsRec) {
    Write-Progress -Activity "Creating DNS record for HTTP"
    Try {
        $RoutableIpv4 = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $Null } | Select-Object -First 1
        # $RoutableIpv6 = Get-NetIPConfiguration | Where-Object { $_.IPv6DefaultGateway -ne $Null } | Select-Object -First 1
        
        Write-Verbose "Adding DNS record for $HttpFqdn.."
        If($RoutableIpv4) {
            Add-DnsServerResourceRecordA -Name "$HttpFqdn." -IPv4Address $RoutableIpv4.IPv4Address.IPAddress -ZoneName $AdForestDns -ComputerName $AdForestDns
        }
    } Catch {
        Write-Warning "DNS registration failed. Will proceed with installation."
        Write-Warning $_.Exception.Message
    }
}

# Website must be installed and configured now so CDP checking works, otherwise installing the signed CA certificate will fail.
Write-Progress -Activity "Installing AIA/CDP web site"
New-ZPkiWebsite -HttpFqdn $HttpFqdn -Verbose

Write-Progress -Activity "Installing CA service"
Install-ZPkiCa -CaType EnterpriseSubordinateCA -CaCommonName $CaCommonName -CaDnSuffix $CaDnSuffix -CpsOid "1.3.6.1.4.1.53997.509.1.1" -CpsUrl "http://$HttpFqdn/Docs/cps.txt" -CaCertValidityPeriodUnits 10 -CryptoProvider "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -IncludeAllIssuancePolicy -Verbose

# Copy CA certs and CRLs to repo directory
Copy-Item *.crt $RepoDir
Copy-Item *.cer $RepoDir
Copy-Item *.crl $RepoDir

$FoundCert = $False
Do {
    Read-Host "Pending CA certificate signing. Copy signed CA certificate file to $RepoDir and hit enter to proceed"
    Get-childItem $RepoDir | Where-Object { $_ -match ".*\.(crt|cer)$" } | ForEach-Object {
        $c = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $_.FullName
        $c.Subject -match "cn\s*=\s*([^,]*),?.*" | Out-Null
        $cn = $Matches[1] 
        If($cn -eq $CaCommonName) {
            $SignedCertFile = $_
            $SignedCert = $c
            $FoundCert = $True
        }
    }
} While(-Not $FoundCert)

If($SignedCertFile.Name -ne "$CaCommonName.crt") {
    $n = "$RepoDir\$CaCommonName.crt"
    Move-Item $SignedCertFile.FullName $n
    $SignedCertFile = Get-Item $n
}

$SignedCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $SignedCertFile

$CertValidates = $False
Do {
    $Chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    $CertValidates = $Chain.Build($SignedCert)
    If(-not $CertValidates) {
        Write-Warning "CA certificate failed validation. Ensure you copied the correct file, and that the revocation service is working and responding."
        Write-Warning "To check status of the revocation service, run 'certutil -verify -urlfetch $($SignedCertFile.FullName)' in a cmd window."
        Read-Host "Press play on tape"
    }
} While (-Not $CertValidates)

Install-ZPkiCaCertificate -CertFile $SignedCertFile.FullName -Verbose

Write-Progress -Activity "Running CA post config"
Set-ZPkiCaPostInstallConfig -CrlPeriod "Days" -CrlPeriodUnits 8 -CrlOverlap "Days" -CrlOverlapUnits 4

Write-Progress -Activity "Updating CA CDP/AIA information"
Set-ZPkiCaUrlConfig -ClearCDPs -ClearAIAs
Set-ZPkiCaUrlConfig -HttpCdpFqdn $HttpFqdn -AddFileCdp
Set-ZPkiCaUrlConfig -HttpAiaFqdn $HttpFqdn

Write-Progress -Activity "Generating content for AIA/CDP Web site"
New-ZPkiRepoIndex -Sourcepath $RepoDir -IndexFile "$WebrootDir\index.html" -CssFiles "style.css"
New-ZPkiRepoCssFile "$WebrootDir\style.css"
