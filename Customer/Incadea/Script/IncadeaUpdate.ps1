$CompanyName = 'Incadea'
$Location = "C:\GitHub\NAVUpgrade\Customer\$CompanyName\Script"
. (join-path $Location 'Set-IncadeaUpdateSettings.ps1')


clear-host

$StartedDateTime = Get-Date

#Reset Workingfolder
if (test-path $WorkingFolder){
    if (Confirm-YesOrNo -title 'Remove WorkingFolder?' -message "Do you want to remove the WorkingFolder $WorkingFolder ?"){
        Remove-Item -Path $WorkingFolder -Force -Recurse
    } else {
        write-error '$WorkingFolder already exists.  Overwrite not allowed.'
        break
    }
}
