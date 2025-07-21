import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

// 타이머 상태 관리
class TimerNotifier extends StateNotifier<int> {
  TimerNotifier() : super(0);

  void setTime(int minutes) {
    state = minutes;
  }

  void increment() {
    state = state + 5;
  }

  void decrement() {
    if (state >= 5) {
      state = state - 5;
    }
  }
}

final exerciseTimerProvider = StateNotifierProvider<TimerNotifier, int>(
      (ref) => TimerNotifier(),
);

class ExerciseTimer extends ConsumerWidget {
  const ExerciseTimer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(exerciseTimerProvider);
    final timerNotifier = ref.read(exerciseTimerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운동 시간',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => timerNotifier.decrement(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingXL),
                  Column(
                    children: [
                      Text(
                        '$duration',
                        style: GoogleFonts.notoSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '분',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSizes.paddingXL),
                  IconButton(
                    onPressed: () => timerNotifier.increment(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [15, 30, 45, 60].map((minutes) {
                  return GestureDetector(
                    onTap: () => timerNotifier.setTime(minutes),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: duration == minutes
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${minutes}분',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: duration == minutes
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (duration > 0) ...[
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  '+ ${duration ~/ 5} XP',
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
}
