// lib/features/daily_record/presentation/screens/meeting_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/record_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/models/global_user_model.dart';

class MeetingEditScreen extends ConsumerStatefulWidget {
  final MeetingLog meeting;
  
  const MeetingEditScreen({required this.meeting});

  @override
  ConsumerState<MeetingEditScreen> createState() => _MeetingEditScreenState();
}

class _MeetingEditScreenState extends ConsumerState<MeetingEditScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _noteController = TextEditingController();
  double _satisfaction = 3.0;
  String _selectedMood = 'happy';
  bool _isShared = false;
  bool _isSubmitting = false;

  // 기분 데이터 매핑
  final List<Map<String, dynamic>> _moods = [
    {'id': 'very_happy', 'emoji': '😄', 'label': '매우 좋았음'},
    {'id': 'happy', 'emoji': '😊', 'label': '좋았음'},
    {'id': 'good', 'emoji': '🙂', 'label': '괜찮았음'},
    {'id': 'normal', 'emoji': '😐', 'label': '보통'},
    {'id': 'tired', 'emoji': '😴', 'label': '피곤했음'},
    {'id': 'stressed', 'emoji': '😰', 'label': '스트레스'},
  ];

  // 카테고리별 색상 매핑
  final Map<String, Map<String, dynamic>> _categoryData = {
    '스터디': {'emoji': '📚', 'color': Color(0xFF3B82F6), 'gradient': [Color(0xFF3B82F6), Color(0xFF1E3A8A)]},
    '운동': {'emoji': '🏃', 'color': Color(0xFF10B981), 'gradient': [Color(0xFF10B981), Color(0xFF047857)]},
    '독서': {'emoji': '📖', 'color': Color(0xFF8B5CF6), 'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)]},
    '취미': {'emoji': '🎨', 'color': Color(0xFFF59E0B), 'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)]},
    '네트워킹': {'emoji': '🤝', 'color': Color(0xFFEC4899), 'gradient': [Color(0xFFEC4899), Color(0xFFDB2777)]},
    '업무': {'emoji': '💼', 'color': Color(0xFF6B7280), 'gradient': [Color(0xFF6B7280), Color(0xFF4B5563)]},
    '친목': {'emoji': '🍻', 'color': Color(0xFFEF4444), 'gradient': [Color(0xFFEF4444), Color(0xFFDC2626)]},
    '종교': {'emoji': '🙏', 'color': Color(0xFF06B6D4), 'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)]},
    '봉사': {'emoji': '❤️', 'color': Color(0xFF84CC16), 'gradient': [Color(0xFF84CC16), Color(0xFF65A30D)]},
  };

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
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // 기존 모임 데이터 로드
    _noteController.text = widget.meeting.note ?? '';
    _satisfaction = widget.meeting.satisfaction;
    _selectedMood = widget.meeting.mood;
    _isShared = widget.meeting.isShared;

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
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryInfo = _categoryData[widget.meeting.category] ?? _categoryData['친목']!;
    
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          ),
        ),
        actions: [
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
            child: IconButton(
              onPressed: _isSubmitting ? null : _saveMeeting,
              icon: Icon(
                Icons.check,
                color: _isSubmitting ? Colors.grey : categoryInfo['color'],
                size: 20,
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
                  colors: categoryInfo['gradient'],
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
                    child: _buildHeader(categoryInfo),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 변경 불가능한 정보 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildReadOnlyInfo(categoryInfo),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 만족도 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSatisfactionSection(categoryInfo),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 기분 선택 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildMoodSection(categoryInfo),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 한마디 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildNoteSection(categoryInfo),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 공유 설정 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildShareSection(categoryInfo),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 저장 버튼
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSaveButton(categoryInfo),
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

  Widget _buildHeader(Map<String, dynamic> categoryInfo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: categoryInfo['color'].withOpacity(0.2),
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
          // 카테고리 아이콘과 정보
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: categoryInfo['gradient'],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: categoryInfo['color'].withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit,
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
                      '모임 기록 수정',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: categoryInfo['color'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '만족도, 기분, 한마디를 수정할 수 있어요',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: RecordColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyInfo(Map<String, dynamic> categoryInfo) {
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
                    color: RecordColors.textLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lock_outlined,
                    color: RecordColors.textSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '변경 불가 정보',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: RecordColors.textLight.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildReadOnlyInfoRow('📅', '날짜', _formatDate(widget.meeting.date)),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfoRow(categoryInfo['emoji'], '분류', widget.meeting.category),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfoRow('📝', '모임명', widget.meeting.meetingName),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '모임명과 분류는 수정할 수 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: RecordColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyInfoRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: RecordColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: RecordColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSatisfactionSection(Map<String, dynamic> categoryInfo) {
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
                    color: const Color(0xFFFBBF24).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.star,
                    color: const Color(0xFFFBBF24),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '만족도',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_satisfaction.toStringAsFixed(1)}/5.0',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFBBF24),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFBBF24).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) {
                        final starValue = index + 1;
                        final isFullStar = _satisfaction >= starValue;
                        final isHalfStar = _satisfaction >= starValue - 0.5 && _satisfaction < starValue;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_satisfaction == starValue) {
                                // 이미 선택된 별을 클릭하면 0.5 감소
                                _satisfaction = (starValue - 0.5).clamp(0.5, 5.0);
                              } else {
                                // 새로운 별을 클릭하면 해당 값으로 설정
                                _satisfaction = starValue.toDouble();
                              }
                            });
                            HapticFeedbackManager.lightImpact();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Stack(
                              children: [
                                Icon(
                                  Icons.star_border,
                                  size: 32,
                                  color: const Color(0xFFFBBF24),
                                ),
                                if (isFullStar)
                                  Icon(
                                    Icons.star,
                                    size: 32,
                                    color: const Color(0xFFFBBF24),
                                  )
                                else if (isHalfStar)
                                  ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: 0.5,
                                      child: Icon(
                                        Icons.star,
                                        size: 32,
                                        color: const Color(0xFFFBBF24),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFFBBF24),
                      inactiveTrackColor: const Color(0xFFFBBF24).withOpacity(0.2),
                      thumbColor: const Color(0xFFFBBF24),
                      overlayColor: const Color(0xFFFBBF24).withOpacity(0.2),
                      trackHeight: 6,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                    ),
                    child: Slider(
                      value: _satisfaction,
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      onChanged: (value) {
                        setState(() {
                          _satisfaction = value;
                        });
                        HapticFeedbackManager.lightImpact();
                      },
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

  Widget _buildMoodSection(Map<String, dynamic> categoryInfo) {
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
                    color: categoryInfo['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.sentiment_satisfied,
                    color: categoryInfo['color'],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '기분',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: categoryInfo['color'].withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _moods.map((mood) {
                  final isSelected = _selectedMood == mood['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = mood['id'];
                      });
                      HapticFeedbackManager.lightImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? categoryInfo['color'] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? categoryInfo['color'] : RecordColors.textLight.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: categoryInfo['color'].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mood['emoji'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mood['label'],
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : RecordColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection(Map<String, dynamic> categoryInfo) {
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
                    color: categoryInfo['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    color: categoryInfo['color'],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '한마디',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: categoryInfo['color'].withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '모임에 대한 생각이나 느낌을 자유롭게 적어보세요...',
                  hintStyle: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: RecordColors.textLight,
                  ),
                  counterText: '',
                ),
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: RecordColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareSection(Map<String, dynamic> categoryInfo) {
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
                    color: categoryInfo['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.share,
                    color: categoryInfo['color'],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '공유 설정',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: categoryInfo['color'].withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isShared ? Icons.public : Icons.lock,
                    color: categoryInfo['color'],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isShared ? '공개' : '비공개',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: RecordColors.textPrimary,
                          ),
                        ),
                        Text(
                          _isShared ? '다른 사용자가 볼 수 있어요' : '나만 볼 수 있어요',
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
                      setState(() {
                        _isShared = value;
                      });
                      HapticFeedbackManager.lightImpact();
                    },
                    activeColor: categoryInfo['color'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(Map<String, dynamic> categoryInfo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: categoryInfo['color'].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _saveMeeting,
          style: ElevatedButton.styleFrom(
            backgroundColor: categoryInfo['color'],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '수정 완료',
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

  String _formatDate(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays[date.weekday % 7]})';
  }

  void _saveMeeting() async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });

    HapticFeedbackManager.mediumImpact();

    try {
      final updatedMeeting = MeetingLog(
        id: widget.meeting.id,
        date: widget.meeting.date,
        meetingName: widget.meeting.meetingName,
        category: widget.meeting.category,
        satisfaction: _satisfaction,
        mood: _selectedMood,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        isShared: _isShared,
      );

      // 기존 모임 로그를 찾아서 업데이트
      final user = ref.read(globalUserProvider);
      final updatedMeetingLogs = user.dailyRecords.meetingLogs.map((log) {
        if (log.id == widget.meeting.id) {
          return updatedMeeting;
        }
        return log;
      }).toList();
      
      final updatedRecords = user.dailyRecords.copyWith(
        meetingLogs: updatedMeetingLogs,
      );
      
      final updatedUser = user.copyWith(dailyRecords: updatedRecords);
      ref.read(globalUserProvider.notifier).state = updatedUser;

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // 상세보기 화면도 닫기
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '모임 기록이 수정되었습니다! 👥',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF8B5CF6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '수정 중 오류가 발생했습니다. 다시 시도해주세요.',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
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
}