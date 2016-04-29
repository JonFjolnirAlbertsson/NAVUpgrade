--Select top 1000 *
--FROM [Elas AS$G_L Entry] d2
--left join [NAV80CU17ElasPerfTest].[dbo].[Elas AS$G_L Entry] d1 on ((d2.[Entry No_] = d1.[Entry No_]) and ((d2.[G_L Account No_] not like d1.[G_L Account No_])))
--Select top 10 *
--FROM [Elas AS$G_L Entry] d2
--WHERE NOT EXISTS (SELECT 1 
--                  FROM [NAV80CU17ElasPerfTest].[dbo].[Elas AS$G_L Entry] d1
--                  WHERE d2.[Entry No_] = d1.[Entry No_])

Select top 10 *
FROM [Elas AS$G_L Entry] d2
WHERE EXISTS (SELECT 1 
                  FROM [NAV80CU17ElasPerfTest].[dbo].[Elas AS$G_L Entry] d1
                  WHERE (d2.[Entry No_] = d1.[Entry No_])
						and ((not(d2.[G_L Account No_] = d1.[G_L Account No_]))
						or (not(d2.[Bal_ Account No_] = d1.[Bal_ Account No_]))))

--SELECT * FROM [NAV80CU17ElasPerfTest].[dbo].[Elas AS$G_L Entry]