---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Install-ZPkiCa

## SYNOPSIS
Install and configure an ADCS based CA.

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
This cmdlet will
1.
Install ADCS role
2.
Create local directories for ADCS content
3.
Create CAPolicy.inf and copy to C:\Windows
4.
Configure CA and generate CA cert or cert request

If this is a sub CA, get the signed CA cert from superior CA and
install it with the Install-ZPkiCaCertificate cmdlet.

Next step is typically running Set-ZPkiCaPostInstallConfig.

Author anders !Ä!T!
runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ADCSPath
Root directory for ADCS files

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 21
Default value: C:\ADCS
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowAdminInteraction
Require admin interaction on each key use.

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

### -AssurancePolicyName
Assurance policy name, used for Autodetect of Assurance policy.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: Low Assurance
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssurancePolicyNotice
Notice text for Assurance Policy

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
Assurance policy OID

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
URL for Assurance policy document

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
For a domain joined CA server we can determine the OID to use 
if AssurancePolicyName is given and such a policy has been
created in AD already.

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

### -BasicConstraintsIsCritical
{{ Fill BasicConstraintsIsCritical Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaCertValidityPeriod
Validity period for CA certificate

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 15
Default value: Years
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaCertValidityPeriodUnits
Validity period for CA certificate

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: 20
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaCommonName
CN in CA certificate Subject

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: ZampleWorks CA v1
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaDnSuffix
Distinguished name suffix for CA certificate Subject

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: O = ZampleWorks, C = SE
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaType
CA type.
Valid values: "EnterpriseRootCA","EnterpriseSubordinateCA","StandaloneRootCA", or "StandaloneSubordinateCA"

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: EnterpriseRootCA, EnterpriseSubordinateCA, StandaloneRootCA, StandaloneSubordinateCA

Required: False
Position: 2
Default value: EnterpriseRootCA
Accept pipeline input: False
Accept wildcard characters: False
```

### -CpsNotice
Notice text for CPS extension

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
OID for CPS

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
URI for CPS document

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
CRL Delta validity period

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 19
Default value: Days
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlDeltaPeriodUnits
CRL Delta validity period

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlPeriod
CRL validity period

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hours, Days, Weeks, Months, Years

Required: False
Position: 17
Default value: Weeks
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrlPeriodUnits
CRL validity period

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -CryptoProvider
CSP or KSP provider to use for key storage.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Microsoft Software Key Storage Provider
Accept pipeline input: False
Accept wildcard characters: False
```

### -DbLogPath
Transaction log directory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 23
Default value: C:\ADCS\DbLog
Accept pipeline input: False
Accept wildcard characters: False
```

### -DbPath
Database directory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 22
Default value: C:\ADCS\Db
Accept pipeline input: False
Accept wildcard characters: False
```

### -EkuOids
OID strings to include in EKU section

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
Mark EKU section as critical

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

### -EnableBasicConstraints
Enableds Basic Constraints extension in CA certificate.
Defaults to true.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hash
Hash algorithm to use.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: SHA256
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeAllIssuancePolicy
Include All Issuance Policy in CA certificate

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeAssurancePolicy
Include an Assurance policy in CA certificate.
Requires Autodetect or policy definition using appropriate parameters.

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

### -KeyLength
CA Private key length

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 2048
Accept pipeline input: False
Accept wildcard characters: False
```

### -OverwriteDb
If reinstalling ADCS this parameter may be needed

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

### -OverwriteInAd
If reinstalling ADCS this parameter may be needed

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

### -OverwriteKey
If reinstalling ADCS this parameter may be needed

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

### -PathLength
Default CA type is Enterprise root, so appropriate PathLength is 0 (meaning no sub CA can be issued)
Valid input for PathLength is an integer \>= 0, or 'None' to remove constraint.
PathLength = None and EnableBasicConstraints = $True will still include the attribute in the cert.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -RootCaForcePolicy
By default policy entries are disallowed in root certificates.
Include this parameter to force inclusion of policy in root cert.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
