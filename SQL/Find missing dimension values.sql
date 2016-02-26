select * from

  [NAV2016_BuschUpgrade].[dbo].[Busch Vakuumteknikk AS$Ledger Entry Dimension] A

 where A.[Dimension Value Code] not in 

 (

 select B.Code

 from

 [NAV2016_BuschUpgrade].[dbo].[Busch Vakuumteknikk AS$Dimension Value] B

 )
