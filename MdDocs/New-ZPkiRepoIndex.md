---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# New-ZPkiRepoIndex

## SYNOPSIS
Generates a HTML index file for CDP/AIA repository

## SYNTAX

```
New-ZPkiRepoIndex [[-Sourcepath] <String>] [[-IndexFile] <String>] [[-CssFiles] <String[]>]
 [[-JsFiles] <String[]>] [[-PageTitle] <String>] [[-PageHeader] <String>] [[-CertsHeader] <String>]
 [[-CrlsHeader] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will generate a helpful HTML page containing web links to all CA certificates and CRL files in the given
directory (SourcePath).
You can include Javascript/CSS files of your choosing by using the CssFiles/JsFiles parameters.
You can generate a default CSS file with the New-ZPkiRepoCssFile.

Recommendation: create both binary and PEM versions of each cert in the source directory.
Follow this naming standard: cacert.crt and cacert.pem.crt.
If you do the pem versions will 
be included on the same table row.

The cmdlet assumes the following layout of files in the generated HTML:
-\> index.html
-\> Repository/
   -\> cacert.crt
   -\> cacert.pem.crt

Author anders !Ä!T!
runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CertsHeader
HTML header for the CA certs section

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: CA Certificates
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlsHeader
HTML header for the CA CRLs section

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: CRL files
Accept pipeline input: False
Accept wildcard characters: False
```

### -CssFiles
Style sheet to include in html

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndexFile
Path for generated index file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Index.html
Accept pipeline input: False
Accept wildcard characters: False
```

### -JsFiles
Javascript to include in html

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageHeader
HTML h1 tab

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: PKI Repository
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageTitle
HTML title tag

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: PKI Repository
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sourcepath
This directory will be scanned for crt/cer/crl files.
It is assumed that files will be in a subdirectory named 'Repository' relative to the index.html file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: .\
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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
