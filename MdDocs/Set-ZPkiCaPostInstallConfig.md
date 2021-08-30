---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Set-ZPkiCaPostInstallConfig

## SYNOPSIS
Performs post-installation configuration tasks.
Sets registry values for CRL/Delta validity time,
validity time for issued certs, and sets LDAP path.

## SYNTAX

```
Set-ZPkiCaPostInstallConfig [[-IssuedCertValidityPeriod] <String>] [[-IssuedCertValidityPeriodUnits] <Int32>]
 [[-CrlPeriod] <String>] [[-CrlPeriodUnits] <Int32>] [[-CrlOverlap] <String>] [[-CrlOverlapUnits] <Int32>]
 [[-CrlDeltaPeriod] <String>] [[-CrlDeltaPeriodUnits] <Int32>] [[-LdapConfigDn] <String>]
 [[-RepositoryLocalPath] <String>] [-RestartCertSvc] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Author anders !Ä!T!
runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CrlDeltaPeriod
CRL Delta validity

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 6
Default value: Days
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlDeltaPeriodUnits
CRL Delta validity

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlOverlap
CRL overlap

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 4
Default value: Weeks
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlOverlapUnits
CRL overlap

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 6
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlPeriod
CRL validity

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 2
Default value: Weeks
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlPeriodUnits
CRL validity

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 26
Accept pipeline input: False
Accept wildcard characters: False
```

### -IssuedCertValidityPeriod
Max validity in issued certificates

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 0
Default value: Years
Accept pipeline input: False
Accept wildcard characters: False
```

### -IssuedCertValidityPeriodUnits
Max validity in issued certificates

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -LdapConfigDn
Distinguished Name of configuration partition in AD.
Only needed if using LDAP for CDP/AIA publishing

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepositoryLocalPath
Path to CDP/AIA repository

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: C:\ADCS\Web\Repository
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestartCertSvc
Restart ADCS after running

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
