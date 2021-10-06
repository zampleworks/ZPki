---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Install-ZPkiCaCertificate

## SYNOPSIS
Install a signed CA certificate for intermediate CA

## SYNTAX

```
Install-ZPkiCaCertificate [[-CertFile] <String>] [-SkipCopyToRepository] [[-AdcsRepositoryPath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
When deploying an intermediate CA you will receive a CSR file that needs to be signed by the
superior CA. After this is done, this cmdlet installs and configures the CA certificate.

## EXAMPLES

### Example 1
```powershell
PS C:\> Install-ZPkiCaCertificate -CertFile "C:\ADCS\cacert.cer"
```

## PARAMETERS

### -AdcsRepositoryPath
Path to ADCS web repository

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertFile
Certificate file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipCopyToRepository
Don't copy files to web repository

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
