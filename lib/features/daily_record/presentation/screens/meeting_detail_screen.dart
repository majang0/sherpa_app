// lib/features/daily_record/presentation/screens/meeting_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/record_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import 'meeting_edit_screen.dart';

class MeetingDetailScreen extends ConsumerStatefulWidget {
  final MeetingLog meeting;
  
  const MeetingDetailScreen({required this.meeting});

  @override
  ConsumerState<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends ConsumerState<MeetingDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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
              onPressed: _editMeeting,
              icon: Icon(
                Icons.edit_outlined,
                color: categoryInfo['color'],
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
                  
                  // 헤더 섹션 (날짜, 모임정보)
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeader(categoryInfo),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 모임 정보 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildMeetingInfo(categoryInfo),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 만족도 및 기분 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSatisfactionMood(categoryInfo),
                  ),
                  
                  if (widget.meeting.note != null) ...[
                    const SizedBox(height: 20),
                    
                    // 노트 섹션
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildNote(categoryInfo),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // 액션 버튼들
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildActionButtons(categoryInfo),
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
          // 카테고리 아이콘과 기분
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
                child: Text(
                  categoryInfo['emoji'],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(widget.meeting.date),
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: RecordColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.meeting.category,
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: categoryInfo['color'],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: categoryInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: categoryInfo['color'].withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.meeting.moodIcon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 모임 이름
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: categoryInfo['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: categoryInfo['color'].withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              widget.meeting.meetingName,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: categoryInfo['color'],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingInfo(Map<String, dynamic> categoryInfo) {
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
                    Icons.info_outline,
                    color: categoryInfo['color'],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '모임 정보',
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
                  color: categoryInfo['color'].withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow('📅', '날짜', _formatFullDate(widget.meeting.date)),
                  const SizedBox(height: 12),
                  _buildInfoRow('📂', '분류', widget.meeting.category),
                  const SizedBox(height: 12),
                  _buildInfoRow('🔗', '공유', widget.meeting.isShared ? '공개' : '비공개'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSatisfactionMood(Map<String, dynamic> categoryInfo) {
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
                  '만족도 & 기분',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                // 만족도
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFBBF24).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '⭐',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.meeting.satisfaction.toStringAsFixed(1)}/5.0',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < widget.meeting.satisfaction.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: const Color(0xFFFBBF24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 기분
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: categoryInfo['color'].withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.meeting.moodIcon,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMoodLabel(widget.meeting.mood),
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: categoryInfo['color'],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNote(Map<String, dynamic> categoryInfo) {
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
                    Icons.note_outlined,
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
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: categoryInfo['color'].withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                widget.meeting.note!,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: RecordColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
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
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: RecordColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> categoryInfo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 수정하기 버튼
          Expanded(
            child: Container(
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
                onPressed: _editMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: categoryInfo['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '수정하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 공유하기 버튼
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: categoryInfo['color'].withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _shareMeeting,
              icon: Icon(
                Icons.share_outlined,
                color: categoryInfo['color'],
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays[date.weekday % 7]})';
  }

  String _formatFullDate(DateTime date) {
    final weekdays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    return '${date.year}년 ${date.month}월 ${date.day}일 ${weekdays[date.weekday % 7]}';
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'very_happy': return '매우 좋았음';
      case 'happy': return '좋았음';
      case 'good': return '괜찮았음';
      case 'normal': return '보통';
      case 'tired': return '피곤했음';
      case 'stressed': return '스트레스';
      default: return '좋았음';
    }
  }

  void _editMeeting() {
    HapticFeedbackManager.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingEditScreen(meeting: widget.meeting),
      ),
    );
  }

  void _shareMeeting() {
    HapticFeedbackManager.lightImpact();
    
    final shareText = '''
${widget.meeting.meetingName}

📅 ${_formatDate(widget.meeting.date)}
📂 ${widget.meeting.category}
⭐ ${widget.meeting.satisfaction}/5.0
${widget.meeting.moodIcon} ${_getMoodLabel(widget.meeting.mood)}

${widget.meeting.note ?? ''}

#셰르파앱 #모임기록
''';

    Clipboard.setData(ClipboardData(text: shareText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '모임 기록이 클립보드에 복사되었습니다',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}