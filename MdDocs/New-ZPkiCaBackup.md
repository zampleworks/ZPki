---
external help file: PsZPki.psm1-help.xml
Module Name: ZPki
online version:
schema: 2.0.0
---

# New-ZPkiCaBackup

## SYNOPSIS
Backs up ADCS to given directory.
Private key is not included by default, use -BackupKey to include it.
Backups up CA database and configuration:
    1.
Registry values
    2.
Published templates
    3.
Installed local certificates

## SYNTAX

```
New-ZPkiCaBackup [[-BackupsDirectoryName] <String>] [[-BackupsParentDirectory] <String>]
 [[-BackupPwd] <String>] [[-RetentionCount] <Int32>] [-SkipBackupKey] [<CommonParameters>]
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

### -BackupPwd
Password for p12 file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupsDirectoryName
Directory for backups within root directory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: Backups
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupsParentDirectory
Parent directory for backups

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: C:\ADCS
Accept pipeline input: False
Accept wildcard characters: False
```

### -RetentionCount
Not currently implemented

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipBackupKey
{{ Fill SkipBackupKey Description }}

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
