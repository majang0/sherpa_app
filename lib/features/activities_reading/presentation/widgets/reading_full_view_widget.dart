// lib/features/activities_reading/presentation/widgets/reading_full_view_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/features/activities_reading/presentation/screens/reading_record_screen.dart';
import 'package:sherpa_app/features/activities_reading/presentation/widgets/reading_detail_modal.dart';
import 'package:sherpa_app/features/activities_reading/utils/reading_utils.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';

class ReadingFullViewWidget extends ConsumerStatefulWidget {
  const ReadingFullViewWidget({super.key});

  @override
  ConsumerState<ReadingFullViewWidget> createState() =>
      _ReadingFullViewWidgetState();
}

class _ReadingFullViewWidgetState extends ConsumerState<ReadingFullViewWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  DateTime _selectedMonth = DateTime.now();
  String? _selectedCategory; // Category filter

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
    final readingLogs = user.dailyRecords.readingLogs;

    // 선택된 월의 독서 로그 필터링
    final monthlyLogs = readingLogs.where((log) {
      return log.date.year == _selectedMonth.year &&
          log.date.month == _selectedMonth.month;
    }).toList();

    return Scaffold(
      backgroundColor: ModernColors.background,
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
                    ModernColors.reading,
                    ModernColors.reading.withValues(alpha: 0.7),
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

                  // 필터 섹션 (카테고리 필터)
                  if (monthlyLogs.isNotEmpty)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildFilterSection(monthlyLogs),
                    ),

                  const SizedBox(height: 20),

                  // 캘린더 그리드 섹션 (월 이동 기능 통합)
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

  Widget _buildHeader(List<ReadingLog> monthlyLogs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ModernColors.reading.withValues(alpha: 0.2),
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
                      ModernColors.reading,
                      Color(0xFF059669),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.reading.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book,
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
                      '독서 기록 전체보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.reading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '지식의 성장을 기록해보세요',
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
        ],
      ),
    );
  }

  Widget _buildFilterSection(List<ReadingLog> readingLogs) {
    // 독서 카테고리 순서 (reading_record_screen.dart와 동일하게 11개)
    final orderedCategories = [
      '소설',
      '자기계발',
      '경영',
      '과학',
      '역사',
      '예술',
      '인문학',
      '철학',
      '심리학',
      'SF',
      '기타',
    ];

    final availableCategories = readingLogs.map((e) => e.category).toSet();
    final uniqueCategories = orderedCategories
        .where((category) => availableCategories.contains(category))
        .toList();

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ModernColors.reading.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.filter_alt,
                    color: ModernColors.reading,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '독서 카테고리',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildFilterChip('전체', null, readingLogs),
                ...uniqueCategories
                    .map((category) => _buildFilterChip(category, category, readingLogs)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String? value, List<ReadingLog> readingLogs) {
    final isSelected = _selectedCategory == value;
    final count = value == null
        ? readingLogs.length
        : readingLogs.where((log) => log.category == value).length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
        HapticFeedbackManager.lightImpact();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? ModernColors.reading : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? ModernColors.reading
                    : ModernColors.reading.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ModernColors.reading.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null) ...[
                  Text(
                    _getCategoryEmoji(value),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // 숫자를 오른쪽 위에 작게 표시
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: value != null
                    ? _getCategoryColor(value)
                    : ModernColors.reading,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigationHeader(List<ReadingLog> monthlyLogs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ModernColors.reading.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.reading.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                });
                HapticFeedbackManager.lightImpact();
              },
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: ModernColors.reading,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  Text(
                    _getMonthMessage(monthlyLogs),
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.reading.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                });
                HapticFeedbackManager.lightImpact();
              },
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: ModernColors.reading,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<ReadingLog> monthlyLogs) {
    // 날짜별로 독서 그룹화
    final readingsByDate = <DateTime, List<ReadingLog>>{};
    for (final log in monthlyLogs) {
      final date = DateTime(log.date.year, log.date.month, log.date.day);
      if (_selectedCategory == null || log.category == _selectedCategory) {
        readingsByDate[date] = [...(readingsByDate[date] ?? []), log];
      }
    }

    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
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
            // 월 이동 헤더 통합
            _buildMonthNavigationHeader(monthlyLogs),

            // 캘린더 본문
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // 안내 텍스트
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ModernColors.background.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: ModernColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '독서한 날을 탭하면 상세 정보를 볼 수 있어요',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 요일 헤더
                  _buildWeekdayHeaders(),
                  const SizedBox(height: 8),

                  // 캘린더 날짜들 (6주)
                  ...List.generate(6, (weekIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: List.generate(7, (dayIndex) {
                          final date = startDate
                              .add(Duration(days: weekIndex * 7 + dayIndex));
                          final isCurrentMonth =
                              date.month == _selectedMonth.month;
                          final isToday = ReadingUtils.isToday(date);
                          final dayReadings = readingsByDate[
                                  DateTime(date.year, date.month, date.day)] ??
                              [];

                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: _buildCalendarDay(
                                  date, isCurrentMonth, isToday, dayReadings),
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
    return Row(
      children: ['일', '월', '화', '수', '목', '금', '토']
          .map(
            (day) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarDay(DateTime date, bool isCurrentMonth, bool isToday,
      List<ReadingLog> dayReadings) {
    final hasReading = dayReadings.isNotEmpty;
    final isFuture =
        date.isAfter(DateTime.now().subtract(const Duration(hours: 1)));
    // 독서 기록이 있거나, 현재 월의 과거/오늘 날짜면 클릭 가능
    final isClickable = isCurrentMonth && !isFuture;

    return GestureDetector(
      onTap: isClickable
          ? () {
              if (hasReading) {
                // 독서 기록이 있으면 상세 모달 표시
                _showDateDetail(date, dayReadings);
              } else {
                // 독서 기록이 없으면 바로 독서 기록 작성 화면으로 이동
                HapticFeedbackManager.mediumImpact();
                _addReadingForDate(date);
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          gradient: isToday
              ? const LinearGradient(
                  colors: [ModernColors.reading, Color(0xFF059669)],
                )
              : null,
          color: !isToday
              ? (hasReading
                  ? Colors.white // 기록 있는 날: 흰색
                  : (isFuture
                      ? Colors.grey.shade200.withValues(alpha: 0.5) // 미래 날짜
                      : (isCurrentMonth
                          ? Colors.transparent // 이번 달 빈 날짜: 투명
                          : Colors.grey.shade100.withValues(alpha: 0.3)))) // 이전/다음 달
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? Colors.transparent
                : (hasReading
                    ? ModernColors.reading.withValues(alpha: 0.2) // 기록 있는 날: 연한 테두리
                    : Colors.transparent), // 빈 날짜: 투명 테두리
            width: 1,
          ),
          boxShadow: hasReading || isToday
              ? [
                  BoxShadow(
                    color: ModernColors.reading.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // 날짜 표시 (중앙)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${date.day}',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCurrentMonth
                        ? (isToday
                            ? Colors.white
                            : (hasReading
                                ? ModernColors.reading
                                : ModernColors.textPrimary))
                        : ModernColors.textTertiary,
                  ),
                ),
              ),
            ),

            // 독서 표시 (우측 상단 아이콘)
            if (hasReading)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: dayReadings.length > 1
                        ? ModernColors.reading
                        : _getCategoryColor(dayReadings.first.category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: dayReadings.length > 1
                        ? Text(
                            '${dayReadings.length}',
                            style: GoogleFonts.notoSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _getCategoryEmoji(dayReadings.first.category),
                            style: const TextStyle(fontSize: 8),
                          ),
                  ),
                ),
              ),

            // + 아이콘 (하단 중앙) - 기록 없고 작성 가능한 날짜만
            if (!hasReading && isCurrentMonth && !isFuture)
              Positioned(
                bottom: 3,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 10,
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.9)
                        : ModernColors.reading.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDateDetail(DateTime date, List<ReadingLog> readingLogs) {
    HapticFeedbackManager.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
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

            // 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ModernColors.reading, Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ModernColors.reading.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_today,
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
                          '${date.year}년 ${date.month}월 ${date.day}일',
                          style: GoogleFonts.notoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${readingLogs.length}권 • ${readingLogs.fold(0, (sum, e) => sum + e.pages)}페이지',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: ModernColors.textTertiary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 독서 기록 목록
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: readingLogs.length,
                itemBuilder: (context, index) {
                  final log = readingLogs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showReadingDetail(log, date);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ModernColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getCategoryColor(log.category)
                                .withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getCategoryColor(log.category)
                                  .withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getCategoryColor(log.category),
                                    _getCategoryColor(log.category)
                                        .withValues(alpha: 0.8)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getCategoryColor(log.category)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  log.categoryEmoji,
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
                                    log.bookTitle,
                                    style: GoogleFonts.notoSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _getCategoryColor(log.category),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 14,
                                        color: ModernColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        log.author,
                                        style: GoogleFonts.notoSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: ModernColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.auto_stories,
                                        size: 14,
                                        color: ModernColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${log.pages}p',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: ModernColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (log.rating != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ModernColors.reading,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...List.generate(
                                      log.rating?.round() ?? 0,
                                      (index) => const Icon(
                                        Icons.star,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 독서 기록 추가하기 버튼
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.reading.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 모달 닫기
                  HapticFeedbackManager.mediumImpact();
                  _addReadingForDate(date);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.reading,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.add, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '독서 기록 추가하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showReadingDetail(ReadingLog readingLog, DateTime? selectedDate) {
    ReadingDetailModal.show(context, readingLog, selectedDate: selectedDate);
  }

  Widget _buildActionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.reading.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedbackManager.mediumImpact();
          Navigator.of(context).push(
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
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              '독서 기록 추가하기',
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

  void _addReadingForDate(DateTime date) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadingRecordScreen(
          targetDate: date,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '소설':
        return const Color(0xFF6366F1); // 보라
      case '자기계발':
        return const Color(0xFFEC4899); // 분홍
      case '경영':
        return const Color(0xFF3B82F6); // 파랑
      case '과학':
        return const Color(0xFF10B981); // 초록
      case '역사':
        return const Color(0xFFF59E0B); // 주황
      case '예술':
        return const Color(0xFFEF4444); // 빨강
      case '인문학':
        return const Color(0xFF8B5CF6); // 보라
      case '철학':
        return const Color(0xFF64748B); // 회색
      case '심리학':
        return const Color(0xFF06B6D4); // 시안
      case 'SF':
        return const Color(0xFF6366F1); // 보라
      case '기타':
      default:
        return const Color(0xFF94A3B8); // 회색
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case '소설':
        return '📚';
      case '자기계발':
        return '💡';
      case '경영':
        return '💼';
      case '과학':
        return '🔬';
      case '역사':
        return '📜';
      case '예술':
        return '🎨';
      case '인문학':
        return '📖';
      case '철학':
        return '🤔';
      case '심리학':
        return '🧠';
      case 'SF':
        return '🚀';
      case '기타':
      default:
        return '📗';
    }
  }

  String _getMonthMessage(List<ReadingLog> monthlyLogs) {
    final count = monthlyLogs.length;
    if (count == 0) {
      return '아직 독서 기록이 없어요';
    } else if (count <= 3) {
      return '좋은 시작이에요!';
    } else if (count <= 10) {
      return '활발한 독서 습관 중!';
    } else {
      return '정말 꾸준하시네요!';
    }
  }
}
