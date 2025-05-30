﻿---
external help file: PsZPki.psm1-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Set-ZPkiAdIssuancePolicyGroupLink

## SYNOPSIS
Link an AMA group to Issuance Policy

## SYNTAX

```
Set-ZPkiAdIssuancePolicyGroupLink [-IssuancePolicyName] <String> [-GroupName] <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Link an AMA group to Issuance Policy

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-ZPkiAdIssuancePolicyGroupLink -IssuancePolicyName "High Security" -GroupName "System Admins"
```

## PARAMETERS

### -GroupName
Group name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IssuancePolicyName
Issuance Policy name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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

### System.Object
## NOTES

## RELATED LINKS
