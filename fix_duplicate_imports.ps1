# PowerShell script to remove duplicate import statements
Get-ChildItem -Path "lib", "test" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $originalContent = $content

    # Remove duplicate consecutive import 'package:flutter/foundation.dart'; statements
    # Keep only one and remove the duplicates
    $content = $content -replace "(import 'package:flutter/foundation\.dart';\s*\n)+", "import 'package:flutter/foundation.dart';`n"

    if ($content -ne $originalContent) {
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Fixed duplicate imports in: $($_.Name)"
    }
}

Write-Host "Completed fixing duplicate imports"