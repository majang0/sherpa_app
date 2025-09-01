import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/sherpi_emotions.dart';
import '../../../../core/ai/smart_sherpi_manager_openai.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

/// 📖 독서 분석 페이지 - 감성적인 독서 여정
/// 
/// StoryGraph와 같은 무드 기반 독서 경험을 제공합니다.
/// 셰르피가 함께하는 감성적인 독서 여정을 구현합니다.
class ReadingAnalysisPage extends ConsumerStatefulWidget {
  const ReadingAnalysisPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReadingAnalysisPage> createState() => _ReadingAnalysisPageState();
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
  
  // AI 매니저
  final SmartSherpiManager _sherpiManager = SmartSherpiManager();
  
  // 캐시된 AI 응답들
  Map<String, String> _cachedResponses = {};
  bool _isLoadingAnalysis = false;
  
  // 오늘과 이전 독서 기록
  ReadingLog? _todayReading;
  ReadingLog? _previousReading;
  
  // 추천 도서 목록
  List<BookRecommendation> _bookRecommendations = [];
  
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
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('reading_analysis_cache');
    
    if (cachedData != null) {
      try {
        final decoded = json.decode(cachedData) as Map<String, dynamic>;
        _cachedResponses = Map<String, String>.from(decoded);
        
        // 캐시된 추천 도서 로드
        final recommendationsData = prefs.getString('book_recommendations_cache');
        if (recommendationsData != null) {
          final recommendationsList = json.decode(recommendationsData) as List;
          _bookRecommendations = recommendationsList
              .map((data) => BookRecommendation.fromJson(data))
              .toList();
        }
        
        if (mounted) setState(() {});
      } catch (e) {
        print('캐시 로드 실패: $e');
      }
    }
    
    // 캐시가 없거나 오래된 경우 새로 생성
    if (_cachedResponses.isEmpty && _todayReading != null) {
      _generateAnalysis();
    }
  }
  
  /// AI 분석 생성
  Future<void> _generateAnalysis() async {
    if (_isLoadingAnalysis || _todayReading == null) return;
    
    setState(() {
      _isLoadingAnalysis = true;
    });
    
    try {
      // 1. 이전 책 분석
      if (_previousReading != null) {
        final previousContext = {
          'bookTitle': _previousReading!.bookTitle,
          'author': _previousReading!.author,
          'category': _previousReading!.category,
          'pages': _previousReading!.pages,
          'rating': _previousReading!.rating ?? 0,
        };
        
        final previousResponse = await _sherpiManager.getMessageWithAI(
          SherpiContext.readingComplete,
          previousContext,
          {'section': 'previous_book_insight'},
        );
        
        _cachedResponses['previous_insight'] = previousResponse.message;
      }
      
      // 2. 오늘 책 분석
      final todayContext = {
        'bookTitle': _todayReading!.bookTitle,
        'author': _todayReading!.author,
        'category': _todayReading!.category,
        'pages': _todayReading!.pages,
        'rating': _todayReading!.rating ?? 0,
      };
      
      final todayResponse = await _sherpiManager.getMessageWithAI(
        SherpiContext.readingComplete,
        todayContext,
        {'section': 'today_book_insight'},
      );
      
      _cachedResponses['today_insight'] = todayResponse.message;
      
      // 3. 독서 여정 응원
      final journeyContext = {
        'previousBook': _previousReading?.bookTitle ?? '없음',
        'previousCategory': _previousReading?.category ?? '없음',
        'previousRating': _previousReading?.rating ?? 0,
        'todayBook': _todayReading!.bookTitle,
        'todayCategory': _todayReading!.category,
        'todayRating': _todayReading!.rating ?? 0,
      };
      
      final journeyResponse = await _sherpiManager.getMessageWithAI(
        SherpiContext.encouragement,
        journeyContext,
        {'section': 'reading_journey_encouragement'},
      );
      
      _cachedResponses['journey_encouragement'] = journeyResponse.message;
      
      // 4. 책 추천 생성
      await _generateBookRecommendations();
      
      // 캐시 저장
      await _saveCachedAnalysis();
      
    } catch (e) {
      print('분석 생성 실패: $e');
      // 실패 시 기본 메시지 사용
      _useDefaultMessages();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAnalysis = false;
        });
      }
    }
  }
  
  /// 책 추천 생성
  Future<void> _generateBookRecommendations() async {
    final recommendationContext = {
      'previousBook': _previousReading?.bookTitle ?? '없음',
      'previousCategory': _previousReading?.category ?? '없음',
      'todayBook': _todayReading!.bookTitle,
      'todayCategory': _todayReading!.category,
      'userPreferences': {
        'likedCategories': [_todayReading!.category, _previousReading?.category].where((c) => c != null).toList(),
        'averageRating': ((_todayReading!.rating ?? 4.0) + (_previousReading?.rating ?? 4.0)) / 2,
      },
    };
    
    final recommendationResponse = await _sherpiManager.getMessageWithAI(
      SherpiContext.questComplete,
      recommendationContext,
      {'section': 'book_recommendations', 'count': 3},
    );
    
    // AI 응답을 파싱하여 추천 도서 목록 생성
    _bookRecommendations = _parseBookRecommendations(recommendationResponse.message);
  }
  
  /// AI 응답에서 추천 도서 파싱
  List<BookRecommendation> _parseBookRecommendations(String aiResponse) {
    // 간단한 파싱 로직 (실제로는 더 정교한 파싱 필요)
    final recommendations = <BookRecommendation>[];
    
    // 기본 추천 도서 (AI 응답 파싱 실패 시 사용)
    final defaultRecommendations = [
      BookRecommendation(
        title: '아몬드',
        author: '손원평',
        reason: '감성적인 성장 이야기로 당신의 독서 취향과 잘 맞습니다.',
        category: '소설',
        mood: '따뜻한',
      ),
      BookRecommendation(
        title: '미드나잇 라이브러리',
        author: '매트 헤이그',
        reason: '인생의 다양한 가능성을 탐구하는 흥미로운 이야기입니다.',
        category: '소설',
        mood: '사색적인',
      ),
      BookRecommendation(
        title: '불편한 편의점',
        author: '김호연',
        reason: '일상 속 작은 기적을 발견하는 따뜻한 이야기입니다.',
        category: '소설',
        mood: '희망적인',
      ),
    ];
    
    // AI 응답이 유효하면 파싱, 아니면 기본값 사용
    if (aiResponse.isNotEmpty) {
      // TODO: AI 응답 파싱 로직 구현
      return defaultRecommendations;
    }
    
    return defaultRecommendations;
  }
  
  /// 기본 메시지 사용 (AI 실패 시)
  void _useDefaultMessages() {
    _cachedResponses = {
      'previous_insight': '지난번 독서 시간이 참 의미 있었네요. 📚',
      'today_insight': '오늘도 책과 함께한 시간이 소중했어요! ✨',
      'journey_encouragement': '꾸준히 독서하는 모습이 정말 멋져요. 앞으로도 함께 책의 세계를 탐험해요! 🌟',
    };
  }
  
  /// 캐시 저장
  Future<void> _saveCachedAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reading_analysis_cache', json.encode(_cachedResponses));
    
    // 추천 도서도 저장
    final recommendationsData = _bookRecommendations.map((r) => r.toJson()).toList();
    await prefs.setString('book_recommendations_cache', json.encode(recommendationsData));
    
    // 캐시 타임스탬프 저장
    await prefs.setInt('reading_analysis_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
  
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
      body: _todayReading == null
          ? _buildEmptyState()
          : _buildAnalysisContent(),
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
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).scale(
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
      height: 200,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뒤로가기 버튼
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: ModernColors.reading,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  
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
                                width: 60,
                                height: 60,
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
                                '셰르피와 함께하는 감성적인 독서 이야기',
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ModernColors.reading.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      ModernColors.reading.withValues(alpha: 0.05),
                    ],
                  ),
                ),
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
                            color: ModernColors.reading.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '📖',
                              style: GoogleFonts.notoSans(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '지난 독서',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 책 정보
                    _buildBookInfo(_previousReading!),
                    
                    const SizedBox(height: 16),
                    
                    // 셰르피 인사이트
                    if (_cachedResponses['previous_insight'] != null)
                      _buildSherpiInsight(_cachedResponses['previous_insight']!),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 300))
      .slideY(begin: 0.1, end: 0);
  }
  
  /// 오늘 책 섹션
  Widget _buildTodayBookSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _heartbeatAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _heartbeatAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ModernColors.reading.withValues(alpha: 0.15),
                    ModernColors.reading.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ModernColors.reading.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.reading.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 섹션 헤더
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ModernColors.reading,
                                    ModernColors.reading.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '📚',
                                  style: GoogleFonts.notoSans(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '오늘의 독서',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: ModernColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '✨ 특별한 순간',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 12,
                                    color: ModernColors.reading,
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
                        if (_cachedResponses['today_insight'] != null)
                          _buildSherpiInsight(
                            _cachedResponses['today_insight']!,
                            isSpecial: true,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 600))
      .slideY(begin: 0.1, end: 0);
  }
  
  /// 독서 여정 응원 섹션
  Widget _buildJourneyEncouragementSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              ModernColors.reading.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ModernColors.reading.withValues(alpha: 0.1),
            width: 1,
          ),
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
                    offset: Offset(_floatingAnimation.value * 0.5, _floatingAnimation.value),
                    child: Image.asset(
                      SherpiEmotion.cheering.imagePath,
                      width: 80,
                      height: 80,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // 응원 메시지
              if (_cachedResponses['journey_encouragement'] != null)
                Text(
                  _cachedResponses['journey_encouragement']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: ModernColors.textPrimary,
                    height: 1.6,
                  ),
                ).animate()
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
                    value: '${ref.watch(globalUserProvider).dailyRecords.readingLogs.length}권',
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
    ).animate()
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
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.reading,
                      ModernColors.accent,
                    ],
                  ),
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
          if (_bookRecommendations.isEmpty && _isLoadingAnalysis)
            _buildLoadingRecommendations()
          else if (_bookRecommendations.isNotEmpty)
            ..._bookRecommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final book = entry.value;
              return _buildRecommendationCard(book, index);
            }).toList()
          else
            _buildDefaultRecommendations(),
        ],
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 1200))
      .slideY(begin: 0.1, end: 0);
  }
  
  /// 책 정보 위젯
  Widget _buildBookInfo(ReadingLog book, {bool isToday = false}) {
    return Container(
      padding: EdgeInsets.all(isToday ? 20 : 16),
      decoration: BoxDecoration(
        color: isToday 
            ? ModernColors.reading.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? ModernColors.reading.withValues(alpha: 0.2)
              : ModernColors.borderLight,
          width: 1,
        ),
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ModernColors.reading.withValues(alpha: 0.3),
                      ModernColors.reading.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ModernColors.reading.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.category,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: ModernColors.reading,
                              fontWeight: FontWeight.w500,
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
                  '${book.rating!.toStringAsFixed(1)}',
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSpecial
              ? [
                  ModernColors.reading.withValues(alpha: 0.05),
                  Colors.white,
                ]
              : [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSpecial
              ? ModernColors.reading.withValues(alpha: 0.2)
              : ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 셰르피 미니 아이콘
          Image.asset(
            SherpiEmotion.happy.imagePath,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
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
    ).animate()
      .scale(
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            ModernColors.reading.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.reading.withValues(alpha: 0.1),
          width: 1,
        ),
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.reading,
                    ModernColors.accent,
                  ],
                ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    ).animate()
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
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ModernColors.gray100,
                      ModernColors.gray200,
                      ModernColors.gray100,
                    ],
                    stops: [
                      0.0,
                      _shimmerController.value,
                      1.0,
                    ],
                  ),
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
          Icon(
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
  
  /// 평균 평점 계산
  String _calculateAverageRating() {
    final logs = ref.watch(globalUserProvider).dailyRecords.readingLogs;
    final ratedLogs = logs.where((log) => log.rating != null && log.rating! > 0).toList();
    
    if (ratedLogs.isEmpty) return '0.0';
    
    final sum = ratedLogs.fold(0.0, (sum, log) => sum + log.rating!);
    final average = sum / ratedLogs.length;
    
    return average.toStringAsFixed(1);
  }
}

/// 책 추천 모델
class BookRecommendation {
  final String title;
  final String author;
  final String reason;
  final String category;
  final String mood;
  
  BookRecommendation({
    required this.title,
    required this.author,
    required this.reason,
    required this.category,
    required this.mood,
  });
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'reason': reason,
    'category': category,
    'mood': mood,
  };
  
  factory BookRecommendation.fromJson(Map<String, dynamic> json) => BookRecommendation(
    title: json['title'] ?? '',
    author: json['author'] ?? '',
    reason: json['reason'] ?? '',
    category: json['category'] ?? '',
    mood: json['mood'] ?? '',
  );
}

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