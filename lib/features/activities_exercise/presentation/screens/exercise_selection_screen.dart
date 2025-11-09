// lib/features/activities_exercise/presentation/screens/exercise_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';
import 'exercise_record_screen.dart';
import 'running_record_screen.dart';

class ExerciseSelectionScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const ExerciseSelectionScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  ConsumerState<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState
    extends ConsumerState<ExerciseSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // 운동 종목 데이터 (색상별 분류 - 캘린더 구분용)
  final List<Map<String, String>> _exercises = [
    {'name': '헬스', 'emoji': '💪', 'color': '0xFF1F2937'}, // 검은색 - 묵직한 쇠질 느낌
    {'name': '러닝', 'emoji': '🏃‍♂️', 'color': '0xFF059669'}, // 초록색 - 자연적인 운동
    {'name': '등산', 'emoji': '🥾', 'color': '0xFF059669'}, // 초록색 - 자연적인 운동
    {'name': '수영', 'emoji': '🏊‍♂️', 'color': '0xFF059669'}, // 초록색 - 자연적인 운동
    {'name': '자전거', 'emoji': '🚴‍♂️', 'color': '0xFF059669'}, // 초록색 - 자연적인 운동
    {'name': '요가', 'emoji': '🧘‍♀️', 'color': '0xFF8B5CF6'}, // 보라색 - 몸과 소통하는 느낌
    {
      'name': '필라테스',
      'emoji': '🤸‍♀️',
      'color': '0xFF8B5CF6'
    }, // 보라색 - 몸과 소통하는 느낌
    {
      'name': '클라이밍',
      'emoji': '🧗‍♂️',
      'color': '0xFF8B5CF6'
    }, // 보라색 - 몸과 소통하는 느낌
    {'name': '테니스', 'emoji': '🎾', 'color': '0xFFFBBF24'}, // 노란색 - 밝은 느낌
    {'name': '배드민턴', 'emoji': '🏸', 'color': '0xFFFBBF24'}, // 노란색 - 밝은 느낌
    {'name': '골프', 'emoji': '⛳', 'color': '0xFFFBBF24'}, // 노란색 - 밝은 느낌
    {'name': '축구', 'emoji': '⚽', 'color': '0xFFEF4444'}, // 빨간색 - 타오르는 열정
    {'name': '농구', 'emoji': '🏀', 'color': '0xFFEF4444'}, // 빨간색 - 타오르는 열정
  ];

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
    return Scaffold(
      backgroundColor: ModernColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ModernColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: ModernColors.getElevationShadow(2),
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
            // 배경 그라데이션 (오렌지 계열)
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ModernColors.exercise,
                    ModernColors.exercise.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // 메인 콘텐츠
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  // 헤더 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeader(),
                  ),

                  const SizedBox(height: 32),

                  // 운동 목록
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildExerciseList(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final targetDate = widget.selectedDate;
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[(targetDate.weekday - 1) % 7];
    final dateStr = '${targetDate.year}년 ${targetDate.month}월 ${targetDate.day}일';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: ModernColors.premiumShadow(
          primaryColor: ModernColors.exercise,
          lightColor: ModernColors.exerciseLight,
        ),
      ),
      child: Column(
        children: [
          // 제목과 아이콘
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.exercise,
                      ModernColors.exercise.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.exercise.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '운동 종목 선택',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.exercise,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '어떤 운동을 하셨나요?',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
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

          // 날짜 정보 - Borderless Design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.exercise.withValues(alpha: 0.05),
                  ModernColors.exercise.withValues(alpha: 0.08),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.exercise.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: ModernColors.exercise,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  dateStr,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.exercise,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  weekday,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.exercise,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.textTertiary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          final isLast = index == _exercises.length - 1;

          return _buildExerciseItem(
            exercise['name']!,
            exercise['emoji']!,
            Color(int.parse(exercise['color']!)),
            isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseItem(
      String name, String emoji, Color categoryColor, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedbackManager.lightImpact();

          // 러닝 선택 시 러닝 전용 화면으로 분기
          if (name == '러닝') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RunningRecordScreen(
                  selectedDate: widget.selectedDate,
                ),
              ),
            );
          } else {
            // 다른 운동은 기존 화면으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseRecordScreen(
                  exerciseType: name,
                  selectedDate: widget.selectedDate,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.vertical(
          top: isLast ? Radius.zero : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: ModernColors.textTertiary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
          ),
          child: Row(
            children: [
              // 운동 이모지
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 운동 이름
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ),

              // 색상 동그라미 (캘린더 구분용)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 12),

              // 화살표 아이콘
              const Icon(
                Icons.chevron_right,
                color: ModernColors.exercise,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
