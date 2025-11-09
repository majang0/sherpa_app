import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/widgets/sherpa_button.dart';
import 'package:sherpa_app/features/goals/models/goal_model.dart';
import 'package:sherpa_app/features/goals/providers/goal_provider.dart';

/// 목표 모달 위젯
///
/// 목표 추가, 수정, 삭제를 담당하는 모달
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
      decoration: const BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                _buildHeader(),
                const SizedBox(height: 24),

                // 카테고리 선택
                _buildCategorySelector(),
                const SizedBox(height: 20),

                // 날짜 선택
                _buildDateSelector(),
                const SizedBox(height: 20),

                // 이름 입력
                _buildNameInput(),
                const SizedBox(height: 20),

                // 목표값 입력
                _buildTargetInput(),
                const SizedBox(height: 24),

                // 버튼
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _isEditing ? '목표 상세' : '목표 추가',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// 카테고리 선택
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: GoalCategory.all.map((category) {
            final isSelected = _selectedCategory == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: ModernColors.quest.withValues(alpha: 0.2),
              labelStyle: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? ModernColors.quest
                    : ModernColors.textSecondary,
              ),
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
        Text(
          '날짜',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: ModernColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 20),
                const SizedBox(width: 12),
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 이름 입력
  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 내용 (이름)',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '예: 전국 AI활용 아이디어 경진대회 대상',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '이름을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 목표값 입력
  Widget _buildTargetInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '목표',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _targetController,
          decoration: InputDecoration(
            hintText: '예: 1시간 40분, 대상, 90점 이상',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '목표를 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 버튼
  Widget _buildButtons() {
    return Column(
      children: [
        // 저장 버튼
        SherpaButton(
          text: _isEditing ? '수정' : '추가',
          onPressed: _saveGoal,
          backgroundColor: ModernColors.quest,
        ),

        // 삭제 버튼 (수정 모드일 때만)
        if (_isEditing) ...[
          const SizedBox(height: 12),
          SherpaButton(
            text: '삭제',
            onPressed: _deleteGoal,
            backgroundColor: Colors.transparent,
            textColor: ModernColors.error,
          ),
        ],
      ],
    );
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

  /// 목표 삭제
  void _deleteGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '목표 삭제',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '정말 이 목표를 삭제하시겠습니까?',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: GoogleFonts.notoSans()),
          ),
          TextButton(
            onPressed: () {
              ref.read(goalProvider.notifier).deleteGoal(widget.goal!.id);
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 모달 닫기
            },
            child: Text(
              '삭제',
              style: GoogleFonts.notoSans(color: ModernColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
