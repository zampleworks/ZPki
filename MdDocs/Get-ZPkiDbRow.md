---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiDbRow

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Get-ZPkiDbRow [-ConfigString <String>] [-Filters <String[]>] [-Properties <String[]>] [-Table <String>]
 [-PageSize <Int32>] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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

### -Filters
Limit results to requests matching the given filters.
Valid syntax: \<DbColumnName\>\<operator\>\<value\>.
Operators: \[==, \>, \>=, \<, \<=\].
Valid DbColumnNames are any in 'certutil -c \<configstring\> -schema'.

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

### -PageSize
Maximum number of rows to fetch at a time.
Default 50 000

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties
Properties to include in output.
If you specify columns, the default columns are omitted.
Default columns: RequestID, Request.Disposition, Request.RequesterName, CommonName, NotBefore, NotAfter, SerialNumber.

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

### xyz.zwks.pkilib.adcs.AdcsDbRow

## NOTES

## RELATED LINKS
