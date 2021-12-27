---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Get-ZPkiServiceBindings

## SYNOPSIS
List network ports/pipe addresses for well known services. Can query RPC Endpoint mapper for runtime ports for services that dynamically allocates ports for RPC/DCOM access. Currently only Active Directory is defined.

## SYNTAX

### default (Default)
```
Get-ZPkiServiceBindings -ServiceName <String> [-NoTcpPorts] [-IncludeUdpPorts] [-Timeout <UInt32>]
 [-ExtraVerbose] [<CommonParameters>]
```

### QueryRpc
```
Get-ZPkiServiceBindings -ServiceName <String> [-NoTcpPorts] [-IncludeUdpPorts] [-IncludeRpcPorts]
 -QueryRpcServer <String> [-Timeout <UInt32>] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
The intention of this cmdlet is to generate input to the Test-ZPkiServiceBinding cmdlet to test network connectivity to given services.
UDP ports are excluded since there is no simple way to test UPD ports without knowing the specific application listening.
RPC ports are excluded by default since it requires a round-trip to the server in question.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiServiceBindings -Service ActiveDirectory
```

Get a list of all TCP static port services used by Active Directory. UDP and RPC ports are not included.

### Example
```powershell
PS C:\> Get-ZPkiServiceBindings -Service ActiveDirectory -IncludeRpcPorts -QueryRpcServer server1
```

Get a list of all TCP static port services used by Active Directory. UDP ports are not included.
Also queries the RPC Endpoint Mapper on the server and retrieves dynamic ports allocated to AD services.

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

### -IncludeRpcPorts
Query Endpoint mapper for ports used by RPC-based AD services

```yaml
Type: SwitchParameter
Parameter Sets: QueryRpc
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeUdpPorts
Include UDP ports

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

### -NoTcpPorts
Do not include TCP ports

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

### -QueryRpcServer
Domain Controller to query for RPC ports

```yaml
Type: String
Parameter Sets: QueryRpc
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceName
Return port set for given service

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: ActiveDirectory

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout
Maximum time to wait for connection (milliseconds)

```yaml
Type: UInt32
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

### xyz.zwks.pkilib.connectivity.Binding

## NOTES

## RELATED LINKS
