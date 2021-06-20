---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# New-ZPkiCertRequest

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
New-ZPkiCertRequest [-Subject <String>] [-CryptoProvider <String>] [-KeyAlg <String>] [-KeySize <Int32>]
 [-Hash <String>] [-SANs <String[]>] [-Template <String>] [-EnforceTemplate] [-ExtraVerbose]
 [<CommonParameters>]
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

### -CryptoProvider
Name of the Key Storage Provider or Crypto Service Provider to use for key storage.

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

### -EnforceTemplate
Ensure that request complies with template settings.
Any cmdlet parameters that conflict with template settings will be ignored.

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

### -Hash
Hash algorithm

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: SHA1, SHA256, SHA384, SHA512

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyAlg
Public key algorithm

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: RSA, ECC, DSA

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeySize
Public key size

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

### -SANs
Subject Alternate Names.
Format: \<type\>:\<name\>, eg DNS:app.com or UPN:user@domain.com

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

### -Subject
Subject name in DN form, eg 'CN = mycert, O = company, C = SE' or 'CN = myapp.mycompany.com'

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

### -Template
Use settings from AD cert template.

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

### None

## OUTPUTS

### xyz.zwks.pkilib.ICertificateRequest

## NOTES

## RELATED LINKS
