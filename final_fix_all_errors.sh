#!/bin/bash

echo "Final comprehensive error fix..."

# Fix point_display_widget.dart - Remove const from EdgeInsets with isCompact
sed -i '28s/const EdgeInsets\.symmetric(/EdgeInsets.symmetric(/' lib/shared/widgets/point_display_widget.dart
sed -i '64s/const EdgeInsets\.symmetric(/EdgeInsets.symmetric(/' lib/shared/widgets/point_display_widget.dart

# Fix quest_card_v2_widget.dart - Remove const from EdgeInsets.only with index comparison
sed -i '659s/const EdgeInsets\.only(/EdgeInsets.only(/' lib/features/quests/presentation/widgets/quest_card_v2_widget.dart

# Fix sherpi_message_history_screen.dart
sed -i '125s/const //' lib/features/sherpi/chat/presentation/screens/sherpi_message_history_screen.dart

# Fix meeting_card_2025.dart - Multiple fixes
sed -i '295s/const //' lib/shared/widgets/components/molecules/meeting_card_2025.dart
sed -i '397s/const //' lib/shared/widgets/components/molecules/meeting_card_2025.dart

# Fix search_bar_2025.dart
sed -i '393s/const //' lib/shared/widgets/components/molecules/search_bar_2025.dart

# Fix sherpa_quick_filter_2025.dart - Multiple const removals
sed -i '332s/const //' lib/shared/widgets/components/molecules/sherpa_quick_filter_2025.dart
sed -i '356s/const //' lib/shared/widgets/components/molecules/sherpa_quick_filter_2025.dart
sed -i '394s/const //' lib/shared/widgets/components/molecules/sherpa_quick_filter_2025.dart
sed -i '463s/const //' lib/shared/widgets/components/molecules/sherpa_quick_filter_2025.dart
sed -i '490s/const //' lib/shared/widgets/components/molecules/sherpa_quick_filter_2025.dart
sed -i '526s/const //' lib/shared/widgets/components/molecules/sherpa_quick_filter_2025.dart

# Fix sherpa_smart_filter_2025.dart - Multiple const removals
sed -i '320s/const //' lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart
sed -i '347s/const //' lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart
sed -i '414s/const //' lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart
sed -i '415s/const //' lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart
sed -i '440s/const //' lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart
sed -i '542s/const //' lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart
sed -i '543s/const //' lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart
sed -i '571s/const //' lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart
sed -i '593s/const //' lib/shared/widgets/components/molecules/sherpa_smart_filter_2025.dart

echo "Done! Checking error count..."
flutter analyze 2>&1 | grep "  error -" | wc -l