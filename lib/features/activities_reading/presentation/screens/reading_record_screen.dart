// lib/features/daily_record/presentation/screens/reading_record_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';

class ReadingRecordScreen extends ConsumerStatefulWidget {
  final DateTime? targetDate;
  final ReadingLog? editingLog;

  const ReadingRecordScreen({
    super.key,
    this.targetDate,
    this.editingLog,
  });

  @override
  ConsumerState<ReadingRecordScreen> createState() =>
      _ReadingRecordScreenState();
}

class _ReadingRecordScreenState extends ConsumerState<ReadingRecordScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _startPageController = TextEditingController();
  final TextEditingController _endPageController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = '';
  double _rating = 0.0;
  String _selectedEmotion = '';
  bool _shareWithCommunity = false;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {'id': '소설', 'emoji': '📚', 'label': '소설'},
    {'id': '자기계발', 'emoji': '💡', 'label': '자기계발'},
    {'id': '경영', 'emoji': '💼', 'label': '경영'},
    {'id': '과학', 'emoji': '🔬', 'label': '과학'},
    {'id': '역사', 'emoji': '📜', 'label': '역사'},
    {'id': '예술', 'emoji': '🎨', 'label': '예술'},
    {'id': '인문학', 'emoji': '📖', 'label': '인문학'},
    {'id': '철학', 'emoji': '🤔', 'label': '철학'},
    {'id': '심리학', 'emoji': '🧠', 'label': '심리학'},
    {'id': 'SF', 'emoji': '🚀', 'label': 'SF'},
    {'id': '기타', 'emoji': '📗', 'label': '기타'},
  ];

  final List<Map<String, dynamic>> _emotions = [
    {'id': 'happy', 'emoji': '😊', 'label': '기뻤어요'},
    {'id': 'excited', 'emoji': '🥰', 'label': '설렜어요'},
    {'id': 'thoughtful', 'emoji': '🤔', 'label': '생각이 많아졌어요'},
    {'id': 'moved', 'emoji': '🥺', 'label': '감동적이었어요'},
    {'id': 'surprised', 'emoji': '😮', 'label': '놀라웠어요'},
    {'id': 'calm', 'emoji': '😌', 'label': '편안했어요'},
  ];

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

    // 편집 모드일 때 기존 데이터 로드
    if (widget.editingLog != null) {
      _loadEditingData();
    }

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  void _loadEditingData() {
    final log = widget.editingLog!;
    _bookTitleController.text = log.bookTitle;
    _noteController.text = log.note ?? '';
    _rating = log.rating ?? 0.0;
    _selectedEmotion = log.mood ?? '';
    _shareWithCommunity = log.isShared;

    // 페이지 정보는 단순화 (총 페이지만 표시)
    _endPageController.text = log.pages.toString();
    _startPageController.text = '1';

    // 카테고리 설정
    final categoryMap = _categories.firstWhere(
      (cat) => cat['id'] == log.category,
      orElse: () => _categories.first,
    );
    _selectedCategory = categoryMap['id'];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _bookTitleController.dispose();
    _startPageController.dispose();
    _endPageController.dispose();
    _noteController.dispose();
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
        leading: Container(
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
          ),
        ),
        actions: [
          if (_canSubmit())
            Container(
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
                onPressed: _isSubmitting ? null : _submitReading,
                child: Text(
                  widget.editingLog != null ? '수정' : '완료',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _isSubmitting
                        ? ModernColors.textTertiary
                        : ModernColors.reading,
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
            // 배경 그라데이션
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ModernColors.reading,
                    ModernColors.reading.withValues(alpha: 0.7),
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
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeader(),
                  ),

                  const SizedBox(height: 24),

                  // 카테고리 선택
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildCategorySelector(),
                  ),

                  const SizedBox(height: 24),

                  // 책 제목 입력
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildBookTitleInput(),
                  ),

                  const SizedBox(height: 20),

                  // 페이지 입력
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildPageInput(),
                  ),

                  const SizedBox(height: 20),

                  // 평점 선택
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildRatingSelector(),
                  ),

                  const SizedBox(height: 20),

                  // 감정 선택
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildEmotionSelector(),
                  ),

                  const SizedBox(height: 20),

                  // 메모 입력
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildNoteInput(),
                  ),

                  const SizedBox(height: 20),

                  // 사진 섹션
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildPhotoSection(),
                  ),

                  const SizedBox(height: 20),

                  // 공유 옵션
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildShareOption(),
                  ),

                  const SizedBox(height: 32),

                  // 저장 버튼
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSubmitButton(),
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

  Widget _buildHeader() {
    final targetDate = widget.targetDate ?? DateTime.now();
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
            color: ModernColors.reading.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                      ModernColors.reading,
                      ModernColors.reading.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.reading.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  widget.editingLog != null
                      ? Icons.edit_note
                      : Icons.menu_book_rounded,
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
                      widget.editingLog != null ? '독서 기록 수정하기' : '독서 기록하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.reading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.editingLog != null
                          ? '기록을 편집해보세요'
                          : '오늘 읽은 책을 기록해보세요',
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

          // 날짜 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: ModernColors.reading.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ModernColors.reading.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: ModernColors.reading,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$dateStr $weekday',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.reading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                        color: ModernColors.reading.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: ModernColors.reading,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '어떤 분야의 책을 읽으셨나요?',
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '책의 장르를 선택해주세요',
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

                // 카테고리 선택 칩들
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _categories
                      .map((category) => _buildCategoryChip(category))
                      .toList(),
                ),

                if (_selectedCategory.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ModernColors.reading.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ModernColors.reading.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _categories.firstWhere(
                              (cat) => cat['id'] == _selectedCategory)['emoji'],
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '"${_categories.firstWhere((cat) => cat['id'] == _selectedCategory)['label']}" 카테고리를 선택하셨네요! 📖',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.reading,
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

  Widget _buildCategoryChip(Map<String, dynamic> category) {
    final isSelected = _selectedCategory == category['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['id'];
        });
        HapticFeedbackManager.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    ModernColors.reading,
                    ModernColors.reading.withValues(alpha: 0.85)
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ModernColors.reading
                : ModernColors.textTertiary.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ModernColors.reading.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category['emoji'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              category['label'],
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

  Widget _buildBookTitleInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    color: ModernColors.reading.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: ModernColors.reading,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '책 제목',
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
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _bookTitleController.text.isNotEmpty
                      ? ModernColors.reading.withValues(alpha: 0.3)
                      : ModernColors.textTertiary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _bookTitleController,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: '예: 데미안, 어린 왕자, 1984',
                  hintStyle: GoogleFonts.notoSans(
                    color: ModernColors.textTertiary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.book_outlined,
                      color: ModernColors.reading,
                      size: 24,
                    ),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    color: ModernColors.reading.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: ModernColors.reading,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '읽은 페이지',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '오늘 읽은 범위를 기록해주세요',
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _startPageController.text.isNotEmpty
                            ? ModernColors.reading.withValues(alpha: 0.3)
                            : ModernColors.textTertiary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _startPageController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '시작',
                        hintStyle: GoogleFonts.notoSans(
                          color: ModernColors.textTertiary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ModernColors.reading.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: ModernColors.reading,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _endPageController.text.isNotEmpty
                            ? ModernColors.reading.withValues(alpha: 0.3)
                            : ModernColors.textTertiary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _endPageController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '끝',
                        hintStyle: GoogleFonts.notoSans(
                          color: ModernColors.textTertiary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
              ],
            ),

            // 페이지 수 표시
            if (_startPageController.text.isNotEmpty &&
                _endPageController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ModernColors.reading.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: ModernColors.reading,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '총 ${(int.tryParse(_endPageController.text) ?? 0) - (int.tryParse(_startPageController.text) ?? 0) + 1}페이지를 읽으셨네요!',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.reading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '책은 어떠셨나요?',
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '별점으로 평가해주세요',
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
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final fullStarValue = index + 1.0;
                      final halfStarValue = index + 0.5;
                      final isFullSelected = _rating >= fullStarValue;
                      final isHalfSelected =
                          _rating >= halfStarValue && _rating < fullStarValue;

                      return Row(
                        children: [
                          // 별의 왼쪽 절반 (0.5점 클릭 영역)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = halfStarValue;
                              });
                              HapticFeedbackManager.lightImpact();
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                  top: 4, bottom: 4, left: 2, right: 0),
                              child: Stack(
                                children: [
                                  // 별 전체 (클리핑용)
                                  ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: 0.5,
                                      child: Icon(
                                        isHalfSelected || isFullSelected
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: isHalfSelected || isFullSelected
                                            ? Colors.amber
                                            : Colors.grey.shade300,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 별의 오른쪽 절반 (1.0점 클릭 영역)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = fullStarValue;
                              });
                              HapticFeedbackManager.lightImpact();
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                  top: 4, bottom: 4, left: 0, right: 2),
                              child: Stack(
                                children: [
                                  // 별 전체 (클리핑용)
                                  ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      widthFactor: 0.5,
                                      child: Icon(
                                        isFullSelected
                                            ? Icons.star_rounded
                                            : (isHalfSelected
                                                ? Icons.star_outline_rounded
                                                : Icons.star_outline_rounded),
                                        color: isFullSelected
                                            ? Colors.amber
                                            : Colors.grey.shade300,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    color: ModernColors.reading.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mood,
                    color: ModernColors.reading,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '읽고 난 후 기분은?',
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '책을 읽고 난 후의 감정을 선택해주세요',
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

            // 감정 선택 칩들
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _emotions
                  .map((emotion) => _buildEmotionChip(emotion))
                  .toList(),
            ),

            if (_selectedEmotion.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ModernColors.reading.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ModernColors.reading.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _emotions.firstWhere(
                          (e) => e['id'] == _selectedEmotion)['emoji'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_emotions.firstWhere((e) => e['id'] == _selectedEmotion)['label']} 기분이시군요! ✨',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.reading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionChip(Map<String, dynamic> emotion) {
    final isSelected = _selectedEmotion == emotion['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmotion = emotion['id'];
        });
        HapticFeedbackManager.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    ModernColors.reading,
                    ModernColors.reading.withValues(alpha: 0.85)
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ModernColors.reading
                : ModernColors.textTertiary.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ModernColors.reading.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emotion['emoji'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              emotion['label'],
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

  Widget _buildNoteInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    color: ModernColors.reading.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.format_quote,
                    color: ModernColors.reading,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '한마디, 오늘의 문장 등',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '책에서 인상 깊었던 부분을 기록해보세요',
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
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _noteController.text.isNotEmpty
                      ? ModernColors.reading.withValues(alpha: 0.3)
                      : ModernColors.textTertiary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 8,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textPrimary,
                  height: 1.7,
                ),
                decoration: InputDecoration(
                  hintText:
                      '인상 깊었던 구절이나 느낀 점을 적어보세요...\n\n📌 이런 것들을 기록해보세요:\n\n• 기억에 남는 문장\n• 새롭게 알게 된 점\n• 삶에 적용해보고 싶은 내용\n• 저자의 통찰이 돋보였던 부분',
                  hintStyle: GoogleFonts.notoSans(
                    color: ModernColors.textTertiary,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(24),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),

            // 글자 수 표시
            if (_noteController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12, right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ModernColors.reading.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_noteController.text.length}자',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.reading,
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

  Widget _buildPhotoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                    color: ModernColors.reading.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: ModernColors.reading,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '책 사진 (선택)',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // TODO: 사진 선택 구현
                HapticFeedbackManager.lightImpact();
              },
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ModernColors.reading.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ModernColors.reading.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: ModernColors.reading,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '책 표지나 메모 사진 추가하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '탭하여 사진 선택',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernColors.reading.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: ModernColors.reading,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사람들과 공유해보세요!',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '독서 기록을 커뮤니티에 공유하기',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: _shareWithCommunity
                    ? [
                        BoxShadow(
                          color: ModernColors.reading.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Switch(
                value: _shareWithCommunity,
                onChanged: (value) {
                  setState(() {
                    _shareWithCommunity = value;
                  });
                  HapticFeedbackManager.lightImpact();
                },
                activeColor: ModernColors.reading,
                inactiveTrackColor: Colors.grey.shade300,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _canSubmit();
    final buttonColor =
        canSubmit ? ModernColors.reading : ModernColors.textTertiary;

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
                    color: buttonColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: canSubmit && !_isSubmitting ? _submitReading : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
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
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.editingLog != null ? '수정하는 중...' : '기록하는 중...',
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
                      widget.editingLog != null
                          ? Icons.edit
                          : Icons.menu_book_rounded,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.editingLog != null ? '독서 기록 수정 완료' : '독서 기록 작성 완료',
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
    return _selectedCategory.isNotEmpty &&
        _bookTitleController.text.trim().isNotEmpty &&
        _startPageController.text.trim().isNotEmpty &&
        _endPageController.text.trim().isNotEmpty &&
        _rating > 0; // 별점 필수 조건 추가
  }

  Future<void> _submitReading() async {
    if (!_canSubmit()) return;

    setState(() => _isSubmitting = true);

    try {
      // 페이지 수 계산
      final startPage = int.tryParse(_startPageController.text) ?? 0;
      final endPage = int.tryParse(_endPageController.text) ?? 0;
      final pagesRead = endPage - startPage + 1;

      // 사용할 날짜 결정
      final targetDate = widget.targetDate ?? DateTime.now();

      // 독서 로그 생성 또는 수정
      final readingLog = ReadingLog(
        id: widget.editingLog?.id ??
            'reading_${DateTime.now().millisecondsSinceEpoch}',
        date: targetDate,
        bookTitle: _bookTitleController.text.trim(),
        author: widget.editingLog?.author ?? '', // 기존 저자 정보 유지 또는 빈 문자열
        pages: pagesRead > 0 ? pagesRead : 1,
        rating: _rating,
        category: _selectedCategory.isNotEmpty ? _selectedCategory : '소설',
        mood: _selectedEmotion.isNotEmpty ? _selectedEmotion : null,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        isShared: _shareWithCommunity,
      );

      // 독서 기록 추가 또는 수정
      if (widget.editingLog != null) {
        ref.read(globalUserProvider.notifier).updateReadingLog(readingLog);
      } else {
        ref.read(globalUserProvider.notifier).addReadingLog(readingLog);
      }

      // AI 분석은 이제 GlobalUserNotifier.handleActivityCompletion에서 자동으로 처리됨

      HapticFeedbackManager.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '독서 기록이 완료되었어요! 📚',
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

        // 2초 후 화면 닫기 및 수정된 데이터 반환
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop(readingLog);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '독서 기록 저장에 실패했습니다. 다시 시도해주세요.',
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
