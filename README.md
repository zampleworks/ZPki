# ZPki
A collection of utilities for managing PKI and certificates. 
Currently included is a powershell module and work is ongoing 
on a GUI client for windows to make cert management less painful. 

## Project structure

### Zamples - AdcsDeployment
Scripts for installation and configuration of ADCS. These scripts are intended as guides for how to deploy ADCS using this module. Grab them and modify per your own needs.

### ZPki
PS backend module. Mixed binary and script module. Includes functionality for  
querying and managing ADCS and AD. AD support is focused toward ADCS as of yet.

## Environment
Tested and works on Windows Server 2012R2+ and Windows 10.

For Windows 10 1803 and earlier, you must install RSAT manually
to use all features, and enable the ADCS management tools. 
You will get a COM error from any cmdlet that calls the CA directly
if it is missing. You can use Install-ZPkiRsatComponents to install 
the necessary components easily!
