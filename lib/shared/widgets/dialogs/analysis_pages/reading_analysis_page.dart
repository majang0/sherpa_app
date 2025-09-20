import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../providers/global_user_provider.dart';
import '../../../models/global_user_model.dart';
import '../../../../core/constants/sherpi_emotions.dart';
import 'package:sherpa_app/core/ai/services/activity_analysis_service.dart';

/// 📖 독서 분석 페이지 - 감성적인 독서 여정
///
/// StoryGraph와 같은 무드 기반 독서 경험을 제공합니다.
/// 셰르피가 함께하는 감성적인 독서 여정을 구현합니다.
class ReadingAnalysisPage extends ConsumerStatefulWidget {
  const ReadingAnalysisPage({super.key});

  @override
  ConsumerState<ReadingAnalysisPage> createState() =>
      _ReadingAnalysisPageState();
}

class _ReadingAnalysisPageState extends ConsumerState<ReadingAnalysisPage>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러들
  late AnimationController _pageAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _heartbeatController;
  late AnimationController _shimmerController;

  // 애니메이션들
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _heartbeatAnimation;

  // AI 분석 서비스
  final ActivityAnalysisService _analysisService =
      ActivityAnalysisService.instance;

  // 종합 독서 분석 데이터
  ComprehensiveReadingAnalysis? _readingAnalysis;
  bool _isLoadingAnalysis = false;

  // 오늘과 이전 독서 기록
  ReadingLog? _todayReading;
  ReadingLog? _previousReading;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadReadingData();
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

    // 애니메이션 곡선 설정
    _fadeInAnimation = CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.elasticOut,
    ));

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

    // 페이지 애니메이션 시작
    _pageAnimationController.forward();
  }

  /// 독서 데이터 로드
  void _loadReadingData() {
    final user = ref.read(globalUserProvider);
    if (user.dailyRecords.readingLogs.isEmpty) return;

    final readingLogs = user.dailyRecords.readingLogs;

    if (readingLogs.isNotEmpty) {
      // 날짜순 정렬 (최신순)
      final sortedLogs = List<ReadingLog>.from(readingLogs)
        ..sort((a, b) => b.date.compareTo(a.date));

      // 오늘 기록 찾기
      final today = DateTime.now();
      _todayReading = sortedLogs.firstWhere(
        (log) => _isSameDay(log.date, today),
        orElse: () => sortedLogs.first, // 오늘 기록이 없으면 가장 최근 기록
      );

      // 이전 기록 찾기
      if (sortedLogs.length > 1) {
        _previousReading = sortedLogs.firstWhere(
          (log) => log.id != _todayReading?.id,
          orElse: () => sortedLogs[1],
        );
      }
    }
  }

  /// 같은 날짜인지 확인
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 캐시된 분석 데이터 로드
  Future<void> _loadCachedAnalysis() async {
    setState(() {
      _isLoadingAnalysis = true;
    });

    try {
      // ActivityAnalysisService에서 캐시된 독서 분석 로드
      final cachedAnalysis =
          await _analysisService.getComprehensiveReadingFromCache();

      if (cachedAnalysis != null) {
        setState(() {
          _readingAnalysis = cachedAnalysis;
          _isLoadingAnalysis = false;
        });
      } else {
        // 캐시가 없으면 기본 메시지 사용 (보통 발생하지 않음 - 독서 완료 시 이미 생성됨)
        debugPrint('⚠️ 독서 분석 캐시 없음 - 기본 메시지 사용');
        setState(() {
          _isLoadingAnalysis = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 독서 분석 캐시 로드 실패: $e');
      setState(() {
        _isLoadingAnalysis = false;
      });
    }
  }

  // AI 분석 생성 메서드 제거됨 - 이제 GlobalUserNotifier에서 중앙 처리

  // _saveCachedAnalysis 메서드 제거 - ActivityAnalysisService가 자체적으로 캐싱 처리

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _floatingAnimationController.dispose();
    _heartbeatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      body:
          _todayReading == null ? _buildEmptyState() : _buildAnalysisContent(),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 셰르피 이미지
          Image.asset(
            'assets/images/sherpi/sherpi_thinking.png',
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
            '아직 독서 기록이 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '책을 읽고 기록을 남겨보세요.\n셰르피가 함께 독서 여정을 분석해드릴게요!',
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

  /// 분석 콘텐츠
  Widget _buildAnalysisContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 헤더
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),

        // 이전 책 섹션 (있는 경우)
        if (_previousReading != null)
          SliverToBoxAdapter(
            child: _buildPreviousBookSection(),
          ),

        // 오늘 책 섹션
        SliverToBoxAdapter(
          child: _buildTodayBookSection(),
        ),

        // 독서 여정 응원 섹션
        SliverToBoxAdapter(
          child: _buildJourneyEncouragementSection(),
        ),

        // 추천 도서 섹션
        SliverToBoxAdapter(
          child: _buildRecommendationsSection(),
        ),

        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
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
            ModernColors.reading.withValues(alpha: 0.2),
            ModernColors.reading.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(
            child: CustomPaint(
              painter: BookPatternPainter(
                color: ModernColors.reading.withValues(alpha: 0.1),
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
                                SherpiEmotion.happy.imagePath,
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
                                '독서 여정 분석',
                                style: GoogleFonts.notoSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: ModernColors.reading,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '셰르피와 함께하는 독서 이야기',
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

  /// 이전 책 섹션
  Widget _buildPreviousBookSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              width: 1,
              color: ModernColors.mintPale.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 섹션 헤더
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ModernColors.mintPale,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '📖',
                          style: GoogleFonts.notoSans(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '지난 독서',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 책 정보
                _buildBookInfo(_previousReading!),

                const SizedBox(height: 16),

                // 셰르피 인사이트
                if (_readingAnalysis?.previousInsight != null)
                  _buildSherpiInsight(_readingAnalysis!.previousInsight),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 300))
        .slideY(begin: 0.1, end: 0);
  }

  /// 오늘 책 섹션
  Widget _buildTodayBookSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: 1.5,
            color: ModernColors.deepMintSoft.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: ModernColors.deepMintSoft.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ModernColors.deepMintLight.withValues(alpha: 0.8),
                        ModernColors.deepMint.withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.deepMint.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '📚',
                      style: GoogleFonts.notoSans(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 독서',
                      style: GoogleFonts.notoSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '✨ 특별한 순간',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.deepMint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 책 정보 (더 크고 강조)
            _buildBookInfo(_todayReading!, isToday: true),

            const SizedBox(height: 20),

            // 셰르피 인사이트
            if (_readingAnalysis?.todayInsight != null)
              _buildSherpiInsight(
                _readingAnalysis!.todayInsight,
                isSpecial: true,
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 600))
        .slideY(begin: 0.1, end: 0);
  }

  /// 독서 여정 응원 섹션
  Widget _buildJourneyEncouragementSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: ModernColors.getElevationShadow(1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 셰르피 애니메이션
              AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_floatingAnimation.value * 0.5,
                        _floatingAnimation.value),
                    child: Image.asset(
                      SherpiEmotion.cheering.imagePath,
                      width: 108,
                      height: 108,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 응원 메시지
              if (_readingAnalysis?.journeyEncouragement != null)
                Text(
                  _readingAnalysis!.journeyEncouragement,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    color: ModernColors.textPrimary,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 800))
                    .scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: 24),

              // 독서 통계 미니 카드들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMiniStatCard(
                    icon: '📚',
                    label: '읽은 책',
                    value: '${_calculateUniqueBooks()}권',
                  ),
                  _buildMiniStatCard(
                    icon: '📖',
                    label: '총 페이지',
                    value: '${_calculateTotalPages()}쪽',
                  ),
                  _buildMiniStatCard(
                    icon: '⭐',
                    label: '평균 평점',
                    value: _calculateAverageRating(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 900))
        .slideY(begin: 0.1, end: 0);
  }

  /// 추천 도서 섹션
  Widget _buildRecommendationsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ModernColors.reading,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '셰르피의 추천 도서',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 추천 도서 카드들
          if (_readingAnalysis?.recommendations == null && _isLoadingAnalysis)
            _buildLoadingRecommendations()
          else if (_readingAnalysis?.recommendations != null &&
              _readingAnalysis!.recommendations.isNotEmpty)
            ..._readingAnalysis!.recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final book = entry.value;
              return _buildRecommendationCard(book, index);
            })
          else
            _buildDefaultRecommendations(),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 1200))
        .slideY(begin: 0.1, end: 0);
  }

  /// 책 정보 위젯
  Widget _buildBookInfo(ReadingLog book, {bool isToday = false}) {
    return Container(
      padding: EdgeInsets.all(isToday ? 14 : 12),
      decoration: BoxDecoration(
        color: isToday
            ? Colors.white
            : ModernColors.mintPale.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isToday ? 14 : 12),
        border: Border.all(
          color: isToday
              ? ModernColors.deepMintSoft.withValues(alpha: 0.3)
              : ModernColors.mintPale.withValues(alpha: 0.2),
          width: isToday ? 1 : 0.5,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: ModernColors.deepMintLight.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 제목과 저자
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 책 아이콘
              Container(
                width: isToday ? 60 : 50,
                height: isToday ? 80 : 70,
                decoration: BoxDecoration(
                  gradient: isToday
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ModernColors.deepMintSoft.withValues(alpha: 0.4),
                            ModernColors.deepMintLight.withValues(alpha: 0.3),
                          ],
                        )
                      : null,
                  color: !isToday
                      ? ModernColors.reading.withValues(alpha: 0.08)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday
                      ? Border.all(
                          color: ModernColors.deepMint.withValues(alpha: 0.1),
                          width: 1,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    book.categoryEmoji,
                    style: TextStyle(fontSize: isToday ? 28 : 24),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.bookTitle,
                      style: GoogleFonts.notoSans(
                        fontSize: isToday ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // 카테고리 태그
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      ModernColors.deepMintLight
                                          .withValues(alpha: 0.8),
                                      ModernColors.deepMint
                                          .withValues(alpha: 0.9),
                                    ],
                                  )
                                : null,
                            color: !isToday
                                ? ModernColors.reading.withValues(alpha: 0.1)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            book.category,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color:
                                  isToday ? Colors.white : ModernColors.reading,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 페이지 수
                        Text(
                          '${book.pages}쪽',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 평점 (있는 경우)
          if (book.rating != null && book.rating! > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                ...List.generate(5, (index) {
                  final filled = index < book.rating!.round();
                  return Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: ModernColors.warning,
                    size: isToday ? 22 : 18,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  book.rating!.toStringAsFixed(1),
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 셰르피 인사이트 위젯
  Widget _buildSherpiInsight(String message, {bool isSpecial = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isSpecial
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ModernColors.deepMintSoft.withValues(alpha: 0.08),
                  ModernColors.deepMintLight.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: !isSpecial ? ModernColors.gray50 : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSpecial
              ? ModernColors.deepMint.withValues(alpha: 0.12)
              : ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Text(
          message,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: isSpecial
                ? ModernColors.textPrimary
                : ModernColors.textSecondary,
            height: 1.6,
            fontWeight: isSpecial ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 미니 통계 카드
  Widget _buildMiniStatCard({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ModernColors.reading.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().scale(
          delay: Duration(milliseconds: 1000 + (100 * icon.length)),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
        );
  }

  /// 추천 도서 카드
  Widget _buildRecommendationCard(BookRecommendation book, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ModernColors.reading.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 번호 뱃지
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: ModernColors.reading,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 책 제목과 저자
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                      ),
                      // 무드 태그
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ModernColors.reading.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.mood,
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            color: ModernColors.reading,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 추천 이유
                  Text(
                    book.reason,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: ModernColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 1400 + (index * 200)),
          duration: const Duration(milliseconds: 600),
        )
        .slideX(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: 1400 + (index * 200)),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
  }

  /// 로딩 중 추천 도서
  Widget _buildLoadingRecommendations() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 100,
          decoration: BoxDecoration(
            color: ModernColors.gray100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: ModernColors.gray100,
                ),
              );
            },
          ),
        );
      }),
    );
  }

  /// 기본 추천 도서 (로딩 실패 시)
  Widget _buildDefaultRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.reading.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: ModernColors.reading,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '독서 기록을 더 쌓으면 맞춤형 추천을 받을 수 있어요!',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: ModernColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 총 페이지 계산
  int _calculateTotalPages() {
    final logs = ref.watch(globalUserProvider).dailyRecords.readingLogs;
    return logs.fold(0, (sum, log) => sum + log.pages);
  }

  /// 중복 제거된 책 수 계산
  int _calculateUniqueBooks() {
    final logs = ref.watch(globalUserProvider).dailyRecords.readingLogs;
    final uniqueBookTitles = <String>{};

    for (final log in logs) {
      if (log.bookTitle.isNotEmpty) {
        uniqueBookTitles.add(log.bookTitle);
      }
    }

    return uniqueBookTitles.length;
  }

  /// 평균 평점 계산
  String _calculateAverageRating() {
    final logs = ref.watch(globalUserProvider).dailyRecords.readingLogs;
    final ratedLogs =
        logs.where((log) => log.rating != null && log.rating! > 0).toList();

    if (ratedLogs.isEmpty) return '0.0';

    final sum = ratedLogs.fold(0.0, (sum, log) => sum + log.rating!);
    final average = sum / ratedLogs.length;

    return average.toStringAsFixed(1);
  }
}

/// 책 추천 모델
// BookRecommendation 클래스는 ActivityAnalysisService에서 import됨

/// 책 패턴 페인터 (배경 장식)
class BookPatternPainter extends CustomPainter {
  final Color color;

  BookPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 책 모양 패턴 그리기
    const bookWidth = 30.0;
    const bookHeight = 40.0;
    const spacing = 15.0;

    for (double x = 0; x < size.width; x += bookWidth + spacing) {
      for (double y = 0; y < size.height; y += bookHeight + spacing) {
        // 책 직사각형
        final rect = Rect.fromLTWH(
          x + (y.toInt() % 2 == 0 ? 0 : bookWidth / 2),
          y,
          bookWidth,
          bookHeight,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );

        // 책등 라인
        canvas.drawLine(
          Offset(rect.left + 5, rect.top),
          Offset(rect.left + 5, rect.bottom),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
