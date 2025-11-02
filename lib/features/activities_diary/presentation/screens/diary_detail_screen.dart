// lib/features/activities_diary/presentation/screens/diary_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/constants/mood_constants.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/utils/haptic_feedback_manager.dart';
import 'diary_write_edit_screen.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  final DiaryLog diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // 감정 데이터는 MoodConstants에서 중앙 관리

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
    final moodInfo = MoodConstants.getMoodInfo(widget.diary.mood) ??
        MoodConstants.getMoodInfo('normal')!;

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
            child: IconButton(
              onPressed: _editDiary,
              icon: const Icon(
                Icons.edit_outlined,
                color: ModernColors.diary,
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
            // 배경 그라데이션 (diary_write_edit_screen.dart와 동일)
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ModernColors.diary,
                    ModernColors.diary.withValues(alpha: 0.7),
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

                  // 헤더 섹션 (날짜, 기분)
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeader(moodInfo),
                  ),

                  const SizedBox(height: 24),

                  // 콘텐츠 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildContent(),
                  ),

                  const SizedBox(height: 32),

                  // 액션 버튼들
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildActionButtons(moodInfo),
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

  Widget _buildHeader(Map<String, dynamic> moodInfo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ModernColors.diary.withValues(alpha: 0.2),
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
          // 기분 아이콘과 라벨
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: moodInfo['selectedColor'],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: moodInfo['selectedColor'].withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: moodInfo['selectedColor'].withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  moodInfo['emoji'],
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moodInfo['label'],
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: moodInfo['selectedColor'],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '오늘의 기분',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
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
                  ModernColors.diary.withValues(alpha: 0.06),
                  ModernColors.diary.withValues(alpha: 0.10),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.diary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ModernColors.diary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.diary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: ModernColors.diary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getFormattedDate(widget.diary.date),
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

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 제목 (있는 경우)
          if (widget.diary.title.isNotEmpty) ...[
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ModernColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.title,
                          color: ModernColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '제목',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.diary.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 내용
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ModernColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.article,
                        color: ModernColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '일기 내용',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SelectableText(
                  widget.diary.content,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textPrimary,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),

          // 첨부 파일 (있는 경우)
          if (widget.diary.hasAttachments) ...[
            const SizedBox(height: 16),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ModernColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.attach_file,
                          color: ModernColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '첨부 파일',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 첨부 파일 목록
                  if (widget.diary.imageUrl != null)
                    _buildAttachmentItem(
                      icon: Icons.photo_camera,
                      label: '사진',
                      color: const Color(0xFF10B981),
                    ),
                  if (widget.diary.musicUrl != null)
                    _buildAttachmentItem(
                      icon: Icons.music_note,
                      label: '음악',
                      color: const Color(0xFF8B5CF6),
                    ),
                  if (widget.diary.videoUrl != null)
                    _buildAttachmentItem(
                      icon: Icons.videocam,
                      label: '영상',
                      color: const Color(0xFFF59E0B),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> moodInfo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 수정 버튼
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.diary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _editDiary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.diary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit, size: 20),
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

          const SizedBox(width: 12),

          // 공유 버튼
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _shareDiary,
              icon: const Icon(
                Icons.share,
                color: ModernColors.diary,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 복사 버튼
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _copyDiary,
              icon: const Icon(
                Icons.copy,
                color: ModernColors.diary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.04),
            color.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: ModernColors.surface.withValues(alpha: 0.9),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}년 ${date.month}월 ${date.day}일 $weekday';
  }

  void _editDiary() {
    HapticFeedbackManager.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryWriteEditScreen(
          existingDiary: widget.diary,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // 수정이 완료되면 화면을 새로고침하거나 뒤로 가기
        Navigator.pop(context, true);
      }
    });
  }

  void _shareDiary() {
    HapticFeedbackManager.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '공유 기능은 곧 추가될 예정입니다',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: ModernColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _copyDiary() {
    HapticFeedbackManager.lightImpact();
    final content = '${widget.diary.title}\n\n${widget.diary.content}';
    Clipboard.setData(ClipboardData(text: content));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '일기 내용이 복사되었습니다',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: ModernColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
