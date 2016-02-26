﻿# Comparing and merging
#Busch Vakuumteknikk
$CompanyFolderName = "Busch"
$CompanyOriginalFileName = "NAV50_NO_AllObjects.txt"
$CompanyModifiedFileName = "Busch_AllModifiedObjects.txt"
$CompanyTargetFileName = "2016_CU1_NO_AllObjects.txt"

# Set the right folder path based on company folder and files name
$RootFolderPath = "C:\NavUpgrade\"
$SourceOriginal = $RootFolderPath + $CompanyFolderName + "\" + $CompanyOriginalFileName
$SourceModified = $RootFolderPath + $CompanyFolderName + "\" + $CompanyModifiedFileName
$SourceTarget = $RootFolderPath + $CompanyFolderName + "\" + $CompanyTargetFileName

$DestinationOriginal = $RootFolderPath + $CompanyFolderName + "\Original\"
$DestinationModified = $RootFolderPath + $CompanyFolderName + "\Modified\"
$DestinationTarget = $RootFolderPath + $CompanyFolderName + "\Target\"

$Delta = $RootFolderPath + $CompanyFolderName + "\Delta\"
$Result = $RootFolderPath + $CompanyFolderName + "\Result\"
#$Merged = $RootFolderPath + $CompanyFolderName + "\Merged\Ready2Import\"
$Merged = $RootFolderPath + $CompanyFolderName + "\Merged\"

# Check if folders exists. If not create them.
if(!(Test-Path -Path $Delta )){
    New-Item -ItemType directory -Path $Delta
}
if(!(Test-Path -Path $Result )){
    New-Item -ItemType directory -Path $Result
}
if(!(Test-Path -Path $Merged )){
    New-Item -ItemType directory -Path $Merged
}
# Set file name to merge or files (*.TXT)
#$CompareObject = "TAB1500000*.TXT"
#$UpdateObject = "TAB18.DELTA"
$CompareObject = "*.TXT"

#Set Source, modified, target and result values
$OriginalCompareObject = $DestinationOriginal + $CompareObject
$ModifiedCompareObject = $DestinationModified + $CompareObject
$TargetCompareObject = $DestinationTarget + $CompareObject
$DeltaUpdateObject = $Delta + $UpdateObject
$JoinSource = $Merged + "ToBeJoined\" +$CompareObject
$JoinDestination = $Merged + "all-merged-objects.txt"

#Uprade process action
#$UpgradeAction = "Split" # First step
#$UpgradeAction = "Merge" # Second step
$UpgradeAction = "Join" # Third step. When all objects er reday for import to new database


$Version = '9.0*'
if(([string]::Equals($Version, "7.1")) -or ($Version -eq "71")-or ($Version -eq "7.1*"))
{
    Import-Module "C:\Users\jal\OneDrive for Business\Files\NAV\Script\NAV2013R2\StartingISENAV71.ps1"  
}
if(([string]::Equals($Version, "8.0")) -or ($Version -eq "80")-or ($Version -like '8.0*'))
{
    Import-Module "C:\Users\jal\OneDrive for Business\Files\NAV\Script\NAV2015\StartingISENAV80.ps1" 
}    
if(([string]::Equals($Version, "9.0")) -or ($Version -eq "90")-or ($Version -like '9.0*'))
{
    Import-Module "C:\Users\jal\OneDrive for Business\Files\NAV\Script\NAV2016\StartingISENAV90.ps1" 
} 
# Split text files with many objects
If($UpgradeAction -eq "Split")
{
    Remove-Item -Path "$DestinationOriginal*.*"
    Remove-Item -Path "$DestinationModified*.*"
    Remove-Item -Path "$DestinationTarget*.*"

    Split-NAVApplicationObjectFile  -Source $SourceOriginal -Destination $DestinationOriginal -PreserveFormatting -Force
    Split-NAVApplicationObjectFile  -Source $SourceModified -Destination $DestinationModified -PreserveFormatting -Force
    Split-NAVApplicationObjectFile  -Source $SourceTarget -Destination $DestinationTarget -PreserveFormatting -Force
    
    echo "The source file $SourceOriginal has been split to the destination $DestinationOriginal"
    echo "The source file $SourceModified has been split to the destination $DestinationModified"
    echo "The source file $SourceTarget has been split to the destination $DestinationModified"
}
ElseIf($UpgradeAction -eq "Merge")
{
# This merge command has been run.
# If the MergedTool has also been runned and updated the merge. The new files are in the "Merged" folder. 
    #Merge-NAVApplicationObject -Original $OriginalCompareObject -Modified $ModifiedCompareObject -Target $TargetCompareObject -Result $Result -Force -Verbose -ErrorAction Inquire  | Sort-Object ObjectType, Id | Format-Table
    Merge-NAVApplicationObject -Modified $ModifiedCompareObject -Original $OriginalCompareObject -Result $Result -Target $TargetCompareObject -DateTimeProperty FromTarget -ModifiedProperty FromModified -VersionListProperty FromTarget -Force
    
    $CODFolder = $Result + "COD\"
    Remove-Item -Path "$CODFolder*.*"
    $TABFolder = $Result + "TAB\"
    Remove-Item -Path "$TABFolder*.*"
    $PAGFolder = $Result + "PAG\"
    Remove-Item -Path "$PAGFolder*.*"
    $REPFolder = $Result + "REP\"
    Remove-Item -Path "$REPFolder*.*"

    #get-childitem  -path $Result  | where-object {$_.Name -like "COD*.*"} | Out-Default
    get-childitem  -path $Result  | where-object {$_.Name -like "COD*.*"} | Move-Item -Destination $CODFolder
    get-childitem  -path $Result  | where-object {$_.Name -like "TAB*.*"} | Move-Item -Destination $TABFolder
    get-childitem  -path $Result  | where-object {$_.Name -like "PAG*.*"} | Move-Item -Destination $PAGFolder
    get-childitem  -path $Result  | where-object {$_.Name -like "REP*.*"} | Move-Item -Destination $REPFolder

    echo "The filter used to merge files was $CompareObject"
    echo "Below you can see were the source files come from.."
    echo $OriginalCompareObject
    echo $ModifiedCompareObject
    echo $TargetCompareObject
    echo "The merged files are found in the folder $Result, and the related subfolders (COD,TAB,PAG and REP)."

    echo "Remember.."
    echo "After the script has run the result files should be compared." 
    echo "The result files should be compared to the Modified file and the target file."

}
ElseIf($UpgradeAction -eq "Join")
{
    Join-NAVApplicationObjectFile -Source $JoinSource -Destination $JoinDestination -Force

    echo "The filter used to join files was $CompareObject"
    echo "The join files come from the $JoinSource"
    echo "The join files are in the file $JoinDestination"
}
echo "Execution finished."