import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_colors.dart';
import '../../../core/ai/activity_analysis_service.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../core/constants/sherpi_emotions.dart';

/// 🌟 오늘의 분석 다이얼로그 - 감성적이고 모던한 디자인
/// 
/// 셰르피와 함께하는 따뜻한 하루 분석 경험을 제공합니다.
class TodayAnalysisDialog extends ConsumerStatefulWidget {
  const TodayAnalysisDialog({super.key});

  @override
  ConsumerState<TodayAnalysisDialog> createState() => _TodayAnalysisDialogState();
}

class _TodayAnalysisDialogState extends ConsumerState<TodayAnalysisDialog> 
    with TickerProviderStateMixin {
  final ActivityAnalysisService _analysisService = ActivityAnalysisService.instance;
  TodayAnalysisData? _analysisData;
  bool _isLoading = true;
  bool _hasAllActivities = false;
  String _missingActivities = '';
  
  // 애니메이션 컨트롤러
  late AnimationController _sherpiFloatController;
  late AnimationController _cardRevealController;
  late AnimationController _glowController;
  
  // 현재 감정 상태 (일기 기분 기반)
  String _currentMood = 'normal';
  
  @override
  void initState() {
    super.initState();
    
    // 애니메이션 초기화
    _sherpiFloatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _cardRevealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _loadAnalysisData();
  }
  
  @override
  void dispose() {
    _sherpiFloatController.dispose();
    _cardRevealController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// 분석 데이터 로드
  Future<void> _loadAnalysisData() async {
    setState(() => _isLoading = true);
    
    try {
      final globalUser = ref.read(globalUserProvider);
      final todayRecord = globalUser.todayRecord;
      
      // 캐시 클리어 제거 - 운동 완료 시 이미 생성된 캐시를 활용
      // await _analysisService.clearTodayCache();  // 주석 처리
      
      // 모든 활동이 완료되었는지 확인
      final hasExercise = todayRecord?.exerciseLog != null;
      final hasReading = todayRecord?.readingLog != null;
      final hasDiary = todayRecord?.diaryLog != null;
      
      if (hasExercise && hasReading && hasDiary) {
        _hasAllActivities = true;
        
        // 일기 기분 설정
        if (todayRecord!.diaryLog != null) {
          _currentMood = _translateMood(todayRecord.diaryLog!.mood);
        }
        
        // 캐시에서 분석 데이터 먼저 확인
        _analysisData = await _analysisService.getTodayAnalyses();
        
        // 캐시가 없거나 종합 분석이 비어있으면 새로 생성
        if (_analysisData == null || 
            _analysisData!.summaryAnalysis.isEmpty ||
            _analysisData!.summaryAnalysis.contains('종합 분석을 준비 중')) {
          await _generateAllAnalyses();
          _analysisData = await _analysisService.getTodayAnalyses();
        }
        
        // 카드 애니메이션 시작
        _cardRevealController.forward();
        _glowController.repeat(reverse: true);
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
      // 분석 데이터 로드 실패
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
        'intensity': _translateIntensity(todayRecord.exerciseLog!.intensity),
        'duration': todayRecord.exerciseLog!.durationMinutes,
        'calories': todayRecord.caloriesBurned,
        'steps': todayRecord.stepCount,
      };
      
      Map<String, dynamic>? previousExercise;
      if (previousExerciseLog != null) {
        previousExercise = {
          'type': previousExerciseLog.exerciseType,
          'intensity': _translateIntensity(previousExerciseLog.intensity),
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
      final translatedMood = _translateMood(todayRecord.diaryLog!.mood);
      final diaryData = {
        'mood': translatedMood,
        'moodEmoji': _getMoodEmoji(translatedMood),
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
        final previousTranslatedMood = _translateMood(previousDiaryLog.mood);
        previousDiary = {
          'mood': previousTranslatedMood,
          'moodEmoji': _getMoodEmoji(previousTranslatedMood),
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
      
      // UI 업데이트
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // 분석 생성 실패
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
    final koreanIntensity = _translateIntensity(intensity);
    final caloriesPerMinute = switch (koreanIntensity) {
      '낮음' => 3,
      '중간' => 5,
      '높음' => 8,
      '매우 높음' => 10,
      _ => 5,
    };
    return durationMinutes * caloriesPerMinute;
  }
  
  /// 운동 강도를 영어에서 한국어로 변환
  String _translateIntensity(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return '낮음';
      case 'medium':
      case 'moderate':
        return '중간';
      case 'high':
        return '높음';
      case 'very_high':
      case 'veryhigh':
        return '매우 높음';
      default:
        if (['낮음', '중간', '높음', '매우 높음'].contains(intensity)) {
          return intensity;
        }
        return '중간';
    }
  }
  
  /// 감정을 영어에서 한국어로 변환
  String _translateMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'excited':
        return '설레요';
      case 'happy':
        return '행복해요';
      case 'peaceful':
        return '평온해요';
      case 'normal':
        return '보통이에요';
      case 'tired':
        return '피곤해요';
      case 'sad':
        return '우울해요';
      case 'anxious':
        return '불안해요';
      case 'angry':
        return '화나요';
      case 'stressed':
        return '스트레스받아요';
      default:
        if (['설레요', '행복해요', '평온해요', '보통이에요', '피곤해요', 
             '우울해요', '불안해요', '화나요', '스트레스받아요'].contains(mood)) {
          return mood;
        }
        return '보통이에요';
    }
  }
  
  /// 감정에 따른 셰르피 이모션 반환
  SherpiEmotion _getSherpiEmotion() {
    switch (_currentMood) {
      case '설레요':
      case '행복해요':
        return SherpiEmotion.happy;
      case '평온해요':
        return SherpiEmotion.smile;
      case '피곤해요':
        return SherpiEmotion.sleeping;
      case '우울해요':
      case '불안해요':
        return SherpiEmotion.sad;
      case '화나요':
      case '스트레스받아요':
        return SherpiEmotion.warning;
      default:
        return SherpiEmotion.defaults;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          minHeight: size.height * 0.5,
          maxHeight: size.height * 0.95,
        ),
        child: _buildMainContent(context),
      ),
    );
  }
  
  /// 메인 컨텐츠 빌드
  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        // 헤더
        _buildSimpleHeader(context),
        
        // 구분선
        const Divider(height: 1, color: ModernColors.borderLight),
        
        // 컨텐츠
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _hasAllActivities
                  ? _buildAnalysisContent()
                  : _buildWarmRequirementsMessage(),
        ),
      ],
    );
  }
  
  /// 심플한 헤더
  Widget _buildSimpleHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 제목 섹션
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 분석',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.modernText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '셰르피가 분석한 오늘의 활동',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: ModernColors.modernTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // 닫기 버튼
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: ModernColors.modernTextSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 플로팅 셰르피
  Widget _buildFloatingSherpi() {
    return AnimatedBuilder(
      animation: _sherpiFloatController,
      builder: (context, child) {
        return Positioned(
          top: 100 + (math.sin(_sherpiFloatController.value * 2 * math.pi) * 10),
          right: 20,
          child: IgnorePointer(
            child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ModernColors.getMoodLightColor(_currentMood).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Image.asset(
                _getSherpiEmotion().imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 2.seconds,
            curve: Curves.easeInOut,
          ),
          ),
        );
      },
    );
  }
  
  /// 로딩 상태
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ModernColors.modernPrimary,
          ),
          SizedBox(height: 20),
          Text(
            '셰르피가 오늘의 활동을 분석하고 있어요! 🤔\n잠시만 기다려주세요~',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ModernColors.modernTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 따뜻한 요구사항 메시지
  Widget _buildWarmRequirementsMessage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 셰르피 일러스트
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ModernColors.warmGradient,
              boxShadow: ModernColors.softShadow(
                primaryColor: ModernColors.modernWarning,
              ),
            ),
            child: Center(
              child: Image.asset(
                SherpiEmotion.guiding.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ).animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
          
          const SizedBox(height: 32),
          
          // 메시지
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ModernColors.modernWarning.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '조금만 더 힘내세요! 💪',
                  style: GoogleFonts.notoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.modernText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '오늘의 분석을 보려면\n모든 활동을 완료해주세요',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.modernTextSecondary,
                    height: 1.6,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // 누락된 활동 표시
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ModernColors.modernWarning.withOpacity(0.1),
                        ModernColors.modernWarning.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.assignment_late_rounded,
                        color: ModernColors.modernWarning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '남은 활동: $_missingActivities',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.modernWarning,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate()
            .slideY(
              begin: 0.1,
              end: 0,
              duration: 400.ms,
              delay: 200.ms,
            )
            .fadeIn(
              duration: 400.ms,
              delay: 200.ms,
            ),
        ],
      ),
    );
  }
  
  /// 분석 컨텐츠
  Widget _buildAnalysisContent() {
    // 분석 데이터가 없거나 종합 분석이 없으면 로딩 상태 표시
    if (_analysisData == null || 
        _analysisData!.summaryAnalysis.isEmpty ||
        _analysisData!.summaryAnalysis == '종합 분석을 준비 중입니다...') {
      return _buildLoadingState();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 운동 카드
          _buildSimpleCard(
            title: '🏃 운동',
            content: _analysisData!.exerciseAnalysis,
            color: ModernColors.exercise,
          ),
          const SizedBox(height: 16),
          
          // 독서 카드
          _buildSimpleCard(
            title: '📚 독서',
            content: _analysisData!.readingAnalysis,
            color: ModernColors.reading,
          ),
          const SizedBox(height: 16),
          
          // 일기 카드
          _buildSimpleCard(
            title: '📝 일기',
            content: _analysisData!.diaryAnalysis,
            color: ModernColors.diary,
          ),
          const SizedBox(height: 20),
          
          // 셰르피의 종합 메시지
          _buildSimpleSummaryCard(),
        ],
      ),
    );
  }
  
  /// 시각적 활동 카드
  Widget _buildVisualActivityCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color lightColor,
    required String content,
    required int delay,
    bool isFullWidth = false,
  }) {
    return AnimatedBuilder(
      animation: _cardRevealController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            (1 - _cardRevealController.value) * 50,
          ),
          child: Opacity(
            opacity: _cardRevealController.value,
            child: Container(
              height: isFullWidth ? null : 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    lightColor.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: ModernColors.softShadow(
                  primaryColor: color,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.modernText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 컨텐츠
                  if (!isFullWidth)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.modernTextSecondary,
                            height: 1.6,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  if (isFullWidth)
                    Text(
                      content,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.modernTextSecondary,
                        height: 1.6,
                        letterSpacing: -0.2,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ).animate()
      .slideY(
        begin: 0.2,
        end: 0,
        duration: 600.ms,
        delay: delay.ms,
        curve: Curves.easeOutCubic,
      );
  }
  
  /// 심플한 카드
  Widget _buildSimpleCard({
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.modernText,
                  ),
                ),
              ],
            ),
          ),
          // 컨텐츠 - 패딩 증가 및 전체 내용 표시
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              content,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ModernColors.modernText,
                height: 1.7,
                letterSpacing: -0.2,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 심플한 종합 메시지 카드
  Widget _buildSimpleSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: ModernColors.modernPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.modernPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(
                SherpiEmotion.happy.imagePath,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              Text(
                '셰르피의 종합 분석',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.modernText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _analysisData?.summaryAnalysis ?? '종합 분석을 준비 중입니다...',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ModernColors.modernText,
              height: 1.6,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
  
  /// 셰르피의 종합 메시지 카드 (기존 - 사용하지 않음)
  Widget _buildSherpiSummaryCard() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ModernColors.modernPrimary.withOpacity(0.1),
                ModernColors.modernAccent.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: ModernColors.modernPrimary.withOpacity(
                0.2 + (_glowController.value * 0.1),
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: ModernColors.modernPrimary.withOpacity(
                  0.2 + (_glowController.value * 0.1),
                ),
                blurRadius: 20 + (_glowController.value * 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // 셰르피 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.modernPrimary,
                      ModernColors.modernAccent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.modernPrimary.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                '✨ 셰르피의 종합 분석',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ModernColors.modernText,
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                _analysisData!.summaryAnalysis,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.modernTextSecondary,
                  height: 1.7,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    ).animate()
      .slideY(
        begin: 0.2,
        end: 0,
        duration: 800.ms,
        delay: 400.ms,
        curve: Curves.easeOutBack,
      )
      .fadeIn(
        duration: 800.ms,
        delay: 400.ms,
      );
  }
}