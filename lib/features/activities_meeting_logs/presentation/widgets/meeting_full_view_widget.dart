// lib/features/daily_record/widgets/meeting_full_view_widget.dart

import 'package:flutter/material.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/features/activities_meeting_logs/presentation/screens/meeting_log_detail_screen.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';
import 'package:sherpa_app/core/constants/meeting_categories.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';

class MeetingFullViewWidget extends ConsumerStatefulWidget {
  const MeetingFullViewWidget({super.key});

  @override
  ConsumerState<MeetingFullViewWidget> createState() =>
      _MeetingFullViewWidgetState();
}

class _MeetingFullViewWidgetState extends ConsumerState<MeetingFullViewWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final meetingLogs = user.dailyRecords.meetingLogs;

    LoggerService.instance
        .d('📊 MeetingFullView: 모임 데이터 확인 - 총 ${meetingLogs.length}개');
    if (meetingLogs.isNotEmpty) {
      final dates =
          meetingLogs.map((m) => '${m.date.month}/${m.date.day}').join(', ');
      LoggerService.instance.d('  모임 날짜: $dates');
    }

    // 선택된 월의 모임 로그 필터링
    final monthlyLogs = meetingLogs.where((log) {
      return log.date.year == _selectedMonth.year &&
          log.date.month == _selectedMonth.month;
    }).toList();

    LoggerService.instance.d(
        '📅 ${_selectedMonth.year}년 ${_selectedMonth.month}월 모임: ${monthlyLogs.length}개');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black87, size: 20),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 배경 그라데이션
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF8B5CF6),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // 메인 콘텐츠
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 120), // AppBar 공간

                  // 헤더 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeader(monthlyLogs),
                  ),

                  const SizedBox(height: 24),

                  // 월 선택 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildMonthSelector(monthlyLogs),
                  ),

                  const SizedBox(height: 20),

                  // 캘린더 그리드 섹션
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildCalendarGrid(monthlyLogs),
                  ),

                  const SizedBox(height: 32),

                  // 액션 버튼
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildActionButton(),
                  ),

                  // 하단 여백 증가하여 오버플로우 방지
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<MeetingLog> monthlyLogs) {
    final user = ref.watch(globalUserProvider);
    final totalMeetings = user.dailyRecords.meetingLogs.length;
    final monthlyCount = monthlyLogs.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 아이콘과 제목
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF7C3AED),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '모임 기록 전체보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '소중한 모임의 추억들을 한눈에',
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

          const SizedBox(height: 24),

          // 통계 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedMonth.year}년 ${_selectedMonth.month}월 • $monthlyCount개 모임 • 총 $totalMeetings개',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(List<MeetingLog> monthlyLogs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth =
                        DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                  });
                  HapticFeedbackManager.lightImpact();
                },
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMonthMessage(monthlyLogs),
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth =
                        DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                  });
                  HapticFeedbackManager.lightImpact();
                },
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthMessage(List<MeetingLog> monthlyLogs) {
    final count = monthlyLogs.length;
    if (count == 0) {
      return '아직 모임 기록이 없어요';
    } else if (count <= 3) {
      return '좋은 시작이에요!';
    } else if (count <= 10) {
      return '활발한 모임 활동 중!';
    } else {
      return '정말 활발하시네요!';
    }
  }

  Widget _buildCalendarGrid(List<MeetingLog> monthlyLogs) {
    // 월의 첫 번째 날과 마지막 날 계산
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_view_month,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedMonth.month}월 모임 캘린더',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '색상 도트: 모임 카테고리 • 클릭: 상세 정보 보기',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 카테고리 색상 범례
            _buildCategoryLegend(),

            const SizedBox(height: 16),

            // 캘린더 내용
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 요일 헤더
                  _buildWeekdayHeaders(),
                  const SizedBox(height: 12),

                  // 캘린더 날짜들 (6주)
                  ...List.generate(6, (weekIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: List.generate(7, (dayIndex) {
                          final date = startDate
                              .add(Duration(days: weekIndex * 7 + dayIndex));
                          final isCurrentMonth =
                              date.month == _selectedMonth.month;
                          final isToday = _isToday(date);
                          final dayMeetings =
                              _getMeetingsForDate(monthlyLogs, date);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(1),
                              child: _buildCalendarDay(
                                  date, isCurrentMonth, isToday, dayMeetings),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekdays
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// 모임 도트들을 표시하는 위젯
  Widget _buildMeetingDots(List<MeetingLog> meetings, bool isToday) {
    // 최대 4개까지만 표시
    final displayMeetings = meetings.take(4).toList();
    final hasMore = meetings.length > 4;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2,
      runSpacing: 2,
      children: [
        ...displayMeetings.map((meeting) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withValues(alpha: 0.9)
                    : _getCategoryColor(meeting.category),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getCategoryColor(meeting.category)
                        .withValues(alpha: 0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            )),
        if (hasMore) ...[
          const SizedBox(width: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: isToday
                  ? Colors.white.withValues(alpha: 0.2)
                  : const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isToday
                    ? Colors.white.withValues(alpha: 0.4)
                    : const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              '+${meetings.length - 4}',
              style: GoogleFonts.notoSans(
                fontSize: 6,
                fontWeight: FontWeight.w700,
                color: isToday
                    ? Colors.white.withValues(alpha: 0.9)
                    : const Color(0xFF8B5CF6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCalendarDay(DateTime date, bool isCurrentMonth, bool isToday,
      List<MeetingLog> dayMeetings) {
    final hasMeeting = dayMeetings.isNotEmpty;
    final isFuture =
        date.isAfter(DateTime.now().subtract(const Duration(hours: 1)));
    final isClickable = isCurrentMonth && hasMeeting; // 모임이 있는 날짜만 클릭 가능

    return GestureDetector(
      onTap: isClickable ? () => _onDateTap(date, dayMeetings) : null,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: isToday
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                )
              : null,
          color: !isToday
              ? (hasMeeting
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                  : (isFuture
                      ? Colors.grey.shade200.withValues(alpha: 0.5)
                      : (isCurrentMonth
                          ? Colors.white
                          : Colors.grey.shade100.withValues(alpha: 0.3))))
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? Colors.transparent
                : (hasMeeting
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                    : (isCurrentMonth
                        ? ModernColors.textTertiary.withValues(alpha: 0.1)
                        : Colors.transparent)),
            width: 1.5,
          ),
          boxShadow: hasMeeting || isToday
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              // 날짜 표시 (상단)
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isCurrentMonth
                          ? (isToday
                              ? Colors.white
                              : (isFuture
                                  ? ModernColors.textTertiary
                                      .withValues(alpha: 0.4)
                                  : ModernColors.textPrimary))
                          : ModernColors.textTertiary.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),

              // 모임 도트 표시 (하단)
              Expanded(
                flex: 1,
                child: hasMeeting
                    ? _buildMeetingDots(dayMeetings, isToday)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MeetingLog> _getMeetingsForDate(
      List<MeetingLog> meetingLogs, DateTime date) {
    return meetingLogs
        .where((log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day)
        .toList();
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  void _onDateTap(DateTime date, List<MeetingLog> dayMeetings) {
    HapticFeedbackManager.lightImpact();

    if (dayMeetings.length == 1) {
      // 모임이 하나만 있는 경우 - 상세보기로 바로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MeetingLogDetailScreen(meeting: dayMeetings.first),
        ),
      );
    } else if (dayMeetings.length > 1) {
      // 여러 모임이 있는 경우 - 모달로 선택
      _showMultipleMeetingsModal(date, dayMeetings);
    }
  }

  void _showMultipleMeetingsModal(DateTime date, List<MeetingLog> meetings) {
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
                          Text(
                            '${meetings.length}개의 모임',
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

              // 모임 목록
              Container(
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
                      margin: EdgeInsets.only(
                          bottom: index == meetings.length - 1 ? 0 : 12),
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
                            color:
                                const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.1),
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
                                  color: _getCategoryColor(meeting.category)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    _getCategoryEmoji(meeting.category),
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
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            5,
                                            (index) {
                                              final starValue = index + 1;
                                              final isFullStar =
                                                  meeting.satisfaction >=
                                                      starValue;
                                              final isHalfStar =
                                                  meeting.satisfaction >=
                                                          starValue - 0.5 &&
                                                      meeting.satisfaction <
                                                          starValue;

                                              return Stack(
                                                children: [
                                                  const Icon(
                                                    Icons.star_border,
                                                    size: 12,
                                                    color: Color(0xFFFBBF24),
                                                  ),
                                                  if (isFullStar)
                                                    const Icon(
                                                      Icons.star,
                                                      size: 12,
                                                      color: Color(0xFFFBBF24),
                                                    )
                                                  else if (isHalfStar)
                                                    const ClipRect(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        widthFactor: 0.5,
                                                        child: Icon(
                                                          Icons.star,
                                                          size: 12,
                                                          color:
                                                              Color(0xFFFBBF24),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
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
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            HapticFeedbackManager.mediumImpact();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back, size: 22),
              const SizedBox(width: 10),
              Text(
                '돌아가기',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '스터디':
        return const Color(0xFF3B82F6); // 파랑
      case '운동':
        return const Color(0xFF10B981); // 초록
      case '독서':
        return const Color(0xFF8B5CF6); // 보라
      case '취미':
        return const Color(0xFFF59E0B); // 주황
      case '네트워킹':
        return const Color(0xFFEC4899); // 핀크
      case '업무':
        return const Color(0xFF6B7280); // 회색
      case '친목':
        return const Color(0xFFEF4444); // 빨강
      case '종교':
        return const Color(0xFF06B6D4); // 하늘색
      case '봉사':
        return const Color(0xFF84CC16); // 라임
      default:
        return const Color(0xFF9CA3AF); // 기본 회색
    }
  }

  String _getCategoryEmoji(String category) {
    // 🎯 중앙집중식 카테고리 시스템 사용
    return MeetingCategories.getEmoji(category);
  }

  /// 카테고리 색상 범례 위젯
  Widget _buildCategoryLegend() {
    final categories = [
      {'이름': '스터디', '색상': const Color(0xFF3B82F6)},
      {'이름': '운동', '색상': const Color(0xFF10B981)},
      {'이름': '독서', '색상': const Color(0xFF8B5CF6)},
      {'이름': '취미', '색상': const Color(0xFFF59E0B)},
      {'이름': '네트워킹', '색상': const Color(0xFFEC4899)},
      {'이름': '업무', '색상': const Color(0xFF6B7280)},
      {'이름': '친목', '색상': const Color(0xFFEF4444)},
      {'이름': '종교', '색상': const Color(0xFF06B6D4)},
      {'이름': '봉사', '색상': const Color(0xFF84CC16)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
                    color: Color(0xFF8B5CF6),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '카테고리 색상 범례',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: categories
                  .map(
                    (category) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: category['색상'] as Color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (category['색상'] as Color)
                                    .withValues(alpha: 0.3),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category['이름'] as String,
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
