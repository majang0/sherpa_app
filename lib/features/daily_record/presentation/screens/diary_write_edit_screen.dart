// lib/features/daily_record/presentation/screens/diary_write_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/models/global_user_model.dart';

class DiaryWriteEditScreen extends ConsumerStatefulWidget {
  final DateTime? selectedDate;
  final DiaryLog? existingDiary;

  const DiaryWriteEditScreen({
    this.selectedDate,
    this.existingDiary,
  });

  @override
  ConsumerState<DiaryWriteEditScreen> createState() =>
      _DiaryWriteEditScreenState();
}

class _DiaryWriteEditScreenState extends ConsumerState<DiaryWriteEditScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = '';
  bool _isSubmitting = false;

  // 중앙집중식 감정 데이터 사용
  List<Map<String, dynamic>> get _moods => MoodConstants.moodList;

  bool get isEditing => widget.existingDiary != null;
  DateTime get targetDate =>
      widget.selectedDate ?? widget.existingDiary?.date ?? DateTime.now();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // 기존 일기 데이터 로드
    if (widget.existingDiary != null) {
      _titleController.text = widget.existingDiary!.title;
      _contentController.text = widget.existingDiary!.content;
      _selectedMood = widget.existingDiary!.mood;
    }

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMoodInfo = _selectedMood.isNotEmpty
        ? MoodConstants.getMoodInfo(_selectedMood)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black87, size: 20),
          ),
        ),
        actions: [
          if (_canSubmit())
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: _isSubmitting ? null : _submitDiary,
                child: Text(
                  isEditing ? '수정' : '완료',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _isSubmitting
                        ? ModernColors.textTertiary
                        : ModernColors.diary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 배경 그라데이션 (일관된 블루 계열)
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ModernColors.diary,
                    ModernColors.diary.withOpacity(0.7),
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

                  // 헤더 섹션 (날짜, 제목)
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeader(selectedMoodInfo),
                  ),

                  const SizedBox(height: 24),

                  // 기분 선택 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildMoodSelector(),
                  ),

                  const SizedBox(height: 24),

                  // 제목 입력 섹션
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTitleInput(),
                  ),

                  const SizedBox(height: 20),

                  // 내용 입력 섹션
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildContentInput(),
                  ),

                  const SizedBox(height: 32),

                  // 저장 버튼
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSubmitButton(selectedMoodInfo),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? moodInfo) {
    final dateStr =
        '${targetDate.year}년 ${targetDate.month}월 ${targetDate.day}일';
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[targetDate.weekday - 1];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                      ModernColors.primary,
                      ModernColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  isEditing ? Icons.edit_note : Icons.edit_calendar,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? '일기 수정하기' : '일기 작성하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEditing ? '이 일기를 편집해보세요' : '오늘의 소중한 순간들을 기록해보세요',
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
                  ModernColors.diary.withOpacity(0.05),
                  ModernColors.diary.withOpacity(0.08),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.diary.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ModernColors.diary.withOpacity(0.12),
                        ModernColors.diary.withOpacity(0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.diary.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: ModernColors.diary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$dateStr $weekday',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.diary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 섹션 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ModernColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sentiment_satisfied,
                        color: ModernColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 기분은 어떠세요?',
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '하루를 대표하는 기분을 선택해주세요',
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

                // 기분 선택 그리드 (4x2)
                Column(
                  children: [
                    // 첫 번째 행 (4개)
                    Row(
                      children: _moods
                          .take(4)
                          .map((mood) =>
                              Expanded(child: _buildMoodGridItem(mood)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // 두 번째 행 (4개)
                    Row(
                      children: _moods
                          .skip(4)
                          .take(4)
                          .map((mood) =>
                              Expanded(child: _buildMoodGridItem(mood)))
                          .toList(),
                    ),
                  ],
                ),

                if (_selectedMood.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          MoodConstants.getMoodBackgroundColor(_selectedMood),
                          MoodConstants.getMoodBackgroundColor(_selectedMood)
                              .withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              MoodConstants.getMoodSelectedColor(_selectedMood)
                                  .withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MoodConstants.getMoodSelectedColor(
                                _selectedMood),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: MoodConstants.getMoodSelectedColor(
                                        _selectedMood)
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            MoodConstants.getMoodEmoji(_selectedMood),
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '오늘의 기분을 선택했어요!',
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ModernColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"${MoodConstants.getMoodLabel(_selectedMood)}"',
                                style: GoogleFonts.notoSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: MoodConstants.getMoodSelectedColor(
                                      _selectedMood),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChip(Map<String, dynamic> mood) {
    final isSelected = _selectedMood == mood['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood['id'];
        });
        HapticFeedbackManager.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? mood['selectedColor']
              : ModernColors.backgroundElevated,
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? Border.all(color: mood['selectedColor'], width: 2)
              : Border.all(color: ModernColors.border, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: mood['selectedColor'].withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: mood['selectedColor'].withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: ModernColors.shadowBase.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                    spreadRadius: -0.5,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 22 : 18,
              ),
              child: Text(mood['emoji']),
            ),
            const SizedBox(width: 8),
            Text(
              mood['label'],
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ModernColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodGridItem(Map<String, dynamic> mood) {
    final isSelected = _selectedMood == mood['id'];

    return Container(
      margin: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMood = mood['id'];
          });
          HapticFeedbackManager.lightImpact();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          height: 80, // 1:1 비율을 위한 고정 높이
          decoration: BoxDecoration(
            color: isSelected ? mood['selectedColor'] : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            // 테두리 제거
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: mood['selectedColor'].withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이모지
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSelected ? 30 : 26,
                ),
                child: Text(mood['emoji']),
              ),
              const SizedBox(height: 6),
              // 라벨
              Text(
                mood['label'],
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : ModernColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
                    color: ModernColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.title,
                    color: ModernColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '제목 (선택사항)',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _titleController.text.isNotEmpty
                        ? ModernColors.diary.withOpacity(0.02)
                        : ModernColors.backgroundElevated,
                    _titleController.text.isNotEmpty
                        ? ModernColors.diary.withOpacity(0.05)
                        : ModernColors.backgroundFloating,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _titleController.text.isNotEmpty
                        ? ModernColors.diary.withOpacity(0.12)
                        : ModernColors.textTertiary.withOpacity(0.06),
                    blurRadius: _titleController.text.isNotEmpty ? 16 : 8,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: TextField(
                controller: _titleController,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: '예: 오늘의 소중한 순간들',
                  hintStyle: GoogleFonts.notoSans(
                    color: ModernColors.textTertiary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(22),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
                    color: ModernColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.article,
                    color: ModernColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘 하루 어떠셨나요?',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '자유롭게 기록해보세요',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _contentController.text.isNotEmpty
                        ? ModernColors.diary.withOpacity(0.02)
                        : ModernColors.backgroundElevated,
                    _contentController.text.isNotEmpty
                        ? ModernColors.diary.withOpacity(0.04)
                        : ModernColors.backgroundSubtle,
                    _contentController.text.isNotEmpty
                        ? ModernColors.diary.withOpacity(0.06)
                        : ModernColors.backgroundFloating,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _contentController.text.isNotEmpty
                        ? ModernColors.diary.withOpacity(0.15)
                        : ModernColors.shadowBase.withOpacity(0.05),
                    blurRadius: _contentController.text.isNotEmpty ? 20 : 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 12,
                onChanged: (_) =>
                    setState(() {}), // Update for dynamic UI changes
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textPrimary,
                  height: 1.7,
                ),
                decoration: InputDecoration(
                  hintText:
                      '오늘의 소중한 순간들을 기록해보세요...\n\n✨ 이런 것들을 적어보세요:\n\n• 감사했던 순간들\n• 새롭게 배운 것들\n• 만났던 사람들과의 이야기\n• 느꼈던 감정들\n• 내일에 대한 계획이나 기대',
                  hintStyle: GoogleFonts.notoSans(
                    color: ModernColors
                        .textPlaceholder, // Improved contrast for accessibility
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(26),
                ),
              ),
            ),

            // 글자 수 표시
            if (_contentController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12, right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ModernColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_contentController.text.length}자',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Map<String, dynamic>? moodInfo) {
    final canSubmit = _canSubmit();
    final buttonColor = canSubmit ? ModernColors.diary : ModernColors.gray300;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: canSubmit
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: buttonColor.withOpacity(0.2),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: ModernColors.shadowBase.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: canSubmit && !_isSubmitting ? _submitDiary : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canSubmit ? buttonColor : ModernColors.gray200,
            foregroundColor:
                canSubmit ? Colors.white : ModernColors.textSecondary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? '수정하는 중...' : '기록하는 중...',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.check_circle,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEditing ? '일기 수정 완료' : '일기 작성 완료',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  bool _canSubmit() {
    return _selectedMood.isNotEmpty &&
        _contentController.text.trim().isNotEmpty;
  }

  Future<void> _submitDiary() async {
    if (!_canSubmit()) return;

    setState(() => _isSubmitting = true);

    try {
      final title = _titleController.text.trim().isEmpty
          ? '${targetDate.month}월 ${targetDate.day}일의 일기'
          : _titleController.text.trim();

      if (isEditing) {
        // 기존 일기 수정
        final updatedDiary = DiaryLog(
          id: widget.existingDiary!.id,
          date: targetDate,
          title: title,
          content: _contentController.text.trim(),
          mood: _selectedMood,
        );

        ref.read(globalUserProvider.notifier).updateDiaryLog(updatedDiary);

        if (mounted) {
          HapticFeedbackManager.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    '일기가 수정되었어요! ✨',
                    style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: ModernColors.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          Navigator.of(context).pop(true);
        }
      } else {
        // 새 일기 작성
        final diaryLog = DiaryLog(
          id: 'diary_${targetDate.millisecondsSinceEpoch}',
          date: targetDate,
          title: title,
          content: _contentController.text.trim(),
          mood: _selectedMood,
        );

        ref.read(globalUserProvider.notifier).addDiaryLog(diaryLog);

        if (mounted) {
          HapticFeedbackManager.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    '오늘의 일기가 기록되었어요! 🎉',
                    style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: ModernColors.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '일기 저장에 실패했습니다. 다시 시도해주세요.',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
