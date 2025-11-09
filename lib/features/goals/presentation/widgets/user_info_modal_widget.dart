import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';

/// 사용자 상세 정보 입력/편집 모달 위젯
///
/// 목표 및 루틴 화면에서 사용하는 사용자 상세 정보 입력 폼
/// 신체 정보, 학업 성적, 대회 수상, 자격증, 어학 성적 등을 입력/수정 가능
class UserInfoModalWidget extends ConsumerStatefulWidget {
  final GlobalUser user;

  const UserInfoModalWidget({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<UserInfoModalWidget> createState() =>
      _UserInfoModalWidgetState();
}

class _UserInfoModalWidgetState extends ConsumerState<UserInfoModalWidget> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // 신체 정보 컨트롤러
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bodyFatController;
  late TextEditingController _muscleMassController;
  late TextEditingController _birthYearController;

  // 리스트 데이터
  late List<String> _academicAchievements;
  late List<String> _competitionAwards;
  late List<String> _certifications;
  late List<String> _languageScores;

  // 리스트 항목 추가 컨트롤러
  final _achievementController = TextEditingController();
  final _awardController = TextEditingController();
  final _certificationController = TextEditingController();
  final _languageScoreController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 컨트롤러 초기화
    _heightController =
        TextEditingController(text: widget.user.height?.toString() ?? '');
    _weightController =
        TextEditingController(text: widget.user.weight?.toString() ?? '');
    _bodyFatController =
        TextEditingController(text: widget.user.bodyFatRate?.toString() ?? '');
    _muscleMassController =
        TextEditingController(text: widget.user.muscleMass?.toString() ?? '');
    _birthYearController =
        TextEditingController(text: widget.user.birthYear?.toString() ?? '');

    // 리스트 데이터 초기화 (복사본 생성)
    _academicAchievements = List.from(widget.user.academicAchievements);
    _competitionAwards = List.from(widget.user.competitionAwards);
    _certifications = List.from(widget.user.certifications);
    _languageScores = List.from(widget.user.languageScores);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _birthYearController.dispose();
    _achievementController.dispose();
    _awardController.dispose();
    _certificationController.dispose();
    _languageScoreController.dispose();
    super.dispose();
  }

  /// 저장 버튼 클릭
  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 데이터 파싱
    final height = _heightController.text.isEmpty
        ? null
        : int.tryParse(_heightController.text);
    final weight = _weightController.text.isEmpty
        ? null
        : double.tryParse(_weightController.text);
    final bodyFat = _bodyFatController.text.isEmpty
        ? null
        : double.tryParse(_bodyFatController.text);
    final muscleMass = _muscleMassController.text.isEmpty
        ? null
        : double.tryParse(_muscleMassController.text);
    final birthYear = _birthYearController.text.isEmpty
        ? null
        : int.tryParse(_birthYearController.text);

    // Provider에 저장
    ref.read(globalUserProvider.notifier).updateUserInfo(
      height: height,
      weight: weight,
      bodyFatRate: bodyFat,
      muscleMass: muscleMass,
      birthYear: birthYear,
      academicAchievements: _academicAchievements,
      competitionAwards: _competitionAwards,
      certifications: _certifications,
      languageScores: _languageScores,
    );

    // 모달 닫기
    Navigator.pop(context);

    // 성공 스낵바
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('사용자 정보가 저장되었습니다'),
        backgroundColor: ModernColors.quest,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                _buildHeader(context),
                const SizedBox(height: 24),

                // 섹션 1: 신체 정보
                _buildPhysicalInfoSection(),
                const SizedBox(height: 24),

                // 섹션 2: 학업 성적
                _buildListSection(
                  title: '학업 성적',
                  icon: Icons.school,
                  color: ModernColors.reading,
                  items: _academicAchievements,
                  controller: _achievementController,
                  hintText: '예: 2024-1학기 4.3/4.5',
                  onAdd: () => _addListItem(_academicAchievements,
                      _achievementController, '학업 성적'),
                  onRemove: (index) =>
                      _removeListItem(_academicAchievements, index),
                ),
                const SizedBox(height: 24),

                // 섹션 3: 대회 수상경력
                _buildListSection(
                  title: '대회 수상경력',
                  icon: Icons.emoji_events,
                  color: ModernColors.quest,
                  items: _competitionAwards,
                  controller: _awardController,
                  hintText: '예: 2024 SW컨테스트 대상',
                  onAdd: () => _addListItem(
                      _competitionAwards, _awardController, '대회 수상경력'),
                  onRemove: (index) => _removeListItem(_competitionAwards, index),
                ),
                const SizedBox(height: 24),

                // 섹션 4: 자격증
                _buildListSection(
                  title: '자격증',
                  icon: Icons.card_membership,
                  color: ModernColors.exercise,
                  items: _certifications,
                  controller: _certificationController,
                  hintText: '예: 정보처리기사',
                  onAdd: () => _addListItem(
                      _certifications, _certificationController, '자격증'),
                  onRemove: (index) => _removeListItem(_certifications, index),
                ),
                const SizedBox(height: 24),

                // 섹션 5: 어학 성적
                _buildListSection(
                  title: '어학 성적',
                  icon: Icons.translate,
                  color: ModernColors.meeting,
                  items: _languageScores,
                  controller: _languageScoreController,
                  hintText: '예: TOEIC 900점',
                  onAdd: () => _addListItem(
                      _languageScores, _languageScoreController, '어학 성적'),
                  onRemove: (index) => _removeListItem(_languageScores, index),
                ),
                const SizedBox(height: 32),

                // 저장 버튼
                _buildSaveButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사용자 상세 정보',
              style: GoogleFonts.notoSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '목표 달성 분석에 활용됩니다',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 24),
          color: ModernColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// 신체 정보 섹션
  Widget _buildPhysicalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('신체 정보', Icons.fitness_center,
            ModernColors.exercise),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ModernColors.exercise.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ModernColors.exercise.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      label: '키',
                      unit: 'cm',
                      controller: _heightController,
                      icon: Icons.height,
                      min: 100,
                      max: 250,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      label: '몸무게',
                      unit: 'kg',
                      controller: _weightController,
                      icon: Icons.monitor_weight_outlined,
                      min: 30,
                      max: 200,
                      isDecimal: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      label: '체지방률',
                      unit: '%',
                      controller: _bodyFatController,
                      icon: Icons.percent,
                      min: 0,
                      max: 100,
                      isDecimal: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      label: '골격근량',
                      unit: 'kg',
                      controller: _muscleMassController,
                      icon: Icons.fitness_center,
                      min: 0,
                      max: 100,
                      isDecimal: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                label: '생년',
                unit: '년',
                controller: _birthYearController,
                icon: Icons.cake,
                min: 1900,
                max: DateTime.now().year.toDouble(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 숫자 입력 필드
  Widget _buildNumberField({
    required String label,
    required String unit,
    required TextEditingController controller,
    required IconData icon,
    required double min,
    required double max,
    bool isDecimal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: ModernColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType:
              TextInputType.numberWithOptions(decimal: isDecimal),
          inputFormatters: [
            if (isDecimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '입력',
            hintStyle: GoogleFonts.notoSans(
              color: ModernColors.textSecondary.withValues(alpha: 0.5),
            ),
            suffixText: unit,
            suffixStyle: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
            filled: true,
            fillColor: ModernColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ModernColors.gray300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ModernColors.gray300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ModernColors.quest,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ModernColors.error,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null; // 선택 항목
            }
            final numValue =
                isDecimal ? double.tryParse(value) : int.tryParse(value);
            if (numValue == null) {
              return '올바른 숫자를 입력하세요';
            }
            if (numValue < min || numValue > max) {
              return '$min~$max 범위로 입력하세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 리스트 섹션 (학업 성적, 대회 수상, 자격증, 어학 성적)
  Widget _buildListSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, icon, color),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 추가 입력 필드
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: GoogleFonts.notoSans(
                          color: ModernColors.textSecondary
                              .withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: ModernColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ModernColors.gray300,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ModernColors.gray300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: color,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onAdd,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 항목 리스트
              if (items.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: ModernColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              size: 16,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ModernColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: ModernColors.textSecondary,
                            onPressed: () => onRemove(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ] else ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '아직 추가된 항목이 없습니다',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 리스트 항목 추가
  void _addListItem(
      List<String> list, TextEditingController controller, String itemName) {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$itemName을(를) 입력하세요'),
          backgroundColor: ModernColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      list.add(text);
      controller.clear();
    });
  }

  /// 리스트 항목 제거
  void _removeListItem(List<String> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  /// 저장 버튼
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.quest,
            ModernColors.questLight,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.quest.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleSave,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              '저장하기',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
