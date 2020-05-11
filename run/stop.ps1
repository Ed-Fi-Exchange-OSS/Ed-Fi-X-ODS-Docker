param (
    [String]$Environment="localdev"
)

Push-Location $Environment
docker-compose down
Pop-Location