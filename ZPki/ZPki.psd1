#
# Module manifest for module 'ZPki'
#
# Generated by: Anders Runesson
#
# Generated on: 4/13/2025
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '0.1.10.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '564424c6-6ffe-4fd5-b681-d1db19ea5f73'

# Author of this module
Author = 'Anders Runesson'

# Company or vendor of this module
CompanyName = 'ZampleWorks'

# Copyright statement for this module
Copyright = '(c) Anders Runesson'

# Description of the functionality provided by this module
Description = 'PKI and certificate management'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = 'ZPki.types.ps1xml'

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('PsZPki.psm1', 
               'coreclr/ZPkiPsCore.dll')

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Copy-ZPkiCertSrvFilesToRepo', 'Export-ZPkiCertAsPem', 
               'Get-ZPkiAdIssuancePolicy', 'Get-ZPkiAdIssuancePolicyGroupLinks', 
               'Get-ZPkiLocalCaConfigString', 'Install-ZPkiCa', 
               'Install-ZPkiCaCertificate', 'Install-ZPkiRsatComponents', 
               'New-ZPkiCaBackup', 'New-ZPkiRandomPassword', 'New-ZPkiRepoCssFile', 
               'New-ZPkiRepoIndex', 'New-ZPkiWebsite', 'Publish-ZPkiCaDsFile', 
               'Remove-ZPkiAdIssuancePolicyGroupLink', 
               'Set-ZPkiAdAltSecurityIdentities', 
               'Set-ZPkiAdIssuancePolicyGroupLink', 'Set-ZPkiCaPostInstallConfig', 
               'Set-ZPkiCaUrlConfig', 'Submit-ZPkiRequest'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = 'Convert-ZPkiHexToBytes', 'Find-ZPkiAdAttributeSchema', 
               'Find-ZPkiAdClassSchema', 'Find-ZPkiAdControlAccessRight', 
               'Find-ZPkiAdObject', 'Find-ZPkiAdOid', 'Find-ZPkiAdUser', 
               'Find-ZPkiLocalCert', 'Get-ZPkiAdCasConfigString', 
               'Get-ZPkiAdcsRoles', 'Get-ZPkiAdDomain', 'Get-ZPkiAdForest', 
               'Get-ZPkiAdForestOid', 'Get-ZPkiAdMsSchema', 'Get-ZPkiAdRootDse', 
               'Get-ZPkiAdTemplate', 'Get-ZPkiAdTemplateRiskScore', 'Get-ZPkiAsn', 
               'Get-ZPkiCertCdpUris', 'Get-ZPkiCrl', 'Get-ZPkiDbLastRowId', 
               'Get-ZPkiDbRow', 'Get-ZPkiDbSchema', 'Get-ZPkiOid', 
               'Get-ZPkiOidCnFromOid', 'Get-ZPkiServiceBindings', 
               'New-ZPkiCertRequest', 'Test-ZPkiAdcsIsOnline', 'Test-ZPkiIsAdmin', 
               'Test-ZPkiServiceBinding', 'Test-ZPkiTlsConnection'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'zpadfo', 'fzpcert', 'gzpconfig', 'gzpaddom', 'gzpadfrst', 'gzpmsschema', 
               'zpadrdse', 'gzptpl', 'gzpa', 'gzpcdp', 'gzpcrl', 'zpschema', 'gznfh', 'nzpcsr', 
               'tzptls'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'PSEdition_Core', 'PKI', 'ActiveDirectory'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/zampleworks/ZPki'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

