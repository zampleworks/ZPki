---
external help file: PsZPki.psm1-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# New-ZPkiRandomPassword

## SYNOPSIS
Generate random password containing alphanumeric characters and the following set: !@#$%^&*()_-+=\[{\]};:\<\>|./?

## SYNTAX

```
New-ZPkiRandomPassword [[-Length] <Int32>] [[-NumberOfNonAlphaNumChars] <Int32>] [-ConvertToSecureString]
 [<CommonParameters>]
```

## DESCRIPTION
Author anders !Ä!T!
runesson D"Ö"T info

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ConvertToSecureString
{{ Fill ConvertToSecureString Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Length
{{ Fill Length Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: 128
Accept pipeline input: False
Accept wildcard characters: False
```

### -NumberOfNonAlphaNumChars
{{ Fill NumberOfNonAlphaNumChars Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 5
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
