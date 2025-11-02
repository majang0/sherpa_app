// lib/features/daily_record/widgets/enhanced_meeting_calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_colors.dart';
import '../../../core/constants/meeting_categories.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import 'meeting_full_view_widget.dart';
import '../presentation/screens/meeting_log_detail_screen.dart';
import '../presentation/screens/meeting_edit_screen.dart';

class EnhancedMeetingCalendarWidget extends ConsumerStatefulWidget {
  const EnhancedMeetingCalendarWidget({super.key});

  @override
  ConsumerState<EnhancedMeetingCalendarWidget> createState() =>
      _EnhancedMeetingCalendarWidgetState();
}

class _EnhancedMeetingCalendarWidgetState
    extends ConsumerState<EnhancedMeetingCalendarWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final meetingLogs = user.dailyRecords.meetingLogs;

    // 날짜순으로 정렬 (최신순)
    final sortedMeetingLogs = List<MeetingLog>.from(meetingLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ModernColors.textTertiary.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '모임 기록',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        Text(
                          '다양한 모임 활동을 관리하세요',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 추가 버튼 - 모임 탭으로 안내
                  GestureDetector(
                    onTap: () {
                      HapticFeedbackManager.mediumImpact();
                      _showMeetingNavigationGuide(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 월간 통계 및 인사이트
              _buildMonthlyInsights(sortedMeetingLogs),

              const SizedBox(height: 20),

              // 카테고리별 분석
              _buildCategoryAnalysis(sortedMeetingLogs),

              const SizedBox(height: 20),

              // 주간 모임 현황
              _buildWeeklyMeetings(sortedMeetingLogs),

              const SizedBox(height: 16),

              // 전체 모임 보기 버튼
              _buildFullViewButton(),

              const SizedBox(height: 20),

              // 최근 모임 기록들
              if (sortedMeetingLogs.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      '최근 모임 기록',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(최신순)',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...sortedMeetingLogs
                    .take(3)
                    .map((meeting) => _buildMeetingItem(meeting)),
              ] else
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStats(List<MeetingLog> meetingLogs) {
    final today = DateTime.now();
    final todayMeetings =
        meetingLogs.where((log) => _isSameDay(log.date, today)).toList();
    final sessionCount = todayMeetings.length;
    final avgSatisfaction = todayMeetings.isEmpty
        ? 0.0
        : todayMeetings.fold<double>(0, (sum, log) => sum + log.satisfaction) /
            todayMeetings.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            const Color(0xFF7C3AED).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '👥',
              '$sessionCount개',
              '오늘 모임',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: ModernColors.textTertiary.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '⭐',
              avgSatisfaction > 0
                  ? '${avgSatisfaction.toStringAsFixed(1)}/5.0'
                  : '-',
              '평균 만족도',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // 월간 통계 및 인사이트
  Widget _buildMonthlyInsights(List<MeetingLog> meetingLogs) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);

    // 이번 달 모임 데이터
    final currentMonthMeetings = meetingLogs
        .where((log) =>
            log.date.year == currentMonth.year &&
            log.date.month == currentMonth.month)
        .toList();

    // 지난 달 모임 데이터
    final previousMonthMeetings = meetingLogs
        .where((log) =>
            log.date.year == previousMonth.year &&
            log.date.month == previousMonth.month)
        .toList();

    final currentCount = currentMonthMeetings.length;
    final previousCount = previousMonthMeetings.length;
    final growthRate = previousCount > 0
        ? ((currentCount - previousCount) / previousCount * 100).round()
        : 0;

    final avgSatisfaction = currentMonthMeetings.isEmpty
        ? 0.0
        : currentMonthMeetings.fold<double>(
                0, (sum, log) => sum + log.satisfaction) /
            currentMonthMeetings.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            const Color(0xFF7C3AED).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 달 모임 현황',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '📊',
                  '$currentCount개',
                  '모임 횟수',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: ModernColors.textTertiary.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  '⭐',
                  avgSatisfaction > 0
                      ? avgSatisfaction.toStringAsFixed(1)
                      : '-',
                  '평균 만족도',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: ModernColors.textTertiary.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  growthRate > 0
                      ? '📈'
                      : growthRate < 0
                          ? '📉'
                          : '➖',
                  '${growthRate > 0 ? '+' : ''}$growthRate%',
                  '전월 대비',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 카테고리별 분석
  Widget _buildCategoryAnalysis(List<MeetingLog> meetingLogs) {
    final now = DateTime.now();
    final currentMonthMeetings = meetingLogs
        .where(
            (log) => log.date.year == now.year && log.date.month == now.month)
        .toList();

    if (currentMonthMeetings.isEmpty) {
      return const SizedBox.shrink();
    }

    // 카테고리별 통계
    final categoryStats = <String, Map<String, dynamic>>{};
    for (final meeting in currentMonthMeetings) {
      final category = meeting.category;
      if (!categoryStats.containsKey(category)) {
        categoryStats[category] = {
          'count': 0,
          'totalSatisfaction': 0.0,
          'emoji': MeetingCategories.getEmoji(category),
          'color': MeetingCategories.getColor(category),
        };
      }
      categoryStats[category]!['count'] += 1;
      categoryStats[category]!['totalSatisfaction'] += meeting.satisfaction;
    }

    // 가장 많은 카테고리 찾기
    final topCategory = categoryStats.entries
        .reduce((a, b) => a.value['count'] > b.value['count'] ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.textTertiary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카테고리별 활동',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: topCategory.value['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    topCategory.value['emoji'],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '가장 활발한 분야: ${topCategory.key}',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${topCategory.value['count']}회 참여 • 평균 만족도 ${(topCategory.value['totalSatisfaction'] / topCategory.value['count']).toStringAsFixed(1)}',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMeetings(List<MeetingLog> meetingLogs) {
    final now = DateTime.now();
    // 퀘스트 시스템과 동일한 주간 계산 (월요일~일요일)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekDays =
        List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.textTertiary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이번 주 모임 현황',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textSecondary,
                ),
              ),
              // 주간 모임 수 표시 (퀘스트 디버깅용)
              Builder(
                builder: (context) {
                  final weekStart =
                      now.subtract(Duration(days: now.weekday - 1));
                  final weekEnd = weekStart.add(const Duration(days: 6));
                  final weekMeetings = meetingLogs.where((log) {
                    // 이번 주 월요일 0시부터 일요일 23시59분까지만 포함
                    final logDate =
                        DateTime(log.date.year, log.date.month, log.date.day);
                    final startDate = DateTime(
                        weekStart.year, weekStart.month, weekStart.day);
                    final endDate =
                        DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
                    return !logDate.isBefore(startDate) &&
                        !logDate.isAfter(endDate);
                  }).length;

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ModernColors.textTertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ModernColors.textTertiary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$weekMeetings개',
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map((day) => _buildWeeklyDay(day, meetingLogs))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDay(DateTime day, List<MeetingLog> meetingLogs) {
    final dayMeetings =
        meetingLogs.where((log) => _isSameDay(log.date, day)).toList();
    final isToday = _isSameDay(day, DateTime.now());
    final weekdayName = ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];

    return GestureDetector(
      onTap: () {
        // 모임이 있는 날짜만 클릭 가능
        if (dayMeetings.isNotEmpty) {
          HapticFeedbackManager.lightImpact();
          _showDateMeetingModal(day, dayMeetings);
        }
      },
      child: Container(
        width: 36,
        height: 60,
        decoration: BoxDecoration(
          color: isToday
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? const Color(0xFF8B5CF6)
                : ModernColors.textTertiary.withValues(alpha: 0.2),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekdayName,
              style: GoogleFonts.notoSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.day}',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? const Color(0xFF8B5CF6)
                    : ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            if (dayMeetings.isNotEmpty) ...[
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${dayMeetings.length}',
                    style: GoogleFonts.notoSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ModernColors.textTertiary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingItem(MeetingLog meeting) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingLogDetailScreen(meeting: meeting),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ModernColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ModernColors.textTertiary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 카테고리 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: MeetingCategories.getColor(meeting.category)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: MeetingCategories.getColor(meeting.category)
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  MeetingCategories.getEmoji(meeting.category),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 모임 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meeting.meetingName,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        meeting.moodIcon,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        meeting.category,
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${meeting.date.month}/${meeting.date.day}',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      ...List.generate(
                        meeting.satisfaction.round(),
                        (index) => const Icon(
                          Icons.star,
                          size: 10,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.05),
            const Color(0xFF7C3AED).withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 48,
              color: Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '아직 모임 기록이 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다양한 모임에 참여하고\n소중한 추억을 남겨보세요',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedbackManager.mediumImpact();
              Navigator.pushNamed(context, '/', arguments: 3);
            },
            icon: const Icon(Icons.explore, size: 18),
            label: Text(
              '모임 둘러보기',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 모임 탭으로 안내하는 친절한 가이드 모달
  void _showMeetingNavigationGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: ModernColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 16),

            // 일러스트 아이콘
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups,
                size: 48,
                color: Color(0xFF8B5CF6),
              ),
            ),

            const SizedBox(height: 24),

            // 안내 텍스트
            Text(
              '모임에 참여하고 싶으신가요?',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '하단의 모임 탭에서 다양한 모임을 찾아보고\n참여할 수 있어요!',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedbackManager.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5CF6),
                        side: const BorderSide(
                          color: Color(0xFF8B5CF6),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '닫기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedbackManager.mediumImpact();
                        Navigator.pop(context);
                        // 모임 탭으로 이동
                        Navigator.pushNamed(context, '/', arguments: 3);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_forward, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '모임 탭으로',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 힌트 텍스트
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ModernColors.textTertiary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '모임에 참여하면 자동으로 기록이 추가됩니다',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 전체 모임 보기 버튼
  Widget _buildFullViewButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        onPressed: () {
          HapticFeedbackManager.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MeetingFullViewWidget(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF8B5CF6),
          side: BorderSide(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_view_month,
              color: Color(0xFF8B5CF6),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '전체 모임 보기',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 날짜별 모임 모달
  void _showDateMeetingModal(DateTime date, List<MeetingLog> dayMeetings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: ModernColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.month}월 ${date.day}일',
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          if (dayMeetings.length > 1)
                            Text(
                              '${dayMeetings.length}개의 모임',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: ModernColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 모임이 한 개인 경우
              if (dayMeetings.length == 1) ...[
                _buildSingleMeetingPreview(dayMeetings.first),
              ] else ...[
                // 여러 개인 경우 목록으로 표시
                _buildMultipleMeetingsList(dayMeetings),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 단일 모임 프리뷰
  Widget _buildSingleMeetingPreview(MeetingLog meeting) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MeetingCategories.getColor(meeting.category)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        MeetingCategories.getEmoji(meeting.category),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.meetingName,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              meeting.category,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: ModernColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: List.generate(
                                meeting.satisfaction.round(),
                                (index) => const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Color(0xFFFBBF24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    meeting.moodIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
              if (meeting.note != null) ...[
                const SizedBox(height: 16),
                Text(
                  meeting.note!,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textPrimary,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // 액션 버튼들
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // 자세히 보기 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MeetingLogDetailScreen(meeting: meeting),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    side:
                        const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.visibility, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '자세히 보기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 수정하기 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MeetingEditScreen(meeting: meeting),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '수정하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 여러 모임 목록
  Widget _buildMultipleMeetingsList(List<MeetingLog> meetings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];

          return Container(
            margin:
                EdgeInsets.only(bottom: index == meetings.length - 1 ? 0 : 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MeetingLogDetailScreen(meeting: meeting),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // 카테고리 아이콘
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: MeetingCategories.getColor(meeting.category)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          MeetingCategories.getEmoji(meeting.category),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 내용
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting.meetingName,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ModernColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                meeting.category,
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: ModernColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                meeting.moodIcon,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Spacer(),
                              ...List.generate(
                                meeting.satisfaction.round(),
                                (index) => const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Color(0xFFFBBF24),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 화살표
                    const Icon(
                      Icons.chevron_right,
                      color: ModernColors.textTertiary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
