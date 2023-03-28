---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Find-ZPkiAdUser

## SYNOPSIS
Search AD for user objects.

## SYNTAX

```
Find-ZPkiAdUser [-Name <String>] [-SearchBase <String>] [-SearchScope <String>] [-Properties <String[]>] [-Rpc]
 [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly]
 [-Credential <PSCredential>] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Similar to Find-ZPkiAdObject, but searches specifically for user objects. Filter by -Name, which will match attributes: name, displayname, cn, samaccountname, userprincipalname.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-ZPkiAdUser -Name "Tommy Teapot"
```

Search for AD users in the default naming context (Get-ZPkiAdRootDse | Select defaultnamingcontext)

## PARAMETERS

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

### -Name
Search by name.
Will match attributes 'name', 'cn', 'displayname'

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
Search in OU/container

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

### -SearchScope
Search scope.
Must be Base, OneLevel, or Subtree.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: OneLevel, Base, Subtree

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

### None

## OUTPUTS

### System.Collections.Generic.IEnumerable`1[[xyz.zwks.pkilib.ad.AdObject, xyz.zwks.pkilib, Version=0.1.9.3, Culture=neutral, PublicKeyToken=null]]

## NOTES

## RELATED LINKS
