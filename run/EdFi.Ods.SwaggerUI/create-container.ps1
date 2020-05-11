docker run -d -p 8001:80 -p 8101:443 --name edfi-swagger-ui --env-file EdFi.Ods.SwaggerUI.env -v "$PSScriptRoot\cert:C:\cert" --env CERT_FILE_NAME=certificate.pfx edfi-swagger-ui -d