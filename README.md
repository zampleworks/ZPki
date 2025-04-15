# ZPki
A collection of utilities for managing PKI and certificates. 
Currently included is a powershell module and work is ongoing 
on a GUI client to make cert management less painful. 

The project also contains sample scripts for ADCS deployment and 
configuration.

## Project structure

### Zamples - AdcsDeployment
Scripts for installation and configuration of ADCS. These scripts are intended as guides for how to deploy ADCS using the PS module. Grab them and modify per your own needs.

### ZPki
PS backend module. Mixed binary and script module. Includes functionality for  
querying and managing ADCS and AD, and ADCS deployment. AD support is focused 
toward ADCS as of yet but has some nifty cmdlets for AD querying.

#### Installing PS module
Preferably, install the ZPki module from PSGallery instead of downloading it from Github:

```
PS:> Register-PSRepository -Default
PS:> Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
PS:> Install-Module -Name ZPki
```

To install this module you need PowerShell 7.2 or newer: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell

When installing from PSGallery you only get the PS module. Sample scripts
and non-PS tools are not included and need to be downloaded from Github.

If you need to install the PS module in an offline environment, download the
latest release and run the supplied install script.

## Environment
Tested and works on Windows Server 2012R2+ and Windows 10.

For Windows 10 1803 and earlier, you must install RSAT manually
to use all features, and enable the ADCS management tools. 
You will get a COM error from any cmdlet that calls the CA directly
if it is missing. 
On newer OSes you can use Install-ZPkiRsatComponents to install 
the necessary components easily.

Only some parts work on non-windows OSes. AD, ADCS, and Win32 cmdlets and lib calls do not work. Sorry.

## Usage and examples
### General notes 
The cmdlets in this module will either provide functionality not available in built in modules, or  try to be a little more helpful than some of built in similar cmdlets.

For example, when retrieving an AD user, the attributes are decoded into a useable and readable format. Date attributes are returned as DateTime, instead of the very annoying nTFileTime format and other enum/flag attributes are interpreted for you. See examples further down.

This is primarily a compiled module, with some wrapper scripts provided where calling other powershell modules is required. Behind the compiled PS module is a C# library that does the heavy lifting - this could potentially be included in your own .NET projects, but note that I'm not promising any API stability and no documentation, so this is probably risky.

There is as yet limited to no support for writing data back to Active Directory. It may be added in the future, but for now MS ActiveDirectory module is used for writing in the few places it is done.


**Example MS ActiveDirectory module output**
```
PS:> Get-AdUser anders -properties userAccountControl,pwdLastSet
...
pwdLastSet         : 132554366397124441
userAccountControl : 512
...
```

**ZPki output**
```
PS:> Find-ZPkiAdUser anders -properties userAccountControl,pwdLastSet
...
PwdLastSet                : 1/18/2021 10:43:59 AM
UserAccountControl        : Normal_Acct
...
```

Querying for other types of objects include similar user and programmer friendliness. The objects and properties returned are generally strongly typed to make it easy to process objects programmatically without string juggling or manual tedious conversions. The UserAccountControl property above is an .NET enum that can be used in your own scripts:
```
PS:> Find-ZPkiAdUser and -properties userAccountControl, pwdLastSet | Where-Object {$_.UserAccountControl.hasflag([xyz.zwks.pkilib.ad.UserAccountControl]::AccountDisable)} | select displayname, useraccountcontrol

DisplayName                    UserAccountControl
-----------                    ------------------
Andreas T Berglund    AccountDisable, Normal_Acct
Sean P Alexander      AccountDisable, Normal_Acct
Candy L Spoon         AccountDisable, Normal_Acct
Barbara C Moreland    AccountDisable, Normal_Acct
Mikael Q Sandberg     AccountDisable, Normal_Acct
Brandon G Heidepriem  AccountDisable, Normal_Acct
Nancy A Anderson      AccountDisable, Normal_Acct
Andrew R Hill         AccountDisable, Normal_Acct
Randy T Reeves        AccountDisable, Normal_Acct
Carole M Poland       AccountDisable, Normal_Acct
Sandeep P Kaliyath    AccountDisable, Normal_Acct
Mandar H Samant       AccountDisable, Normal_Acct
Cynthia S Randall     AccountDisable, Normal_Acct
Andy M Ruth           AccountDisable, Normal_Acct
Michael T Vanderhyde  AccountDisable, Normal_Acct
Linda A Randall       AccountDisable, Normal_Acct
Andrew M Cencini      AccountDisable, Normal_Acct
Nitin S Mirchandani   AccountDisable, Normal_Acct
Alejandro E McGuel    AccountDisable, Normal_Acct
Tom M Vande Velde     AccountDisable, Normal_Acct
Sandra Reátegui Alayo AccountDisable, Normal_Acct
```


There are many common parameters among the cmdlets, mostly regarding connectivity
to Active Directory or specifying an ADCS instance. They are mostly self explanatory,
but a couple deserve explanation:

* -Rpc: Query AD via ADSI interface instead of ADWS
* -DnsOnly: Does not attempt to use local Windows APIs to determine domain services. May work better when connecting to domains other that user/computers own domain.
* -ResolveSecurityIdentifiers: Include object ACL in output, and attempt to resolve all identifiers - IdentityReference, ObjectType, and InheritedObjectType. These fields will have related objects populated with the relevant data - classSchema, attributeSchema, and controlAccessRights objects. This is read from Active Directory when requested, and may take a moment to read. Data is cached and will be preserved between invocations of different cmdlets, but if you exit the powershell process the cache will be emptied.

### Find config strings for ADCS instances in the forest
```
PS:> Get-ZPkiAdCasConfigString
SRV1.ad.zwks.xyz\ZampleWorks Issuing CA 1
SRV3.ad.zwks.xyz\ZampleWorks Issuing CA 2
```

### Check if ADCS instance is online and accessible
```
PS:> Get-ZPkiAdCasConfigString | Test-ZPkiAdcsIsOnline
true
```

### Get current user's CA roles on an ADCS instance
```
PS:> Get-ZPkiAdCasConfigString | Get-ZPkiAdcsRoles
CaOfficer, CaReader, CaSubscriber
```

### Get AD Forest OID
Retrieve the forest-wide OID that is randomly generated when the first ADCS instance is installed, and gets written as template OID to every template in the forest. This value 
is deterministic from the moment the forest is installed (it is based on the ObjectGuid
of the OID container in the configuration partition), but is not stored until ADCS is 
installed. This cmdlet will get the correct value even if ADCS has not yet been installed.
```
PS:> Get-ZPkiAdForestOid
1.3.6.1.4.1.311.21.8.11500238.6184211.13585310.15846697.14872516.228
```

### Query ADCS database

#### Retrieve the database schema 
In order to do row queries, you need to know the names of the DB columns. They can be retrieved with:

```
PS:> Get-ZPkiAdCasConfigString | Get-ZPkiDbSchema | Select-Object Name
... (output trimmed for brevity)
Name
----
Request.RequestID
Request.RawRequest
Request.StatusCode
Request.Disposition
Request.DispositionMessage
Request.SubmittedWhen
Request.DistinguishedName
RequestID
RawCertificate
CertificateHash
CertificateTemplate
EnrollmentFlags
SerialNumber
NotBefore
NotAfter
SubjectKeyIdentifier

```
These column names can then be used in queries to the database.

#### Get ADCS DB rows

By default RequestID, Request_Disposition, Request_RequesterName, CommonName, NotBefore, NotAfter, and SerialNumber are included in the output. 

```
PS:> Get-ZPkiAdCasConfigString | Get-ZPkiDbRow -filters {RequestID == 3}
RequestID             : 3
Request_Disposition   : 20
Request_RequesterName : OZWCORP\SRV03$
CommonName            : SRV03.ad.zwks.xyz
NotBefore             : 5/30/2022 12:58:59 PM
NotAfter              : 5/30/2023 12:58:59 PM
SerialNumber          : 31000000033c19283a62deb106000000000003
```

If you wish to return more data you can use the -Properties parameter using the DB column names from before. Note that when -Properties is used no default columns are included. Columns with a period in the name are renamed in the output with the period replaced with an underscore:

```
PS:> Get-ZPkiAdCasConfigString | Get-ZPkiDbRow -filters {RequestID == 2} -Properties RequestID, CommonName, Request.RawRequest | select RequestID, CommonName, Request_RawRequest

RequestID CommonName         Request_RawRequest
--------- ----------         ------------------
        2 SRV01A.ad.zwks.xyz MIIGUgYJKoZIhvcNAQcCoIIGQzC...

```