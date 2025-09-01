import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_colors.dart';
import '../../../core/ai/activity_analysis_service.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../core/constants/sherpi_emotions.dart';
import 'analysis_pages/exercise_analysis_page.dart';
import 'analysis_pages/reading_analysis_page.dart';
import 'analysis_pages/diary_analysis_page.dart';
import 'analysis_pages/comprehensive_analysis_page.dart';

/// 🌟 향상된 오늘의 분석 다이얼로그 - 페이지 네비게이션과 시각적 데이터
/// 
/// 운동, 독서, 일기, 종합 분석을 별도 페이지로 제공하며
/// 시각적 배지와 AI 기반 인사이트를 제공합니다.
class EnhancedTodayAnalysisDialog extends ConsumerStatefulWidget {
  const EnhancedTodayAnalysisDialog({super.key});

  @override
  ConsumerState<EnhancedTodayAnalysisDialog> createState() => 
      _EnhancedTodayAnalysisDialogState();
}

class _EnhancedTodayAnalysisDialogState 
    extends ConsumerState<EnhancedTodayAnalysisDialog> 
    with TickerProviderStateMixin {
  final ActivityAnalysisService _analysisService = ActivityAnalysisService.instance;
  bool _isLoading = false;  // 종합 분석 대기 없이 바로 열림
  bool _hasAllActivities = false;
  String _missingActivities = '';
  
  // 페이지 컨트롤러
  late PageController _pageController;
  int _currentPage = 0;
  
  // 애니메이션 컨트롤러
  late AnimationController _pageIndicatorController;
  late AnimationController _backgroundAnimationController;
  
  // 활동 데이터
  Map<String, dynamic>? _todayExerciseData;
  Map<String, dynamic>? _previousExerciseData;
  Map<String, dynamic>? _todayReadingData;
  Map<String, dynamic>? _previousReadingData;
  Map<String, dynamic>? _todayDiaryData;
  Map<String, dynamic>? _previousDiaryData;
  
  // 사용자 이름
  String _userName = '';
  
  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    // 애니메이션 초기화
    _pageIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadAnalysisData();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _pageIndicatorController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  /// 분석 데이터 로드 및 준비
  Future<void> _loadAnalysisData() async {
    try {
      final globalUser = ref.read(globalUserProvider);
      final todayRecord = globalUser.todayRecord;
      
      // 모든 활동이 완료되었는지 확인
      final hasExercise = todayRecord?.exerciseLog != null;
      final hasReading = todayRecord?.readingLog != null;
      final hasDiary = todayRecord?.diaryLog != null;
      
      if (hasExercise && hasReading && hasDiary) {
        _hasAllActivities = true;
        
        // 오늘의 데이터 준비
        _prepareActivityData(globalUser, todayRecord!);
        
        // 애니메이션 시작
        _pageIndicatorController.forward();
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
      // 에러 처리
    }
  }
  
  /// 활동 데이터 준비
  void _prepareActivityData(GlobalUser globalUser, TodayActivityRecord todayRecord) {
    _userName = globalUser.name;  // 사용자 이름 저장
    final today = DateTime.now();
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    
    // 운동 데이터
    if (todayRecord.exerciseLog != null) {
      _todayExerciseData = {
        'type': todayRecord.exerciseLog!.exerciseType,
        'intensity': _translateIntensity(todayRecord.exerciseLog!.intensity),
        'duration': todayRecord.exerciseLog!.durationMinutes,
        'calories': todayRecord.caloriesBurned,
        'steps': todayRecord.stepCount,
        'date': today,
      };
      
      // 이전 운동 기록 찾기
      for (final log in globalUser.dailyRecords.exerciseLogs) {
        if (log.date.isAfter(sevenDaysAgo) && 
            !_isSameDay(log.date, today)) {
          _previousExerciseData = {
            'type': log.exerciseType,
            'intensity': _translateIntensity(log.intensity),
            'duration': log.durationMinutes,
            'calories': _calculateCalories(log.durationMinutes, log.intensity),
            'date': log.date,
          };
          break;
        }
      }
    }
    
    // 독서 데이터
    if (todayRecord.readingLog != null) {
      _todayReadingData = {
        'title': todayRecord.readingLog!.bookTitle,
        'category': todayRecord.readingLog!.category,
        'pages': todayRecord.pagesRead,
        'totalPages': todayRecord.totalPages,
        'rating': todayRecord.readingLog!.rating?.round() ?? 0,
        'date': today,
      };
      
      // 이전 독서 기록 찾기
      for (final log in globalUser.dailyRecords.readingLogs) {
        if (log.date.isAfter(sevenDaysAgo) && 
            !_isSameDay(log.date, today)) {
          _previousReadingData = {
            'title': log.bookTitle,
            'category': log.category,
            'pages': log.pages,
            'rating': log.rating,
            'date': log.date,
          };
          break;
        }
      }
    }
    
    // 일기 데이터
    if (todayRecord.diaryLog != null) {
      final translatedMood = _translateMood(todayRecord.diaryLog!.mood);
      _todayDiaryData = {
        'mood': translatedMood,
        'moodEmoji': _getMoodEmoji(translatedMood),
        'content': todayRecord.diaryLog!.content,
        'keywords': _extractKeywords(todayRecord.diaryLog!.content),
        'date': today,
      };
      
      // 이전 일기 기록 찾기
      for (final log in globalUser.dailyRecords.diaryLogs) {
        if (log.date.isAfter(sevenDaysAgo) && 
            !_isSameDay(log.date, today)) {
          final previousTranslatedMood = _translateMood(log.mood);
          _previousDiaryData = {
            'mood': previousTranslatedMood,
            'moodEmoji': _getMoodEmoji(previousTranslatedMood),
            'content': log.content,
            'date': log.date,
          };
          break;
        }
      }
    }
  }
  
  // 개별 활동 분석 생성 메서드 제거됨
  // 종합 운동 분석만 ExerciseAnalysisPage에서 직접 호출
  
  // 헬퍼 메서드들
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          minHeight: size.height * 0.6,
          maxHeight: size.height * 0.95,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // 헤더
            _buildEnhancedHeader(context),
            
            // 컨텐츠
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _hasAllActivities
                      ? _buildPageViewContent()
                      : _buildRequirementsMessage(),
            ),
            
            // 페이지 인디케이터 (활동이 모두 완료된 경우에만)
            if (!_isLoading && _hasAllActivities)
              _buildPageIndicator(),
          ],
        ),
      ),
    );
  }
  
  /// 향상된 헤더
  Widget _buildEnhancedHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.primary.withOpacity(0.05),
            ModernColors.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: ModernColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          
          // 제목
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 분석',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                if (!_isLoading && _hasAllActivities)
                  Text(
                    _getPageTitle(),
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          // 네비게이션 버튼 (활동이 모두 완료된 경우에만)
          if (!_isLoading && _hasAllActivities) ...[
            IconButton(
              onPressed: _currentPage > 0 ? _previousPage : null,
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: _currentPage > 0 
                    ? ModernColors.textPrimary 
                    : ModernColors.textTertiary,
                size: 20,
              ),
            ),
            IconButton(
              onPressed: _currentPage < 3 ? _nextPage : null,
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: _currentPage < 3 
                    ? ModernColors.textPrimary 
                    : ModernColors.textTertiary,
                size: 20,
              ),
            ),
          ],
          
          // 닫기 버튼
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: ModernColors.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 현재 페이지 제목 가져오기
  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return '운동 분석';
      case 1:
        return '독서 분석';
      case 2:
        return '일기 분석';
      case 3:
        return '종합 분석';
      default:
        return '';
    }
  }
  
  /// 페이지 뷰 컨텐츠
  Widget _buildPageViewContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      children: [
        // Page 1: 운동 분석
        ExerciseAnalysisPage(
          todayData: _todayExerciseData,
          previousData: _previousExerciseData,
          userName: _userName,
        ),
        
        // Page 2: 독서 분석 (임시 플레이스홀더)
        _buildComingSoonPage('독서 분석', Icons.menu_book_rounded),
        
        // Page 3: 일기 분석 (임시 플레이스홀더)
        _buildComingSoonPage('일기 분석', Icons.edit_note_rounded),
        
        // Page 4: 종합 분석 (임시 플레이스홀더)
        _buildComingSoonPage('종합 분석', Icons.dashboard_rounded),
      ],
    );
  }
  
  /// Coming Soon 페이지 (임시)
  Widget _buildComingSoonPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: ModernColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '준비 중입니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1, 1),
        duration: 500.ms,
        curve: Curves.easeOutBack,
      );
  }
  
  /// 페이지 인디케이터
  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive 
                  ? ModernColors.primary 
                  : ModernColors.textTertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
  
  /// 로딩 상태
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 로딩 애니메이션
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ModernColors.primaryGradient,
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).rotate(
                duration: 2.seconds,
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Image.asset(
                    SherpiEmotion.thinking.imagePath,
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '셰르피가 분석 중이에요',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '잠시만 기다려주세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 요구사항 메시지
  Widget _buildRequirementsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 셰르피 일러스트
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ModernColors.warning.withOpacity(0.2),
                    ModernColors.warning.withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: Image.asset(
                  SherpiEmotion.guiding.imagePath,
                  width: 70,
                  height: 70,
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
            
            Text(
              '모든 활동을 완료해주세요',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '오늘의 분석을 보려면\n아래 활동들을 완료해주세요',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
                height: 1.5,
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
                color: ModernColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ModernColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment_late_rounded,
                    color: ModernColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '남은 활동: $_missingActivities',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.warning,
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
  
  // 페이지 네비게이션
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}