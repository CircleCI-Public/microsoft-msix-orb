$ErrorActionPreference = "Stop" 

$default_parameters = "/p:Platform=x64"
$parameters = if ($Env:PACK_PARAMETERS -eq $null) {
  $default_parameters
} else {
  $Env:PACK_PARAMETERS
}

$msbuild = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"

if ($Env:PACK_IMPORT_CERT -eq 1) {
  $certificate = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_SIGNING_CERT)
  $cert_pass = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_CERT_PASSWORD)

  [System.Convert]::FromBase64String($certificate) | Set-Content temp:\cert.pfx -AsByteStream
  # From https://gist.github.com/jrahme-cci/30a135c50db93a27bba649ddfb054661
  $Cert = Import-PfxCertificate -FilePath temp:\cert.pfx -Password (ConvertTo-SecureString -String "$cert_pass" -AsPlainText -Force) -CertStoreLocation Cert:\LocalMachine\My
  Export-Certificate -Cert $Cert -File temp:\cert.sst -Type SST
  Import-Certificate -File temp:\cert.sst  -CertStoreLocation Cert:\LocalMachine\Root 
  Import-Certificate -File temp:\cert.sst -CertStoreLocation Cert:\CurrentUser\My
}
& $msbuild $parameters

$compress = @{
  Path = "AppPackages"
  CompressionLevel = "Fastest"
  DestinationPath = "AppPackages.zip"
}
Compress-Archive @compress
