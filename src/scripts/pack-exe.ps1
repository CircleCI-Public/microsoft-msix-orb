$parameters = ""

if ( $Env:PACK_MAPPING_FILE -ne "") {
    "/f ${Env.PACK_MAPPING_FILE}"
}

if ($Env:PACK_IMPORT_CERT -eq "true") {
  $certificate = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_SIGNING_CERT)
  $cert_pass = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_CERT_PASSWORD)

  [System.Convert]::FromBase64String($certificate) | Set-Content cert.pfx -Encoding Byte 
  # From https://gist.github.com/jrahme-cci/30a135c50db93a27bba649ddfb054661
  $Cert = Import-PfxCertificate -FilePath ./cert.pfx -Password (ConvertTo-SecureString -String "$cert_pass" -AsPlainText -Force) -CertStoreLocation Cert:\LocalMachine\My
  Export-Certificate -Cert $Cert -File c:\Cert.sst -Type SST
  Import-Certificate -File c:\cert.sst  -CertStoreLocation Cert:\LocalMachine\Root 
  Import-Certificate -File c:\cert.sst -CertStoreLocation Cert:\CurrentUser\My
}

$makeappx = "C:\Program Files (x86)\Windows Kits\10\bin\${Env.PACK_WINDOWS_SDK}\x64\makeappx.exe"

& $makeappx pack /d $Env:PACK_INPUT_DIR /p $Env:PACK_PACKAGE_NAME $parameters

$compress = @{
  Path = "AppPackages"
  CompressionLevel = "Fastest"
  DestinationPath = "AppPackages.zip"
}
Compress-Archive @compress
