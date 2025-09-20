# PowerShell script to fix sherpi_relationship_model imports
$files = @(
    "lib\core\ai\managers\openai_sherpi_manager.dart",
    "lib\features\sherpi\domain\services\sherpi_insight_repository.dart",
    "lib\core\ai\sources\openai_dialogue_source.dart",
    "lib\core\ai\services\activity_prompt_templates.dart",
    "lib\core\ai\managers\static_sherpi_manager.dart",
    "lib\core\ai\managers\sherpi_message_manager.dart"
)

$totalFixed = 0
$errors = @()

foreach ($file in $files) {
    if (Test-Path $file) {
        try {
            $content = Get-Content $file -Raw
            $originalContent = $content

            # Replace the incorrect import path with the correct one
            $content = $content -replace "import 'package:sherpa_app/features/sherpi/domain/models/sherpi_relationship_model\.dart';", "import 'package:sherpa_app/shared/models/sherpi_relationship_model.dart';"

            if ($content -ne $originalContent) {
                $content | Set-Content $file -NoNewline
                Write-Host "✅ Fixed import in: $file" -ForegroundColor Green
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