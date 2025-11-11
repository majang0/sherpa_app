import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/widgets/sherpa_card.dart';
import 'package:sherpa_app/features/goals/models/routine_model.dart';
import 'package:sherpa_app/features/goals/providers/routine_provider.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/routine_modal_widget.dart';

/// 루틴 카드 위젯
///
/// 개별 루틴을 표시하고 체크 기능을 제공하는 카드
class RoutineCardWidget extends ConsumerWidget {
  final RoutineModel routine;

  const RoutineCardWidget({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChecked = routine.isCheckedToday();

    return SherpaCard(
      child: InkWell(
        onTap: () {
          _showRoutineDetail(context, ref);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 체크박스
              _buildCheckbox(ref, isChecked),
              const SizedBox(width: 16),

              // 루틴 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 + 시간대
                    Row(
                      children: [
                        _buildCategoryChip(),
                        const SizedBox(width: 8),
                        _buildTimeChip(),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 루틴 이름
                    Text(
                      routine.name,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isChecked
                            ? ModernColors.textSecondary
                            : ModernColors.textPrimary,
                        decoration:
                            isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 빈도
                    _buildFrequencyChip(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 체크박스
  Widget _buildCheckbox(WidgetRef ref, bool isChecked) {
    return GestureDetector(
      onTap: () {
        if (isChecked) {
          ref.read(routineProvider.notifier).uncheckRoutine(routine.id);
        } else {
          ref.read(routineProvider.notifier).checkRoutine(routine.id);
        }
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChecked ? _getCategoryColor() : Colors.transparent,
          border: Border.all(
            color: _getCategoryColor(),
            width: 2,
          ),
        ),
        child: isChecked
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              )
            : null,
      ),
    );
  }

  /// 카테고리 칩
  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        routine.category,
        style: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getCategoryColor(),
        ),
      ),
    );
  }

  /// 시간대 칩
  Widget _buildTimeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ModernColors.gray100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTimeIcon(),
            size: 12,
            color: ModernColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            routine.timePreference ?? '시간 미정',
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 빈도 칩
  Widget _buildFrequencyChip() {
    String frequencyText;
    if (routine.frequency == '요일선택') {
      // weekdays are already string names like '월', '화', etc.
      frequencyText = routine.weekdays.join(', ');
    } else {
      frequencyText = routine.frequency;
    }

    return Text(
      frequencyText,
      style: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: ModernColors.textSecondary,
      ),
    );
  }

  /// 카테고리별 색상
  Color _getCategoryColor() {
    switch (routine.category) {
      case '운동':
        return ModernColors.exercise; // 오렌지
      case '문화':
        return ModernColors.reading; // 그린
      case '학습':
        return ModernColors.primary; // 푸른색
      case '건강':
        return ModernColors.error; // 붉은색
      case '기타':
        return ModernColors.meeting; // 시안
      default:
        return ModernColors.meeting;
    }
  }

  /// 시간대 아이콘
  IconData _getTimeIcon() {
    switch (routine.timePreference) {
      case '아침':
        return Icons.wb_sunny_outlined;
      case '점심':
        return Icons.wb_sunny;
      case '저녁':
        return Icons.wb_twilight;
      case '밤':
        return Icons.nightlight_outlined;
      case '아무때나':
      default:
        return Icons.schedule;
    }
  }

  /// 루틴 상세 모달 표시
  void _showRoutineDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoutineModalWidget(routine: routine),
    );
  }
}
