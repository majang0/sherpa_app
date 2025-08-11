// lib/features/daily_record/presentation/screens/enhanced_daily_record_screen_v2.dart
// 감성적이고 일관된 디자인의 일일 기록 화면 - 개선된 버전

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/record_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../widgets/simple_today_growth_widget.dart';
import '../../widgets/step_analysis_widget.dart';
import '../../widgets/focus_time_analysis_widget.dart';
import '../../widgets/enhanced_diary_calendar_widget_v2.dart';
import '../../widgets/exercise_summary_widget.dart';
import '../../widgets/enhanced_reading_calendar_widget.dart';
import '../../widgets/movie_calendar_widget.dart';
import '../../widgets/enhanced_meeting_calendar_widget.dart';
import '../../widgets/daily_quest_widget.dart';

class EnhancedDailyRecordScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<EnhancedDailyRecordScreen> createState() => _EnhancedDailyRecordScreenState();
}

class _EnhancedDailyRecordScreenState extends ConsumerState<EnhancedDailyRecordScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _fabController;
  late AnimationController _scrollController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabRotation;
  late Animation<double> _fabScale;
  late ScrollController _scrollListener;
  
  bool _showQuestBottomSheet = false;
  bool _isFabExpanded = false;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollListener = ScrollController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _fabRotation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));
    
    _fabScale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));
    
    _fadeController.forward();
    
    // 스크롤 리스너
    _scrollListener.addListener(() {
      setState(() {
        _scrollOffset = _scrollListener.offset;
        // FAB 축소/확대 애니메이션
        if (_scrollOffset > 100 && _isFabExpanded) {
          setState(() => _isFabExpanded = false);
        } else if (_scrollOffset <= 100 && !_isFabExpanded) {
          setState(() => _isFabExpanded = true);
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
    _scrollListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecordColors.background,
      body: Stack(
        children: [
          // 배경 그라데이션
          _buildBackgroundGradient(),
          
          // 메인 콘텐츠
          FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                HapticFeedbackManager.lightImpact();
                await ref.read(globalUserProvider.notifier).refresh();
              },
              color: const Color(0xFFEC4899),
              backgroundColor: Colors.white,
              child: CustomScrollView(
                controller: _scrollListener,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // 커스텀 앱바
                  _buildSliverAppBar(),
                  
                  // 콘텐츠 영역
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. 오늘의 성장 브리핑
                        _buildSectionWrapper(
                          child: SimpleTodayGrowthWidget(),
                          delay: 100,
                        ),
                        const SizedBox(height: 24),
                        
                        // 2. 걸음수 분석
                        _buildSectionWrapper(
                          child: StepAnalysisWidget(),
                          delay: 200,
                        ),
                        const SizedBox(height: 24),
                        
                        // 3. 몰입시간 분석
                        _buildSectionWrapper(
                          child: FocusTimeAnalysisWidget(),
                          delay: 300,
                        ),
                        const SizedBox(height: 24),
                        
                        // 4. 일기 캘린더 - 이미 개선됨
                        EnhancedDiaryCalendarWidget()
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 800.ms)
                          .slideY(begin: 0.2, end: 0, delay: 400.ms),
                        const SizedBox(height: 24),
                        
                        // 5. 운동 기록 요약
                        _buildSectionWrapper(
                          child: ExerciseSummaryWidget(),
                          delay: 500,
                        ),
                        const SizedBox(height: 24),
                        
                        // 6. 독서 기록
                        _buildSectionWrapper(
                          child: EnhancedReadingCalendarWidget(),
                          delay: 600,
                        ),
                        const SizedBox(height: 24),
                        
                        // 7. 영화 기록
                        _buildSectionWrapper(
                          child: MovieCalendarWidget(),
                          delay: 700,
                        ),
                        const SizedBox(height: 24),
                        
                        // 8. 모임 기록
                        _buildSectionWrapper(
                          child: EnhancedMeetingCalendarWidget(),
                          delay: 800,
                        ),
                        const SizedBox(height: 120), // FAB 공간
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 플로팅 액션 버튼
          Positioned(
            right: 20,
            bottom: 24,
            child: _buildEnhancedFAB(),
          ),
        ],
      ),
    );
  }

  // 배경 그라데이션
  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RecordColors.background,
            const Color(0xFFFDF2F8).withOpacity(0.3),
            RecordColors.background,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // 커스텀 Sliver 앱바
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                const Color(0xFFFDF2F8).withOpacity(0.5),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_graph_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '일일 기록',
                                style: GoogleFonts.notoSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: RecordColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '오늘의 성장을 기록하고 분석해보세요',
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 섹션 래퍼 - 일관된 스타일 적용
  Widget _buildSectionWrapper({
    required Widget child,
    required int delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: child,
        ),
      ),
    ).animate()
      .fadeIn(delay: delay.ms, duration: 800.ms)
      .slideY(begin: 0.1, end: 0, delay: delay.ms);
  }

  // 향상된 FAB
  Widget _buildEnhancedFAB() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScale.value,
          child: Transform.rotate(
            angle: _fabRotation.value * 2 * 3.14159,
            child: GestureDetector(
              onTapDown: (_) {
                HapticFeedbackManager.lightImpact();
                _fabController.forward();
              },
              onTapUp: (_) {
                _fabController.reverse();
              },
              onTapCancel: () {
                _fabController.reverse();
              },
              onTap: _showQuestBottomSheetModal,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isFabExpanded ? 140 : 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFFF97316).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showQuestBottomSheetModal,
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isFabExpanded
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '오늘의 목표',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 목표 모달 시트 표시
  void _showQuestBottomSheetModal() {
    if (_showQuestBottomSheet) return;

    setState(() => _showQuestBottomSheet = true);
    HapticFeedbackManager.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                
                // 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFFF97316)],
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
                          Icons.flag_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '오늘의 목표',
                              style: GoogleFonts.notoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: RecordColors.textPrimary,
                              ),
                            ),
                            Text(
                              '목표를 설정하고 달성해보세요',
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: RecordColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: RecordColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: DailyQuestWidget(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() => _showQuestBottomSheet = false);
    });
  }
}