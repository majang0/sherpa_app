# PowerShell script to fix empty catch blocks
Get-ChildItem -Path "lib", "test" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $originalContent = $content

    # Fix empty catch blocks - pattern 1: catch (e) {}
    $content = $content -replace '(\s*)catch\s*\(\s*(\w+)\s*\)\s*\{\s*\}', '$1catch ($2) {$1  // TODO: Proper error handling$1  debugPrint(''Error caught: $$$2'');$1}'

    # Fix empty catch blocks - pattern 2: catch (_) {}
    $content = $content -replace '(\s*)catch\s*\(\s*_\s*\)\s*\{\s*\}', '$1catch (e) {$1  // TODO: Proper error handling$1  debugPrint(''Error caught: $$e'');$1}'

    # Fix empty catch blocks - pattern 3: } catch (e) {} on single line
    $content = $content -replace '\}\s*catch\s*\(\s*(\w+)\s*\)\s*\{\s*\}', '} catch ($1) {
      // TODO: Proper error handling
      debugPrint(''Error caught: $$$1'');
    }'

    if ($content -ne $originalContent) {
        # Check if debugPrint is imported, if not add import
        if ($content -notmatch "import 'package:flutter/foundation.dart';") {
            if ($content -match "(import '.*?';)") {
                # Add after first import
                $content = $content -replace "(import '.*?';)", "$1`nimport 'package:flutter/foundation.dart';"
            }
        }

        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Fixed empty catches in: $($_.Name)"
    }
}

Write-Host "Completed fixing empty catch blocks"