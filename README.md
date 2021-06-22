# ZPki
A collection of utilities for managing PKI and certificates.  
Currently included is a powershell module and work is ongoing  
on a GUI client for windows to make cert management less painful. 

Tested and works on Windows Server 2012R2+ and Windows 10.

For Windows 10 1803 and earlier, you must install RSAT manually
to use all features, and enable the ADCS management tools. 
You will get a COM error from any cmdlet that calls the CA directly
if it is missing.