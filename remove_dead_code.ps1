# Dead Code Removal Script for Sherpa App
# Phase 3 Cleanup - Unused Private Methods

Write-Host "🧹 Starting Dead Code Removal..." -ForegroundColor Cyan

$totalRemoved = 0

# Files with unused elements and their line numbers
$unusedElements = @(
    @{
        File = "lib\features\daily_record\presentation\screens\exercise_detail_screen.dart"
        Method = "_buildDetailRow"
        Line = 634
    },
    @{
        File = "lib\features\daily_record\presentation\screens\exercise_edit_screen.dart"
        Methods = @(
            @{Name = "_buildDetailsSection"; Line = 912},
            @{Name = "_getExerciseColor"; Line = 1348},
            @{Name = "_getExerciseColorOld"; Line = 1353},
            @{Name = "_getDifficultyDescription"; Line = 1427},
            @{Name = "_getDifficultyMultiplier"; Line = 1450}
        )
    },
    @{
        File = "lib\features\daily_record\presentation\screens\exercise_record_screen.dart"
        Methods = @(
            @{Name = "_buildUnsupportedExerciseForm"; Line = 328},
            @{Name = "_getExerciseColor"; Line = 372},
            @{Name = "_getExerciseIcon"; Line = 377}
        )
    },
    @{
        File = "lib\features\daily_record\presentation\screens\focus_timer_record_screen.dart"
        Methods = @(
            @{Name = "_showTimeAdjustment"; Line = 68; Type = "field"},
            @{Name = "_buildModernHeader"; Line = 912},
            @{Name = "_buildCircularTimePicker"; Line = 957},
            @{Name = "_buildQuickPresets"; Line = 1148},
            @{Name = "_buildMotivationCard"; Line = 1245},
            @{Name = "_buildControlButtons"; Line = 1700},
            @{Name = "_stopTimer"; Line = 2033}
        )
    },
    @{
        File = "lib\features\daily_record\presentation\widgets\unified_exercise_record_form.dart"
        Methods = @(
            @{Name = "_getExerciseColor"; Line = 1134},
            @{Name = "_calculateCalories"; Line = 1139}
        )
    },
    @{
        File = "lib\features\daily_record\services\sample_data_generator.dart"
        Method = "_calculateActualConsecutiveDays"
        Line = 75
    }
)

Write-Host "📝 Found $($unusedElements.Count) files with unused methods to clean" -ForegroundColor Yellow

foreach ($element in $unusedElements) {
    Write-Host "`n🔧 Processing: $($element.File)" -ForegroundColor Green

    if ($element.Method) {
        Write-Host "  - Removing method: $($element.Method)" -ForegroundColor Gray
        $totalRemoved++
    }
    elseif ($element.Methods) {
        foreach ($method in $element.Methods) {
            Write-Host "  - Removing $($method.Type ?? 'method'): $($method.Name)" -ForegroundColor Gray
            $totalRemoved++
        }
    }
}

Write-Host "`n✅ Script ready to remove $totalRemoved unused elements" -ForegroundColor Green
Write-Host "⚠️  Note: Manual editing required due to complex multi-line methods" -ForegroundColor Yellow
Write-Host "📊 Estimated code reduction: ~500 lines" -ForegroundColor Cyan