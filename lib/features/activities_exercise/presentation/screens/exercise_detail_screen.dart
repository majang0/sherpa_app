// lib/features/activities_exercise/presentation/screens/exercise_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/widgets/sherpa_button.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';
import 'package:sherpa_app/shared/utils/calorie_calculator.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final ExerciseLog exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late ExerciseLog _currentExercise;

  @override
  void initState() {
    super.initState();

    // Initialize current exercise with the provided data
    _currentExercise = widget.exercise;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Progress bar animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 7.0 / 10).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();

    // Start progress animation after fade
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
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
            child: IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: ModernColors.exercise, size: 20),
              onPressed: _editExercise,
              tooltip: '수정하기',
            ),
          ),
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
            child: IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: ModernColors.error, size: 20),
              onPressed: _showDeleteDialog,
              tooltip: '삭제하기',
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
                  _buildHeader()
                      .animate()
                      .slide(duration: 600.ms, delay: 100.ms),

                  const SizedBox(height: 32),

                  // 운동 세부 정보 카드
                  _buildDetailsCard()
                      .animate()
                      .slide(duration: 600.ms, delay: 300.ms),

                  const SizedBox(height: 20),

                  // 성취도 카드
                  _buildAchievementCard()
                      .animate()
                      .slide(duration: 600.ms, delay: 400.ms),

                  const SizedBox(height: 20),

                  // 사진 카드 (항상 표시)
                  _buildPhotoCard()
                      .animate()
                      .slide(duration: 600.ms, delay: 500.ms),

                  const SizedBox(height: 20),

                  // 메모 카드 (메모가 있는 경우만)
                  if (_currentExercise.note != null &&
                      _currentExercise.note!.isNotEmpty)
                    _buildNotesCard()
                        .animate()
                        .slide(duration: 600.ms, delay: 600.ms),

                  const SizedBox(height: 20),

                  // 커뮤니티 공유 정보
                  _buildCommunityCard()
                      .animate()
                      .slide(duration: 600.ms, delay: 700.ms),

                  const SizedBox(height: 20),

                  // 액션 버튼들
                  _buildActionButtons()
                      .animate()
                      .slide(duration: 600.ms, delay: 800.ms),

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
    final exerciseEmoji = _getExerciseEmoji(_currentExercise.exerciseType);
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[(_currentExercise.date.weekday - 1) % 7];
    final dateStr =
        '${_currentExercise.date.year}년 ${_currentExercise.date.month}월 ${_currentExercise.date.day}일';

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
                    exerciseEmoji,
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
                      '${_currentExercise.exerciseType} 상세',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.exercise,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '운동 기록을 확인하세요',
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

  Widget _buildDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ModernColors.exercise.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
                  color: ModernColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 요약',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 사용자 친화적 운동 정보
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ModernColors.exercise.withValues(alpha: 0.1),
                  ModernColors.exercise.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ModernColors.exercise.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getExerciseEmoji(_currentExercise.exerciseType),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentExercise.exerciseType,
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ModernColors.exercise,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_currentExercise.durationMinutes}분 동안 운동했어요',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ModernColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: ModernColors.error,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_calculateCalories()}kcal',
                              style: GoogleFonts.notoSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: ModernColors.error,
                              ),
                            ),
                            Text(
                              '소모 칼로리',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ModernColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getIntensityIcon(_currentExercise.intensity),
                              color: _getIntensityColor(
                                  _currentExercise.intensity),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getIntensityLabel(_currentExercise.intensity),
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _getIntensityColor(
                                    _currentExercise.intensity),
                              ),
                            ),
                            Text(
                              '운동 강도',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ModernColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: ModernColors.exercise,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDateTime(_currentExercise.date),
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard() {
    // Note: Since ExerciseLog doesn't have achievement score yet, we'll show a placeholder
    // In production, this would come from the actual exercise data
    const achievementScore = 7.0; // Default score for display

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ModernColors.exercise.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: ModernColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 성취도',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Achievement score display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ModernColors.exercise.withValues(alpha: 0.05),
                  ModernColors.exercise.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ModernColors.exercise.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ModernColors.exercise.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '💪',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${achievementScore.toInt()}/10',
                          style: GoogleFonts.notoSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: ModernColors.exercise,
                          ),
                        ),
                        Text(
                          _getAchievementLabel(achievementScore),
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Visual progress bar with animation
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: ModernColors.exercise.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ModernColors.exercise,
                                ModernColors.exercise.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: ModernColors.exercise
                                    .withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ModernColors.exercise.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_camera,
                  color: ModernColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 사진',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _currentExercise.hasPhoto &&
                    _currentExercise.imageUrl!.startsWith('http')
                ? () => _showFullScreenPhoto(context)
                : null,
            child: Hero(
              tag: 'exercise_photo_${_currentExercise.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _currentExercise.hasPhoto
                    ? (_currentExercise.imageUrl!.startsWith('http')
                        ? Image.network(
                            _currentExercise.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey.shade100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '사진을 불러올 수 없습니다',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey.shade100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '로컬 사진',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ))
                    : Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernColors.exercise.withValues(alpha: 0.03),
                              ModernColors.exercise.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color:
                                  ModernColors.exercise.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '운동 사진이 없습니다',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ModernColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '수정하기에서 사진을 추가해보세요',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ModernColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenPhoto(BuildContext context) {
    HapticFeedbackManager.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'exercise_photo_${_currentExercise.id}',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    _currentExercise.imageUrl!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    HapticFeedbackManager.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ModernColors.exercise.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _currentExercise.isShared
                  ? ModernColors.exercise.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _currentExercise.isShared ? Icons.group : Icons.lock,
              color: _currentExercise.isShared
                  ? ModernColors.exercise
                  : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentExercise.isShared ? '커뮤니티 공유됨' : '비공개 기록',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentExercise.isShared
                      ? '다른 사용자들이 이 운동 기록을 볼 수 있습니다'
                      : '이 운동 기록은 나만 볼 수 있습니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _currentExercise.isShared
                  ? ModernColors.exercise.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentExercise.isShared ? '공개' : '비공개',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _currentExercise.isShared
                    ? ModernColors.exercise
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ModernColors.exercise.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.book,
                  color: ModernColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 일기',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentExercise.note!,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ModernColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SherpaButton(
              text: '수정하기',
              onPressed: _editExercise,
              backgroundColor: ModernColors.exercise,
              height: 56,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SherpaButton(
              text: '삭제하기',
              onPressed: _showDeleteDialog,
              backgroundColor: ModernColors.error,
              height: 56,
            ),
          ),
        ],
      ),
    );
  }

  void _editExercise() async {
    HapticFeedbackManager.lightImpact();
    final result = await Navigator.pushNamed(
      context,
      '/exercise_edit',
      arguments: _currentExercise,
    );

    // If edit screen returned updated data, refresh the display
    if (result != null && result is ExerciseLog) {
      setState(() {
        _currentExercise = result;
      });
    }
  }

  void _showDeleteDialog() {
    HapticFeedbackManager.lightImpact();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: ModernColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '운동 기록 삭제',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            '이 운동 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textSecondary,
                ),
              ),
            ),
            SherpaButton(
              text: '삭제',
              onPressed: _deleteExercise,
              backgroundColor: ModernColors.error,
              height: 40,
              width: 80,
            ),
          ],
        );
      },
    );
  }

  void _deleteExercise() async {
    try {
      // 실제 삭제 로직 구현
      final globalUserNotifier = ref.read(globalUserProvider.notifier);
      await globalUserNotifier.deleteExerciseRecord(_currentExercise.id);

      if (mounted) {
        Navigator.pop(context); // 다이얼로그 닫기
        Navigator.pop(context); // 상세 화면 닫기

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '운동 기록이 삭제되었습니다.',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: ModernColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 다이얼로그 닫기

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '삭제 중 오류가 발생했습니다: $e',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: ModernColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
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
      case '수영':
        return '🏊';
      case '자전거':
        return '🚴';
      case '요가':
        return '🧘';
      case '골프':
        return '⛳';
      case '축구':
        return '⚽';
      case '농구':
        return '🏀';
      case '테니스':
        return '🎾';
      default:
        return '💪';
    }
  }

  String _getIntensityLabel(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '낮음':
      case 'light':
        return '편안함';
      case 'medium':
      case '보통':
      case 'moderate':
        return '적당함';
      case 'high':
      case '높음':
      case 'vigorous':
        return '힘듦';
      case 'very_high':
      case '매우높음':
      case 'extreme':
        return '매우 힘듦';
      default:
        return '적당함'; // 기본값을 한국어로 변경
    }
  }

  String _formatDateTime(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[date.weekday % 7];
    return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday) ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  int _calculateCalories() {
    return CalorieCalculator.calculateCalories(
      exerciseType: _currentExercise.exerciseType,
      durationMinutes: _currentExercise.durationMinutes,
      intensity: _currentExercise.intensity,
    );
  }

  IconData _getIntensityIcon(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '낮음':
        return Icons.spa;
      case 'medium':
      case '보통':
        return Icons.directions_walk;
      case 'high':
      case '높음':
        return Icons.directions_run;
      case 'very_high':
      case '매우높음':
        return Icons.whatshot;
      default:
        return Icons.directions_walk;
    }
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
      case '낮음':
        return ModernColors.success;
      case 'medium':
      case '보통':
        return ModernColors.warning;
      case 'high':
      case '높음':
        return ModernColors.error;
      case 'very_high':
      case '매우높음':
        return ModernColors.modernAccent;
      default:
        return ModernColors.warning;
    }
  }

  String _getAchievementLabel(double score) {
    if (score >= 9) return '최고의 운동이었어요! 🏆';
    if (score >= 7) return '정말 만족스러운 운동! 💪';
    if (score >= 5) return '괜찮은 운동이었어요 👍';
    if (score >= 3) return '조금 아쉬웠어요 😅';
    return '다음엔 더 잘할 수 있어요! 💫';
  }
}
