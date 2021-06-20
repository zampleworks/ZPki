---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Publish-ZPkiCaDsFile

## SYNOPSIS
Publish cert or CRL file in ADDS

## SYNTAX

### Cert
```
Publish-ZPkiCaDsFile [-PublishFile <String>] [-CertType <String>] [<CommonParameters>]
```

### Crl
```
Publish-ZPkiCaDsFile [-PublishFile <String>] [-CdpContainer <String>] [-CdpObject <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Author anders !Ä!T!
runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CdpContainer
CdpContainer CN of ADDS container to create for CRL.
Recommended: CA Common Name.

```yaml
Type: String
Parameter Sets: Crl
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CdpObject
CdpObject CN of ADDS Object to create for CRL.
Recommended: CA Common Name.

```yaml
Type: String
Parameter Sets: Crl
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertType
CertType Either "RootCA", "SubCA", or "NTAuthCA", "CrossCA", "KRA", "User", "Machine"

```yaml
Type: String
Parameter Sets: Cert
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PublishFile
PublishFile CRL or certificate file to publish in AD DS

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
