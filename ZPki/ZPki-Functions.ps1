
Function Get-HttpUri {
    Param(
        $HostFQDN
        ,$Path
        ,$Document
    )
    If($Path -ne $null) {
        $Path = $Path.Trim('/')
    } Else {
        $Path = ""
    }
    If($Path.Length -gt 0) {
        $Path = "/$Path/"
    } Else {
        $Path = "/"
    }
    Write-Output "http://$($HostFQDN)$($Path)$($Document)"
}

Function Get-LdapUri {
    Param( 
        [switch]
        $IsAIA
    )

    If($IsAIA) {
        Write-Output "ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11"
    } Else {
        Write-Output "ldap:///CN=%7%8,CN=%7,CN=CDP,CN=Public Key Services,CN=Services,%6%10"
    }
}

Function Get-FileUri {
    Param(
        $Path,

        [switch]
        $IsAIA
    )

    If($IsAIA) {
        Write-Output "file:///$Path\%3%4.crt"
    } Else {
        Write-Output "file:///$Path\%7%8%9.crl"
    }
}

Function New-ADCSPath {
    [CmdletBinding()]
    Param(
        [string]
        $PathName,
        [string]
        $Path
    )

    If(-Not (Test-Path $Path -PathType Any)) {
        Write-Verbose "Creating ADCS Directory [$PathName]"
        New-Item $Path -ItemType Directory | Out-Null
    } Elseif(Test-Path $Path -PathType Leaf) {
        Write-Error "ADCS Directory exists, but is a file. Cannot continue. [$PathName]: [$Path]"
    }
}

Function Get-CaPolicyFileTemplate {
    Param(
        [Parameter(Mandatory=$True)]
        $CAType
    )
    If($CAType -like "*root*") {
        Get-Content .\CAPolicy-root.inf
    } Else {
        Get-Content .\CAPolicy-sub.inf
    }
}

Function Get-CaPolicyHeaderSection {
    Write-Output "[Version]`r`nSignature=`"`$Windows NT`$`" `r`n"
}

Function Get-CaPolicyCertSrvSection {
    Param(
        $Keylength,
        $CACertValidityPeriod,
        $CACertValidityPeriodUnits,
        $CRLPeriod,
        $CRLPeriodUnits,
        $DeltaPeriod,
        $DeltaPeriodUnits,
        $LoadDefaultTemplates,
        $AltSignatureAlgorithm,
        $ForceUTF8,
        $ClockSkewMinutes,
        $EnableKeyCounting
    )

    $ldt = [int] $LoadDefaultTemplates
    $asa = [int] $AltSignatureAlgorithm
    $futf = [int] $ForceUTF8
    $ekc = [int] $EnableKeyCounting

    Write-Output (("[Certsrv_Server]", 
        "RenewalKeyLength = $Keylength",
        "RenewalValidityPeriod = $CACertValidityPeriod",
        "RenewalValidityPeriodUnits = $CACertValidityPeriodUnits", 
        "CRLPeriod = $CRLPeriod",
        "CRLPeriodUnits = $CRLPeriodUnits",
        "CRLDeltaPeriod = $DeltaPeriod",
        "CRLDeltaPeriodUnits =  $DeltaPeriodUnits",
        "LoadDefaultTemplates = $ldt",
        "AlternateSignatureAlgorithm = $asa",
        "ForceUTF8 = $futf".
        "ClockSkewMinutes = $ClockSkewMinutes",
        "EnableKeyCounting = $ekc") -join "`r`n")
}

Function Get-CaPolicyPolicySection {
    Param(
        $PolicyName,
        $PolicyOid,
        $PolicyNotice,
        $PolicyUrl
    )

    If([string]::IsNullOrWhiteSpace($PolicyName)) {
        Write-Error "Get-CaPolicyPolicySection(): Policy name cannot be empty."
    }
    If([string]::IsNullOrWhiteSpace($PolicyOid)) {
        Write-Error "Get-CaPolicyPolicySection(): Policy OID cannot be empty. Policy name: [$PolicyName]"
    }
    If([string]::IsNullOrWhiteSpace($PolicyName) -And [string]::IsNullOrWhiteSpace($PolicyNotice) -and [string]::IsNullOrWhiteSpace($PolicyUrl)) {
        Write-Error "Get-CaPolicyPolicySection(): Policy Notice and Url cannot both be empty. Policy name: [$PolicyName]"
    }

    $Section = "" 
    $Section = "[$PolicyName]`r`nOID=$PolicyOid`r`n"
    If(-Not [string]::IsNullOrWhiteSpace($PolicyNotice)) {
        $Section = "$($Section)Notice=$PolicyNotice`r`n"
    }
    If(-Not [string]::IsNullOrWhiteSpace($PolicyUrl)) {
        $Section = "$($Section)URL=$PolicyUrl`r`n"
    }

    Write-Output $Section
}

Function Get-CaPolicyPolicyExtensionsSection {
    Param(
        [string]
        $Sections
    )

    If(-Not [string]::IsNullOrWhiteSpace($Sections)) {
        Write-Output "[PolicyStatementExtension] `r`n Policies=$Sections`r`n"
    }
}

Function Get-CaPolicyBasicConstraintsSection {
    Param(
        [string]
        $PathLength,
        [bool]
        $Critical
    )
    
    $Crit = If($Critical) { "Yes" } Else { "No" }
    $Pl = ""
    If($PathLength -ne "None") {
        $Pl = "PathLength = $PathLength"
    }
    
    Write-Output (("[BasicConstraintsExtension]",
    $Pl,
    "Critical = $Crit`r`n") -join "`r`n")
}

Function Get-CaPolicyEkuSection {
    Param(
        [string[]]
        $Oids,

        [switch]
        $Critical
    )
    
    $Crit = If($Critical) { "Yes" } Else { "No" }
    Write-Output (( & { 
        Write-Output "[EnhancedKeyUsageExtension]"
        Write-Output "Critical = $Crit"

        Foreach($e in $Oids) {
            Write-Output "OID = $e"
        }

        Write-Output "`r`n"
    }) -join "`r`n")
}

Function Create-Dir {
    Param(
        [string]
        $Path,
        [string]
        $Name
    )

    $FullPath = "$Path\$Name"

    Write-Verbose "Creating $FullPath"

    If(Test-Path $FullPath -PathType Leaf) {
	    Write-Error "Target directory [$FullPath] already exists, but is a file. Please remove the file or use a different path."
    }

    If(-Not (Test-Path $FullPath)) {
	    mkdir $FullPath | Out-Null
    }

    If(-Not (Test-Path $FullPath)) {
	    Write-Error "Failed to create target directory [$FullPath]."
    }
}

Function Test-IsAdmin {
    [CmdletBinding()]
    Param()
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    Write-Output $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}