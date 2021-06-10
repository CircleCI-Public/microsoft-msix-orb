$ErrorActionPreference = "Stop" 

$default_parameters = "${Env:SIGN_PACKAGE_NAME}.appx"
$parameters = ($Env:SIGN_PARAMETERS -eq $null) ? $default_parameters : $Env:SIGN_PARAMETERS

if ($Env:SIGN_FINGERPRINT -ne $null) {
  $parameters = "/sha1 $Env:SIGN_FINGERPRINT " + $parameters
} else {
    $parameters = "/a " + $parameters
}

if ($Env:SIGN_IMPORT_CERT -eq 1) {
  $certificate = $ExecutionContext.InvokeCommand.ExpandString($Env:SIGN_SIGNING_CERT)
  $cert_pass = $ExecutionContext.InvokeCommand.ExpandString($Env:SIGN_CERT_PASSWORD)

  [System.Convert]::FromBase64String($certificate) | Set-Content Temp:\cert.pfx -Encoding Byte
  Import-PfxCertificate -FilePath Temp:\cert.pfx -Password (ConvertTo-SecureString -String "$cert_pass" -AsPlainText -Force) -CertStoreLocation Cert:\LocalMachine\My
}

$signtool = "'${Env:ProgramFiles(x86)}\Windows Kits\10\bin\${Env:SIGN_WINDOWS_SDK}\x64\signtool.exe'"

"& $signtool sign $parameters" | iex
