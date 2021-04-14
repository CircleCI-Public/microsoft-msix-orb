$parameters = ""

$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"

$cert = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_SIGNING_CERT)
$cert_pass = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_CERT_PASSWORD) | ConvertTo-SecureString

[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($cert)) | Out-File -Encoding "ASCII" cert.pfx
Import-PfxCertificate -FilePath ./cert.pfx -CertStoreLocation Cert:\CurrentUser\Root -Password $cert_pass

& $msbuild /p:Platform=x64
