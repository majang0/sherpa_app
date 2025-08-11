// lib/features/daily_record/widgets/enhanced_diary_calendar_widget_v2.dart
// 감성적이고 입체적인 일기 캘린더 위젯 - 개선된 버전

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  // 호버 효과를 위한 상태
  int? _hoveredDayIndex;
  bool _isMainCardHovered = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
    
    // 순차적 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 800), () {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final diaryLogs = user.dailyRecords.diaryLogs;
    
    // 날짜순으로 정렬 (최신순)
    final sortedDiaryLogs = List<DiaryLog>.from(diaryLogs)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isMainCardHovered = true),
            onExit: (_) => setState(() => _isMainCardHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..scale(_isMainCardHovered ? 1.01 : 1.0),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    // 메인 그림자 - 핑크 톤
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                    // 중간 그림자 - 부드러운 그림자
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                      spreadRadius: 5,
                    ),
                    // 세밀한 그림자 - 선명도
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더
                        _buildHeader(context),
                        
                        const SizedBox(height: 28),
                        
                        // 최근 7일 캘린더
                        _buildWeeklyCalendar(sortedDiaryLogs),
                        
                        const SizedBox(height: 20),
                        
                        // 전체보기 버튼
                        _buildFullViewButton().animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0, delay: 200.ms),
                        
                        const SizedBox(height: 24),
                        
                        // 최근 기록들
                        if (sortedDiaryLogs.isNotEmpty) ...[
                          _buildRecentHeader()
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 600.ms),
                          const SizedBox(height: 16),
                          ...sortedDiaryLogs.take(3).map((diary) => 
                            _buildDiaryItem(diary)
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 600.ms)
                              .slideX(begin: -0.1, end: 0, delay: 400.ms)
                          ),
                        ] else
                          _buildEmptyState()
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 800.ms)
                            .scale(begin: const Offset(0.9, 0.9), delay: 300.ms),
                        
                        const SizedBox(height: 28),
                        
                        // 일기 작성하기 버튼
                        _buildWriteButton()
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0, delay: 500.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // 아이콘 컨테이너 - 그라데이션 배경
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.edit_note,
            color: Colors.white,
            size: 26,
          ),
        ).animate()
          .scale(delay: 100.ms, duration: 600.ms, curve: Curves.elasticOut),
        
        const SizedBox(width: 16),
        
        // 텍스트 영역
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '일기 기록',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: RecordColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '오늘의 이야기를 남겨보세요',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: RecordColors.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        
        // 작성 버튼 - 플로팅 스타일
        GestureDetector(
          onTapDown: (_) => HapticFeedbackManager.lightImpact(),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Color(0xFFEC4899),
              size: 24,
            ),
          ).animate()
            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar(List<DiaryLog> diaryLogs) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
    
    return Container(
      padding: const EdgeInsets.all(16),  // 패딩 감소
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFDF2F8).withOpacity(0.5),
            Colors.white.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '이번 주 기록',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: RecordColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),  // 간격 감소
          // Center와 FittedBox로 오버플로우 방지
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: weekDays.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),  // 각 아이템 간격 축소
                    child: _buildCalendarDay(day, diaryLogs, index)
                      .animate()
                      .fadeIn(delay: (100 * index).ms, duration: 600.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        delay: (100 * index).ms,
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, List<DiaryLog> diaryLogs, int index) {
    final dayLogs = diaryLogs.where((log) => _isSameDay(log.date, day)).toList();
    final latestDiary = dayLogs.isNotEmpty ? dayLogs.first : null;
    final hasMultipleDiaries = dayLogs.length > 1;
    final isToday = _isSameDay(day, DateTime.now());
    final isHovered = _hoveredDayIndex == index;
    final weekdayName = ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];
    
    return GestureDetector(
      onTapDown: (_) => HapticFeedbackManager.lightImpact(),
      onTap: () {
        HapticFeedbackManager.mediumImpact();
        _showDateDiaryModal(day, dayLogs);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,  // 너비를 작게 조정
        height: 60,  // 높이를 작게 조정
        transform: Matrix4.identity()
          ..scale(isHovered ? 1.02 : 1.0),  // 호버 시 스케일 최소화
        decoration: BoxDecoration(
          gradient: isToday
              ? const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white,
                    latestDiary != null 
                        ? const Color(0xFFFDF2F8)
                        : Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          borderRadius: BorderRadius.circular(12),  // 둥글기 감소
          boxShadow: [
            if (isHovered || isToday) ...[
              BoxShadow(
                color: const Color(0xFFEC4899).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekdayName,
              style: GoogleFonts.notoSans(
                fontSize: 8,  // 폰트 크기 감소
                fontWeight: FontWeight.w600,
                color: isToday ? Colors.white.withOpacity(0.9) : RecordColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.day}',
              style: GoogleFonts.notoSans(
                fontSize: 12,  // 폰트 크기 감소
                fontWeight: FontWeight.w700,
                color: isToday ? Colors.white : RecordColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            if (latestDiary != null) ...[
              if (hasMultipleDiaries) ...[
                // 심플한 디자인으로 변경
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isToday 
                        ? Colors.white.withOpacity(0.3)
                        : const Color(0xFFEC4899).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_getMoodEmoji(latestDiary.mood)} ${dayLogs.length}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isToday ? Colors.white : const Color(0xFFEC4899),
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  _getMoodEmoji(latestDiary.mood),
                  style: TextStyle(
                    fontSize: 10,
                    color: isToday ? Colors.white : null,
                  ),
                ),
              ],
            ] else ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isToday 
                      ? Colors.white.withOpacity(0.5)
                      : RecordColors.textLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHeader() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFFF97316)],
            ),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '최근 기록',
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: RecordColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '최신순',
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEC4899),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiaryItem(DiaryLog diary) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedbackManager.lightImpact(),
      onTap: () {
        HapticFeedbackManager.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryDetailScreen(diary: diary),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // 기분 이모지 - 그라데이션 배경
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEC4899).withOpacity(0.1),
                    const Color(0xFFF97316).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getMoodEmoji(diary.mood),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            
            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getMoodLabel(diary.mood),
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${diary.date.month}/${diary.date.day}',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: RecordColors.textLight,
                        ),
                      ),
                      if (diary.hasAttachments) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.attachment_rounded,
                          size: 14,
                          color: RecordColors.textLight,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    diary.title.isNotEmpty ? diary.title : diary.content,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: RecordColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // 화살표 아이콘
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: const Color(0xFFEC4899),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFDF2F8).withOpacity(0.3),
            Colors.white.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899).withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '📝',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 작성된 일기가 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: RecordColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘의 소중한 순간을 기록해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: RecordColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullViewButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedbackManager.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryFullViewWidget(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_view_month_rounded,
                    color: const Color(0xFFEC4899),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '전체 일기 보기',
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEC4899),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWriteButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedbackManager.mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryWriteEditScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_rounded, size: 22, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  '일기 작성하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDateDiaryModal(DateTime date, List<DiaryLog> dayLogs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEnhancedModal(date, dayLogs),
    );
  }

  Widget _buildEnhancedModal(DateTime date, List<DiaryLog> dayLogs) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                width: 48,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                  ),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              
              // 모달 내용...
              _buildModalContent(date, dayLogs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalContent(DateTime date, List<DiaryLog> dayLogs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
      child: Column(
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.month}월 ${date.day}일',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: RecordColors.textPrimary,
                      ),
                    ),
                    if (dayLogs.length > 1)
                      Text(
                        '${dayLogs.length}개의 일기',
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
          
          const SizedBox(height: 28),
          
          // 일기 내용 표시
          if (dayLogs.isNotEmpty) ...[
            if (dayLogs.length == 1) 
              _buildSingleDiaryPreview(dayLogs.first)
            else 
              _buildMultipleDiariesList(dayLogs),
          ] else
            _buildEmptyDayContent(date),
          
          const SizedBox(height: 20),
          
          // 작성 버튼
          _buildModalWriteButton(date, dayLogs.isNotEmpty),
        ],
      ),
    );
  }

  Widget _buildModalWriteButton(DateTime date, bool hasExisting) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF97316)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
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
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  hasExisting ? '새 일기 추가하기' : '일기 작성하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
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

  // 기타 헬퍼 메서드들...
  
  Widget _buildSingleDiaryPreview(DiaryLog diary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEC4899).withOpacity(0.05),
            const Color(0xFFF97316).withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getMoodEmoji(diary.mood),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getMoodLabel(diary.mood),
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (diary.title.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        diary.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 17,
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
          const SizedBox(height: 16),
          Text(
            diary.content,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: RecordColors.textPrimary,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          
          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: _buildModalActionButton(
                  icon: Icons.visibility_rounded,
                  label: '자세히 보기',
                  isOutlined: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryDetailScreen(diary: diary),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModalActionButton(
                  icon: Icons.edit_rounded,
                  label: '수정하기',
                  isOutlined: false,
                  onTap: () {
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModalActionButton({
    required IconData icon,
    required String label,
    required bool isOutlined,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.white : null,
            gradient: isOutlined ? null : const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFFF97316)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: isOutlined ? Border.all(
              color: const Color(0xFFEC4899),
              width: 1.5,
            ) : null,
            boxShadow: [
              if (!isOutlined)
                BoxShadow(
                  color: const Color(0xFFEC4899).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isOutlined ? const Color(0xFFEC4899) : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? const Color(0xFFEC4899) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDayContent(DateTime date) {
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final isPast = date.isBefore(now.subtract(const Duration(days: 1)));
    
    String emoji;
    String title;
    String subtitle;
    
    if (isToday) {
      emoji = '✨';
      title = '오늘의 이야기를 시작해보세요';
      subtitle = '지금 이 순간의 소중한 감정과 경험을 기록해보세요';
    } else if (isPast) {
      emoji = '💭';
      title = '${date.month}월 ${date.day}일의 기억들';
      subtitle = '지나간 하루를 되돌아보며 소중한 순간들을 기록해보세요';
    } else {
      emoji = '🌱';
      title = '미래의 나에게 메시지를';
      subtitle = '앞으로의 계획이나 기대감을 미리 적어보세요';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFDF2F8).withOpacity(0.5),
            Colors.white.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 52),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: RecordColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
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
    );
  }

  Widget _buildMultipleDiariesList(List<DiaryLog> dayLogs) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: dayLogs.length,
        itemBuilder: (context, index) {
          final diary = dayLogs[index];
          final isLatest = index == 0;
          
          return Container(
            margin: EdgeInsets.only(bottom: index == dayLogs.length - 1 ? 0 : 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryDetailScreen(diary: diary),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLatest 
                          ? [
                              const Color(0xFFEC4899).withOpacity(0.08),
                              const Color(0xFFF97316).withOpacity(0.04),
                            ]
                          : [
                              Colors.white,
                              const Color(0xFFFDF2F8).withOpacity(0.3),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEC4899).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 순서 표시
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isLatest 
                                ? [const Color(0xFFEC4899), const Color(0xFFF97316)]
                                : [RecordColors.textLight, RecordColors.textLight.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isLatest 
                                  ? const Color(0xFFEC4899).withOpacity(0.2)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      
                      // 기분 이모지
                      Text(
                        _getMoodEmoji(diary.mood),
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 14),
                      
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
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                                      ),
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
                              const SizedBox(height: 4),
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
                            const SizedBox(height: 3),
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
                      
                      // 화살표 아이콘
                      Icon(
                        Icons.chevron_right_rounded,
                        color: const Color(0xFFEC4899).withOpacity(0.5),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}