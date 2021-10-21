---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiAdRootDse

## SYNOPSIS
Get RootDSE for Active Directory. Use parameters to control which domain to connect to.

## SYNTAX

```
Get-ZPkiAdRootDse [-Rpc] [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain]
 [-DnsOnly] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
If run without parameters, cmdlet will connect to computer's joined domain. If -UserDomain is supplied, the cmdlet will connect to calling user's domain. 
Using -Domain or -DomainController you can connect to specific DC's, or to another domain in the forest, or any trusted forest.

Default is to connect to ADWS. Use -Rpc if you need to connect via RPC instead.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiAdRootDse
```

Get RootDSE object and all properties.

## PARAMETERS

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

### None

## OUTPUTS

### xyz.zwks.pkilib.ad.AdObject

## NOTES

## RELATED LINKS
