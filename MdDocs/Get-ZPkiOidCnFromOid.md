---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiOidCnFromOid

## SYNOPSIS
Generate cn for an OID object

## SYNTAX

```
Get-ZPkiOidCnFromOid -Oid <String> [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
OID objects in the config partition in AD have their cn attribute set to a specific format based on the OID registered in the object's msPKI-Cert-Template-OID attribute. This cmdlet will generate the CN string from a given OID.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

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

### -Oid
This OID will be converted to form used for OID object names in forest OID Container.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

### System.String

## NOTES

## RELATED LINKS
