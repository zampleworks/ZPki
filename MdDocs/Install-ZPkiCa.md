---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Install-ZPkiCa

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Install-ZPkiCa [[-CaCommonName] <String>] [[-CaDnSuffix] <String>] [[-CaType] <String>] [[-KeyLength] <Int32>]
 [[-CryptoProvider] <String>] [-AllowAdminInteraction] [[-Hash] <String>] [-EnableBasicConstraints]
 [-BasicConstraintsIsCritical] [[-PathLength] <String>] [[-EkuOids] <String[]>] [-EkuSectionIsCritical]
 [[-CpsNotice] <String>] [[-CpsOid] <String>] [[-CpsUrl] <String>] [-IncludeAllIssuancePolicy]
 [-IncludeAssurancePolicy] [-AutoDetectAssurancePolicy] [[-AssurancePolicyName] <String>]
 [[-AssurancePolicyOid] <String>] [[-AssurancePolicyNotice] <String>] [[-AssurancePolicyUrl] <String>]
 [-RootCaForcePolicy] [[-CaCertValidityPeriod] <String>] [[-CaCertValidityPeriodUnits] <Int32>]
 [[-CrlPeriod] <String>] [[-CrlPeriodUnits] <Int32>] [[-CrlDeltaPeriod] <String>]
 [[-CrlDeltaPeriodUnits] <Int32>] [-OverwriteKey] [-OverwriteDb] [-OverwriteInAd] [[-ADCSPath] <String>]
 [[-DbPath] <String>] [[-DbLogPath] <String>] [<CommonParameters>]
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

### -ADCSPath
{{ Fill ADCSPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 21
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowAdminInteraction
{{ Fill AllowAdminInteraction Description }}

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

### -AssurancePolicyName
{{ Fill AssurancePolicyName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssurancePolicyNotice
{{ Fill AssurancePolicyNotice Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssurancePolicyOid
{{ Fill AssurancePolicyOid Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssurancePolicyUrl
{{ Fill AssurancePolicyUrl Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoDetectAssurancePolicy
{{ Fill AutoDetectAssurancePolicy Description }}

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

### -BasicConstraintsIsCritical
{{ Fill BasicConstraintsIsCritical Description }}

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

### -CaCertValidityPeriod
{{ Fill CaCertValidityPeriod Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaCertValidityPeriodUnits
{{ Fill CaCertValidityPeriodUnits Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaCommonName
{{ Fill CaCommonName Description }}

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

### -CaDnSuffix
{{ Fill CaDnSuffix Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaType
{{ Fill CaType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: EnterpriseRootCA, EnterpriseSubordinateCA, StandaloneRootCA, StandaloneSubordinateCA

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CpsNotice
{{ Fill CpsNotice Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CpsOid
{{ Fill CpsOid Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CpsUrl
{{ Fill CpsUrl Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlDeltaPeriod
{{ Fill CrlDeltaPeriod Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 19
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlDeltaPeriodUnits
{{ Fill CrlDeltaPeriodUnits Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlPeriod
{{ Fill CrlPeriod Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlPeriodUnits
{{ Fill CrlPeriodUnits Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CryptoProvider
{{ Fill CryptoProvider Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DbLogPath
{{ Fill DbLogPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 23
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DbPath
{{ Fill DbPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 22
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EkuOids
{{ Fill EkuOids Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EkuSectionIsCritical
{{ Fill EkuSectionIsCritical Description }}

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

### -EnableBasicConstraints
{{ Fill EnableBasicConstraints Description }}

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

### -Hash
{{ Fill Hash Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeAllIssuancePolicy
{{ Fill IncludeAllIssuancePolicy Description }}

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

### -IncludeAssurancePolicy
{{ Fill IncludeAssurancePolicy Description }}

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

### -KeyLength
{{ Fill KeyLength Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverwriteDb
{{ Fill OverwriteDb Description }}

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

### -OverwriteInAd
{{ Fill OverwriteInAd Description }}

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

### -OverwriteKey
{{ Fill OverwriteKey Description }}

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

### -PathLength
{{ Fill PathLength Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RootCaForcePolicy
{{ Fill RootCaForcePolicy Description }}

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

### System.Object
## NOTES

## RELATED LINKS
