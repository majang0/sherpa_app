$files = @(
    'C:\sherpa_app\test\features\sherpi\managers\openai_sherpi_manager_test.dart',
    'C:\sherpa_app\test\features\sherpi\managers\sherpi_managers_test.dart'
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Processing: $file"
        try {
            # Read file with current encoding and write back as UTF-8 without BOM
            $content = Get-Content -Path $file -Raw -Encoding Default

            # Write back as UTF-8 without BOM
            $utf8NoBOM = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($file, $content, $utf8NoBOM)

            Write-Host "  Fixed encoding for file"
        } catch {
            Write-Host "  Error processing file: $_"
        }
    } else {
        Write-Host "  File not found: $file"
    }
}

Write-Host "Encoding fix completed"