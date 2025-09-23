# Batch Dead Code Removal Script for Sherpa App
# Phase 3 Cleanup - Unused Private Methods

Write-Host "🧹 Starting Batch Dead Code Removal..." -ForegroundColor Cyan

# Get all unused elements
$analyzer_output = dart analyze 2>&1 | Select-String "(unused_element|unused_field|dead_code)"

$totalCount = $analyzer_output.Count
Write-Host "📊 Found $totalCount unused elements to clean" -ForegroundColor Yellow

# Group by file
$fileGroups = @{}
foreach ($warning in $analyzer_output) {
    if ($warning -match 'lib\\(.+?)\.dart:(\d+):(\d+) - .* ''(.+?)'' .* - (unused_element|unused_field|dead_code)') {
        $filePath = "lib\$($matches[1]).dart"
        $lineNum = [int]$matches[2]
        $elementName = $matches[4]
        $warningType = $matches[5]

        if (-not $fileGroups.ContainsKey($filePath)) {
            $fileGroups[$filePath] = @()
        }

        $fileGroups[$filePath] += @{
            Line = $lineNum
            Name = $elementName
            Type = $warningType
        }
    }
}

Write-Host "`n📁 Files with unused elements:" -ForegroundColor Green
foreach ($file in $fileGroups.Keys | Sort-Object) {
    $count = $fileGroups[$file].Count
    Write-Host "  $file : $count unused elements" -ForegroundColor Gray
}

Write-Host "`n✅ Analysis complete. Manual editing required for complex removal." -ForegroundColor Green
Write-Host "💡 Tip: Use MultiEdit tool for batch removal in each file" -ForegroundColor Cyan