$OrgFile = 'C:\incadea\Customer\Heydi\NAV2009\NAV2009_R2_32012_NO_Heydi_AllObjects.txt'
$NewFile = 'C:\incadea\Customer\Heydi\NAV2009\NAV2009_R2_32012_NO_Heydi_AllObjects_New.txt'
$FormsFile = 'C:\incadea\Customer\Heydi\NAV2009\NAV2009_R2_32012_NO_Heydi_AllObjects - Forms.txt'
$NewFormsFile = 'C:\incadea\Customer\Heydi\NAV2009\NAV2009_R2_32012_NO_Heydi_AllObjects - Forms New.txt'
$DestFolder = 'C:\incadea\Customer\Heydi\NAV2009\Modified'
$DestFormsFolder = 'C:\incadea\Customer\Heydi\NAV2009\Forms'
Split-NAVApplicationObjectFile -Source $OrgFile -Destination $DestFolder -PreserveFormatting -Force
Join-NAVApplicationObjectFile -Source "$DestFolder\*.TXT" -Destination $NewFile -Force
Split-NAVApplicationObjectFile -Source $FormsFile -Destination $DestFormsFolder -PreserveFormatting -Force
Join-NAVApplicationObjectFile -Source "$DestFormsFolder\*.TXT" -Destination $NewFormsFile -Force