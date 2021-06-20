---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Set-ZPkiCaUrlConfig

## SYNOPSIS
Add/remove CDP and AIA URL configuration

## SYNTAX

### addcdp
```
Set-ZPkiCaUrlConfig [-HttpCdpFqdn <String>] [-HttpCdpPath <String>] [-AddLdapCdp] [-AddFileCdp]
 [-CdpFilePath <String>] [<CommonParameters>]
```

### addaia
```
Set-ZPkiCaUrlConfig [-HttpAiaFqdn <String>] [-HttpAiaPath <String>] [-AddLdapAia] [<CommonParameters>]
```

### addocsp
```
Set-ZPkiCaUrlConfig [-OcspUri <String>] [<CommonParameters>]
```

### clear
```
Set-ZPkiCaUrlConfig [-ClearCDPs] [-ClearAIAs] [<CommonParameters>]
```

## DESCRIPTION
the *Fqdn and *Path parameters are for building a complete HTTP URI. 
For example,
    $HttpCdpFqdn = my.server.com
    $HttpCdpPath = "Repository"
the generated URI will start with "http://my.server.com/Repository"

Author anders !Ä!T!
runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AddFileCdp
Include file URI for CDP

```yaml
Type: SwitchParameter
Parameter Sets: addcdp
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddLdapAia
Use LDAP AIA URI

```yaml
Type: SwitchParameter
Parameter Sets: addaia
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddLdapCdp
Use LDAP CDP URI

```yaml
Type: SwitchParameter
Parameter Sets: addcdp
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CdpFilePath
Path for CDP file publishing

```yaml
Type: String
Parameter Sets: addcdp
Aliases:

Required: False
Position: Named
Default value: C:\ADCS\Web\Repository
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClearAIAs
Removes all AIA entries.
Will always leave default file publish path C:\Windows\system32\certsrv\CertEnroll

```yaml
Type: SwitchParameter
Parameter Sets: clear
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClearCDPs
Removes all CDP entries.
Will always leave default file publish path C:\Windows\system32\certsrv\CertEnroll

```yaml
Type: SwitchParameter
Parameter Sets: clear
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -HttpAiaFqdn
FQDN for accessing AIA over HTTP

```yaml
Type: String
Parameter Sets: addaia
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HttpAiaPath
HTTP path for accessing AIA over HTTP

```yaml
Type: String
Parameter Sets: addaia
Aliases:

Required: False
Position: Named
Default value: Repository
Accept pipeline input: False
Accept wildcard characters: False
```

### -HttpCdpFqdn
FQDN for accessing CDP over HTTP

```yaml
Type: String
Parameter Sets: addcdp
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HttpCdpPath
HTTP path for accessing CDP over HTTP

```yaml
Type: String
Parameter Sets: addcdp
Aliases:

Required: False
Position: Named
Default value: Repository
Accept pipeline input: False
Accept wildcard characters: False
```

### -OcspUri
Include OCSP URI

```yaml
Type: String
Parameter Sets: addocsp
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
