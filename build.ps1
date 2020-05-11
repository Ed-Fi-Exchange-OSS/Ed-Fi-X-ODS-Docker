param (
    [String]$Version
)
$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$targetNugetExe = "$PSScriptRoot\tools\nuget.exe"
$myget = "https://www.myget.org/F/ed-fi/api/v3/index.json"
$dockerfiles = "$PSScriptRoot\Dockerfiles"

# Cleanup and create folders
Push-Location "$PSScriptRoot"
Remove-Item build -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
mkdir -Force tools
mkdir -Force build
mkdir -Force output
mkdir -Force feed
Pop-Location

$nugetExists = $false
if (Get-Command 'nuget.exe' -ErrorAction SilentlyContinue) {
    $nugetExists = $true
} else {
    # Download Nuget
    if (!(Test-Path "$PSScriptRoot\tools\nuget.exe" -PathType Leaf) -and !$nugetExists) {
        Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
    }
    Set-Alias nuget $targetNugetExe -Scope Global
} 


$tagVersion = "latest"
if ($Version) {
    $tagVersion = $Version
    $versionFlag = '-Version'
}

nuget install WebConfigTransformRunner -OutputDirectory "$PSScriptRoot\build\Edfi.Docker.Base" -Version 1.0.0.1
nuget install EdFi.Ods.WebApi.EFA -OutputDirectory "$PSScriptRoot\build" -Source $myget $versionFlag $Version
nuget install EdFi.Ods.SwaggerUI.EFA -OutputDirectory "$PSScriptRoot\build" -Source $myget $versionFlag $Version
nuget install EdFi.Ods.Admin.Web.EFA -OutputDirectory "$PSScriptRoot\build" -Source $myget $versionFlag $Version
nuget install EdFi.RestApi.Databases.EFA -OutputDirectory "$PSScriptRoot\build" -Source $myget $versionFlag $Version

# Stage source files
$apiFolder = @(Get-ChildItem -Directory "$PSScriptRoot\build\EdFi.Ods.WebApi.EFA*")[-1]
$swaggerFolder = @(Get-ChildItem -Directory "$PSScriptRoot\build\EdFi.Ods.SwaggerUI.EFA*")[-1]
$adminFolder = @(Get-ChildItem -Directory "$PSScriptRoot\build\EdFi.Ods.Admin.Web.EFA*")[-1]
$sqlFolder = @(Get-ChildItem -Directory "$PSScriptRoot\build\EdFi.RestApi.Databases.EFA*")[-1]

Copy-Item "$dockerfiles\EdFi.Ods.WebApi\*" -Recurse -Force -Destination "$apiFolder\"
Copy-Item "$dockerfiles\EdFi.Ods.SwaggerUI\*" -Recurse -Force -Destination "$swaggerFolder\"
Copy-Item "$dockerfiles\EdFi.Ods.Admin.Web\*" -Recurse -Force -Destination "$adminFolder\"
Copy-Item "$dockerfiles\EdFi.RestApi.Databases\*" -Recurse -Force -Destination "$sqlFolder\"
Copy-Item .dockerignore -Destination "$apiFolder\"
Copy-Item .dockerignore -Destination "$swaggerFolder\"
Copy-Item .dockerignore -Destination "$adminFolder\"
Copy-Item .dockerignore -Destination "$sqlFolder\"
Push-Location "$dockerfiles\Edfi.Docker.Base"
Copy-Item -Path . -Include * -Recurse -Force -Destination "$PSScriptRoot\build\"
Pop-Location

# Build Images
Push-Location "$PSScriptRoot\build\Edfi.Docker.Base"
docker build --tag "edfi-base:$tagVersion" --build-arg ODS_VERSION=$tagVersion . 
Pop-Location
Push-Location $apiFolder
docker build --tag "edfi-web-api:$tagVersion" --build-arg ODS_VERSION=$tagVersion .
Pop-Location
Push-Location $swaggerFolder
docker build --tag "edfi-swagger-ui:$tagVersion" --build-arg ODS_VERSION=$tagVersion .
Pop-Location
Push-Location $adminFolder
docker build --tag "edfi-admin-web:$tagVersion" --build-arg ODS_VERSION=$tagVersion .
Pop-Location
Push-Location $sqlFolder
docker build --tag "edfi-restapi-database:$tagVersion" --build-arg ODS_VERSION=$tagVersion .
Pop-Location