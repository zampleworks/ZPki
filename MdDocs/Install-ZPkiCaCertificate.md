﻿---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Install-ZPkiCaCertificate

## SYNOPSIS
Installs a signed CA certificate for this CA

## SYNTAX

```
Install-ZPkiCaCertificate [[-CertFile] <String>] [-SkipCopyToRepository] [[-AdcsRepositoryPath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This is used when installing a subordinate CA.
The installation generates a 
Certificate Signing Request file that needs to get signed by another CA.
Use this cmdlet to install the resulting signed certificate.

Author anders !Ä!T!
runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AdcsRepositoryPath
{{ Fill AdcsRepositoryPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: C:\ADCS\Web\Repository
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertFile
{{ Fill CertFile Description }}

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

### -SkipCopyToRepository
{{ Fill SkipCopyToRepository Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS