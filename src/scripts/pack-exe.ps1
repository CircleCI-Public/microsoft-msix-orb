$parameters = ""

if ( $Env:PACK_MAPPING_FILE -ne "") {
    "/f ${Env.PACK_MAPPING_FILE}"
}

$cert = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_SIGNING_CERT)
$cert_pass = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_CERT_PASSWORD) | ConvertTo-SecureString

[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($cert)) | Out-File -Encoding "ASCII" cert.pfx
Import-PfxCertificate -FilePath ./cert.pfx -CertStoreLocation Cert:\CurrentUser\Root -Password $cert_pass

$makeappx = "C:\Program Files (x86)\Windows Kits\10\bin\${Env.PACK_WINDOWS_SDK}\x64\makeappx.exe"

& $makeappx pack /d $Env:PACK_INPUT_DIR /p $Env:PACK_PACKAGE_NAME $parameters
