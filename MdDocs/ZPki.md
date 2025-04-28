---
Module Name: ZPki
Module Guid: 9c890be1-0e6d-4965-a250-ee9b414b350e
Download Help Link: {{ no download link }}
Help Version: {{ 1.9.8.0 }}
Locale: en-US
---

# ZPki Module
## Description
{{ Active Directory and Active Directory Certificate Services tools }}

## ZPki Cmdlets
### [Convert-ZPkiHexToBytes](Convert-ZPkiHexToBytes.md)
Convert string in hex format to byte array

### [Copy-ZPkiCertSrvFilesToRepo](Copy-ZPkiCertSrvFilesToRepo.md)
Copy certificate and CRL files from ADCS to online repository directory

### [Export-ZPkiCertAsPem](Export-ZPkiCertAsPem.md)
{{ Fill in the Synopsis }}

### [Find-ZPkiAdAttributeSchema](Find-ZPkiAdAttributeSchema.md)
Get attributeSchema objects

### [Find-ZPkiAdClassSchema](Find-ZPkiAdClassSchema.md)
Get attributeSchema objects

### [Find-ZPkiAdControlAccessRight](Find-ZPkiAdControlAccessRight.md)
Get ControlAccessRights registered in Active Directory

### [Find-ZPkiAdObject](Find-ZPkiAdObject.md)
Search AD for objects.

### [Find-ZPkiAdOid](Find-ZPkiAdOid.md)
Find OID registrations in AD. Retrieve all OIDs, or filter by type and/or name.

### [Find-ZPkiAdUser](Find-ZPkiAdUser.md)
Search AD for user objects.

### [Find-ZPkiLocalCert](Find-ZPkiLocalCert.md)
Search for certificates in local windows stores

### [Get-ZPkiAdCasConfigString](Get-ZPkiAdCasConfigString.md)
List configuration strings for all Enterprise CAs in the forest

### [Get-ZPkiAdcsRoles](Get-ZPkiAdcsRoles.md)
{{ Fill in the Synopsis }}

### [Get-ZPkiAdDomain](Get-ZPkiAdDomain.md)
Get information about an AD domain

### [Get-ZPkiAdForest](Get-ZPkiAdForest.md)
Get AD forest information

### [Get-ZPkiAdForestOid](Get-ZPkiAdForestOid.md)
Retrieve or generate the Windows generated OID for the AD forest.

### [Get-ZPkiAdIssuancePolicy](Get-ZPkiAdIssuancePolicy.md)
Lists all Issuance policy OIDs registered in Active Directory

### [Get-ZPkiAdIssuancePolicyGroupLinks](Get-ZPkiAdIssuancePolicyGroupLinks.md)
Get linked Issuance Policies linked to Authentication Mechanism Assurance (AMA) groups

### [Get-ZPkiAdMsSchema](Get-ZPkiAdMsSchema.md)
Get registered schema and object versions for Microsoft services such as ADDS, Exchange, and SfB.

### [Get-ZPkiAdObject](Get-ZPkiAdObject.md)
Get a specific AD object

### [Get-ZPkiAdRootDse](Get-ZPkiAdRootDse.md)
Get RootDSE for Active Directory. Use parameters to control which domain to connect to.

### [Get-ZPkiAdTemplate](Get-ZPkiAdTemplate.md)
Get certificate templates from AD.

### [Get-ZPkiAdTemplateRiskScore](Get-ZPkiAdTemplateRiskScore.md)
TODO: Not implemented yet!

### [Get-ZPkiAdUser](Get-ZPkiAdUser.md)
Get a specific AD user account

### [Get-ZPkiAsn](Get-ZPkiAsn.md)
Parse DER encoded ASN.1 data

### [Get-ZPkiCertCdpUris](Get-ZPkiCertCdpUris.md)
Get CDP Uris from certificate

### [Get-ZPkiCrl](Get-ZPkiCrl.md)
Read CRL file from local file, URI, ASN.1 object, or raw bytes. HTTP or LDAP Uris only.

### [Get-ZPkiDbLastRowId](Get-ZPkiDbLastRowId.md)
Get the row ID of the last row in the ADCS Db.

### [Get-ZPkiDbRow](Get-ZPkiDbRow.md)
Query ADCS Db

### [Get-ZPkiDbSchema](Get-ZPkiDbSchema.md)
Get ADCS Db schema

### [Get-ZPkiLocalCaConfigString](Get-ZPkiLocalCaConfigString.md)
Get config string for local instance of ADCS

### [Get-ZPkiOid](Get-ZPkiOid.md)
{{ Fill in the Synopsis }}

### [Get-ZPkiOidCnFromOid](Get-ZPkiOidCnFromOid.md)
Generate cn for an OID object

### [Get-ZPkiServiceBindings](Get-ZPkiServiceBindings.md)
List network ports/pipe addresses for well known services. Can query RPC Endpoint mapper for runtime ports for services that dynamically allocates ports for RPC/DCOM access. Currently only Active Directory is defined.

### [Install-ZPkiCa](Install-ZPkiCa.md)
Install and configure ADCS on the local machine.

### [Install-ZPkiCaCertificate](Install-ZPkiCaCertificate.md)
Install a signed CA certificate for intermediate CA

### [Install-ZPkiRsatComponents](Install-ZPkiRsatComponents.md)
Install ADCS RSAT tools.

### [New-ZPkiCaBackup](New-ZPkiCaBackup.md)
Backs up ADCS to given directory.
Private key is not included by default, use -BackupKey to include it.
Backups up CA database and configuration:
    1.
Registry values
    2.
Published templates
    3.
Installed local certificates

### [New-ZPkiCertRequest](New-ZPkiCertRequest.md)
This cmdlet is not finished, do not use..

### [New-ZPkiRandomPassword](New-ZPkiRandomPassword.md)
Generate random password containing alphanumeric characters and the following set: !@#$%^&*()_-+=\[{\]};:\<\>|./?
This cmdlet does not work on .net core-based versions of powershell! 

### [New-ZPkiRepoCssFile](New-ZPkiRepoCssFile.md)
Generate a new default CSS file for use with HTML repository

### [New-ZPkiRepoIndex](New-ZPkiRepoIndex.md)
Generates a HTML index file for CDP/AIA repository

### [New-ZPkiWebsite](New-ZPkiWebsite.md)
Create a new IIS website to host AIA or CDP Repository

### [Publish-ZPkiCaDsFile](Publish-ZPkiCaDsFile.md)
Publish cert or CRL file in ADDS

### [Remove-ZPkiAdIssuancePolicyGroupLink](Remove-ZPkiAdIssuancePolicyGroupLink.md)
Removes AMA group link from Issuance Policy OID

### [Set-ZPkiAdAltSecurityIdentities](Set-ZPkiAdAltSecurityIdentities.md)
Update altSecIdentities on Active Directory user object based on certificate in ADCS db

### [Set-ZPkiAdIssuancePolicyGroupLink](Set-ZPkiAdIssuancePolicyGroupLink.md)
Link an AMA group to Issuance Policy

### [Set-ZPkiCaPostInstallConfig](Set-ZPkiCaPostInstallConfig.md)
Performs post-installation configuration tasks.
Sets registry values for CRL/Delta validity time,
validity time for issued certs, and sets LDAP path.

### [Set-ZPkiCaUrlConfig](Set-ZPkiCaUrlConfig.md)
Add/remove CDP and AIA URL configuration

### [Submit-ZPkiRequest](Submit-ZPkiRequest.md)
This cmdlet is not finished.
Do not use.

### [Test-ZPkiAdcsIsOnline](Test-ZPkiAdcsIsOnline.md)
{{ Fill in the Synopsis }}

### [Test-ZPkiAdObjectAclSecurity](Test-ZPkiAdObjectAclSecurity.md)
{{ Fill in the Synopsis }}

### [Test-ZPkiIsAdmin](Test-ZPkiIsAdmin.md)
{{ Fill in the Synopsis }}

### [Test-ZPkiServiceBinding](Test-ZPkiServiceBinding.md)
Test connectivity to a service bound to a TCP port.

### [Test-ZPkiTlsConnection](Test-ZPkiTlsConnection.md)
Test TLS connection and return server certificate

