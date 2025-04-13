---
external help file: PsZPki.psm1-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Install-ZPkiRsatComponents

## SYNOPSIS
Install ADCS RSAT tools.

## SYNTAX

```
Install-ZPkiRsatComponents [-IncludeAdTools] [<CommonParameters>]
```

## DESCRIPTION
Install ADCS RSAT tools. On older Operating Systems you need to download them from Microsoft and run the installer first.

## EXAMPLES

### Example 1
```powershell
PS C:\> Install-ZPkiRsatComponents
```

## PARAMETERS

### -IncludeAdTools
Install ADDS admin tools as well as ADCS.

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

### System.Object
## NOTES

## RELATED LINKS
