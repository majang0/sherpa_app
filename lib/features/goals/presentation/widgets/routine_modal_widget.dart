import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/widgets/sherpa_button.dart';
import '../../models/routine_model.dart';
import '../../providers/routine_provider.dart';

/// 루틴 모달 위젯
///
/// 루틴 추가, 수정, 삭제를 담당하는 모달
class RoutineModalWidget extends ConsumerStatefulWidget {
  final RoutineModel? routine; // null이면 추가, 있으면 수정/삭제

  const RoutineModalWidget({super.key, this.routine});

  @override
  ConsumerState<RoutineModalWidget> createState() => _RoutineModalWidgetState();
}

class _RoutineModalWidgetState extends ConsumerState<RoutineModalWidget> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedCategory;
  late String _selectedFrequency;
  late String _selectedTimePreference;
  late List<String> _selectedWeekdays;
  DateTime? _endDate;
  late TextEditingController _nameController;

  bool get _isEditing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.routine?.category ?? '운동';
    _selectedFrequency = widget.routine?.frequency ?? '매일';
    _selectedTimePreference = widget.routine?.timePreference ?? '아무때나';
    _selectedWeekdays = widget.routine?.weekdays ?? [];
    _endDate = widget.routine?.endDate;
    _nameController = TextEditingController(text: widget.routine?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
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

                // 이름 입력
                _buildNameInput(),
                const SizedBox(height: 20),

                // 빈도 선택
                _buildFrequencySelector(),
                const SizedBox(height: 20),

                // 요일 선택 (빈도가 '요일선택'일 때만)
                if (_selectedFrequency == '요일선택') ...[
                  _buildWeekdaySelector(),
                  const SizedBox(height: 20),
                ],

                // 시간대 선택
                _buildTimePreferenceSelector(),
                const SizedBox(height: 20),

                // 기간 설정
                _buildDateRange(),
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
          _isEditing ? '루틴 상세' : '루틴 추가',
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
          children: RoutineCategory.all.map((category) {
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

  /// 이름 입력
  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '루틴 이름',
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
            hintText: '예: 아침 조깅 30분',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '루틴 이름을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 빈도 선택
  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빈도',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: RoutineFrequency.all.map((frequency) {
            final isSelected = _selectedFrequency == frequency;
            return ChoiceChip(
              label: Text(frequency),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFrequency = frequency;
                  if (frequency != '요일선택') {
                    _selectedWeekdays = [];
                  }
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

  /// 요일 선택
  Widget _buildWeekdaySelector() {
    final weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '요일 선택',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final weekdayName = weekdayNames[index];
            final isSelected = _selectedWeekdays.contains(weekdayName);
            return ChoiceChip(
              label: Text(weekdayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedWeekdays.add(weekdayName);
                  } else {
                    _selectedWeekdays.remove(weekdayName);
                  }
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
          }),
        ),
      ],
    );
  }

  /// 시간대 선택
  Widget _buildTimePreferenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시간대',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: RoutineTimePreference.all.map((time) {
            final isSelected = _selectedTimePreference == time;
            return ChoiceChip(
              label: Text(time),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedTimePreference = time;
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

  /// 기간 설정
  Widget _buildDateRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기간 설정 (선택)',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // 종료일 선택
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  _endDate ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() {
                _endDate = picked;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: ModernColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '종료일 (선택)',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _endDate != null
                            ? DateFormat('yyyy년 MM월 dd일').format(_endDate!)
                            : '계속 진행',
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
          onPressed: _saveRoutine,
          backgroundColor: ModernColors.quest,
        ),

        // 삭제 버튼 (수정 모드일 때만)
        if (_isEditing) ...[
          const SizedBox(height: 12),
          SherpaButton(
            text: '삭제',
            onPressed: _deleteRoutine,
            backgroundColor: Colors.transparent,
            textColor: ModernColors.error,
          ),
        ],

        // 완료 버튼 (수정 모드일 때만)
        if (_isEditing) ...[
          const SizedBox(height: 12),
          SherpaButton(
            text: '루틴 완료',
            onPressed: _completeRoutine,
            backgroundColor: Colors.transparent,
            textColor: ModernColors.quest,
          ),
        ],
      ],
    );
  }

  /// 루틴 저장
  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      // 요일선택인데 요일이 선택되지 않은 경우
      if (_selectedFrequency == '요일선택' && _selectedWeekdays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '최소 하나의 요일을 선택해주세요',
              style: GoogleFonts.notoSans(),
            ),
            backgroundColor: ModernColors.error,
          ),
        );
        return;
      }

      if (_isEditing) {
        // 수정
        final updatedRoutine = widget.routine!.copyWith(
          category: _selectedCategory,
          frequency: _selectedFrequency,
          weekdays: _selectedWeekdays,
          timePreference: _selectedTimePreference,
          name: _nameController.text,
          endDate: _endDate,
        );
        ref
            .read(routineProvider.notifier)
            .updateRoutine(widget.routine!.id, updatedRoutine);
      } else {
        // 추가
        final newRoutine = RoutineNotifier.createNewRoutine(
          category: _selectedCategory,
          frequency: _selectedFrequency,
          weekdays: _selectedWeekdays,
          timePreference: _selectedTimePreference,
          name: _nameController.text,
          endDate: _endDate,
        );
        ref.read(routineProvider.notifier).addRoutine(newRoutine);
      }

      Navigator.pop(context);
    }
  }

  /// 루틴 삭제
  void _deleteRoutine() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '루틴 삭제',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '정말 이 루틴을 삭제하시겠습니까?',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: GoogleFonts.notoSans()),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(routineProvider.notifier)
                  .deleteRoutine(widget.routine!.id);
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

  /// 루틴 완료
  void _completeRoutine() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '루틴 완료',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '이 루틴을 완료 처리하시겠습니까? 완료한 루틴은 "완료한 루틴" 메뉴에서 확인할 수 있습니다.',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: GoogleFonts.notoSans()),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(routineProvider.notifier)
                  .completeRoutine(widget.routine!.id);
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 모달 닫기
            },
            child: Text(
              '완료',
              style: GoogleFonts.notoSans(color: ModernColors.quest),
            ),
          ),
        ],
      ),
    );
  }
}
