---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Find-ZPkiAdClassSchema

## SYNOPSIS
Get attributeSchema objects

## SYNTAX

### SearchByName (Default)
```
Find-ZPkiAdClassSchema [[-Name] <String>] [-Rpc] [-Domain <String>] [-DomainController <String>]
 [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>] [-ExtraVerbose]
 [<CommonParameters>]
```

### SearchByGuid
```
Find-ZPkiAdClassSchema [-SchemaIdGuid <Guid>] [-Rpc] [-Domain <String>] [-DomainController <String>]
 [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>] [-ExtraVerbose]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-ZPkiAdClassSchema computer


DistinguishedName         : CN=Computer,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
Name                      : Computer
CommonName                : Computer
ObjectGuid                : 7393af38-407c-4d95-9f99-802e5a8d4c8c
RelativeDistinguishedName : CN=Computer
SchemaIdGuid              : bf967a86-0de6-11d0-a285-00aa003049e2
LdapDisplayName           : computer
DefaultObjectCategory     : CN=Computer,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
RdnAttribute              : cn
DefaultSecurityDescriptor : D:(A;;RPWPCRCCDCLCLORCWOWDSDDTSW;;;DA)(A;;RP...
ObjectClassCategory       : Structural
SystemFlags               : BaseSchemaObject
SystemOnly                : False
AuxiliaryClass            : {ipHost}
MayContain                : {mslapsencrypteddsrmpasswordhistory, mslapsencrypteddsrmpassword, ...}
MustContain               : {}
SubclassOf                : CN=User,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
PossibleSuperiors         : {}
SystemAuxiliaryClass      : {}
SystemMayContain          : {msimaginghashalgorithm, msimagingthumbprinthash, msdsgenerationid, ...}
SystemMustContain         : {}
SystemPossibleSuperiors   : {container, organizationalUnit, domainDNS}

DistinguishedName         : CN=ms-Exch-Computer-Policy,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
Name                      : ms-Exch-Computer-Policy
CommonName                : ms-Exch-Computer-Policy
ObjectGuid                : a5a9a67a-fcdc-4957-974c-bfa5eeb0e26a
RelativeDistinguishedName : CN=ms-Exch-Computer-Policy
SchemaIdGuid              : ed2c752c-a980-11d2-a9ff-00c04f8eedd8
LdapDisplayName           : msExchComputerPolicy
DefaultObjectCategory     : CN=ms-Exch-Computer-Policy,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
RdnAttribute              : cn
DefaultSecurityDescriptor : D:S:
ObjectClassCategory       : Structural
SystemFlags               : None
SystemOnly                : False
AuxiliaryClass            : {msExchBaseClass}
MayContain                : {msexchpolicylastappliedtime, msexchpolicyoptionlist, msexchpolicylockdown, ...}
MustContain               : {}
SubclassOf                : CN=Computer,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
PossibleSuperiors         : {container}
SystemAuxiliaryClass      : {}
SystemMayContain          : {}
SystemMustContain         : {}
SystemPossibleSuperiors   : {}
```

Search for classSchema objects in the schema partition. Searches match on substring so "computer" will match both "computer" and "ms-Exch-Computer-Policy".

### Example 2
```powershell
PS C:\> "bf967aba-0de6-11d0-a285-00aa003049e2" | Find-ZPkiAdClassSchema

DistinguishedName         : CN=User,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
Name                      : User
CommonName                : User
ObjectGuid                : 5dc6ff41-a901-4642-a51f-048f49b0491f
RelativeDistinguishedName : CN=User
SchemaIdGuid              : bf967aba-0de6-11d0-a285-00aa003049e2
LdapDisplayName           : user
DefaultObjectCategory     : CN=Person,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
RdnAttribute              : cn
DefaultSecurityDescriptor : D:(A;;RPWPCRCCDCLCLORCW...
ObjectClassCategory       : Structural
SystemFlags               : BaseSchemaObject
SystemOnly                : False
AuxiliaryClass            : {msExchOmaUser, msExchIMRecipient, msExchCertificateInformation, msExchMultiMediaUser...}
MayContain                : {msexchoriginatingforest, msexchimapowaurlprefixoverride, kmserver, ...}
MustContain               : {}
SubclassOf                : CN=Organizational-Person,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
PossibleSuperiors         : {msExchSystemObjectsContainer}
SystemAuxiliaryClass      : {msDS-CloudExtensions, securityPrincipal, mailRecipient}
SystemMayContain          : {msdskeycredentiallink, msdskeyprincipalbl, msdsauthnpolicysilomembersbl, ...}
SystemMustContain         : {}
SystemPossibleSuperiors   : {builtinDomain, organizationalUnit, domainDNS}
```

Search in the schema partition for a classSchema object with SchemaIDGuid. Returns at most one object

## PARAMETERS

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

### -Name
Search by name.
Will match attributes CN or lDAPDisplayName

```yaml
Type: String
Parameter Sets: SearchByName
Aliases:

Required: False
Position: 0
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

### -SchemaIdGuid
Filter by schemaIDGuid

```yaml
Type: Guid
Parameter Sets: SearchByGuid
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### System.Guid

## OUTPUTS

### System.Collections.Generic.IEnumerable`1[[xyz.zwks.pkilib.ad.AdClassSchema, xyz.zwks.pkilib, Version=0.3.0.0, Culture=neutral, PublicKeyToken=null]]

## NOTES

## RELATED LINKS
