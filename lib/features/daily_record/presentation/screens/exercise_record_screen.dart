// lib/features/daily_record/presentation/screens/exercise_record_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../widgets/unified_exercise_record_form.dart';

class ExerciseRecordScreen extends ConsumerStatefulWidget {
  final String exerciseType;
  final DateTime selectedDate;

  const ExerciseRecordScreen({
    super.key,
    required this.exerciseType,
    required this.selectedDate,
  });

  @override
  ConsumerState<ExerciseRecordScreen> createState() =>
      _ExerciseRecordScreenState();
}

class _ExerciseRecordScreenState extends ConsumerState<ExerciseRecordScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _canSubmit = false;
  bool _isSubmitting = false;
  final GlobalKey<UnifiedExerciseRecordFormState> _formKey =
      GlobalKey<UnifiedExerciseRecordFormState>();

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
        actions: [
          if (_canSubmit)
            Container(
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
              child: TextButton(
                onPressed: _isSubmitting ? null : _submitExercise,
                child: Text(
                  '완료',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _isSubmitting
                        ? ModernColors.textTertiary
                        : ModernColors.exercise,
                  ),
                ),
              ),
            ),
        ],
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
                  const SizedBox(height: 120), // AppBar 공간

                  // 헤더 섹션
                  _buildHeader(),

                  const SizedBox(height: 32),

                  // 선택된 운동에 맞는 폼 표시
                  _buildExerciseForm(),

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
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[(widget.selectedDate.weekday - 1) % 7];
    final dateStr =
        '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withValues(alpha: 0.2),
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
                child: Center(
                  child: Text(
                    _getExerciseEmoji(widget.exerciseType),
                    style: const TextStyle(fontSize: 28),
                  ),
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
                        color: ModernColors.exercise,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘의 운동을 기록하세요',
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.exercise.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 완료 버튼 클릭 시 호출되는 메서드
  Future<void> _submitExercise() async {
    setState(() {
      _isSubmitting = true;
    });

    // GlobalKey를 통해 폼의 submit 메서드 호출
    await _formKey.currentState?.submitExerciseRecord();

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildExerciseForm() {
    // 모든 운동 타입에 대해 통합된 폼을 사용
    return UnifiedExerciseRecordForm(
      key: _formKey,
      selectedDate: widget.selectedDate,
      exerciseType: widget.exerciseType,
      onFormValidityChanged: (isValid) {
        setState(() {
          _canSubmit = isValid;
        });
      },
    );
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.construction,
            size: 64,
            color: ModernColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.exerciseType} 기록 폼은 준비 중입니다',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '곧 업데이트 예정입니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getExerciseColor(String exerciseType) {
    // 모든 운동 타입에 대해 통일된 오렌지 색상 사용
    return ModernColors.exercise;
  }

  IconData _getExerciseIcon(String exerciseType) {
    switch (exerciseType) {
      case '러닝':
        return Icons.directions_run;
      case '걷기':
        return Icons.directions_walk;
      case '수영':
        return Icons.pool;
      case '자전거':
        return Icons.directions_bike;
      case '요가':
        return Icons.self_improvement;
      case '클라이밍':
        return Icons.terrain;
      case '필라테스':
        return Icons.accessibility_new;
      case '헬스':
        return Icons.fitness_center;
      case '골프':
        return Icons.golf_course;
      case '배드민턴':
        return Icons.sports_tennis;
      case '테니스':
        return Icons.sports_tennis;
      case '농구':
        return Icons.sports_basketball;
      case '축구':
        return Icons.sports_soccer;
      case '등산':
        return Icons.landscape;
      default:
        return Icons.fitness_center;
    }
  }

  String _getExerciseEmoji(String exerciseType) {
    switch (exerciseType) {
      case '헬스':
        return '💪';
      case '러닝':
        return '🏃‍♂️';
      case '등산':
        return '🥾';
      case '수영':
        return '🏊‍♂️';
      case '자전거':
        return '🚴‍♂️';
      case '요가':
        return '🧘‍♀️';
      case '필라테스':
        return '🤸‍♀️';
      case '클라이밍':
        return '🧗‍♂️';
      case '테니스':
        return '🎾';
      case '배드민턴':
        return '🏸';
      case '골프':
        return '⛳';
      case '축구':
        return '⚽';
      case '농구':
        return '🏀';
      case '걷기':
        return '🚶‍♂️';
      default:
        return '💪';
    }
  }
}
