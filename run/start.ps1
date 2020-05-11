param (
    [String]$Version="latest",
    [String]$Environment="localdev"
)

Push-Location $Environment

# Ensure that the data directory exists
$dataDir = ".\data\$Version"
if (! (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Force -Path $dataDir
}

# Update the .env file
$envFile = Get-Content ".env"
$envFile = $envFile -replace "DATA_FOLDER=\.\\data\\[0-9\.]+", "DATA_FOLDER=.\data\$Version"
$envFile = $envFile -replace "TAG=[0-9\.]+", "TAG=$Version"
$envFile | Out-File -encoding ASCII ".env"

docker-compose up -d
Pop-Location