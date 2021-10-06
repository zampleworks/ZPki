---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Copy-ZPkiCertSrvFilesToRepo

## SYNOPSIS
Copy certificate and CRL files from ADCS to online repository directory

## SYNTAX

```
Copy-ZPkiCertSrvFilesToRepo [[-LocalRepositoryPath] <String>] [[-FileType] <String>] [<CommonParameters>]
```

## DESCRIPTION
Enumerate all files in ADCS windows directory (C:\Windows\System32\Certsrv) and copies
them to web repository. Certificate files with ADCS-style "<hostname>_<caname>.crt" file name will be renamed 
to just "<caname>.crt". 
All certs will also be exported as PEM files.

## EXAMPLES

### Example 1
```powershell
PS C:\> Copy-ZPkiCertSrvFilesToRepo -LocalRepositoryPath C:\ADCS\Web
```

Processes both certificate and CRL files in C:\Windows\System32\Certsrv

## PARAMETERS

### -FileType
Valid values: "crl", "crt", or "all"

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: crl, crt, all

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalRepositoryPath
Path to repository directory

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
