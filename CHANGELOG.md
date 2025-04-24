# Changelog

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
