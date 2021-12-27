---
external help file: PkiCertClient.dll-Help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Test-ZPkiServiceBinding

## SYNOPSIS
Test connectivity to a service bound to a TCP port.

## SYNTAX

### MultipleBindings (Default)
```
Test-ZPkiServiceBinding -Bindings <Binding[]> [-Computer <String>] [-ExtraVerbose] [<CommonParameters>]
```

### SingleBinding
```
Test-ZPkiServiceBinding -Binding <Binding> [-Computer <String>] [-ExtraVerbose] [<CommonParameters>]
```

## DESCRIPTION
Use to test connectivity to services bound to TCP ports. Use this by specifying bindings manually, or by using the output from Get-ZPkiServiceBinding cmdlet.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ZPkiServiceBindings -Service ActiveDirectory -IncludeRpcPorts -QueryRpcServer server1 | Test-ZPkiServiceBinding -Computer server1
```

Get a list of static and dynamic port bindings for AD running on server1 and test if a simple TCP connection can be established.
(The comma and parenthesis are included to force powershell to send the bindings to the pipeline as an array, instead of unrolling and piping each binding individually. This allows Test-ZPkiServiceBinding to parallelize the connection attempts)

## PARAMETERS

### -Binding
Test single binding

```yaml
Type: Binding
Parameter Sets: SingleBinding
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Bindings
Test multiple bindings

```yaml
Type: Binding[]
Parameter Sets: MultipleBindings
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Computer
Computer to try connecting to.
Required if Bindings do not have a hostname set.
Overrides value from Binding.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### xyz.zwks.pkilib.connectivity.Binding

### xyz.zwks.pkilib.connectivity.Binding[]

## OUTPUTS

### xyz.zwks.pkilib.connectivity.ConnectTestResult

## NOTES

## RELATED LINKS
