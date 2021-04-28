$default_parameters = @("$Env:SIGN_PACKAGE_NAME.appx")
$parameters = if ($Env:SIGN_PARAMETERS -eq $null) {
  $default_parameters
} else {
  $Env:SIGN_PARAMETERS
}

if ($Env:SIGN_FINGERPRINT -ne $null) {
  $parameters = ,"/sha1 $Env:SIGN_FINGERPRINT " + $parameters
} else {
    $parameters = ,"/a " + $parameters
}

echo $parameters

if ($Env:SIGN_IMPORT_CERT -eq 1) {
  $certificate = $ExecutionContext.InvokeCommand.ExpandString($Env:SIGN_SIGNING_CERT)
  $cert_pass = $ExecutionContext.InvokeCommand.ExpandString($Env:SIGN_CERT_PASSWORD)

  [System.Convert]::FromBase64String($certificate) | Set-Content temp:/cert.pfx -AsByteStream
  # From https://gist.github.com/jrahme-cci/30a135c50db93a27bba649ddfb054661
  $Cert = Import-PfxCertificate -FilePath temp:/cert.pfx -Password (ConvertTo-SecureString -String "$cert_pass" -AsPlainText -Force) -CertStoreLocation Cert:\LocalMachine\My
  Export-Certificate -Cert $Cert -File temp:\cert.sst -Type SST
  Import-Certificate -File temp:\cert.sst  -CertStoreLocation Cert:\LocalMachine\Root 
  Import-Certificate -File tmp:\cert.sst -CertStoreLocation Cert:\CurrentUser\My
}

$signtool = "${Env:ProgramFiles(x86)}\Windows Kits\10\bin\${Env:SIGN_WINDOWS_SDK}\x64\signtool.exe"

"& $signtool sign $parameters" | iex
