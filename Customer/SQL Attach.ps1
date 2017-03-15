$servername = "localhost"
$primaryfile = "BMW_Master_Data.mdf"

[void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO")
$options = [Microsoft.SqlServer.Management.Smo.AttachOptions]::None
$server = New-Object Microsoft.SqlServer.Management.Smo.Server $servername

# Here you can automatically determine the database name, or set it manually
$dbname = ($server.DetachedDatabaseInfo($primaryfile) | Where { $_.Property -eq "Database name" }).Value

# If you want to specify your files manually, use:
 $filestructure = New-Object System.Collections.Specialized.StringCollection
 $filestructure.add("C:\MSSQL\log\BMW_Master_Log.ldf")
 $filestructure.add("C:\MSSQL\data\BMW_Master_Data.mdf")
 $filestructure.add("C:\MSSQL\data\BMW_Master_1_Data.ndf")

<#
foreach    ($file in $server.EnumDetachedDatabaseFiles($primaryfile)) {
	$null = $filestructure.add($file)
}

foreach ($file in $server.EnumDetachedLogFiles($primaryfile)) {
	$null = $filestructure.add($file)
}
#>

try { 
	$server.AttachDatabase($dbname, $filestructure, "sa", $options)
	Write-Host "Successfully attached $dbname from $source" -ForegroundColor Green 
} 
catch { 
	$exception = $_.Exception.InnerException; 
	Write-Host $exception -ForegroundColor Red -BackgroundColor Black }