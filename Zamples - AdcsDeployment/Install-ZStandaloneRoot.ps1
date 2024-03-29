﻿<#
  .SYNOPSIS
  This script uses the ZPki module to install and configure a root CA.

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

# FQDN for HTTP AIA & CDP
$HttpFqdn = "pki.zampleworks.com"

$CaCommonName = "ZampleWorks PKI v1 Root CA"
$CaDnSuffix = "O=ZampleWorks,C=SE"

<#
 Run the CA installation procedure. This Cmdlet will:
 1. Install ADCS role
 2. Create CAPolicy.inf in C:\Windows with selected options
 3. Create local directories for ADCS (Db and transaction log), CDP/AIA repository, scripts, etc
 4. Configure CA role
 
 The Cmdlet defaults to settings for an Enterprise Root CA, so we give some parameters appropriate for a standalone root CA.
#> 
Write-Progress -Activity "Running CA installation script"
Install-ZPkiCa -CaCommonName $CaCommonName -CaDnSuffix $CaDnSuffix -KeyLength 4096 -Hash "SHA256" -CaType StandaloneRootCA -EnableBasicConstraints -BasicConstraintsIsCritical -PathLength 1

<#
 Run CA postconfiguration procedure. This Cmdlet will:

 1. Set lifetime for issued certs
 2. Set CRL/Delta/Overlap time spans
 3. Audit config = 127
 4. Copy CA cert and CRL to Repository directory

 Setting LdapConfigDn is only needed if you will write LDAP URIs for CDP/AIA. If you're going pure HTTP you can remove it.

#>
Write-Progress -Activity "Running CA post config"
Set-ZPkiCaPostInstallConfig -CrlOverlap Weeks -CrlOverlapUnits 8 -CrlPeriod Weeks -CrlPeriodUnits 52 -IssuedCertValidityPeriod Years -IssuedCertValidityPeriodUnits 10

<#
 Set CDP and AIA URIs for issued certificates. Remove any default ones and add HTTP only.
#>
Write-Progress -Activity "Updating CA CDP/AIA information"

# the -ClearX options will keep the built-in file publish locations c:\Windows\certsvc\CertEnroll
Set-ZPkiCaUrlConfig -ClearCDPs -ClearAIAs
Set-ZPkiCaUrlConfig -HttpCdpFqdn $HttpFqdn -AddFileCdp
Set-ZPkiCaUrlConfig -HttpAiaFqdn $HttpFqdn

Restart-Service CertSvc

certutil -crl | Out-Null
