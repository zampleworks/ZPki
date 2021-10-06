---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiAdIssuancePolicy

## SYNOPSIS
Lists all Issuance policy OIDs registered in Active Directory

## SYNTAX

```
Get-ZPkiAdIssuancePolicy [[-IssuancePolicyName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Issuance Policy OIDs are registered in Active Directory's Configuration partition.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiAdIssuancePolicy
```

Get all Issuance Policy OIDs

## PARAMETERS

### -IssuancePolicyName
Try to find Issuance Policy by name

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
