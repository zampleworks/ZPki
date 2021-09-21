<#
  .SYNOPSIS
  This script uses the ZPki module to install and configure an Enterprise subordinate CA.
  You must already have installed a root CA, and you need the CA certificate and CRL file
  available.

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

$AdcsRootDir = "C:\ADCS"
$DbDir = "C:\ADCS\Db"
$DbLogDir = "C:\ADCS\DbLog"
$WebrootDir = "C:\ADCS\Web"
$RepoDir = "C:\ADCS\Web\Repository"

$CaCommonName = "ZampleWorks Sub CA v1"

<###########################################################################
 #   Required section - install ADDS tools for AD info lookup
 #   AD tools are used for lookup of domain/forest names, and check Enterprise Admin rights.
 #   DNS tools are used to register DNS record for HTTP AIA/CDP (OPTIONAL)
 ###########################################################################>

Write-Progress -Activity "Installing ADDS tools and DNS Server tools.."

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

$HttpFqdn = "pki.$AdForestDns"

<###########################################################################
 #   Required section - install CA certificate for our directly superior CA.
 #   We expect a superior CA certificate file in the current directory which will be published to ADDS. Check for the file and
 #   verify that it is a valid CA cert. Also try to find a CRL file to publish.
 ###########################################################################>

$SigningCaCertFile = Get-childItem | Where-Object { $_.Name -match ".*\.(crt|cer)$" -and $_.Name -notlike "*.pem.*" }
If(($SigningCaCertFile | Measure-Object | Select -ExpandProperty Count) -ne 1) {
    Write-Error "Please copy the signing CA certificate file to this directory. It will be published to ADDS stores. Please don't put multiple cert files in this directory. cwd: [$(Get-Location)]"
}
$SigningCaCertFile = $SigningCaCertFile[0]

$SigningCaCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $SigningCaCertFile

Write-Verbose "Found cert for superior CA $($SigningCaCert.Subject)"

$SigningCaCrlFile = Get-childItem | Where-Object { $_ -match ".*\.crl$" }
If(($SigningCaCrlFile | Measure-Object | Select -ExpandProperty Count) -ne 1) {
    Write-Error "Please copy the superior CA CRL file to this directory. It will be published to ADDS stores. Please don't put multiple CRL files in this directory. cwd: [$(Get-Location)]"
}
$SigningCaCrlFile = $SigningCaCrlFile[0]

$SigningCaCert.Subject -match "CN=([^,]*),?.*" | Out-Null
$SigningCaCn = $Matches[1]

Publish-ZPkiCaDsFile -PublishFile $SigningCaCertFile.FullName -CertType RootCA -Verbose

# Publishing CRL in AD is only necessary if you use LDAP CDP. If needed, uncomment the following line.
# Publish-ZPkiCaDsFile -PublishFile $SigningCaCrlFile.FullName -CdpContainer $SigningCaCn -CdpObject $SigningCaCn -Verbose

<# 
    OPTIONAL SECTION - Register DNS record in AD DNS
    Check if DNS record for HTTP CDP/AIA exists. If not, try to create it.
#>

Write-Verbose "Checking for DNS record.."

$DnsRec = Resolve-DnsName $HttpFqdn -ErrorAction SilentlyContinue
If($DnsRec -eq $Null) {
    Write-Progress -Activity "Creating DNS record for HTTP"
    Try {
        $RoutableIpv4 = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $Null } | Select -First 1
        $RoutableIpv6 = Get-NetIPConfiguration | Where-Object { $_.IPv6DefaultGateway -ne $Null } | Select -First 1
        
        Write-Verbose "Adding DNS record for $HttpFqdn.."
        If($RoutableIpv4) {
            Add-DnsServerResourceRecordA -Name "$HttpFqdn." -IPv4Address $RoutableIpv4.IPv4Address.IPAddress -ZoneName $AdForestDns -ComputerName $AdForestDns
        }
    } Catch {
        Write-Warning "DNS registration failed. Will proceed with installation."
        Write-Warning $_.Exception.Message
    }
}

Write-Progress -Activity "Running CA installation script"
Install-ZPkiCa -CaType EnterpriseSubordinateCA -CaCommonName $CaCommonName -CpsOid "1.3.6.1.4.1.53997.509.1.1" -CpsUrl "http://$HttpFqdn/Docs/cps.txt" -CaCertValidityPeriodUnits 10 -CryptoProvider "ECDSA_P256#Microsoft Software Key Storage Provider" -KeyLength 256 -Verbose -OverwriteKey -OverwriteDb

# Website must be installed and configured now so CDP checking works, otherwise installing the signed CA certificate will fail.
New-ZPkiWebsite -HttpFqdn $HttpFqdn -Verbose

# Copy CA certs and CRLs to repo directory
cp *.crt $RepoDir
cp *.cer $RepoDir
cp *.crl $RepoDir

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
    mv $SignedCertFile.FullName $n
    $SignedCertFile = Get-Item $n
}

Install-ZPkiCaCertificate -CertFile $SignedCertFile.FullName -Verbose

Write-Progress -Activity "Running CA post config"
Set-ZPkiCaPostInstallConfig 

Write-Progress -Activity "Updating CA CDP/AIA information"
Set-ZPkiCaUrlConfig -ClearCDPs -ClearAIAs
Set-ZPkiCaUrlConfig -HttpCdpFqdn $HttpFqdn -AddFileCdp
Set-ZPkiCaUrlConfig -HttpAiaFqdn $HttpFqdn

Write-Progress -Activity "Generating content for AIA/CDP Web site"
New-ZPkiRepoIndex -Sourcepath $RepoDir -IndexFile "$WebrootDir\index.html" -CssFiles "style.css"
New-ZPkiRepoCssFile "$WebrootDir\style.css"
