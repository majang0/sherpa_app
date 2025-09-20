# PowerShell script to replace all withOpacity with withValues
Get-ChildItem -Path "lib", "test" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $originalContent = $content

    # Replace withOpacity(value) with withValues(alpha: value)
    $content = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'

    if ($content -ne $originalContent) {
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($_.Name)"
    }
}

Write-Host "Completed fixing withOpacity deprecations"