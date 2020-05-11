param (
    [string]$webConfig = "c:\inetpub\wwwroot\Web.config"
)

$doc = (Get-Content $webConfig) -as [Xml];
$modified = $FALSE;

$appSettingPrefix = "APPSETTING_";
$connectionStringPrefix = "CONNSTR_";

Get-ChildItem env:* | ForEach-Object {
    if ($_.Key.StartsWith($appSettingPrefix)) {
        $key = $_.Key.Substring($appSettingPrefix.Length);
        $appSetting = $doc.configuration.appSettings.add | Where-Object {$_.key -eq $key};
        if ($appSetting) {
            $appSetting.value = $_.Value;
            Write-Host "Replaced appSetting" $_.Key $_.Value;
            $modified = $TRUE;
        }
    }
    if ($_.Key.StartsWith($connectionStringPrefix)) {
        $key = $_.Key.Substring($connectionStringPrefix.Length);
        $connStr = $doc.configuration.connectionStrings.add | Where-Object {$_.name -eq $key};
        if ($connStr) {
            $connStr.connectionString = $_.Value;
            Write-Host "Replaced connectionString" $_.Key $_.Value;
            $modified = $TRUE;
        }
    }
}

# Custom settings
$log4netLogLevel = (Get-ChildItem env:LOG4NET_LOG_LEVEL).Value;
Write-Host "Seting log level to $log4netLogLevel";
if ($log4netLogLevel -ne "") {
    try {
        $doc.configuration.log4net.root.level.value = $log4netLogLevel;
    }
    catch {
        Write-Host "Log level setting not found, skipping...";
    }
}
$turnOffCustomErrors = Test-Path env:\CUSTOM_ERRORS_OFF
if ($turnOffCustomErrors) {
    try {
        $customErrorValue = [string] $doc.configuration."system.web".customErrors.mode;
        if ($customErrorValue -eq "") {
            $node = $doc.CreateElement("customErrors");
            $att = $doc.CreateAttribute("mode", $null);
            $node.Attributes.Append($att);
            $node.mode = "Off";
            $doc.configuration."system.web".AppendChild($node);
        }
    }
    catch {
        Write-Host "Failed disabling custom errors...";
    }
}
$doc.Save($webConfig);

