import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/animation/micro_interactions.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';

/// 사용자 상세 정보 다이얼로그 (Glassmorphism + View/Edit 모드)
///
/// goals_screen.dart 디자인 철학 + global_sherpi_widget.dart 모달 스타일 적용
class UserInfoDialogWidget extends ConsumerStatefulWidget {
  final GlobalUser user;

  const UserInfoDialogWidget({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<UserInfoDialogWidget> createState() => _UserInfoDialogWidgetState();
}

class _UserInfoDialogWidgetState extends ConsumerState<UserInfoDialogWidget> {
  // View/Edit 모드 상태
  bool _isEditMode = false;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // 신체 정보 컨트롤러
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bodyFatController;
  late TextEditingController _muscleMassController;
  late TextEditingController _birthYearController;

  // 구조화된 데이터 리스트
  late List<AcademicRecord> _academicAchievements;
  late List<CompetitionAward> _competitionAwards;
  late List<Certification> _certifications;
  late List<LanguageScore> _languageScores;

  @override
  void initState() {
    super.initState();

    // 컨트롤러 초기화
    _heightController = TextEditingController(text: widget.user.height?.toString() ?? '');
    _weightController = TextEditingController(text: widget.user.weight?.toString() ?? '');
    _bodyFatController = TextEditingController(text: widget.user.bodyFatRate?.toString() ?? '');
    _muscleMassController = TextEditingController(text: widget.user.muscleMass?.toString() ?? '');
    _birthYearController = TextEditingController(text: widget.user.birthYear?.toString() ?? '');

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
    super.dispose();
  }

  /// 저장 버튼 클릭
  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 데이터 파싱
    final height = _heightController.text.isEmpty ? null : int.tryParse(_heightController.text);
    final weight = _weightController.text.isEmpty ? null : double.tryParse(_weightController.text);
    final bodyFat = _bodyFatController.text.isEmpty ? null : double.tryParse(_bodyFatController.text);
    final muscleMass = _muscleMassController.text.isEmpty ? null : double.tryParse(_muscleMassController.text);
    final birthYear = _birthYearController.text.isEmpty ? null : int.tryParse(_birthYearController.text);

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

    // Edit 모드 종료
    setState(() {
      _isEditMode = false;
    });

    // 성공 스낵바
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '사용자 정보가 저장되었습니다',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: ModernColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primary.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 헤더
                  _buildHeader(context),

                  // 컨텐츠 영역 (스크롤 가능)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                      child: Column(
                        children: [
                          // 신체 정보 섹션
                          _buildPhysicalInfoSection(),
                          const SizedBox(height: 24),

                          // 학업 성적 섹션
                          _buildAcademicSection(),
                          const SizedBox(height: 24),

                          // 대회 수상경력 섹션
                          _buildCompetitionSection(),
                          const SizedBox(height: 24),

                          // 자격증 섹션
                          _buildCertificationSection(),
                          const SizedBox(height: 24),

                          // 어학 성적 섹션
                          _buildLanguageSection(),
                          const SizedBox(height: 32),

                          // 편집 모드일 때만 저장 버튼 표시
                          if (_isEditMode) _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.98, 0.98),
          curve: Curves.easeOut,
          duration: 200.ms,
        )
        .fade(
          curve: Curves.easeOut,
          duration: 150.ms,
        );
  }

  /// 헤더 섹션 (제목 + 편집/저장 버튼)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.primary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.primary,
                  ModernColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),

          // 제목
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '사용자 정보',
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: ModernColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditMode ? '정보를 수정하세요' : '${widget.user.name}님의 정보',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary.withValues(alpha: 0.8),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          // 편집/닫기 버튼
          if (!_isEditMode) ...[
            _buildHeaderButton(
              icon: Icons.edit,
              onTap: () {
                setState(() {
                  _isEditMode = true;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
          _buildHeaderButton(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// 헤더 버튼
  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return MicroInteractions.tapResponse(
      onTap: onTap,
      scaleDownTo: 0.95,
      enableHaptic: true,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ModernColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: ModernColors.primary.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  /// 신체 정보 섹션
  Widget _buildPhysicalInfoSection() {
    return _buildSection(
      title: '신체 정보',
      icon: Icons.fitness_center,
      color: ModernColors.exercise,
      child: _isEditMode ? _buildPhysicalInfoEdit() : _buildPhysicalInfoView(),
    );
  }

  /// 신체 정보 View 모드
  Widget _buildPhysicalInfoView() {
    final items = [
      if (widget.user.height != null) _InfoItem(label: '키', value: '${widget.user.height}cm', icon: Icons.height),
      if (widget.user.weight != null) _InfoItem(label: '몸무게', value: '${widget.user.weight}kg', icon: Icons.monitor_weight_outlined),
      if (widget.user.bodyFatRate != null) _InfoItem(label: '체지방률', value: '${widget.user.bodyFatRate}%', icon: Icons.percent),
      if (widget.user.muscleMass != null) _InfoItem(label: '골격근량', value: '${widget.user.muscleMass}kg', icon: Icons.fitness_center),
      if (widget.user.birthYear != null) _InfoItem(label: '생년', value: '${widget.user.birthYear}년', icon: Icons.cake),
    ];

    if (items.isEmpty) {
      return _buildEmptyState('신체 정보를 추가해주세요');
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) => _buildInfoCard(item)).toList(),
    );
  }

  /// 신체 정보 Edit 모드
  Widget _buildPhysicalInfoEdit() {
    return Column(
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
    );
  }

  /// 학업 성적 섹션
  Widget _buildAcademicSection() {
    return _buildSection(
      title: '학업 성적',
      icon: Icons.school,
      color: ModernColors.reading,
      child: _isEditMode
          ? _buildAcademicEdit()
          : _buildListView<AcademicRecord>(
              items: _academicAchievements.reversed.toList(),
              icon: Icons.school,
              color: ModernColors.reading,
              displayText: (item) => item.displayText,
              emptyMessage: '학업 성적을 추가해주세요',
            ),
    );
  }

  /// 학업 성적 Edit 모드
  Widget _buildAcademicEdit() {
    return Column(
      children: [
        // 추가 버튼
        _buildAddButton(
          label: '학업 성적 추가',
          icon: Icons.add,
          color: ModernColors.reading,
          onTap: () => _showAcademicDialog(),
        ),
        if (_academicAchievements.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._academicAchievements.reversed.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final originalIndex = _academicAchievements.length - 1 - index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildEditCard(
                icon: Icons.school,
                color: ModernColors.reading,
                displayText: item.displayText,
                onDelete: () {
                  setState(() {
                    _academicAchievements.removeAt(originalIndex);
                  });
                },
              ),
            );
          }),
        ],
      ],
    );
  }

  /// 대회 수상경력 섹션
  Widget _buildCompetitionSection() {
    return _buildSection(
      title: '대회 수상경력',
      icon: Icons.emoji_events,
      color: ModernColors.quest,
      child: _isEditMode
          ? _buildCompetitionEdit()
          : _buildListView<CompetitionAward>(
              items: _competitionAwards.reversed.toList(),
              icon: Icons.emoji_events,
              color: ModernColors.quest,
              displayText: (item) => item.displayText,
              emoji: (item) => item.awardEmoji,
              emptyMessage: '대회 수상경력을 추가해주세요',
            ),
    );
  }

  /// 대회 수상경력 Edit 모드
  Widget _buildCompetitionEdit() {
    return Column(
      children: [
        _buildAddButton(
          label: '대회 수상경력 추가',
          icon: Icons.add,
          color: ModernColors.quest,
          onTap: () => _showCompetitionDialog(),
        ),
        if (_competitionAwards.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._competitionAwards.reversed.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final originalIndex = _competitionAwards.length - 1 - index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildEditCard(
                icon: Icons.emoji_events,
                color: ModernColors.quest,
                displayText: item.displayText,
                emoji: item.awardEmoji,
                onDelete: () {
                  setState(() {
                    _competitionAwards.removeAt(originalIndex);
                  });
                },
              ),
            );
          }),
        ],
      ],
    );
  }

  /// 자격증 섹션
  Widget _buildCertificationSection() {
    return _buildSection(
      title: '자격증',
      icon: Icons.card_membership,
      color: ModernColors.exercise,
      child: _isEditMode
          ? _buildCertificationEdit()
          : _buildListView<Certification>(
              items: _certifications,
              icon: Icons.card_membership,
              color: ModernColors.exercise,
              displayText: (item) => item.displayText,
              emptyMessage: '자격증을 추가해주세요',
            ),
    );
  }

  /// 자격증 Edit 모드
  Widget _buildCertificationEdit() {
    return Column(
      children: [
        _buildAddButton(
          label: '자격증 추가',
          icon: Icons.add,
          color: ModernColors.exercise,
          onTap: () => _showCertificationDialog(),
        ),
        if (_certifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._certifications.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildEditCard(
                icon: Icons.card_membership,
                color: ModernColors.exercise,
                displayText: item.displayText,
                onDelete: () {
                  setState(() {
                    _certifications.removeAt(index);
                  });
                },
              ),
            );
          }),
        ],
      ],
    );
  }

  /// 어학 성적 섹션
  Widget _buildLanguageSection() {
    return _buildSection(
      title: '어학 성적',
      icon: Icons.translate,
      color: ModernColors.meeting,
      child: _isEditMode
          ? _buildLanguageEdit()
          : _buildListView<LanguageScore>(
              items: _languageScores,
              icon: Icons.translate,
              color: ModernColors.meeting,
              displayText: (item) => item.displayText,
              emoji: (item) => item.testEmoji,
              emptyMessage: '어학 성적을 추가해주세요',
            ),
    );
  }

  /// 어학 성적 Edit 모드
  Widget _buildLanguageEdit() {
    return Column(
      children: [
        _buildAddButton(
          label: '어학 성적 추가',
          icon: Icons.add,
          color: ModernColors.meeting,
          onTap: () => _showLanguageDialog(),
        ),
        if (_languageScores.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._languageScores.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildEditCard(
                icon: Icons.translate,
                color: ModernColors.meeting,
                displayText: item.displayText,
                emoji: item.testEmoji,
                onDelete: () {
                  setState(() {
                    _languageScores.removeAt(index);
                  });
                },
              ),
            );
          }),
        ],
      ],
    );
  }

  /// 섹션 공통 래퍼
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 섹션 컨텐츠
        child,
      ],
    );
  }

  /// 정보 카드 (View 모드)
  Widget _buildInfoCard(_InfoItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.exercise.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 16, color: ModernColors.exercise.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text(
            item.label,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            item.value,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 리스트 뷰 공통 (View 모드)
  Widget _buildListView<T>({
    required List<T> items,
    required IconData icon,
    required Color color,
    required String Function(T) displayText,
    String Function(T)? emoji,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (emoji != null) ...[
                  Text(
                    emoji(item),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    displayText(item),
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Edit 카드 (삭제 버튼 포함)
  Widget _buildEditCard({
    required IconData icon,
    required Color color,
    required String displayText,
    String? emoji,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              displayText,
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
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// 추가 버튼 (Edit 모드)
  Widget _buildAddButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MicroInteractions.tapResponse(
      onTap: onTap,
      scaleDownTo: 0.97,
      enableHaptic: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 표시
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ),
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
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
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
            fillColor: Colors.white.withValues(alpha: 0.7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ModernColors.gray300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ModernColors.gray300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ModernColors.primary,
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
            final numValue = isDecimal ? double.tryParse(value) : int.tryParse(value);
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

  /// 저장 버튼
  Widget _buildSaveButton() {
    return MicroInteractions.tapResponse(
      onTap: _handleSave,
      scaleDownTo: 0.97,
      enableHaptic: true,
      child: Container(
        width: double.infinity,
        height: 56,
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
          boxShadow: [
            BoxShadow(
              color: ModernColors.climbing.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '저장하기',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }

  /// 학업 성적 추가 다이얼로그
  Future<void> _showAcademicDialog() async {
    final yearController = TextEditingController();
    final semesterController = TextEditingController(text: '1');
    final achievedGPAController = TextEditingController();
    final totalGPAController = TextEditingController(text: '4.5');

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.reading.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ModernColors.reading.withValues(alpha: 0.1),
                          ModernColors.reading.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ModernColors.reading.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.school,
                            color: ModernColors.reading,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '학업 성적 추가',
                          style: GoogleFonts.notoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildModernTextField(
                          controller: yearController,
                          label: '년도',
                          hint: '예: 2024',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          controller: semesterController,
                          label: '학기',
                          hint: '1 또는 2',
                          icon: Icons.format_list_numbered,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          controller: achievedGPAController,
                          label: '평균 학점',
                          hint: '예: 4.3',
                          icon: Icons.star,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          controller: totalGPAController,
                          label: '총 학점',
                          hint: '예: 4.5',
                          icon: Icons.grade,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDialogButton(
                            label: '취소',
                            onPressed: () => Navigator.pop(context),
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDialogButton(
                            label: '추가',
                            onPressed: () {
                              final year = int.tryParse(yearController.text);
                              final semester = int.tryParse(semesterController.text);
                              final achievedGPA = double.tryParse(achievedGPAController.text);
                              final totalGPA = double.tryParse(totalGPAController.text);

                              if (year != null && semester != null && achievedGPA != null && totalGPA != null) {
                                setState(() {
                                  _academicAchievements.add(
                                    AcademicRecord(
                                      year: year,
                                      semester: semester,
                                      achievedGPA: achievedGPA,
                                      totalGPA: totalGPA,
                                    ),
                                  );
                                });
                                Navigator.pop(context);
                                HapticFeedback.lightImpact();
                              } else {
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('모든 필드를 올바르게 입력하세요'),
                                    backgroundColor: ModernColors.error,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            isPrimary: true,
                            color: ModernColors.reading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate()
        .scale(begin: const Offset(0.95, 0.95), duration: 200.ms)
        .fade(duration: 150.ms),
    );
  }

  /// 대회 수상경력 추가 다이얼로그
  Future<void> _showCompetitionDialog() async {
    DateTime selectedDate = DateTime.now();
    final competitionNameController = TextEditingController();
    String selectedGrade = '대상';
    final grades = ['대상', '최우수상', '금상', '우수상', '은상', '장려상', '동상', '입선'];

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.quest.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernColors.quest.withValues(alpha: 0.1),
                              ModernColors.quest.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ModernColors.quest.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.emoji_events,
                                color: ModernColors.quest,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '대회 수상경력 추가',
                              style: GoogleFonts.notoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ModernColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildDatePickerButton(
                              context: context,
                              selectedDate: selectedDate,
                              onDateSelected: (date) {
                                setDialogState(() {
                                  selectedDate = date;
                                });
                              },
                              color: ModernColors.quest,
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: competitionNameController,
                              label: '대회 이름',
                              hint: '예: SW 컨테스트',
                              icon: Icons.emoji_events,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownButton<String>(
                              label: '수상 등급',
                              value: selectedGrade,
                              items: grades,
                              onChanged: (grade) {
                                setDialogState(() {
                                  selectedGrade = grade;
                                });
                              },
                              itemLabel: (grade) => grade,
                              icon: Icons.military_tech,
                              color: ModernColors.quest,
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildDialogButton(
                                label: '취소',
                                onPressed: () => Navigator.pop(context),
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDialogButton(
                                label: '추가',
                                onPressed: () {
                                  if (competitionNameController.text.isNotEmpty) {
                                    setState(() {
                                      _competitionAwards.add(
                                        CompetitionAward(
                                          date: selectedDate,
                                          competitionName: competitionNameController.text,
                                          awardGrade: selectedGrade,
                                        ),
                                      );
                                    });
                                    Navigator.pop(context);
                                    HapticFeedback.lightImpact();
                                  } else {
                                    HapticFeedback.mediumImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('대회 이름을 입력하세요'),
                                        backgroundColor: ModernColors.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                isPrimary: true,
                                color: ModernColors.quest,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate()
            .scale(begin: const Offset(0.95, 0.95), duration: 200.ms)
            .fade(duration: 150.ms);
        },
      ),
    );
  }

  /// 자격증 추가 다이얼로그
  Future<void> _showCertificationDialog() async {
    DateTime selectedDate = DateTime.now();
    final certificationNameController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.exercise.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernColors.exercise.withValues(alpha: 0.1),
                              ModernColors.exercise.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ModernColors.exercise.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.card_membership,
                                color: ModernColors.exercise,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '자격증 추가',
                              style: GoogleFonts.notoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ModernColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildDatePickerButton(
                              context: context,
                              selectedDate: selectedDate,
                              onDateSelected: (date) {
                                setDialogState(() {
                                  selectedDate = date;
                                });
                              },
                              color: ModernColors.exercise,
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: certificationNameController,
                              label: '자격증 이름',
                              hint: '예: 정보처리기사',
                              icon: Icons.card_membership,
                              keyboardType: TextInputType.text,
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildDialogButton(
                                label: '취소',
                                onPressed: () => Navigator.pop(context),
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDialogButton(
                                label: '추가',
                                onPressed: () {
                                  if (certificationNameController.text.isNotEmpty) {
                                    setState(() {
                                      _certifications.add(
                                        Certification(
                                          date: selectedDate,
                                          certificationName: certificationNameController.text,
                                        ),
                                      );
                                    });
                                    Navigator.pop(context);
                                    HapticFeedback.lightImpact();
                                  } else {
                                    HapticFeedback.mediumImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('자격증 이름을 입력하세요'),
                                        backgroundColor: ModernColors.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                isPrimary: true,
                                color: ModernColors.exercise,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate()
            .scale(begin: const Offset(0.95, 0.95), duration: 200.ms)
            .fade(duration: 150.ms);
        },
      ),
    );
  }

  /// 어학 성적 추가 다이얼로그
  Future<void> _showLanguageDialog() async {
    DateTime selectedDate = DateTime.now();
    final testNameController = TextEditingController();
    final scoreOrGradeController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.meeting.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernColors.meeting.withValues(alpha: 0.1),
                              ModernColors.meeting.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ModernColors.meeting.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.language,
                                color: ModernColors.meeting,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '어학 성적 추가',
                              style: GoogleFonts.notoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ModernColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildDatePickerButton(
                              context: context,
                              selectedDate: selectedDate,
                              onDateSelected: (date) {
                                setDialogState(() {
                                  selectedDate = date;
                                });
                              },
                              color: ModernColors.meeting,
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: testNameController,
                              label: '시험 이름',
                              hint: '예: TOEIC',
                              icon: Icons.translate,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: scoreOrGradeController,
                              label: '점수/등급',
                              hint: '예: 900점 또는 Level 7',
                              icon: Icons.grade,
                              keyboardType: TextInputType.text,
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildDialogButton(
                                label: '취소',
                                onPressed: () => Navigator.pop(context),
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDialogButton(
                                label: '추가',
                                onPressed: () {
                                  if (testNameController.text.isNotEmpty && scoreOrGradeController.text.isNotEmpty) {
                                    setState(() {
                                      _languageScores.add(
                                        LanguageScore(
                                          date: selectedDate,
                                          testName: testNameController.text,
                                          scoreOrGrade: scoreOrGradeController.text,
                                        ),
                                      );
                                    });
                                    Navigator.pop(context);
                                    HapticFeedback.lightImpact();
                                  } else {
                                    HapticFeedback.mediumImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('모든 필드를 입력하세요'),
                                        backgroundColor: ModernColors.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                isPrimary: true,
                                color: ModernColors.meeting,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate()
            .scale(begin: const Offset(0.95, 0.95), duration: 200.ms)
            .fade(duration: 150.ms);
        },
      ),
    );
  }

  /// 모던 텍스트 필드 빌더
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.reading.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.notoSans(
          fontSize: 16,
          color: ModernColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: ModernColors.reading, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: GoogleFonts.notoSans(
            color: ModernColors.textSecondary,
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.notoSans(
            color: ModernColors.textTertiary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// 다이얼로그 버튼 빌더
  Widget _buildDialogButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    Color? color,
  }) {
    final buttonColor = color ?? ModernColors.primary;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    buttonColor,
                    buttonColor.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? buttonColor.withValues(alpha: 0.3)
                : ModernColors.textTertiary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : ModernColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 날짜 선택 버튼 빌더
  Widget _buildDatePickerButton({
    required BuildContext context,
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '날짜',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: color),
          ],
        ),
      ),
    );
  }

  /// 드롭다운 선택 버튼 빌더
  Widget _buildDropdownButton<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T) onChanged,
    required String Function(T) itemLabel,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(itemLabel(item)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      HapticFeedback.lightImpact();
                      onChanged(newValue);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 정보 아이템 헬퍼 클래스
class _InfoItem {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
