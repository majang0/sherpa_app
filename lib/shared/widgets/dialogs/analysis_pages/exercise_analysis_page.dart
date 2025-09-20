import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import 'package:sherpa_app/core/ai/services/activity_analysis_service.dart';
import '../../../../core/utils/exercise_calculator.dart';
import '../../../../core/constants/sherpi_emotions.dart';

/// 운동 분석 페이지 - 셰르피가 직접 대화하는 친근한 분석 (주황색 테마)
class ExerciseAnalysisPage extends StatefulWidget {
  final Map<String, dynamic>? todayData;
  final Map<String, dynamic>? previousData;
  final String userName;

  const ExerciseAnalysisPage({
    super.key,
    this.todayData,
    this.previousData,
    required this.userName,
  });

  @override
  State<ExerciseAnalysisPage> createState() => _ExerciseAnalysisPageState();
}

class _ExerciseAnalysisPageState extends State<ExerciseAnalysisPage>
    with TickerProviderStateMixin {
  // 토글 상태 (true: 시간/강도, false: 칼로리)
  bool _showTimeIntensity = true;

  // AI 분석 데이터
  final ActivityAnalysisService _analysisService =
      ActivityAnalysisService.instance;
  ComprehensiveExerciseAnalysis? _analysisData;
  bool _isLoading = true;

  // 애니메이션 컨트롤러
  late AnimationController _badgeAnimationController;
  late AnimationController _pulseController;
  late AnimationController _cardAnimationController;
  late AnimationController _pageAnimationController;
  late AnimationController _floatingAnimationController;

  // 애니메이션들
  late Animation<double> _fadeInAnimation;
  late Animation<double> _floatingAnimation;

  // ModernColors.exercise를 사용 (이제 주황색으로 변경됨)

  @override
  void initState() {
    super.initState();

    _badgeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
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

    // 페이지 애니메이션 시작
    _pageAnimationController.forward();

    // AI 분석 데이터 로드
    _loadAnalysisData();
  }

  /// AI 분석 데이터 로드
  Future<void> _loadAnalysisData() async {
    if (widget.todayData == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 먼저 캐시 확인 (즉시 반환됨)
      final cachedAnalysis =
          await _analysisService.getComprehensiveExerciseFromCache();

      if (cachedAnalysis != null) {
        // 캐시가 있으면 즉시 표시 (로딩 없음)
        if (mounted) {
          setState(() {
            _analysisData = cachedAnalysis;
            _isLoading = false;
          });
        }
        print('💾 캐시에서 종합 운동 분석 즉시 로드 완료');
        return;
      }

      // 캐시가 없는 경우에만 생성 (보통 발생하지 않음 - 운동 완료 시 이미 생성됨)
      print('⚠️ 캐시 없음 - 운동 분석 새로 생성 중...');
      final analysis = await _analysisService.analyzeExerciseComprehensive(
        todayExercise: widget.todayData!,
        previousExercise: widget.previousData,
        userName: widget.userName,
      );

      if (mounted) {
        setState(() {
          _analysisData = analysis;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 운동 분석 로드 실패: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _badgeAnimationController.dispose();
    _pulseController.dispose();
    _cardAnimationController.dispose();
    _pageAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  // 운동 타입에 따른 이모지 반환 - ExerciseSelectionScreen과 동일한 시스템
  String _getExerciseEmoji(String? type) {
    if (type == null) return '💪';

    // 실제 운동 선택 화면과 동일한 이모지 매핑
    switch (type) {
      case '헬스':
        return '💪';
      case '러닝':
        return '🏃‍♂️';
      case '등산':
        return '🥾';
      case '수영':
        return '🏊‍♂️';
      case '자전거':
        return '🚴‍♂️';
      case '요가':
        return '🧘‍♀️';
      case '필라테스':
        return '🤸‍♀️';
      case '클라이밍':
        return '🧗‍♂️';
      case '테니스':
        return '🎾';
      case '배드민턴':
        return '🏸';
      case '골프':
        return '⛳';
      case '축구':
        return '⚽';
      case '농구':
        return '🏀';
      default:
        return '💪';
    } // 기본값
  }

  // 강도에 따른 색상 반환 (주황색 테마)
  Color _getIntensityColor(String? intensity) {
    switch (intensity) {
      case '낮음':
        return ModernColors.warning; // 경고 색상
      case '중간':
        return ModernColors.exercise;
      case '높음':
        return ModernColors.exercise;
      case '매우 높음':
        return ModernColors.exercise;
      default:
        return ModernColors.exercise;
    }
  }

  // 강도 레벨 반환 (1-4)
  int _getIntensityLevel(String? intensity) {
    switch (intensity) {
      case '낮음':
        return 1;
      case '중간':
        return 2;
      case '높음':
        return 3;
      case '매우 높음':
        return 4;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.todayData == null) {
      return Scaffold(
        backgroundColor: ModernColors.background,
        body: _buildNoDataState(),
      );
    }

    return Scaffold(
      backgroundColor: ModernColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 헤더
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // 컨텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1-2. 시각적 배지 섹션
                  _buildBadgeSection(),

                  const SizedBox(height: 24),

                  // 3. 비교 분석 섹션 (리디자인)
                  _buildModernComparisonSection(),

                  const SizedBox(height: 20),

                  // 4. 오늘 운동의 장점 (리디자인)
                  _buildModernBenefitsSection(),

                  const SizedBox(height: 20),

                  // 5. 셰르피의 추천 (리디자인)
                  _buildModernRecommendationSection(),

                  const SizedBox(height: 20),

                  // 6. 응원의 말 (리디자인)
                  _buildModernEncouragementSection(),

                  const SizedBox(height: 100),
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
            ModernColors.exercise.withValues(alpha: 0.2),
            ModernColors.exercise.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(
            child: CustomPaint(
              painter: ExercisePatternPainter(
                color: ModernColors.exercise.withValues(alpha: 0.1),
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
                        // 셰르피 아이콘
                        AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatingAnimation.value),
                              child: Image.asset(
                                SherpiEmotion.cheering.imagePath,
                                width: 90,
                                height: 90,
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '운동 여정 분석',
                                style: GoogleFonts.notoSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: ModernColors.exercise,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '셰르피와 함께하는 운동 이야기',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
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
    ).animate().fadeIn(duration: const Duration(milliseconds: 800));
  }

  /// 시각적 배지 섹션
  Widget _buildBadgeSection() {
    return Column(
      children: [
        // 지난번 운동 배지 (있는 경우)
        if (widget.previousData != null) ...[
          _buildExerciseBadge(
            title: '지난번 운동',
            data: widget.previousData!,
            isToday: false,
            delay: 0,
          ),
          const SizedBox(height: 16),
        ],

        // 오늘의 운동 배지
        _buildExerciseBadge(
          title: '오늘의 운동',
          data: widget.todayData!,
          isToday: true,
          delay: 200,
        ),
      ],
    );
  }

  /// 개별 운동 배지 (주황색 테마 적용)
  Widget _buildExerciseBadge({
    required String title,
    required Map<String, dynamic> data,
    required bool isToday,
    required int delay,
  }) {
    final exerciseType = data['type'] as String?;
    final duration = data['duration'] as int? ?? 0;
    final calories = data['calories'] as int? ?? 0;
    final intensity = data['intensity'] as String?;
    final date = data['date'] as DateTime?;

    return GestureDetector(
      onTap: () {
        // 햅틱 피드백
        HapticFeedback.lightImpact();

        setState(() {
          _showTimeIntensity = !_showTimeIntensity;
        });

        // 애니메이션 재생
        _badgeAnimationController.forward(from: 0);
      },
      child: AnimatedBuilder(
        animation: _badgeAnimationController,
        builder: (context, child) {
          final scale = 1.0 + (_badgeAnimationController.value * 0.05);

          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isToday
                    ? ModernColors.exercise
                    : ModernColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: isToday
                    ? null
                    : Border.all(
                        color: ModernColors.border,
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isToday
                        ? ModernColors.exercise.withOpacity(0.3)
                        : ModernColors.border.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isToday ? Colors.white : ModernColors.textPrimary,
                        ),
                      ),
                      if (date != null)
                        Text(
                          '${date.month}/${date.day}',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isToday
                                ? Colors.white.withOpacity(0.8)
                                : ModernColors.textSecondary,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 메인 컨텐츠
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showTimeIntensity
                        ? _buildTimeIntensityView(
                            exerciseType: exerciseType,
                            duration: duration,
                            intensity: intensity,
                            isToday: isToday,
                          )
                        : _buildCaloriesView(
                            exerciseType: exerciseType,
                            calories: calories,
                            isToday: isToday,
                          ),
                  ),

                  const SizedBox(height: 16),

                  // 탭 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 16,
                        color: isToday
                            ? Colors.white.withOpacity(0.6)
                            : ModernColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '탭하여 전환',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isToday
                              ? Colors.white.withOpacity(0.6)
                              : ModernColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 600.ms,
          delay: delay.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(
          duration: 600.ms,
          delay: delay.ms,
        );
  }

  /// 시간/강도 뷰
  Widget _buildTimeIntensityView({
    required String? exerciseType,
    required int duration,
    required String? intensity,
    required bool isToday,
  }) {
    return Row(
      key: const ValueKey('time-intensity'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 운동 타입
        Column(
          children: [
            Text(
              _getExerciseEmoji(exerciseType),
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 4),
            Text(
              exerciseType ?? '운동',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isToday ? Colors.white : ModernColors.textPrimary,
              ),
            ),
          ],
        ),

        // 구분선
        Container(
          width: 1,
          height: 50,
          color: isToday ? Colors.white.withOpacity(0.3) : ModernColors.border,
        ),

        // 시간
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$duration',
                  style: GoogleFonts.notoSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: isToday ? Colors.white : ModernColors.textPrimary,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 2),
                  child: Text(
                    '분',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isToday
                          ? Colors.white.withOpacity(0.8)
                          : ModernColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '운동 시간',
              style: GoogleFonts.notoSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isToday
                    ? Colors.white.withOpacity(0.8)
                    : ModernColors.textSecondary,
              ),
            ),
          ],
        ),

        // 구분선
        Container(
          width: 1,
          height: 50,
          color: isToday ? Colors.white.withOpacity(0.3) : ModernColors.border,
        ),

        // 강도
        Column(
          children: [
            _buildIntensityIndicator(intensity, isToday),
            const SizedBox(height: 8),
            Text(
              intensity ?? '중간',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isToday ? Colors.white : ModernColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 칼로리 뷰
  Widget _buildCaloriesView({
    required String? exerciseType,
    required int calories,
    required bool isToday,
  }) {
    return Column(
      key: const ValueKey('calories'),
      children: [
        // 운동 타입
        Text(
          _getExerciseEmoji(exerciseType),
          style: const TextStyle(fontSize: 35), // 50 -> 35로 줄임
        ),

        const SizedBox(height: 8), // 12 -> 8로 줄임

        // 칼로리
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$calories',
              style: GoogleFonts.notoSans(
                fontSize: 24, // 28 -> 24로 더 줄임
                fontWeight: FontWeight.w700,
                color: isToday ? Colors.white : ModernColors.textPrimary,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 3, left: 3), // bottom: 4 -> 3으로 조정
              child: Text(
                'kcal',
                style: GoogleFonts.notoSans(
                  fontSize: 12, // 14 -> 12로 더 줄임
                  fontWeight: FontWeight.w500,
                  color: isToday
                      ? Colors.white.withOpacity(0.8)
                      : ModernColors.textSecondary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 2), // 4 -> 2로 줄임

        Text(
          '소모 칼로리',
          style: GoogleFonts.notoSans(
            fontSize: 11, // 12 -> 11로 줄임
            fontWeight: FontWeight.w500,
            color: isToday
                ? Colors.white.withOpacity(0.8)
                : ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 강도 인디케이터
  Widget _buildIntensityIndicator(String? intensity, bool isToday) {
    final level = _getIntensityLevel(intensity);

    return Row(
      children: List.generate(4, (index) {
        final isActive = index < level;
        return Container(
          width: 8,
          height: isActive ? 20 + (index * 4) : 16,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive
                ? (isToday ? Colors.white : _getIntensityColor(intensity))
                : (isToday
                    ? Colors.white.withOpacity(0.3)
                    : ModernColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  /// 비교 분석 섹션 (말풍선 스타일)
  Widget _buildModernComparisonSection() {
    final content = _isLoading
        ? '"잠시만요... 데이터를 보고 있어요..."'
        : (_analysisData?.comparison ?? _getDefaultComparisonMessage());

    // 텍스트를 bullet points로 분리
    final points = _splitIntoPoints(content);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 - 효과 섹션과 동일한 스타일
          Row(
            children: [
              // 아이콘 컨테이너
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: ModernColors.exercise,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // 타이틀
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 지난번과의 비교',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '셰르피가 분석해드려요',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.exercise,
                      ),
                    ),
                  ],
                ),
              ),
              // 비교 데이터가 있으면 차트 표시
              if (widget.previousData != null && !_isLoading) _buildMiniChart(),
            ],
          ),

          const SizedBox(height: 20),

          // 컨텐츠 섹션
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points.map((point) => _buildBulletPoint(point)).toList(),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 400.ms)
        .fadeIn(duration: 600.ms, delay: 400.ms);
  }

  /// 효과 섹션 (구체적 수치와 시각화) - Modern Clean Design
  Widget _buildModernBenefitsSection() {
    if (_isLoading) {
      return _buildLoadingBenefitsSection();
    }

    // 실제 운동 데이터 기반 효과 계산
    final todayData = widget.todayData!;
    final duration = todayData['duration'] as int? ?? 0;
    final intensity = todayData['intensity'] as String? ?? '중간';
    final exerciseType = todayData['type'] as String? ?? '운동';
    final exerciseTime = todayData['date'] ?? DateTime.now();

    // 칼로리 계산 (실제 칼로리가 없으면 MET 기반 계산)
    final calories = todayData['calories'] as int? ??
        ExerciseCalculator.calculateCalories(
          exerciseType: ExerciseTypeMapper.toKorean(exerciseType),
          durationMinutes: duration,
          intensity: intensity,
        );

    // 의학적 근거 기반 데이터 계산
    final heartRateData = ExerciseCalculator.calculateHeartRateEffect(
      durationMinutes: duration,
      intensity: intensity,
    );

    final bloodPressureData = ExerciseCalculator.getBloodPressureEffect(
      durationMinutes: duration,
      intensity: intensity,
    );

    final endorphinData = ExerciseCalculator.getEndorphinEffect(
      durationMinutes: duration,
      intensity: intensity,
    );

    final brainData = ExerciseCalculator.getBrainEffect(
      durationMinutes: duration,
      exerciseType: ExerciseTypeMapper.toKorean(exerciseType),
      intensity: intensity,
    );

    final metabolicData = ExerciseCalculator.getMetabolicEffect(
      calories: calories,
      intensity: intensity,
      durationMinutes: duration,
    );

    final muscleData = ExerciseCalculator.getMuscleGrowthEffect(
      exerciseType: ExerciseTypeMapper.toKorean(exerciseType),
      durationMinutes: duration,
      intensity: intensity,
    );

    final sleepData = ExerciseCalculator.getSleepEffect(
      durationMinutes: duration,
      intensity: intensity,
      exerciseTime: exerciseTime,
    );

    return Container(
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernColors.softShadow(primaryColor: ModernColors.exercise),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션 - Clean Design
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타이틀 - 단순하고 명확
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: ModernColors.exercise,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎉 오! 이런 효과가?',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '생각보다 더 대단한 변화들',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ModernColors.exercise,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 메인 임팩트 수치 - White Background with Orange Accent
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ModernColors.exercise.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildImpactMetric(
                        icon: '🔥',
                        value: '${metabolicData['totalCalories']}kcal',
                        label: '총 소모',
                        subtitle: '${metabolicData['epocDuration']}시간 추가 소모!',
                      ),
                      _buildVerticalDivider(),
                      _buildImpactMetric(
                        icon: '💓',
                        value: '+${heartRateData['increase']}bpm',
                        label: '심박수 증가',
                        subtitle: '목표 ${heartRateData['targetHR']}회/분',
                      ),
                      _buildVerticalDivider(),
                      _buildImpactMetric(
                        icon: '🧠',
                        value: '+${brainData['bdnfIncrease']}%',
                        label: 'BDNF 증가',
                        subtitle: '${brainData['cognitiveEffect']}',
                      ),
                    ],
                  ),
                ),

                // AI 개인화 메시지 - Clean Modern Design
                if (_analysisData?.benefits != null &&
                    _analysisData!.benefits!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ModernColors.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: ModernColors.exercise,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI 분석 인사이트',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: ModernColors.exercise,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _analysisData!.benefits!,
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                  color: ModernColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(
                      begin: 0.05, end: 0, duration: 600.ms, delay: 400.ms),
              ],
            ),
          ),

          // 구체적 효과 카드들 - Clean White Design
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const SizedBox(height: 2),

                _buildSpecificEffectCard(
                  icon: '🫀',
                  title: '심혈관 건강',
                  mainEffect:
                      '혈압 ${bloodPressureData['systolic']}/${bloodPressureData['diastolic']}mmHg 감소',
                  details: [
                    '${bloodPressureData['duration']} 동안 효과 지속',
                    '${bloodPressureData['longTermBenefit']}',
                    '회복 시간 ${heartRateData['recoveryMinutes']}분'
                  ],
                  progress: _getIntensityLevel(intensity) / 4,
                  index: 0,
                ),

                const SizedBox(height: 10), // Optimal card spacing

                _buildSpecificEffectCard(
                  icon: '😴',
                  title: '수면 개선',
                  mainEffect: '수면 질 ${sleepData['qualityImprovement']} 개선',
                  details: [
                    '${sleepData['effect']}',
                    '깊은 수면 ${sleepData['deepSleep']}',
                    '${sleepData['recommendation']}'
                  ],
                  progress: math.min(
                      double.parse(sleepData['qualityImprovement']
                              .replaceAll('%', '')) /
                          40.0,
                      1.0),
                  index: 1,
                ),

                const SizedBox(height: 10), // Optimal card spacing

                _buildSpecificEffectCard(
                  icon: '💪',
                  title: '근육 & 대사',
                  mainEffect:
                      '운동후 Afterburn ${metabolicData['epocCalories']}kcal 추가 소모',
                  details: [
                    '${muscleData['growthRate']}',
                    '단백질 합성 +${muscleData['proteinSynthesis']}',
                    '${muscleData['muscleGroup']} 강화'
                  ],
                  progress: math.min(calories / 500, 1.0),
                  index: 2,
                ),

                const SizedBox(height: 12), // Compact section spacing

                // "Did you know?" 섹션 - Optimized Compact Design
                _buildSimpleDidYouKnowSection(
                    duration, calories, intensity, endorphinData),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 600.ms)
        .fadeIn(duration: 600.ms, delay: 600.ms);
  }

  /// 추천 섹션 (말풍선 스타일)
  Widget _buildModernRecommendationSection() {
    final content = _isLoading
        ? '"추천을 준비 중이에요..."'
        : (_analysisData?.recommendation ?? '"다음에는 이렇게 해보면 어떨까요?"');

    final points = _splitIntoPoints(content);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernColors.exercise,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더 - Clean Design
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ModernColors.exercise,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // 셰르피 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: ModernColors.exercise,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '셰르피의 꿀팁이에요!',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '다음엔 이렇게 해보세요',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 추천 카드들 - 깔끔한 디자인
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: points.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                return _buildRecommendationCard(point, index);
              }).toList(),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 800.ms)
        .fadeIn(duration: 600.ms, delay: 800.ms);
  }

  /// 셰르피가 응원해요! 🎉
  Widget _buildModernEncouragementSection() {
    final encouragement = _isLoading
        ? '응원 메시지를 준비하고 있어요...'
        : (_analysisData?.encouragement ?? '오늘도 정말 수고하셨어요! 💪');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.exerciseLight.withOpacity(0.5),
            Colors.white,
            ModernColors.exerciseLight.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ModernColors.exercise.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 셰르피 캐릭터 이미지 (애니메이션)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.exercise.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/sherpi/sherpi_cheering.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          // 셰르피 대화 시작
          Text(
            '"와~ 오늘도 정말 대단해요!"',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ModernColors.exercise,
            ),
          ),

          const SizedBox(height: 14),

          // 셑르피의 말풍선 메시지
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ModernColors.exercise.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  encouragement.replaceAll('"', ''), // 따옴표 제거
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                    height: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // 말풍선 꼬리
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: CustomPaint(
                    size: const Size(20, 10),
                    painter: _BubbleTailPainter(
                      color: Colors.white.withOpacity(0.9),
                      borderColor: ModernColors.exercise.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 동기부여 배지
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMotivationBadge('💪', '꾸준함'),
              const SizedBox(width: 12),
              _buildMotivationBadge('🔥', '열정'),
              const SizedBox(width: 12),
              _buildMotivationBadge('⭐', '성장'),
            ],
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.1, end: 0, duration: 800.ms, delay: 1000.ms)
        .fadeIn(duration: 800.ms, delay: 1000.ms);
  }

  // ============ 헬퍼 메서드들 ============
  // 사용하지 않는 의학적 계산 메서드들 제거됨

  // ============ 헬퍼 위젯들 ============

  /// 로딩 중 효과 섹션
  Widget _buildLoadingBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernColors.softShadow(primaryColor: ModernColors.exercise),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: ModernColors.exercise,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            '"운동 효과를 분석하고 있어요..."',
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

  /// 임팩트 메트릭 위젯
  Widget _buildImpactMetric({
    required String icon,
    required String value,
    required String label,
    required String subtitle,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: ModernColors.exercise,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.notoSans(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 세로 구분선
  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: ModernColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  /// 구체적 효과 카드 (Optimized Compact Design)
  Widget _buildSpecificEffectCard({
    required String icon,
    required String title,
    required String mainEffect,
    required List<String> details,
    required double progress,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced from 16 to 12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 - Compact Design
          Row(
            children: [
              Container(
                width: 28, // Reduced from 32 to 28
                height: 28, // Reduced from 32 to 28
                decoration: BoxDecoration(
                  color: ModernColors.exercise.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(icon,
                      style: const TextStyle(
                          fontSize: 14)), // Reduced from 16 to 14
                ),
              ),
              const SizedBox(width: 8), // Reduced from 12 to 8
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        fontSize: 13, // Reduced from 14 to 13
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                        height: 1.2, // Added for compact display
                      ),
                    ),
                    const SizedBox(height: 1), // Reduced from 2 to 1
                    Text(
                      mainEffect,
                      style: GoogleFonts.notoSans(
                        fontSize: 11, // Reduced from 12 to 11
                        fontWeight: FontWeight.w600,
                        color: ModernColors.exercise,
                        height: 1.2, // Added for compact display
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10), // Reduced from 12 to 10

          // 프로그레스 바 - Compact Orange
          Container(
            height: 4, // Reduced from 6 to 4
            decoration: BoxDecoration(
              color: ModernColors.border,
              borderRadius: BorderRadius.circular(2), // Reduced from 3 to 2
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: ModernColors.exercise,
                  borderRadius: BorderRadius.circular(2), // Reduced from 3 to 2
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: (200 * index).ms)
        .fadeIn(duration: 400.ms, delay: (200 * index).ms);
  }

  /// 간단한 "알고 계셨나요?" 섹션 - Optimized Compact Design
  Widget _buildSimpleDidYouKnowSection(int duration, int calories,
      String intensity, Map<String, dynamic> endorphinData) {
    // MET 기반 실제 계산
    final stairs = (duration * 20).toInt(); // 분당 20층 (실제 MET 계산)
    final apples = (calories / 95).toStringAsFixed(1); // 중간 사과 1개 = 95kcal
    final heartBeats =
        (duration * 140 - duration * 70).toInt(); // 운동시 평균 140bpm - 안정시 70bpm

    return Container(
      padding: const EdgeInsets.all(10), // Reduced padding for compact design
      decoration: BoxDecoration(
        color:
            ModernColors.exercise.withOpacity(0.02), // Very subtle background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.exercise.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact title with smaller font
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text('💡',
                    style: const TextStyle(fontSize: 12)), // Smaller icon
                const SizedBox(width: 6),
                Text(
                  '재미있는 사실',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.exercise,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Compact facts with better spacing
          _buildCompactFact('🏃', '${duration}분 = 계단 ${stairs}층'),
          const SizedBox(height: 6), // Tighter spacing
          _buildCompactFact('🍎', '${calories}kcal = 사과 ${apples}개'),
          const SizedBox(height: 6), // Tighter spacing
          _buildCompactFact('💓', '심장박동 = ${heartBeats}회 증가'),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 600.ms)
        .fadeIn(duration: 400.ms, delay: 600.ms);
  }

  /// Compact fact item helper
  Widget _buildCompactFact(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)), // Compact emoji
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 12, // Reduced from 14 to 12 for secondary info
              fontWeight: FontWeight.w500, // Reduced from w600 to w500
              color:
                  ModernColors.textSecondary, // Changed to secondary text color
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  /// 미니 차트 위젯
  Widget _buildMiniChart() {
    final todayCalories = widget.todayData!['calories'] as int? ?? 0;
    final prevCalories = widget.previousData!['calories'] as int? ?? 0;
    final diff = todayCalories - prevCalories;
    final isIncrease = diff >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isIncrease ? Icons.trending_up : Icons.trending_down,
            color:
                isIncrease ? ModernColors.exercise : ModernColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '${isIncrease ? '+' : ''}$diff kcal',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isIncrease
                  ? ModernColors.exercise
                  : ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Bullet point 위젯
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 10),
            decoration: BoxDecoration(
              color: ModernColors.exercise,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 효과 카드 위젯
  Widget _buildEffectCard(String text, int index) {
    final icons = [
      Icons.favorite_rounded,
      Icons.flash_on_rounded,
      Icons.trending_up_rounded,
      Icons.psychology_rounded,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ModernColors.exerciseLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icons[index % icons.length],
              color: ModernColors.exercise,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: (100 * index).ms)
        .fadeIn(duration: 400.ms, delay: (100 * index).ms);
  }

  /// 추천 카드 위젯
  Widget _buildRecommendationCard(String text, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: index < 2 ? 12 : 0), // 마지막 카드는 margin 없음
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ModernColors.surfaceElevated, // 연한 회색 배경
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 번호 뱃지 - 더 심플하고 작게
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ModernColors.exercise.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.exercise,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 14, // 가독성 향상
                fontWeight: FontWeight.w500,
                color: ModernColors.textPrimary, // 더 진한 색상으로 가독성 향상
                height: 1.4,
                letterSpacing: -0.2, // 약간 타이트한 자간
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideX(begin: 0.05, end: 0, duration: 300.ms, delay: (80 * index).ms)
        .fadeIn(duration: 300.ms, delay: (80 * index).ms);
  }

  /// 동기부여 배지 위젯
  Widget _buildMotivationBadge(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ModernColors.exercise,
            ),
          ),
        ],
      ),
    );
  }

  /// 텍스트를 포인트로 분리하는 헬퍼 메서드
  List<String> _splitIntoPoints(String text) {
    // 셰르피 대화체 따옴표 제거
    final cleanText = text.replaceAll('"', '');

    // 문장 단위로 분리 (. ! ? 기준)
    final sentences = cleanText.split(RegExp(r'[.!?]\s*'));

    // 빈 문자열 제거하고 3-4개씩 그룹화
    final filtered = sentences.where((s) => s.trim().isNotEmpty).toList();

    if (filtered.length <= 2) {
      // 짧은 텍스트는 그대로 반환
      return [cleanText];
    }

    // 긴 텍스트는 2-3개 포인트로 분리
    final points = <String>[];
    for (int i = 0; i < filtered.length; i += 2) {
      final end = (i + 2 > filtered.length) ? filtered.length : i + 2;
      points.add(filtered.sublist(i, end).join('. '));
    }

    return points.take(3).toList(); // 최대 3개 포인트
  }

  /// 기본 비교 메시지 (셰르피 대화체)
  String _getDefaultComparisonMessage() {
    if (widget.previousData == null) {
      return '"와! 첫 운동이네요! 🎉\n정말 대단해요! 이제부터 함께 건강한 몸을 만들어가요! 저 셰르피가 열심히 응원할게요!"';
    }
    return '"잠시만요... 데이터를 비교하고 있어요..."';
  }

  /// 데이터 없음 상태
  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 셰르피 이미지 (애니메이션 추가)
          Image.asset(
            SherpiEmotion.thinking.imagePath,
            width: 120,
            height: 120,
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .scale(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
              ),

          const SizedBox(height: 24),

          Text(
            '아직 운동 기록이 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '운동을 하고 기록을 남겨보세요.\n셰르피가 함께 운동 여정을 분석해드릴게요!',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 말풍선 꼬리 페인터
class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _BubbleTailPainter({
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(size.width / 2 - 8, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width / 2 + 8, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 운동 패턴 페인터 (배경 장식)
class ExercisePatternPainter extends CustomPainter {
  final Color color;

  ExercisePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 운동 관련 패턴 그리기 (덤벨 모양)
    const dumbbellWidth = 35.0;
    const dumbbellHeight = 15.0;
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += dumbbellWidth + spacing) {
      for (double y = 0; y < size.height; y += dumbbellHeight + spacing) {
        final centerX = x + (y.toInt() % 2 == 0 ? 0 : dumbbellWidth / 2);
        final centerY = y + dumbbellHeight / 2;

        // 덤벨 그리기
        _drawDumbbell(
            canvas, paint, centerX, centerY, dumbbellWidth, dumbbellHeight);
      }
    }
  }

  void _drawDumbbell(Canvas canvas, Paint paint, double centerX, double centerY,
      double width, double height) {
    // 덤벨 바 (중앙 막대)
    final barRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width * 0.6,
      height: height * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
      paint,
    );

    // 왼쪽 웨이트
    final leftWeight = Rect.fromCenter(
      center: Offset(centerX - width * 0.25, centerY),
      width: width * 0.2,
      height: height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftWeight, const Radius.circular(3)),
      paint,
    );

    // 오른쪽 웨이트
    final rightWeight = Rect.fromCenter(
      center: Offset(centerX + width * 0.25, centerY),
      width: width * 0.2,
      height: height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightWeight, const Radius.circular(3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
