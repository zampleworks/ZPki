<#
  .SYNOPSIS
  This script will install the ZPki module. By default it installs into the current users's 
  profile. Use the -Systemwide switch to install for all users.
#>
[CmdletBinding(SupportsShouldProcess,
        ConfirmImpact = 'High')]
Param(
    [switch]
    $SystemWide
)

$Module = "ZPki"

$ErrorActionPreference = "Stop"

$UserModulesDir = "{0}\Documents\WindowsPowerShell\Modules" -f $env:USERPROFILE
$SystemModulesDir = "{0}\WindowsPowerShell\Modules" -f $env:ProgramFiles 

If($SystemWide) {
    
    $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList ([Security.Principal.WindowsIdentity]::GetCurrent())
    If(-Not $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "Installing system-wide requires admin privileges! Run the script again as admin to install system wide."
    }
    $ModulesDir = $SystemModulesDir
} Else {
    $ModulesDir = $UserModulesDir
}

If((Test-Path "$SystemModulesDir\ZPki") -and (Test-Path "$UserModulesDir\ZPki")) {
    Write-Warning "The ZPki module is installed both system-wide and in the current user's profile. Both should be upgraded to avoid confusion."
    Write-Warning "System wide install path: $SystemModulesDir\ZPki"
    Write-Warning "Current user install path: $UserModulesDir\ZPki"
}

$ZModuleDir = "$ModulesDir\$Module"

If(Test-Path $ZModuleDir) {
    If(-Not $PSCmdlet.ShouldProcess("ZPki", "Remove previous installation")) {
        Write-Verbose "You chose not to proceed. exiting installation"
        return
    }
}

Try {
    If(Test-Path $ZModuleDir) {
        rm $ZModuleDir -Recurse -Force
    }

    If(-Not (Test-Path $ModulesDir -PathType Container)) {
        mkdir $ModulesDir | Out-Null
    }

    cp .\ZPki $ModulesDir -Recurse | Out-Null
    
    If($SystemWide) {
        Write-Verbose "Done installing $Module module system wide!"
    } Else {
        Write-Verbose "Done installing $Module module to current user's profile!"
    }
} Catch {
    Write-Host $_.Exception.Message -ForegroundColor red
    $_.Exception
    Read-Host "press play on tape"
}