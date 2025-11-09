// lib/features/activities_exercise/presentation/widgets/running_record_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import '../../models/detailed_exercise_models.dart';
import '../../services/running_image_analyzer.dart';
import '../../utils/running_record_helper.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';
import 'package:sherpa_app/shared/utils/exercise_utils.dart';
import 'package:sherpa_app/shared/utils/snackbar_utils.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/widgets/sherpa_button.dart';

class RunningRecordForm extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Function(bool)? onFormValidityChanged;

  const RunningRecordForm({
    super.key,
    required this.selectedDate,
    this.onFormValidityChanged,
  });

  @override
  ConsumerState<RunningRecordForm> createState() => RunningRecordFormState();
}

// public으로 변경하여 GlobalKey에서 접근 가능하도록 함
class RunningRecordFormState extends ConsumerState<RunningRecordForm>
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

  // Form state
  double? _distanceKm; // 거리 (km)
  int? _paceMinutes; // 1km당 페이스 (분)
  int? _paceSeconds; // 1km당 페이스 (초)
  int? _totalHours; // 총 시간 (시)
  int? _totalMinutes; // 총 시간 (분)
  int? _totalSeconds; // 총 시간 (초)

  DifficultyLevel? _selectedDifficulty; // 체감 난이도
  double? _achievementScore; // 운동 성취도 (1-10)
  bool _isShared = false;
  bool _isSubmitting = false; // 제출 중 상태
  File? _selectedImage;

  // AI 분석 상태
  bool _isAnalyzing = false;
  String? _analysisError;

  final ImagePicker _imagePicker = ImagePicker();
  final RunningImageAnalyzer _imageAnalyzer = RunningImageAnalyzer();

  @override
  void initState() {
    super.initState();

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

    // 초기 폼 유효성 상태 전달
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFormValidity();
    });

    // TextField 리스너 추가
    _distanceController.addListener(_updateDistanceFromText);
  }

  void _updateDistanceFromText() {
    final text = _distanceController.text;
    if (text.isNotEmpty) {
      final parsed = double.tryParse(text);
      if (parsed != null && parsed != _distanceKm) {
        setState(() {
          _distanceKm = parsed;
        });
        _checkFormValidity();
      }
    }
  }

  void _checkFormValidity() {
    final bool isValid = _distanceKm != null &&
        _paceMinutes != null &&
        _paceSeconds != null &&
        (_totalHours != null || _totalMinutes != null || _totalSeconds != null);

    widget.onFormValidityChanged?.call(isValid);
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          // AI 분석 버튼 섹션
          _buildAIAnalysisSection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 50.ms),
          const SizedBox(height: 24),

          // 거리 입력
          _buildDistanceSection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 100.ms),
          const SizedBox(height: 24),

          // 페이스 입력
          _buildPaceSection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 150.ms),
          const SizedBox(height: 24),

          // 총 시간 입력
          _buildTotalTimeSection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms),
          const SizedBox(height: 24),

          // 난이도 선택
          _buildDifficultySection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 250.ms),
          const SizedBox(height: 24),

          // 운동 일기 (성취도 + 일기)
          _buildWorkoutDiarySection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms),
          const SizedBox(height: 24),

          // 사진 업로드
          _buildPhotoSection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 350.ms),
          const SizedBox(height: 24),

          // 커뮤니티 공유
          _buildShareToggle()
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms),
          const SizedBox(height: 32),

          // 완료 버튼
          _buildSubmitButton()
              .animate()
              .fadeIn(duration: 600.ms, delay: 450.ms),
        ],
      ),
    );
  }

  // ==================== AI 분석 섹션 ====================

  Widget _buildAIAnalysisSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Subtle elevation shadow (Material Design 3)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: ModernColors.exercise,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 자동 입력',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '나이키런 스크린샷으로 자동 입력',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: '러닝 기록 스크린샷 업로드',
                button: true,
                hint: '나이키런이나 스트라바 앱의 러닝 기록 스크린샷을 선택하면 자동으로 데이터를 입력합니다',
                enabled: !_isAnalyzing,
                child: IconButton(
                  onPressed: _isAnalyzing ? null : _analyzeRunningImage,
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: _isAnalyzing
                        ? ModernColors.textTertiary
                        : ModernColors.exercise,
                    size: 24,
                  ),
                  tooltip: '스크린샷 분석',
                ),
              ),
            ],
          ),
          if (_isAnalyzing) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ModernColors.exercise),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI가 데이터를 분석 중입니다...',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.exercise,
                  ),
                ),
              ],
            ),
          ],
          if (_analysisError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _analysisError!,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== 거리 입력 섹션 ====================

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
                '거리 (필수)',
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
    final isSelected = _distanceKm == km;
    return Semantics(
      label: '$label 거리 선택',
      button: true,
      hint: '$km 킬로미터로 자동 입력됩니다',
      selected: isSelected,
      child: GestureDetector(
        onTap: () {
          HapticFeedbackManager.lightImpact();
          setState(() {
            _distanceKm = km;
            _distanceController.text = km.toString();
          });
          _checkFormValidity();
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
      ),
    );
  }

  // ==================== 페이스 입력 섹션 ====================

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
                '1km당 페이스 (필수)',
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
                        _paceMinutes = int.tryParse(value);
                      });
                      _checkFormValidity();
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
                        _paceSeconds = int.tryParse(value);
                      });
                      _checkFormValidity();
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

  // ==================== 총 시간 입력 섹션 ====================

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
                '총 소요시간 (필수)',
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
                            _totalHours = int.tryParse(value);
                          });
                          _checkFormValidity();
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
                            _totalMinutes = int.tryParse(value);
                          });
                          _checkFormValidity();
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
                            _totalSeconds = int.tryParse(value);
                          });
                          _checkFormValidity();
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

  // ==================== 난이도 선택 섹션 ====================

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
                      _checkFormValidity();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ModernColors.exercise
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? ModernColors.exercise
                              : ModernColors.exercise.withValues(alpha: 0.1),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: ModernColors.exercise
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
                            ExerciseUtils.getDifficultyIcon(difficulty),
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

  // ==================== 운동 일기 섹션 ====================

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
                        color: _achievementScore != null
                            ? ModernColors.exercise
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _achievementScore != null
                            ? '${_achievementScore!.toInt()}/10'
                            : '?/10',
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
                    value: _achievementScore ?? 1.0,
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
                  _achievementScore != null
                      ? _getAchievementLabel(_achievementScore!)
                      : '만족도를 선택해주세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _achievementScore != null
                        ? ModernColors.textSecondary
                        : Colors.grey.shade500,
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

  // ==================== 사진 업로드 섹션 ====================

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
                '사진 업로드',
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
          if (_selectedImage == null) ...[
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
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
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

  // ==================== 커뮤니티 공유 섹션 ====================

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

  // ==================== 완료 버튼 ====================

  Widget _buildSubmitButton() {
    // 필수 항목: 거리, 페이스, 총 시간 (체감 난이도는 선택사항)
    final bool isFormValid = _distanceKm != null &&
        _paceMinutes != null &&
        _paceSeconds != null &&
        (_totalHours != null || _totalMinutes != null || _totalSeconds != null);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SherpaButton(
        text: isFormValid ? '러닝 기록 완료' : '필수 항목을 모두 입력해주세요',
        onPressed:
            (_isSubmitting || !isFormValid) ? null : _submitRunningRecord,
        backgroundColor:
            isFormValid ? ModernColors.exercise : Colors.grey.shade400,
        height: 56,
        isLoading: _isSubmitting,
      ),
    );
  }

  // ==================== AI 분석 로직 ====================

  Future<void> _analyzeRunningImage() async {
    HapticFeedbackManager.lightImpact();

    // 이미지 선택
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    try {
      final imageFile = File(pickedFile.path);

      // AI 분석 실행
      final runningData = await _imageAnalyzer.analyzeRunningImage(imageFile);

      if (runningData != null) {
        // 성공: 데이터를 폼에 자동 입력
        setState(() {
          _distanceKm = runningData.distanceKm;
          _paceMinutes = runningData.paceMinutes;
          _paceSeconds = runningData.paceSeconds;
          _totalHours = runningData.totalHours;
          _totalMinutes = runningData.totalMinutes;
          _totalSeconds = runningData.totalSeconds;

          // TextField 업데이트
          _distanceController.text = runningData.distanceKm.toString();
          _paceMinController.text = runningData.paceMinutes.toString();
          _paceSecController.text = runningData.paceSeconds.toString();
          _hoursController.text = runningData.totalHours.toString();
          _minutesController.text = runningData.totalMinutes.toString();
          _secondsController.text = runningData.totalSeconds.toString();

          _isAnalyzing = false;
        });

        _checkFormValidity();

        // 성공 메시지
        if (mounted) {
          SnackBarUtils.showInfo(context, 'AI 분석 완료! 데이터를 확인해주세요');
        }
      } else {
        // 실패: 에러 메시지 표시
        setState(() {
          _isAnalyzing = false;
          _analysisError = '데이터를 읽을 수 없습니다. 수동으로 입력해주세요.';
        });
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _analysisError = '분석 중 오류가 발생했습니다. 다시 시도해주세요.';
      });
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

  // ==================== 데이터 저장 로직 ====================

  // 외부에서 호출 가능한 submit 메서드
  Future<void> submitRunningRecord() async {
    return _submitRunningRecord();
  }

  Future<void> _submitRunningRecord() async {
    // null 체크
    if (_distanceKm == null ||
        _paceMinutes == null ||
        _paceSeconds == null) {
      return;
    }

    // 시간 계산
    final totalHours = _totalHours ?? 0;
    final totalMinutes = _totalMinutes ?? 0;
    final totalSeconds = _totalSeconds ?? 0;

    if (totalHours == 0 && totalMinutes == 0 && totalSeconds == 0) {
      return; // 시간이 입력되지 않음
    }

    setState(() {
      _isSubmitting = true;
    });

    HapticFeedbackManager.heavyImpact();

    try {
      // RunningRecord 생성
      final runningRecord = RunningRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: widget.selectedDate,
        durationMinutes: (totalHours * 60) + totalMinutes,
        location: '기록됨', // 위치 정보 없음
        distanceKm: _distanceKm!,
        difficulty: _selectedDifficulty, // 선택하지 않으면 null
        averagePace: _paceMinutes! + (_paceSeconds! / 60.0),
        note: _detailsController.text.isEmpty ? null : _detailsController.text,
        isShared: _isShared,
        imageUrl: _selectedImage != null
            ? 'local_image_${DateTime.now().millisecondsSinceEpoch}'
            : null,
      );

      // ExerciseLog으로 변환하여 저장
      final exerciseLog = ExerciseLog(
        id: runningRecord.id,
        date: runningRecord.date,
        exerciseType: '러닝',
        durationMinutes: runningRecord.durationMinutes,
        intensity: _difficultyToIntensity(_selectedDifficulty), // null 허용
        note: runningRecord.note,
        imageUrl: runningRecord.imageUrl,
        isShared: runningRecord.isShared,
      );

      // Add exercise to user's records
      ref.read(globalUserProvider.notifier).addExerciseLog(exerciseLog);

      // Save RunningRecord to SharedPreferences for detail view - Using RunningRecordHelper
      await RunningRecordHelper.saveRecord(runningRecord);

      // Show success animation and navigate back
      if (mounted) {
        SnackBarUtils.showSuccess(context, '러닝 기록이 완료되었습니다! 🏃‍♂️');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, '기록 중 오류가 발생했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _difficultyToIntensity(DifficultyLevel? difficulty) {
    if (difficulty == null) {
      return 'medium'; // 선택하지 않으면 기본 강도
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

}
