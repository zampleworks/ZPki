---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiOidCnFromOid

## SYNOPSIS
Generate cn for an OID object

## SYNTAX

### string
```
Get-ZPkiOidCnFromOid [-OidString] <String> [-ExtraVerbose] [<CommonParameters>]
```

### oid
```
Get-ZPkiOidCnFromOid [-Oid] <Oid> [-ExtraVerbose] [<CommonParameters>]
```

### oidw
```
Get-ZPkiOidCnFromOid [-OidW] <OidW> [-ExtraVerbose] [<CommonParameters>]
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
Type: Oid
Parameter Sets: oid
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OidString
This OID will be converted to form used for OID object names in forest OID Container.

```yaml
Type: String
Parameter Sets: string
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OidW
This OID will be converted to form used for OID object names in forest OID Container.

```yaml
Type: OidW
Parameter Sets: oidw
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

### System.Security.Cryptography.Oid

### xyz.zwks.pkilib.cert.OidW

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
