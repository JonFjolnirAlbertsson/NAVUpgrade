$NotepadPlus = Join-Path 'C:\Program Files (x86)\Notepad++' 'notepad++.exe'
$Kdiff = Join-Path 'C:\Program Files\KDiff3' 'kdiff3.exe'
#Split Original, Modified and Target object file. Creates Folder structure under the working folder
#[UpgradeAction] $UpgradeAction = [UpgradeAction]::Split
#Merge-NAVCode -WorkingFolderPath $WorkingFolder -OriginalFileName $OriginalObjects -ModifiedFileName $ModifiedObjects -TargetFileName $TargetObjects -UpgradeAction $UpgradeAction -CompareObject $CompareObject

#& $Kdiff $Original $Modified $Target -o $Merged  
#Merge-NAVApplicationObject -Modified $Modified -Original $Original -Result $Merged -Target $Target -DateTimeProperty FromTarget -ModifiedProperty FromModified -VersionListProperty FromTarget -Force 

#Get overview over deleted, new or changed objects, between MergeResult and Target object files.
$MergeResultFolder = "$WorkingFolder\MergeResult"
$CompareObject = '*.TXT'
$CompOriginal = Get-ChildItem -Recurse -path $TargetFolder | where-object {$_.Name -like $CompareObject}
$CompTarget = Get-ChildItem -Recurse -path $MergeResultFolder | where-object {$_.Name -like $CompareObject}
$results = @(Compare-Object  -casesensitive -ReferenceObject $CompOriginal -DifferenceObject $CompTarget -property Name, Length -PassThru)
$results | Out-GridView
#Copy file with difference in size to Merged folder
foreach($result in $results)
{
    Write-Host $MessageStr -foregroundcolor "yellow"
    $MessageStr = $result.Name + ". The SideIndicator is" + $result.SideIndicator   
    Copy-Item -Path (join-path "$WorkingFolderNAV2009\Result\TAB" $result.Name) -Destination (join-path "$WorkingFolderNAV2009\Merged" $result.Name)         
}
# NAV 2009 overview over deleted, new or changed tables, between Result and Target object files.
$CompareObject = 'TAB*.TXT'
$CompOriginal = Get-ChildItem -Recurse -path "$WorkingFolderNAV2009\Target" | where-object {$_.Name -like $CompareObject}
$CompTarget = Get-ChildItem -Recurse -path "$WorkingFolderNAV2009\Result\TAB" | where-object {$_.Name -like $CompareObject}
$results = @(Compare-Object -DifferenceObject $CompTarget -ReferenceObject $CompOriginal -property Name, Length -PassThru)
$results | Out-GridView
#Copy file with difference in size to Merged folder
foreach($result in $results)
{
    Write-Host $MessageStr -foregroundcolor "yellow"
    $MessageStr = $result.Name + ". The SideIndicator is" + $result.SideIndicator   
    Copy-Item -Path (join-path "$WorkingFolderNAV2009\Result\TAB" $result.Name) -Destination (join-path "$WorkingFolderNAV2009\Merged" $result.Name)         
}
#Remove unactual object from standard in the range 1..49999
$CompareObject = 'TAB*.TXT'
Remove-OriginalFilesNotInTarget -CompareObject $CompareObject -OriginalFolder "$WorkingFolderNAV2009\Original" -TargetFolder "$WorkingFolderNAV2009\Target" -WorkingFolderPath $WorkingFolderNAV2009
Remove-ModifiedFilesNotInTarget -CompareObject $CompareObject -ModifiedFolder "$WorkingFolderNAV2009\Modified" -TargetFolder "$WorkingFolderNAV2009\Target" -WorkingFolderPath $WorkingFolderNAV2009
#Open file in Notepad++ to merge them
$ObjectName ='TAB36'
Open-File-SID -ObjectName $ObjectName -WorkingFolderPath $WorkingFolderNAV2009 -OpenTarget -OpenMerged

<#
$CompTarget | ForEach-Object {
    # Check if the file, from $folder1, exists with the same path under $folder2
    If ( Test-Path ( $_.FullName.Replace($CompTarget, $CompOriginal) ) ) {

        # Compare the contents of the two files...
        If ( Compare-Object (Get-Content $_.FullName) (Get-Content $_.FullName.Replace($CompTarget, $CompOriginal) ) ) {

            # List the paths of the files containing diffs
            Write-Host $_.FullName
            Write-Host $_.FullName.Replace($CompTarget, $CompOriginal)

        }
    }   
}
$ResultFiles = Merge-NAVApplicationObject -Modified $Modified -Original $Original -Result $Merged -Target $Target -DateTimeProperty FromTarget -ModifiedProperty FromModified -VersionListProperty FromTarget -Force 
Write-Host "`nOpen NOTEPAD for each CONFLICT file" -foreground Green
$ResultFiles | 
	Where-Object MergeResult -eq 'Conflict' | 
	foreach {
        &  $NotepadPlus $_.Conflict 
    }

# Open three-way merge-tool KDIFF3 for each object with conflict(s)
$ResultFiles | 
	Where-Object MergeResult -eq 'Conflict' | 
	#foreach { & "C:\Program Files\KDiff3\kdiff3" $_.Original $_.Modified $_.Target -o $_.Result }
    foreach {
        & $Kdiff $_.Original $_.Modified $_.Target -o  (join-path $Merged (Get-Item $_.Original.FileName).Name) 
        }
#}

$MergeResultFolder = Join-Path $WorkingFolder 'MergeResult'
    if(Test-Path $MergeResultFolder){
        if(!$force){
            if (!(Confirm-YesOrNo -title "Remove $MergeResultFolder ?" -message "Do you want to remove the existing folder $MergeResultFolder ?")){
                Write-Error "Merge cancelled!`n Folder $MergeResultFolder already exists."
                break
            }
        }
        $null = Remove-Item $MergeResultFolder -Recurse -Force
    }
#Merge objects
Write-Host "Merge to $MergeResultFolder" -ForegroundColor Green
$Mergeresult = Merge-NAVApplicationObject `
    -OriginalPath $OriginalObjects `
    -ModifiedPath $ModifiedObjects `
    -TargetPath $TargetObjects `
    -ResultPath $MergeResultFolder `
    -DateTimeProperty FromModified `
    -ModifiedProperty FromModified `
    -VersionListProperty FromModified `
    -DocumentationConflict TargetFirst `
    -Force
#Update Versionlist
Write-Host 'Update Versionlist and DateTime' -ForegroundColor Green
$Mergeresult | Where-Object {$_.MergeResult –eq 'Merged' -or $_.MergeResult –eq 'Conflict'}  |  Merge-NAVApplicationObjectProperty -UpdateDateTime $true -UpdateVersionList $true -VersionListPrefixes $VersionListPrefixes

#>