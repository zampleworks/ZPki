---
external help file: PsZPki.psm1-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Install-ZPkiCa

## SYNOPSIS
Install and configure ADCS on the local machine.

## SYNTAX

```
Install-ZPkiCa [[-CaCommonName] <String>] [[-CaDnSuffix] <String>] [[-CaType] <String>] [[-KeyLength] <Int32>]
 [[-CryptoProvider] <String>] [-AllowAdminInteraction] [[-Hash] <String>] [-AltSignatureAlgorithm]
 [-EnableBasicConstraints] [-BasicConstraintsIsCritical] [[-PathLength] <String>] [[-EkuOids] <String[]>]
 [-EkuSectionIsCritical] [[-CpsNotice] <String>] [[-CpsOid] <String>] [[-CpsUrl] <String>]
 [-IncludeAllIssuancePolicy] [-IncludeAssurancePolicy] [-AutoDetectAssurancePolicy]
 [[-AssurancePolicyName] <String>] [[-AssurancePolicyOid] <String>] [[-AssurancePolicyNotice] <String>]
 [[-AssurancePolicyUrl] <String>] [-RootCaForcePolicy] [[-CaCertValidityPeriod] <String>]
 [[-CaCertValidityPeriodUnits] <Int32>] [[-CrlPeriod] <String>] [[-CrlPeriodUnits] <Int32>]
 [[-CrlDeltaPeriod] <String>] [[-CrlDeltaPeriodUnits] <Int32>] [-OverwriteKey] [-OverwriteDb] [-OverwriteInAd]
 [-ForceUTF8] [[-ADCSPath] <String>] [[-DbPath] <String>] [[-DbLogPath] <String>] [-NotReally]
 [<CommonParameters>]
```

## DESCRIPTION
Install and configure ADCS on the local machine. Most parameters have sane default values, but you definitely want to change CaCommonName.

## EXAMPLES

### Example 1
```powershell
PS C:\> Install-ZPkiCa
```

## PARAMETERS

### -ADCSPath
Root path of ADCS directory. This will contain (by default) subdirectories for ADCS database, 
log file, requests, web repository, etc.

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
This switch is required if you want to store CA keys on HSM

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

### -AltSignatureAlgorithm
{{ Fill AltSignatureAlgorithm Description }}

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
Used together with -AutoDetectAssurancePolicy. Find the given Assurance Policy OID in
Active Directory by matching AssurancePolicyName.

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
Text Notice for Assurance Policy

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
Assurance Policy OID for CA certificate.

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
URL for Assurance Policy

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
Use this together with AssurancePolicyName to find Assurance Policy OID in Active Directory.

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
Mark Basic Constraints extension as critical

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
Validity for CA certificate

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
Validity for CA certificate

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
Common Name for CA

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
Distinguished Name suffix for ADCS. Used when publishing CA in ADDS.

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
CA installation type. Valid values: EnterpriseRootCA, EnterpriseSubordinateCA, StandaloneRootCA, StandaloneSubordinateCA

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
Text notice for CPS

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
Oid for CPS

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
URL for CPS

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
Delta period for CRL

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
Delta period for CRL

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
Validity period for CRL

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
Validity period for CRL

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
Specify which cryptographic provider to use. Can also be used to specify key algorithm. 
For example to use ECC keys, set -CryptoProvider to "ECDSA_P256#Microsoft Software Key Storage Provider"
and -KeyLength 256

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
Path to ADCS database log directory

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
Path to ADCS database directory

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
Add these OIDs to Extended Key Usage extension

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
Mark Extended Key Usage extension as critical

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
Include Basic Constraints

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

### -ForceUTF8
{{ Fill ForceUTF8 Description }}

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
Choose hash algorithm

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
Include All Issuance Policy OID in certificate

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
Include Assurance Policy in certificate

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
Key length for CA private key

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

### -NotReally
{{ Fill NotReally Description }}

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

### -OverwriteDb
You may need to use this if you are reinstalling ADCS, for example after a failed install.

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
You may need to use this if you are reinstalling an ADCS instance from backup, for example after upgrading Operating System.

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
You may need to use this if you are reinstalling ADCS, for example after a failed install.

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
Number to use for Path Length Constraint extension. 0 means this CA can only issue End Entity certificates.

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
Normally you should not include any policies in a root CA certificate. Use this switch to force inclusion of policies.

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
