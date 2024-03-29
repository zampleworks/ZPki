<#PSScriptInfo

.VERSION 0.1.9.3

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


.PRIVATEDATA

#> 










<#

.DESCRIPTION
Exported functions for ZPki module

#>


#Requires -Version 4

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

        # Root directory for ADCS files
        [string]
        $ADCSPath = "C:\ADCS",

        # Database directory
        [string]
        $DbPath = "C:\ADCS\Db",

        # Transaction log directory
        [string]
        $DbLogPath = "C:\ADCS\DbLog"
    )

    If(-Not (Test-IsAdmin)) {
        Write-Error "This cmdlet requires admin privileges to run."
        return
    }

    #$IsRoot = $CaType -like "*root*"
    $IsStandalone = $CaType -like "*standalone*"

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

    $EnableCps = (-Not [string]::IsNullOrWhiteSpace($CpsOid)) -and $CpsOid.Length -gt 0
    If($EnableCps) {
        If([string]::IsNullOrWhiteSpace($CpsUrl) -and [string]::IsNullOrWhiteSpace($CpsNotice)) {
            Write-Error "If you want a CPS section in certificate you must include either CpsUrl or CpsNotice, or both."
        }
    }

    If($CaType -eq "StandaloneRootCA" -and ($EnableCps -Or $IncludeAssurancePolicy -or $IncludeAllIssuancePolicy) -And -not $RootCaForcePolicy) {
        Write-Error "Policy attributes should not be set in root CA certs. Use -RootCaForcePolicy to override."
    }

    $EnableEkuSection = $Null -ne $EkuOids -And $EkuOids.Count -gt 0
    If($EnableEkuSection) {
        Foreach($eku in $EkuOids) {
            If($eku -eq "Oid1" -or $eku -eq "Oid2") {
                Write-Error "EnhancedKeyUsageExtension is enabled, but oid list is left with defaults. `$EkuOids must be updated with real OID values you need on your CA."
            }
        }
    }

    $HeaderSection = Get-CaPolicyHeaderSection

    $CertSrvSection = Get-CaPolicyCertSrvSection -Keylength $Keylength -CACertValidityPeriod $CACertValidityPeriod -CACertValidityPeriodUnits $CACertValidityPeriodUnits `
                                                -CRLPeriod $CRLPeriod -CRLPeriodUnits $CRLPeriodUnits -DeltaPeriod $CrlDeltaPeriod -DeltaPeriodUnits $CrlDeltaPeriodUnits `
                                                -LoadDefaultTemplates $LoadDefaultTemplates -AltSignatureAlgorithm $AltSignatureAlgorithm `
                                                -ForceUTF8 $ForceUTF8 -ClockSkewMinutes $ClockSkewMinutes -EnableKeyCounting $EnableKeyCounting


    $CpsSection = ""
    $AssuranceSection = ""
    $AllIssuanceSection = ""

    $PolicyExtensionsSection = ""
    $BasicConstraintsSection = ""
    $EkuSection = ""

    $SectionNames = ""

    If($EnableCps) {
        $CpsSection = Get-CaPolicyPolicySection -PolicyName "CPS" -PolicyOid $CpsOid -PolicyNotice $CpsNotice -PolicyUrl $CpsURL
        $SectionNames = "CPS"
    }

    If($IncludeAssurancePolicy) {
        $AssuranceSection = Get-CaPolicyPolicySection -PolicyName "AssurancePolicy" -PolicyOid $AssurancePolicyOid -PolicyNotice $AssurancePolicyNotice -PolicyUrl $AssurancePolicyURL
        $SectionNames = "$SectionNames,AssurancePolicy".Trim(',')
    }

    If($IncludeAllIssuancePolicy) {
        $AllIssuanceSection = Get-CaPolicyPolicySection -PolicyName "AllIssuancePolicy" -PolicyOid $AllIssuancePolicyOid
        $SectionNames = "$SectionNames,AllIssuancePolicy".Trim(',')
    }

    If($EnableBasicConstraints) {
        $BasicConstraintsSection = Get-CaPolicyBasicConstraintsSection -PathLength $PathLength -Critical $BasicConstraintsIsCritical
    }

    If($EnableEkuSection) {
        $EkuSection = Get-CaPolicyEkuSection -Oids $EkuOids -Critical $EkuSectionIsCritical
    }

    $PolicyExtensionsSection = Get-CaPolicyPolicyExtensionsSection -Sections $SectionNames

    $HeaderSection, $PolicyExtensionsSection, $CpsSection, $AssuranceSection, $AllIssuanceSection, $EkuSection, $BasicConstraintsSection, $CertSrvSection | Out-File ".\CAPolicy.inf" -Force

    Copy-Item .\CAPolicy.inf C:\Windows -Force

    Write-Verbose ""
    Write-Verbose "Created CAPolicy.inf and copied it to windows directory"

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

    Write-Progress -Activity "Installing ADCS windows role"
    Write-Verbose "Installing ADCS Windows role"
    Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools | Out-Null

    Import-Module ADCSDeployment

    Write-Progress -Activity "Installing ADCS"

    Write-Verbose "Installing $($CAType)"
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
            'AdcsRepoPath' = $AdcsRepositoryPath
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

    If($EnableLDAPAIA) {
        Write-Verbose "Creating LDAP AIA configuration"
        $LdapUri = Get-LdapUri -IsAIA
        Add-CAAuthorityInformationAccess -Uri $LdapUri -AddToCertificateAia -Confirm:$False | Out-Null
    }

    If($EnableOCSP) {
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
    $password = [System.Web.Security.Membership]::GeneratePassword($Length,$NumberOfAlphaNumericCharacters)
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
# MIIczAYJKoZIhvcNAQcCoIIcvTCCHLkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU308eC7N75hMh8B/ZvTzxVbH5
# zuagghcSMIIEBzCCA6ygAwIBAgITMQAAAAaig5eyJWRoJAAAAAAABjAKBggqhkjO
# PQQDAjBIMQswCQYDVQQGEwJTRTEUMBIGA1UEChMLWmFtcGxlV29ya3MxIzAhBgNV
# BAMTGlphbXBsZVdvcmtzIEludGVybmFsIENBIHYzMB4XDTIyMDYyMzE3MTgwMloX
# DTIzMDYyMzE3MTgwMlowGjEYMBYGA1UEAxMPQW5kZXJzIFJ1bmVzc29uMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA570cFxi6rW2B1kjF7vdfpfsyUC0g
# cztkNGOsWdQQWSyyIOQa7Pj/iva9qJOpXgGCKVmI5JVD0h3UHdDBuTrsYZ2qNZiK
# XQpa3y+oWDjFnxUwuW6mPGv2L98tG3G1reINcPPfJIblHc3UqqrjzgKMpx8wijXC
# 0+zKaRb8gp8argwqv1dVEZkEGjSoi86YauRALWBI0Z2FplzgLSDcFYMFeEzka20v
# U42sO3POrdP+BN6Woiv87h04BepcFdkoYtbuzJDCfA2wgwc9A0DnDbHCgjbtmkcR
# GckJOzXh7SNypex++DHvQTCKgn2GZkmsx5Nudpz09aEYjWRClu45Oj2fOQIDAQAB
# o4IB1jCCAdIwPgYJKwYBBAGCNxUHBDEwLwYnKwYBBAGCNxUIhb31ToL5uhOGvZce
# h8eaKYeL30SBZIb4qhWEotFXAgFlAgECMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4G
# A1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1Ud
# DgQWBBTfjZA5S5YyR9Zc/wnR940dXISNvjAfBgNVHSMEGDAWgBTcnJy/9vjUCSFq
# nt0GjbrUATwUNjBiBggrBgEFBQcBAQRWMFQwUgYIKwYBBQUHMAKGRmh0dHA6Ly9w
# a2kub3Auendrcy54eXovUmVwb3NpdG9yeS9aYW1wbGVXb3JrcyUyMEludGVybmFs
# JTIwQ0ElMjB2My5jcnQwWwYDVR0RBFQwUqAvBgorBgEEAYI3FAIDoCEMH0FuZGVy
# cy5SdW5lc3NvbkB6YW1wbGV3b3Jrcy5jb22BH0FuZGVycy5SdW5lc3NvbkB6YW1w
# bGV3b3Jrcy5jb20wTQYJKwYBBAGCNxkCBEAwPqA8BgorBgEEAYI3GQIBoC4ELFMt
# MS01LTIxLTE2OTAwNzU1NC01NjE1NTU1ODMtMzQ2NTg3MDA2NS0xNTE2MAoGCCqG
# SM49BAMCA0kAMEYCIQCEN3STU0FB2cY6DaISc5cb5G7YOJ/4wyDBRBfWatnIaQIh
# AJfalg8eOYZUmEFuN4ZerSzIXP0hOc6kzFjRK35jg0OBMIIFjTCCBHWgAwIBAgIQ
# DpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwODAx
# MDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQD
# ExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aa
# za57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllV
# cq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT
# +CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd
# 463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+
# EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92k
# J7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5j
# rubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7
# f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJU
# KSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/Y+wh
# X8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQAB
# o4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5n
# P+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0P
# AQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29j
# c3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+MDww
# OqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJ
# RFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUAA4IB
# AQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSId229
# GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n096wwepqLsl7Uz9FD
# RJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxAGTVG
# amlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9vytsgjTVgHAIDyyCw
# rFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW/VvR
# XKwYw02fc7cBqZ9Xql4o4rmUMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipe
# WzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1
# OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1Bkmz
# wT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkL
# f50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C
# 3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5
# n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUd
# zTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWH
# po9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/
# oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPV
# A+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg
# 0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mM
# DDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6E
# VO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1Ud
# IwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNV
# HSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0f
# BDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBT
# zr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/E
# UExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fm
# niye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szw
# cqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8TH
# wcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/
# JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9
# Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm
# 228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVB
# tzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnw
# ZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv2
# 7dZ8/DCCBsAwggSooAMCAQICEAxNaXJLlPo8Kko9KQeAPVowDQYJKoZIhvcNAQEL
# BQAwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQTAeFw0yMjA5MjEwMDAwMDBaFw0zMzExMjEyMzU5NTlaMEYxCzAJBgNV
# BAYTAlVTMREwDwYDVQQKEwhEaWdpQ2VydDEkMCIGA1UEAxMbRGlnaUNlcnQgVGlt
# ZXN0YW1wIDIwMjIgLSAyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# z+ylJjrGqfJru43BDZrboegUhXQzGias0BxVHh42bbySVQxh9J0Jdz0Vlggva2Sk
# /QaDFteRkjgcMQKW+3KxlzpVrzPsYYrppijbkGNcvYlT4DotjIdCriak5Lt4eLl6
# FuFWxsC6ZFO7KhbnUEi7iGkMiMbxvuAvfTuxylONQIMe58tySSgeTIAehVbnhe3y
# YbyqOgd99qtu5Wbd4lz1L+2N1E2VhGjjgMtqedHSEJFGKes+JvK0jM1MuWbIu6pQ
# OA3ljJRdGVq/9XtAbm8WqJqclUeGhXk+DF5mjBoKJL6cqtKctvdPbnjEKD+jHA9Q
# Bje6CNk1prUe2nhYHTno+EyREJZ+TeHdwq2lfvgtGx/sK0YYoxn2Off1wU9xLokD
# EaJLu5i/+k/kezbvBkTkVf826uV8MefzwlLE5hZ7Wn6lJXPbwGqZIS1j5Vn1TS+Q
# Hye30qsU5Thmh1EIa/tTQznQZPpWz+D0CuYUbWR4u5j9lMNzIfMvwi4g14Gs0/EH
# 1OG92V1LbjGUKYvmQaRllMBY5eUuKZCmt2Fk+tkgbBhRYLqmgQ8JJVPxvzvpqwcO
# agc5YhnJ1oV/E9mNec9ixezhe7nMZxMHmsF47caIyLBuMnnHC1mDjcbu9Sx8e47L
# ZInxscS451NeX1XSfRkpWQNO+l3qRXMchH7XzuLUOncCAwEAAaOCAYswggGHMA4G
# A1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUF
# BwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAW
# gBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUYore0GH8jzEU7ZcLzT0q
# lBTfUpwwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNy
# bDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NB
# LmNydDANBgkqhkiG9w0BAQsFAAOCAgEAVaoqGvNG83hXNzD8deNP1oUj8fz5lTmb
# Jeb3coqYw3fUZPwV+zbCSVEseIhjVQlGOQD8adTKmyn7oz/AyQCbEx2wmIncePLN
# fIXNU52vYuJhZqMUKkWHSphCK1D8G7WeCDAJ+uQt1wmJefkJ5ojOfRu4aqKbwVNg
# CeijuJ3XrR8cuOyYQfD2DoD75P/fnRCn6wC6X0qPGjpStOq/CUkVNTZZmg9U0rIb
# f35eCa12VIp0bcrSBWcrduv/mLImlTgZiEQU5QpZomvnIj5EIdI/HMCb7XxIstiS
# DJFPPGaUr10CU+ue4p7k0x+GAWScAMLpWnR1DT3heYi/HAGXyRkjgNc2Wl+WFrFj
# DMZGQDvOXTXUWT5Dmhiuw8nLw/ubE19qtcfg8wXDWd8nYiveQclTuf80EGf2JjKY
# e/5cQpSBlIKdrAqLxksVStOYkEVgM4DgI974A6T2RUflzrgDQkfoQTZxd639ouiX
# dE4u2h4djFrIHprVwvDGIqhPm73YHJpRxC+a9l+nJ5e6li6FV8Bg53hWf2rvwpWa
# SxECyIKcyRoFfLpxtU56mWz06J7UWpjIn7+NuxhcQ/XQKujiYu54BNu90ftbCqhw
# fvCXhHjjCANdRyxjqCU4lwHSPzra5eX25pvcfizM/xdMTQCi2NYBDriL7ubgclWJ
# LCcZYfZ3AYwxggUkMIIFIAIBATBfMEgxCzAJBgNVBAYTAlNFMRQwEgYDVQQKEwta
# YW1wbGVXb3JrczEjMCEGA1UEAxMaWmFtcGxlV29ya3MgSW50ZXJuYWwgQ0EgdjMC
# EzEAAAAGooOXsiVkaCQAAAAAAAYwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFBoQc20Is4I4zgZQ
# 1l0zRV4XRYUgMA0GCSqGSIb3DQEBAQUABIIBAJmUm9noJqpEeoIpDYP8KIwrHLyy
# MfSrLPULY0c1aOzpgs9AwnL4dwhatULSe4az1PfnuottZYMbIH2d3IlL23gcJuLO
# s7zEzPundG7Hu84pduHruVOVnPrINqxiwuFyfjX7H0vWO6JQYeup6f9Zqp2zuh7N
# LV0JSCIqdylNeq5OIcT/jEovZyuTcUM1Fr/1gx+XDMv+MFuOiRd/f3FHz2Jonl1o
# v4dzYS7x+W2Bv631CBIsQ1wlQ6ggXeEKEXRSC0cCEMrgQRkIm2QWeRcdS8CBn+/a
# ytjNn/rtxKeO4JnJQMS+7lEGXAXhmSK00qy44+M++QkQpNXM21jfMymJ2NmhggMg
# MIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBjMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQg
# RzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAMTWlyS5T6PCpKPSkH
# gD1aMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAc
# BgkqhkiG9w0BCQUxDxcNMjMwMTEzMDkzNjA0WjAvBgkqhkiG9w0BCQQxIgQg8/M2
# WjFLKwkgwTfkhfk4QobQXk5+MKiolT1yCEZm4QYwDQYJKoZIhvcNAQEBBQAEggIA
# tjSHUdnpnswTF2EmP8qF9Rv5cqWLAOqU/ov2B77Ywh5addCshAcOZfzExfIjxnnn
# cM9D8OtIIrfQBXqBlcyK6Ft0KZUgTUrqs/3w6/Ca/0bSVM2EVGotUNImn7aV7AoV
# TQ7G5bBRFGlNsY8bPiO5BSbOrF/6rPUkBHdGYyQ4mrKB8SJRWtgXHGI/7Af7Zaph
# xxeB+yms9dPR0b3aKsLQkSXBP4L1sRIekn/IlHSNNCUx8p6lALjSN9zYskYlg5Cm
# /C0OgAO4gas+cJJWN7+iFoJLk70QwNN+DwRKYGjhjBQF7Ul2ayFOsvymYWsAYiq/
# CWZFAHC2whv0m2DYd8/LZDwVnAT58W9DnKqltv7e6QSiw36QdJ3ujCFu7e7vTtYJ
# 7La482DBOWvvsQZvRJVJIBHBXEQvhr1y4oUEwFTy/4SCj1rDnuKW3JW92K+9RI71
# 5COEbpAwJiO1eFSYwuPYbhluxWb7P0NrEdkEWFgUl0fnptZKwRSeYoUkhPZRB7XB
# Zq75bCkNTIR3bN7xTcUTIDFXs2qbTZ4flSjXy6jsMUnjGtNepx+Sn8Z/dC7ZQ0ZY
# fJUPuRxkbSnHI95t8Ocu6PuJy5/UAMDo+glNZCKeeOd3tg6WvpgE+UcZ/svQiiw/
# lWlgIvkRKf/P0wmFJDJ/NHGEXeWoR7AWsGjN3JoLg20=
# SIG # End signature block
