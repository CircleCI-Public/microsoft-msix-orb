$ErrorActionPreference = "Stop" 

$default_parameters = "/p:Platform=x64"

$parameters = if ($null -ne $Env:PACK_PARAMETERS) {
  $Env:PACK_PARAMETERS
} else { $default_parameters }

$msbuild = "'${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe'"

if ($Env:PACK_IMPORT_CERT -eq 1) {
  Import-Module -SkipEditionCheck PKI
  $certificate = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_SIGNING_CERT)
  $cert_pass = $ExecutionContext.InvokeCommand.ExpandString($Env:PACK_CERT_PASSWORD)

  [System.Convert]::FromBase64String($certificate) | Set-Content Temp:\cert.pfx -AsByteStream
  Import-PfxCertificate -FilePath Temp:\cert.pfx -Password (ConvertTo-SecureString -String "$cert_pass" -AsPlainText -Force) -CertStoreLocation Cert:\CurrentUser\My
}
"& $msbuild $parameters" | Invoke-Expression

$compress = @{
  Path = "AppPackages"
  CompressionLevel = "Fastest"
  DestinationPath = "AppPackages.zip"
}
Compress-Archive @compress
