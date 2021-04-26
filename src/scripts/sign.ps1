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

  [System.Convert]::FromBase64String($certificate) | Set-Content cert.pfx -Encoding Byte 
  # From https://gist.github.com/jrahme-cci/30a135c50db93a27bba649ddfb054661
  $Cert = Import-PfxCertificate -FilePath ./cert.pfx -Password (ConvertTo-SecureString -String "$cert_pass" -AsPlainText -Force) -CertStoreLocation Cert:\LocalMachine\My
  Export-Certificate -Cert $Cert -File c:\Cert.sst -Type SST
  Import-Certificate -File c:\cert.sst  -CertStoreLocation Cert:\LocalMachine\Root 
  Import-Certificate -File c:\cert.sst -CertStoreLocation Cert:\CurrentUser\My
}

$signtool = "'C:\Program Files (x86)\Windows Kits\10\bin\${Env:SIGN_WINDOWS_SDK}\x64\signtool.exe'"

"& $signtool sign $parameters" | iex
