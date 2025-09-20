import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/ai/activity_analysis_service.dart';
import '../../../../core/constants/sherpi_emotions.dart';
// import '../../../providers/global_user_provider.dart';
// import '../../../models/global_user_model.dart';

/// 🌟 종합 분석 페이지 - 하루 전체를 아우르는 통찰력 있는 분석
///
/// 운동, 독서, 일기를 하나의 스토리로 엮어내어
/// 사용자의 하루를 더 깊이 이해하고 의미를 찾을 수 있도록 돕습니다.
class ComprehensiveAnalysisPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? exerciseData;
  final Map<String, dynamic>? readingData;
  final Map<String, dynamic>? diaryData;
  final String userName;

  const ComprehensiveAnalysisPage({
    super.key,
    this.exerciseData,
    this.readingData,
    this.diaryData,
    required this.userName,
  });

  @override
  ConsumerState<ComprehensiveAnalysisPage> createState() =>
      _ComprehensiveAnalysisPageState();
}

class _ComprehensiveAnalysisPageState
    extends ConsumerState<ComprehensiveAnalysisPage>
    with TickerProviderStateMixin {
  // AI 분석 서비스
  final ActivityAnalysisService _analysisService =
      ActivityAnalysisService.instance;

  // 종합 분석 데이터
  ComprehensiveDayAnalysis? _analysisData;
  bool _isLoading = false;
  bool _hasGenerated = false; // 분석 생성 여부
  String _loadingMessage = '오늘의 데이터를 모으고 있어요...';
  double _loadingProgress = 0.0;

  // 애니메이션 컨트롤러들
  late AnimationController _pageAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _shimmerController;
  late AnimationController _progressController;
  late AnimationController _chartAnimationController;

  // 애니메이션들
  late Animation<double> _fadeInAnimation;
  late Animation<double> _floatingAnimation;
  // late Animation<double> _scaleAnimation;

  // UI 상태
  // int _selectedSection = 0; // 선택된 섹션 (0: 전체, 1: 균형, 2: 성장, 3: 내일)

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // 자동 로딩 제거 - 버튼 클릭 시에만 로딩
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _floatingAnimationController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
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

    // 쉬머 효과 애니메이션
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // 진행 바 애니메이션
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // 차트 애니메이션
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

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

    // _scaleAnimation = CurvedAnimation(
    //   parent: _pageAnimationController,
    //   curve: Curves.easeOutBack,
    // );
  }

  /// 종합 분석 데이터 로드
  Future<void> _loadAnalysisData() async {
    // 로딩 프로그레스 애니메이션 시작
    _progressController.forward();

    try {
      // 로딩 메시지 업데이트 (순차적으로)
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _loadingMessage = '운동 데이터 분석 중...';
        _loadingProgress = 0.25;
      });

      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _loadingMessage = '독서 기록 확인 중...';
        _loadingProgress = 0.5;
      });

      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _loadingMessage = '감정 패턴 파악 중...';
        _loadingProgress = 0.75;
      });

      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _loadingMessage = '종합 인사이트 생성 중...';
        _loadingProgress = 0.9;
      });

      // 실제 AI 분석 호출 - forceRegenerate: true로 항상 새로 생성
      await _performAnalysis(forceRefresh: true);

      // 로딩 완료
      setState(() {
        _loadingProgress = 1.0;
        _isLoading = false;
      });

      // 페이지 애니메이션 시작
      _pageAnimationController.forward();
      _chartAnimationController.forward();
    } catch (e) {
      print('종합 분석 로드 에러: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// AI 분석 수행
  Future<void> _performAnalysis({bool forceRefresh = false}) async {
    try {
      // 실제 AI 서비스 호출 (forceRegenerate 파라미터 추가)
      _analysisData = await _analysisService.analyzeDayComprehensive(
        exerciseData: widget.exerciseData ?? {},
        readingData: widget.readingData ?? {},
        diaryData: widget.diaryData ?? {},
        userName: widget.userName,
        forceRegenerate: forceRefresh, // 강제 새로고침 옵션
      );
    } catch (e) {
      print('종합 분석 수행 중 에러: $e');
      // 에러 발생 시 기본 데이터 사용
      _analysisData = ComprehensiveDayAnalysis(
        dayTheme: '성실한 하루 ✨',
        emotionalJourney:
            '오늘 하루도 열심히 보내셨네요. 운동, 독서, 일기를 통해 몸과 마음을 돌보는 시간을 가지셨어요.',
        balanceReport: '신체와 정신, 감정이 조화를 이루며 균형잡힌 하루를 보내셨습니다.',
        growthInsight: '꾸준한 기록과 활동이 당신의 성장을 만들어가고 있어요.',
        tomorrowGuide: '오늘의 좋은 흐름을 내일도 이어가보세요.',
        sherpiMessage:
            '${widget.userName}님, 오늘 하루도 수고 많으셨어요! 내일도 함께 멋진 하루를 만들어가요!',
        balanceScore: 75.0,
        scores: {
          '신체': 80.0,
          '정신': 75.0,
          '감정': 70.0,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (!_hasGenerated) {
      return _buildGenerateButton();
    }

    return _buildAnalysisContent();
  }

  /// 분석 생성 버튼 화면
  Widget _buildGenerateButton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 셰르피 아이콘
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ModernColors.primary.withOpacity(0.1),
                  ModernColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Image.asset(
                SherpiEmotion.defaults.imagePath,
                width: 70,
                height: 70,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 안내 텍스트
          Text(
            'AI가 오늘 하루를\n종합적으로 분석해드릴게요',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              height: 1.5,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // 생성 버튼
          GestureDetector(
            onTap: _generateAnalysis,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: ModernColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '종합 분석 생성',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        ],
      ),
    );
  }

  /// 분석 생성 실행
  Future<void> _generateAnalysis() async {
    setState(() {
      _isLoading = true;
      _hasGenerated = true;
    });

    await _loadAnalysisData();
  }

  /// 로딩 화면 구성
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 셰르피 생각하는 애니메이션
          AnimatedBuilder(
            animation: _floatingAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: ModernColors.primaryGradient,
                  ),
                  child: Center(
                    child: Image.asset(
                      SherpiEmotion.thinking.imagePath,
                      width: 70,
                      height: 70,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // 로딩 메시지
          Text(
            _loadingMessage,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          )
              .animate(key: ValueKey(_loadingMessage))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // 진행 바
          Container(
            width: 200,
            height: 8,
            decoration: BoxDecoration(
              color: ModernColors.gray100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 200 * _loadingProgress,
                decoration: BoxDecoration(
                  gradient: ModernColors.primaryGradient,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 분석 콘텐츠 구성
  Widget _buildAnalysisContent() {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThemeCard(),
            const SizedBox(height: 20),
            _buildBalanceChart(),
            const SizedBox(height: 20),
            _buildStorySection(),
            const SizedBox(height: 20),
            _buildGrowthInsights(),
            const SizedBox(height: 20),
            _buildTomorrowGuide(),
            const SizedBox(height: 20),
            _buildSherpiMessage(),
          ],
        ),
      ),
    );
  }

  /// 오늘의 테마 카드
  Widget _buildThemeCard() {
    return Container(
      width: double.infinity, // 전체 너비 사용
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 부분
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: ModernColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '오늘의 테마',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                ],
              ),
              // 날짜 표시
              Text(
                DateTime.now().toString().split(' ')[0],
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 테마 텍스트
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.primary.withOpacity(0.05),
                  ModernColors.primary.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _analysisData?.dayTheme ?? '',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.primary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  /// 균형 차트 (레이더 차트)
  Widget _buildBalanceChart() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 균형',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_analysisData?.balanceScore.toStringAsFixed(0)}점',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _chartAnimationController,
              builder: (context, child) {
                return RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    radarBorderData: BorderSide(
                      color: ModernColors.borderLight,
                      width: 1,
                    ),
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    titlePositionPercentageOffset: 0.2,
                    titleTextStyle: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textSecondary,
                    ),
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0:
                          return RadarChartTitle(
                            text: '신체 💪',
                            angle: 0,
                          );
                        case 1:
                          return RadarChartTitle(
                            text: '정신 🧠',
                            angle: 0,
                          );
                        case 2:
                          return RadarChartTitle(
                            text: '감정 💝',
                            angle: 0,
                          );
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.transparent,
                    ),
                    tickBorderData: BorderSide(
                      color: ModernColors.borderLight.withOpacity(0.3),
                      width: 0.5,
                    ),
                    gridBorderData: BorderSide(
                      color: ModernColors.borderLight.withOpacity(0.5),
                      width: 0.5,
                    ),
                    dataSets: [
                      RadarDataSet(
                        fillColor: ModernColors.primary.withOpacity(0.2),
                        borderColor: ModernColors.primary,
                        borderWidth: 2,
                        entryRadius: 4,
                        dataEntries: [
                          RadarEntry(
                            value: (_analysisData?.scores['신체'] ?? 0) *
                                _chartAnimationController.value,
                          ),
                          RadarEntry(
                            value: (_analysisData?.scores['정신'] ?? 0) *
                                _chartAnimationController.value,
                          ),
                          RadarEntry(
                            value: (_analysisData?.scores['감정'] ?? 0) *
                                _chartAnimationController.value,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // 점수 레전드
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreLegend(
                '신체',
                _analysisData?.scores['신체'] ?? 0,
                ModernColors.exercise,
              ),
              _buildScoreLegend(
                '정신',
                _analysisData?.scores['정신'] ?? 0,
                ModernColors.reading,
              ),
              _buildScoreLegend(
                '감정',
                _analysisData?.scores['감정'] ?? 0,
                ModernColors.diary,
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  /// 점수 레전드 위젯
  Widget _buildScoreLegend(String label, double score, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ${score.toStringAsFixed(0)}',
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 스토리 섹션
  Widget _buildStorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_stories_rounded,
                color: ModernColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 스토리',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _analysisData?.emotionalJourney ?? '',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              height: 1.6,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: ModernColors.borderLight),
          const SizedBox(height: 12),
          Text(
            _analysisData?.balanceReport ?? '',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              height: 1.6,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  /// 성장 인사이트
  Widget _buildGrowthInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.success.withOpacity(0.1),
            ModernColors.success.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: ModernColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '성장 인사이트',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _analysisData?.growthInsight ?? '',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              height: 1.6,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  /// 내일을 위한 제안
  Widget _buildTomorrowGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: ModernColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '내일을 위한 제안',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _analysisData?.tomorrowGuide ?? '',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              height: 1.6,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  /// 셰르피 메시지
  Widget _buildSherpiMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.primary.withOpacity(0.05),
            ModernColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            SherpiEmotion.cheering.imagePath,
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 16),
          Text(
            '셰르피의 메시지',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _analysisData?.sherpiMessage ?? '',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              height: 1.6,
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0)
        .then()
        .shimmer(
            duration: 2000.ms, color: ModernColors.primary.withOpacity(0.1));
  }
}
