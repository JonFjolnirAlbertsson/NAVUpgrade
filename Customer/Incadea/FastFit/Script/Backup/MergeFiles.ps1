$Location = 'C:\GitHub\NAVUpgrade\Customer\Incadea\FastFit\Script\'
. (join-path $Location 'Set-UpgradeSettings.ps1')

$fileNames = Get-ChildItem -Path $ConflictTarget -Recurse -Include *.txt
foreach($filename in $fileNames)
{
    $Source = join-path $SourcePath  $filename.Name
    $Destination = join-path $DestinationPath  $filename.Name
    Copy-Item $Source -Destination $Destination
    Write-Host $Source + ' file copied to ' + $Destination
}

Join-NAVApplicationObjectFile -Destination $JoinFile -Source $DestinationPath

