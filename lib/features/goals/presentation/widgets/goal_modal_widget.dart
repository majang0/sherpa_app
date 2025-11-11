import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/animation/micro_interactions.dart';
import 'package:sherpa_app/features/goals/models/goal_model.dart';
import 'package:sherpa_app/features/goals/providers/goal_provider.dart';

/// 목표 모달 위젯 (2025 Modern Redesign)
///
/// Glassmorphism 디자인으로 완전히 리뉴얼
/// - 드래그 핸들과 프리미엄 헤더
/// - 애니메이션 카테고리 카드
/// - Glassmorphism 날짜 선택기
/// - 플로팅 레이블 텍스트 필드
/// - 그라디언트 액션 버튼
/// - 아름다운 삭제 확인 다이얼로그
class GoalModalWidget extends ConsumerStatefulWidget {
  final GoalModel? goal; // null이면 추가, 있으면 수정/삭제

  const GoalModalWidget({super.key, this.goal});

  @override
  ConsumerState<GoalModalWidget> createState() => _GoalModalWidgetState();
}

class _GoalModalWidgetState extends ConsumerState<GoalModalWidget> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedCategory;
  late DateTime _selectedDate;
  late TextEditingController _nameController;
  late TextEditingController _targetController;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.goal?.category ?? '운동';
    _selectedDate = widget.goal?.date ?? DateTime.now();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetController =
        TextEditingController(text: widget.goal?.targetValue ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.climbing.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, -10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 60,
            offset: const Offset(0, -15),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 드래그 핸들
                _buildDragHandle(),
                const SizedBox(height: 16),

                // 헤더
                _buildHeader(),
                const SizedBox(height: 20),

                // 카테고리 선택
                _buildCategorySelector(),
                const SizedBox(height: 18),

                // 날짜 선택
                _buildDateSelector(),
                const SizedBox(height: 18),

                // 이름 입력
                _buildNameInput(),
                const SizedBox(height: 18),

                // 목표값 입력
                _buildTargetInput(),
                const SizedBox(height: 24),

                // 버튼
                _buildButtons(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
            duration: 350.ms,
            curve: Curves.easeOutCubic,
        )
        .scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1.0, 1.0),
            duration: 350.ms,
            curve: Curves.easeOutCubic,
        );
  }

  /// 드래그 핸들
  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernColors.climbing.withValues(alpha: 0.3),
              ModernColors.climbing.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.climbing.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.climbing,
                  ModernColors.climbing.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.climbing.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              _isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEditing ? '목표 상세' : '새로운 목표',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 50.ms, duration: 250.ms, curve: Curves.easeOut)
        .slideY(
            begin: -0.05,
            end: 0,
            delay: 50.ms,
            duration: 300.ms,
            curve: Curves.easeOutCubic);
  }

  /// 카테고리 선택
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 레이블
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ModernColors.climbing, ModernColors.success],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '카테고리',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 카테고리 카드들 (4개가 한 줄에)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GoalCategory.all.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isSelected = _selectedCategory == category;
            final categoryColor = _getCategoryColor(category);

            return MicroInteractions.tapResponse(
              onTap: () => setState(() => _selectedCategory = category),
              scaleDownTo: 0.96,
              enableHaptic: true,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            categoryColor,
                            categoryColor.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? categoryColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: isSelected ? Colors.white : categoryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : ModernColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(
                  delay: (50 + (index * 30)).ms,
                  duration: 250.ms,
                  curve: Curves.easeOut,
                )
                .slideX(
                  begin: 0.02,
                  end: 0,
                  delay: (50 + (index * 30)).ms,
                  duration: 250.ms,
                  curve: Curves.easeOutCubic,
                );
          }).toList(),
        ),
      ],
    );
  }

  /// 날짜 선택
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 레이블
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ModernColors.climbing, ModernColors.success],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '목표 달성일',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 날짜 선택 카드
        MicroInteractions.tapResponse(
          onTap: _selectDate,
          scaleDownTo: 0.98,
          enableHaptic: true,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.climbing.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 캘린더 아이콘
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ModernColors.climbing.withValues(alpha: 0.15),
                        ModernColors.climbing.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: ModernColors.climbing,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                        style: GoogleFonts.notoSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getDDayPreview(),
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: ModernColors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 150.ms, duration: 250.ms, curve: Curves.easeOut)
            .slideX(
                begin: 0.02,
                end: 0,
                delay: 150.ms,
                duration: 300.ms,
                curve: Curves.easeOutCubic),
      ],
    );
  }

  /// 이름 입력
  Widget _buildNameInput() {
    return _buildModernTextField(
      controller: _nameController,
      label: '상세 내용',
      placeholder: '예: 전국 AI활용 아이디어 경진대회 TOP5',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '목표 이름을 입력해주세요';
        }
        return null;
      },
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 250.ms, curve: Curves.easeOut)
        .slideX(
            begin: 0.02,
            end: 0,
            delay: 200.ms,
            duration: 300.ms,
            curve: Curves.easeOutCubic);
  }

  /// 목표값 입력
  Widget _buildTargetInput() {
    return _buildModernTextField(
      controller: _targetController,
      label: '목표',
      placeholder: '예: 최우수상, 1시간 40분, 90점 이상',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '목표값을 입력해주세요';
        }
        return null;
      },
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 250.ms, curve: Curves.easeOut)
        .slideX(
            begin: 0.02,
            end: 0,
            delay: 250.ms,
            duration: 300.ms,
            curve: Curves.easeOutCubic);
  }

  /// 모던 텍스트 필드
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 레이블
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ModernColors.climbing, ModernColors.success],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Glassmorphism 텍스트 필드
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: ModernColors.climbing.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ModernColors.textPrimary,
              letterSpacing: -0.1,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary.withValues(alpha: 0.5),
                letterSpacing: -0.1,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: ModernColors.climbing.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: ModernColors.error.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: ModernColors.error.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              errorStyle: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ModernColors.error,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  /// 버튼
  Widget _buildButtons() {
    return Column(
      children: [
        // 저장 버튼
        MicroInteractions.tapResponse(
          onTap: _saveGoal,
          scaleDownTo: 0.97,
          enableHaptic: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.climbing,
                  ModernColors.climbing.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.climbing.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isEditing
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  _isEditing ? '수정 완료' : '목표 추가',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 250.ms, curve: Curves.easeOut)
            .slideY(
                begin: 0.05,
                end: 0,
                delay: 300.ms,
                duration: 300.ms,
                curve: Curves.easeOutCubic),

        // 삭제 버튼 (수정 모드일 때만)
        if (_isEditing) ...[
          const SizedBox(height: 12),
          MicroInteractions.tapResponse(
            onTap: _showDeleteDialog,
            scaleDownTo: 0.98,
            enableHaptic: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ModernColors.error.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.error.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_outline,
                    color: ModernColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '목표 삭제',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.error,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 250.ms, curve: Curves.easeOut)
              .slideY(
                  begin: 0.05,
                  end: 0,
                  delay: 350.ms,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic),
        ],
      ],
    );
  }

  /// 날짜 선택
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ModernColors.climbing,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ModernColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 목표 저장
  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        // 수정
        final updatedGoal = widget.goal!.copyWith(
          category: _selectedCategory,
          date: _selectedDate,
          name: _nameController.text,
          targetValue: _targetController.text,
        );
        ref
            .read(goalProvider.notifier)
            .updateGoal(widget.goal!.id, updatedGoal);
      } else {
        // 추가
        final newGoal = GoalNotifier.createNewGoal(
          category: _selectedCategory,
          date: _selectedDate,
          name: _nameController.text,
          targetValue: _targetController.text,
        );
        ref.read(goalProvider.notifier).addGoal(newGoal);
      }

      Navigator.pop(context);
    }
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.88),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ModernColors.error.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 60,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 에러 아이콘
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      ModernColors.error.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 36,
                  color: ModernColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '목표를 삭제하시겠어요?',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '삭제된 목표는 복구할 수 없어요',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textSecondary.withValues(alpha: 0.8),
                  letterSpacing: -0.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // 액션 버튼들
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: MicroInteractions.tapResponse(
                      onTap: () => Navigator.pop(context),
                      scaleDownTo: 0.97,
                      enableHaptic: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.9),
                              Colors.white.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  ModernColors.climbing.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '취소',
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 삭제 버튼
                  Expanded(
                    child: MicroInteractions.tapResponse(
                      onTap: () {
                        ref
                            .read(goalProvider.notifier)
                            .deleteGoal(widget.goal!.id);
                        Navigator.pop(context); // 다이얼로그 닫기
                        Navigator.pop(context); // 모달 닫기
                      },
                      scaleDownTo: 0.97,
                      enableHaptic: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernColors.error,
                              ModernColors.error.withValues(alpha: 0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ModernColors.error.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          '삭제',
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms, curve: Curves.easeOut)
            .scale(
                begin: const Offset(0.94, 0.94),
                end: const Offset(1.0, 1.0),
                duration: 250.ms,
                curve: Curves.easeOutCubic),
      ),
    );
  }

  /// 카테고리 색상 반환
  Color _getCategoryColor(String category) {
    switch (category) {
      case '운동':
        return ModernColors.exercise;
      case '학습':
        return ModernColors.reading;
      case '대회':
        return ModernColors.climbing;
      case '자격증':
        return ModernColors.focus;
      default:
        return ModernColors.climbing;
    }
  }

  /// 카테고리 아이콘 반환
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '운동':
        return Icons.fitness_center;
      case '학습':
        return Icons.school;
      case '대회':
        return Icons.emoji_events;
      case '자격증':
        return Icons.workspace_premium;
      default:
        return Icons.flag;
    }
  }

  /// D-day 미리보기
  String _getDDayPreview() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final difference = target.difference(today).inDays;

    if (difference < 0) {
      return 'D+${-difference} (${-difference}일 지남)';
    } else if (difference == 0) {
      return 'D-Day (오늘)';
    } else {
      return 'D-$difference ($difference일 남음)';
    }
  }
}
