---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Copy-ZPkiCertSrvFilesToRepo

## SYNOPSIS
Copies files from C:\Windows\system32\certsrv\CertEnroll to CDP/AIA repository.
Crt files with server name in file name will be renamed to a sane name.

## SYNTAX

```
Copy-ZPkiCertSrvFilesToRepo [[-LocalRepositoryPath] <String>] [[-FileType] <String>] [<CommonParameters>]
```

## DESCRIPTION
Author anders !Ä!T! runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> Copy-ZPkiCertSrvFilesToRepo -LocalRepositoryPath C:\ADCS\Web\Repository
```

This copies all .crt and .crl files from C:\Windows\System32\Certsrv\CertEnroll to C:\ADCS\Web\Repository. .crt files will be renamed to the Common name in the certificate Subject field.

## PARAMETERS

### -FileType
Choose file type to copy: "crl", "crt", or "all".

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: crl, crt, all

Required: False
Position: 1
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalRepositoryPath
Local repository path to copy files to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: C:\ADCS\Web\Repository
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
