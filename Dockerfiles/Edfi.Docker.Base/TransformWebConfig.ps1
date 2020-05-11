param (
    [string]$webConfig = "c:\inetpub\wwwroot\Web.config"
)

$transformEnvironment = (Get-ChildItem env:RUN_ENV).Value;
$doNotRequireHttps = (Get-ChildItem env:DO_NOT_REQUIRE_HTTPS).Value;
$transformFile = "C:/inetpub/wwwroot/Web.$transformEnvironment.config";
$doNotRequireHttpsFile = "C:/aspnet-startup/Web.DoNotRequireHttps.config";

if (Test-Path $transformFile) {
    Write-Host "Applying $transformEnvironment transform";
    C:/aspnet-startup/WebConfigTransformRunner.1.0.0.1/Tools/WebConfigTransformRunner.exe "$webConfig" "$transformFile" "$webConfig"
}

if ($doNotRequireHttps.ToLower() -eq "true") {
    Write-Host "Skipping HTTPS redirect";
    C:/aspnet-startup/WebConfigTransformRunner.1.0.0.1/Tools/WebConfigTransformRunner.exe "$webConfig" "$doNotRequireHttpsFile" "$webConfig"
}