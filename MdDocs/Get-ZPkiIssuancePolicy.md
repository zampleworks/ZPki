---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiIssuancePolicy

## SYNOPSIS
Lists all Issuance policy objects in ADDS.

## SYNTAX

```
Get-ZPkiIssuancePolicy [[-IssuancePolicyName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Author anders !Ä!T!
runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiIssuancePolicy
```

This will lista all Issuance policy OIDs registered in the AD forest.

## PARAMETERS

### -IssuancePolicyName
If supplied, display info about only this policy.
If omitted display information for all issuance policies.

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
