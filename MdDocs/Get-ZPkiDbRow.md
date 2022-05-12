---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiDbRow

## SYNOPSIS
Query ADCS Db

## SYNTAX

```
Get-ZPkiDbRow [-ConfigString <String>] [-Filters <String[]>] [-Properties <String[]>] [-Table <Table>]
 [-PageSize <Int32>] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Query ADCS database for rows matching given filters.  
You can query the request table, CRL table, or extensions table.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiDbRow -ConfigString $c
```

This will return all rows in Db on ADCS instance $c

### Example 2
```powershell
PS C:\> Get-ZPkiDbRow -ConfigString $c -Filters "RequestID==2"
```

This will return the row with ID 2 in Db on ADCS instance $c

## PARAMETERS

### -ConfigString
ADCS instance config string. Find CAs with Get-ZPkiAdCasConfigString

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
Valid DbColumnNames are any returned by 'Get-ZPkiDbSchema'.
You can also sort on the selected column by prepending the filter with '+' (ascending sort) or '-' (descending).


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
Properties to include in output. Use "*" to include all columns.
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
Type: Table
Parameter Sets: (All)
Aliases:
Accepted values: ReqCert, Extensions, Attr, Crl

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
