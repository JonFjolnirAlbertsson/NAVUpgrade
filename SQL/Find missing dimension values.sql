
select * from [NAV2009R2_PP_ToUpgrade].[dbo].[PPFINANS$Ledger Entry Dimension] A
where A.[Dimension Value Code] not in (select B.Code from [NAV2009R2_PP_ToUpgrade].[dbo].[PPFINANS$Dimension Value] B)

 select * from [NAV2009R2_PP_ToUpgrade].[dbo].[Bydelenes Personellservice BA$Ledger Entry Dimension] A
 where A.[Dimension Value Code] not in (select B.Code from [NAV2009R2_PP_ToUpgrade].[dbo].[Bydelenes Personellservice BA$Dimension Value] B)

 select * from [NAV2009R2_PP_ToUpgrade].[dbo].[A_L Rådhusets Personellservice$Ledger Entry Dimension] A
 where A.[Dimension Value Code] not in (select B.Code from [NAV2009R2_PP_ToUpgrade].[dbo].[A_L Rådhusets Personellservice$Dimension Value] B)

 select * from [NAV2009R2_PP_ToUpgrade].[dbo].[Komm_ansattes Pers_service BA$Ledger Entry Dimension] A
 where A.[Dimension Value Code] not in (select B.Code from [NAV2009R2_PP_ToUpgrade].[dbo].[Komm_ansattes Pers_service BA$Dimension Value] B)

 select * from [NAV2009R2_PP_ToUpgrade].[dbo].[ENIBA$Ledger Entry Dimension] A
 where A.[Dimension Value Code] not in (select B.Code from [NAV2009R2_PP_ToUpgrade].[dbo].[ENIBA$Dimension Value] B)

 select * from [NAV2009R2_PP_ToUpgrade].[dbo].[KTPS$Ledger Entry Dimension] A
 where A.[Dimension Value Code] not in (select B.Code from [NAV2009R2_PP_ToUpgrade].[dbo].[KTPS$Dimension Value] B)