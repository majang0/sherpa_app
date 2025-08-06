// lib/features/daily_record/presentation/screens/enhanced_daily_record_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/record_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../widgets/simple_today_growth_widget.dart';
import '../../widgets/step_analysis_widget.dart';
import '../../widgets/focus_time_analysis_widget.dart';
import '../../widgets/enhanced_diary_calendar_widget.dart';

import '../../widgets/exercise_summary_widget.dart';
import '../../widgets/enhanced_reading_calendar_widget.dart';
import '../../widgets/movie_calendar_widget.dart';
import '../../widgets/enhanced_meeting_calendar_widget.dart';
import '../../widgets/daily_quest_widget.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class EnhancedDailyRecordScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<EnhancedDailyRecordScreen> createState() => _EnhancedDailyRecordScreenState();
}

class _EnhancedDailyRecordScreenState extends ConsumerState<EnhancedDailyRecordScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabRotation;
  late ScrollController _scrollController;
  
  bool _showQuestBottomSheet = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    ));
    
    _fabRotation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RecordColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(globalUserProvider.notifier).refresh();
          },
          color: RecordColors.primary,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 오늘의 성장 브리핑
                SimpleTodayGrowthWidget(),
                const SizedBox(height: 32),
                
                // 2. 걸음수 분석
                StepAnalysisWidget(),
                const SizedBox(height: 32),
                
                // 3. 몰입시간 분석
                FocusTimeAnalysisWidget(),
                const SizedBox(height: 32),
                
                // 4. 일기 캘린더
                EnhancedDiaryCalendarWidget(),
                const SizedBox(height: 32),
                
                // 5. 운동 기록 요약
                ExerciseSummaryWidget(),
                const SizedBox(height: 32),
                
                // 6. 독서 기록 (다중 등록 지원)
                EnhancedReadingCalendarWidget(),
                const SizedBox(height: 32),
                
                // 7. 영화 기록
                MovieCalendarWidget(),
                const SizedBox(height: 32),
                
                // 8. 모임 기록 (다중 등록 지원)
                EnhancedMeetingCalendarWidget(),
                const SizedBox(height: 100), // 하단 여백 (FAB 공간)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // 플로팅 액션 버튼 (오늘의 목표)
  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabRotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _fabRotation.value * 2 * 3.14159,
          child: Container(
            decoration: BoxDecoration(
              gradient: RecordColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: RecordColors.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: _showQuestBottomSheetModal,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '목표',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
    _fabController.forward();
    HapticFeedbackManager.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuestBottomSheet(),
    ).whenComplete(() {
      setState(() => _showQuestBottomSheet = false);
      _fabController.reverse();
    });
  }

  Widget _buildQuestBottomSheet() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: DailyQuestWidget(),
    );
  }
}