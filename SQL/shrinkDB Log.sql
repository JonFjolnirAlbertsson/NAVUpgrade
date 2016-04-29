backup database[NAV2009SP1_OSO_Upgrade] to disk='nul'

backup log [NAV2009SP1_OSO_Upgrade] to disk='nul'
dbcc shrinkfile([NAV2009SP1_OSO_Upgrade_Log], 500)

backup log [NAV2009SP1_OSO_Upgrade] to disk='nul'
dbcc shrinkfile([NAV2009SP1_OSO_Upgrade_Log], 500)
