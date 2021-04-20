$default_parameters = "/p:Platform=x64"
$parameters = if ($Env:PACK_PARAMETERS -eq $null) {
  $default_parameters
} else {
  $Env:PACK_PARAMETERS
}

echo $parameters

$msbuild = "'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe'"

if ($Env:PACK_IMPORT_CERT -eq 1) {
  $certificate = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_SIGNING_CERT)
  $cert_pass = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_CERT_PASSWORD)

  [System.Convert]::FromBase64String($certificate) | Set-Content cert.pfx -Encoding Byte 
  # From https://gist.github.com/jrahme-cci/30a135c50db93a27bba649ddfb054661
  $Cert = Import-PfxCertificate -FilePath ./cert.pfx -Password (ConvertTo-SecureString -String "$cert_pass" -AsPlainText -Force) -CertStoreLocation Cert:\LocalMachine\My
  Export-Certificate -Cert $Cert -File c:\Cert.sst -Type SST
  Import-Certificate -File c:\cert.sst  -CertStoreLocation Cert:\LocalMachine\Root 
  Import-Certificate -File c:\cert.sst -CertStoreLocation Cert:\CurrentUser\My
}
"& $msbuild $parameters" | iex

$compress = @{
  Path = "AppPackages"
  CompressionLevel = "Fastest"
  DestinationPath = "AppPackages.zip"
}
Compress-Archive @compress
