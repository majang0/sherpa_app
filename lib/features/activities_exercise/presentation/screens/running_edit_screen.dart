// lib/features/activities_exercise/presentation/screens/running_edit_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import '../../models/detailed_exercise_models.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/widgets/sherpa_button.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';
import 'package:sherpa_app/shared/utils/snackbar_utils.dart';
import 'package:sherpa_app/features/activities_exercise/utils/running_record_helper.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';

class RunningEditScreen extends ConsumerStatefulWidget {
  final RunningRecord runningRecord;

  const RunningEditScreen({
    super.key,
    required this.runningRecord,
  });

  @override
  ConsumerState<RunningEditScreen> createState() => _RunningEditScreenState();
}

class _RunningEditScreenState extends ConsumerState<RunningEditScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _paceMinController = TextEditingController();
  final TextEditingController _paceSecController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  // Form state - initialized with existing data
  late double _distanceKm;
  late int _paceMinutes;
  late int _paceSeconds;
  late int _totalHours;
  late int _totalMinutes;
  late int _totalSeconds;

  DifficultyLevel? _selectedDifficulty;
  double _achievementScore = 7.0; // 운동 성취도 (1-10)
  bool _isShared = false;
  bool _isSubmitting = false;
  File? _selectedImage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize form with existing running data
    _initializeFormData();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  void _initializeFormData() {
    // 거리
    _distanceKm = widget.runningRecord.distanceKm;
    _distanceController.text = _distanceKm.toString();

    // 페이스 (averagePace는 분 단위의 double)
    _paceMinutes = widget.runningRecord.averagePace.floor();
    _paceSeconds = ((widget.runningRecord.averagePace - _paceMinutes) * 60).round();
    _paceMinController.text = _paceMinutes.toString();
    _paceSecController.text = _paceSeconds.toString();

    // 총 시간 (durationMinutes를 시:분:초로 변환)
    final totalMinutes = widget.runningRecord.durationMinutes;
    _totalHours = totalMinutes ~/ 60;
    _totalMinutes = totalMinutes % 60;
    _totalSeconds = 0; // ExerciseLog는 분 단위만 저장하므로 초는 0
    _hoursController.text = _totalHours.toString();
    _minutesController.text = _totalMinutes.toString();
    _secondsController.text = _totalSeconds.toString();

    // 난이도
    _selectedDifficulty = widget.runningRecord.difficulty;

    // 운동 일기
    _detailsController.text = widget.runningRecord.note ?? '';
    _isShared = widget.runningRecord.isShared;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _detailsController.dispose();
    _distanceController.dispose();
    _paceMinController.dispose();
    _paceSecController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
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
          if (_canSubmit())
            Semantics(
              label: '러닝 기록 수정 완료',
              button: true,
              hint: '수정한 러닝 기록을 저장합니다',
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
                child: TextButton(
                  onPressed: _isSubmitting ? null : _updateRunning,
                  child: Text(
                    '수정',
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
            ),
        ],
      ),
      body: ScaleTransition(
        scale: _scaleAnimation,
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

                  // 편집 폼
                  _buildEditForm(),

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ModernColors.exerciseLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ModernColors.exercise.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Text(
              '🏃',
              style: TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '러닝 기록 수정',
                  style: GoogleFonts.notoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(widget.runningRecord.date),
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
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        // Quick summary card
        _buildQuickSummaryCard()
            .animate()
            .fadeIn(duration: 600.ms, delay: 50.ms),
        const SizedBox(height: 24),
        _buildDistanceSection()
            .animate()
            .fadeIn(duration: 600.ms, delay: 100.ms),
        const SizedBox(height: 24),
        _buildPaceSection()
            .animate()
            .fadeIn(duration: 600.ms, delay: 150.ms),
        const SizedBox(height: 24),
        _buildTotalTimeSection()
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms),
        const SizedBox(height: 24),
        _buildDifficultySection()
            .animate()
            .fadeIn(duration: 600.ms, delay: 250.ms),
        const SizedBox(height: 24),
        _buildWorkoutDiarySection()
            .animate()
            .fadeIn(duration: 600.ms, delay: 300.ms),
        const SizedBox(height: 24),
        _buildPhotoSection().animate().fadeIn(duration: 600.ms, delay: 350.ms),
        const SizedBox(height: 24),
        _buildShareToggle().animate().fadeIn(duration: 600.ms, delay: 400.ms),
        const SizedBox(height: 32),
        _buildSubmitButton().animate().fadeIn(duration: 600.ms, delay: 450.ms),
      ],
    );
  }

  Widget _buildQuickSummaryCard() {
    const exerciseColor = ModernColors.exercise;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: exerciseColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: exerciseColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_run,
              color: exerciseColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 설정',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_distanceKm.toStringAsFixed(1)}km · ${_paceMinutes}\'${_paceSeconds.toString().padLeft(2, '0')}"',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedDifficulty != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedDifficulty!.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedDifficulty!.label,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _selectedDifficulty!.color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDistanceSection() {
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
                  Icons.straighten,
                  color: ModernColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '거리 조정',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 거리 입력 필드
          TextField(
            controller: _distanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: GoogleFonts.notoSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: ModernColors.exercise,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0.0',
              hintStyle: GoogleFonts.notoSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade300,
              ),
              suffixText: 'km',
              suffixStyle: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernColors.textSecondary,
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: ModernColors.exercise.withValues(alpha: 0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _distanceKm = double.tryParse(value) ?? _distanceKm;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // 거리 프리셋 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDistancePreset(5.0, '5K'),
              _buildDistancePreset(10.0, '10K'),
              _buildDistancePreset(21.1, '하프'),
              _buildDistancePreset(42.195, '풀코스'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistancePreset(double km, String label) {
    final isSelected = (_distanceKm - km).abs() < 0.01;
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        setState(() {
          _distanceKm = km;
          _distanceController.text = km.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ModernColors.exercise : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${km}km',
              style: GoogleFonts.notoSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : ModernColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaceSection() {
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
                '1km당 페이스',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 페이스 입력 (분'초")
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 분 입력
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _paceMinController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.notoSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: ModernColors.exercise,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.notoSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade300,
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: ModernColors.exercise.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _paceMinutes = int.tryParse(value) ?? _paceMinutes;
                      });
                    }
                  },
                ),
              ),
              Text(
                "'",
                style: GoogleFonts.notoSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              // 초 입력
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _paceSecController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.notoSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: ModernColors.exercise,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '00',
                    hintStyle: GoogleFonts.notoSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade300,
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: ModernColors.exercise.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _paceSeconds = int.tryParse(value) ?? _paceSeconds;
                      });
                    }
                  },
                ),
              ),
              Text(
                '"',
                style: GoogleFonts.notoSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '예: 4분 54초 → 4\'54"',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTimeSection() {
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
                  Icons.access_time,
                  color: ModernColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '총 소요시간',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 시간 입력 (시:분:초)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 시 입력
              Column(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.notoSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.exercise,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: GoogleFonts.notoSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade300,
                        ),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: ModernColors.exercise.withValues(alpha: 0.05),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _totalHours = int.tryParse(value) ?? _totalHours;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '시간',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  ':',
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ),
              // 분 입력
              Column(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.notoSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.exercise,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '00',
                        hintStyle: GoogleFonts.notoSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade300,
                        ),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: ModernColors.exercise.withValues(alpha: 0.05),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _totalMinutes = int.tryParse(value) ?? _totalMinutes;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '분',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  ':',
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ),
              // 초 입력
              Column(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _secondsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.notoSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.exercise,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '00',
                        hintStyle: GoogleFonts.notoSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade300,
                        ),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: ModernColors.exercise.withValues(alpha: 0.05),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _totalSeconds = int.tryParse(value) ?? _totalSeconds;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '초',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '예: 1시간 43분 8초 → 1:43:08',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection() {
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
                  Icons.fitness_center,
                  color: ModernColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '체감 난이도',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '선택',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.exercise,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Difficulty options
          Row(
            children: DifficultyLevel.values.map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: difficulty != DifficultyLevel.values.last ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedbackManager.lightImpact();
                      setState(() {
                        _selectedDifficulty = difficulty;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? difficulty.color
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? difficulty.color
                              : difficulty.color.withValues(alpha: 0.1),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: difficulty.color
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getDifficultyIcon(difficulty),
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            difficulty.label,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
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

  Widget _buildWorkoutDiarySection() {
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
          // 헤더
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '선택',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.exercise,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 성취도 슬라이더
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ModernColors.exercise.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '💪',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '오늘의 성취도',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ModernColors.exercise,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_achievementScore.toInt()}/10',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: ModernColors.exercise,
                    inactiveTrackColor:
                        ModernColors.exercise.withValues(alpha: 0.2),
                    thumbColor: ModernColors.exercise,
                    overlayColor: ModernColors.exercise.withValues(alpha: 0.2),
                    trackHeight: 6.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 20.0),
                  ),
                  child: Slider(
                    value: _achievementScore,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (value) {
                      HapticFeedbackManager.lightImpact();
                      setState(() {
                        _achievementScore = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getAchievementLabel(_achievementScore),
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 운동 일기 입력
          TextField(
            controller: _detailsController,
            maxLines: 3,
            maxLength: 200,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '오늘 뛰면서 어떤 생각이 들었나요?\n새로운 코스는 어땠나요?',
              hintStyle: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
                height: 1.4,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ModernColors.exercise,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              counterStyle: GoogleFonts.notoSans(
                fontSize: 11,
                color: ModernColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAchievementLabel(double score) {
    if (score >= 9) return '최고의 러닝이었어요! 🏆';
    if (score >= 7) return '정말 만족스러운 러닝! 💪';
    if (score >= 5) return '괜찮은 러닝이었어요 👍';
    if (score >= 3) return '조금 아쉬웠어요 😅';
    return '다음엔 더 잘할 수 있어요! 💫';
  }

  Widget _buildPhotoSection() {
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
                  Icons.camera_alt_outlined,
                  color: ModernColors.exercise,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '사진',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '선택',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.exercise,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedImage == null && !widget.runningRecord.hasPhoto) ...[
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ModernColors.exercise.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: ModernColors.exercise.withValues(alpha: 0.6),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '사진 추가하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.exercise.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.photo,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShareToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
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
              color: ModernColors.exercise.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.group_outlined,
              color: ModernColors.exercise,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '커뮤니티 공유',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '러닝 기록을 다른 사용자와 공유합니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isShared,
            onChanged: (value) {
              HapticFeedbackManager.lightImpact();
              setState(() {
                _isShared = value;
              });
            },
            activeColor: ModernColors.exercise,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SherpaButton(
        text: '수정 완료',
        onPressed: _isSubmitting ? null : _submitEditedRunning,
        backgroundColor: ModernColors.exercise,
        height: 56,
        isLoading: _isSubmitting,
      ),
    );
  }

  Future<void> _submitEditedRunning() async {
    setState(() {
      _isSubmitting = true;
    });

    HapticFeedbackManager.heavyImpact();

    try {
      // RunningRecord 업데이트
      final updatedRunningRecord = RunningRecord(
        id: widget.runningRecord.id,
        date: widget.runningRecord.date,
        durationMinutes: (_totalHours * 60) + _totalMinutes,
        location: widget.runningRecord.location,
        distanceKm: _distanceKm,
        difficulty: _selectedDifficulty,
        averagePace: _paceMinutes + (_paceSeconds / 60.0),
        note:
            _detailsController.text.isNotEmpty ? _detailsController.text : null,
        isShared: _isShared,
        imageUrl: _selectedImage?.path ?? widget.runningRecord.imageUrl,
      );

      // ExerciseLog으로 변환하여 저장
      final exerciseLog = ExerciseLog(
        id: updatedRunningRecord.id,
        date: updatedRunningRecord.date,
        exerciseType: '러닝',
        durationMinutes: updatedRunningRecord.durationMinutes,
        intensity: _difficultyToIntensity(_selectedDifficulty),
        note: updatedRunningRecord.note,
        imageUrl: updatedRunningRecord.imageUrl,
        isShared: updatedRunningRecord.isShared,
      );

      // Update the exercise record in global user provider
      final globalUserNotifier = ref.read(globalUserProvider.notifier);
      await globalUserNotifier.updateExerciseRecord(exerciseLog);

      // Save RunningRecord to SharedPreferences - Using RunningRecordHelper
      await RunningRecordHelper.updateRecord(updatedRunningRecord);

      // Show success animation and navigate back
      if (mounted) {
        SnackBarUtils.showSuccess(context, '러닝 기록이 수정되었습니다!');
        Navigator.pop(context, updatedRunningRecord);
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, '수정 중 오류가 발생했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool _canSubmit() {
    return _distanceKm > 0 &&
        _paceMinutes > 0 &&
        (_totalHours > 0 || _totalMinutes > 0);
  }

  void _updateRunning() {
    _submitEditedRunning();
  }

  String _formatDate(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[date.weekday % 7];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }

  String _difficultyToIntensity(DifficultyLevel? difficulty) {
    if (difficulty == null) {
      return 'medium';
    }

    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'low';
      case DifficultyLevel.moderate:
        return 'medium';
      case DifficultyLevel.hard:
        return 'high';
      case DifficultyLevel.veryHard:
        return 'high';
    }
  }

  Future<void> _pickImage() async {
    HapticFeedbackManager.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: ModernColors.exercise.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: ModernColors.exercise,
                ),
                title: Text(
                  '카메라로 촬영',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1080,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );

                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: ModernColors.exercise,
                ),
                title: Text(
                  '갤러리에서 선택',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1080,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );

                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
