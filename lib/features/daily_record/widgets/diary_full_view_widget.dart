// lib/features/daily_record/widgets/diary_full_view_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_colors.dart';
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
      backgroundColor: const Color(0xFFFAFBFC),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
                boxShadow: ModernColors.getContextShadow('diary', level: 1),
              ),
              child: const Icon(
                Icons.calendar_view_month_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '일기 캘린더',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // 월 선택 섹션
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildMonthSelector(),
              ),
              
              const SizedBox(height: 24),
              
              // 캘린더 그리드 섹션
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildCalendarGrid(monthlyLogs),
              ),
              
              const SizedBox(height: 36),
              
              // 액션 버튼
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildActionButton(),
              ),
              
              // 하단 여백 증가하여 오버플로우 방지
              SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이전 달 버튼
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
              HapticFeedbackManager.lightImpact();
            },
            icon: Icon(
              Icons.chevron_left,
              color: ModernColors.todayPastel,
              size: 24,
            ),
          ),
          
          // 년월 표시 (2줄로 분리)
          Column(
            children: [
              // 연도
              Text(
                '${_selectedMonth.year}년',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textSecondary,
                ),
              ),
              // 월
              Text(
                '${_selectedMonth.month}월',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          
          // 다음 달 버튼
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              });
              HapticFeedbackManager.lightImpact();
            },
            icon: Icon(
              Icons.chevron_right,
              color: ModernColors.todayPastel,
              size: 24,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 요일 헤더
          _buildWeekdayHeaders(),
          const SizedBox(height: 20),

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
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isWeekend = index == 0 || index == 6; // 일요일(0) 또는 토요일(6)
          
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: index == 6 
                    ? ModernColors.todayPastel // 토요일은 파스텔 블루
                    : index == 0 
                      ? ModernColors.error // 일요일은 빨간색
                      : ModernColors.textTertiary, // 평일은 기본 색상
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date, bool isCurrentMonth, bool isToday, DiaryLog? diaryLog) {
    final hasDiary = diaryLog != null;
    final moodInfo = hasDiary ? _moodData[diaryLog.mood] : null;
    final isFuture = date.isAfter(DateTime.now().subtract(const Duration(hours: 1)));
    final isClickable = isCurrentMonth && !isFuture;

    // 파스텔 색상 결정
    Color? backgroundColor;
    Color textColor = ModernColors.textPrimary;
    
    if (isToday) {
      backgroundColor = ModernColors.todayPastel;
      textColor = Colors.white;
    } else if (hasDiary) {
      backgroundColor = ModernColors.getMoodPastelColor(diaryLog!.mood);
      textColor = ModernColors.textPrimary;
    }

    return GestureDetector(
      onTap: isClickable ? () => _onDateTap(date, diaryLog) : null,
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Stack(
          children: [
            // 날짜 숫자 (중앙 상단)
            Positioned(
              top: 6,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${date.day}',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCurrentMonth 
                        ? textColor
                        : ModernColors.textTertiary.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            
            // 이모지 (일기가 있는 경우) 또는 + 아이콘 (일기가 없는 경우)
            if (hasDiary)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    moodInfo?['emoji'] ?? '😊',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            else if (isClickable) // 일기가 없고 클릭 가능한 경우 모던한 + 아이콘 표시
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: ModernColors.gray100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 11,
                      color: ModernColors.textTertiary,
                    ),
                  ),
                ),
              ),
          ],
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
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ModernColors.diary.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
            backgroundColor: ModernColors.diary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, size: 22),
              const SizedBox(width: 12),
              Text(
                '새 일기 작성하기',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}