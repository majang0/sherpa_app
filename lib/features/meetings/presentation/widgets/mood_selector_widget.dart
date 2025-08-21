import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// 😊 기분 선택 위젯
class MoodSelectorWidget extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onMoodChanged;

  const MoodSelectorWidget({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
  });

  static const Map<String, Map<String, dynamic>> moods = {
    'very_happy': {
      'emoji': '😄',
      'label': '매우 좋음',
      'color': Color(0xFF10B981),
    },
    'happy': {
      'emoji': '😊',
      'label': '좋음',
      'color': Color(0xFF3B82F6),
    },
    'good': {
      'emoji': '🙂',
      'label': '괜찮음',
      'color': Color(0xFF8B5CF6),
    },
    'normal': {
      'emoji': '😐',
      'label': '보통',
      'color': Color(0xFF6B7280),
    },
    'tired': {
      'emoji': '😴',
      'label': '피곤함',
      'color': Color(0xFFEF4444),
    },
    'stressed': {
      'emoji': '😰',
      'label': '스트레스',
      'color': Color(0xFFF59E0B),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: moods.entries.map((entry) {
        final moodKey = entry.key;
        final moodData = entry.value;
        final isSelected = selectedMood == moodKey;

        return GestureDetector(
          onTap: () => onMoodChanged(moodKey),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? (moodData['color'] as Color).withValues(alpha: 0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? (moodData['color'] as Color)
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  moodData['emoji'] as String,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  moodData['label'] as String,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected 
                        ? (moodData['color'] as Color)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
