Write-Host "Starting Database Container..."
$dataFolder = "C:\SQL"
$jsonDataFolder = "C:\\SQL"
mkdir -Force $dataFolder
Push-Location $dataFolder
mkdir -Force .\data
mkdir -Force logs
Pop-Location
$attach_db = $env:attach_dbs
$databaseExists = $false

try {
    $conn = New-Object system.Data.SqlClient.SqlConnection
    $conn.connectionstring = "Server=localhost;Database=Edfi_Admin;Integrated Security=True;"
    $conn.ConnectionTimeout = 5
    $conn.open()
    $databaseExists = $true
}
catch {
}
$hasFiles = @(Get-ChildItem "$dataFolder\data\*.mdf").Count -gt 0
if (!$databaseExists -and $hasFiles) {
    Write-Host "Reattaching existing files..."
    $attach = @()
    @(Get-ChildItem "$dataFolder\data\*.mdf") | ForEach-Object -Process { 
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($_)
        if (Test-Path "$dataFolder\data\$fileName.ldf" -PathType Leaf) {
            $logFileName = "$jsonDataFolder\\data\\$fileName.ldf"
        }
        else {
            $logFileName = "$jsonDataFolder\\logs\\$fileName" + "_log.ldf"
        }
        $attach += ("{`"dbName`": `"$fileName`", `"dbFiles`": `[`"$jsonDataFolder\\data\\$fileName.mdf`",`"$logFileName`"]}")
    }
    $attach_db = "[" + ($attach -join ",") + "]"
}
if (!$databaseExists -and !$hasFiles -and ($attach_db -eq "[]")) {
    Write-Host "No databases detected, initializing..."
    sqlcmd -i c:\\sql-init\\SetTempSqlPassword.sql -o c:\\sql-init\\DefaultSqlFoldersOutput.txt
    ./sql-init/DLPDeployment.ps1 -PathResolverRepositoryOverride 'Ed-Fi-Common;Ed-Fi-ODS;Ed-Fi-ODS-Implementation;ed-fi-ods-buildsys' -InstallType $env:InstallType
    sqlcmd -i c:\\sql-init\\DisableSaLogin.sql -o c:\\sql-init\\DisableSaLoginOutput.txt
}

if ($attach_db -ne "[]") {
    Write-Host "Databases specified, attaching...";
    $attach_dbs_cleaned = $attach_db.TrimStart('\\').TrimEnd('\\');
    $dbs = $attach_dbs_cleaned | ConvertFrom-Json;
    Write-Host "Found $($dbs.Length) database(s)";
    if ($dbs.Length -gt 0) {
        Foreach ($db in $dbs) {
            $files = @();
            Foreach ($file in $db.dbFiles) {
                $files += "(FILENAME = N'$($file)')";
            }
            $files = $files -join ","
            $sqlcmd = "IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = '" + $($db.dbName) + "') BEGIN EXEC sp_detach_db [$($db.dbName)] END;CREATE DATABASE [$($db.dbName)] ON $($files) FOR ATTACH;"
            Write-Verbose "Invoke-Sqlcmd -Query $($sqlcmd)"
            & sqlcmd -Q $sqlcmd
        }
    }
}
Write-Host "Initialization complete, starting server..."
.\start -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA