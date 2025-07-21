// lib/features/daily_record/presentation/screens/exercise_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/record_colors.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import 'exercise_edit_screen.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final ExerciseLog exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // 현재 표시되는 운동 기록 (수정 후 업데이트됨)
  late ExerciseLog currentExercise;


  @override
  void initState() {
    super.initState();
    
    // 초기 운동 기록 설정
    currentExercise = widget.exercise;
    
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

  // 수정된 운동 기록 데이터로 업데이트하는 메서드
  void _updateExerciseData(ExerciseLog updatedExercise) {
    if (mounted) {
      setState(() {
        currentExercise = updatedExercise;
      });
    }
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
    final exerciseColor = _getExerciseColor(currentExercise.exerciseType);
    final exerciseEmoji = _getExerciseEmoji(currentExercise.exerciseType);
    
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
        actions: [
          Container(
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
              onPressed: () => _navigateToEdit(),
              icon: Icon(
                Icons.edit,
                color: exerciseColor,
                size: 20,
              ),
            ),
          ),
        ],
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
                    exerciseColor.withOpacity(0.1),
                    exerciseColor.withOpacity(0.05),
                    Colors.transparent,
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
                    child: _buildHeader(exerciseColor, exerciseEmoji),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 운동 정보 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildExerciseInfo(exerciseColor),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 시간 정보 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildTimeInfo(exerciseColor),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 노트 섹션
                  if (currentExercise.note != null && currentExercise.note!.isNotEmpty)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildNoteSection(exerciseColor),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // 액션 버튼들
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildActionButtons(exerciseColor),
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

  Widget _buildHeader(Color exerciseColor, String exerciseEmoji) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: exerciseColor.withOpacity(0.2),
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
                      exerciseColor,
                      exerciseColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: exerciseColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
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
                      currentExercise.exerciseType,
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: exerciseColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(currentExercise.date),
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
          
          const SizedBox(height: 20),
          
          // 요약 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: exerciseColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: exerciseColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  color: exerciseColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${currentExercise.durationMinutes}분 운동 • ${_calculateCalories()}kcal 소모',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: exerciseColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfo(Color exerciseColor) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: exerciseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: exerciseColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '운동 정보',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: exerciseColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow('📅', '날짜', _formatDate(currentExercise.date)),
                  const SizedBox(height: 12),
                  _buildInfoRow('🏃', '운동 타입', currentExercise.exerciseType),
                  const SizedBox(height: 12),
                  _buildInfoRow('💪', '강도', _getExerciseIntensity(currentExercise.exerciseType)),
                  const SizedBox(height: 12),
                  _buildInfoRow('⏱️', '운동 시간', '${currentExercise.durationMinutes}분'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(Color exerciseColor) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: exerciseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.timer,
                    color: exerciseColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '운동 분석',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: exerciseColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatsInfo('시간', '${(currentExercise.durationMinutes / 60).toStringAsFixed(1)}h'),
                  Container(
                    width: 1,
                    height: 40,
                    color: exerciseColor.withOpacity(0.2),
                  ),
                  _buildStatsInfo('분', '${currentExercise.durationMinutes}min'),
                  Container(
                    width: 1,
                    height: 40,
                    color: exerciseColor.withOpacity(0.2),
                  ),
                  _buildStatsInfo('칼로리', '${_calculateCalories()}kcal'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection(Color exerciseColor) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: exerciseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.note_alt,
                    color: exerciseColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '운동 노트',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: exerciseColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                currentExercise.note ?? '',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: RecordColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Color exerciseColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 수정 버튼
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: exerciseColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _navigateToEdit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: exerciseColor,
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
                    child: const Icon(Icons.edit, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '운동 기록 수정',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 삭제 버튼
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _confirmDeleteExercise(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
                    child: const Icon(Icons.delete, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '운동 기록 삭제',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: RecordColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: RecordColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _getExerciseColor(currentExercise.exerciseType),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: RecordColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _navigateToEdit() async {
    HapticFeedbackManager.lightImpact();
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseEditScreen(exercise: currentExercise),
      ),
    );
    
    // 수정 후 돌아왔을 때 데이터 업데이트
    if (result == true) {
      // 글로벌 상태에서 최신 데이터 가져오기
      final user = ref.read(globalUserProvider);
      final updatedExercise = user.dailyRecords.exerciseLogs
          .where((log) => log.id == currentExercise.id)
          .firstOrNull;
      
      if (updatedExercise != null) {
        _updateExerciseData(updatedExercise);
      }
    }
  }

  void _confirmDeleteExercise() {
    HapticFeedbackManager.mediumImpact();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 기록 삭제',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정말로 이 운동 기록을 삭제하시겠습니까?',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: RecordColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _getExerciseEmoji(currentExercise.exerciseType),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentExercise.exerciseType,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: RecordColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${currentExercise.durationMinutes}분',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: RecordColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '삭제된 기록은 복구할 수 없습니다.',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RecordColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteExercise();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '삭제',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteExercise() async {
    try {
      final user = ref.read(globalUserProvider);
      final updatedExerciseLogs = user.dailyRecords.exerciseLogs
          .where((log) => log.id != currentExercise.id)
          .toList();
      
      final updatedRecords = user.dailyRecords.copyWith(
        exerciseLogs: updatedExerciseLogs,
      );
      
      final updatedUser = user.copyWith(dailyRecords: updatedRecords);
      ref.read(globalUserProvider.notifier).state = updatedUser;

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '운동 기록이 삭제되었습니다.',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '삭제 중 오류가 발생했습니다. 다시 시도해주세요.',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays[date.weekday % 7]})';
  }


  String _getExerciseIntensity(String exerciseType) {
    switch (exerciseType) {
      case '러닝':
      case '축구':
      case '농구':
      case '클라이밍':
        return '고강도';
      case '자전거':
      case '수영':
      case '테니스':
      case '배드민턴':
      case '헬스':
        return '중강도';
      case '걷기':
      case '요가':
      case '필라테스':
      case '골프':
        return '저강도';
      case '등산':
        return '중-고강도';
      default:
        return '보통';
    }
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

  int _calculateCalories() {
    const double weight = 70.0;
    double met = 0.0;
    
    switch (currentExercise.exerciseType) {
      case '러닝':
        met = 8.0;
        break;
      case '걷기':
        met = 3.5;
        break;
      case '자전거':
        met = 6.0;
        break;
      case '수영':
        met = 8.0;
        break;
      case '요가':
        met = 2.5;
        break;
      case '헬스':
        met = 6.0;
        break;
      case '필라테스':
        met = 3.0;
        break;
      case '테니스':
        met = 7.0;
        break;
      case '축구':
        met = 7.0;
        break;
      case '농구':
        met = 6.5;
        break;
      case '클라이밍':
        met = 8.0;
        break;
      case '등산':
        met = 6.0;
        break;
      case '배드민턴':
        met = 5.5;
        break;
      case '골프':
        met = 4.5;
        break;
      default:
        met = 4.0;
    }
    
    return ((met * weight * (currentExercise.durationMinutes / 60.0)).round());
  }

  String _getExerciseEmoji(String exerciseType) {
    switch (exerciseType) {
      case '러닝': return '🏃‍♂️';
      case '걷기': return '🚶‍♂️';
      case '자전거': return '🚴‍♂️';
      case '수영': return '🏊‍♂️';
      case '등산': return '🥾';
      case '요가': return '🧘‍♀️';
      case '클라이밍': return '🧗‍♂️';
      case '필라테스': return '🤸‍♀️';
      case '헬스': return '💪';
      case '테니스': return '🎾';
      case '배드민턴': return '🏸';
      case '골프': return '⛳';
      case '축구': return '⚽';
      case '농구': return '🏀';
      default: return '🏃‍♂️';
    }
  }
}