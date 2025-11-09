// lib/features/activities_exercise/presentation/screens/running_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/widgets/sherpa_button.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';
import 'package:sherpa_app/shared/utils/snackbar_utils.dart';
import 'package:sherpa_app/features/activities_exercise/utils/running_record_helper.dart';
import '../../models/detailed_exercise_models.dart';
import 'running_edit_screen.dart';

class RunningDetailScreen extends ConsumerStatefulWidget {
  final RunningRecord runningRecord;

  const RunningDetailScreen({
    super.key,
    required this.runningRecord,
  });

  @override
  ConsumerState<RunningDetailScreen> createState() =>
      _RunningDetailScreenState();
}

class _RunningDetailScreenState extends ConsumerState<RunningDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late RunningRecord _currentRunning;

  @override
  void initState() {
    super.initState();

    // Initialize current running with the provided data
    _currentRunning = widget.runningRecord;

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
        leading: Semantics(
          label: '뒤로 가기',
          button: true,
          child: Container(
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
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        ),
        actions: [
          Semantics(
            label: '러닝 기록 수정',
            button: true,
            hint: '러닝 기록을 수정합니다',
            child: Container(
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
                onPressed: _editRunning,
                tooltip: '수정하기',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ),
          Semantics(
            label: '러닝 기록 삭제',
            button: true,
            hint: '러닝 기록을 삭제합니다',
            child: Container(
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
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
                  _buildHeader()
                      .animate()
                      .slide(duration: 600.ms, delay: 100.ms),

                  const SizedBox(height: 32),

                  // 러닝 세부 정보 카드
                  _buildRunningDetailsCard()
                      .animate()
                      .slide(duration: 600.ms, delay: 200.ms),

                  const SizedBox(height: 20),

                  // 페이스 & 시간 카드
                  _buildPaceAndTimeCard()
                      .animate()
                      .slide(duration: 600.ms, delay: 300.ms),

                  const SizedBox(height: 20),

                  // 성취도 카드 (난이도가 있는 경우)
                  if (_currentRunning.difficulty != null)
                    _buildAchievementCard()
                        .animate()
                        .slide(duration: 600.ms, delay: 400.ms),

                  if (_currentRunning.difficulty != null)
                    const SizedBox(height: 20),

                  // 사진 카드 (항상 표시)
                  _buildPhotoCard()
                      .animate()
                      .slide(duration: 600.ms, delay: 500.ms),

                  const SizedBox(height: 20),

                  // 메모 카드 (메모가 있는 경우만)
                  if (_currentRunning.note != null &&
                      _currentRunning.note!.isNotEmpty)
                    _buildNotesCard()
                        .animate()
                        .slide(duration: 600.ms, delay: 600.ms),

                  if (_currentRunning.note != null &&
                      _currentRunning.note!.isNotEmpty)
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
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[(_currentRunning.date.weekday - 1) % 7];
    final dateStr =
        '${_currentRunning.date.year}년 ${_currentRunning.date.month}월 ${_currentRunning.date.day}일';

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
                child: const Center(
                  child: Text(
                    '🏃',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '러닝 기록 상세',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.exercise,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '러닝 기록을 확인하세요',
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

  Widget _buildRunningDetailsCard() {
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
                '러닝 요약',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 거리 정보
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _currentRunning.distanceKm.toStringAsFixed(1),
                      style: GoogleFonts.notoSans(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.exercise,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'km',
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '총 ${_currentRunning.durationMinutes}분 동안 달렸어요',
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
    );
  }

  Widget _buildPaceAndTimeCard() {
    final paceMinutes = _currentRunning.averagePace.floor();
    final paceSeconds = ((_currentRunning.averagePace - paceMinutes) * 60).round();
    final hours = _currentRunning.durationMinutes ~/ 60;
    final minutes = _currentRunning.durationMinutes % 60;

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
                  Icons.speed,
                  color: ModernColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '페이스 & 시간',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              // 페이스
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ModernColors.exercise.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.speed,
                        color: ModernColors.exercise,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$paceMinutes\'${paceSeconds.toString().padLeft(2, '0')}"',
                        style: GoogleFonts.notoSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: ModernColors.exercise,
                        ),
                      ),
                      Text(
                        '평균 페이스',
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
              // 시간
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ModernColors.exercise.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: ModernColors.exercise,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hours > 0 ? '$hours:${minutes.toString().padLeft(2, '0')}:00' : '$minutes:00',
                        style: GoogleFonts.notoSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: ModernColors.exercise,
                        ),
                      ),
                      Text(
                        '총 소요시간',
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
        ],
      ),
    );
  }

  Widget _buildAchievementCard() {
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
                '러닝 난이도',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Difficulty display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _currentRunning.difficulty!.color.withValues(alpha: 0.1),
                  _currentRunning.difficulty!.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _currentRunning.difficulty!.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentRunning.difficulty!.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDifficultyIcon(_currentRunning.difficulty!),
                    color: _currentRunning.difficulty!.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentRunning.difficulty!.label,
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _currentRunning.difficulty!.color,
                      ),
                    ),
                    Text(
                      '체감 난이도',
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
          ),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Icons.spa;
      case DifficultyLevel.moderate:
        return Icons.directions_walk;
      case DifficultyLevel.hard:
        return Icons.directions_run;
      case DifficultyLevel.veryHard:
        return Icons.whatshot;
    }
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
                '러닝 사진',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _currentRunning.hasPhoto
                ? Container(
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
                          '사진 정보',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
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
                          '러닝 사진이 없습니다',
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
        ],
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
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _currentRunning.isShared
                  ? ModernColors.exercise.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _currentRunning.isShared ? Icons.group : Icons.lock,
              color: _currentRunning.isShared
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
                  _currentRunning.isShared ? '커뮤니티 공유됨' : '비공개 기록',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentRunning.isShared
                      ? '다른 사용자들이 이 러닝 기록을 볼 수 있습니다'
                      : '이 러닝 기록은 나만 볼 수 있습니다',
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
              color: _currentRunning.isShared
                  ? ModernColors.exercise.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentRunning.isShared ? '공개' : '비공개',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _currentRunning.isShared
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
                '러닝 일기',
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
              _currentRunning.note!,
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
              onPressed: _editRunning,
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

  void _editRunning() async {
    HapticFeedbackManager.lightImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RunningEditScreen(
          runningRecord: _currentRunning,
        ),
      ),
    );

    // If edit screen returned updated data, refresh the display
    if (result != null && result is RunningRecord) {
      setState(() {
        _currentRunning = result;
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
                '러닝 기록 삭제',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            '이 러닝 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
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
              onPressed: _deleteRunning,
              backgroundColor: ModernColors.error,
              height: 40,
              width: 80,
            ),
          ],
        );
      },
    );
  }

  void _deleteRunning() async {
    try {
      // ExerciseLog 삭제 (GlobalUserProvider)
      final globalUserNotifier = ref.read(globalUserProvider.notifier);
      await globalUserNotifier.deleteExerciseRecord(_currentRunning.id);

      // RunningRecord 삭제 (SharedPreferences) - Using RunningRecordHelper
      await RunningRecordHelper.deleteRecord(_currentRunning.id);

      if (mounted) {
        Navigator.pop(context); // 다이얼로그 닫기
        Navigator.pop(context); // 상세 화면 닫기

        SnackBarUtils.showSuccess(context, '러닝 기록이 삭제되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 다이얼로그 닫기

        SnackBarUtils.showError(context, '삭제 중 오류가 발생했습니다.');
      }
    }
  }
}
