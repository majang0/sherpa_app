// lib/features/daily_record/presentation/screens/exercise_record_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/record_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../widgets/running_record_form.dart';
import '../widgets/climbing_record_form.dart';
import '../widgets/hiking_record_form.dart';
import '../widgets/gym_record_form.dart';
import '../widgets/badminton_record_form.dart';

class ExerciseRecordScreen extends ConsumerStatefulWidget {
  final String exerciseType;
  final DateTime selectedDate;

  const ExerciseRecordScreen({
    super.key,
    required this.exerciseType,
    required this.selectedDate,
  });

  @override
  ConsumerState<ExerciseRecordScreen> createState() => _ExerciseRecordScreenState();
}

class _ExerciseRecordScreenState extends ConsumerState<ExerciseRecordScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: SherpaCleanAppBar(
        title: '${widget.exerciseType} 기록하기',
        backgroundColor: const Color(0xFFF8FAFC),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 헤더 섹션
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // 선택된 운동에 맞는 폼 표시
              _buildExerciseForm(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][widget.selectedDate.weekday % 7];
    final exerciseColor = _getExerciseColor(widget.exerciseType);
    final exerciseEmoji = _getExerciseEmoji(widget.exerciseType);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            exerciseColor,
            exerciseColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: exerciseColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  exerciseEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.exerciseType} 기록하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.selectedDate.month}월 ${widget.selectedDate.day}일 ($dayOfWeek)',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '상세 정보를 입력해주세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseForm() {
    switch (widget.exerciseType) {
      case '러닝':
        return RunningRecordForm(selectedDate: widget.selectedDate);
      case '클라이밍':
        return ClimbingRecordForm(selectedDate: widget.selectedDate);
      case '등산':
        return HikingRecordForm(selectedDate: widget.selectedDate);
      case '헬스':
        return GymRecordForm(selectedDate: widget.selectedDate);
      case '배드민턴':
        return BadmintonRecordForm(selectedDate: widget.selectedDate);
      default:
        return _buildUnsupportedExerciseForm();
    }
  }

  Widget _buildUnsupportedExerciseForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
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
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: RecordColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.exerciseType} 기록 폼은 준비 중입니다',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RecordColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '곧 업데이트 예정입니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: RecordColors.textSecondary,
            ),
          ),
        ],
      ),
    );
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
      case '러닝':
        return '🏃';
      case '클라이밍':
        return '🧗';
      case '등산':
        return '🥾';
      case '헬스':
        return '🏋️';
      case '배드민턴':
        return '🏸';
      default:
        return '💪';
    }
  }
}