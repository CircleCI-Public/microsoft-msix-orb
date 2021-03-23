# Update appxmanifest. This must be done before the build.
[xml]$manifest = get-content ".\Msix\Package.appxmanifest"
$manifest.Package.Identity.Version = "$(major).$(minor).$(build).$(revision)"    
$manifest.save("Msix/Package.appxmanifest")
