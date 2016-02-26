SELECT        TOP (200) [Service Order No_],[Transfer Order No_],[Prod_ Order No_],[Entry No_], [Item No_], [Posting Date], [Entry Type], [Source No_], [Document No_], Description
FROM            [OSO Hotwater AS$Item Ledger Entry]
WHERE        (NOT ([Service Order No_]  = '')) AND (NOT ([Transfer Order No_] = '')) AND (NOT ([Prod_ Order No_]  = ''))