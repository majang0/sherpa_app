#!/bin/bash

# Files with unused imports
declare -A unused_imports

# Map file to line numbers of unused imports
unused_imports["lib/core/config/api_config.dart"]="import 'package:flutter/foundation.dart';"
unused_imports["lib/core/utils/phase1_performance_benchmark.dart"]="import '../../core/constants/sherpi_dialogues.dart';"

# Remove each unused import
echo "Removing unused imports..."

# api_config.dart
sed -i "/import 'package:flutter\/foundation.dart';/d" lib/core/config/api_config.dart
echo "✓ Removed unused import from api_config.dart"

# phase1_performance_benchmark.dart
sed -i "/import '..\/..\/core\/constants\/sherpi_dialogues.dart';/d" lib/core/utils/phase1_performance_benchmark.dart
echo "✓ Removed unused import from phase1_performance_benchmark.dart"

# animated_rpg_level_card.dart - multiple unused imports
sed -i "/import '..\/..\/..\/..\/core\/constants\/game_constants.dart';/d" lib/features/climbing/presentation/widgets/animated_rpg_level_card.dart
sed -i "/import '..\/..\/..\/..\/shared\/providers\/global_sherpi_provider.dart';/d" lib/features/climbing/presentation/widgets/animated_rpg_level_card.dart
sed -i "/import '..\/..\/..\/..\/shared\/providers\/global_point_provider.dart';/d" lib/features/climbing/presentation/widgets/animated_rpg_level_card.dart
sed -i "/import '..\/..\/..\/..\/shared\/widgets\/sherpa_card.dart';/d" lib/features/climbing/presentation/widgets/animated_rpg_level_card.dart
echo "✓ Removed 4 unused imports from animated_rpg_level_card.dart"

# ascent_dashboard_widget.dart
sed -i "/import 'dart:math';/d" lib/features/climbing/presentation/widgets/ascent_dashboard_widget.dart
sed -i "/import '..\/..\/..\/..\/shared\/widgets\/sherpa_card.dart';/d" lib/features/climbing/presentation/widgets/ascent_dashboard_widget.dart
sed -i "/import '..\/..\/..\/..\/shared\/providers\/global_point_provider.dart';/d" lib/features/climbing/presentation/widgets/ascent_dashboard_widget.dart
sed -i "/import '..\/..\/..\/..\/shared\/providers\/global_sherpi_provider.dart';/d" lib/features/climbing/presentation/widgets/ascent_dashboard_widget.dart
echo "✓ Removed 4 unused imports from ascent_dashboard_widget.dart"

# badge_management_widget.dart
sed -i "/import '..\/..\/..\/..\/shared\/providers\/global_game_provider.dart';/d" lib/features/climbing/presentation/widgets/badge_management_widget.dart
echo "✓ Removed unused import from badge_management_widget.dart"

# today_growth_widget.dart
sed -i "/import 'dart:math';/d" lib/features/climbing/presentation/widgets/today_growth_widget.dart
echo "✓ Removed unused import from today_growth_widget.dart"

# user_stats_summary_widget.dart
sed -i "/import '..\/..\/..\/..\/shared\/widgets\/sherpa_card.dart';/d" lib/features/climbing/presentation/widgets/user_stats_summary_widget.dart
echo "✓ Removed unused import from user_stats_summary_widget.dart"

# climbing_providers.dart
sed -i "/import '..\/..\/..\/shared\/providers\/global_game_provider.dart';/d" lib/features/climbing/providers/climbing_providers.dart
echo "✓ Removed unused import from climbing_providers.dart"

# social_exploration_header_widget.dart
sed -i "/import '..\/..\/..\/..\/shared\/models\/global_user_model.dart';/d" lib/features/community/presentation/widgets/social_exploration_header_widget.dart
echo "✓ Removed unused import from social_exploration_header_widget.dart"

# exercise_selection_screen.dart
sed -i "/import '..\/..\/..\/..\/shared\/widgets\/sherpa_clean_app_bar.dart';/d" lib/features/daily_record/presentation/screens/exercise_selection_screen.dart
echo "✓ Removed unused import from exercise_selection_screen.dart"

# focus_timer_record_screen.dart
sed -i "/import '..\/..\/..\/..\/shared\/models\/point_system_model.dart';/d" lib/features/daily_record/presentation/screens/focus_timer_record_screen.dart
echo "✓ Removed unused import from focus_timer_record_screen.dart"

# meeting_log_detail_screen.dart
sed -i "/import '..\/..\/..\/..\/shared\/widgets\/sherpa_clean_app_bar.dart';/d" lib/features/daily_record/presentation/screens/meeting_log_detail_screen.dart
echo "✓ Removed unused import from meeting_log_detail_screen.dart"

# reading_detail_screen.dart
sed -i "/import '..\/..\/..\/..\/shared\/providers\/global_user_provider.dart';/d" lib/features/daily_record/presentation/screens/reading_detail_screen.dart
echo "✓ Removed unused import from reading_detail_screen.dart"

# meeting_full_view_widget.dart
sed -i "/import '..\/presentation\/screens\/meeting_edit_screen.dart';/d" lib/features/daily_record/widgets/meeting_full_view_widget.dart
echo "✓ Removed unused import from meeting_full_view_widget.dart"

echo "Total files processed: 14"
