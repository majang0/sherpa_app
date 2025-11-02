// lib/features/daily_record/widgets/enhanced_reading_calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/features/activities_reading/presentation/screens/reading_record_screen.dart';
import 'reading_full_view_widget.dart';
import 'package:sherpa_app/features/activities_reading/presentation/widgets/reading_detail_modal.dart';
import 'package:sherpa_app/features/activities_reading/utils/reading_utils.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';

class EnhancedReadingCalendarWidget extends ConsumerStatefulWidget {
  const EnhancedReadingCalendarWidget({super.key});

  @override
  ConsumerState<EnhancedReadingCalendarWidget> createState() =>
      _EnhancedReadingCalendarWidgetState();
}

class _EnhancedReadingCalendarWidgetState
    extends ConsumerState<EnhancedReadingCalendarWidget>
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

    Future.delayed(const Duration(milliseconds: 800), () {
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
    final readingLogs = user.dailyRecords.readingLogs;

    // 날짜순으로 정렬 (최신순 - 현재 날짜와 가장 가까운 순서)
    final sortedReadingLogs = List<ReadingLog>.from(readingLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ModernColors.surface, // 깔끔한 흰색 배경
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ModernColors.textTertiary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                      color: ModernColors.reading.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: ModernColors.reading,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '독서 기록',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        Text(
                          '매일 여러 번 독서 기록을 남겨보세요',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 추가 버튼
                  GestureDetector(
                    onTap: () {
                      HapticFeedbackManager.mediumImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReadingRecordScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ModernColors.reading, // 단순한 독서 색상
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: ModernColors.reading.withValues(alpha: 0.2),
                            blurRadius: 6,
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

              // 오늘의 통계
              _buildTodayStats(sortedReadingLogs),

              const SizedBox(height: 20),

              // 최근 7일 독서량 차트
              _buildWeeklyChart(sortedReadingLogs),

              const SizedBox(height: 20),

              // 전체보기 버튼
              _buildFullViewButton(),

              const SizedBox(height: 20),

              // 최근 독서 기록들
              if (sortedReadingLogs.isNotEmpty) ...[
                Text(
                  '최근 기록',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...sortedReadingLogs
                    .take(3)
                    .map((reading) => _buildReadingItem(reading)),
              ] else
                _buildEmptyState(),

              const SizedBox(height: 24),

              // 독서 기록 작성하기 버튼
              _buildWriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStats(List<ReadingLog> readingLogs) {
    final now = DateTime.now();
    final weekStart = ReadingUtils.getWeekStart(now);
    final weekStartDate =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEndExclusive = weekStartDate.add(const Duration(days: 7));

    final todayReadings =
        readingLogs.where((log) => ReadingUtils.isSameDay(log.date, now)).toList();

    final thisWeekReadings = readingLogs.where((log) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      final isOnOrAfterStart = !logDate.isBefore(weekStartDate);
      final isBeforeEnd = logDate.isBefore(weekEndExclusive);
      return isOnOrAfterStart && isBeforeEnd;
    }).toList();

    final todayTotalPages =
        todayReadings.fold<int>(0, (sum, log) => sum + log.pages);
    final weeklyReadingCount = thisWeekReadings.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.background, // 연한 회색 배경으로 구분
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.textTertiary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '📖',
              '$weeklyReadingCount회',
              '이번주 독서',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: ModernColors.textTertiary.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '📄',
              '${todayTotalPages}페이지',
              '오늘 읽은 양',
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
            color: ModernColors.reading,
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

  Widget _buildWeeklyChart(List<ReadingLog> readingLogs) {
    final now = DateTime.now();
    final weekDays =
        List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.background, // 연한 회색 배경
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.textTertiary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 독서량 (페이지)',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekDays
                .map((day) => _buildChartBar(day, readingLogs))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(DateTime day, List<ReadingLog> readingLogs) {
    final dayReadings = readingLogs
        .where((log) => ReadingUtils.isSameDay(log.date, day))
        .toList();
    final totalPages = dayReadings.fold<int>(0, (sum, log) => sum + log.pages);
    final isToday = ReadingUtils.isToday(day);
    final weekdayName = ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];

    // 최대 높이를 위한 비율 계산 (최대 100페이지 기준)
    const maxHeight = 40.0;
    final barHeight = (totalPages / 100.0 * maxHeight).clamp(2.0, maxHeight);

    return Column(
      children: [
        Container(
          width: 20,
          height: maxHeight,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 16,
            height: barHeight,
            decoration: BoxDecoration(
              color: isToday
                  ? ModernColors.reading
                  : ModernColors.reading.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          weekdayName,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isToday ? ModernColors.reading : ModernColors.textSecondary,
          ),
        ),
        Text(
          '${day.day}',
          style: GoogleFonts.notoSans(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: ModernColors.textTertiary,
          ),
        ),
        if (totalPages > 0)
          Text(
            '${totalPages}p',
            style: GoogleFonts.notoSans(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: ModernColors.reading,
            ),
          ),
      ],
    );
  }

  Widget _buildReadingItem(ReadingLog reading) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        _showReadingDetail(reading);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ModernColors.surface, // 흰색 카드 배경
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ModernColors.textTertiary.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 카테고리 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: reading.categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  reading.categoryEmoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 책 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reading.bookTitle,
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
                        '${reading.pages}p',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.reading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        reading.author,
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${reading.date.month}/${reading.date.day}',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      ...List.generate(
                        reading.rating?.round() ?? 0,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.background, // 연한 회색 배경
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.textTertiary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '📚',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            '아직 독서 기록이 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '오늘부터 독서 습관을 시작해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ModernColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showReadingDetail(ReadingLog readingLog) {
    ReadingDetailModal.show(context, readingLog);
  }

  void _editReading(ReadingLog readingLog) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadingRecordScreen(
          editingLog: readingLog,
          targetDate: readingLog.date,
        ),
      ),
    );
  }

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
              builder: (context) => const ReadingFullViewWidget(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: ModernColors.reading,
          backgroundColor: ModernColors.background, // 연한 회색 배경
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_view_month,
              color: ModernColors.reading,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '전체 독서 기록 보기',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.reading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedbackManager.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReadingRecordScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernColors.reading,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 20),
            const SizedBox(width: 8),
            Text(
              '독서 기록 작성하기',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
