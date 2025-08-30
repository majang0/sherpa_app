import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/ai/activity_analysis_service.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';

/// 오늘의 분석 다이얼로그
/// 
/// ChatGPT API를 통해 하루 동안의 활동을 분석하고 개인화된 피드백을 제공합니다.
class TodayAnalysisDialog extends ConsumerStatefulWidget {
  const TodayAnalysisDialog({super.key});

  @override
  ConsumerState<TodayAnalysisDialog> createState() => _TodayAnalysisDialogState();
}

class _TodayAnalysisDialogState extends ConsumerState<TodayAnalysisDialog> {
  final ActivityAnalysisService _analysisService = ActivityAnalysisService.instance;
  TodayAnalysisData? _analysisData;
  bool _isLoading = true;
  bool _hasAllActivities = false;
  String _missingActivities = '';

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  /// 분석 데이터 로드
  Future<void> _loadAnalysisData() async {
    setState(() => _isLoading = true);
    
    try {
      // 오늘의 활동 데이터 확인
      final globalUser = ref.read(globalUserProvider);
      final todayRecord = globalUser.todayRecord;
      
      // 모든 활동이 완료되었는지 확인
      final hasExercise = todayRecord?.exerciseLog != null;
      final hasReading = todayRecord?.readingLog != null;
      final hasDiary = todayRecord?.diaryLog != null;
      
      if (hasExercise && hasReading && hasDiary) {
        _hasAllActivities = true;
        
        // 캐시에서 분석 데이터 로드
        _analysisData = await _analysisService.getTodayAnalyses();
        
        // 캐시에 데이터가 없으면 새로 생성
        if (_analysisData == null) {
          await _generateAllAnalyses();
        }
      } else {
        _hasAllActivities = false;
        
        // 누락된 활동 목록 생성
        List<String> missing = [];
        if (!hasExercise) missing.add('운동');
        if (!hasReading) missing.add('독서');
        if (!hasDiary) missing.add('일기');
        _missingActivities = missing.join(', ');
      }
    } catch (e) {
      print('❌ 분석 데이터 로드 실패: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  /// 모든 분석 생성
  Future<void> _generateAllAnalyses() async {
    try {
      final globalUser = ref.read(globalUserProvider);
      final userName = globalUser.name;
      final todayRecord = globalUser.todayRecord!;
      
      // 이전 기록 가져오기 (최근 7일)
      final today = DateTime.now();
      final sevenDaysAgo = today.subtract(const Duration(days: 7));
      
      // 최근 7일 내의 이전 운동 기록 찾기
      ExerciseLog? previousExerciseLog;
      for (final log in globalUser.dailyRecords.exerciseLogs) {
        if (log.date.isAfter(sevenDaysAgo) && 
            !_isSameDay(log.date, today)) {
          previousExerciseLog = log;
          break;
        }
      }
      
      // 운동 분석
      final exerciseData = {
        'type': todayRecord.exerciseLog!.exerciseType,
        'intensity': todayRecord.exerciseLog!.intensity,
        'duration': todayRecord.exerciseLog!.durationMinutes,
        'calories': todayRecord.caloriesBurned,
        'steps': todayRecord.stepCount,
      };
      
      Map<String, dynamic>? previousExercise;
      if (previousExerciseLog != null) {
        previousExercise = {
          'type': previousExerciseLog.exerciseType,
          'intensity': previousExerciseLog.intensity,
          'duration': previousExerciseLog.durationMinutes,
          'calories': _calculateCalories(previousExerciseLog.durationMinutes, previousExerciseLog.intensity),
        };
      }
      
      // 독서 분석
      final readingData = {
        'title': todayRecord.readingLog!.bookTitle,
        'category': todayRecord.readingLog!.category,
        'pages': todayRecord.pagesRead,
        'totalPages': todayRecord.totalPages,
        'rating': todayRecord.readingLog!.rating?.round() ?? 0,
      };
      
      // 최근 7일 내의 이전 독서 기록 찾기
      ReadingLog? previousReadingLog;
      for (final log in globalUser.dailyRecords.readingLogs) {
        if (log.date.isAfter(sevenDaysAgo) && 
            !_isSameDay(log.date, today)) {
          previousReadingLog = log;
          break;
        }
      }
      
      Map<String, dynamic>? previousReading;
      if (previousReadingLog != null) {
        previousReading = {
          'title': previousReadingLog.bookTitle,
          'category': previousReadingLog.category,
          'pages': previousReadingLog.pages,
          'rating': previousReadingLog.rating,
        };
      }
      
      // 일기 분석
      final diaryData = {
        'mood': todayRecord.diaryLog!.mood,
        'moodEmoji': _getMoodEmoji(todayRecord.diaryLog!.mood),
        'content': todayRecord.diaryLog!.content,
        'keywords': _extractKeywords(todayRecord.diaryLog!.content),
      };
      
      // 최근 7일 내의 이전 일기 기록 찾기
      DiaryLog? previousDiaryLog;
      for (final log in globalUser.dailyRecords.diaryLogs) {
        if (log.date.isAfter(sevenDaysAgo) && 
            !_isSameDay(log.date, today)) {
          previousDiaryLog = log;
          break;
        }
      }
      
      Map<String, dynamic>? previousDiary;
      if (previousDiaryLog != null) {
        previousDiary = {
          'mood': previousDiaryLog.mood,
          'moodEmoji': _getMoodEmoji(previousDiaryLog.mood),
          'content': previousDiaryLog.content,
        };
      }
      
      // 분석 생성 (백그라운드)
      await Future.wait([
        _analysisService.analyzeExercise(
          todayExercise: exerciseData,
          previousExercise: previousExercise,
          userName: userName,
        ),
        _analysisService.analyzeReading(
          todayReading: readingData,
          previousReading: previousReading,
          userName: userName,
        ),
        _analysisService.analyzeDiary(
          todayDiary: diaryData,
          previousDiary: previousDiary,
          userName: userName,
        ),
      ]);
      
      // 종합 분석 생성
      await _analysisService.generateSummaryAnalysis(
        todayExercise: exerciseData,
        todayReading: readingData,
        todayDiary: diaryData,
        userName: userName,
      );
      
      // 캐시에서 다시 로드
      _analysisData = await _analysisService.getTodayAnalyses();
    } catch (e) {
      print('❌ 분석 생성 실패: $e');
    }
  }
  
  /// 감정에 따른 이모지 반환
  String _getMoodEmoji(String mood) {
    final moodEmojis = {
      '행복해요': '😊',
      '기뻐요': '😄',
      '설레요': '🥰',
      '평온해요': '😌',
      '보통이에요': '😐',
      '피곤해요': '😴',
      '우울해요': '😔',
      '불안해요': '😟',
      '화나요': '😠',
      '스트레스받아요': '😣',
    };
    return moodEmojis[mood] ?? '😊';
  }
  
  /// 일기 내용에서 키워드 추출
  List<String> _extractKeywords(String content) {
    if (content.isEmpty) return [];
    
    // 간단한 키워드 추출 (실제로는 더 정교한 알고리즘 필요)
    final words = content.split(' ');
    final keywords = <String>[];
    
    for (final word in words) {
      if (word.length > 2 && !keywords.contains(word)) {
        keywords.add(word);
        if (keywords.length >= 3) break;
      }
    }
    
    return keywords;
  }
  
  /// 날짜 비교 헬퍼 메서드
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// 칼로리 계산 헬퍼 메서드
  int _calculateCalories(int durationMinutes, String intensity) {
    final caloriesPerMinute = switch (intensity) {
      '낮음' => 3,
      '중간' => 5,
      '높음' => 8,
      _ => 5,
    };
    return durationMinutes * caloriesPerMinute;
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
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.indigo.shade400.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // 헤더
                _buildHeader(context),
                
                // 컨텐츠 영역
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _hasAllActivities
                          ? _buildAnalysisContent()
                          : _buildRequirementsMessage(),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
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

  /// 헤더 빌드
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade400.withOpacity(0.08),
            Colors.indigo.shade400.withOpacity(0.04),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.analytics,
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
                  '오늘의 분석',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'ChatGPT가 분석한 오늘의 활동',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 로딩 상태
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            '분석 데이터를 불러오는 중...',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 요구사항 메시지
  Widget _buildRequirementsMessage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade50.withOpacity(0.9),
                  Colors.orange.shade50.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.orange.shade200.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 64,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  '📝 모든 활동을 완료해주세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '오늘의 분석을 보려면\n운동, 독서, 일기를 모두 기록해야 해요.',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.6,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '아직 기록하지 않은 활동: $_missingActivities',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 분석 컨텐츠
  Widget _buildAnalysisContent() {
    if (_analysisData == null) {
      return _buildLoadingState();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 운동 분석
          _buildAnalysisCard(
            title: '🏃 운동 분석',
            content: _analysisData!.exerciseAnalysis,
            gradient: [Colors.blue.shade50, Colors.blue.shade100],
            borderColor: Colors.blue.shade200,
            icon: Icons.fitness_center,
            iconColor: Colors.blue.shade600,
          ),
          const SizedBox(height: 16),
          
          // 독서 분석
          _buildAnalysisCard(
            title: '📚 독서 분석',
            content: _analysisData!.readingAnalysis,
            gradient: [Colors.green.shade50, Colors.green.shade100],
            borderColor: Colors.green.shade200,
            icon: Icons.menu_book,
            iconColor: Colors.green.shade600,
          ),
          const SizedBox(height: 16),
          
          // 일기 분석
          _buildAnalysisCard(
            title: '📝 일기 분석',
            content: _analysisData!.diaryAnalysis,
            gradient: [Colors.purple.shade50, Colors.purple.shade100],
            borderColor: Colors.purple.shade200,
            icon: Icons.edit_note,
            iconColor: Colors.purple.shade600,
          ),
          const SizedBox(height: 24),
          
          // 종합 요약
          _buildSummaryCard(),
        ],
      ),
    );
  }
  
  /// 분석 카드
  Widget _buildAnalysisCard({
    required String title,
    required String content,
    required List<Color> gradient,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withOpacity(0.9)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.notoSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.6,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
  
  /// 종합 요약 카드
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade100.withOpacity(0.9),
            Colors.indigo.shade200.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.indigo.shade300.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade400.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '🌟 셰르피의 종합 분석',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _analysisData!.summaryAnalysis,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.7,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: 200.ms)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms);
  }
}