---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiCrl

## SYNOPSIS
Read CRL file from local file, URI, ASN.1 object, or raw bytes. HTTP or LDAP Uris only.

## SYNTAX

### Path
```
Get-ZPkiCrl [-Path] <String> [-SaveToFile <String>] [-Force] [-Rpc] [-Domain <String>]
 [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>]
 [-CertValidationMode <X509CertificateValidationMode>] [-CertRevocationMode <X509RevocationMode>]
 [-ExtraVerbose] [<CommonParameters>]
```

### Uri
```
Get-ZPkiCrl [-Uri] <Uri> [-SaveToFile <String>] [-Force] [-Rpc] [-Domain <String>] [-DomainController <String>]
 [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>]
 [-CertValidationMode <X509CertificateValidationMode>] [-CertRevocationMode <X509RevocationMode>]
 [-ExtraVerbose] [<CommonParameters>]
```

### Bytes
```
Get-ZPkiCrl [-Bytes] <Byte[]> [-SaveToFile <String>] [-Force] [-Rpc] [-Domain <String>]
 [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>]
 [-CertValidationMode <X509CertificateValidationMode>] [-CertRevocationMode <X509RevocationMode>]
 [-ExtraVerbose] [<CommonParameters>]
```

### Asn
```
Get-ZPkiCrl [-Asn] <AsnReader> [-SaveToFile <String>] [-Force] [-Rpc] [-Domain <String>]
 [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>]
 [-CertValidationMode <X509CertificateValidationMode>] [-CertRevocationMode <X509RevocationMode>]
 [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Returns a .NET object representing a CRL file.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiCrl -Uri "http://crl4.digicert.com/sha2-ev-server-g3.crl"
```

Download and parse CRL file from a public CA.

### Example 2
```powershell
PS C:\> ls *.cer | Get-ZPkiCertCdpUris | Get-ZPkiCrl
```

Extract CDP URIs from all certificate files in the current directory and fetch the CRLs

### Example 3
```powershell
PS C:\> ls *.crl | Get-ZPkiCrl
```

Get a CRL object from all local CRL files

### Example 4
```powershell
PS C:\> ls *.crl | Get-ZPkiAsn | Get-ZPkiCrl
```

Get an ASN.1 object from all local CRL files, and build a CRL object from each one

## PARAMETERS

### -Asn
ASN.1 object

```yaml
Type: AsnReader
Parameter Sets: Asn
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Bytes
Byte array of ASN.1 encoded data

```yaml
Type: Byte[]
Parameter Sets: Bytes
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -CertRevocationMode
Check certificate for revocation.

```yaml
Type: X509RevocationMode
Parameter Sets: (All)
Aliases:
Accepted values: NoCheck, Online, Offline

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertValidationMode
Validate trust to cert chain, only leaf, or chain + leaf.

```yaml
Type: X509CertificateValidationMode
Parameter Sets: (All)
Aliases:
Accepted values: None, PeerTrust, ChainTrust, PeerOrChainTrust, Custom

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Credential for connecting. Default on Windows is logged on user. On non-Windows platforms, this is mandatory.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DnsOnly
Use only DNS for AD infrastructure discovery. Do not use Win32/DirectoryServices API.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Domain
Connect to specified domain instead of current user/local computer's domain.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DomainController
Connect to specific domain controller. This takes precedence over both Domain and UserDomain parameter settings.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtraVerbose
Debug output

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrite CRL file if it already exists

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to CRL file

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Rpc
Use RPC interface for querying. If false/not set, use ADWS (default)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SaveToFile
Save CRL to file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SiteName
Force use of the specified Active Directory site.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri
Uri (HTTP or LDAP) where a CRL can be downloaded

```yaml
Type: Uri
Parameter Sets: Uri
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UserDomain
If not set/false, connect to computer's domain. If true, connect to current user's domain.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Uri

### System.Byte[]

### xyz.zwks.pkilib.cert.AsnReader

## OUTPUTS

### xyz.zwks.pkilib.cert.Crl

## NOTES

## RELATED LINKS
