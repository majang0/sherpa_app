# 데드코드 제거 스크립트
Write-Host "🧹 데드코드 일괄 제거 시작..." -ForegroundColor Green

# 미사용 로컬 변수 제거
$files = @(
    "lib\features\climbing\presentation\widgets\badge_management_widget.dart",
    "lib\features\climbing\presentation\widgets\climbing_power_analysis_widget.dart",
    "lib\features\climbing\presentation\widgets\today_growth_widget.dart",
    "lib\features\climbing\presentation\widgets\user_stats_summary_widget.dart",
    "lib\features\daily_record\presentation\screens\exercise_dashboard_screen.dart"
)

# focus_timer_record_screen.dart 미사용 변수 제거
$focusFile = "lib\features\daily_record\presentation\screens\focus_timer_record_screen.dart"
if (Test-Path $focusFile) {
    $content = Get-Content $focusFile -Raw

    # currentType 미사용 변수 라인 제거
    $content = $content -replace ".*final currentType = .*\n", ""

    Set-Content $focusFile $content
    Write-Host "✅ focus_timer_record_screen.dart 정리 완료" -ForegroundColor Green
}

Write-Host "`n📊 analyzer 재실행 중..." -ForegroundColor Yellow
dart analyze lib --no-fatal-warnings 2>&1 | Select-String "unused|never" | Select-Object -First 10

Write-Host "`n✨ 데드코드 제거 완료!" -ForegroundColor Green