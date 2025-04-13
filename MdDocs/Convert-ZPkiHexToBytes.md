---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Convert-ZPkiHexToBytes

## SYNOPSIS
Convert string in hex format to byte array

## SYNTAX

```
Convert-ZPkiHexToBytes [-HexString] <String> [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Convert string in hex format to byte array

## EXAMPLES

### Example 1
```powershell
PS C:\> Convert-ZPkiHexToBytes -HexString "cafebabe"
202
252
186
190
```

The hexadecimal string "cafebabe" was converted to a byte array: 0xCA -> 202, 0xFE -> 252, 0xBA -> 186, 0xBE -> 190

## PARAMETERS

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

### -HexString
String of hexadecimal characters, without "0x"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Byte[]

## NOTES

## RELATED LINKS
