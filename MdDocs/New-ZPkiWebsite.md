---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# New-ZPkiWebsite

## SYNOPSIS
Create a new IIS website to host AIA or CDP Repository

## SYNTAX

```
New-ZPkiWebsite [[-IisSiteName] <String>] [-HttpFqdn] <String> [[-LocalPath] <String>] [-InstallWebEnroll]
 [<CommonParameters>]
```

## DESCRIPTION
Installs IIS and creates a new IIS site with the given local root path and host header binding.

Author anders !Ä!T!
runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -HttpFqdn
{{ Fill HttpFqdn Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IisSiteName
{{ Fill IisSiteName Description }}

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

### -InstallWebEnroll
{{ Fill InstallWebEnroll Description }}

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

### -LocalPath
{{ Fill LocalPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: C:\ADCS\Web
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
