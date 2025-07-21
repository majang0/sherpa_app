// lib/features/daily_record/widgets/exercise_full_view_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/record_colors.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import '../presentation/screens/exercise_detail_screen.dart';

class ExerciseFullViewWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExerciseFullViewWidget> createState() => _ExerciseFullViewWidgetState();
}

class _ExerciseFullViewWidgetState extends ConsumerState<ExerciseFullViewWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  DateTime _selectedMonth = DateTime.now();
  String? _selectedExerciseType;
  
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
    final exerciseLogs = user.dailyRecords.exerciseLogs;
    
    // 선택된 월의 운동 로그 필터링
    final monthlyLogs = exerciseLogs.where((log) {
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
                    const Color(0xFFF97316),
                    const Color(0xFFF97316).withOpacity(0.7),
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
                  
                  // 필터 섹션
                  if (exerciseLogs.isNotEmpty)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildFilterSection(exerciseLogs),
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

  Widget _buildHeader(List<ExerciseLog> monthlyLogs) {
    final user = ref.watch(globalUserProvider);
    final totalExercises = user.dailyRecords.exerciseLogs.length;
    final monthlyCount = monthlyLogs.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.2),
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
                      const Color(0xFFF97316),
                      const Color(0xFFEA580C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF97316).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fitness_center,
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
                      '운동 기록 전체보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF97316),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '건강한 운동 습관의 기록들',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: RecordColors.textSecondary,
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
              color: const Color(0xFFF97316).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF97316).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month,
                  color: const Color(0xFFF97316),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedMonth.year}년 ${_selectedMonth.month}월 • ${monthlyCount}개 운동 • 총 ${totalExercises}개',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF97316),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigationHeader(List<ExerciseLog> monthlyLogs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF97316).withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                });
                HapticFeedbackManager.lightImpact();
              },
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.chevron_left_rounded,
                color: const Color(0xFFF97316),
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
                      color: RecordColors.textPrimary,
                    ),
                  ),
                  Text(
                    _getMonthMessage(monthlyLogs),
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: RecordColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                });
                HapticFeedbackManager.lightImpact();
              },
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFF97316),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(List<ExerciseLog> exerciseLogs) {
    // 색상 카테고리별로 정렬된 운동 종류 순서
    final orderedTypes = [
      // 묵직한 쇠질 운동 (검은색)
      '헬스',
      // 자연적인 운동 (초록색)
      '등산', '러닝', '수영', '자전거',
      // 몸과 소통하는 운동 (보라색)  
      '요가', '클라이밍', '필라테스',
      // 밝은 라켓/도구 운동 (노란색)
      '골프', '배드민턴', '테니스',
      // 열정적인 팀 스포츠 (빨간색)
      '농구', '축구',
    ];
    
    final availableTypes = exerciseLogs.map((e) => e.exerciseType).toSet();
    final uniqueTypes = orderedTypes.where((type) => availableTypes.contains(type)).toList();
    
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.filter_alt,
                    color: Color(0xFFF97316),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '운동 종류',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildFilterChip('전체', null, exerciseLogs),
                ...uniqueTypes.map((type) => _buildFilterChip(type, type, exerciseLogs)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, List<ExerciseLog> exerciseLogs) {
    final isSelected = _selectedExerciseType == value;
    final count = value == null 
        ? exerciseLogs.length 
        : exerciseLogs.where((log) => log.exerciseType == value).length;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedExerciseType = value;
        });
        HapticFeedbackManager.lightImpact();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF97316) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFFF97316) : const Color(0xFFF97316).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null) ...[
                  Text(
                    _getExerciseEmoji(value),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : RecordColors.textPrimary,
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
                color: value != null ? _getExerciseColor(value) : const Color(0xFFF97316),
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

  Widget _buildCalendarGrid(List<ExerciseLog> monthlyLogs) {
    // 날짜별로 운동 그룹화
    final exercisesByDate = <DateTime, List<ExerciseLog>>{};
    for (final log in monthlyLogs) {
      final date = DateTime(log.date.year, log.date.month, log.date.day);
      if (_selectedExerciseType == null || log.exerciseType == _selectedExerciseType) {
        exercisesByDate[date] = [...(exercisesByDate[date] ?? []), log];
      }
    }
    
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: RecordColors.background.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: RecordColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '운동한 날을 탭하면 상세 정보를 볼 수 있어요',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: RecordColors.textSecondary,
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
                          final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
                          final isCurrentMonth = date.month == _selectedMonth.month;
                          final isToday = _isSameDay(date, DateTime.now());
                          final dayExercises = exercisesByDate[DateTime(date.year, date.month, date.day)] ?? [];

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: _buildCalendarDay(date, isCurrentMonth, isToday, dayExercises),
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

  Widget _buildActionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedbackManager.mediumImpact();
          Navigator.pushNamed(
            context,
            '/exercise_selection',
            arguments: DateTime.now(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97316),
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              '운동 기록 추가하기',
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

  void _showDayExercisesModal(DateTime day, List<ExerciseLog> exercises) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                color: RecordColors.textLight,
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
                        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withOpacity(0.3),
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
                          '${day.year}년 ${day.month}월 ${day.day}일',
                          style: GoogleFonts.notoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: RecordColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${exercises.length}개의 운동 • 총 ${exercises.fold(0, (sum, e) => sum + e.durationMinutes)}분',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: RecordColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: RecordColors.textLight),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // 운동 목록
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final exerciseColor = _getExerciseColor(exercise.exerciseType);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseDetailScreen(exercise: exercise),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: exerciseColor.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: exerciseColor.withOpacity(0.1),
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
                                    colors: [exerciseColor, exerciseColor.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: exerciseColor.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _getExerciseEmoji(exercise.exerciseType),
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
                                      exercise.exerciseType,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: exerciseColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 14,
                                          color: RecordColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${exercise.durationMinutes}분',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: RecordColors.textSecondary,
                                          ),
                                        ),
                                        if (exercise.note != null) ...[
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.note,
                                            size: 14,
                                            color: RecordColors.textSecondary,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: exerciseColor.withOpacity(0.6),
                              ),
                            ],
                          ),
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
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getExerciseColor(String exerciseType) {
    switch (exerciseType) {
      // 초록색 - 자연적인 운동
      case '걷기':
      case '등산':
      case '러닝':
      case '수영':
      case '자전거':
        return const Color(0xFF059669);
      
      // 보라색 - 몸과 소통하는 운동
      case '요가':
      case '클라이밍':
      case '필라테스':
        return const Color(0xFF8B5CF6);
      
      // 검은색 - 묵직한 쇠질 느낌
      case '헬스':
        return const Color(0xFF1F2937);
      
      // 노란색 - 밝은 느낌
      case '골프':
      case '배드민턴':
      case '테니스':
        return const Color(0xFFFBBF24);
      
      // 빨간색 - 타오르는 열정
      case '농구':
      case '축구':
        return const Color(0xFFEF4444);
      
      // 주황색 - 기타
      default:
        return const Color(0xFFF97316);
    }
  }

  String _getExerciseEmoji(String exerciseType) {
    switch (exerciseType) {
      case '러닝': return '🏃';
      case '걷기': return '🚶';
      case '자전거': return '🚴';
      case '수영': return '🏊';
      case '요가': return '🧘';
      case '헬스': return '🏋️';
      case '필라테스': return '🤸';
      case '테니스': return '🎾';
      case '축구': return '⚽';
      case '농구': return '🏀';
      case '클라이밍': return '🧗';
      case '등산': return '🥾';
      case '배드민턴': return '🏸';
      case '골프': return '⛳';
      default: return '💪';
    }
  }

  String _getMonthMessage(List<ExerciseLog> monthlyLogs) {
    final count = monthlyLogs.length;
    if (count == 0) {
      return '아직 운동 기록이 없어요';
    } else if (count <= 3) {
      return '좋은 시작이에요!';
    } else if (count <= 10) {
      return '활발한 운동 습관 중!';
    } else {
      return '정말 꾸준하시네요!';
    }
  }


  Widget _buildWeekdayHeaders() {
    return Row(
      children: ['일', '월', '화', '수', '목', '금', '토'].map((day) => 
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              day,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: RecordColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildCalendarDay(DateTime date, bool isCurrentMonth, bool isToday, List<ExerciseLog> dayExercises) {
    final hasExercise = dayExercises.isNotEmpty;
    final isFuture = date.isAfter(DateTime.now().subtract(const Duration(hours: 1)));
    final isClickable = isCurrentMonth && hasExercise;

    return GestureDetector(
      onTap: isClickable ? () => _showDayExercisesModal(date, dayExercises) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          gradient: isToday 
              ? LinearGradient(
                  colors: [const Color(0xFFF97316), const Color(0xFFEA580C)],
                )
              : null,
          color: !isToday 
              ? (hasExercise 
                  ? const Color(0xFFF97316).withOpacity(0.1)
                  : (isFuture 
                      ? Colors.grey.shade200.withOpacity(0.5)
                      : (isCurrentMonth ? Colors.white : Colors.grey.shade100.withOpacity(0.3))))
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday 
                ? Colors.transparent
                : (hasExercise 
                    ? const Color(0xFFF97316).withOpacity(0.3)
                    : (isCurrentMonth ? RecordColors.textLight.withOpacity(0.1) : Colors.transparent)),
            width: 1.5,
          ),
          boxShadow: hasExercise || isToday ? [
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ] : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 날짜 표시 (상단)
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isCurrentMonth
                          ? (isToday 
                              ? Colors.white 
                              : (hasExercise 
                                  ? const Color(0xFFF97316) 
                                  : RecordColors.textPrimary))
                          : RecordColors.textLight,
                    ),
                  ),
                ),
              ),
              
              // 운동 도트 표시 (하단)
              if (hasExercise) ...[
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: _buildExerciseDots(dayExercises, isToday),
                  ),
                ),
              ] else ...[
                const Expanded(flex: 1, child: SizedBox()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseDots(List<ExerciseLog> exercises, bool isToday) {
    // 최대 3개의 도트만 표시하고 4개 이상이면 + 추가
    final displayExercises = exercises.take(3).toList();
    final hasMore = exercises.length > 3;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 운동 도트들
            ...displayExercises.map((exercise) => Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: isToday 
                    ? Colors.white.withOpacity(0.9)
                    : _getExerciseColor(exercise.exerciseType),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getExerciseColor(exercise.exerciseType).withOpacity(0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            )),
          ],
        ),
        // + 표시를 3번째 원 오른쪽 위에 배치
        if (hasMore)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isToday 
                    ? Colors.white.withOpacity(0.9)
                    : RecordColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isToday 
                      ? Colors.white.withOpacity(0.3)
                      : RecordColors.textSecondary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '+',
                  style: GoogleFonts.notoSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: isToday 
                        ? RecordColors.textPrimary
                        : RecordColors.textSecondary,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}