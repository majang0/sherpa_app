// lib/features/daily_record/presentation/screens/exercise_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/record_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import 'exercise_record_screen.dart';

class ExerciseSelectionScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const ExerciseSelectionScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  ConsumerState<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends ConsumerState<ExerciseSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // 운동 종목 데이터
  final List<Map<String, String>> _exercises = [
    {'name': '헬스', 'emoji': '💪', 'color': '0xFF1F2937'}, // 검은색 - 묵직한 쇠질 느낌
    {'name': '러닝', 'emoji': '🏃‍♂️', 'color': '0xFF059669'}, // 초록색 - 자연적인 운동
    {'name': '등산', 'emoji': '🥾', 'color': '0xFF059669'}, // 초록색 - 자연적인 운동
    {'name': '수영', 'emoji': '🏊‍♂️', 'color': '0xFF059669'}, // 초록색 - 자연적인 운동
    {'name': '자전거', 'emoji': '🚴‍♂️', 'color': '0xFF059669'}, // 초록색 - 자연적인 운동
    {'name': '요가', 'emoji': '🧘‍♀️', 'color': '0xFF8B5CF6'}, // 보라색 - 몸과 소통하는 느낌
    {'name': '필라테스', 'emoji': '🤸‍♀️', 'color': '0xFF8B5CF6'}, // 보라색 - 몸과 소통하는 느낌
    {'name': '클라이밍', 'emoji': '🧗‍♂️', 'color': '0xFF8B5CF6'}, // 보라색 - 몸과 소통하는 느낌
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
        ),
        centerTitle: true,
        title: Text(
          '운동 종목 선택',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: RecordColors.textPrimary,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
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
      ),
    );
  }

  Widget _buildHeader() {
    final targetDate = widget.selectedDate;
    final dateStr = '${targetDate.month}월 ${targetDate.day}일';
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[targetDate.weekday - 1];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RecordColors.textLight.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              color: const Color(0xFFF97316).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fitness_center,
              color: const Color(0xFFF97316),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 운동을 선택해주세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: RecordColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr ($weekday)',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: RecordColors.textSecondary,
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
          color: RecordColors.textLight.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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

  Widget _buildExerciseItem(String name, String emoji, Color color, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedbackManager.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseRecordScreen(
                exerciseType: name,
                selectedDate: widget.selectedDate,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.vertical(
          top: isLast ? Radius.zero : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            border: isLast ? null : Border(
              bottom: BorderSide(
                color: RecordColors.textLight.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // 운동 이모지
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 22),
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
                    color: RecordColors.textPrimary,
                  ),
                ),
              ),
              
              // 색상 동그라미
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 화살표 아이콘
              Icon(
                Icons.chevron_right,
                color: RecordColors.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }


}