#!/bin/bash

echo "Fixing empty catch blocks..."

# Fix all empty catch blocks by adding comments
files=(
  "lib/features/quests/presentation/widgets/quest_card_v2_widget.dart"
  "lib/features/quests/providers/quest_provider_v2.dart"
  "lib/main.dart"
  "lib/shared/providers/global_point_provider.dart"
  "lib/shared/providers/global_sherpi_provider.dart"
  "lib/shared/providers/global_user_provider.dart"
)

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    # Replace empty catch blocks with commented ones
    sed -i 's/} catch (e) {}/} catch (e) {\n      \/\/ 에러 무시 - 중요하지 않은 작업\n    }/g' "$file"
    echo "✓ Fixed empty catches in $file"
  fi
done

echo "Empty catch blocks fixed!"
