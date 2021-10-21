---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiAdDomain

## SYNOPSIS
TODO: This cmdlet is not usable yet.

## SYNTAX

```
Get-ZPkiAdDomain [-Rpc] [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain]
 [-DnsOnly] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -DnsOnly
Use only DNS for AD infrastructure discovery. Do not use Win32/DirectoryServices API.

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

### -SiteName
Force use of the specified Active Directory site.

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

### None

## OUTPUTS

### xyz.zwks.pkilib.ad.AdObject

## NOTES

## RELATED LINKS
