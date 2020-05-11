C:\aspnet-startup\TransformWebConfig.ps1 -webConfig c:\inetpub\wwwroot\Web.config
C:\aspnet-startup\ApplySettings.ps1 -webConfig c:\inetpub\wwwroot\Web.config

$isSSL = Test-Path env:\CERT_FILE_NAME
if ($isSSL) {
    Write-Host "Checking certificate $env:CERT_FILE_NAME"
    $isSSLAndFilePresent = Test-Path "C:\cert\$env:CERT_FILE_NAME" -PathType Leaf
}

if ($isSSL -and !$isSSLAndFilePresent) {
    Write-Host "Certificate declared but file not found"
}
else {
    Write-Host "Certificate found!"
}

if ($isSSLAndFilePresent) {
    Write-Host "Loading SSL certificate from $env:CERT_FILE_NAME"
    $certPassword = [string] $env:CERT_PASSWORD
    $certFileName = $env:CERT_FILE_NAME
    $certPath = "C:\cert"
    $sitename = "Default Web Site"
    if ($certPassword -ne "") {
        $secureCertPass = ConvertTo-SecureString -String $certPassword -AsPlainText -Force
        $thumbprint = @(Import-PfxCertificate -Password $secureCertPass -CertStoreLocation Cert:\LocalMachine\My -FilePath $certPath\$certFileName).Thumbprint
    }
    else {
        $thumbprint = @(Import-PfxCertificate -CertStoreLocation Cert:\LocalMachine\My -FilePath $certPath\$certFileName).Thumbprint   
    }
    try {
        $binding = New-WebBinding -Name ${sitename} -Protocol https -IPAddress * -Port 443;
    }
    catch {
        Write-Host "HTTPS binding already exists. Skipping."
    }
    $binding = Get-WebBinding -Name ${sitename} -Protocol https;
    $binding.AddSslCertificate(${thumbprint}, "my");
}

C:\ServiceMonitor.exe w3svc