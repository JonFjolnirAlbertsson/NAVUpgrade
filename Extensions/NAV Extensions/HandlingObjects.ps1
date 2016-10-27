#Joining and importing version 1 modified objects
Join-NAVApplicationObjectFile -Source C:\NAVUpgrade\Extension\_Workingfolder\FOB\MODIFIED-V1 -Destination C:\NAVUpgrade\Extension\_Workingfolder\FOB\ModifiedV1.txt
Import-NAVApplicationObject -DatabaseName $ModifiedServerInstanceV1 -NavServerInstance $ModifiedServerInstanceV1 -Path C:\NAVUpgrade\Extension\_Workingfolder\FOB\ModifiedV1.txt -SynchronizeSchemaChanges Yes 
Compile-NAVApplicationObject2 -ServerInstance $ModifiedServerInstanceV1 -Filter "Modified = Ja" -LogPath C:\NAVUpgrade\Extension\_Workingfolder\FOB -Recompile -SynchronizeSchemaChanges Yes

#Joining and importing version 2 modified objects
Join-NAVApplicationObjectFile -Source C:\NAVUpgrade\Extension\_Workingfolder\FOB\MODIFIED-V2 -Destination C:\NAVUpgrade\Extension\_Workingfolder\FOB\ModifiedV2.txt
Import-NAVApplicationObject -DatabaseName $ModifiedServerInstanceV2 -NavServerInstance $ModifiedServerInstanceV2 -Path C:\NAVUpgrade\Extension\_Workingfolder\FOB\ModifiedV2.txt -SynchronizeSchemaChanges Yes 
Compile-NAVApplicationObject2 -ServerInstance $ModifiedServerInstanceV2 -Filter "Modified = Ja" -LogPath C:\NAVUpgrade\Extension\_Workingfolder\FOB -Recompile -SynchronizeSchemaChanges Yes