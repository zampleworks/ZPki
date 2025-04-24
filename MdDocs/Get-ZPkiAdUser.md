---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiAdUser

## SYNOPSIS
Get a specific AD user account

## SYNTAX

### GetByDistinguishedName
```
Get-ZPkiAdUser [[-DistinguishedName] <String>] [-Properties <String[]>] [-ResolveSecurityIdentifiers] [-Rpc]
 [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly]
 [-Credential <PSCredential>] [-ExtraVerbose] [<CommonParameters>]
```

### GetBySamaccountName
```
Get-ZPkiAdUser [-SamAccountName <String>] [-Properties <String[]>] [-ResolveSecurityIdentifiers] [-Rpc]
 [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly]
 [-Credential <PSCredential>] [-ExtraVerbose] [<CommonParameters>]
```

### GetByObjectGuid
```
Get-ZPkiAdUser [-ObjectGuid <Guid>] [-Properties <String[]>] [-ResolveSecurityIdentifiers] [-Rpc]
 [-Domain <String>] [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly]
 [-Credential <PSCredential>] [-ExtraVerbose] [<CommonParameters>]
```

### GetByName
```
Get-ZPkiAdUser [-ByName] [-Properties <String[]>] [-ResolveSecurityIdentifiers] [-Rpc] [-Domain <String>]
 [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>]
 [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Get an AD user account identified by ObjectGuid or Distinguished Name.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiAdUser "CN=Just A User,OU=Employees,OU=Users,OU=OZWCORP,DC=zwks,DC=xyz"

DistinguishedName  : CN=Just A User,OU=Employees,OU=Users,OU=ZWCORP,DC=zwks,DC=xyz
UserPrincipalName  : just.a.user@zampleworks.com
Mail               : just.a.user@zampleworks.com
DisplayName        : Just A User
Name               : Just A User
SamAccountName     : justauser
CommonName         : Just A User
UserAccountControl : Normal_Acct
PwdLastSet         : 1/18/2021 10:43:59 AM
Sid                : S-1-5-21-169007554-561555583-3465870065-1516
ObjectGuid         : 914fa5fe-74cf-4230-84c0-caea93c37acd
WhenCreated        : 4/8/2020 12:09:07 PM
WhenChanged        : 4/15/2025 2:25:37 PM
```

Get User by distinguished name

### Example 2
```powershell
PS C:\> "CN=Just A User,OU=Employees,OU=Users,OU=OZWCORP,DC=zwks,DC=xyz" | Get-ZPkiAdUser

DistinguishedName  : CN=Just A User,OU=Employees,OU=Users,OU=ZWCORP,DC=zwks,DC=xyz
UserPrincipalName  : just.a.user@zampleworks.com
Mail               : just.a.user@zampleworks.com
DisplayName        : Just A User
Name               : Just A User
SamAccountName     : justauser
CommonName         : Just A User
UserAccountControl : Normal_Acct
PwdLastSet         : 1/18/2021 10:43:59 AM
Sid                : S-1-5-21-169007554-561555583-3465870065-1516
ObjectGuid         : 914fa5fe-74cf-4230-84c0-caea93c37acd
WhenCreated        : 4/8/2020 12:09:07 PM
WhenChanged        : 4/15/2025 2:25:37 PM
```

get User by distinguished name via pipeline input 

### Example 3
```powershell
PS C:\> Find-ZPkiAdObject -ldapfilter "(samaccountname=justauser)" | Get-ZPkiAdUser

DistinguishedName  : CN=Just A User,OU=Employees,OU=Users,OU=ZWCORP,DC=zwks,DC=xyz
UserPrincipalName  : just.a.user@zampleworks.com
Mail               : just.a.user@zampleworks.com
DisplayName        : Just A User
Name               : Just A User
SamAccountName     : justauser
CommonName         : Just A User
UserAccountControl : Normal_Acct
PwdLastSet         : 1/18/2021 10:43:59 AM
Sid                : S-1-5-21-169007554-561555583-3465870065-1516
ObjectGuid         : 914fa5fe-74cf-4230-84c0-caea93c37acd
WhenCreated        : 4/8/2020 12:09:07 PM
WhenChanged        : 4/15/2025 2:25:37 PM
```

get User by distinguished name via pipeline input. You can pipe in an object with a DistinguishedName property

### Example 4
```powershell
PS C:\> Get-ZPkiAdUser -ObjectGuid 914fa5fe-74cf-4230-84c0-caea93c37acd

DistinguishedName  : CN=Just A User,OU=Employees,OU=Users,OU=ZWCORP,DC=zwks,DC=xyz
UserPrincipalName  : just.a.user@zampleworks.com
Mail               : just.a.user@zampleworks.com
DisplayName        : Just A User
Name               : Just A User
SamAccountName     : justauser
CommonName         : Just A User
UserAccountControl : Normal_Acct
PwdLastSet         : 1/18/2021 10:43:59 AM
Sid                : S-1-5-21-169007554-561555583-3465870065-1516
ObjectGuid         : 914fa5fe-74cf-4230-84c0-caea93c37acd
WhenCreated        : 4/8/2020 12:09:07 PM
WhenChanged        : 4/15/2025 2:25:37 PM
```

get User by ObjectGuid

## PARAMETERS

### -ByName
Force name

```yaml
Type: Switch
Parameter Sets: GetByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Credential for connecting.
Default on Windows is logged on user.
On non-Windows platforms, this is mandatory.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DistinguishedName
Distinguished Name

```yaml
Type: String
Parameter Sets: GetByDistinguishedName
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DnsOnly
Use only DNS for AD infrastructure discovery.
Do not use Win32/DirectoryServices API.

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

### -ObjectGuid
Get by ObjectID

```yaml
Type: Guid
Parameter Sets: GetByObjectGuid
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties
Select properties to return

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResolveSecurityIdentifiers
Resolve SIDs, GUIDs and ExtendedRights when returning object security

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

### -SamAccountName
Samaccountname

```yaml
Type: String
Parameter Sets: GetBySamaccountName
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

### System.String

## OUTPUTS

### System.Collections.Generic.IEnumerable`1[[xyz.zwks.pkilib.ad.AdUser, xyz.zwks.pkilib, Version=0.3.0.0, Culture=neutral, PublicKeyToken=null]]

## NOTES

## RELATED LINKS
