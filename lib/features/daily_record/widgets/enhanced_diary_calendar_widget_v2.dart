// lib/features/daily_record/widgets/enhanced_diary_calendar_widget_v2.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_colors.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import '../presentation/screens/diary_write_edit_screen.dart';
import '../presentation/screens/diary_detail_screen.dart';
import '../../../shared/widgets/dialogs/analysis_pages/diary_analysis_page.dart';
import 'diary_full_view_widget.dart';

class EnhancedDiaryCalendarWidget extends ConsumerStatefulWidget {
  const EnhancedDiaryCalendarWidget({super.key});

  @override
  ConsumerState<EnhancedDiaryCalendarWidget> createState() =>
      _EnhancedDiaryCalendarWidgetState();
}

class _EnhancedDiaryCalendarWidgetState
    extends ConsumerState<EnhancedDiaryCalendarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final diaryLogs = user.dailyRecords.diaryLogs;

    // 날짜순으로 정렬 (최신순)
    final sortedDiaryLogs = List<DiaryLog>.from(diaryLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ModernColors.getElevationShadow(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildWeeklyCalendar(sortedDiaryLogs),
            const SizedBox(height: 10),
            _buildFullViewButton(),
            const SizedBox(height: 12),

            // 최근 기록들
            if (sortedDiaryLogs.isNotEmpty) ...[
              _buildRecentHeader(),
              const SizedBox(height: 10),
              ...sortedDiaryLogs.take(3).map((diary) => _buildDiaryItem(diary)),
            ] else
              _buildEmptyState(),

            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ModernColors.diary, ModernColors.diaryAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: ModernColors.getContextShadow('diary', level: 2),
          ),
          child: const Icon(
            Icons.edit_note,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '일기 기록',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '오늘의 이야기를 남겨보세요',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedbackManager.mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryWriteEditScreen(),
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ModernColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: ModernColors.getContextShadow('diary', level: 1),
            ),
            child: Icon(
              Icons.add_rounded,
              color: ModernColors.diary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar(List<DiaryLog> diaryLogs) {
    final now = DateTime.now();
    final weekDays =
        List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: ModernColors.textTertiary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: ModernColors.diary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '이번 주 기록',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDays
                .map((day) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildCalendarDay(day, diaryLogs),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, List<DiaryLog> diaryLogs) {
    final dayLogs =
        diaryLogs.where((log) => _isSameDay(log.date, day)).toList();
    final latestDiary = dayLogs.isNotEmpty ? dayLogs.first : null;
    final hasMultipleDiaries = dayLogs.length > 1;
    final isToday = _isSameDay(day, DateTime.now());
    final weekdayName = ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];

    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.mediumImpact();
        _showDateDiaryModal(day, dayLogs);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 요일
            Text(
              weekdayName,
              style: GoogleFonts.notoSans(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: isToday ? ModernColors.diary : ModernColors.textTertiary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 3),

            // 날짜
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isToday
                    ? ModernColors.diary
                    : latestDiary != null
                        ? ModernColors.diaryLight
                        : ModernColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  if (isToday) ...[
                    BoxShadow(
                      color: ModernColors.diary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ],
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? Colors.white
                        : latestDiary != null
                            ? ModernColors.diary
                            : ModernColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // 감정 이모지 또는 상태 표시
            if (latestDiary != null) ...[
              if (hasMultipleDiaries)
                Column(
                  children: [
                    Text(
                      _getMoodEmoji(latestDiary.mood),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: ModernColors.diary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${dayLogs.length}',
                        style: GoogleFonts.notoSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  _getMoodEmoji(latestDiary.mood),
                  style: const TextStyle(fontSize: 14),
                ),
            ] else
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: ModernColors.textTertiary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHeader() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ModernColors.diary, ModernColors.diaryAccent],
            ),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '최근 기록',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: ModernColors.diary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '최신순',
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: ModernColors.diary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiaryItem(DiaryLog diary) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryDetailScreen(diary: diary),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ModernColors.textTertiary.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ModernColors.diaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getMoodEmoji(diary.mood),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              ModernColors.diary,
                              ModernColors.diaryAccent
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getMoodLabel(diary.mood),
                          style: GoogleFonts.notoSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${diary.date.month}/${diary.date.day}',
                        style: GoogleFonts.notoSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textTertiary,
                        ),
                      ),
                      if (diary.hasAttachments) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.attachment_rounded,
                          size: 12,
                          color: ModernColors.textTertiary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diary.title.isNotEmpty ? diary.title : diary.content,
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: ModernColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: ModernColors.diary,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ModernColors.textTertiary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ModernColors.diary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.diary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '📝',
                style: TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '아직 작성된 일기가 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘의 소중한 순간을 기록해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullViewButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedbackManager.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryFullViewWidget(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: ModernColors.diaryLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.diary.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: ModernColors.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.calendar_view_month_rounded,
                    color: ModernColors.diary,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '전체 일기 보기',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.diary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final user = ref.watch(globalUserProvider);
    final hasDiaryLogs = user.dailyRecords.diaryLogs.isNotEmpty;

    return Row(
      children: [
        // 일기 작성 버튼
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: ModernColors.diary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: ModernColors.getContextShadow('diary', level: 4),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedbackManager.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryWriteEditScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit_rounded,
                          size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '일기 작성',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 일기가 있을 때만 분석 버튼 표시
        if (hasDiaryLogs) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.diaryAccent.withOpacity(0.8),
                    ModernColors.diary.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: ModernColors.getContextShadow('diary', level: 3),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedbackManager.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DiaryAnalysisPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.insights_rounded,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          '감정 분석',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWriteButton() {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: ModernColors.diary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: ModernColors.getContextShadow('diary', level: 4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedbackManager.mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryWriteEditScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '일기 작성하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDateDiaryModal(DateTime date, List<DiaryLog> dayLogs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEnhancedModal(date, dayLogs),
    );
  }

  Widget _buildEnhancedModal(DateTime date, List<DiaryLog> dayLogs) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: ModernColors.getElevationShadow(4),
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
                width: 48,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: ModernColors.diary,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),

              // 모달 내용...
              _buildModalContent(date, dayLogs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalContent(DateTime date, List<DiaryLog> dayLogs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
      child: Column(
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ModernColors.diary, ModernColors.diaryAccent],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.diary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.month}월 ${date.day}일',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    if (dayLogs.length > 1)
                      Text(
                        '${dayLogs.length}개의 일기',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // 일기 내용 표시
          if (dayLogs.isNotEmpty) ...[
            if (dayLogs.length == 1)
              _buildSingleDiaryPreview(dayLogs.first)
            else
              _buildMultipleDiariesList(dayLogs),
          ] else
            _buildEmptyDayContent(date),

          const SizedBox(height: 20),

          // 작성 버튼
          _buildModalWriteButton(date, dayLogs.isNotEmpty),
        ],
      ),
    );
  }

  Widget _buildModalWriteButton(DateTime date, bool hasExisting) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: ModernColors.diary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.diary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryWriteEditScreen(
                  selectedDate: date,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  hasExisting ? '새 일기 추가하기' : '일기 작성하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 기타 헬퍼 메서드들...

  Widget _buildSingleDiaryPreview(DiaryLog diary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.diaryLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ModernColors.diary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getMoodEmoji(diary.mood),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ModernColors.diary,
                            ModernColors.diaryAccent
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getMoodLabel(diary.mood),
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (diary.title.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        diary.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            diary.content,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textPrimary,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: _buildModalActionButton(
                  icon: Icons.visibility_rounded,
                  label: '자세히 보기',
                  isOutlined: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryDetailScreen(diary: diary),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModalActionButton(
                  icon: Icons.edit_rounded,
                  label: '수정하기',
                  isOutlined: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryWriteEditScreen(
                          existingDiary: diary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModalActionButton({
    required IconData icon,
    required String label,
    required bool isOutlined,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.white : null,
            gradient: isOutlined
                ? null
                : const LinearGradient(
                    colors: [ModernColors.diary, ModernColors.diaryAccent],
                  ),
            borderRadius: BorderRadius.circular(12),
            border: isOutlined
                ? Border.all(
                    color: ModernColors.diary,
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              if (!isOutlined)
                BoxShadow(
                  color: ModernColors.diary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isOutlined ? ModernColors.diary : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? ModernColors.diary : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDayContent(DateTime date) {
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final isPast = date.isBefore(now.subtract(const Duration(days: 1)));

    String emoji;
    String title;
    String subtitle;

    if (isToday) {
      emoji = '✨';
      title = '오늘의 이야기를 시작해보세요';
      subtitle = '지금 이 순간의 소중한 감정과 경험을 기록해보세요';
    } else if (isPast) {
      emoji = '💭';
      title = '${date.month}월 ${date.day}일의 기억들';
      subtitle = '지나간 하루를 되돌아보며 소중한 순간들을 기록해보세요';
    } else {
      emoji = '🌱';
      title = '미래의 나에게 메시지를';
      subtitle = '앞으로의 계획이나 기대감을 미리 적어보세요';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.diaryLight.withOpacity(0.5),
            Colors.white.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ModernColors.diary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 52),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleDiariesList(List<DiaryLog> dayLogs) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: dayLogs.length,
        itemBuilder: (context, index) {
          final diary = dayLogs[index];
          final isLatest = index == 0;

          return Container(
            margin:
                EdgeInsets.only(bottom: index == dayLogs.length - 1 ? 0 : 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryDetailScreen(diary: diary),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLatest
                        ? ModernColors.diaryLight.withOpacity(0.6)
                        : ModernColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.diary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 순서 표시
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isLatest
                              ? ModernColors.diary
                              : ModernColors.textTertiary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isLatest
                                  ? ModernColors.diary.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 기분 이모지
                      Text(
                        _getMoodEmoji(diary.mood),
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 14),

                      // 내용
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _getMoodLabel(diary.mood),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ModernColors.diary,
                                  ),
                                ),
                                if (isLatest) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          ModernColors.diary,
                                          ModernColors.diaryAccent
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '최신',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (diary.title.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                diary.title,
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ModernColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 3),
                            Text(
                              diary.content,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: ModernColors.textSecondary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // 화살표 아이콘
                      Icon(
                        Icons.chevron_right_rounded,
                        color: ModernColors.diary.withOpacity(0.5),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'excited':
        return '🥰';
      case 'happy':
        return '😄';
      case 'good':
        return '😊';
      case 'normal':
        return '😐';
      case 'thoughtful':
        return '🤔';
      case 'tired':
        return '😴';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      default:
        return '😊';
    }
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'excited':
        return '설레요';
      case 'happy':
        return '기뻐요';
      case 'good':
        return '좋아요';
      case 'normal':
        return '보통이에요';
      case 'thoughtful':
        return '생각이 많아요';
      case 'tired':
        return '피곤해요';
      case 'sad':
        return '슬퍼요';
      case 'angry':
        return '화나요';
      default:
        return '기뻐요';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
