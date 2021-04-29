$ErrorActionPreference = "Stop"

$default_parameters = "/m $Env:PACK_MANIFEST_FILE /f $Env:PACK_MAP_FILE /p $Env:PACK_PACKAGE_NAME"
$parameters = if ($Env:PACK_PARAMETERS -eq $null) {
  $default_parameters
} else {
  $Env:PACK_PARAMETERS
}

$makeappx = "'${Env:ProgramFiles(x86)}\Windows Kits\10\bin\${Env:PACK_WINDOWS_SDK}\x64\makeappx.exe'"

"& $makeappx pack $parameters" | iex