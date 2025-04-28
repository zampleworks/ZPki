<#PSScriptInfo

.VERSION 0.3.3.0

.GUID d974d680-897c-4998-b628-df6b889a9f98

.AUTHOR Anders Runesson

.COMPANYNAME ZampleWorks

.COPYRIGHT (c) Anders Runesson

.TAGS 

.LICENSEURI 

.PROJECTURI https://github.com/zampleworks/ZPki

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#> 





























<#
.DESCRIPTION
Exported functions for ZPki module

#> 

#Requires -Version 5

$ErrorActionPreference = "stop"

$CertSrvDir = "C:\Windows\System32\CertSrv\CertEnroll"
$CertSvcRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration"

$DefaultCss = "*,::after,::before{box-sizing:border-box}blockquote,body,dd,dl,figure,h1,h2,h3,h4,p{margin:0}ol[role=list],ul[role=list]{list-style:none}html:focus-within{scroll-behavior:smooth}body{min-height:100vh;text-rendering:optimizeSpeed;line-height:1.5}a:not([class]){text-decoration-skip-ink:auto}img,picture{max-width:100%;display:block}button,input,select,textarea{font:inherit}@media (prefers-reduced-motion:reduce){html:focus-within{scroll-behavior:auto}*,::after,::before{animation-duration:0s!important;animation-iteration-count:1!important;transition-duration:0s!important;scroll-behavior:auto!important}}body{font-family:sans-serif}table{border-collapse:collapse}th{border-bottom:2px #ddd solid;text-align:left}td{border-bottom:1px #ddd solid;min-height:3em;padding-right:2em}.container{margin-left:1em;margin-right:1em;margin-bottom:3em;padding:1em}"

Function Install-ZPkiCa {
# .ExternalHelp PsZPki-help.xml

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidDefaultValueSwitchParameter", "")]
    Param(
        # CN in CA certificate Subject
        [string]
        $CaCommonName = "ZampleWorks CA v1",

        # Distinguished name suffix for CA certificate Subject
        [string]
        $CaDnSuffix = "O = ZampleWorks, C = SE",

        # CA type. Valid values: "EnterpriseRootCA","EnterpriseSubordinateCA","StandaloneRootCA", or "StandaloneSubordinateCA"
        [string]
        [ValidateSet("EnterpriseRootCA","EnterpriseSubordinateCA","StandaloneRootCA","StandaloneSubordinateCA")]
        $CaType = "EnterpriseRootCA",

        # CA Private key length
        [int]
        $KeyLength = 2048,

        # CSP or KSP provider to use for key storage.
        [string]
        $CryptoProvider = "RSA#Microsoft Software Key Storage Provider",

        # Require admin interaction on each key use.
        [switch]
        $AllowAdminInteraction,

        # Hash algorithm to use.
        [string]
        $Hash = "SHA256",

        [Switch]
        $AltSignatureAlgorithm,

        # Enableds Basic Constraints extension in CA certificate. Defaults to true.
        [switch]
        $EnableBasicConstraints = $True,
        [switch]
        $BasicConstraintsIsCritical = $True,

        <#
          Default CA type is Enterprise root, so appropriate PathLength is 0 (meaning no sub CA can be issued)
          Valid input for PathLength is an integer >= 0, or 'None' to remove constraint.
          PathLength = None and EnableBasicConstraints = $True will still include the attribute in the cert.
        #>
        [string]
        [Parameter(Mandatory=$False)]
        $PathLength = 0,

        # OID strings to include in EKU section
        [string[]]
        $EkuOids,

        # Mark EKU section as critical
        [switch]
        $EkuSectionIsCritical,

        # Notice text for CPS extension
        [string]
        $CpsNotice,

        # OID for CPS
        [string]
        $CpsOid,

        # URI for CPS document
        [string]
        $CpsUrl,

        # Include All Issuance Policy in CA certificate
        [switch]
        $IncludeAllIssuancePolicy,

        # Include an Assurance policy in CA certificate. Requires Autodetect or policy definition using appropriate parameters.
        [switch]
        $IncludeAssurancePolicy,

        <#
            For a domain joined CA server we can determine the OID to use
            if AssurancePolicyName is given and such a policy has been
            created in AD already.
        #>
        [switch]
        $AutoDetectAssurancePolicy,

        # Assurance policy name, used for Autodetect of Assurance policy.
        [string]
        $AssurancePolicyName = "Low Assurance",

        # Assurance policy OID
        [string]
        $AssurancePolicyOid,

        # Notice text for Assurance Policy
        [string]
        $AssurancePolicyNotice,

        # URL for Assurance policy document
        [string]
        $AssurancePolicyUrl,

        # By default policy entries are disallowed in root certificates. Include this parameter to force inclusion of policy in root cert.
        [switch]
        $RootCaForcePolicy,

        # Validity period for CA certificate
        [string]
        [ValidateSet("Hours","Days","Weeks","Months", "Years")]
        $CaCertValidityPeriod = "Years",

        # Validity period for CA certificate
        [int]
        $CaCertValidityPeriodUnits = 20,

        # CRL validity period
        [string]
        [ValidateSet("Hours","Days","Weeks","Months", "Years")]
        $CrlPeriod = "Weeks",

        # CRL validity period
        [int]
        $CrlPeriodUnits = 1,

        # CRL Delta validity period
        [string]
        [ValidateSet("Hours","Days","Weeks","Months", "Years")]
        $CrlDeltaPeriod = "Days",

        # CRL Delta validity period
        [int]
        $CrlDeltaPeriodUnits = 0,

        # If reinstalling ADCS this parameter may be needed
        [switch]
        $OverwriteKey,

        # If reinstalling ADCS this parameter may be needed
        [switch]
        $OverwriteDb,

        # If reinstalling ADCS this parameter may be needed
        [switch]
        $OverwriteInAd,

        [switch]
        $ForceUTF8,

        # Root directory for ADCS files
        [string]
        $ADCSPath = "C:\ADCS",

        # Database directory
        [string]
        $DbPath = "C:\ADCS\Db",

        # Transaction log directory
        [string]
        $DbLogPath = "C:\ADCS\DbLog",

        # Only log planned changes, don't make any changes
        [switch]
        $NotReally
    )

    If(-Not (Test-IsAdmin)) {
        Write-Error "This cmdlet requires admin privileges to run."
        return
    }

    #$IsRoot = $CaType -like "*root*"
    $IsStandalone = $CaType -like "*standalone*"

    Write-Verbose "Enumerating crypto providers.."
    # Command will give more than actual providers, but never mind. Command might not work if matching on "*Name: " if language is not english.
    $InstalledProviders = certutil -csplist | Where-Object { $_ -like "*: *" } | ForEach-Object { $_.Substring($_.IndexOf(":") + 2) }

    $CspShort = $CryptoProvider
    If($CryptoProvider -like "*#*") {
        $CspShort = $CryptoProvider -split  "#" | Select-Object -Last 1
    }

    If($InstalledProviders -notcontains $CspShort) {
        Write-Verbose "Crypto provider supplied, but provider is not installed on system."
        Write-Verbose "Selected provider: [$CryptoProvider]. Installed providers: "
        Foreach($p in $InstalledProviders) {
            Write-Verbose "[$p]"
        }
        Write-Error "Crypto provider [$CryptoProvider] not found. Exiting."
    }

    Try {
        If($PathLength -ne "None") {
            $plInt = [int] $PathLength
            if($plInt -lt 0) {
                throw "PathLength must be greater than or equal to 0!"
            }
        }
    } Catch {
        Write-Error "Path length must be either 'None', or an integer value of 0 or greater. $($_.Exception.Message)"
    }

    #TODO: remove requirement for AD PS module"
    If(-Not $IsStandalone) {
        Write-Progress -Activity "Installing AD tools"
        Install-WindowsFeature RSAT-AD-Tools -IncludeAllSubFeature | Out-Null
    }

    Write-Progress -Activity "Generating CAPolicy.inf"

    $AllIssuancePolicyOid = "2.5.29.32.0"

    Write-Verbose "Validating Assurance Policy options.."
    If($AutoDetectAssurancePolicy -and -Not $IncludeAssurancePolicy) {
        Write-Error "AutoDetectAssurancePolicy is true, but IncludeAssurancePolicy is false."
        return
    }

    If($AutoDetectAssurancePolicy -and [string]::IsNullOrWhiteSpace($AssurancePolicyName)) {
        Write-Error "If AutoDetectAssurancePolicy is true, AssurancePolicyName must contain the name of an existing (or well-known) policy object in AD."
        return
    }

    If($IncludeAssurancePolicy -and $AutoDetectAssurancePolicy) {
        If(-Not (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain -eq $True) {
            Write-Error "AutoDetectAssurancePolicy can only be used on a domain-joined system."
            return
        }

        $Ap = get-adobject -filter {displayname -eq $AssurancePolicyName} -searchbase "CN=OID,CN=Public Key Services,CN=Services,CN=Configuration,$(Get-AdRootDse | Select-Object -expand rootDomainNamingContext)" -properties displayname,name,mspki-cert-template-oid | Select-Object mspki-cert-template-oid,displayname
        $AssurancePolicyOid = $Ap.'mspki-cert-template-oid'
        If([string]::IsNullOrWhiteSpace($AssurancePolicyOid)) {
            $WellKnownAssurancePolicies = @{
                "High Assurance" = 402;
                "Medium Assurance" = 401;
                "Low Assurance" = 400;
            }
            If($AssurancePolicyName -notin $WellKnownAssurancePolicies.Keys) {
                Write-Error "$AssurancePolicyName could not be found. Ensure that this is a registered policy OID, or one of the well-known ADCS policies: 'High Assurance', 'Medium Assurance', or 'Low Assurance'."
                return
            }
            $ForestOid = Get-ZPkiAdForestOid

            If([string]::IsNullOrWhiteSpace($ForestOid)) {
                Write-Error "Failed to determine Assurance policy OID."
                return
            }

            $AssurancePolicyOid = "{0}.1.{1}" -f $ForestOid, $WellKnownAssurancePolicies[$AssurancePolicyName]
        }
    }

    Write-Verbose "Validating CPS options.."
    $EnableCps = (-Not [string]::IsNullOrWhiteSpace($CpsOid)) -and $CpsOid.Length -gt 0
    If($EnableCps) {
        If([string]::IsNullOrWhiteSpace($CpsUrl) -and [string]::IsNullOrWhiteSpace($CpsNotice)) {
            Write-Error "If you want a CPS section in certificate you must include either CpsUrl or CpsNotice, or both."
        }
    }

    Write-Verbose "Validating CA type.."
    
    If($CaType -eq "StandaloneRootCA" -and ($EnableCps -Or $IncludeAssurancePolicy -or $IncludeAllIssuancePolicy) -And -not $RootCaForcePolicy) {
        Write-Error "Policy attributes should not be set in root CA certs. Use -RootCaForcePolicy to override."
    }

    Write-Verbose "Validating EKU options.."
    $EnableEkuSection = $Null -ne $EkuOids -And $EkuOids.Count -gt 0
    If($EnableEkuSection) {
        Foreach($eku in $EkuOids) {
            If($eku -eq "Oid1" -or $eku -eq "Oid2") {
                Write-Error "EnhancedKeyUsageExtension is enabled, but oid list is left with defaults. `$EkuOids must be updated with real OID values you need on your CA."
            }
        }
    }

    Write-Verbose "Creating CAPolicy.inf CertSrv section"
    $HeaderSection = Get-CaPolicyHeaderSection

    $CertSrvSection = Get-CaPolicyCertSrvSection -Keylength $Keylength -CACertValidityPeriod $CACertValidityPeriod -CACertValidityPeriodUnits $CACertValidityPeriodUnits `
                                                -CRLPeriod $CRLPeriod -CRLPeriodUnits $CRLPeriodUnits -DeltaPeriod $CrlDeltaPeriod -DeltaPeriodUnits $CrlDeltaPeriodUnits `
                                                -LoadDefaultTemplates $False -AltSignatureAlgorithm $AltSignatureAlgorithm `
                                                -ForceUTF8 $ForceUTF8 -EnableKeyCounting $False -ClockSkewMinutes 0


    $CpsSection = ""
    $AssuranceSection = ""
    $AllIssuanceSection = ""

    $PolicyExtensionsSection = ""
    $BasicConstraintsSection = ""
    $EkuSection = ""

    $SectionNames = ""

    If($EnableCps) {
        Write-Verbose "Creating CAPolicy.inf CPS section"
        $CpsSection = Get-CaPolicyPolicySection -PolicyName "CPS" -PolicyOid $CpsOid -PolicyNotice $CpsNotice -PolicyUrl $CpsURL
        $SectionNames = "CPS"
    }

    If($IncludeAssurancePolicy) {
        Write-Verbose "Creating CAPolicy.inf Assurance Policy section"
        $AssuranceSection = Get-CaPolicyPolicySection -PolicyName "AssurancePolicy" -PolicyOid $AssurancePolicyOid -PolicyNotice $AssurancePolicyNotice -PolicyUrl $AssurancePolicyURL
        $SectionNames = "$SectionNames,AssurancePolicy".Trim(',')
    }

    If($IncludeAllIssuancePolicy) {
        Write-Verbose "Creating CAPolicy.inf All Issuance section"
        $AllIssuanceSection = Get-CaPolicyPolicySection -PolicyName "AllIssuancePolicy" -PolicyOid $AllIssuancePolicyOid
        $SectionNames = "$SectionNames,AllIssuancePolicy".Trim(',')
    }

    If($EnableBasicConstraints) {
        Write-Verbose "Creating CAPolicy.inf Basic Constraints section"
        $BasicConstraintsSection = Get-CaPolicyBasicConstraintsSection -PathLength $PathLength -Critical $BasicConstraintsIsCritical
    }

    If($EnableEkuSection) {
        Write-Verbose "Creating CAPolicy.inf EKU section"
        $EkuSection = Get-CaPolicyEkuSection -Oids $EkuOids -Critical $EkuSectionIsCritical
    }

    Write-Verbose "Creating CAPolicy.inf Policy Extension section"
    $PolicyExtensionsSection = Get-CaPolicyPolicyExtensionsSection -Sections $SectionNames

    $CaPolicyContent = $HeaderSection, $PolicyExtensionsSection, $CpsSection, $AssuranceSection, $AllIssuanceSection, $EkuSection, $BasicConstraintsSection, $CertSrvSection

    If($NotReally) {
        Write-Verbose "Generated CAPolicy.inf: "
        $CaPolicyContent | Write-Verbose 
    } Else {
        $CaPolicyContent | Out-File ".\CAPolicy.inf" -Force
        Copy-Item .\CAPolicy.inf C:\Windows -Force
        Write-Verbose ""
        Write-Verbose "Created CAPolicy.inf and copied it to C:\Windows"
    }

    # CAPolicy.inf reference document
    # https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc737264(v=ws.10)

    # Prep - ADCS Deployment module needs to be installed and imported

    Write-Progress -Activity "Creating local directories for ADCS"

    $FilePublishPath = "$ADCSPath\Web\Repository"
    $DocsPath = "$ADCSPath\Web\Docs"
    $ReqsPath = "$ADCSpath\Requests"
    $SignedPath = "$ADCSPath\Signed"
    $BackupsPath = "$ADCSPath\Backup"

    New-ADCSPath -PathName "Base directory" -Path $ADCSPath
    New-ADCSPath -PathName "AIA/CDP Repository" -Path $FilePublishPath
    New-ADCSPath -PathName "Db directory" -Path $DbPath
    New-ADCSPath -PathName "Db log directory" -Path $DbLogPath
    New-ADCSPath -PathName "Policy and documents directory" -Path $DocsPath
    New-ADCSPath -PathName "Certificate requests directory" -Path $ReqsPath
    New-ADCSPath -PathName "Signed certificates directory" -Path $SignedPath
    New-ADCSPath -PathName "Backup directory" -Path $BackupsPath

    If($NotReally) {
        Write-Verbose "Would have installed ADCS Windows role"
    } Else {
        Write-Progress -Activity "Installing ADCS windows role"
        Write-Verbose "Installing ADCS Windows role"
    
        Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools | Out-Null
        Import-Module ADCSDeployment
        Write-Progress -Activity "Installing ADCS"
        Write-Verbose "Installing $($CAType)"
    }
    
    If($NotReally) {
        Write-Verbose ""
        Write-Verbose "Would have installed a CA with the following settings: "
        Write-Verbose ""
        
        Write-Verbose "CA Type: $CAType"
        Write-Verbose "CA Subject Name: $CaCommonName,$CaDnSuffix"
        Write-Verbose "Key length & provider: $KeyLength, $CryptoProvider"
        Write-Verbose "Admin interaction: $AllowAdminInteraction"
        Write-Verbose "Hash: $Hash"
        Write-Verbose "Validity: $CACertValidityPeriodUnits $CACertValidityPeriod"
        Write-Verbose "DB directory: $DbPath"
        Write-Verbose "DB Log directory: $DbLogPath"
        Write-Verbose "Web repository path: $FilePublishPath"
        Write-Verbose "Overwrite existing key: $OverwriteKey"
        Write-Verbose "Overwrite existing DB: $OverwriteDB"
        Write-Verbose "Overwrite existing AD CA: $OverwriteInAd"

        Return
    }

    $Result = 0
    Try {
        Switch($CAType) {
            "EnterpriseRootCA" {
                If($AllowAdminInteraction) {
                    $Result = Install-AdcsCertificationAuthority -ValidityPeriod $CACertValidityPeriod -ValidityPeriodUnits $CACertValidityPeriodUnits `
                    -DatabaseDirectory $DbPath -LogDirectory $DbLogPath -CAType EnterpriseRootCA -HashAlgorithmName $Hash -KeyLength $Keylength `
                    -CACommonName $CaCommonName -CADistinguishedNameSuffix $CaDnSuffix -AllowAdministratorInteraction $AllowAdminInteraction -CryptoProviderName $CryptoProvider `
                    -OverwriteExistingKey:$OverwriteKey -OverwriteExistingDatabase:$OverwriteDb -OverwriteExistingCAinDS:$OverwriteInAd -Confirm:$false
                } Else {
                    $Result = Install-AdcsCertificationAuthority -ValidityPeriod $CACertValidityPeriod -ValidityPeriodUnits $CACertValidityPeriodUnits `
                    -DatabaseDirectory $DbPath -LogDirectory $DbLogPath -CAType EnterpriseRootCA -HashAlgorithmName $Hash -KeyLength $Keylength `
                    -CACommonName $CaCommonName -CADistinguishedNameSuffix $CaDnSuffix -CryptoProviderName $CryptoProvider `
                    -OverwriteExistingKey:$OverwriteKey -OverwriteExistingDatabase:$OverwriteDb -OverwriteExistingCAinDS:$OverwriteInAd -Confirm:$false
                }
            }

            "EnterpriseSubordinateCA" {
                Write-Verbose "This installation step may produce a message that looks like an error"
                If($AllowAdminInteraction) {
                    $Result = Install-AdcsCertificationAuthority  `
                    -DatabaseDirectory $DbPath -LogDirectory $DbLogPath -CAType EnterpriseSubordinateCA -HashAlgorithmName $Hash -KeyLength $KeyLength `
                    -CACommonName $CaCommonName -CADistinguishedNameSuffix $CaDnSuffix -AllowAdministratorInteraction $AllowAdminInteraction -CryptoProviderName $CryptoProvider `
                    -OverwriteExistingKey:$OverwriteKey -OverwriteExistingDatabase:$OverwriteDb -OverwriteExistingCAinDS:$OverwriteInAd `
                    -OutputCertRequestFile "$AdcsPath\CACert.req" -Confirm:$false
                } Else {
                    $Result = Install-AdcsCertificationAuthority  `
                    -DatabaseDirectory $DbPath -LogDirectory $DbLogPath -CAType EnterpriseSubordinateCA -HashAlgorithmName $Hash -KeyLength $KeyLength `
                    -CACommonName $CaCommonName -CADistinguishedNameSuffix $CaDnSuffix -OutputCertRequestFile "$AdcsPath\CACert.req" -Confirm:$false `
                    -OverwriteExistingKey:$OverwriteKey -OverwriteExistingDatabase:$OverwriteDb -OverwriteExistingCAinDS:$OverwriteInAd -CryptoProviderName $CryptoProvider
                }
            }

            "StandaloneRootCA" {
                If($AllowAdminInteraction) {
                    $Result = Install-AdcsCertificationAuthority -ValidityPeriod $CACertValidityPeriod -ValidityPeriodUnits $CACertValidityPeriodUnits `
                    -DatabaseDirectory $DbPath -LogDirectory $DbLogPath -CAType StandaloneRootCA -HashAlgorithmName $Hash -KeyLength $KeyLength `
                    -CACommonName $CaCommonName -CADistinguishedNameSuffix $CaDnSuffix -AllowAdministratorInteraction $AllowAdminInteraction -CryptoProviderName $CryptoProvider `
                    -OverwriteExistingKey:$OverwriteKey -OverwriteExistingDatabase:$OverwriteDb -OverwriteExistingCAinDS:$OverwriteInAd -Confirm:$false
                } Else {
                    $Result = Install-AdcsCertificationAuthority -ValidityPeriod $CACertValidityPeriod -ValidityPeriodUnits $CACertValidityPeriodUnits `
                    -DatabaseDirectory $DbPath -LogDirectory $DbLogPath -CAType StandaloneRootCA -HashAlgorithmName $Hash -KeyLength $KeyLength `
                    -CACommonName $CaCommonName -CADistinguishedNameSuffix $CaDnSuffix `
                    -OverwriteExistingKey:$OverwriteKey -OverwriteExistingDatabase:$OverwriteDb -OverwriteExistingCAinDS:$OverwriteInAd -Confirm:$false
                }
            }

            "StandaloneSubordinateCA" {
                Write-Warning "This installation step may produce a message that looks like an error"
                Write-Error "Not implemented: StandaloneSubordinateCA"
            }

            Default {
                Write-Error "No CA type selected: [$CAType]"
            }
        }
    } Catch {
        Write-Warning "Error running ADCS install command: $($_.Exception.Message)"
        $Prms = @{
            'CaType' = $CAType
            'AdcsPath' = $AdcsPath
            'AdcsRepoPath' = $FilePublishPath
            'IncludeAllIssuance' = $IncludeAllIssuancePolicy
            'IncludeAssurance' = $IncludeAssurancePolicy
            'CaCommonName' = $CaCommonName
            'CaDnSuffix' = $CaDnSuffix
            'DbPath' = $DbPath
            'DbLogPath' = $DbLogPath
            'CACertValidityPeriod' = $CACertValidityPeriod
            'CACertValidityPeriodUnits' = $CACertValidityPeriodUnits
            'Hash' = $Hash
            'KeyLength' = $KeyLength
            'CryptoProvider' = $CryptoProvider
            'AllowAdminInteraction' = $AllowAdminInteraction
            'OverwriteKey' = $OverwriteKey
            'OverwriteDb' = $OverwriteDb
            'OverwriteInAd' = $OverwriteInAd
        }
        Write-Warning "Installation parameters:"
        $Prms
    }

    If($Result.ErrorId -eq 398) {
        Write-Verbose ""
        Write-Verbose "The configuration was succcessful, but will not be complete until you install the signed CA certificate."
        Write-Verbose "Copy the file [$AdcsPath\CACert.req] to the root CA and sign it. When it is signed, place the signed"
        Write-Verbose "certificate in the [$FilePublishPath] directory. Then run the following cmdlet to finish installing the certificate: "
        Write-Verbose ":\> Install-ZPkiCaCertificate -CertFile <file>"
        Write-Verbose ""
    } ElseIf($Result.ErrorId -ne 0 -And $Result.ErrorId -ne 398) {
        Write-Error "CA Installation result: [$Result]"
    }

}

<#
    .SYNOPSIS
    Installs a signed CA certificate for this CA

    .DESCRIPTION
    This is used when installing a subordinate CA. The installation generates a
    Certificate Signing Request file that needs to get signed by another CA.
    Use this cmdlet to install the resulting signed certificate.

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Install-ZPkiCaCertificate {

    [CmdletBinding()]
    Param(
        [string]
        $CertFile,

        [switch]
        $SkipCopyToRepository,

        [string]
        $AdcsRepositoryPath = "C:\ADCS\Web\Repository"
    )

    $Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $CertFile

    If($Cert.Issuer -ne $Cert.Subject) {
        $Verified = $Cert.Verify()
        If(-Not $Verified) {
            Write-Verbose "Certificate $CertFile cannot be verified as valid. Ensure that all AIA and CDP paths are valid and accessible."
            Write-Verbose "Test certificate with 'certutil -verify -urlfetch $CertFile' to see which URLs are not responding."
            Write-Verbose "GUI command: 'certutil -url $CertFile' to see which URLs are not responding."
            Write-Verbose ""
            Write-Error "Cannot install CA certificate. Ensure CA certificate chain validates before running this command again."
        }
    }

    $CertUtilOutput = certutil -Installcert "$CertFile"

    If(-Not $?) {
        Write-Verbose $CertUtilOutput
        Write-Error "CA certificate install command failed"
    }

    Restart-Service certsvc
}

<#
    .SYNOPSIS
    Generates a HTML index file for CDP/AIA repository

    .DESCRIPTION
    This cmdlet will generate a helpful HTML page containing web links to all CA certificates and CRL files in the given
    directory (SourcePath). You can include Javascript/CSS files of your choosing by using the CssFiles/JsFiles parameters.
    You can generate a default CSS file with the New-ZPkiRepoCssFile.

    Recommendation: create both binary and PEM versions of each cert in the source directory.
    Follow this naming standard: cacert.crt and cacert.pem.crt. If you do the pem versions will
    be included on the same table row.

    The cmdlet assumes the following layout of files in the generated HTML:
    -> index.html
    -> Repository/
       -> cacert.crt
       -> cacert.pem.crt

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>

Function New-ZPkiRepoIndex {
    [CmdletBinding(ConfirmImpact='Medium', SupportsShouldProcess=$true)]
    Param(
        <#
            This directory will be scanned for crt/cer/crl files.
            It is assumed that files will be in a subdirectory named 'Repository' relative to the index.html file.
        #>
        [string]
        $Sourcepath = ".\",

        # Path for generated index file.
        [string]
        $IndexFile = "index.html",

        # Style sheet to include in html
        [string[]]
        $CssFiles,

        # Javascript to include in html
        [string[]]
        $JsFiles,

        # HTML title tag
        [string]
        $PageTitle = "PKI Repository",

        # HTML h1 tab
        [string]
        $PageHeader = "PKI Repository",

        # HTML header for the CA certs section
        [string]
        $CertsHeader = "CA Certificates",

        # HTML header for the CA CRLs section
        [string]
        $CrlsHeader = "CRL files"
    )

    If(Test-Path $IndexFile) {
        If(-Not ($PSCmdlet.ShouldProcess("Overwrite file $IndexFile"))) {
            Write-Output "File $IndexFile exists, will not overwrite. use -Confirm:`$false to avoid confirmation prompts."
            return
        }
    }

    $Certs = @(Get-ChildItem $Sourcepath -Filter "*.cer") + (Get-ChildItem $Sourcepath -Filter "*.crt") + (Get-ChildItem $Sourcepath -Filter "*.pem")
    $Crls = Get-ChildItem $Sourcepath -Filter "*.crl"

    $n = [Environment]::NewLine
    $t = "`t"

    $StyleSheets = $CssFiles | Where-Object { -Not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { Write-Output "$t<link rel=`"stylesheet`" href=`"$_`">$n" }
    $JavaScripts = $JsFiles | Where-Object { -Not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { Write-Output "<script src=`"$_`"></script>$n" }

    $Head = "" +
        "<head>$n" +
            "$t<title>$PageTitle</title>$n" +
            "$t<meta http-equiv=`"Content-type`" content=`"text/html; charset=utf-8`">$n" +
            "$t<meta http-equiv=`"X-UA-Compatible`" content=`"IE=edge`">$n" +
            "$StyleSheets$n" +
        "</head>"

    $PageHeadContainer = "" +
                "$t<div class='row'>$n" +
                    "$t$t<div class='page header page-header col-sm-12'>$n" +
                    "$t$t$t<h1>$PageHeader</h1>$n" +
                    "$t$t</div>$n" +
                "$t</div>$n"

    $Serials = @()
    $CertsTableRows = ""
    If($Certs.Count -gt 0) {
        $XCerts = $Certs | ForEach-Object {
            $c = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $_.FullName
            If($c.Subject -match "[^\w]*CN=([^,]*),?") {
                $Name = $matches[1]
            } else {
                $Name = $c.Subject
            }
            If($c.Issuer -match "[^\w]*CN=([^,]*),?") {
                $Issuer = $matches[1]
            } else {
                $Issuer = $c.Issuer
            }

            If($Serials -contains $c.SerialNumber) {
                Return
            }

            $Serials += @($c.SerialNumber)

            $PemFileName = "{0}\{1}.pem.crt" -f $_.DirectoryName, $_.BaseName
            $HasPem = Test-Path -Path $PemFileName -PathType Leaf

            $Out = New-Object PSObject -Property @{
                    'CertFile' = $_.FullName;
                    'X509' = $c;
                    'Serial' = $c.SerialNumber;
                    'NotAfter' = $c.NotAfter;
                    'Issuer' = $Issuer;
                    'Subject' = $Name;
                    'File' = [Uri]::EscapeUriString($_.Name)
                    'HasPem' = $HasPem
                }

            If($HasPem) {
                $PemFile = Get-ChildItem $PemFileName
                $Out | Add-Member -MemberType NoteProperty -Name "PemFile" -Value ([Uri]::EscapeUriString($PemFile.Name))
            }
            Write-Output $Out
        }
    }

    $CertsTableRows = $XCerts | Sort-Object -property @{ e = { $_.X509.Issuer -eq $_.X509.Subject }; Ascending = $false}, { $_.X509.Subject } | ForEach-Object {

        $LinkOut = If($_.File -match ".*\.pem(\.*)") {
            Write-Output "<a href=`"Repository/{3}`">PEM Format (base64 text)</a>$n"
        } Else {
            Write-Output "<a href=`"Repository/{3}`">DER Format (binary)</a>$n"
        }

        $PemOut = If($_.HasPem) {
            Write-Output "$t$t$t$t$t$t<br />$n$t$t$t$t$t$t<a href=`"Repository/{4}`">PEM Format (base64 text)</a>$n"
        } else { Write-Output "" }

        Write-Output (
            ("$t$t$t$t<tr>$n" +
                "$t$t$t$t$t<td>{0}</td>$n" +
                "$t$t$t$t$t<td>{1}</td>$n" +
                "$t$t$t$t$t<td>{2}</td>$n" +
                "$t$t$t$t$t<td>$n" +
                "$t$t$t$t$t$t$LinkOut" +
                $PemOut +
                "$t$t$t$t$t</td>$n" +
            "$t$t$t$t</tr>$n") -f $_.Subject, $_.Issuer, $_.Serial, $_.File, $_.PemFile
        )
    }

    $CertsListContainer = "" +
                "$t<div class='container row'>$n" +
                    "$t$t<div class='cert header'>$n" +
                    "$t$t$t<h2>$CertsHeader</h2>$n" +
                    "$t$t</div>$n" +
                    "$t$t<div class='cert table col-sm-10'>$n" +
                    "$t$t$t<table class='table table-striped'><thead><th>CA name</th><th>Issuer name</th><th>Serial</th><th>Download link</th></thead>$n" +
                    "$t$t$t$t<tbody>$n" +
                    "$CertsTableRows" +
                    "$t$t$t$t</tbody>$n" +
                    "$t$t$t</table>$n" +
                    "$t$t</div>$n" +
                "$t</div>"

    $CrlsTableRows = $Crls | ForEach-Object {
        #$crl = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        #[byte[]] $crlBytes = Get-Content $_.FullName -Encoding Byte
        #$Crl.Import($crlBytes)

        Write-Output (
            ("$t$t$t$t<tr>$n" +
                "$t$t$t$t$t<td>{0}</td>$n" +
    #            "$t$t$t$t$t<td>{1}</td>$n" +
    #            "$t$t$t$t$t<td>{2}</td>$n" +
                "$t$t$t$t$t<td><a href=`"Repository/{1}`">Download</a></td>$n" +
            "$t$t$t$t</tr>$n") -f $_.BaseName, [uri]::EscapeUriString($_.Name)
        )
    }

    $CrlsListContainer = "" +
                "$t<div class='container row'>$n" +
                    "$t$t<div class='crl header'>$n" +
                    "$t$t$t<h2>$CrlsHeader</h2>$n" +
                    "$t$t</div>$n" +
                    "$t$t<div class='crl table col-sm-10'>$n" +
                    "$t$t$t<table class='table table-striped'>$n" +
                    "$t$t$t<thead><tr><th>CRL file</th><th>Download link</th></tr></thead>$n" +
                    "$t$t$t$t<tbody>$n" +
                    "$CrlsTableRows" +
                    "$t$t$t$t</tbody>$n" +
                    "$t$t$t</table>$n" +
                    "$t$t</div>$n" +
                "$t</div>"

    $Output = "" +
        "<!DOCTYPE html>$n" +
        "<html>$n" +
            "$Head$n" +
            "<body>$n" +
                "<div class='container content'>$n" +
                "$PageHeadContainer$n" +
                "$CertsListContainer$n" +
                "$CrlsListContainer$n" +
                "</div>$n" +
                "$Javascripts$n" +
            "</body>$n" +
        "</html>"

    $Output | Out-File $IndexFile -Force -encoding utf8
}

<#
    .SYNOPSIS
    Generate a new default CSS file for use with HTML repository

    .DESCRIPTION

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function New-ZPkiRepoCssFile {
    [CmdletBinding(ConfirmImpact='Medium', SupportsShouldProcess=$true)]
    Param(
        [string]
        $CssFile = "C:\ADCS\Web\style.css"
    )

    If(Test-Path $CssFile) {
        If(-Not ($PSCmdlet.ShouldProcess("Overwrite file $CssFile"))) {
            Write-Output "File $CssFile exists, will not overwrite. use -Confirm:`$false to avoid confirmation prompts."
            return
        }
    }

    If(Test-Path $CssFile -PathType Container) {
        Remove-Item $CssFile -Recurse
    }

    $DefaultCss | Out-File $CssFile -Force
}

<#
    .SYNOPSIS
    Create a new IIS website to host AIA or CDP Repository

    .DESCRIPTION
    Installs IIS and creates a new IIS site with the given local root path and host header binding.

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function New-ZPkiWebsite {
    [CmdletBinding(ConfirmImpact='Medium', SupportsShouldProcess=$true)]
    Param(
        [string]
        $IisSiteName,

        [string]
        [Parameter(Mandatory=$True)]
        $HttpFqdn,

        [string]
        $LocalPath = "C:\ADCS\Web",

        [switch]
        $InstallWebEnroll
    )

    Write-Progress -Activity "Installing web components"
    Write-Verbose "Installing IIS"

    $IisInstalled = Get-WindowsFeature WebServer | Select-Object -ExpandProperty Installed
    If((-Not $IisInstalled) -And ($PSCmdlet.ShouldProcess("Install IIS"))) {
        Install-WindowsFeature Web-Server -IncludeAllSubFeature -IncludeManagementTools | Out-Null
    }

    Write-Warning "Adding web sites. Remember to update DNS to point to this server."
    
    Import-Module IISAdministration

    If((Get-IISSite | Where-Object { $_.Name -eq $HttpFqdn } | Measure-Object | Select-Object -ExpandProperty Count) -lt 1) {
        If([string]::IsNullOrWhiteSpace($IisSiteName)) {
            $SiteName = $HttpFqdn
        } Else {
            $SiteName = $IisSiteName
        }

        If($PSCmdlet.ShouldProcess("Create new IIS Web site $SiteName")) {
            Write-Verbose "Creating web site named $SiteName with root directory $LocalPath"
            If(-Not (Test-Path $LocalPath)) {
                mkdir -Path $LocalPath -Force
            }

            New-IISSite -Name $HttpFqdn -PhysicalPath $LocalPath -BindingInformation "*:80:$HttpFqdn"
        }
    }
}

<#
    .SYNOPSIS
    Copies files from C:\Windows\system32\certsrv\CertEnroll to CDP/AIA repository.
    Crt files with server name in file name will be renamed to a sane name.

    .DESCRIPTION

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Copy-ZPkiCertSrvFilesToRepo {
    [CmdletBinding()]
    Param(
        # Local repository path to copy files to
        [string]
        $LocalRepositoryPath = "C:\ADCS\Web\Repository",

        # Choose file type to copy: "crl", "crt", or "all".
        [string]
        [ValidateSet("crl","crt","all")]
        $FileType = "all"
    )

    Write-Verbose "Copying CA cert to repository and creating PEM version"
    $CaSubjectName = Get-ItemProperty $CertSvcRegPath -Name Active | Select-Object -ExpandProperty Active

    If($FileType -eq "crl" -or $FileType -eq "crt") {
        $Types = $($FileType)
    } Else {
        $Types = "crl","crt"
    }

    Foreach($Type in $Types) {
        Get-ChildItem -Path $CertSrvDir -Filter "*.$Type" | ForEach-Object {
            $hostname = & hostname
            $base = $_.BaseName
            $Fullname = $_.FullName
            If($Type -eq "crt" -And $Fullname -match "$($hostname).*_$CASubjectName.*\.crt") {
                $NewName = "$LocalRepositoryPath\$($base.Substring($Base.IndexOf("_") + 1)).crt"
                Write-Verbose "Copying crt [$Fullname] to [$Newname]"
                Copy-Item $_.FullName $NewName -Force

                $PemName = $NewName.Replace(".crt", ".pem.crt")
                $Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $NewName
                Export-ZPkiCertAsPem -Cert $Cert -FullName $PemName
            } Elseif($Type -eq "crl") {
                Copy-Item $_.FullName $LocalRepositoryPath -Force
            }
        }
    }
}

<#
    .SYNOPSIS
    Publish cert or CRL file in ADDS

    .DESCRIPTION

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Publish-ZPkiCaDsFile {
    [CmdletBinding()]
    Param(
        # PublishFile CRL or certificate file to publish in AD DS
        [string]
        $PublishFile,

        # CertType Either "RootCA", "SubCA", or "NTAuthCA", "CrossCA", "KRA", "User", "Machine"
        [string]
        [Parameter(ParameterSetName = "Cert")]
        [ValidateSet("RootCA", "SubCA", "NTAuthCA", "CrossCA", "KRA", "User", "Machine")]
        $CertType,

        # CdpContainer CN of ADDS container to create for CRL. Recommended: CA Common Name.
        [string]
        [Parameter(ParameterSetName = "Crl")]
        $CdpContainer,

        # CdpObject CN of ADDS Object to create for CRL. Recommended: CA Common Name.
        [string]
        [Parameter(ParameterSetName = "Crl")]
        $CdpObject
    )

    If(-Not (Test-Path $PublishFile -PathType Leaf)) {
        Write-Error ("File [{0}] not found, please check path and try again." -f $PublishFile)
        return
    }

    $File = Get-Item $PublishFile

    # Publish cert to ADDS AIA Certificate store
    If($PSCmdlet.ParameterSetName -eq "Crl") {
        Write-Verbose "Publishing CRL"
        $Output = certutil -dspublish "$($File.FullName)" $CdpContainer $CdpObject
    } Else {
        Write-Verbose "Publishing certificate to $CertType AD DS store"
        $Output = certutil -dspublish -f "$($File.FullName)" $CertType
    }

    # If command was successful, update local server cert stores with new cert
    If($? -eq $True) {
        Write-Verbose "Added/updated DS objects:"
        $Output | Where-Object { $_ -like "*ldap*" } | ForEach-Object { Write-Verbose $_ }
        Write-Verbose ""
        Write-Verbose "Refreshing local machine certificate stores.."
        gpupdate /force | Out-Null
    } else {
        Write-Error "Error when running publish command: $Output"
    }

}

<#
    .SYNOPSIS
    Performs post-installation configuration tasks.
    Sets registry values for CRL/Delta validity time,
    validity time for issued certs, and sets LDAP path.

    .DESCRIPTION

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Set-ZPkiCaPostInstallConfig {
    [CmdletBinding(ConfirmImpact='Medium', SupportsShouldProcess=$true)]
    Param(

        # Max validity in issued certificates
        [string]
        [ValidateSet("Hours","Days","Weeks","Months", "Years")]
        $IssuedCertValidityPeriod = "Years",

        # Max validity in issued certificates
        [int]
        $IssuedCertValidityPeriodUnits = 1,

        # CRL validity
        [string]
        [ValidateSet("Hours","Days","Weeks","Months", "Years")]
        $CrlPeriod = "Weeks",

        # CRL validity
        [int]
        $CrlPeriodUnits = 26,

        # CRL overlap
        [string]
        [ValidateSet("Hours","Days","Weeks","Months", "Years")]
        $CrlOverlap = "Weeks",

        # CRL overlap
        [int]
        $CrlOverlapUnits = 6,

        # CRL Delta validity
        [string]
        [ValidateSet("Hours","Days","Weeks","Months", "Years")]
        $CrlDeltaPeriod = "Days",

        # CRL Delta validity
        [int]
        $CrlDeltaPeriodUnits = 0,

        # Distinguished Name of configuration partition in AD. Only needed if using LDAP for CDP/AIA publishing
        [string]
        $LdapConfigDn = "default",

        # Path to CDP/AIA repository
        [string]
        $RepositoryLocalPath = "C:\ADCS\Web\Repository",

        [switch]
        $LoadDefaultTemplates,

        # Restart ADCS after running
        [switch]
        $RestartCertSvc
    )

    If(-Not (Test-IsAdmin)) {
        Write-Error "This cmdlet requires admin privileges to run."
        return
    }

    Write-Progress -Activity "Updating registry values"

    If($PSVersionTable.PSVersion.Major -gt 5) {
        $Domain = Get-CimInstance -Class Win32_ComputerSystem | Select-Object -expand Domain    
    } Else {
        $Domain = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -expand Domain
    }

    If(-Not [string]::IsNullOrWhiteSpace($Domain) -and $Domain -ne 'WORKGROUP' -and $LdapConfigDn -eq "default") {
        $LdapConfigDn = Get-ADRootDSE -Server $Domain | Select-Object -ExpandProperty configurationNamingContext
    }

    $CaSubjectName = Get-ItemProperty $CertSvcRegPath -Name Active | Select-Object -ExpandProperty Active

    # Catype 0 = EnterpriseRoot, 1 = EnterpriseSub, 2 = StandaloneRoot, 3 = StandaloneSub
    $CaType = Get-ItemProperty "$CertSvcRegPath\$CaSubjectName" -Name "CAType" | Select-Object -ExpandProperty CAType

    certutil -setreg CA\ValidityPeriodUnits $IssuedCertValidityPeriodUnits | Out-Null
    certutil -setreg CA\ValidityPeriod $IssuedCertValidityPeriod | Out-Null

    certutil -setreg CA\DSConfigDN "$LdapConfigDn" | Out-Null

    certutil -setreg CA\CRLPeriod $CRLPeriod | Out-Null
    certutil -setreg CA\CRLPeriodUnits $CRLPeriodUnits | Out-Null
    certutil -setreg CA\CRLOverlapPeriod $CRLOverlap | Out-Null
    certutil -setreg CA\CRLOverlapUnits $CRLOverlapUnits | Out-Null

    certutil -setreg CA\CRLDeltaPeriod $CrlDeltaPeriod | Out-Null
    certutil -setreg CA\CRLDeltaPeriodUnits $CrlDeltaPeriodUnits | Out-Null

    certutil -setreg CA\AuditFilter 127 | Out-Null
    certutil -setreg CA\UseDefinedCACertInRequest 1 | Out-Null

    Write-Progress -Activity "Removing default templates and restarting certsvc"

    If(-Not $LoadDefaultTemplates -And $CAType -le 2) {
        Write-Verbose "Un-publishing default templates.."
        Get-CATemplate | Remove-CATemplate -AllTemplates -Force
    }

    If($RestartCertSvc) {
        Restart-Service certsvc
    }

    Write-Verbose "Copying CA cert to repository and creating PEM version"

    Get-ChildItem -Path $CertSrvDir -Filter "*.crt" | ForEach-Object {
        $hostname = & hostname
        $base = $_.BaseName
        $Fullname = $_.FullName
        If($Fullname -match "$($hostname).*_$CASubjectName.*\.crt") {
            $NewName = "$RepositoryLocalPath\$($base.Substring($Base.IndexOf("_") + 1)).crt"
            Write-Verbose "Copying crt [$Fullname] to [$Newname]"
            Copy-Item $_.FullName $NewName -Force

            $PemName = $NewName.Replace(".crt", ".pem.crt")
            $Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $NewName
            Export-ZPkiCertAsPem -Cert $Cert -FullName $PemName
        }
    }

}

<#
    .SYNOPSIS
    Add/remove CDP and AIA URL configuration

    .DESCRIPTION
    the *Fqdn and *Path parameters are for building a complete HTTP URI.
    For example,
        $HttpCdpFqdn = my.server.com
        $HttpCdpPath = "Repository"
    the generated URI will start with "http://my.server.com/Repository"

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Set-ZPkiCaUrlConfig {
    [CmdletBinding(ConfirmImpact='Medium', SupportsShouldProcess=$true)]
    Param(
        # FQDN for accessing CDP over HTTP
        [Parameter(ParameterSetName="addcdp")]
        [string]
        $HttpCdpFqdn,

        # HTTP path for accessing CDP over HTTP
        [Parameter(ParameterSetName="addcdp")]
        [string]
        $HttpCdpPath = "Repository",

        # FQDN for accessing AIA over HTTP
        [Parameter(ParameterSetName="addaia")]
        [string]
        $HttpAiaFqdn,

        # HTTP path for accessing AIA over HTTP
        [Parameter(ParameterSetName="addaia")]
        [string]
        $HttpAiaPath = "Repository",

        # Use LDAP CDP URI
        [Parameter(ParameterSetName="addcdp")]
        [switch]
        $AddLdapCdp,

        # Use LDAP AIA URI
        [Parameter(ParameterSetName="addaia")]
        [switch]
        $AddLdapAia,

        # Add OCSP
        [Parameter(ParameterSetName="addocsp")]
        [Switch]
        $AddOcsp,
        
        # Include OCSP URI
        [Parameter(ParameterSetName="addocsp")]
        [string]
        $OcspUri,

        # Include file URI for CDP
        [Parameter(ParameterSetName="addcdp")]
        [switch]
        $AddFileCdp,

        # Path for CDP file publishing
        [Parameter(ParameterSetName="addcdp")]
        [string]
        $CdpFilePath = "C:\ADCS\Web\Repository",

        # Removes all CDP entries. Will always leave default file publish path C:\Windows\system32\certsrv\CertEnroll
        [Parameter(ParameterSetName="clear")]
        [switch]
        $ClearCDPs,

        # Removes all AIA entries. Will always leave default file publish path C:\Windows\system32\certsrv\CertEnroll
        [Parameter(ParameterSetName="clear")]
        [switch]
        $ClearAIAs
    )

    If($ClearCDPs -And ($PSCmdlet.ShouldProcess("all", "Remove CDP URL entries"))) {
        Write-Verbose "Removing all CDP URL's. Adding default file URL."
        Get-CACrlDistributionPoint | Remove-CACrlDistributionPoint -Confirm:$False | Out-Null
        Add-CACrlDistributionPoint -Uri "$CertSrvDir\%7%8%9.crl" -PublishToServer -Confirm:$False | Out-Null
    }

    If($ClearAIAs -And ($PSCmdlet.ShouldProcess("all", "Remove AIA URL entries"))) {
        Write-Verbose "Removing all AIA URL's. Adding default file URL."

        Get-CAAuthorityInformationAccess | Remove-CAAuthorityInformationAccess -Confirm:$False | Out-Null

        # Setting default file path does not work via Set-CAAuthorityInformationAccess.
        $ActiveCa = Get-ItemProperty $CertSvcRegPath -Name Active | Select-Object -ExpandProperty Active
        $DefaultCrtFilePath = ("1:$CertSrvDir\%1_%3%4.crt")
        Set-ItemProperty -Path "$CertSvcRegPath\$ActiveCa" -Name "CACertPublicationURLs" -Value $DefaultCrtFilePath
    }

    If($ClearCDPs -or $ClearAIAs) {
        Return
    }

    If(-Not [string]::IsNullOrWhiteSpace($HttpCdpFqdn)) {
        Write-Verbose "Creating HTTP CDP configuration"
        $HttpUri = Get-HttpUri -HostFQDN $HttpCdpFqdn -Path $HttpCDPPath -Document "%7%8%9.crl"
        Add-CACrlDistributionPoint -Uri $HttpUri -AddToCertificateCdp -Confirm:$False | Out-Null
    }

    If($AddLdapCdp) {
        Write-Verbose "Creating LDAP CDP configuration"
        Add-CACrlDistributionPoint -Uri (Get-LdapUri) -AddToCertificateCdp -Confirm:$False | Out-Null
    }

    If($AddFileCdp -and -Not [string]::IsNullOrWhiteSpace($CdpFilePath)) {
        Write-Verbose "Creating file system CDP configuration"
        Add-CACrlDistributionPoint -Uri (Get-FileUri -Path $CdpFilePath) -PublishToServer -Confirm:$False | Out-Null
    }

    If(-Not [string]::IsNullOrWhiteSpace($HttpAiaFqdn)) {
        Write-Verbose "Creating HTTP AIA configuration"
        $HttpUri = Get-HttpUri -HostFQDN $HttpAIAFQDN -Path $HttpAIAPath -Document "%3%4.crt"
        Add-CAAuthorityInformationAccess -Uri $HttpUri -AddToCertificateAia -Confirm:$False | Out-Null
    }

    If($AddLdapAia) {
        Write-Verbose "Creating LDAP AIA configuration"
        $LdapUri = Get-LdapUri -IsAIA
        Add-CAAuthorityInformationAccess -Uri $LdapUri -AddToCertificateAia -Confirm:$False | Out-Null
    }

    If($AddOcsp) {
        Add-CAAuthorityInformationAccess -Uri $OCSPUri -AddToCertificateOcsp -Confirm:$False | Out-Null
    }

    certutil -crl | Out-Null

    Restart-Service certsvc
}

<#
    .SYNOPSIS
    Exports an x509 certificate as base64 PEM

    .DESCRIPTION

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Export-ZPkiCertAsPem {
    [CmdletBinding()]
    Param(
        # X509 certificate to export as PEM
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Cert,

        # Full file name of PEM file to create
        [string]
        $FullName
    )

    $Bytes = $Cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
    $Sb = New-Object System.Text.StringBuilder
    $Sb.AppendLine("-----BEGIN CERTIFICATE-----") | Out-Null
    $Sb.AppendLine([Convert]::ToBase64String($Bytes, [System.Base64FormattingOptions]::InsertLineBreaks)) | Out-Null
    $Sb.AppendLine("-----END CERTIFICATE-----") | Out-Null

    $Sb.ToString() | Out-File $FullName -Force -Encoding ascii
}

<#
    .SYNOPSIS
    Get the config string for the local CA. To get config strings for other CAs, use Get-ZPkiAdCasConfigString

    .DESCRIPTION

    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Get-ZPkiLocalCaConfigString {
    Write-Output ("{0}\{1}" -f (hostname), (Get-ChildItem -Path $CertSvcRegPath -Name))
}

<#
    .SYNOPSIS
    This cmdlet is not finished. Do not use.

    .DESCRIPTION
    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Get-NewRequests {
    Param(
        $ReqsPath
    )

    If(-Not (Test-Path $ReqsPath -PathType Container)) {
        Throw "Requests path not found: [$ReqsPath]"
    }

    Get-ChildItem $ReqsPath -Filter *.req | ForEach-Object { Write-Output $_ }
    Get-ChildItem $ReqsPath -Filter *.csr | ForEach-Object { Write-Output $_ }
}

<#
    .SYNOPSIS
    This cmdlet is not finished. Do not use.

    .DESCRIPTION
    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Submit-ZPkiRequest {
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $CsrFile,

        [Parameter(Mandatory=$True)]
        [string]
        $SignedCertFile,

        [Parameter(Mandatory=$False)]
        [string[]]
        $SanName,

        [Parameter(Mandatory=$False)]
        [string]
        $Template,

        [Parameter(Mandatory=$False)]
        [string]
        $Config
    )

    $Cwd = Get-Location | Select-Object -ExpandProperty Path

    If($SignedCertFile -notlike "*\*") {
        $SignedCertPath = $Cwd
    } Else {
        $SignedCertPath = $SignedCertFile.Substring(0, $SignedCertFile.LastIndexOf("\"))
        $SignedCertPath = Get-Item $SignedCertPath | Select-Object -ExpandProperty FullName
    }

    If(-Not (Test-Path $CsrFile -PathType Leaf)) {
        Write-Error "$CsrFile not found or is not a file"
    }
    If(-Not (Test-Path $SignedCertPath -PathType Container)) {
        Write-Error "$SignedCertPath not found or is not a directory"
    }

    $CsrFile = Get-Item $CsrFile | Select-Object -ExpandProperty FullName
    Set-Location $SignedCertPath

    If([string]::IsNullOrWhiteSpace($Config)) {
        $Config = Get-ZPkiLocalCaConfigString
    }

    $SignedCertFileName = $SignedCertFile.Substring($SignedCertFile.LastIndexOf("\") + 1)

    $i = 0
    While (Test-Path $SignedCertFile -PathType Leaf) {
        $i++
        $SignedCertFile = "{0}\{1}{2}" -f $SignedCertPath, $SignedCertFileName.Substring(0, $SignedCertFileName.LastIndexOf(".")), "-$($i).cer"
    }

    $SanAttr = ""
    if(-Not [string]::IsNullOrWhiteSpace($SanName)) {
        $SanAttr = $SanName -join "&DNS="
        $SanAttr = "\nSAN:DNS=$SanAttr"
    }

    # Submit request to CA
    If([string]::IsNullOrWhiteSpace($SanAttr) -and [string]::IsNullOrWhiteSpace($Template)) {
        $OutText = certreq -f -config $Config -submit $CsrFile $SignedCertFile
    } Else {
        $OutText = certreq -f -config $Config -submit -attrib "CertificateTemplate:$Template$SanAttr" $CsrFile $SignedCertFile
    }

    Remove-Item *.rsp -Force | Out-Null

    # Combine all output lines into single string
    If($OutText -is [array]) {
        $AllText = $OutText -join " "
    } Else {
        $AllText = $OutText
    }

    # Parse for Request ID
    If($AllText -match "RequestId: ([0-9]*) .*") {
        $Rid = $Matches[1]
    } Else {
        Write-Verbose "Could not automatically determine request Id. You may need to get this from the CA manually. "

        $OutText
        Return
    }

    # Parse for request status
    If($AllText -like "*Certificate request is pending: Taken Under Submission*") {

        certutil -config "$Config" -resubmit $Rid | Out-Null
        If(-Not $?) {
            Write-Verbose "Request is pending approval of CA manager. Please ask CA manager to issue the certificate."
            Write-Verbose "Certificate request can be issued with the following command, if you have proper permission:"
            Write-Verbose "> certutil -config `"$Config`" -resubmit $Rid"
            Read-Host "When the request has been issued, return here and press enter to continue"
        }

        # Try to save cert file after it has been issued
        certreq -retrieve -f -config $Config $Rid $SignedCertFile
    } Elseif($AllText -notlike "*(Issued)*") {
        Write-Output "Cert was not issued. CA output:"
        $OutText
        Return
    }

    Remove-Item *.rsp -Force | Out-Null

    Write-Output "Request Id: $Rid, certificate saved in $SignedCertFile"

    Set-Location $Cwd
}

<#
    .SYNOPSIS
    Generate random password containing alphanumeric characters and the following set: !@#$%^&*()_-+=[{]};:<>|./?
    .DESCRIPTION
    This cmdlet does not work on .net core-based versions of powershell! 
    Author anders !a!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function New-ZPkiRandomPassword {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter()]
        [int]$Length = 128,
        [Parameter()]
        [int]$NumberOfNonAlphaNumChars = 5,
        [Parameter()]
        [switch]$ConvertToSecureString
    )

    Add-Type -AssemblyName 'System.Web'
    $password = [System.Web.Security.Membership]::GeneratePassword($Length,$NumberOfNonAlphaNumChars)
    if ($ConvertToSecureString.IsPresent -and $ConvertToSecureString) {
        ConvertTo-SecureString -String $password -AsPlainText -Force
    } else {
        $password
    }
}

<#
    .SYNOPSIS
    Backs up ADCS to given directory. Private key is not included by default, use -BackupKey to include it.
    Backups up CA database and configuration:
        1. Registry values
        2. Published templates
        3. Installed local certificates

    .DESCRIPTION
    Author anders !a!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function New-ZPkiCaBackup {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    Param(
        [string]
        $BackupsDirectoryName = "Backups",

        [string]
        $BackupsParentDirectory = "C:\ADCS",

        [Parameter(Mandatory=$false)]
        [string]
        $BackupPwd,

        [int]
        $RetentionCount = 10,

        [switch]
        $SkipBackupKey
    )

    $BackupKey = -Not $SkipBackupKey

    #
    # Directories to be copied to backup directory. just straight file copy.
    # Add in extra directories as needed.
    #
    $BackupDirs = @{
        'Db' = ''
        'CaConfig' = ''
    }

    Write-Progress -Activity "CA Backup" -Status "Creating backup directories"
    Write-Verbose "Creating backup directories.."

    $DateTimeString = Get-Date -format "yyyy-MM-dd_HHmmss"
    $BackupDirName = "Backup-$DateTimeString"

    $CurrentBackupLocation = "$BackupsParentDirectory\$BackupsDirectoryName"
    $CurrentBackupDirectory = "$CurrentBackupLocation\$BackupDirName"

    New-AdcsBackupDir -Name $BackupsDirectoryName -Path $BackupsParentDirectory -Verbose
    New-AdcsBackupDir -Name $BackupDirName -Path "$CurrentBackupLocation" -Verbose

    Foreach($Dir in $BackupDirs.GetEnumerator()) {
        New-AdcsBackupDir -Name $Dir.Key -Path $CurrentBackupDirectory -Verbose
    }

    $DbDir = "$CurrentBackupDirectory\Db"
    $CaConfigDir = "$CurrentBackupDirectory\CaConfig"

    Write-Verbose "Backup directory: [$CurrentBackupDirectory]"
    Write-Verbose "Db Dir:           [$DbDir]"
    Write-Verbose "Config dir:       [$CaConfigDir]"

    Write-Progress -Activity "CA Backup" -Status "Backing up CA DB"
    Write-Verbose "Running CA backup.."
    $bckOutput = certutil -backupdb $DbDir

    If(-Not $?) {
        Write-Output "Error backing up CA:"
        Write-Error $bckOutput
    }

    If($BackupKey) {
        If([string]::IsNullOrWhiteSpace($BackupPwd)) {
            $BackupPwd = New-ZPkiRandomPassword -Length 32 -NumberOfNonAlphaNumChars 10
            Write-Output $BackupPwd
        }
        certutil -backupkey -f -p $BackupPwd $CaConfigDir | Out-Null

        If(-Not $?) {
            Write-Error "Error backing up CA certificate and private key: $bckOutput"
        }
    }

    Write-Progress -Activity "CA Backup" -Status "Backing up CA configuration"
    Write-Verbose "Copying certificates"
    Copy-Item C:\Windows\System32\CertSrv\CertEnroll\* "$CaConfigDir" -Recurse | Out-Null

    Write-Verbose "Exporting template list"
    certutil -catemplates | Out-File "$CaConfigDir\Templates.txt" -Force

    If(Test-Path "C:\Windows\CAPolicy.inf") {
	    Write-Verbose "Copying CAPolicy.inf"
	    Copy-Item C:\Windows\CAPolicy.inf "$CaConfigDir" | Out-Null
    } Else {
	    Write-Verbose " >> CAPolicy.inf not found" -foregroundcolor Yellow
    }

    Write-Verbose "Exporting registry values"
    reg export hklm\system\currentcontrolset\services\certsvc\configuration "$($CaConfigDir)\registry.reg" /y | Out-Null

    get-childitem cert:\LocalMachine\my | ForEach-Object {
        $tp = $_.SerialNumber;
        $cn = $_.Subject
        If(-Not $cn.StartsWith("CN=WMSvc-")) {
            $bytes = $_.export("cert");
            Write-Verbose "Saving certificate $($_.Subject)"
            [System.IO.File]::WriteAllBytes("$CaConfigDir\$cn - $tp.cer", $bytes)
        }
    }
}

<#
    .SYNOPSIS
    Removes configuration for AMA group link in an Assurance policy object in ADDS.

    .DESCRIPTION
    Author anders !a!T! runesson D"O"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Remove-ZPkiAdIssuancePolicyGroupLink {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    Param (
        # Display Name of the policy to remove.
        [Parameter(Mandatory=$true)]
        [string]
        $IssuancePolicyName
    )

    $ErrorActionPreference = "stop"

    Import-Module ActiveDirectory -Verbose:$False
    $root = Get-ADRootDSE

    $searchBase = $root.configurationnamingcontext
    $OID = Get-ADObject -searchBase $searchBase -Filter { ((displayname -eq $IssuancePolicyName) -or (name -eq $IssuancePolicyName)) -and (objectClass -eq "msPKI-Enterprise-Oid")} -properties *

    If ($null -eq $OID) {
        Write-Error ("Issuance Policy [{0}] could not be found!" -f $IssuancePolicyName)
    } Elseif (($OID | Measure-Object | Select-Object -ExpandProperty Count) -gt 1) {
        Write-Error ("Multiple matches found. Issuance Policy search term [{0}] matches {1}" -f $IssuancePolicyName, (($OID | Select-Object -expand DisplayName) -join ", "))
    }

    Try {
        If($Null -ne $OID.'msDS-OIDToGroupLink' -And $PSCmdlet.ShouldProcess($IssuancePolicyName, "Delete AMA group link from Issuance Policy (group: $($Oid.'msDS-OIDToGroupLink'))")) {
            Set-ADObject -Identity $OID -Clear "msDS-OIDToGroupLink" | Out-Null
        }

        Write-Verbose "Registered AMA group [$GroupName] to Issuance Policy [$IssuancePolicyName]"
    } Catch {
        throw $_
    }
}

<#
    .SYNOPSIS
    Registers a group for AMA in an Assurance policy in ADDS.

    .DESCRIPTION
    Author anders !A!T! runesson D"O"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Set-ZPkiAdIssuancePolicyGroupLink {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    Param (
        # Display name of issuance policy
        [Parameter(Mandatory=$true)]
        [string]
        $IssuancePolicyName,

        # Name of the group to link to this policy
        [Parameter(Mandatory=$true)]
        [string]
        $GroupName
    )

    $ErrorActionPreference = "stop"

    Import-Module ActiveDirectory -Verbose:$False
    $root = Get-ADRootDSE

    $searchBase = $root.configurationnamingcontext
    $OID = Get-ADObject -searchBase $searchBase -Filter { ((displayname -eq $IssuancePolicyName) -or (name -eq $IssuancePolicyName)) -and (objectClass -eq "msPKI-Enterprise-Oid")} -properties *

    If ($null -eq $OID) {
        Write-Error ("Issuance Policy [{0}] could not be found!" -f $IssuancePolicyName)
    } Elseif (($OID | Measure-Object | Select-Object -ExpandProperty Count) -gt 1) {
        Write-Error ("Multiple matches found. Issuance Policy search term [{0}] matches {1}" -f $IssuancePolicyName, (($OID | Select-Object -expand DisplayName) -join ", "))
    }

    $Group = Get-ADGroup -Filter { (Name -eq $GroupName) -and (objectClass -eq "group") }
    If($Null -eq $Group) {
        Write-Error "Group not found: [$GroupName]"
    }
    If(($Group | Measure-Object | Select-Object -ExpandProperty Count) -gt 1) {
        Write-Error ("Multiple matches found. Group search term [{0}] matches {1}" -f $GroupName, (($Group | Select-Object -expand Name) -join ", "))
    }

    If ($Group.groupCategory -ne "Security") {
        Write-Error "Group [$GroupName] is not a security group"
    }
    If ($Group.groupScope -ne "Universal") {
        Write-Error "Group [$GroupName] is not a universal group"
    }

    Try {
        $Members = Get-ADGroupMember -Identity $GroupName
    } Catch { Write-Error "Could not read members of group [$GroupName]"}

    If ($Members) {
        Write-Error "Group [$GroupName] is not empty"
    }

    Try {
        If($Null -ne $OID.'msDS-OIDToGroupLink' -And $PSCmdlet.ShouldProcess($IssuancePolicyName, "Delete the previous AMA group link from Issuance Policy")) {
            Set-ADObject -Identity $OID -Clear "msDS-OIDToGroupLink" | Out-Null
        }

        If($PSCmdlet.ShouldProcess($IssuancePolicyName, "Link AMA group [$GroupName] to Issuance Policy")) {
            Set-ADObject -Identity $OID -Replace @{ "msDS-OIDToGroupLink" = $Group.DistinguishedName } | Out-Null
        }
        Write-Verbose "Registered AMA group [$GroupName] to Issuance Policy [$IssuancePolicyName]"
    } Catch {
        throw $_
    }
}

<#
    .SYNOPSIS
    Shows all configured AMA policy links in ADDS.

    .DESCRIPTION
    Author anders !A!T! runesson D"O"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Get-ZPkiAdIssuancePolicyGroupLinks {
    [CmdletBinding()]
    Param (
        # If supplied, display info about only this policy. If omitted display information for all issuance policies.
        [string]
        $IssuancePolicyName
    )

    $ErrorActionPreference = "Stop"

    Import-Module ActiveDirectory

    $root = Get-ADRootDSE
    $configNCDN = [String]$root.configurationNamingContext

    If (-Not [string]::IsNullOrWhiteSpace($IssuancePolicyName)) {
        $OIDs = Get-ADObject -Filter {(objectclass -eq "msPKI-Enterprise-Oid") -and ((name -eq $IssuancePolicyName) -or (displayname -eq $IssuancePolicyName) -or (distinguishedName -like $IssuancePolicyName)) } -searchBase $configNCDN -properties *
        If ($null -eq $OIDs) {
            Write-Error "Issuance Policy [$IssuancePolicyName] not found in AD."
        }
    } Else {
        $OIDs = Get-ADObject -LDAPFilter "(&(objectClass=msPKI-Enterprise-Oid)(msDS-OIDToGroupLink=*)(flags=2))" -searchBase $configNCDN -properties *
        If ($null -eq $OIDs) {
            Write-Verbose "No issuance policies with group links found in AD."
        }
    }

    foreach ($OID in $OIDs) {
        $GroupDN = $Null
        $Group = $Null

        if ($OID."msDS-OIDToGroupLink") {
            # In case the Issuance Policy is linked to a group, it is good to check whether there is any problem with the mapping.
            $GroupDN = $OID."msDS-OIDToGroupLink"
            $Group = Get-ADGroup -Identity $GroupDN

            If ($Group.groupCategory -ne "Security") {
                Write-Error ("Policy {0}: {1} is not a security group" -f $IssuancePolicyName, $Group.Name)
            }
            If ($Group.groupScope -ne "Universal") {
                Write-Error ("Policy {0}: {1} is not a universal group" -f $IssuancePolicyName, $Group.Name)
            }

            $Members = Get-ADGroupMember -Identity $Group
            If ($Members) {
                Write-Error ("Policy {0}: {1} is not empty" -f $IssuancePolicyName, $Group.Name)
            }
        }
        Write-Output ([PSCustomObject] @{ "Policy" = $Oid.displayName; "PolicyOid" = $Oid.'msPKI-Cert-Template-Oid'; "PolicyCN" = $OID.CN; "GroupName" = $Group.Name; "GroupDN" = $GroupDN })
    }
}

<#
    .SYNOPSIS
    Lists all Issuance policy objects in ADDS.

    .DESCRIPTION
    Author anders !A!T! runesson D"o"T info

    .ExternalHelp PsZPki-help.xml
#>
Function Get-ZPkiAdIssuancePolicy {
    [CmdletBinding()]
    Param (
        # If supplied, display info about only this policy. If omitted display information for all issuance policies.
        [string]
        $IssuancePolicyName
    )

    $ErrorActionPreference = "Stop"

    Import-Module ActiveDirectory

    $root = Get-ADRootDSE
    $configNCDN = [String]$root.configurationNamingContext

    If (-Not [string]::IsNullOrWhiteSpace($IssuancePolicyName)) {
        $OIDs = Get-ADObject -Filter {(objectclass -eq "msPKI-Enterprise-Oid") -and (flags -eq 2) -and ((name -eq $IssuancePolicyName) -or (displayname -eq $IssuancePolicyName) -or (distinguishedName -like $IssuancePolicyName)) } -searchBase $configNCDN -properties *
        If ($null -eq $OIDs) {
            Write-Error "Issuance Policy [$IssuancePolicyName] not found in AD."
        }
    } Else {
        $OIDs = Get-ADObject -LDAPFilter "(&(objectClass=msPKI-Enterprise-Oid)(flags=2))" -searchBase $configNCDN -properties *
        If ($null -eq $OIDs) {
            Write-Verbose "No issuance policies with group links found in AD."
        }
    }

    foreach ($OID in $OIDs) {
        $GroupDN = $Null
        $Group = $Null

        if ($OID."msDS-OIDToGroupLink") {
            # In case the Issuance Policy is linked to a group, it is good to check whether there is any problem with the mapping.
            $GroupDN = $OID."msDS-OIDToGroupLink"
            $Group = Get-ADGroup -Identity $GroupDN

            If ($Group.groupCategory -ne "Security") {
                Write-Error ("Policy {0}: {1} is not a security group" -f $IssuancePolicyName, $Group.Name)
            }
            If ($Group.groupScope -ne "Universal") {
                Write-Error ("Policy {0}: {1} is not a universal group" -f $IssuancePolicyName, $Group.Name)
            }

            $Members = Get-ADGroupMember -Identity $Group
            If ($Members) {
                Write-Error ("Policy {0}: {1} is not empty" -f $IssuancePolicyName, $Group.Name)
            }
        }
        Write-Output ([PSCustomObject] @{ "Policy" = $Oid.displayName; "PolicyOid" = $Oid.'msPKI-Cert-Template-Oid'; "PolicyCN" = $OID.CN; "GroupName" = $Group.Name; "GroupDN" = $GroupDN })
    }
}

<#
    .SYNOPSIS
    Update altSecIdentities on Active Directory user object based on certificate in ADCS db

    .DESCRIPTION
    Find an AD account by AdSamaccountname and search given CA db for a cert with matching CN and RequesterName.
    If multiple certs match, the last one will be used. You can supply a template name to limit cert search.
    Extract serialnumber and Issuer name from cert and set altSecIdentities accordingly.

    .PARAMETER AdSamaccountName 
    AD Account name

    .PARAMETER CertTemplateName
    Short name of certificate template

    .PARAMETER CaNameFilter
    If you have multiple CAs use this parameter to filter on CA name.

    .PARAMETER ClearAltSecurityIdentities
    Removes all preexisting entries from altSecurityIdentities attribute before setting.
#>

Function Set-ZPkiAdAltSecurityIdentities {
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param(

        [Parameter(Mandatory=$true)]
        [string]
        $AdSamaccountName,

        [Parameter(Mandatory=$false)]
        [string]
        $CertTemplateName,

        [Parameter(Mandatory=$false)]
        [string]
        $CaNameFilter,

        [Switch]
        $ClearAltSecurityIdentities
    )

    $ErrorActionPreference = "Stop"

    try {
        Import-Module ActiveDirectory
    } catch {
        Write-Error "This command requires the ActiveDirectory module to be installed. Please install it by running: 'Install-WindowsFeature RSAT-AD-PowerShell'"
        Return
    }

    $Domain = Get-ADDomain -Current LoggedOnUser
    $Nb = $Domain.NetBiosName
    $AdObject = Get-AdUser $AdSamaccountname -Properties "cn","altSecurityIdentities"

    # For user objects stored in AD containers ADCS will write CommonName in DB as newline separated list of all container CN's and last the objects' own CN. 
    # For example, CN=Administrator will have 'Users\nAdministrator' in ADCS DB (but not in cert...) 8-( eeeeeefml

    $Dn = $AdObject.DistinguishedName
    $DnCmp = $Dn.Split(',')
    $Cns = ($DnCmp | Where-Object { $_.StartsWith("CN=") } | ForEach-Object { $_.Replace("CN=", "") } | Sort-Object -Descending) -join "`n"

    $CertFilters = "Request.RequesterName==$Nb\$($AdObject.Samaccountname)","CommonName==$Cns"

    If(-Not [string]::IsNullOrWhiteSpace($CertTemplateName)) {
        $Tpl = Get-ZPkiAdTemplate -Name $CertTemplateName
        $Count = $Tpl | Measure-Object | Select-Object -ExpandProperty Count
        If($Count -lt 1) {
            Write-Warning "No template named $CertTemplateName found."
            Return
        }
        If($Count -gt 1) {
            Write-Warning "Multiple templates matching $CertTemplateName found."
            Return
        }

        $CertFilters += "CertificateTemplate==$($Tpl.TemplateOid.Value)"
    }

    $cas = Get-ZPkiAdCasConfigString
    If($Cas.Count -gt 1) {
        If(-Not [string]::IsNullOrWhiteSpace($CaNameFilter)) {
            $Cfg = $Cas | Where-Object { $_ -like "*$CaNameFilter*" } | Select-Object -First 1
        } Else {
            $Cfg = $Cas | Select-Object -First 1
        }
    } else {
        $Cfg = $Cas
    }

    Write-Verbose "Checking CA DB on $Cfg for $CertFilters"

    $CertRow = Get-ZPkiDbRow -ConfigString $Cfg -Filters ($CertFilters + ,"Request.Disposition==20") -Properties "RawCertificate","CertificateTemplate","RequestID","NotBefore","NotAfter","Request.RequesterName" | Select-Object -Last 1
    $RowCount = $CertRow | Measure-Object | Select-Object -ExpandProperty Count

    If($RowCount -lt 1) {
        Write-Verbose "Found no matching rows!"
        $CertRow
        Return
    }

    $CertString = $CertRow | Select-Object -expand RawCertificate
    [byte[]] $CertBytes = [Convert]::FromBase64String($CertString)

    $Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 (,$CertBytes)

    $Serial = $Cert.SerialNumber.ToLower()

    Write-Verbose "Found cert $Serial issued to $($Cert.Subject) ($($CertRow.Request_RequesterName))"

    $SerialRev = ""
    for($i = 0; $i -lt $Serial.length; $i += 2) { 
        $byteStr = $Serial.Substring($i, 2)
        $SerialRev = "$byteStr$SerialRev"
    }

    $Dn = New-Object System.Security.Cryptography.X509Certificates.X500DistinguishedName($Cert.Issuer)
    $I = $Dn.Format($True).Replace("`n", ",").Replace("`r", "").Trim(',')

    $altSecString = "X509:<I>$($I)<SR>$SerialRev"

    If($AdObject.altSecurityIdentities) {
        $AlreadySet = $AdObject.altSecurityIdentities | ForEach-Object { 
            If($_ -eq $altSecString) {
                return $True
            }
        }

        If($AlreadySet) {
            If($ClearAltSecurityIdentities) {
                $ClearText = "altSecurityIdentities will NOT be cleared!"
            }
            Write-Verbose "altSecurityIdentities attribute already contains value $($altSecString). No changes will be made. $ClearText"
            Return
        }
    }

    If($AdObject.altSecurityIdentities -And $ClearAltSecurityIdentities) {
        Write-Verbose "Removing previous altSecurityIdentities values"
        $AdObject.altSecurityIdentities | ForEach-Object { Write-Warning "Removing [$_] from altSecurityIdentities" }

        Set-AdObject $AdObject -Clear "altSecurityIdentities"
    }

    Write-Verbose "Adding '$($altSecString)' to altSecurityIdentitites on account $($AdObject.Samaccountname)"

    Set-AdObject $AdObject -Add @{ 'altSecurityIdentities' = $altSecString } 
}

<#
    .ExternalHelp PsZPki-help.xml
#>
Function Install-ZPkiRsatComponents {
    [CmdletBinding()]
    Param(
        # If set, also install the ADDS management tools
        [switch]
        $IncludeAdTools
    )

    If(-Not (Test-IsAdmin)) {
        Write-Error "This cmdlet requires admin privileges to run."
        return
    }

    Write-Progress -Activity "Installing RSAT components" -id 0
    $OsName = (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ProductName')
    $OsMajor = [System.Environment]::OSVersion.Version.Major
    $OsMinor = [System.Environment]::OSVersion.Version.Build

    If($OsName -like "*Server*") {
        Write-Progress -Activity "Installing ADCS Tools" -ParentId 0 -Id 1
        Add-WindowsFeature RSAT-ADCS-Mgmt, RSAT-Online-Responder | Select-Object RestartNeeded
        If($IncludeAdTools) {
            Write-Progress -Activity "Installing ADDS Tools" -ParentId 0 -Id 1
            Add-WindowsFeature RSAT-AD-Tools | Select-Object RestartNeeded
        }
    } Else {
        If($OsMajor -lt 10) {
            Write-Output "Your version of windows requires that you download"
            Write-Output "Remote Server Administration Tools from Microsoft.com and"
            Write-Output "install it manually."
            return
        } Elseif ($OsMajor -eq 10 -and $OsMinor -lt 17763) {
            Write-Output "Your version of windows requires that you download"
            Write-Output "Remote Server Administration Tools from Microsoft.com and"
            Write-Output "install it manually."
            Write-Output "RSAT for Windows 10, 1803 and older: https://www.microsoft.com/en-us/download/details.aspx?id=45520"
            return
        }

        $RsatAdcs = get-windowscapability -online -Name "Rsat.CertificateServices.Tools~~~~0.0.1.0"
        $RsatAdds = get-windowscapability -online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"

        If($RsatAdcs.State -eq "Installed" -and ($RsatAdds.State -eq "Installed" -or $IncludeAdTools -eq $false)) {
            $RsatAdcs, $RsatAdds | Select-Object Name, State
            return
        }

        Write-Progress -Activity "Checking Windows update settings.." -ParentId 0 -Id 1
        $WuSetting = $Null
        If(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -PathType Container) {
            $WuSetting = Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty UseWUServer
            If($WuSetting -eq 1) {
                Write-Progress -Activity "Temporarily disabling Windows update service.." -ParentId 0 -Id 1
                Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
                Restart-Service wuauserv
            }
        }

        If($RsatAdcs.State -ne "Installed") {
            Write-Progress -Activity "Installing ADCS tools" -ParentId 0 -Id 1
            Add-WindowsCapability -Online -Name "Rsat.CertificateServices.Tools~~~~0.0.1.0" | Out-Null
            Get-WindowsCapability -online -Name "Rsat.CertificateServices.Tools~~~~0.0.1.0" | Select-Object Name, State
        } Else {
            $RsatAdcs | Select-Object Name, State
        }

        If($IncludeAdTools) {
            If($RsatAdds.State -ne "Installed") {
                Write-Progress -Activity "Installing ADDS tools" -ParentId 0 -Id 1
                Add-WindowsCapability -online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" | Out-Null
                Get-WindowsCapability -online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" | Select-Object Name, State
            } Else {
                $RsatAdds | Select-Object Name, State
            }
        }

        If($WuSetting -eq 1) {
            Write-Progress -Activity "Restarting Windows update.." -ParentId 0 -Id 1
            Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1
            Restart-Service wuauserv
        }
    }
}
# SIG # Begin signature block
# MIIcxwYJKoZIhvcNAQcCoIIcuDCCHLQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSCdYPDqwAL1LTNu/FF/n5XAG
# crOgghcNMIIEBjCCA6ygAwIBAgITMQAAAEuY5/IiSrSMPQAAAAAASzAKBggqhkjO
# PQQDAjBIMQswCQYDVQQGEwJTRTEUMBIGA1UEChMLWmFtcGxlV29ya3MxIzAhBgNV
# BAMTGlphbXBsZVdvcmtzIEludGVybmFsIENBIHYzMB4XDTI1MDQwMjA3MTYyMloX
# DTI2MDQwMjA3MjYyMlowGjEYMBYGA1UEAxMPQW5kZXJzIFJ1bmVzc29uMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA07FDxLoNRqA9Gq/8qCU9/V9odNF9
# yZ1sBgL5r4fZiOON5ZdaUgeq2+o9s8dCiKHkdU0LvcOp7cuO3XLRn+jseFlSYGY9
# W6CFivpRuewuT1+228A/4CfqmW657I9qi78KRYDLJzE8IQxCnz5Mvw9sug/vnvCM
# 020VnUuyRzzsSrmbZvgsAspLTMHAbkFlmSTLEnnVAfBpOU45OUcwic0BR785q/UE
# eLiS/HRtniIpNBtJLa06OcDGHl59AXGr3mwZ6WDXQQHr+sjZuv/CNNYp3VbswRu9
# vTrfLhpJIiPylAmJnrDv+uQc9nBImtw8JgS6H2IUhv+xifqli1sqXgUyTwIDAQAB
# o4IB1jCCAdIwPgYJKwYBBAGCNxUHBDEwLwYnKwYBBAGCNxUIhb31ToL5uhOGvZce
# h8eaKYeL30SBZIb4qhWEotFXAgFlAgEHMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4G
# A1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1Ud
# DgQWBBTCMPG7tk9kcuLk2dlyo16zyReIRjAfBgNVHSMEGDAWgBTcnJy/9vjUCSFq
# nt0GjbrUATwUNjBiBggrBgEFBQcBAQRWMFQwUgYIKwYBBQUHMAKGRmh0dHA6Ly9w
# a2kub3Auendrcy54eXovUmVwb3NpdG9yeS9aYW1wbGVXb3JrcyUyMEludGVybmFs
# JTIwQ0ElMjB2My5jcnQwWwYDVR0RBFQwUqAvBgorBgEEAYI3FAIDoCEMH0FuZGVy
# cy5SdW5lc3NvbkB6YW1wbGV3b3Jrcy5jb22BH2FuZGVycy5ydW5lc3NvbkB6YW1w
# bGV3b3Jrcy5jb20wTQYJKwYBBAGCNxkCBEAwPqA8BgorBgEEAYI3GQIBoC4ELFMt
# MS01LTIxLTE2OTAwNzU1NC01NjE1NTU1ODMtMzQ2NTg3MDA2NS0xNTE2MAoGCCqG
# SM49BAMCA0gAMEUCIQCEZC5kwpZtziZ3XHMndteFmdJlx9zevImWk1ca8yhnGgIg
# fvJqgybzTMlD/5Uq0j1lwycxc0mEZyNpr3QAFX2jhCYwggWNMIIEdaADAgECAhAO
# mxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# JDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEw
# MDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMT
# GERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprN
# rnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVy
# r2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4
# IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13j
# rclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4Q
# kXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQn
# vKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu
# 5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/
# 8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQp
# JYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFf
# xCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGj
# ggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/
# 57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8B
# Af8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6
# oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEB
# AHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0a
# FPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNE
# m0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZq
# aVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCs
# WKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9Fc
# rBjDTZ9ztwGpn1eqXijiuZQwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5b
# MA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5
# NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPB
# PXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/
# nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLc
# Z47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mf
# XazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3N
# Ng1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yem
# j052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g
# 3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD
# 4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDS
# LFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwM
# O1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU
# 7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0j
# BBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8E
# PDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# DQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPO
# vxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQ
# TGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWae
# LJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPBy
# oyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfB
# wWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8l
# Y5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/
# O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbb
# bxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3
# OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBl
# dkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt
# 1nz8MIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkqhkiG9w0BAQsF
# ADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVowQjELMAkGA1UE
# BhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdpQ2VydCBUaW1l
# c3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5qc5/2
# lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L660x5XltSVhh
# K64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLuslxdr9Qq82aKcp
# A9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7avVnpUVmPvkxT
# 8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl7/r419CvEYVI
# rH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+NBikDO0mlUh90
# 2wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVkiqLq+ISTdEjJK
# GjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5n10jxmGpxoMc
# 6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h6gYldp4FCMgr
# XdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNeREXAu2xUDEW8
# aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLqfY/M/SdV6mwW
# TyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIBhzAOBgNVHQ8B
# Af8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAg
# BgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZ
# bU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGalY17uT5IfdqBb
# MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAG
# CCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQw
# DQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tOCB3RKE/P09x7
# gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSXgmUrDKNSQqGT
# dpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPnvIWrqVogK0qM
# 8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM2UeUUW/8z3fv
# jxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlTVYzqfLDbe9Pp
# BKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ/xll/HjO9JbN
# VekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef4uaZFORNekUg
# QHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk9104WQzYuVNsxy
# oVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7ucykW7eaCuWB
# sBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZDBD+XgbF+23/z
# BjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3KeFUCS7tpFk7C
# rDqkMYIFJDCCBSACAQEwXzBIMQswCQYDVQQGEwJTRTEUMBIGA1UEChMLWmFtcGxl
# V29ya3MxIzAhBgNVBAMTGlphbXBsZVdvcmtzIEludGVybmFsIENBIHYzAhMxAAAA
# S5jn8iJKtIw9AAAAAABLMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKAC
# gAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsx
# DjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTCZUMStwIgVQah3cZGDiia
# qVYPgzANBgkqhkiG9w0BAQEFAASCAQBX7UjOarzrfg5o2XiYMGumORizcZpCl2SY
# Y1TMgiQVnnQ5lxF6LZkULBx0Km7sZBa3Rx/lza7NffEkcgxiwkUer2obgeWaz1xw
# z2R7uyzROslvMQVmUktyWUm51/O3ojEQEqx7F6JIHuScQmGOUdXx0YNfshGVv2IR
# vmHZOQgNxVsSkiZNNiXnQ99tOkUNC7lyXDSHs69eY2aak3WKzzh+we04VJpx6o4O
# szeIWRthoYcDhFGRpyDF7/0ekVv+fXZ/s0uiDJ7GRUb8EI5bMrcw+RLnL890gZ9Q
# 1HL/oaCYXvm0Pz0cWkQl7iaAVRTo3Pt3csgfsQILuLi0in9nVfNYoYIDIDCCAxwG
# CSqGSIb3DQEJBjGCAw0wggMJAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoT
# DkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJT
# QTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQC65mvFq6f5WHxvnpBOMzBDAN
# BglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZI
# hvcNAQkFMQ8XDTI1MDQyODA2NTU1NlowLwYJKoZIhvcNAQkEMSIEIDxWFApkv4cY
# AkJJlJ3RpcRsYNrKiMOC2lAlPOTm7O1WMA0GCSqGSIb3DQEBAQUABIICAHlS5IWb
# p7IM/jftn9CF+EXfQ237/2xLGwhy8tvLzZdNnXbYg4kRLnUgFoQM3mYGe5RFrZ0M
# 5pmwsS+QQYcOxTOi3hzI1SW7d65U1pGv00IUIZe5dKD5MVSOGXI8nTY2p4CcWW9z
# 99rgUR1qt1IWGXbXaz/R/vAm16wwyZ/jqSvpUJONgOPhPmwkM0yiHnphCECPoCTp
# mYo+eR3wkJgJb5iq3BbWyeqP7xejLqfDZ3cT/AZZd1UdEUvfNOb4otBIBVd+OunK
# wUutfFcyqN50enhnDau7zSrPTVKNC1iXpjgiJSaEZ/WQrIj6NzQJ9M+iOq0tGBGx
# NCX+83UKYGuT1DuBFOle4xU7p7wG2kRvie5M8DPHcKKMir2TFQ855EDJmBPYxOXR
# fB6y5cGNcOSyqvsb19aNm0hNkDnsvo67W3nfSF0EMN6f7RGIbvMmUuYpxt/cloGQ
# ubug7eMGpvPKHj3T1LVNw2QgOEOdz1eLd3S2iiao3ND7+sDzzmtmcWw50fxFCWOD
# QGM9vHJ3cfMeQKoGUwj6BKUefo3IXouydQunhrqO1GbYpQeOsNSU/0uqD1sH7Zkt
# 3rhq9894ti0l5kC+Wma5pKDU6tt/Vgv2OwSVERofh2Yve5CgNoaIiZPUbxJmqIN9
# 7LNIeJP0q+0LSokfn08/AOvVAMIa+sOs6rGn
# SIG # End signature block
