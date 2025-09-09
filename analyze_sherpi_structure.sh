#!/bin/bash

echo "====================================="
echo "Sherpi System Structure Analysis"
echo "====================================="

echo ""
echo "1. SHERPI FILES IN CORE:"
echo "------------------------"
echo "core/constants/:"
ls -la lib/core/constants/sherpi* 2>/dev/null || echo "  No sherpi files"

echo ""
echo "core/ai/:"
ls -la lib/core/ai/*sherpi* 2>/dev/null || echo "  No sherpi AI files"
ls -la lib/core/ai/smart_sherpi* 2>/dev/null || echo "  No smart_sherpi files"

echo ""
echo "2. SHERPI FEATURE MODULE:"
echo "-------------------------"
find lib/features/sherpi -type f -name "*.dart" 2>/dev/null | head -20

echo ""
echo "3. SHERPI IN SHARED:"
echo "--------------------"
echo "shared/providers/:"
ls -la lib/shared/providers/*sherpi* 2>/dev/null || echo "  No sherpi providers"

echo ""
echo "shared/widgets/:"
ls -la lib/shared/widgets/*sherpi* 2>/dev/null || echo "  No sherpi widgets"
ls -la lib/shared/widgets/global_sherpi* 2>/dev/null || echo "  No global_sherpi files"

echo ""
echo "4. FILES IMPORTING SHERPI:"
echo "--------------------------"
echo "Files importing sherpi_dialogues.dart:"
grep -l "sherpi_dialogues\.dart" lib/**/*.dart 2>/dev/null | wc -l
echo ""
echo "Files importing sherpi_emotions.dart:"
grep -l "sherpi_emotions\.dart" lib/**/*.dart 2>/dev/null | wc -l

echo ""
echo "5. CIRCULAR DEPENDENCY CHECK:"
echo "-----------------------------"
echo "sherpi_emotions imports:"
grep "^import" lib/core/constants/sherpi_emotions.dart 2>/dev/null | grep -v "dart:"

echo ""
echo "sherpi_dialogues imports:"
grep "^import" lib/core/constants/sherpi_dialogues.dart 2>/dev/null | head -10

echo ""
echo "6. SHERPI AI MANAGERS:"
echo "----------------------"
ls -la lib/core/ai/*dialogue* lib/core/ai/*manager* 2>/dev/null | grep -v "^d"

echo ""
echo "====================================="
echo "Analysis Complete"
echo "====================================="