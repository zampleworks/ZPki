# Changelog

## [v0.3.4] 2025-05-05
- Fixed goofed signatures in script files. 
- Bugfix for duplicate validated write/extended right RightsGuids
- ResolveSecurityIdentifiers now work for Get-AdXXX cmdlets
- Added AdForest, AdRootDse, and AdComputer .net object types
- Added AdComputer object type and cmdlets
- Changed schema cache to use usn instead of only timer
- Fixed missing GpoCreate in ACL analysis
- ObjectSid can no be used in Get-AdXXX cmdlets (nice when searching for well known objects like RID500 etc)

## [v0.3.3] 2025-04-28
- Bugfixes for WriteOutput in pipeline. Pipelining should be less error prone, and work with -ExtraVerbose
- Added Find-ZPkiAdGroup with recursion support
- Added support for searching with ObjectSid in Find-ZPkiAdUser and Find-ZPkiAdGroup
- Updates to Get-AdDomain

## [v0.3.2] 2025-04-25
- Bugfix: More missing exchange attribute bugs
- Connections cross forests work now with both ADWS and RPC
- RPC is much faster and should not stall 
- Added switches to set certificate trust validation and revocation checking for ADWS.

## [v0.3.1] 2025-04-25
- Improved handling of ACEs with multiple ActiveDirectoryRights values
- Bugfix: Fixed broken ADWS querying in domains without Exchange schema extensions

## [v0.3.0] 2025-04-25
- Fixed throwing bug when finding inaccessible objects in AD search
- Added Test-ZPkiAdObjectAclSecurity cmdlet

## [v0.2.1] 2025-04-23
- Updates to Get-ZPkiAdDomain
- Added ValueFromPipelineByPropertyName to Find-ZPkiAdControlAccessRight, Find-ZPkiAdAttributeSchema, and Find-ZPkiAdClassSchema
- Added SearchFlags enum and support in AdAttributeSchema
- Added SystemOnly in AdAttributeSchema
- Changed enum value names in SystemFlags to be clearer
- Changed AdAttributeSchema/AdClassSchema/ControlAccessRight to not throw exception when no schemaidguid/rightsguid is included from the query. This means that the user may get the objects without the identifier, but the module no longer throws exceptions if using Find-ZPkiAdObject to find schema/controlAccessRights objects and forgetting to include the ID properties manually.
