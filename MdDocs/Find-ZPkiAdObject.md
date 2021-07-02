---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Find-ZPkiAdObject

## SYNOPSIS
Search AD for objects

## SYNTAX

```
Find-ZPkiAdObject -SearchBase <String> -LdapFilter <String> -SearchScope <String> [-Properties <String[]>]
 [-Rpc] [-Domain <String>] [-DomainController <String>] [-UserDomain] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet can search AD for objects matching LDAP filter.  
Use -LdapFilter, -SearchBase, -SearchScope, and -Properties like you would with the MS ActiveDirectory module.

## EXAMPLES

### Example 1
```powershell
PS C:\> $RootDse = Get-ZPkiAdRootDse
PS C:\> Find-ZPkiAdObject -SearchBase $RootDse.defaultnamingcontext -SearchScope Subtree -LdapFilter "(objectClass=user)"
```

First, get the RootDSE and use the information to search in the default domain partition for all user objects.

## PARAMETERS

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

### -LdapFilter
Ldap query filter

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

### -SearchBase
Ldap query search root

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchScope
Search scope.
Must be Base, OneLevel, or Subtree.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: OneLevel, Base, Subtree

Required: True
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

### None

## OUTPUTS

### System.Collections.Generic.IEnumerable`1[[xyz.zwks.pkilib.ad.AdObject, xyz.zwks.PkiLib, Version=0.1.7853.1232, Culture=neutral, PublicKeyToken=null]]

## NOTES

## RELATED LINKS
