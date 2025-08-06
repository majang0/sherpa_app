// lib/features/daily_record/widgets/diary_full_view_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/record_colors.dart';
import '../presentation/screens/diary_write_edit_screen.dart';
import '../presentation/screens/diary_detail_screen.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import '../../../shared/models/global_user_model.dart';

class DiaryFullViewWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<DiaryFullViewWidget> createState() => _DiaryFullViewWidgetState();
}

class _DiaryFullViewWidgetState extends ConsumerState<DiaryFullViewWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  DateTime _selectedMonth = DateTime.now();

  // 기분 데이터 매핑 (DetailScreen과 동일)
  final Map<String, Map<String, dynamic>> _moodData = {
    'very_happy': {'emoji': '😄', 'label': '매우 기뻐요', 'color': Color(0xFFFFD93D), 'gradient': [Color(0xFFFFD93D), Color(0xFFFFE55C)]},
    'happy': {'emoji': '😊', 'label': '기뻐요', 'color': Color(0xFF4ECDC4), 'gradient': [Color(0xFF4ECDC4), Color(0xFF44A08D)]},
    'good': {'emoji': '🙂', 'label': '좋아요', 'color': Color(0xFF45B7D1), 'gradient': [Color(0xFF45B7D1), Color(0xFF96C93D)]},
    'normal': {'emoji': '😐', 'label': '보통이에요', 'color': Color(0xFF96CEB4), 'gradient': [Color(0xFF96CEB4), Color(0xFF87CEEB)]},
    'thoughtful': {'emoji': '🤔', 'label': '생각이 많아요', 'color': Color(0xFF9B59B6), 'gradient': [Color(0xFF9B59B6), Color(0xFF8E44AD)]},
    'tired': {'emoji': '😴', 'label': '피곤해요', 'color': Color(0xFF95A5A6), 'gradient': [Color(0xFF95A5A6), Color(0xFF7F8C8D)]},
    'sad': {'emoji': '😢', 'label': '슬퍼요', 'color': Color(0xFF5DADE2), 'gradient': [Color(0xFF5DADE2), Color(0xFF3498DB)]},
    'excited': {'emoji': '🤗', 'label': '설레요', 'color': Color(0xFFFF6B9D), 'gradient': [Color(0xFFFF6B9D), Color(0xFFF093FB)]},
  };

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
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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
    final diaryLogs = user.dailyRecords.diaryLogs;

    // 선택된 월의 일기 로그 필터링
    final monthlyLogs = diaryLogs.where((log) {
      return log.date.year == _selectedMonth.year &&
          log.date.month == _selectedMonth.month;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
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
                    const Color(0xFFEC4899),
                    const Color(0xFFEC4899).withOpacity(0.7),
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
                    child: _buildMonthSelector(),
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

  Widget _buildHeader(List<DiaryLog> monthlyLogs) {
    final user = ref.watch(globalUserProvider);
    final totalDiaries = user.dailyRecords.diaryLogs.length;
    final monthlyCount = monthlyLogs.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFEC4899),
                      const Color(0xFFF97316),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_note,
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
                      '일기 기록 전체보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFEC4899),
                      ),
                    ),
                    const SizedBox(height: 4),

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
              color: const Color(0xFFEC4899).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEC4899).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month,
                  color: const Color(0xFFEC4899),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedMonth.year}년 ${_selectedMonth.month}월 • $monthlyCount개 일기 • 총 $totalDiaries개',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEC4899),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: const Color(0xFFEC4899).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEC4899).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                  });
                  HapticFeedbackManager.lightImpact();
                },
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: const Color(0xFFEC4899),
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
                        color: RecordColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                  ],
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEC4899).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                  });
                  HapticFeedbackManager.lightImpact();
                },
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFFEC4899),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(List<DiaryLog> monthlyLogs) {
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
              color: Colors.black.withOpacity(0.05),
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
                    color: const Color(0xFFEC4899).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_view_month,
                    color: const Color(0xFFEC4899),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedMonth.month}월 일기 캘린더',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: RecordColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '날짜를 클릭하여 일기를 확인하거나 작성해보세요',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: RecordColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 캘린더 내용
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEC4899).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // 요일 헤더
                  _buildWeekdayHeaders(),
                  const SizedBox(height: 12),

                  // 캘린더 날짜들 (6주)
                  ...List.generate(6, (weekIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: List.generate(7, (dayIndex) {
                          final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
                          final isCurrentMonth = date.month == _selectedMonth.month;
                          final isToday = _isToday(date);
                          final diaryLog = _getDiaryForDate(monthlyLogs, date);

                          return Expanded(
                            child: _buildCalendarDay(date, isCurrentMonth, isToday, diaryLog),
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
        children: weekdays.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: RecordColors.textSecondary,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date, bool isCurrentMonth, bool isToday, DiaryLog? diaryLog) {
    final hasDiary = diaryLog != null;
    final moodInfo = hasDiary ? _moodData[diaryLog.mood] : null;
    final isFuture = date.isAfter(DateTime.now().subtract(const Duration(hours: 1))); // 1시간 여유를 둠
    final isClickable = isCurrentMonth && !isFuture;

    return GestureDetector(
      onTap: isClickable ? () => _onDateTap(date, diaryLog) : null,
      child: Container(
        height: 72, // 높이 더 증가하여 이모지와 텍스트 공간 확보
        margin: const EdgeInsets.all(2), // 마진 증가
        decoration: BoxDecoration(
          gradient: isToday 
              ? LinearGradient(
                  colors: [const Color(0xFFEC4899), const Color(0xFFF97316)],
                )
              : hasDiary 
                  ? LinearGradient(
                      colors: moodInfo?['gradient'] ?? [Colors.grey.shade100, Colors.grey.shade50],
                    )
                  : null,
          color: !isToday && !hasDiary 
              ? (isFuture 
                  ? Colors.grey.shade200.withOpacity(0.5) // 미래 날짜는 더 진한 회색
                  : (isCurrentMonth ? Colors.white : Colors.grey.shade100.withOpacity(0.3))) // 다른 월은 더 연한 회색
              : null,
          borderRadius: BorderRadius.circular(16), // 둥근 모서리 증가
          border: Border.all(
            color: isToday 
                ? Colors.transparent
                : (hasDiary 
                    ? (moodInfo?['color'] ?? const Color(0xFFEC4899)).withOpacity(0.3)
                    : (isCurrentMonth ? RecordColors.textLight.withOpacity(0.1) : Colors.transparent)),
            width: 1.5,
          ),
          boxShadow: hasDiary || isToday ? [
            BoxShadow(
              color: (moodInfo?['color'] ?? const Color(0xFFEC4899)).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ] : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasDiary) ...[
                // 날짜 표시
                Text(
                  '${date.day}',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCurrentMonth
                        ? (isToday ? Colors.white : Colors.white)
                        : RecordColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                // 기분 이모지
                Text(
                  moodInfo?['emoji'] ?? '😊',
                  style: const TextStyle(fontSize: 16), // 이모지 크기 조정
                ),
                // 제목 미리보기 (있는 경우)
                if (diaryLog.title.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    diaryLog.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: isToday ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.95),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ] else ...[
                // 일기가 없는 날
                Text(
                  '${date.day}',
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                    color: isCurrentMonth
                        ? (isToday 
                            ? Colors.white 
                            : (isFuture 
                                ? RecordColors.textLight.withOpacity(0.4) // 미래 날짜 더 연하게
                                : RecordColors.textPrimary))
                        : RecordColors.textLight.withOpacity(0.25), // 다른 월 더 연하게
                  ),
                ),
                if (isClickable && !hasDiary && !isFuture) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEC4899).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 10,
                      color: const Color(0xFFEC4899),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  DiaryLog? _getDiaryForDate(List<DiaryLog> diaryLogs, DateTime date) {
    try {
      return diaryLogs.firstWhere((log) => 
        log.date.year == date.year &&
        log.date.month == date.month &&
        log.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  void _onDateTap(DateTime date, DiaryLog? diaryLog) {
    HapticFeedbackManager.lightImpact();
    
    if (diaryLog != null) {
      // 기존 일기가 있는 경우 - 상세보기로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryDetailScreen(diary: diaryLog),
        ),
      );
    } else {
      // 일기가 없는 경우 - 새 일기 작성
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryWriteEditScreen(
            selectedDate: date,
          ),
        ),
      );
    }
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
              color: const Color(0xFFEC4899).withOpacity(0.4),
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
                builder: (context) => DiaryWriteEditScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEC4899),
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
              Icon(Icons.edit, size: 22),
              const SizedBox(width: 10),
              Text(
                '새 일기 작성하기',
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
}