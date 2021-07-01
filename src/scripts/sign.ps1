$ErrorActionPreference = "Stop" 

$default_parameters = "${Env:SIGN_PACKAGE_NAME}.appx"

$p = if ("" -ne $Env:SIGN_PARAMETERS) {
  $Env:SIGN_PARAMETERS
} else { $default_parameters }

if ($Env:SIGN_FINGERPRINT -ne $null) {
  $parameters = "/sha1 $Env:SIGN_FINGERPRINT " + $p
} else {
    $parameters = "/a " + $p
}

if ($Env:SIGN_IMPORT_CERT -eq 1) {
  Import-Module -SkipEditionCheck PKI

  $certificate = $ExecutionContext.InvokeCommand.ExpandString($Env:SIGN_SIGNING_CERT)
  $cert_pass = $ExecutionContext.InvokeCommand.ExpandString($Env:SIGN_CERT_PASSWORD)

  [System.Convert]::FromBase64String($certificate) | Set-Content Temp:\cert.pfx -AsByteStream
  Import-PfxCertificate -FilePath Temp:\cert.pfx -Password (ConvertTo-SecureString -String "$cert_pass" -AsPlainText -Force) -CertStoreLocation Cert:\LocalMachine\My
}

$signtool = "'${Env:ProgramFiles(x86)}\Windows Kits\10\bin\${Env:SIGN_WINDOWS_SDK}\x64\signtool.exe'"

echo $parameters

"& $signtool sign $parameters" | Invoke-Expression
