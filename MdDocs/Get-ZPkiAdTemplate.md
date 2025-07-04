﻿---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiAdTemplate

## SYNOPSIS
Get certificate templates from AD.

## SYNTAX

### Default (Default)
```
Get-ZPkiAdTemplate [-ResolveSecurityIdentifiers] [-PublishedBy <String>] [-IncludePublishingCAs] [-Rpc]
 [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly]
 [-Credential <PSCredential>] [-CertValidationMode <X509CertificateValidationMode>]
 [-CertRevocationMode <X509RevocationMode>] [-ExtraVerbose] [<CommonParameters>]
```

### Name
```
Get-ZPkiAdTemplate [-ResolveSecurityIdentifiers] [-Name <String>] [-PublishedBy <String>]
 [-IncludePublishingCAs] [-Rpc] [-Domain <String>] [-DomainController <String>] [-SiteName <String>]
 [-UserDomain] [-DnsOnly] [-Credential <PSCredential>] [-CertValidationMode <X509CertificateValidationMode>]
 [-CertRevocationMode <X509RevocationMode>] [-ExtraVerbose] [<CommonParameters>]
```

### Oid
```
Get-ZPkiAdTemplate [-ResolveSecurityIdentifiers] [-Oid <String>] [-PublishedBy <String>]
 [-IncludePublishingCAs] [-Rpc] [-Domain <String>] [-DomainController <String>] [-SiteName <String>]
 [-UserDomain] [-DnsOnly] [-Credential <PSCredential>] [-CertValidationMode <X509CertificateValidationMode>]
 [-CertRevocationMode <X509RevocationMode>] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
List or search for templates in Active Directory. You can filter by name, template OID, or which CA that currently publishes this template. 

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiAdTemplate
```

List all templates in the computer's domain.

## PARAMETERS

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
Connect to specific domain controller.
This takes precedence over both Domain and UserDomain parameter settings.

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

### -IncludePublishingCAs
Include list of CAs each template is published on

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

### -Name
Find template by Name

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Oid
Find template by OID

```yaml
Type: String
Parameter Sets: Oid
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PublishedBy
Find template published on a specific CA

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

### -ResolveSecurityIdentifiers
Resolve SIDs, GUIDs and ExtendedRights when returning object security

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

### -Rpc
Use RPC interface for querying.
If false/not set, use ADWS (default)

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

### -UserDomain
If not set/false, connect to computer's domain.
If true, connect to current user's domain.

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

## OUTPUTS

### System.Collections.Generic.IEnumerable`1[[xyz.zwks.pkilib.ad.AdCertificateTemplate, xyz.zwks.pkilib, Version=0.3.0.0, Culture=neutral, PublicKeyToken=null]]

## NOTES

## RELATED LINKS
