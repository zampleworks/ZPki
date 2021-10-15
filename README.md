# ZPki
A collection of utilities for managing PKI and certificates. 
Currently included is a powershell module and work is ongoing 
on a GUI client for windows to make cert management less painful. 

The project also contains sample scripts for ADCS deployment and 
configuration.

## Project structure

### Zamples - AdcsDeployment
Scripts for installation and configuration of ADCS. These scripts are intended as guides for how to deploy ADCS using the PS module. Grab them and modify per your own needs.

### ZPki
PS backend module. Mixed binary and script module. Includes functionality for  
querying and managing ADCS and AD, and ADCS deployment. AD support is focused 
toward ADCS as of yet but has some nifty cmdlets for AD querying.

#### Installing PS module
Preferably, install the ZPki module from PSGallery instead of downloading it from Github:

```
PS:> Register-PSRepository -Default
PS:> Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
PS:> Install-Module -Name ZPki
```

To run Install-Module on Windows Server 2012R2 and older, you need to 
install .NET 4.5.2 and Windows Management Framework version 5.1 or newer: 
https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-7.1

When installing from PSGallery you only get the PS module. Sample scripts
and non-PS tools are not included and need to be downloaded from Github.

If you need to install the PS module in an offline environment, download the
latest release and run the supplied install script.

## Environment
Tested and works on Windows Server 2012R2+ and Windows 10.

For Windows 10 1803 and earlier, you must install RSAT manually
to use all features, and enable the ADCS management tools. 
You will get a COM error from any cmdlet that calls the CA directly
if it is missing. 
On newer OSes you can use Install-ZPkiRsatComponents to install 
the necessary components easily.
