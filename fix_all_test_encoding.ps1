# Find all test files and fix their encoding
$testPath = "C:\sherpa_app\test"
Write-Host "Finding all test files in: $testPath"

$testFiles = Get-ChildItem -Path $testPath -Filter "*.dart" -Recurse -File

$fixedCount = 0
$errorCount = 0

foreach ($file in $testFiles) {
    try {
        # Try to read the file
        $content = Get-Content -Path $file.FullName -Raw -Encoding Default

        # Write back as UTF-8 without BOM
        $utf8NoBOM = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)

        $fixedCount++
        Write-Host "Fixed: $($file.Name)"
    } catch {
        Write-Host "Error with file: $($file.FullName) - $_" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host "`nSummary:"
Write-Host "  Total files processed: $($testFiles.Count)"
Write-Host "  Successfully fixed: $fixedCount"
Write-Host "  Errors: $errorCount"
Write-Host "Encoding fix completed"