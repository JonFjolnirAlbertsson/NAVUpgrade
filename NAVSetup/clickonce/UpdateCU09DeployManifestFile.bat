REM "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\NETFX 4.0 Tools\mage.exe" -cc 
chdir /d "O:\Incadea\clickonce\Deployment"
"C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\NETFX 4.0 Tools\mage.exe" -update Microsoft.Dynamics.Nav.Client.application -appmanifest CU09\Microsoft.Dynamics.Nav.Client.exe.manifest -appcodebase "\\OAS-FIL\Datastore\Incadea\clickonce\Deployment\CU09\Microsoft.Dynamics.Nav.Client.exe.manifest"
chdir /d "C:\Incadea