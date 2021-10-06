---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiAdIssuancePolicyGroupLinks

## SYNOPSIS
Get linked Issuance Policies linked to Authentication Mechanism Assurance (AMA) groups

## SYNTAX

```
Get-ZPkiAdIssuancePolicyGroupLinks [[-IssuancePolicyName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Issuance Policies in Active Directory can be linked to groups via Authentication Mechanism Assurance.
This cmdlet lists all such links.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiAdIssuancePolicyGroupLinks
```

Get all AMA Issuance Policy and group links

## PARAMETERS

### -IssuancePolicyName
Filter by Issuance Policy name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
