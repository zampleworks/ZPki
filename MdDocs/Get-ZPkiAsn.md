﻿---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiAsn

## SYNOPSIS
Parse DER encoded ASN.1 data

## SYNTAX

### File
```
Get-ZPkiAsn [-File] <FileInfo> [-AsText] [-ExtraVerbose] [<CommonParameters>]
```

### Path
```
Get-ZPkiAsn [-Path] <String> [-AsText] [-ExtraVerbose] [<CommonParameters>]
```

### Bytes
```
Get-ZPkiAsn [-Bytes] <Byte[]> [-AsText] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Parses DER encoded ASN.1 data from a file or byte array. File can be either binary DER encoded or optionally base64 (PEM) encoded.  

Returns a PS object or a text blob representing the ASN.1 document.  

This parser does not currently interpret any context specific tags. Only Universal tags are understood.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiAsn -Path c:\path\to\certfile.cer -Dump
```

Reads certfile.cer and outputs a string representation of the ASN.1 document.

## PARAMETERS

### -AsText
Return text representation of ASN.1 data instead of an object

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

### -Bytes
Byte array of ASN.1 encoded data

```yaml
Type: Byte[]
Parameter Sets: Bytes
Aliases:

Required: True
Position: 0
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

### -File
ASN.1 file to parse

```yaml
Type: FileInfo
Parameter Sets: File
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Path to ASN.1 file to parse

```yaml
Type: String
Parameter Sets: Path
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

### System.IO.FileInfo

### System.String

### System.Byte[]

## OUTPUTS

### xyz.zwks.pkilib.cert.AsnReader

## NOTES

## RELATED LINKS
