import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../models/available_meeting_model.dart';

/// 🆕 모임 개설 화면 - 한국형 모임 앱 스타일
/// 사용자가 새로운 모임을 생성할 수 있는 폼 기반 화면
class MeetingCreateScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MeetingCreateScreen> createState() => _MeetingCreateScreenState();
}

class _MeetingCreateScreenState extends ConsumerState<MeetingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailedLocationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _priceController = TextEditingController();

  // 폼 필드 상태
  MeetingCategory _selectedCategory = MeetingCategory.study;
  MeetingType _selectedType = MeetingType.free;
  MeetingScope _selectedScope = MeetingScope.public;
  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1));
  final List<String> _tags = [];
  final List<String> _requirements = [];

  @override
  void initState() {
    super.initState();
    _maxParticipantsController.text = '10'; // 기본값
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _detailedLocationController.dispose();
    _maxParticipantsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SherpaCleanAppBar(
        title: '모임 개설',
        backgroundColor: AppColors.background,
        actions: [
          // 미리보기 버튼
          TextButton(
            onPressed: _previewMeeting,
            child: Text(
              '미리보기',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // 폼 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 기본 정보 섹션
                    _buildBasicInfoSection(),
                    
                    const SizedBox(height: 24),
                    
                    // 카테고리 및 타입 섹션
                    _buildCategorySection(),
                    
                    const SizedBox(height: 24),
                    
                    // 일시 및 장소 섹션
                    _buildDateTimeLocationSection(),
                    
                    const SizedBox(height: 24),
                    
                    // 참가자 및 가격 섹션
                    _buildParticipantsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // 추가 정보 섹션
                    _buildAdditionalInfoSection(),
                    
                    const SizedBox(height: 100), // FAB 공간
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // 모임 개설 완료 버튼
      floatingActionButton: _buildCreateButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 📝 기본 정보 섹션
  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: '기본 정보',
      icon: Icons.info_outline_rounded,
      children: [
        // 모임 제목
        _buildFormField(
          label: '모임 제목',
          controller: _titleController,
          hint: '예: 함께 책 읽고 토론해요',
          maxLength: 50,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '모임 제목을 입력해주세요';
            }
            if (value.trim().length < 5) {
              return '모임 제목은 5글자 이상 입력해주세요';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // 모임 설명
        _buildFormField(
          label: '모임 설명',
          controller: _descriptionController,
          hint: '모임에 대한 자세한 설명을 작성해주세요',
          maxLines: 4,
          maxLength: 200,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '모임 설명을 입력해주세요';
            }
            if (value.trim().length < 10) {
              return '모임 설명은 10글자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 🏷️ 카테고리 섹션
  Widget _buildCategorySection() {
    return _buildSection(
      title: '카테고리 및 유형',
      icon: Icons.category_rounded,
      children: [
        // 카테고리 선택
        _buildSectionLabel('카테고리'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MeetingCategory.values.where((cat) => cat != MeetingCategory.all).map((category) {
            final isSelected = _selectedCategory == category;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            colors: [category.color, category.color.withOpacity(0.8)],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? category.color : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        category.displayName,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // 모임 유형 선택
        _buildSectionLabel('모임 유형'),
        const SizedBox(height: 8),
        Row(
          children: MeetingType.values.map((type) {
            final isSelected = _selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? AppColors.primaryGradient
                          : null,
                      color: isSelected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      type.displayName,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // 모임 범위 선택
        _buildSectionLabel('모임 범위'),
        const SizedBox(height: 8),
        Row(
          children: MeetingScope.values.map((scope) {
            final isSelected = _selectedScope == scope;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedScope = scope;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? LinearGradient(
                              colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      scope.displayName,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 📅 일시 및 장소 섹션
  Widget _buildDateTimeLocationSection() {
    return _buildSection(
      title: '일시 및 장소',
      icon: Icons.place_rounded,
      children: [
        // 날짜 및 시간 선택
        _buildSectionLabel('모임 일시'),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectDateTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_selectedDateTime.year}년 ${_selectedDateTime.month}월 ${_selectedDateTime.day}일 ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, 
                    size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 모임 장소
        _buildFormField(
          label: '모임 장소',
          controller: _locationController,
          hint: '예: 서울, 온라인',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '모임 장소를 입력해주세요';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // 상세 주소
        _buildFormField(
          label: '상세 주소 (선택사항)',
          controller: _detailedLocationController,
          hint: '예: 강남구 테헤란로 123, 카페 이름',
        ),
      ],
    );
  }

  /// 👥 참가자 및 가격 섹션
  Widget _buildParticipantsSection() {
    return _buildSection(
      title: '참가자 및 가격',
      icon: Icons.people_rounded,
      children: [
        // 최대 참가자 수
        _buildFormField(
          label: '최대 참가자 수',
          controller: _maxParticipantsController,
          hint: '2 ~ 50명',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '최대 참가자 수를 입력해주세요';
            }
            final num = int.tryParse(value);
            if (num == null || num < 2 || num > 50) {
              return '2명 이상 50명 이하로 입력해주세요';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // 참가비 (유료 모임인 경우)
        if (_selectedType == MeetingType.paid) ...[
          _buildFormField(
            label: '참가비 (원)',
            controller: _priceController,
            hint: '예: 10000',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (_selectedType == MeetingType.paid) {
                if (value == null || value.trim().isEmpty) {
                  return '참가비를 입력해주세요';
                }
                final num = int.tryParse(value);
                if (num == null || num <= 0) {
                  return '올바른 금액을 입력해주세요';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            '* 참가비에는 5% 서비스 수수료가 포함됩니다',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// ➕ 추가 정보 섹션
  Widget _buildAdditionalInfoSection() {
    return _buildSection(
      title: '추가 정보 (선택사항)',
      icon: Icons.add_circle_outline_rounded,
      children: [
        Text(
          '모임에 대한 추가 정보나 준비물, 주의사항 등을 작성해주세요.',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, 
                    color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '모임 개설 팁',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• 구체적인 모임 내용과 진행 방식을 설명해주세요\n'
                '• 필요한 준비물이나 사전 지식을 명시해주세요\n'
                '• 모임 분위기와 참가 대상을 안내해주세요',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.primary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📦 섹션 컨테이너
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  /// 🏷️ 섹션 라벨
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// ✏️ 폼 필드 빌더
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterStyle: GoogleFonts.notoSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 📅 날짜 시간 선택
  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  /// 👀 미리보기
  void _previewMeeting() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필수 항목을 모두 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: 미리보기 다이얼로그 또는 화면 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('미리보기', style: GoogleFonts.notoSans(fontWeight: FontWeight.w700)),
        content: Text('모임 미리보기 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  /// ✅ 모임 개설 버튼
  Widget _buildCreateButton() {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _createMeeting,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  '모임 개설하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🚀 모임 개설 실행
  void _createMeeting() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필수 항목을 모두 입력해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: 실제 모임 생성 로직 구현
    // 현재는 성공 메시지만 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.celebration_rounded, color: AppColors.success),
            const SizedBox(width: 8),
            Text('모임 개설 완료!', style: GoogleFonts.notoSans(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          '${_titleController.text} 모임이 성공적으로 개설되었습니다!\n다른 사용자들이 참가할 수 있도록 모임을 홍보해보세요.',
          style: GoogleFonts.notoSans(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 모임 개설 화면 닫기
            },
            child: Text('확인', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}