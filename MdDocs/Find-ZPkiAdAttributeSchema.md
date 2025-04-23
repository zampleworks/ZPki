---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Find-ZPkiAdAttributeSchema

## SYNOPSIS
Get attributeSchema objects

## SYNTAX

### SearchByName (Default)
```
Find-ZPkiAdAttributeSchema [[-Name] <String>] [-Rpc] [-Domain <String>] [-DomainController <String>]
 [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>] [-ExtraVerbose]
 [<CommonParameters>]
```

### SearchByGuid
```
Find-ZPkiAdAttributeSchema [-SchemaIdGuid <Guid>] [-Rpc] [-Domain <String>] [-DomainController <String>]
 [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>] [-ExtraVerbose]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-ZPkiAdAttributeSchema samaccountname

DistinguishedName     : CN=ms-DS-Additional-Sam-Account-Name,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
ObjectGuid            : c2e25b99-4118-4dfc-aa69-585ec87138d4
Name                  : ms-DS-Additional-Sam-Account-Name
CommonName            : ms-DS-Additional-Sam-Account-Name
LdapDisplayName       : msDS-AdditionalSamAccountName
ObjectGuid            : c2e25b99-4118-4dfc-aa69-585ec87138d4
SchemaIdGuid          : 975571df-a4d5-429a-9f59-cdc6581d91e6
AttributeSecurityGuid : 00000000-0000-0000-0000-000000000000
PropertySets          : {}
IsSingleValued        : False
OmSyntax              : 64
OmObjectClass         :
SystemFlags           : None
SystemOnly            :
AttributeSyntax       : String(Unicode); Unicode string (2.5.5.12)

DistinguishedName     : CN=SAM-Account-Name,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
ObjectGuid            : b47e7255-a601-4144-8e92-d19a902636de
Name                  : SAM-Account-Name
CommonName            : SAM-Account-Name
LdapDisplayName       : sAMAccountName
ObjectGuid            : b47e7255-a601-4144-8e92-d19a902636de
SchemaIdGuid          : 3e0abfd0-126a-11d0-a060-00aa006c33ed
AttributeSecurityGuid : 59ba2f42-79a2-11d0-9020-00c04fc2d3cf
PropertySets          : {CN=General-Information,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz}
IsSingleValued        : True
OmSyntax              : 64
OmObjectClass         :
SystemFlags           : None
SystemOnly            :
AttributeSyntax       : String(Unicode); Unicode string (2.5.5.12)
```

Search for attributeSchema objects in the schema partition. Searches match on substring so "samaccountname" will match both "samaccountname" and "msDS-AdditionalSamAccountName".

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

### System.Collections.Generic.IEnumerable`1[[xyz.zwks.pkilib.ad.AdAttributeSchema, xyz.zwks.pkilib, Version=0.2.1.0, Culture=neutral, PublicKeyToken=null]]

## NOTES

## RELATED LINKS
