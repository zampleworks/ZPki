---
external help file: ZPkiPsCore.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Find-ZPkiLocalCert

## SYNOPSIS
Search for certificates in local windows stores

## SYNTAX

### SpecificSearch
```
Find-ZPkiLocalCert [-SearchFor] <String> [-Store <StoreLocation>] [-StoreName <StoreName>] [-ExtraVerbose]
 [<CommonParameters>]
```

### GlobalSearch
```
Find-ZPkiLocalCert [-SearchFor] <String> [-GlobalSearch] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Search for certificates matching SearchFor parameter. SearchFor will match:
1. Serial number (exact match only)
2. Thumbprint (exact match only)
3. Subject name (substring match)
4. Subject Alternative Name (substring match)

By default searching will be done in CurrentUser\My certificate store. Use GlobalSearch to search in all stores and all store locations.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-ZPkiLocalCert -SearchFor myserver.com -StoreLocation LocalMachine
```

Search for certs in LocalMachine\My store for certs matching 'myserver.com'

### Example 2
```powershell
PS C:\> Find-ZPkiLocalCert -SearchFor myserver.com -GlobalSearch
```

Search for certs in all local stores in both CurrentUser and LocalMachine for certs matching 'myserver.com'

## PARAMETERS

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

### -GlobalSearch
Search in all stores and locations

```yaml
Type: SwitchParameter
Parameter Sets: GlobalSearch
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchFor
Search string

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Store
Certificate store location

```yaml
Type: StoreLocation
Parameter Sets: SpecificSearch
Aliases:
Accepted values: CurrentUser, LocalMachine

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StoreName
Certificate store name

```yaml
Type: StoreName
Parameter Sets: SpecificSearch
Aliases:
Accepted values: AddressBook, AuthRoot, CertificateAuthority, Disallowed, My, Root, TrustedPeople, TrustedPublisher

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

### xyz.zwks.pkilib.cert.ICertificate

## NOTES

## RELATED LINKS
