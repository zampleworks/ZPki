---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Find-ZPkiAdControlAccessRight

## SYNOPSIS
Get ControlAccessRights registered in Active Directory

## SYNTAX

### SearchByName (Default)
```
Find-ZPkiAdControlAccessRight [[-Name] <String>] [-Type <ControlAccessRightsType>] [-Rpc] [-Domain <String>]
 [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>]
 [-ExtraVerbose] [<CommonParameters>]
```

### SearchByGuid
```
Find-ZPkiAdControlAccessRight [-Type <ControlAccessRightsType>] [-RightsGuid <Guid>] [-Rpc] [-Domain <String>]
 [-DomainController <String>] [-SiteName <String>] [-UserDomain] [-DnsOnly] [-Credential <PSCredential>]
 [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
ControlAccessRights are Extended Rights, Validated Writes, or Property Sets. Search for all or specify which type you need.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-ZPkiAdControlAccessRight
DistinguishedName : CN=Domain-Administer-Server,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName        : Domain-Administer-Server
DisplayName       : Domain Administer Server
ObjectGuid        : a35a59cd-8de9-4d69-bcb6-26ee3424dda9
RightsGuid        : ab721a52-1e2f-11d0-9819-00aa0040529b
ValidAccesses     : 256
AppliesTo         : {samServer}

DistinguishedName : CN=User-Change-Password,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName        : User-Change-Password
DisplayName       : Change Password
ObjectGuid        : c8d00f05-570f-4248-9985-c5f7d3c2c01b
RightsGuid        : ab721a53-1e2f-11d0-9819-00aa0040529b
ValidAccesses     : 256
AppliesTo         : {inetOrgPerson, msDS-ManagedServiceAccount, computer, user}

DistinguishedName : CN=User-Force-Change-Password,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName        : User-Force-Change-Password
DisplayName       : Reset Password
...
```

Find all types of ControlAccessRights

### Example 2
```powershell
PS C:\> Find-ZPkiAdControlAccessRight -Type ExtendedRight

DistinguishedName : CN=Domain-Administer-Server,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName        : Domain-Administer-Server
DisplayName       : Domain Administer Server
ObjectGuid        : a35a59cd-8de9-4d69-bcb6-26ee3424dda9
RightsGuid        : ab721a52-1e2f-11d0-9819-00aa0040529b
ValidAccesses     : 256
AppliesTo         : {samServer}

DistinguishedName : CN=User-Change-Password,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName        : User-Change-Password
DisplayName       : Change Password
ObjectGuid        : c8d00f05-570f-4248-9985-c5f7d3c2c01b
RightsGuid        : ab721a53-1e2f-11d0-9819-00aa0040529b
ValidAccesses     : 256
AppliesTo         : {inetOrgPerson, msDS-ManagedServiceAccount, computer, user}

DistinguishedName : CN=User-Force-Change-Password,CN=Extended-Rights,CN=Configuration,DC=zwks,DC=xyz
CommonName        : User-Force-Change-Password
DisplayName       : Reset Password
...
```

Find Extended Rights

## PARAMETERS

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

### -Name
Search by name.
Will match attributes Common Name, Name, or DisplayName

```yaml
Type: String
Parameter Sets: SearchByName
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RightsGuid
Filter by rightsGuid

```yaml
Type: Guid
Parameter Sets: SearchByGuid
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### -Type
Filter by type

```yaml
Type: ControlAccessRightsType
Parameter Sets: (All)
Aliases:
Accepted values: Any, ExtendedRight, PropertySet, ValidatedWrite

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

### System.Guid

## OUTPUTS

### System.Collections.Generic.IEnumerable`1[[xyz.zwks.pkilib.ad.ControlAccessRight, xyz.zwks.pkilib, Version=0.2.1.0, Culture=neutral, PublicKeyToken=null]]

## NOTES

## RELATED LINKS
