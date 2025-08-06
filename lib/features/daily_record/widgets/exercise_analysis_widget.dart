import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/record_colors.dart';
import '../../../shared/providers/global_user_provider.dart';

/// 운동 분석 위젯
class ExerciseAnalysisWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    final exerciseLogs = user.dailyRecords.exerciseLogs;

    // 최근 7일 운동 기록
    final now = DateTime.now();
    final recentLogs = exerciseLogs.where((log) {
      final daysDiff = now.difference(log.date).inDays;
      return daysDiff >= 0 && daysDiff < 7;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RecordColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RecordColors.exerciseLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: RecordColors.exerciseLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: RecordColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '주간 운동 분석',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: RecordColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 주간 통계
          _buildWeeklyStats(recentLogs),

          const SizedBox(height: 20),

          // 주간 운동 시간 차트
          _buildWeeklyTimeChart(recentLogs),

          if (recentLogs.isNotEmpty) ...[
            const SizedBox(height: 20),

            // 운동 유형별 분석
            _buildExerciseTypeAnalysis(recentLogs),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyStats(List<dynamic> exerciseLogs) {
    // ✅ fold 메서드 타입 수정
    final totalMinutes = exerciseLogs.fold<int>(0, (sum, log) => sum + (log.durationMinutes as int));
    final totalDays = exerciseLogs.length;
    final avgMinutes = totalDays > 0 ? (totalMinutes / totalDays) : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer,
            title: '총 운동시간',
            value: '${totalMinutes}분',
            color: RecordColors.exercise,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            title: '운동 일수',
            value: '${totalDays}일',
            color: RecordColors.focus,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            title: '일평균',
            value: '${avgMinutes.toStringAsFixed(0)}분',
            color: RecordColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), // ✅ withOpacity → withValues 수정
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2), // ✅ withOpacity → withValues 수정
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: RecordColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: RecordColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTimeChart(List<dynamic> exerciseLogs) {
    // 주간 목표 시간 (WHO 권장)
    final weeklyGoal = 150; // 주간 목표 150분 (WHO 권장)
    final weeklyMinutes = exerciseLogs.fold<int>(0, (sum, log) => sum + (log.durationMinutes as int)); // ✅ 타입 수정
    final progress = (weeklyMinutes / weeklyGoal).clamp(0.0, 1.0);
    final isGoalAchieved = weeklyMinutes >= weeklyGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGoalAchieved
              ? [
            RecordColors.success.withValues(alpha: 0.1), // ✅ withOpacity → withValues 수정
            RecordColors.success.withValues(alpha: 0.05), // ✅ withOpacity → withValues 수정
          ]
              : [
            RecordColors.exercise.withValues(alpha: 0.1), // ✅ withOpacity → withValues 수정
            RecordColors.exercise.withValues(alpha: 0.05), // ✅ withOpacity → withValues 수정
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGoalAchieved
              ? RecordColors.success.withValues(alpha: 0.2) // ✅ withOpacity → withValues 수정
              : RecordColors.exercise.withValues(alpha: 0.2), // ✅ withOpacity → withValues 수정
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '주간 운동 목표',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: RecordColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weeklyMinutes}분 / ${weeklyGoal}분',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: RecordColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isGoalAchieved ? RecordColors.success : RecordColors.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isGoalAchieved ? '목표 달성!' : '${((progress * 100).toStringAsFixed(0))}%',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 진행바
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: RecordColors.progressBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: isGoalAchieved ? RecordColors.success : RecordColors.exercise,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // WHO 권장 정보
          Text(
            'WHO 권장: 주 150분 이상 중강도 운동',
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: RecordColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypeAnalysis(List<dynamic> exerciseLogs) {
    // 운동 유형별 시간 집계
    final Map<String, int> typeMinutes = {};
    for (final log in exerciseLogs) {
      final type = log.exerciseType as String;
      final minutes = log.durationMinutes as int;
      typeMinutes[type] = (typeMinutes[type] ?? 0) + minutes;
    }

    // 상위 3개 운동 유형
    final sortedTypes = typeMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTypes = sortedTypes.take(3).toList();

    if (topTypes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RecordColors.progressBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '운동 기록이 없습니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: RecordColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운동 유형별 분석',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: RecordColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...topTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final typeEntry = entry.value;
          final totalMinutes = typeMinutes.values.fold<int>(0, (sum, minutes) => sum + minutes); // ✅ 타입 수정
          final percentage = (typeEntry.value / totalMinutes * 100);

          final colors = [
            RecordColors.exercise,
            RecordColors.focus,
            RecordColors.meeting,
          ];

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    typeEntry.key,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: RecordColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${typeEntry.value}분 (${percentage.toStringAsFixed(0)}%)',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: RecordColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}