---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiAdComputer

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### GetByDistinguishedName
```
Get-ZPkiAdComputer [[-DistinguishedName] <String>] [-Properties <String[]>] [-ResolveSecurityIdentifiers]
 [-Rpc] [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly]
 [-Credential <PSCredential>] [-CertValidationMode <X509CertificateValidationMode>]
 [-CertRevocationMode <X509RevocationMode>] [-ExtraVerbose] [<CommonParameters>]
```

### GetBySamaccountName
```
Get-ZPkiAdComputer [-SamAccountName <String>] [-Properties <String[]>] [-ResolveSecurityIdentifiers] [-Rpc]
 [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly]
 [-Credential <PSCredential>] [-CertValidationMode <X509CertificateValidationMode>]
 [-CertRevocationMode <X509RevocationMode>] [-ExtraVerbose] [<CommonParameters>]
```

### GetByObjectGuid
```
Get-ZPkiAdComputer [-ObjectGuid <Guid>] [-Properties <String[]>] [-ResolveSecurityIdentifiers] [-Rpc]
 [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly]
 [-Credential <PSCredential>] [-CertValidationMode <X509CertificateValidationMode>]
 [-CertRevocationMode <X509RevocationMode>] [-ExtraVerbose] [<CommonParameters>]
```

### GetByObjectSid
```
Get-ZPkiAdComputer [-ObjectSid <String>] [-Properties <String[]>] [-ResolveSecurityIdentifiers] [-Rpc]
 [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly]
 [-Credential <PSCredential>] [-CertValidationMode <X509CertificateValidationMode>]
 [-CertRevocationMode <X509RevocationMode>] [-ExtraVerbose] [<CommonParameters>]
```

### GetByName
```
Get-ZPkiAdComputer [-ByName] [-Properties <String[]>] [-ResolveSecurityIdentifiers] [-Rpc] [-Domain <String>]
 [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>]
 [-CertValidationMode <X509CertificateValidationMode>] [-CertRevocationMode <X509RevocationMode>]
 [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ByName
Force name

```yaml
Type: Switch
Parameter Sets: GetByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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
Credential for connecting.
Default on Windows is logged on user.
On non-Windows platforms, this is mandatory.

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

### -DistinguishedName
Distinguished Name

```yaml
Type: String
Parameter Sets: GetByDistinguishedName
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DnsOnly
Use only DNS for AD infrastructure discovery.
Do not use Win32/DirectoryServices API.

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

### -ObjectGuid
Get by ObjectID

```yaml
Type: Guid
Parameter Sets: GetByObjectGuid
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ObjectSid
Get by ObjectSid

```yaml
Type: String
Parameter Sets: GetByObjectSid
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties
Select properties to return

```yaml
Type: String[]
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

### -SamAccountName
Samaccountname

```yaml
Type: String
Parameter Sets: GetBySamaccountName
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

### System.Collections.Generic.IEnumerable`1[[xyz.zwks.pkilib.ad.AdComputer, xyz.zwks.pkilib, Version=0.3.0.0, Culture=neutral, PublicKeyToken=null]]

## NOTES

## RELATED LINKS
