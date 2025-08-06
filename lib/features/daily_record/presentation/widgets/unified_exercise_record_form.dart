// lib/features/daily_record/presentation/widgets/unified_exercise_record_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/record_colors.dart';
import '../../models/detailed_exercise_models.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/utils/calorie_calculator.dart';
import '../../../../shared/utils/exercise_utils.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/widgets/sherpa_button.dart';

class UnifiedExerciseRecordForm extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final String exerciseType;

  const UnifiedExerciseRecordForm({
    super.key,
    required this.selectedDate,
    required this.exerciseType,
  });

  @override
  ConsumerState<UnifiedExerciseRecordForm> createState() =>
      _UnifiedExerciseRecordFormState();
}

class _UnifiedExerciseRecordFormState
    extends ConsumerState<UnifiedExerciseRecordForm>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final TextEditingController _detailsController = TextEditingController();

  // Form state
  int _durationMinutes = 30;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.moderate;
  bool _isShared = false;
  bool _isSubmitting = false;
  File? _selectedImage;

  // Workout diary state
  double _achievementScore = 7.0; // 운동 성취도 (1-10)

  final ImagePicker _imagePicker = ImagePicker();

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
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          _buildQuickSummaryCard()
              .animate()
              .fadeIn(duration: 600.ms, delay: 50.ms),
          const SizedBox(height: 24),
          _buildDurationSection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 100.ms),
          const SizedBox(height: 24),
          _buildDifficultySection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms),
          const SizedBox(height: 24),
          _buildWorkoutDiarySection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms),
          const SizedBox(height: 24),
          _buildPhotoSection()
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms),
          const SizedBox(height: 24),
          _buildShareToggle().animate().fadeIn(duration: 600.ms, delay: 500.ms),
          const SizedBox(height: 32),
          _buildSubmitButton()
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildQuickSummaryCard() {
    final exerciseColor = _getExerciseColor(widget.exerciseType);
    final calories = (_calculateCalories()).round();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: exerciseColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: exerciseColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fitness_center,
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
                    color: RecordColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatDuration(_durationMinutes),
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: RecordColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: exerciseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${calories}kcal',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: exerciseColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedDifficulty.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _selectedDifficulty.label,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _selectedDifficulty.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: RecordColors.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: RecordColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  color: RecordColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: RecordColors.primary,
                  size: 20,
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
            ],
          ),
          const SizedBox(height: 20),

          // Duration display
          Center(
            child: Column(
              children: [
                Text(
                  _formatDuration(_durationMinutes),
                  style: GoogleFonts.notoSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: RecordColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '드래그하여 시간을 설정하세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: RecordColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: RecordColors.primary,
              inactiveTrackColor: RecordColors.primary.withOpacity(0.1),
              thumbColor: RecordColors.primary,
              overlayColor: RecordColors.primary.withOpacity(0.2),
              trackHeight: 8.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
            ),
            child: Slider(
              value: _durationMinutes.toDouble(),
              min: 5,
              max: 300,
              divisions: 59,
              onChanged: (value) {
                HapticFeedbackManager.lightImpact();
                setState(() {
                  _durationMinutes = value.round();
                });
              },
            ),
          ),

          // Enhanced time suggestions (matching edit screen)
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimePreset(15, '가벼운\n운동'),
              _buildTimePreset(30, '일반적인\n운동'),
              _buildTimePreset(60, '충분한\n운동'),
              _buildTimePreset(90, '집중적인\n운동'),
            ],
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
          color: RecordColors.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: RecordColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  color: RecordColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: RecordColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '체감 난이도',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
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
                        color:
                            isSelected ? difficulty.color : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? difficulty.color
                              : RecordColors.primary.withOpacity(0.1),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: difficulty.color.withOpacity(0.3),
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

  Widget _buildWorkoutDiarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: RecordColors.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: RecordColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                  color: RecordColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.book,
                  color: RecordColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '운동 일기',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: RecordColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '선택',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: RecordColors.primary,
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
                  RecordColors.primary.withOpacity(0.05),
                  RecordColors.primary.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: RecordColors.primary.withOpacity(0.1),
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
                        color: RecordColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '💪',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '오늘의 성취도',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: RecordColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: RecordColors.primary,
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
                    activeTrackColor: RecordColors.primary,
                    inactiveTrackColor: RecordColors.primary.withOpacity(0.2),
                    thumbColor: RecordColors.primary,
                    overlayColor: RecordColors.primary.withOpacity(0.2),
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
                    color: RecordColors.textSecondary,
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
              color: RecordColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: _getPersonalizedPrompt(widget.exerciseType),
              hintStyle: GoogleFonts.notoSans(
                fontSize: 14,
                color: RecordColors.textSecondary,
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
                borderSide: BorderSide(
                  color: RecordColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              counterStyle: GoogleFonts.notoSans(
                fontSize: 11,
                color: RecordColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: RecordColors.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: RecordColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  color: RecordColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: RecordColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '사진 업로드',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: RecordColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '선택',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: RecordColors.primary,
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
                  color: RecordColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: RecordColors.primary.withOpacity(0.2),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: RecordColors.primary.withOpacity(0.6),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '사진 추가하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: RecordColors.primary.withOpacity(0.8),
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
                        color: Colors.black.withOpacity(0.6),
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
          color: RecordColors.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: RecordColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              color: RecordColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.group_outlined,
              color: RecordColors.primary,
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
                    color: RecordColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '운동 기록을 다른 사용자와 공유합니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: RecordColors.textSecondary,
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
            activeColor: RecordColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SherpaButton(
        text: '운동 기록 완료',
        onPressed: _isSubmitting ? null : _submitExerciseRecord,
        backgroundColor: RecordColors.primary,
        height: 56,
        isLoading: _isSubmitting,
      ),
    );
  }

  Future<void> _pickImage() async {
    HapticFeedbackManager.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: RecordColors.primary.withOpacity(0.1),
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
                leading: Icon(
                  Icons.camera_alt,
                  color: RecordColors.primary,
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
                leading: Icon(
                  Icons.photo_library,
                  color: RecordColors.primary,
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

  Future<void> _submitExerciseRecord() async {
    setState(() {
      _isSubmitting = true;
    });

    HapticFeedbackManager.heavyImpact();

    try {
      // Calculate XP and points based on duration and difficulty
      final baseXP = _durationMinutes * 2;
      final difficultyMultiplier =
          ExerciseUtils.getDifficultyMultiplier(_selectedDifficulty);
      final totalXP = (baseXP * difficultyMultiplier).round();
      final points = (_durationMinutes * 5 * difficultyMultiplier).round();

      // Handle activity completion - cast doubles to ints where needed
      final xpInt = totalXP.toInt();
      final pointsInt = points.toInt();

      // Create ExerciseLog entry to persist the exercise data
      final exerciseLog = ExerciseLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: widget.selectedDate,
        exerciseType: widget.exerciseType,
        durationMinutes: _durationMinutes,
        intensity: ExerciseUtils.difficultyToIntensity(_selectedDifficulty),
        note: _detailsController.text.isEmpty ? null : _detailsController.text,
        imageUrl: _selectedImage != null ? 'local_image_${DateTime.now().millisecondsSinceEpoch}' : null,
        isShared: _isShared,
      );

      // Add exercise to user's records
      ref.read(globalUserProvider.notifier).addExerciseLog(exerciseLog);

      // Handle additional rewards and notifications  
      ref.read(globalUserProvider.notifier).handleActivityCompletion(
            activityType: 'exercise',
            xp: xpInt.toDouble(),
            points: pointsInt,
            statIncreases: {
              'stamina': _durationMinutes * 0.01 * difficultyMultiplier,
              'willpower': _durationMinutes * 0.005 * difficultyMultiplier,
            },
            message: '${widget.exerciseType} 기록이 완료되었습니다!',
            additionalData: {
              'exerciseType': widget.exerciseType,
              'duration': _durationMinutes,
              'difficulty': _selectedDifficulty.name,
              'details': _detailsController.text,
              'isShared': _isShared,
              'hasPhoto': _selectedImage != null,
              'achievementScore': _achievementScore,
            },
          );

      // Show success animation and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '운동 기록이 완료되었습니다!',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: RecordColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '기록 중 오류가 발생했습니다: $e',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: RecordColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
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


  Widget _buildTimePreset(int minutes, String label) {
    final isSelected = _durationMinutes == minutes;
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        setState(() {
          _durationMinutes = minutes;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? RecordColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              _formatDuration(minutes),
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : RecordColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : RecordColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 헬퍼 메서드들
  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}시간';
      } else {
        return '${hours}시간 ${remainingMinutes}분';
      }
    } else {
      return '${minutes}분';
    }
  }

  String _getAchievementLabel(double score) {
    if (score >= 9) return '최고의 운동이었어요! 🏆';
    if (score >= 7) return '정말 만족스러운 운동! 💪';
    if (score >= 5) return '괜찮은 운동이었어요 👍';
    if (score >= 3) return '조금 아쉬웠어요 😅';
    return '다음엔 더 잘할 수 있어요! 💫';
  }

  String _getPersonalizedPrompt(String exerciseType) {
    switch (exerciseType) {
      case '러닝':
        return '오늘 뛰면서 어떤 생각이 들었나요?\n새로운 코스는 어땠나요?';
      case '헬스':
        return '어떤 근육이 가장 활발했나요?\n새로운 운동을 시도해보셨나요?';
      case '클라이밍':
        return '오늘 정복한 루트는 어땠나요?\n어떤 기술이 향상되었나요?';
      case '요가':
        return '몸과 마음이 어떻게 변했나요?\n가장 편안했던 자세는?';
      case '등산':
        return '오늘의 경치는 어땠나요?\n가장 인상 깊었던 순간은?';
      default:
        return '오늘 운동에서 가장 뿌듯했던 순간은?\n다음엔 어떤 걸 도전해보고 싶나요?';
    }
  }

  Color _getExerciseColor(String exerciseType) {
    switch (exerciseType) {
      // 딥 블루 - 유산소 운동
      case '걷기':
      case '러닝':
      case '수영':
      case '자전거':
        return const Color(0xFF2563EB);
      
      // 미디엄 블루 - 근력/체조 운동
      case '요가':
      case '클라이밍':
      case '필라테스':
      case '헬스':
        return const Color(0xFF3B82F6);
      
      // 스카이 블루 - 라켓 스포츠
      case '골프':
      case '배드민턴':
      case '테니스':
        return const Color(0xFF0EA5E9);
      
      // 라이트 블루 - 볼 스포츠
      case '농구':
      case '축구':
        return const Color(0xFF60A5FA);
      
      // 등산 - 인디고 블루
      case '등산':
        return const Color(0xFF4F46E5);
      
      // 기타 - 기본 블루
      default:
        return const Color(0xFF2563EB);
    }
  }

  int _calculateCalories() {
    final intensity = CalorieCalculator.difficultyToIntensity(_selectedDifficulty);
    return CalorieCalculator.calculateCalories(
      exerciseType: widget.exerciseType,
      durationMinutes: _durationMinutes,
      intensity: intensity,
    );
  }
}
