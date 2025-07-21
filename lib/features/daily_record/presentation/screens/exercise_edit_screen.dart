// lib/features/daily_record/presentation/screens/exercise_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/record_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/models/global_user_model.dart';

class ExerciseEditScreen extends ConsumerStatefulWidget {
  final ExerciseLog exercise;
  
  const ExerciseEditScreen({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseEditScreen> createState() => _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends ConsumerState<ExerciseEditScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _noteController = TextEditingController();
  int _durationMinutes = 30;
  bool _isSubmitting = false;

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

    // 기존 운동 데이터 로드
    _noteController.text = widget.exercise.note ?? '';
    _durationMinutes = widget.exercise.durationMinutes;

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
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseColor = _getExerciseColor(widget.exercise.exerciseType);
    
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
              onPressed: _isSubmitting ? null : _saveExercise,
              icon: Icon(
                Icons.check,
                color: _isSubmitting ? Colors.grey : exerciseColor,
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
                    child: _buildHeader(exerciseColor),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 변경 불가능한 정보 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildReadOnlyInfo(exerciseColor),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 운동 시간 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildDurationSection(exerciseColor),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 운동 노트 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildNoteSection(exerciseColor),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 저장 버튼
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSaveButton(exerciseColor),
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

  Widget _buildHeader(Color exerciseColor) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [exerciseColor, exerciseColor.withOpacity(0.8)],
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
            child: Icon(
              Icons.edit,
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
                  '운동 기록 수정',
                  style: GoogleFonts.notoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: exerciseColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '운동 시간과 노트를 수정할 수 있어요',
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
    );
  }

  Widget _buildReadOnlyInfo(Color exerciseColor) {
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
                    color: RecordColors.textLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lock_outlined,
                    color: RecordColors.textSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '변경 불가 정보',
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
                  color: RecordColors.textLight.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildReadOnlyInfoRow('📅', '날짜', _formatDate(widget.exercise.date)),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfoRow(
                    _getExerciseEmoji(widget.exercise.exerciseType), 
                    '운동 종류', 
                    widget.exercise.exerciseType
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfoRow('💪', '운동 강도', _getExerciseIntensity(widget.exercise.exerciseType)),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '운동 종류와 날짜는 수정할 수 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: RecordColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyInfoRow(String emoji, String label, String value) {
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

  Widget _buildDurationSection(Color exerciseColor) {
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
                  '운동 시간',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$_durationMinutes분',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: exerciseColor,
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
                  // 시간 표시
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTimeInfo('시간', '${(_durationMinutes / 60).toStringAsFixed(1)}h'),
                      Container(
                        width: 1,
                        height: 40,
                        color: exerciseColor.withOpacity(0.2),
                      ),
                      _buildTimeInfo('분', '${_durationMinutes}min'),
                      Container(
                        width: 1,
                        height: 40,
                        color: exerciseColor.withOpacity(0.2),
                      ),
                      _buildTimeInfo('칼로리', '${_calculateCalories()}kcal'),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 슬라이더
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: exerciseColor,
                      inactiveTrackColor: exerciseColor.withOpacity(0.2),
                      thumbColor: exerciseColor,
                      overlayColor: exerciseColor.withOpacity(0.2),
                      trackHeight: 6,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                    ),
                    child: Slider(
                      value: _durationMinutes.toDouble(),
                      min: 5.0,
                      max: 180.0,
                      divisions: 35,
                      onChanged: (value) {
                        setState(() {
                          _durationMinutes = value.round();
                        });
                        HapticFeedbackManager.lightImpact();
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 빠른 설정 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickTimeButton(15, exerciseColor),
                      _buildQuickTimeButton(30, exerciseColor),
                      _buildQuickTimeButton(60, exerciseColor),
                      _buildQuickTimeButton(90, exerciseColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _getExerciseColor(widget.exercise.exerciseType),
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

  Widget _buildQuickTimeButton(int minutes, Color exerciseColor) {
    final isSelected = _durationMinutes == minutes;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _durationMinutes = minutes;
        });
        HapticFeedbackManager.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? exerciseColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? exerciseColor : exerciseColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: exerciseColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Text(
          '${minutes}분',
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : exerciseColor,
          ),
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
                    Icons.edit_note,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: exerciseColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '운동에 대한 생각이나 느낌을 자유롭게 적어보세요...',
                  hintStyle: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: RecordColors.textLight,
                  ),
                  counterText: '',
                ),
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

  Widget _buildSaveButton(Color exerciseColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
          onPressed: _isSubmitting ? null : _saveExercise,
          style: ElevatedButton.styleFrom(
            backgroundColor: exerciseColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '수정 완료',
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

  String _formatDate(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays[date.weekday % 7]})';
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
    // 체중 70kg 성인 남성 기준 대략적인 칼로리 계산
    const double weight = 70.0;
    double met = 0.0;
    
    switch (widget.exercise.exerciseType) {
      case '러닝':
        met = 8.0; // 평균 속도 기준
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
    
    // 칼로리 = MET × 체중(kg) × 시간(hour)
    return ((met * weight * (_durationMinutes / 60.0)).round());
  }

  void _saveExercise() async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });

    HapticFeedbackManager.mediumImpact();

    try {
      final updatedExercise = ExerciseLog(
        id: widget.exercise.id,
        date: widget.exercise.date,
        exerciseType: widget.exercise.exerciseType,
        durationMinutes: _durationMinutes,
        intensity: widget.exercise.intensity, // Keep the original intensity
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      // 기존 운동 로그를 찾아서 업데이트
      final user = ref.read(globalUserProvider);
      final updatedExerciseLogs = user.dailyRecords.exerciseLogs.map((log) {
        if (log.id == widget.exercise.id) {
          return updatedExercise;
        }
        return log;
      }).toList().cast<ExerciseLog>();
      
      final updatedRecords = user.dailyRecords.copyWith(
        exerciseLogs: updatedExerciseLogs,
      );
      
      final updatedUser = user.copyWith(dailyRecords: updatedRecords);
      ref.read(globalUserProvider.notifier).state = updatedUser;

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // 상세보기 화면도 닫기
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '운동 기록이 수정되었습니다! 💪',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: _getExerciseColor(widget.exercise.exerciseType),
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
              '수정 중 오류가 발생했습니다. 다시 시도해주세요.',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}