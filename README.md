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

### Access Control Lists (ACL) output
You can include an objects AD ACL by requesting the nTSecurityDescriptor attribute as part of the returned properties. The ACL will be in $OutputObject.Access.Acl:
```
# Find AD user object, and ensure we only store one object in case there's many matching the name 'anders'
PS:> $User = Find-ZPkiAdUser anders -Properties ntsecuritydescriptor | Select-Object -First 1
PS:> $User.Access.Acl
...
ActiveDirectoryRights : ReadProperty, WriteProperty, ExtendedRight
AccessControlType     : Allow
ObjectType            : 91e647de-d96f-4b70-9557-d63ff4f3ccd8
InheritedObjectType   :
IdentityReference     : S-1-5-10
InheritanceType       : All
IsInherited           : True
InheritanceFlags      : ContainerInherit
PropagationFlags      : None
ObjectFlags           : ObjectAce

ActiveDirectoryRights : GenericAll
AccessControlType     : Allow
ObjectType            :
InheritedObjectType   :
IdentityReference     : S-1-5-21-169007554-561555583-3465870065-519
InheritanceType       : All
IsInherited           : True
InheritanceFlags      : ContainerInherit
PropagationFlags      : None
ObjectFlags           : None

ActiveDirectoryRights : CreateChild, Self, WriteProperty, ExtendedRight, Delete, GenericRead, WriteDacl, WriteOwner
AccessControlType     : Allow
ObjectType            :
InheritedObjectType   :
IdentityReference     : S-1-5-32-544
InheritanceType       : All
IsInherited           : True
InheritanceFlags      : ContainerInherit
PropagationFlags      : None
ObjectFlags           : None
...
```

This looks like the output you'd expect from the built in Get-Acl cmdlet. If you want the output to be a bit more helpful, include the -ResolveSecurityIdentifiers switch, and IdentityReference, ObjectType, and InheritedObjectType will be translated into human-readable ID's instead. With -ResolveSecurityIdentifiers supplied '-Properties nTSecurityDescriptor' is implied, so no need to include it.
The properties are name-value properties, so if you need the raw identifier it's still there:

```
# Find AD user object, and ensure we only store one object in case there's many matching the name 'anders'
PS:> $User = Find-ZPkiAdUser anders.runesson -ResolveSecurityIdentifiers | Select-Object -First 1
PS:> $User.Access.Acl
...
ActiveDirectoryRights : ReadProperty, WriteProperty, ExtendedRight
AccessControlType     : Allow
ObjectType            : Private-Information
InheritedObjectType   :
IdentityReference     : SELF
InheritanceType       : All
IsInherited           : True
InheritanceFlags      : ContainerInherit
PropagationFlags      : None
ObjectFlags           : ObjectAce

ActiveDirectoryRights : GenericAll
AccessControlType     : Allow
ObjectType            :
InheritedObjectType   :
IdentityReference     : OZWCORP\Enterprise Admins
InheritanceType       : All
IsInherited           : True
InheritanceFlags      : ContainerInherit
PropagationFlags      : None
ObjectFlags           : None

ActiveDirectoryRights : CreateChild, Self, WriteProperty, ExtendedRight, Delete, GenericRead, WriteDacl, WriteOwner
AccessControlType     : Allow
ObjectType            :
InheritedObjectType   :
IdentityReference     : Administrators
InheritanceType       : All
IsInherited           : True
InheritanceFlags      : ContainerInherit
PropagationFlags      : None
ObjectFlags           : None
...

PS:> $Ace = $User.Access.Acl | Select-Object -Last 2 | Select-Object -First 1
PS:> $Ace.IdentityReference

Value                                       Name
-----                                       ----
S-1-5-21-169007554-561555583-3465870065-519 OZWCORP\Enterprise Admins

PS:> $Ace = $User.Access.Acl | Select-Object -Last 3 | Select-Object -First 1
PS:> $Ace.ObjectType

Value                                Name
-----                                ----
91e647de-d96f-4b70-9557-d63ff4f3ccd8 Private-Information
```

### AD Schema information
It's a pain interpreting ACEs with the built-in tools - all you get are GUID's in ACEs and you'll have to dig around yourselves to find them. As you can see above, with the ZPki module you can get a name along with the identifier which is already very helpful.  
There are also cmdlets to get schema data - classSchemas and attributeSchemas, and also controlAccessRights - extended rights, property sets, and validated writes. The returned objects also have relation properties populated, for example if you query a property set (like "Private-Information" from the ACE entry above) the returned object has a "PropertySetMembers" property linking to the attributeSchema objects included in the property set. The cmdlets take a Guid as pipeline input, so using the Guid from the ObjectType in the ACE above:

```
PS:> $Ace.ObjectType.Value | Find-ZPkiAdControlAccessRight

DistinguishedName  : CN=Private-Information,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName         : Private-Information
DisplayName        : Private Information
ObjectGuid         : ec8ae1c3-5ab1-4ca4-a24d-6ad5ee5b9767
RightsGuid         : 91e647de-d96f-4b70-9557-d63ff4f3ccd8
ValidAccesses      : 48
AppliesTo          : {user, inetOrgPerson}
PropertySetMembers : {msPKI-CredentialRoamingTokens, msPKIAccountCredentials, msPKIDPAPIMasterKeys,
                     msPKIRoamingTimeStamp}
```

The PropertySetMembers are attributeSchema objects, and not just strings:

```
PS:> $Ace.ObjectType.Value | Find-ZPkiAdControlAccessRight | Select-Object -ExpandProperty PropertySetMembers

DistinguishedName     : CN=ms-PKI-Credential-Roaming-Tokens,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
ObjectGuid            : 5949b18c-6049-4186-8a6c-5c3a11896988
Name                  : ms-PKI-Credential-Roaming-Tokens
CommonName            : ms-PKI-Credential-Roaming-Tokens
LdapDisplayName       : msPKI-CredentialRoamingTokens
ObjectGuid            : 5949b18c-6049-4186-8a6c-5c3a11896988
SchemaIdGuid          : b7ff5a38-0818-42b0-8110-d3d154c97f24
AttributeSecurityGuid : 91e647de-d96f-4b70-9557-d63ff4f3ccd8
PropertySets          : {CN=Private-Information,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz}
IsSingleValued        : False
OmSyntax              : 127
OmObjectClass         : KoZIhvcUAQEBCw==
SystemFlags           : BaseSchemaObject
SystemOnly            :
AttributeSyntax       : Object(DN-Binary); A distinguished name plus a binary large object (2.5.5.7)

DistinguishedName     : CN=ms-PKI-AccountCredentials,CN=Schema,CN=Configuration,DC=zwks,DC=xyz
ObjectGuid            : 0027c49f-9090-4d59-ac84-cf6be3c7ea5b
Name                  : ms-PKI-AccountCredentials
CommonName            : ms-PKI-AccountCredentials
LdapDisplayName       : msPKIAccountCredentials
ObjectGuid            : 0027c49f-9090-4d59-ac84-cf6be3c7ea5b
SchemaIdGuid          : b8dfa744-31dc-4ef1-ac7c-84baf7ef9da7
AttributeSecurityGuid : 91e647de-d96f-4b70-9557-d63ff4f3ccd8
PropertySets          : {CN=Private-Information,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz}
IsSingleValued        : False
OmSyntax              : 127
OmObjectClass         : KoZIhvcUAQEBCw==
SystemFlags           : BaseSchemaObject
SystemOnly            :
AttributeSyntax       : Object(DN-Binary); A distinguished name plus a binary large object (2.5.5.7)
...
```

### Searching for AD schema and controlAccessRights objects
There are 3 cmdlets for querying schema and controlAccessRights:
* Find-ZPkiAdAttributeSchema
* Find-ZPkiAdClassSchema
* Find-ZPkiAdControlAccessRight

They all can take either a guid or a name as search parameter:

- name as a parameter in position 0 (no parameter name needed). This may return several objects matching the name
- Guid from pipeline input
- Guid from pipeline input via property name
- Guid as parameter
  - "-RightsGuid" for Find-ZPkiAdControlAccessRight
  - "-SchemaIdGuid" for Find-ZPkiAdAttributeSchema and Find-ZPkiAdClassSchema

Note that classSchema and attributeSchema objects are identified by the SchemaIDGuid attribute, and controlAccessRights are identified by the RightsGuid attribute.

Continuing with the above examples: 

```
# $Car has the guid for the "Private-Information" property set:
PS:> $Car = $User.Access.Acl | Select-Object -Last 3 | Select-Object -First 1 | Select-Object -ExpandProperty ObjectType | Select-Object -ExpandProperty Value | Find-ZPkiAdControlAccessRight  

# Create an object with a "RightsGuid" property
PS:> $CarPsObj = [PSCustomObject]@{RightsGuid = $Car.RightsGuid}
PS:> $CarPsObj

RightsGuid
----------
91e647de-d96f-4b70-9557-d63ff4f3ccd8

# We can now pipe the object into Find-ZPkiAdControlAccessRight
PS:> $CarPsObj | Find-ZPkiAdControlAccessRight

DistinguishedName  : CN=Private-Information,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName         : Private-Information
DisplayName        : Private Information
ObjectGuid         : ec8ae1c3-5ab1-4ca4-a24d-6ad5ee5b9767
RightsGuid         : 91e647de-d96f-4b70-9557-d63ff4f3ccd8
ValidAccesses      : 48
AppliesTo          : {user, inetOrgPerson}
PropertySetMembers : {msPKI-CredentialRoamingTokens, msPKIAccountCredentials, msPKIDPAPIMasterKeys,
                     msPKIRoamingTimeStamp}

# We can of course use the Guid directly: 
PS:> "91e647de-d96f-4b70-9557-d63ff4f3ccd8" | Find-ZPkiAdControlAccessRight

DistinguishedName  : CN=Private-Information,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName         : Private-Information
DisplayName        : Private Information
ObjectGuid         : ec8ae1c3-5ab1-4ca4-a24d-6ad5ee5b9767
RightsGuid         : 91e647de-d96f-4b70-9557-d63ff4f3ccd8
ValidAccesses      : 48
AppliesTo          : {user, inetOrgPerson}
PropertySetMembers : {msPKI-CredentialRoamingTokens, msPKIAccountCredentials, msPKIDPAPIMasterKeys,
                     msPKIRoamingTimeStamp}

# Or via parameter: 
PS:> Find-ZPkiAdControlAccessRight -RightsGuid "91e647de-d96f-4b70-9557-d63ff4f3ccd8"

DistinguishedName  : CN=Private-Information,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName         : Private-Information
DisplayName        : Private Information
ObjectGuid         : ec8ae1c3-5ab1-4ca4-a24d-6ad5ee5b9767
RightsGuid         : 91e647de-d96f-4b70-9557-d63ff4f3ccd8
ValidAccesses      : 48
AppliesTo          : {user, inetOrgPerson}
PropertySetMembers : {msPKI-CredentialRoamingTokens, msPKIAccountCredentials, msPKIDPAPIMasterKeys,
                     msPKIRoamingTimeStamp}
```

### Analyze ACLs for security problems
The module has a cmdlet for analyzing ACEs and finding potential weaknesses and paths for privilege escalation. There's plenty of scripts out there that pretty-print ACLs on objects, but this module goes a step beyond and actually tries to tell you what the ACE means.

```
# Retrieve an AD object with questionable permissions: 
PS:> $Ou = Find-ZPkiAdObject -LdapFilter "(ou=testlvl2-2)" -ResolveSecurityIdentifiers

# You can see the raw ACL if you wish via the property $Ou.Access.Acl:
PS:> $Ou.Access.Acl
...
ActiveDirectoryRights : GenericAll
AccessControlType     : Allow
ObjectType            :
InheritedObjectType   :
IdentityReference     : OZWCORP\Domain Admins
InheritanceType       : All
IsInherited           : False
InheritanceFlags      : ContainerInherit
PropagationFlags      : None
ObjectFlags           : None
...
ActiveDirectoryRights : ReadProperty, WriteProperty
AccessControlType     : Allow
ObjectType            :
InheritedObjectType   :
IdentityReference     : OZWCORP\Role AD Admin
InheritanceType       : None
IsInherited           : False
InheritanceFlags      : None
PropagationFlags      : None
ObjectFlags           : None
...
ActiveDirectoryRights : ReadProperty, WriteProperty
AccessControlType     : Allow
ObjectType            : Self-Membership
InheritedObjectType   : group
IdentityReference     : OZWCORP\william0
InheritanceType       : Descendents
IsInherited           : False
InheritanceFlags      : ContainerInherit
PropagationFlags      : InheritOnly
ObjectFlags           : ObjectAce, InheritedAce
...
```

If we run Test-ZPkiAdObjectAclSecurity on this object we'll get a helpful result telling us **why** these permissions are bad. 'Generic All' and 'WriteProperty' are kinda self explanatory, and delegated to Domain Admins and Role AD Admin - they probably should have high permissions. But the last one? Let's see:

```
PS:> $Ou | Test-ZPkiAdObjectAclSecurity
...
Category            : GenericAll
DelegationObject    : OU=testlvl2-2,OU=TestOuInher,OU=Test objects,DC=op,DC=zwks,DC=xyz
DelegationSubject   : OZWCORP\Domain Admins
...
Category            : GpoLinkWrite, GpoInheritanceWrite, WriteAllProperties
DelegationObject    : OU=testlvl2-2,OU=TestOuInher,OU=Test objects,DC=op,DC=zwks,DC=xyz
DelegationSubject   : OZWCORP\Role AD Admin
...
Category            : GroupMemberWrite
DelegationObject    : OU=testlvl2-2,OU=TestOuInher,OU=Test objects,DC=op,DC=zwks,DC=xyz
DelegationSubject   : OZWCORP\william0
ObjectType          :
InheritedObjectType :
ClassSchema         : CN=Group,CN=Schema,CN=Configuration,DC=op,DC=zwks,DC=xyz
AttributeSchema     :
ControlAccessRight  : CN=Self-Membership,CN=Extended-Rights,CN=Configuration,DC=op,DC=zwks,DC=xyz
...
```

The first one is simple - GenericAll is the same as when you set "Full Control" in the Security dialog in ADUC.

The second entry has both WriteAllProperties, but also GpoLinkWrite and GpoInheritanceWrite. These two rights are specific to OUs, domains, and site objects and the cmdlet adds them to make it clear exactly what it means from a security perspective when someone has WriteAllProperties permission on an OU.

The last one is more interesting - if you look in the raw ACE entry above, it is not clear what 'Self-Membership' means. According to Microsoft's documentation (https://learn.microsoft.com/en-us/windows/win32/adschema/r-self-membership) it enables someone to add/remove themselves as members from a group - this is not correct however. With the delegation above, william0 can add/remove anyone from groups in the OU!

### Cross-forest queries and explicit credentials
Querying another forest without a trust is supported using the -Credentials parameter. With the Credentials parameter you can also query the local domain with another user account than the logged in account (which is the default).  
In the example below, the command is run logged on to a computer and with an account in a different forest than mydomain.zwks.xyz, with no trusts between them.

```
PS:> $cred = New-Object System.Management.Automation.PSCredential("wendy.kahn@mydomain.zwks.xyz", (ConvertTo-SecureString "MyFavouritePassword" -AsPlaintext -Force))
PS:> Find-ZPkiAdUser wendy0 -Domain mydomain.zwks.xyz -Credential $cred

DistinguishedName  : CN=Wendy Beth Kahn,OU=Employees,OU=Users,OU=mydomain,DC=mydomain,DC=zwks,DC=xyz
UserPrincipalName  : Wendy.Kahn@mydomain.zwks.xyz
Mail               : Wendy.Kahn@zampleworks.com
DisplayName        : Wendy Beth Kahn
Name               : Wendy Beth Kahn
SamAccountName     : wendy0
CommonName         : Wendy Beth Kahn
UserAccountControl : Normal_Acct
PwdLastSet         : 4/26/2025 3:27:12 AM
Sid                : S-1-5-21-2918238891-334350930-1642106308-1481
ObjectGuid         : cd58d8c1-7463-4b5c-ad88-e4bd14306294
WhenCreated        : 1/27/2025 11:02:02 AM
WhenChanged        : 4/26/2025 3:30:03 AM
```

### Cert validation (ADWS)
The default behaviour for ZPki is more strict than the ActiveDirectory module. It will not run queries without TLS, and the default is to validate both the trust chain against the local machine trust store, and to check revocation status.  
When connecting to different forests you may not trust the certificates from the other forests, and you may not be able to check revocation (if the remote forest only uses LDAP CDP, for example). In these cases you can change validation settings.

Valid options for CertRevocationMode are: NoCheck, Online, Offline

Valid options for CertValidationMode are: None, PeerTrust, ChainTrust, PeerOrChainTrust

```
PS:> $cred = New-Object System.Management.Automation.PSCredential("wendy.kahn@mydomain.zwks.xyz", (ConvertTo-SecureString "MyFavouritePassword" -AsPlaintext -Force))
PS:> Find-ZPkiAdUser wendy0 -Domain mydomain.zwks.xyz -Credential $cred -CertRevocationMode NoCheck -CertValidationMode None

DistinguishedName  : CN=Wendy Beth Kahn,OU=Employees,OU=Users,OU=mydomain,DC=mydomain,DC=zwks,DC=xyz
UserPrincipalName  : Wendy.Kahn@mydomain.zwks.xyz
Mail               : Wendy.Kahn@zampleworks.com
DisplayName        : Wendy Beth Kahn
Name               : Wendy Beth Kahn
SamAccountName     : wendy0
CommonName         : Wendy Beth Kahn
UserAccountControl : Normal_Acct
PwdLastSet         : 4/26/2025 3:27:12 AM
Sid                : S-1-5-21-2918238891-334350930-1642106308-1481
ObjectGuid         : cd58d8c1-7463-4b5c-ad88-e4bd14306294
WhenCreated        : 1/27/2025 11:02:02 AM
WhenChanged        : 4/26/2025 3:30:03 AM
```

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