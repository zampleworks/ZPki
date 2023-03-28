---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiDbLastRowId

## SYNOPSIS
Get the row ID of the last row in the ADCS Db.

## SYNTAX

```
Get-ZPkiDbLastRowId [-ConfigString <String>] [-Table <String>] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Get the row ID of the last row in the ADCS Db.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiDbLastRowId
```

Get the last row of Db on local ADCS instance.

### Example 2
```powershell
PS C:\> Get-ZPkiDbLastRowId (Get-ZPkiAdCasConfigString | Select -First 1)
```

Get the last row of Db on the ADCS instance defined by the first config string found by Get-ZPkiAdCasConfigString.

## PARAMETERS

### -ConfigString
{{ Fill ConfigString Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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

### -Table
Database table to query.
'Cert', 'Ext', 'Attr', and 'Crl' are valid values.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Cert, Ext, Attr, Crl

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
