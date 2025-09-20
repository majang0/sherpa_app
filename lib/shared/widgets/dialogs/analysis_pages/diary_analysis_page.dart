import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../providers/global_user_provider.dart';
import '../../../models/global_user_model.dart';
import '../../../../core/constants/sherpi_emotions.dart';
import '../../../../core/ai/activity_analysis_service.dart';

/// 📝 일기 분석 페이지 - 감정의 여정
///
/// 사용자의 감정 변화를 따뜻하게 분석하고 공감합니다.
/// 셰르피가 함께하는 감성적인 감정 여정을 구현합니다.
class DiaryAnalysisPage extends ConsumerStatefulWidget {
  const DiaryAnalysisPage({super.key});

  @override
  ConsumerState<DiaryAnalysisPage> createState() => _DiaryAnalysisPageState();
}

class _DiaryAnalysisPageState extends ConsumerState<DiaryAnalysisPage>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러들
  late AnimationController _pageAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _heartbeatController;
  late AnimationController _shimmerController;
  late AnimationController _emotionTransitionController;

  // 애니메이션들
  late Animation<double> _fadeInAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _emotionTransitionAnimation;

  // AI 분석 서비스
  final ActivityAnalysisService _analysisService =
      ActivityAnalysisService.instance;

  // 종합 일기 분석 데이터
  ComprehensiveDiaryAnalysis? _diaryAnalysis;
  bool _isLoadingAnalysis = false;

  // 오늘과 이전 일기 기록
  DiaryLog? _todayDiary;
  DiaryLog? _previousDiary;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDiaryData();
    _loadCachedAnalysis();
  }

  /// 애니메이션 초기화
  void _initializeAnimations() {
    // 페이지 전환 애니메이션
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 떠다니는 애니메이션 (셰르피 등)
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // 하트비트 애니메이션 (중요 요소 강조)
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    // 쉬머 효과 애니메이션
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // 감정 전환 애니메이션
    _emotionTransitionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // 애니메이션 곡선 설정
    _fadeInAnimation = CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeInOut,
    );

    _floatingAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));

    _heartbeatAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _heartbeatController,
      curve: Curves.easeInOut,
    ));

    _emotionTransitionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emotionTransitionController,
      curve: Curves.easeInOut,
    ));

    // 페이지 애니메이션 시작
    _pageAnimationController.forward();
  }

  /// 일기 데이터 로드
  void _loadDiaryData() {
    final user = ref.read(globalUserProvider);
    if (user.dailyRecords.diaryLogs.isEmpty) return;

    // 오늘 일기 찾기
    final today = DateTime.now();
    _todayDiary = user.dailyRecords.diaryLogs
        .where((log) => _isSameDay(log.date, today))
        .firstOrNull;

    // 이전 일기 찾기 (오늘 이전의 가장 최근 일기)
    if (_todayDiary != null) {
      final previousLogs = user.dailyRecords.diaryLogs
          .where((log) => log.date.isBefore(_todayDiary!.date))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (previousLogs.isNotEmpty) {
        _previousDiary = previousLogs.first;
      }
    }
  }

  /// 캐시된 분석 로드 또는 새로 생성
  Future<void> _loadCachedAnalysis() async {
    if (_todayDiary == null) return;

    setState(() {
      _isLoadingAnalysis = true;
    });

    try {
      // 먼저 캐시 확인
      final cachedAnalysis =
          await _analysisService.getComprehensiveDiaryFromCache();

      if (cachedAnalysis != null) {
        setState(() {
          _diaryAnalysis = cachedAnalysis;
          _isLoadingAnalysis = false;
        });
        return;
      }

      // 캐시가 없으면 새로 생성
      final analysis = await _analysisService.analyzeDiaryComprehensive(
        currentMood: _todayDiary!.mood,
        previousMood: _previousDiary?.mood,
        recentMoodHistory: _getRecentMoodHistory(),
        userName: ref.read(globalUserProvider).name,
      );

      setState(() {
        _diaryAnalysis = analysis;
        _isLoadingAnalysis = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAnalysis = false;
      });
    }
  }

  /// 최근 감정 히스토리 가져오기
  List<String> _getRecentMoodHistory() {
    final user = ref.read(globalUserProvider);
    final records = user.dailyRecords;
    final today = DateTime.now();
    final moodHistory = <String>[];

    // 최근 7일간의 감정 수집
    for (int i = 0; i < 7; i++) {
      final targetDate = today.subtract(Duration(days: i));
      final diary = records.diaryLogs.where((log) {
        return _isSameDay(log.date, targetDate);
      }).firstOrNull;

      if (diary != null) {
        moodHistory.add(diary.mood);
      }
    }

    return moodHistory;
  }

  /// 감정 이모지 가져오기
  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'excited':
        return '🥰';
      case 'happy':
        return '😄';
      case 'good':
        return '😊';
      case 'normal':
        return '😐';
      case 'thoughtful':
        return '🤔';
      case 'tired':
        return '😴';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      default:
        return '😊';
    }
  }

  /// 감정 색상 가져오기 - 부드러운 일기 테마 색상
  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'excited':
        return ModernColors.diary; // 풀 컬러
      case 'happy':
        return ModernColors.diary; // 풀 컬러
      case 'good':
        return ModernColors.diaryAccent; // 스카이 블루
      case 'normal':
        return ModernColors.diary.withValues(alpha: 0.9); // 살짝만 연하게
      case 'thoughtful':
        return ModernColors.diary.withValues(alpha: 0.85); // 약간 연하게
      case 'tired':
        return ModernColors.diary.withValues(alpha: 0.8); // 조금 연하게
      case 'sad':
        return ModernColors.diary.withValues(alpha: 0.85); // 약간 연하게
      case 'angry':
        return ModernColors.diary.withValues(alpha: 0.9); // 살짝만 연하게
      default:
        return ModernColors.diary;
    }
  }

  /// 감정 한글 라벨 가져오기
  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'excited':
        return '설레요';
      case 'happy':
        return '기뻐요';
      case 'good':
        return '좋아요';
      case 'normal':
        return '보통이에요';
      case 'thoughtful':
        return '생각이 많아요';
      case 'tired':
        return '피곤해요';
      case 'sad':
        return '슬퍼요';
      case 'angry':
        return '화나요';
      default:
        return '기뻐요';
    }
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _floatingAnimationController.dispose();
    _heartbeatController.dispose();
    _shimmerController.dispose();
    _emotionTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 헤더
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // 메인 콘텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 감정 히어로 섹션
                  _buildEmotionHeroSection(),
                  const SizedBox(height: 32),

                  // 감정 전환 섹션
                  if (_previousDiary != null && _diaryAnalysis != null)
                    _buildEmotionTransitionSection()
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 800.ms)
                        .slideY(begin: 0.2, end: 0),
                  if (_previousDiary != null && _diaryAnalysis != null)
                    const SizedBox(height: 32),

                  // AI 분석 섹션
                  if (_diaryAnalysis != null)
                    _buildAIAnalysisSection()
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 800.ms)
                        .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.diaryLight,
            ModernColors.diaryLight.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(
            child: CustomPaint(
              painter: DiaryPatternPainter(
                color: ModernColors.diary.withValues(alpha: 0.05),
              ),
            ),
          ),

          // 콘텐츠
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // 타이틀
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Row(
                      children: [
                        // 셰르피 이미지
                        AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatingAnimation.value),
                              child: Image.asset(
                                SherpiEmotion.smile.imagePath,
                                width: 90,
                                height: 90,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        // 타이틀 텍스트
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '감정 분석',
                                style: GoogleFonts.notoSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: ModernColors.diary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '셰르피와 함께하는 감정 이야기',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ModernColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 감정 히어로 섹션
  Widget _buildEmotionHeroSection() {
    if (_todayDiary == null) {
      return _buildEmptyState();
    }

    final mood = _todayDiary!.mood;
    final moodEmoji = _getMoodEmoji(mood);
    final moodColor = _getMoodColor(mood);
    final moodLabel = _getMoodLabel(mood);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 감정 아이콘
          AnimatedBuilder(
            animation: _heartbeatAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _heartbeatAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        ModernColors.diaryLight,
                        ModernColors.diaryLight.withValues(alpha: 0.3),
                      ],
                      center: Alignment.center,
                      radius: 0.8,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ModernColors.diary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      moodEmoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // 오늘의 감정
          Text(
            '오늘의 감정',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            moodLabel,
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: moodColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 감정 전환 섹션
  Widget _buildEmotionTransitionSection() {
    if (_previousDiary == null || _diaryAnalysis == null) {
      return const SizedBox.shrink();
    }

    final previousMood = _getMoodLabel(_previousDiary!.mood);
    final currentMood = _getMoodLabel(_todayDiary!.mood);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ModernColors.diaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timeline,
                  color: ModernColors.diary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '감정 변화',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 감정 변화 표시
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getMoodEmoji(_previousDiary!.mood),
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      previousMood,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _emotionTransitionAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.5 + _emotionTransitionAnimation.value * 0.5,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ModernColors.diaryLight.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: ModernColors.diary,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getMoodEmoji(_todayDiary!.mood),
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentMood,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // AI 감정 전환 분석
          if (_diaryAnalysis!.emotionTransition.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _diaryAnalysis!.emotionTransition,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: ModernColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// AI 분석 섹션
  Widget _buildAIAnalysisSection() {
    if (_isLoadingAnalysis) {
      return _buildLoadingShimmer();
    }

    if (_diaryAnalysis == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // 감정적 지지 카드
        _buildAnalysisCard(
          icon: Icons.favorite,
          iconColor: ModernColors.error,
          title: '따뜻한 위로',
          content: _diaryAnalysis!.emotionalSupport,
          gradient: LinearGradient(
            colors: [
              ModernColors.error.withValues(alpha: 0.1),
              ModernColors.error.withValues(alpha: 0.05),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 실질적 조언 카드
        _buildAnalysisCard(
          icon: Icons.lightbulb,
          iconColor: ModernColors.warning,
          title: '실질적 조언',
          content: _diaryAnalysis!.practicalAdvice,
          gradient: LinearGradient(
            colors: [
              ModernColors.warning.withValues(alpha: 0.1),
              ModernColors.warning.withValues(alpha: 0.05),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 내일을 위한 희망 카드
        _buildAnalysisCard(
          icon: Icons.wb_sunny,
          iconColor: ModernColors.success,
          title: '내일의 희망',
          content: _diaryAnalysis!.tomorrowHope,
          gradient: LinearGradient(
            colors: [
              ModernColors.success.withValues(alpha: 0.1),
              ModernColors.success.withValues(alpha: 0.05),
            ],
          ),
        ),
      ],
    );
  }

  /// 분석 카드 빌드
  Widget _buildAnalysisCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ModernColors.diary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.diaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 쉬머 효과
  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          decoration: BoxDecoration(
            color: ModernColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.surface,
                      ModernColors.surface.withValues(alpha: 0.5),
                      ModernColors.surface,
                    ],
                    stops: [
                      0.0,
                      _shimmerController.value,
                      1.0,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  /// 빈 상태 화면
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 80,
            color: ModernColors.diary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '오늘의 일기가 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '일기를 작성하고 감정 분석을 받아보세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜가 같은지 확인
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// 일기 패턴 페인터 (배경 장식)
class DiaryPatternPainter extends CustomPainter {
  final Color color;

  DiaryPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 일기장 라인 패턴 그리기
    const lineSpacing = 30.0;
    const marginLeft = 60.0;

    // 가로 줄 그리기 (공책 느낌)
    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint..color = color.withValues(alpha: 0.3),
      );
    }

    // 왼쪽 여백 선 (일기 테마 색상)
    paint
      ..color = ModernColors.diaryAccent.withValues(alpha: 0.3)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(marginLeft, 0),
      Offset(marginLeft, size.height),
      paint,
    );

    // 펜 아이콘 패턴 그리기
    paint
      ..color = color
      ..style = PaintingStyle.fill;
    _drawPenIcon(canvas, size.width - 40, size.height - 40, 20, paint);
  }

  void _drawPenIcon(
      Canvas canvas, double x, double y, double size, Paint paint) {
    // 펜 몸체
    final penPath = Path()
      ..moveTo(x - size * 0.15, y - size * 0.5)
      ..lineTo(x + size * 0.15, y - size * 0.5)
      ..lineTo(x + size * 0.15, y + size * 0.3)
      ..lineTo(x - size * 0.15, y + size * 0.3)
      ..close();

    canvas.drawPath(penPath, paint);

    // 펜 끝 (삼각형)
    final tipPath = Path()
      ..moveTo(x - size * 0.15, y + size * 0.3)
      ..lineTo(x + size * 0.15, y + size * 0.3)
      ..lineTo(x, y + size * 0.5)
      ..close();

    canvas.drawPath(tipPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
