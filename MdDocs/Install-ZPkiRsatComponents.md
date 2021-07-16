---
external help file: PsZPki-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# Install-ZPkiRsatComponents

## SYNOPSIS
Installs RSAT ADCS management tools. Required for cmdlets that  
call the CA COM interface directly, such as the *-ZPkiDb* cmdlets.

## SYNTAX

```
Install-ZPkiRsatComponents [-IncludeAdTools] [<CommonParameters>]
```

## DESCRIPTION
Some cmdlets in this module require extra COM modules installed to 
interface with ADCS. These components are available in Microsoft's 
Remote Server Administration Tools. 
For convenience, a switch is included to add ADDS admin tools as well.

On Windows clients, this cmdlet requires Windows 10 1809. On earlier 
versions of Windows you have to download and install the RSAT packate
from Microsoft manually.

Author anders !Ä!T! runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> Install-ZPkiRsatComponents
```

Installs RSAT ADCS management tools

## PARAMETERS

### -IncludeAdTools
Also install RSAT ActiveDirectory module

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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
