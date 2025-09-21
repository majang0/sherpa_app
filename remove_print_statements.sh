#!/bin/bash

# Script to remove all remaining print statements
# and replace them with LoggerService calls

echo "Starting print statement removal..."

# List of files with print statements
files=(
  "lib/features/sherpi/analysis/services/ai_insight_generator.dart"
  "lib/core/config/api_config.dart"
  "lib/features/sherpi/chat/providers/enhanced_chat_conversation_provider.dart"
  "lib/features/sherpi/chat/providers/chat_conversation_provider.dart"
  "lib/shared/widgets/dialogs/analysis_pages/comprehensive_analysis_page.dart"
  "lib/shared/widgets/dialogs/analysis_pages/exercise_analysis_page.dart"
  "lib/shared/providers/notification_provider.dart"
  "lib/shared/providers/global_climbing_provider.dart"
  "lib/features/sherpi/relationship/services/memory_management_service.dart"
  "lib/features/sherpi/relationship/services/memory_creation_service.dart"
  "lib/features/sherpi/relationship/services/growth_story_service.dart"
  "lib/features/sherpi/relationship/providers/relationship_provider.dart"
  "lib/features/sherpi/relationship/providers/memory_provider.dart"
  "lib/features/sherpi/relationship/providers/growth_story_provider.dart"
  "lib/features/sherpi/emotion/providers/emotion_state_provider.dart"
  "lib/features/sherpi/emotion/providers/emotion_analysis_provider.dart"
  "lib/features/profile/presentation/screens/my_info_screen.dart"
  "lib/features/home/presentation/widgets/personalized_growth_dashboard_widget.dart"
  "lib/features/daily_record/widgets/meeting_full_view_widget.dart"
  "lib/features/daily_record/presentation/screens/focus_timer_record_screen.dart"
  "lib/features/climbing/presentation/widgets/user_stats_summary_widget.dart"
  "lib/features/climbing/presentation/widgets/ascent_dashboard_widget.dart"
  "lib/features/climbing/presentation/widgets/animated_rpg_level_card.dart"
)

# Process each file
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "Processing $file..."

    # Check if LoggerService is already imported
    if ! grep -q "import.*logger_service.dart" "$file"; then
      # Add LoggerService import after the first package import
      sed -i "/^import 'package:/a import 'package:sherpa_app/core/utils/logger_service.dart';" "$file"
    fi

    # Replace print( with LoggerService.debug(
    sed -i "s/print(/LoggerService.debug(/g" "$file"

    # Replace specific patterns for better log levels
    sed -i "s/LoggerService.debug('ERROR/LoggerService.error('/g" "$file"
    sed -i "s/LoggerService.debug('⚠/LoggerService.warning('⚠/g" "$file"
    sed -i "s/LoggerService.debug('✅/LoggerService.info('✅/g" "$file"
    sed -i "s/LoggerService.debug('🎯/LoggerService.info('🎯/g" "$file"
    sed -i "s/LoggerService.debug('\[ERROR\]/LoggerService.error('/g" "$file"
    sed -i "s/LoggerService.debug('\[WARNING\]/LoggerService.warning('/g" "$file"
    sed -i "s/LoggerService.debug('\[INFO\]/LoggerService.info('/g" "$file"

    echo "✓ Completed $file"
  fi
done

echo "Print statement removal complete!"
echo "Now checking for any remaining print statements..."

# Verify no print statements remain
remaining=$(grep -r "print(" lib --include="*.dart" | wc -l)
if [ "$remaining" -gt 0 ]; then
  echo "Warning: $remaining print statements still found"
  grep -r "print(" lib --include="*.dart" | head -5
else
  echo "Success: All print statements have been removed!"
fi