---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiCertCdpUris

## SYNOPSIS
Get CDP Uris from certificate

## SYNTAX

### File
```
Get-ZPkiCertCdpUris [-Path] <String> [-ExtraVerbose] [<CommonParameters>]
```

### Bytes
```
Get-ZPkiCertCdpUris -Bytes <Byte[]> [-ExtraVerbose] [<CommonParameters>]
```

### CertObject
```
Get-ZPkiCertCdpUris [-Cert] <X509Certificate2> [-ExtraVerbose] [<CommonParameters>]
```

### Asn
```
Get-ZPkiCertCdpUris [-Asn] <AsnObject> [-ExtraVerbose] [<CommonParameters>]
```

### ICertificate
```
Get-ZPkiCertCdpUris [-ICert] <ICertificate> [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Get CRL information from certificate and returns a URI object for each entry

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiCertCdpUris -Path c:\Path\to\certfile.cer
```

Returns CRL entries from certfile.cer

## PARAMETERS

### -Asn
ASN.1 object representing an x509 certificate

```yaml
Type: AsnObject
Parameter Sets: Asn
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Bytes
Certificate byte array

```yaml
Type: Byte[]
Parameter Sets: Bytes
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Cert
.NET X509 Certificate object

```yaml
Type: X509Certificate2
Parameter Sets: CertObject
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

### -ICert
Zampleworks Pkilib Certificate object

```yaml
Type: ICertificate
Parameter Sets: ICertificate
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Path to certificate file

```yaml
Type: String
Parameter Sets: File
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

### System.Security.Cryptography.X509Certificates.X509Certificate2

### xyz.zwks.pkilib.cert.AsnObject

### xyz.zwks.pkilib.cert.ICertificate

## OUTPUTS

### System.Uri

## NOTES

## RELATED LINKS
