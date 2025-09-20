# PowerShell script to fix test file imports
$testFiles = @(
    "test\features\sherpi\managers\openai_sherpi_manager_test.dart",
    "test\features\sherpi\managers\sherpi_managers_test.dart",
    "test\features\sherpi\providers\global_ai_recommendation_provider_test.dart",
    "test\features\sherpi\providers\global_sherpi_provider_test.dart"
)

$totalFixed = 0
$errors = @()

foreach ($file in $testFiles) {
    if (Test-Path $file) {
        try {
            $content = Get-Content $file -Raw
            $originalContent = $content
            $changed = $false

            # Fix sherpi_relationship_model import path
            if ($content -match "import 'package:sherpa_app/features/sherpi/domain/models/sherpi_relationship_model\.dart';") {
                $content = $content -replace "import 'package:sherpa_app/features/sherpi/domain/models/sherpi_relationship_model\.dart';", "import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';"
                $changed = $true
            }

            # Fix manager imports - these should work
            if ($content -match "import 'package:sherpa_app/core/ai/managers/openai_sherpi_manager\.dart';") {
                # The import is already correct, but analyzer has issues
                # No change needed here
            }

            if ($changed) {
                $content | Set-Content $file -NoNewline
                Write-Host "✅ Fixed imports in: $file" -ForegroundColor Green
                $totalFixed++
            } else {
                Write-Host "ℹ️ No changes needed in: $file" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "❌ Error processing $file : $_" -ForegroundColor Red
            $errors += "$file : $_"
        }
    } else {
        Write-Host "⚠️ File not found: $file" -ForegroundColor Yellow
    }
}

Write-Host "`n📊 Summary:" -ForegroundColor Cyan
Write-Host "Files fixed: $totalFixed" -ForegroundColor Green
if ($errors.Count -gt 0) {
    Write-Host "`n❌ Errors encountered:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}