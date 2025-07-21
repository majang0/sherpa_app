// lib/features/daily_record/widgets/enhanced_diary_calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/record_colors.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import '../presentation/screens/diary_write_edit_screen.dart';
import '../presentation/screens/diary_detail_screen.dart';
import 'diary_full_view_widget.dart';

class EnhancedDiaryCalendarWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<EnhancedDiaryCalendarWidget> createState() => _EnhancedDiaryCalendarWidgetState();
}

class _EnhancedDiaryCalendarWidgetState extends ConsumerState<EnhancedDiaryCalendarWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    Future.delayed(const Duration(milliseconds: 1200), () {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final diaryLogs = user.dailyRecords.diaryLogs;
    
    // 날짜순으로 정렬 (최신순 - 현재 날짜와 가장 가까운 순서)
    final sortedDiaryLogs = List<DiaryLog>.from(diaryLogs)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: RecordColors.textLight.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_note,
                      color: const Color(0xFFEC4899),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '일기 기록',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: RecordColors.textPrimary,
                          ),
                        ),
                        Text(
                          '하루의 소중한 순간들을 기록해보세요',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: RecordColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 작성 버튼
                  GestureDetector(
                    onTap: () {
                      HapticFeedbackManager.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryWriteEditScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFFEC4899), const Color(0xFFF97316)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEC4899).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 최근 7일 캘린더
              _buildWeeklyCalendar(sortedDiaryLogs),
              
              const SizedBox(height: 16),
              
              // 전체보기 버튼
              _buildFullViewButton(),
              
              const SizedBox(height: 20),
              
              // 최근 기록들
              if (sortedDiaryLogs.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      '최근 기록',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: RecordColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(최신순)',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: RecordColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...sortedDiaryLogs.take(3).map((diary) => _buildDiaryItem(diary)),
              ] else
                _buildEmptyState(),
              
              const SizedBox(height: 24),
              
              // 일기 작성하기 버튼
              _buildWriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar(List<DiaryLog> diaryLogs) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecordColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RecordColors.textLight.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 기록',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: RecordColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) => _buildCalendarDay(day, diaryLogs)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, List<DiaryLog> diaryLogs) {
    final dayLogs = diaryLogs.where((log) => _isSameDay(log.date, day)).toList();
    final latestDiary = dayLogs.isNotEmpty ? dayLogs.first : null; // 이미 정렬된 상태에서 최신 일기
    final hasMultipleDiaries = dayLogs.length > 1;
    final isToday = _isSameDay(day, DateTime.now());
    final weekdayName = ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];
    
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        _showDateDiaryModal(day, dayLogs); // 모든 일기 전달
      },
      child: Container(
        width: 36,
        height: 55, // 높이를 5px 증가
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFFEC4899).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday ? const Color(0xFFEC4899) : RecordColors.textLight.withOpacity(0.2),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4), // 상하 패딩 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 공간을 균등하게 배분
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekdayName,
                style: GoogleFonts.notoSans(
                  fontSize: 8, // 폰트 크기를 9에서 8로 줄임
                  fontWeight: FontWeight.w500,
                  color: RecordColors.textSecondary,
                ),
              ),
              Text(
                '${day.day}',
                style: GoogleFonts.notoSans(
                  fontSize: 11, // 폰트 크기를 12에서 11로 줄임
                  fontWeight: FontWeight.w600,
                  color: isToday ? const Color(0xFFEC4899) : RecordColors.textPrimary,
                ),
              ),
              if (latestDiary != null) ...[
                // 여러 일기가 있는 경우 카운터와 함께 표시
                if (hasMultipleDiaries) ...[
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        _getMoodEmoji(latestDiary.mood),
                        style: const TextStyle(fontSize: 10),
                      ),
                      Positioned(
                        right: -6,
                        top: -3,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${dayLogs.length}',
                            style: GoogleFonts.notoSans(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // 단일 일기인 경우 기존 방식
                  Text(
                    _getMoodEmoji(latestDiary.mood),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ] else ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: RecordColors.textLight.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryItem(DiaryLog diary) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryDetailScreen(diary: diary),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RecordColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: RecordColors.textLight.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 기분 이모지
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: RecordColors.textLight.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _getMoodEmoji(diary.mood),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getMoodLabel(diary.mood),
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEC4899),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${diary.date.month}/${diary.date.day}',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: RecordColors.textLight,
                        ),
                      ),
                      if (diary.hasAttachments) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.attachment,
                          size: 12,
                          color: RecordColors.textLight,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    diary.title.isNotEmpty ? diary.title : diary.content,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: RecordColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // 공유 아이콘
            if (diary.isShared)
              Icon(
                Icons.share,
                size: 14,
                color: RecordColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RecordColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RecordColors.textLight.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '📝',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            '아직 작성된 일기가 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: RecordColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '오늘의 소중한 순간을 기록해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: RecordColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showDateDiaryModal(DateTime date, List<DiaryLog> dayLogs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: RecordColors.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFFEC4899), const Color(0xFFF97316)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.month}월 ${date.day}일',
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: RecordColors.textPrimary,
                            ),
                          ),
                          if (dayLogs.length > 1)
                            Text(
                              '${dayLogs.length}개의 일기',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: RecordColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 일기가 있는 경우 - 여러 개 지원
              if (dayLogs.length == 1) ...[
                // 단일 일기인 경우 기존 로직 유지
                _buildSingleDiaryPreview(dayLogs.first),
              ] else if (dayLogs.length > 1) ...[
                // 여러 일기인 경우 목록으로 표시
                _buildMultipleDiariesList(dayLogs),
              ] else ...[
                // 일기가 없는 경우 - 친근한 안내
                _buildEmptyDayContent(date),
              ],
              
              // 새 일기 작성 버튼
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryWriteEditScreen(
                          selectedDate: date,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
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
                      Icon(Icons.add, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        dayLogs.isNotEmpty ? '새 일기 추가하기' : '일기 작성하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'very_happy': return '😄';
      case 'happy': return '😊';
      case 'good': return '🙂';
      case 'normal': return '😐';
      case 'thoughtful': return '🤔';
      case 'tired': return '😴';
      case 'sad': return '😢';
      case 'excited': return '🤗';
      default: return '😊';
    }
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'very_happy': return '매우 기뻐요';
      case 'happy': return '기뻐요';
      case 'good': return '좋아요';
      case 'normal': return '보통이에요';
      case 'thoughtful': return '생각이 많아요';
      case 'tired': return '피곤해요';
      case 'sad': return '슬퍼요';
      case 'excited': return '설레요';
      default: return '기뻐요';
    }
  }

  Widget _buildFullViewButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        onPressed: () {
          HapticFeedbackManager.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryFullViewWidget(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEC4899),
          side: BorderSide(
            color: const Color(0xFFEC4899).withOpacity(0.3),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_view_month,
              color: const Color(0xFFEC4899),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '전체 일기 보기',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEC4899),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedbackManager.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryWriteEditScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEC4899),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: const Color(0xFFEC4899).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 20),
            const SizedBox(width: 8),
            Text(
              '일기 작성하기',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleDiaryPreview(DiaryLog diary) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEC4899).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getMoodEmoji(diary.mood),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMoodLabel(diary.mood),
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEC4899),
                          ),
                        ),
                        if (diary.title.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            diary.title,
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: RecordColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                diary.content,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: RecordColors.textPrimary,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // 액션 버튼들
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // 자세히 보기 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryDetailScreen(diary: diary),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEC4899),
                    side: BorderSide(color: const Color(0xFFEC4899), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '자세히 보기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 수정하기 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryWriteEditScreen(
                          existingDiary: diary,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '수정하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyDayContent(DateTime date) {
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final isPast = date.isBefore(now.subtract(const Duration(days: 1)));
    final isFuture = date.isAfter(now);
    
    // 날짜별 맞춤 메시지 생성
    String emoji;
    String title;
    String subtitle;
    List<String> suggestions;
    
    if (isToday) {
      emoji = '✨';
      title = '오늘의 이야기를 시작해보세요';
      subtitle = '지금 이 순간의 소중한 감정과 경험을 기록해보세요';
      suggestions = [
        '오늘 기분이 어떠신가요?',
        '특별했던 순간이 있나요?',
        '감사했던 일들을 적어보세요',
        '내일의 계획을 세워보세요'
      ];
    } else if (isPast) {
      emoji = '💭';
      title = '${date.month}월 ${date.day}일의 기억들';
      subtitle = '지나간 하루를 되돌아보며 소중한 순간들을 기록해보세요';
      suggestions = [
        '그날의 기분은 어땠나요?',
        '기억에 남는 순간이 있나요?',
        '배운 것이나 느낀 점은?',
        '소중했던 만남이나 경험은?'
      ];
    } else {
      emoji = '🌱';
      title = '미래의 나에게 메시지를';
      subtitle = '앞으로의 계획이나 기대감을 미리 적어보세요';
      suggestions = [
        '어떤 하루가 되길 바라나요?',
        '이루고 싶은 목표가 있나요?',
        '기대되는 일들은 무엇인가요?',
        '미래의 나에게 응원 메시지를'
      ];
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 메인 콘텐츠 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEC4899).withOpacity(0.05),
                  const Color(0xFFF97316).withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFEC4899).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 이모지와 제목
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: RecordColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 작성 아이디어 제안
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: RecordColors.textLight.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: const Color(0xFFEC4899),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '이런 걸 써보는 건 어떨까요?',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: RecordColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: RecordColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMultipleDiariesList(List<DiaryLog> dayLogs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: dayLogs.length,
        itemBuilder: (context, index) {
          final diary = dayLogs[index];
          final isLatest = index == 0;
          
          return Container(
            margin: EdgeInsets.only(bottom: index == dayLogs.length - 1 ? 0 : 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryDetailScreen(diary: diary),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLatest 
                      ? const Color(0xFFEC4899).withOpacity(0.08)
                      : const Color(0xFFEC4899).withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLatest 
                        ? const Color(0xFFEC4899).withOpacity(0.2)
                        : const Color(0xFFEC4899).withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // 순서 표시
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isLatest ? const Color(0xFFEC4899) : RecordColors.textLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // 기분 이모지
                    Text(
                      _getMoodEmoji(diary.mood),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    
                    // 내용
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getMoodLabel(diary.mood),
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEC4899),
                                ),
                              ),
                              if (isLatest) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEC4899),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '최신',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (diary.title.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              diary.title,
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: RecordColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 2),
                          Text(
                            diary.content,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: RecordColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // 액션 버튼
                    Icon(
                      Icons.chevron_right,
                      color: RecordColors.textLight,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}