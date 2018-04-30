$OrgFile = 'C:\incadea\Customer\Heydi\NAV2009\NAV2009_R2_32012_NO_Heydi_AllObjects.txt'
$NewFile = 'C:\incadea\Customer\Heydi\NAV2009\NAV2009_R2_32012_NO_Heydi_AllObjects_New.txt'
$DestFolder = 'C:\incadea\Customer\Heydi\NAV2009\Modified'
Split-NAVApplicationObjectFile -Source $OrgFile -Destination $DestFolder -PreserveFormatting -Force
Join-NAVApplicationObjectFile -Source "$DestFolder\*.TXT" -Destination $NewFile -Force