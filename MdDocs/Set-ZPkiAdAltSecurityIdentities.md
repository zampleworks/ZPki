---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Set-ZPkiAdAltSecurityIdentities

## SYNOPSIS
Update altSecIdentities on Active Directory user object based on certificate in ADCS db

## SYNTAX

```
Set-ZPkiAdAltSecurityIdentities [-AdSamaccountName] <String> [[-CertTemplateName] <String>]
 [[-CaNameFilter] <String>] [-ClearAltSecurityIdentities] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Find an AD account by AdSamaccountname and search given CA db for a cert with matching CN and RequesterName.
If multiple certs match, the last one will be used.
You can supply a template name to limit cert search.
Extract serialnumber and Issuer name from cert and set altSecIdentities accordingly.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-ZPkiAdAltSecurityIdentities -AdSamaccountName anders -CertTemplateName ZUserAE
```

Get user anders from AD, find the latest cert based on ZUserAE template on default ADCS instance,
and update altSecurityIdentities based on cert Issuer and Serial number

## PARAMETERS

### -AdSamaccountName
AD Account name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaNameFilter
If you have multiple CAs use this parameter to filter on CA name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertTemplateName
Short name of certificate template

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClearAltSecurityIdentities
Removes all preexisting entries from altSecurityIdentities attribute before setting.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
