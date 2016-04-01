﻿$Location = "C:\GitHub\NAVUpgrade\Customer\SI-Data\NAV2013R2"
. (join-path $Location 'Set-UpgradeSettings.ps1')

#enable/disable required functions:
$SplitFiles                   = $false  #This may take a while (depending on the amount of objects)
$CreateDeltas                 = $true
$MergeVersions                = $true
$updateVersionList            = $true 
$updateDateTime               = $true
$CreateFilteredResultFolder   = $true
$DisplayObjectFilters         = $true
$OpenKdiffMergeWhenConflicts = $true
$ImportObjects                = $false
$DeleteObjects                = $false
$CompileObjects               = $false

cd $WorkingFolder
Clear-Host
Write-host "All set.  Starting Script Execution..." -ForegroundColor Green

#Reset Workingfolder
if (test-path $WorkingFolder){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolder ?"){
        Remove-Item -Path $WorkingFolder -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}


If ($SplitFiles) {
    Write-Host "Splitting files" -ForegroundColor Green
    if (-not (Test-Path $OriginalFolder)) {
        Write-Host "Splitting $OriginalFile to folder $OriginalFolder.  Sit back and relax, because this can take a while..." -ForegroundColor White
        New-Item -Path $OriginalFolder -ItemType directory | Out-null
        Split-NAVApplicationObjectFile -Source $OriginalFile -Destination $OriginalFolder
    } 

    if (-not (Test-Path $ModifiedFolder)) {
        Write-Host "Splitting $ModifiedFile to folder $ModifiedFolder.  Sit back and relax, because this can take a while..." -ForegroundColor White
        New-Item -Path $ModifiedFolder -ItemType directory | Out-null
        Split-NAVApplicationObjectFile -Source $ModifiedFile -Destination $ModifiedFolder
    } 

    if (-not (Test-Path $TargetFolder)) {
        Write-Host "Splitting $TargetFile to folder $TargetFolder.  Sit back and relax, because this can take a while..." -ForegroundColor White
        New-Item -Path $TargetFolder -ItemType directory | Out-null
        Split-NAVApplicationObjectFile -Source $TargetFile -Destination $TargetFolder
    }
    
}

if($CreateDeltas){
    Write-host "Creating Delta's..." -ForegroundColor Green
    Write-Host "Creating delta between Original and Modified ..." -ForegroundColor White
    if(Test-Path $DeltaFolderOriginalModified) {remove-Item $DeltaFolderOriginalModified -Recurse -force | Out-null}
    New-Item -Path $DeltaFolderOriginalModified -ItemType directory
    Compare-NAVApplicationObject -Original $OriginalFile -Modified $ModifiedFile -Delta $DeltaFolderOriginalModified

    Write-Host "Creating delta between Original and Target ..." -ForegroundColor White
    if(Test-Path $DeltaFolderOriginalTarget) {remove-Item $DeltaFolderOriginalTarget -Recurse -force | Out-null}
    New-Item -Path $DeltaFolderOriginalTarget -ItemType directory
    Compare-NAVApplicationObject -Original $OriginalFile -Modified $TargetFile -Delta $DeltaFolderOriginalTarget
  
    #Write-Host "Creating delta between Modified and Target ..." -ForegroundColor White
    #if(Test-Path $DeltaFolderModifiedTarget) {remove-Item $DeltaFolderModifiedTarget -Recurse -force | Out-null}
    #New-Item -Path $DeltaFolderModifiedTarget -ItemType directory
    #Compare-NAVApplicationObject -Original $ModifiedFile -Modified $TargetFile -Delta $DeltaFolderModifiedTarget
}

if($MergeVersions){
    Write-Host "Merging to $MergeResultFolder ..." -ForegroundColor Green

    if(Test-Path $MergeResultFolder) {remove-Item $MergeResultFolder -Recurse -force}
    New-Item -Path $MergeResultFolder -ItemType directory | Out-null
    
    $MergeResult = Merge-NAVApplicationObject `
    if(Test-Path $MergeInfoFolder) {Remove-Item -Path $MergeInfoFolder -Recurse -Force} 
            Where-Object {$_.MergeResult –eq 'Merged' -or $_.MergeResult –eq 'Conflict'}  | 
                foreach { 
                    #try
                    #{
                        Write-Host $_.Result
                        Set-NAVApplicationObjectProperty -Target $_.Result -VersionListProperty (Merge-NAVVersionList -OriginalVersionList $_.Original.VersionList `
                                                                                                                                -ModifiedVersionList $_.Modified.VersionList `
                                                                                                                                -TargetVersionList $_.Target.VersionList `
                                                                                                                      -OriginalTime $_.Original.Time `
                                                                                                                      -ModifiedDate $_.Modified.Date `
                                                                                                                      -ModifiedTime $_.Modified.Time `
                                                                                                                      -TargetDate $_.Target.Date `
                Where-Object {$_.MergeResult –eq 'Merged' -or $_.MergeResult –eq 'Conflict'}  |
                    foreach { Set-NAVApplicationObjectProperty -Target $_.Result -VersionListProperty (Merge-NAVVersionList -OriginalVersionList $_.Original.VersionList `
                                                                                                                                    -ModifiedVersionList $_.Modified.VersionList `
                                                                                                                                    -TargetVersionList $_.Target.VersionList `
                Where-Object {$_.MergeResult –eq 'Merged' -or $_.MergeResult –eq 'Conflict'}  |
                    foreach { 
                        Set-NAVApplicationObjectProperty -Target $_.Result -DateTimeProperty (Merge-NAVDateTime -OriginalDate $_.Original.Date `
                                                                                                                      -OriginalTime $_.Original.Time `
                                                                                                                      -ModifiedDate $_.Modified.Date `
                                                                                                                      -ModifiedTime $_.Modified.Time `
                                                                                                                      -TargetDate $_.Target.Date `
        Where-Object {$_.MergeResult –ine 'Unchanged'}  |
             foreach {  
                try
                {                
                    Copy-Item  $_.Result -Destination $FilteredMergeResultFolder -ErrorAction SilentlyContinue    
                }
                catch
                {
                }
            }
    if($AllObjects){
        for ($i = 1; $i -lt 8; $i++)
        {
            switch ($i)
            {
                1 { Get-NAVObjectFilter -ObjectType "Table" -ObjectCollection $AllObjects }
                2 { Get-NAVObjectFilter -ObjectType "Page" -ObjectCollection $AllObjects }
                3 { Get-NAVObjectFilter -ObjectType "Report" -ObjectCollection $AllObjects }
                4 { Get-NAVObjectFilter -ObjectType "Codeunit" -ObjectCollection $AllObjects }
                5 { Get-NAVObjectFilter -ObjectType "Query" -ObjectCollection $AllObjects }
                6 { Get-NAVObjectFilter -ObjectType "XMLPort" -ObjectCollection $AllObjects }
                7 { Get-NAVObjectFilter -ObjectType "MenuSuite" -ObjectCollection $AllObjects }
            }
        }

    Import-NAVApplicationObjectFilesFromFolder -SourceFolder $FilteredMergeResultFolder -LogFolder "$FilteredMergeResultFolder\Log" -Server $Server -Database $Database 
        Where-Object {$_.MergeResult –eq 'Deleted'}  |
             foreach { 
                [String]$ObjectType = $_.ObjectType
                [String]$ObjectId = $_.Id

                Delete-NAVApplicationObject `
                    -DatabaseName $Database `
                    -DatabaseServer $Server `
                    -LogPath $UpgradeLogsDirectory `
                    -Filter "Type=$ObjectType;Id=$ObjectId" `
                    -SynchronizeSchemaChanges "Force" `
                    -NavServerName $NAVServerName `
                    -NavServerInstance $NAVServerInstance `
                    -NavServerManagementPort $NAVServerManagementPort `
                    -Confirm:$false                       
            }

    ParallelCompile-NAVApplicationObject -ServerName $Server -DatabaseName $Database    