docker run -d -p 8000:80 -p 8100:443 --name edfi-web-api --env-file EdFi.Ods.WebApi.env -v "$PSScriptRoot\cert:C:\cert" -v "$PSScriptRoot\logs:C:\ProgramData\Ed-Fi-ODS-API" --env CERT_FILE_NAME=certificate.pfx edfi-web-api -d