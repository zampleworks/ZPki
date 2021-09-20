---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiCrl

## SYNOPSIS
Read CRL file from local file, URI or raw bytes. HTTP or LDAP Uris only.

## SYNTAX

### Path
```
Get-ZPkiCrl [-Path] <String> [-Rpc] [-Domain <String>] [-DomainController <String>] [-UserDomain]
 [-ExtraVerbose] [<CommonParameters>]
```

### Uri
```
Get-ZPkiCrl [-Uri] <Uri> [-Rpc] [-Domain <String>] [-DomainController <String>] [-UserDomain] [-ExtraVerbose]
 [<CommonParameters>]
```

### Bytes
```
Get-ZPkiCrl [-Bytes] <Byte[]> [-Rpc] [-Domain <String>] [-DomainController <String>] [-UserDomain]
 [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Returns a .NET object representing a CRL file.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiCrl -Uri "http://crl4.digicert.com/sha2-ev-server-g3.crl"
```

Download and parse CRL file from a public CA.

## PARAMETERS

### -Bytes
Byte array of ASN.1 encoded data

```yaml
Type: Byte[]
Parameter Sets: Bytes
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Domain
Connect to specified domain instead of current user/local computer's domain.

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

### -DomainController
Connect to specific domain controller.
This takes precedence over both Domain and UserDomain parameter settings.

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

### -Path
Path to CRL file

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Rpc
Use RPC interface for querying.
If false/not set, use ADWS (default)

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

### -Uri
Uri (HTTP or LDAP) where a CRL can be downloaded

```yaml
Type: Uri
Parameter Sets: Uri
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UserDomain
If not set/false, connect to computer's domain.
If true, connect to current user's domain.

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

### System.String

### System.Uri

### System.Byte[]

## OUTPUTS

### xyz.zwks.pkilib.cert.Crl

## NOTES

## RELATED LINKS
