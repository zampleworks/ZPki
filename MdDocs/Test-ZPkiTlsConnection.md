---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Test-ZPkiTlsConnection

## SYNOPSIS
Test TLS connection and return server certificate

## SYNTAX

```
Test-ZPkiTlsConnection [-Uri] <String> -Port <UInt32> [-IgnoreValidation] [-CertFilePath <String>]
 [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Test TLS connection and return server certificate. Optionally save certificate to file.

## EXAMPLES

### Example 1
```powershell
PS C:\> Test-ZPkiTlsConnection -Uri "https://www.google.com"
```

## PARAMETERS

### -CertFilePath
Save server certificate to file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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

### -IgnoreValidation
If set, no validation of server certificates will be performed

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

### -Port
Port for TCP connection

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri
URI to connect to

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

### xyz.zwks.pkilib.common.NetClient+SecurityOptions

## NOTES

## RELATED LINKS
