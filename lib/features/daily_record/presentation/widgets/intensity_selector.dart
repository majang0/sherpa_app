import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class IntensitySelector extends StatelessWidget {
  final int selectedIntensity;
  final Function(int) onIntensityChanged;

  const IntensitySelector({
    Key? key,
    required this.selectedIntensity,
    required this.onIntensityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 운동 강도',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Text(
                '오늘 가장 기억에 남는 운동은...',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final intensity = index + 1;
                  final isSelected = selectedIntensity == intensity;

                  return GestureDetector(
                    onTap: () => onIntensityChanged(intensity),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getIntensityEmoji(intensity),
                          style: TextStyle(
                            fontSize: isSelected ? 28 : 24,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                _getIntensityText(selectedIntensity),
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (selectedIntensity > 0) ...[
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  '+ ${selectedIntensity * 10} XP',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getIntensityEmoji(int intensity) {
    switch (intensity) {
      case 1: return '😌';
      case 2: return '🙂';
      case 3: return '😊';
      case 4: return '😤';
      case 5: return '🔥';
      default: return '😊';
    }
  }

  String _getIntensityText(int intensity) {
    switch (intensity) {
      case 1: return '가벼운 운동이었어요';
      case 2: return '적당한 운동이었어요';
      case 3: return '좋은 운동이었어요';
      case 4: return '힘든 운동이었어요';
      case 5: return '정말 격렬한 운동이었어요!';
      default: return '강도를 선택해주세요';
    }
  }
}
