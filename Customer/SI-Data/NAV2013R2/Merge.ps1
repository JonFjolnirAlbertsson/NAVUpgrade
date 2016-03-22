$Location = "C:\GitHub\NAVUpgrade\Customer\SI-Data\NAV2013R2"
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
    
    $MergeResult = Merge-NAVApplicationObject `                    -Original $OriginalFile `                    -Modified $ModifiedFile `                    -Target $TargetFile `                    -Result $MergeResultFolder `                    -DocumentationConflict ModifiedFirst `                    -VersionListProperty FromModified        
    if(Test-Path $MergeInfoFolder) {Remove-Item -Path $MergeInfoFolder -Recurse -Force}     New-Item -Path $MergeInfoFolder -ItemType directory    $MergeResult | Export-Clixml -Path "$MergeInfoFolder\MergeResult.xml"    Write-host "Saved MergeInfo-objectcollection to $MergeInfoFolder\MergeResult.xml for later reference"    $MergeResult.Summary }if($updateVersionList -or $updateDateTime)  {    if (-not (Test-Path $MergeResultFolder)) {write-error "$MergeResultFolder not found! Updating Version List impossible"}    if (!$MergeResult) {$MergeResult = Import-Clixml -Path "$MergeInfoFolder\MergeResult.xml"}        Import-Module "$ScriptDirectory\Merge-NAVVersionList.ps1"  | Out-null    Import-Module "$ScriptDirectory\Merge-NAVDateTime.ps1"  | Out-null        Import-Module "$ScriptDirectory\Merge-NAVModified.ps1"  | Out-null    if ($updateVersionList -and $updateDateTime)    {        write-host "Updating VersionList and DateTime..." -ForegroundColor Green                                                                                                                                      $MergeResult |
            Where-Object {$_.MergeResult –eq 'Merged' -or $_.MergeResult –eq 'Conflict'}  | 
                foreach { 
                    #try
                    #{
                        Write-Host $_.Result
                        Set-NAVApplicationObjectProperty -Target $_.Result -VersionListProperty (Merge-NAVVersionList -OriginalVersionList $_.Original.VersionList `
                                                                                                                                -ModifiedVersionList $_.Modified.VersionList `
                                                                                                                                -TargetVersionList $_.Target.VersionList `                                                                                                                                -Versionprefix $VersionListPrefixes) `                                                                             -DateTimeProperty (Merge-NAVDateTime -OriginalDate $_.Original.Date `
                                                                                                                      -OriginalTime $_.Original.Time `
                                                                                                                      -ModifiedDate $_.Modified.Date `
                                                                                                                      -ModifiedTime $_.Modified.Time `
                                                                                                                      -TargetDate $_.Target.Date `                                                                                                                      -TargetTime $_.Target.Time) `                                                                             -ModifiedProperty (Merge-NAVModified -Original $_.Original.Modified `                                                                                                                      -Modified $_.Modified.Modified `                                                                                                                      -Target $_.Target.Modified)                     #}                    #catch                    #{                    #    write-host "Error $_.ObjectType $_.Id: $_.Exception.Message"  -ForegroundColor Red                            #}                }    }    else {        if ($updateVersionList)        {            write-host "Updating VersionList..." -ForegroundColor Green                $MergeResult |
                Where-Object {$_.MergeResult –eq 'Merged' -or $_.MergeResult –eq 'Conflict'}  |
                    foreach { Set-NAVApplicationObjectProperty -Target $_.Result -VersionListProperty (Merge-NAVVersionList -OriginalVersionList $_.Original.VersionList `
                                                                                                                                    -ModifiedVersionList $_.Modified.VersionList `
                                                                                                                                    -TargetVersionList $_.Target.VersionList `                                                                                                                                    -Versionprefix $VersionListPrefixes)  `                                                                                 -ModifiedProperty (Merge-NAVModified -Original $_.Original.Modified `                                                                                                                      -Modified $_.Modified.Modified `                                                                                                                      -Target $_.Target.Modified) }        }        else        {            write-host "Updating DateTime..." -ForegroundColor Green                $MergeResult |
                Where-Object {$_.MergeResult –eq 'Merged' -or $_.MergeResult –eq 'Conflict'}  |
                    foreach { 
                        Set-NAVApplicationObjectProperty -Target $_.Result -DateTimeProperty (Merge-NAVDateTime -OriginalDate $_.Original.Date `
                                                                                                                      -OriginalTime $_.Original.Time `
                                                                                                                      -ModifiedDate $_.Modified.Date `
                                                                                                                      -ModifiedTime $_.Modified.Time `
                                                                                                                      -TargetDate $_.Target.Date `                                                                                                                      -TargetTime $_.Target.Time) `                                                                           -ModifiedProperty (Merge-NAVModified -Original $_.Original.Modified `                                                                                                                      -Modified $_.Modified.Modified `                                                                                                                      -Target $_.Target.Modified)  }        }    }}if($CreateFilteredResultFolder){    write-host "Copying the non-identical files to $FilteredMergeResultFolder ..." -ForegroundColor Green    if (-not (Test-Path $MergeResultFolder)) {write-error "$MergeResultFolder not found! Deleting objects based on Mergeinfo is not possible"}    if (!$MergeResult) {$MergeResult = Import-Clixml -Path "$MergeInfoFolder\MergeResult.xml"}    if(Test-Path $FilteredMergeResultFolder) {Remove-Item -Path $FilteredMergeResultFolder -Recurse -Force}     New-Item -Path $FilteredMergeResultFolder -ItemType directory | Out-Null    $MergeResult |
        Where-Object {$_.MergeResult –ine 'Unchanged'}  |
             foreach {  
                try
                {                
                    Copy-Item  $_.Result -Destination $FilteredMergeResultFolder -ErrorAction SilentlyContinue    
                }
                catch
                {
                }
            }}if($DisplayObjectFilters){    Write-Host "Composing ObjectFilters..." -ForegroundColor Green    #if (-not (Test-Path $FilteredMergeResultFolder)) {write-error "$FilteredMergeResultFolder not found! Returning objectfilters will not be possible"}    if (!$MergeResult) {$MergeResult = Import-Clixml -Path "$MergeInfoFolder\MergeResult.xml"}    Import-module "$ScriptDirectory\Get-NAVObjectFilter.ps1" | Out-Null    $AllObjects = $MergeResult | Where-Object MergeResult -ne 'Unchanged'    
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
        }    }}if($OpenKdiffMergeWhenConflicts){    Write-host "Open Kdiff to start solving conflicts" -ForegroundColor Green    $ConflictModifiedFolder = "$MergeResultFolder\ConflictModified"    $ConflictOriginalFolder = "$MergeResultFolder\ConflictOriginal"    $ConflictTargetFolder = "$MergeResultFolder\ConflictTarget"    $MergetoolCommand = """""$MergetoolPath"" ""$ConflictOriginalFolder"" ""$ConflictModifiedFolder"" ""$ConflictTargetFolder"""""    Write-host $MergetoolCommand    cmd /c $MergetoolCommand }if($ImportObjects){    Write-host "Importing New and Changed Objects in NAV" -ForegroundColor Green    Import-Module "$ScriptDirectory\Import-NAVApplicationObjectFilesFromFolder.ps1" | Out-Null

    Import-NAVApplicationObjectFilesFromFolder -SourceFolder $FilteredMergeResultFolder -LogFolder "$FilteredMergeResultFolder\Log" -Server $Server -Database $Database }if($DeleteObjects){    Write-host "Removing Deleted Objects in NAV" -ForegroundColor Green    Import-Module "$ScriptDirectory\Get-NAVServerConfigurationValue.ps1" | Out-Null    if (-not (Test-Path $MergeResultFolder)) {write-error "$MergeResultFolder not found! Deleting objects based on Mergeinfo is not possible"}    if (!$MergeResult) {$MergeResult = Import-Clixml -Path "$MergeInfoFolder\MergeResult.xml"}    $MergeResult |
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
            }}if($CompileObjects){   Write-host "Compiling Objects in NAV" -ForegroundColor Green    Import-Module "$ScriptDirectory\ParallelCompile-NAVApplicationObject.ps1" | Out-Null

    ParallelCompile-NAVApplicationObject -ServerName $Server -DatabaseName $Database    }$MergeResult | Out-GridView