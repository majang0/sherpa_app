import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/ai/activity_analysis_service.dart';

/// 운동 분석 페이지 - 시각적 배지와 AI 기반 인사이트 (주황색 테마)
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
  final ActivityAnalysisService _analysisService = ActivityAnalysisService.instance;
  ComprehensiveExerciseAnalysis? _analysisData;
  bool _isLoading = true;
  
  // 애니메이션 컨트롤러
  late AnimationController _badgeAnimationController;
  late AnimationController _pulseController;
  late AnimationController _cardAnimationController;
  
  // 섹션별 확장 상태
  final Map<String, bool> _expandedSections = {};
  
  // 주황색 테마 색상
  static const Color exerciseOrange = Color(0xFFFF6B35);  // 생동감 넘치는 오렌지
  static const Color exerciseOrangeLight = Color(0xFFFFF3E0);  // 연한 오렌지 배경
  static const Color exerciseOrangeMedium = Color(0xFFFFB74D);  // 중간 오렌지
  static const Color exerciseOrangeDark = Color(0xFFFF5722);  // 진한 오렌지
  
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
      final cachedAnalysis = await _analysisService.getComprehensiveExerciseFromCache();
      
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
    super.dispose();
  }
  
  // 운동 타입에 따른 이모지 반환
  String _getExerciseEmoji(String? type) {
    if (type == null) return '🏃';
    
    final typeMap = {
      '달리기': '🏃',
      '런닝': '🏃',
      '조깅': '🏃',
      '걷기': '🚶',
      '산책': '🚶',
      '자전거': '🚴',
      '사이클': '🚴',
      '수영': '🏊',
      '요가': '🧘',
      '필라테스': '🧘',
      '헬스': '💪',
      '웨이트': '💪',
      '근력운동': '💪',
      '축구': '⚽',
      '농구': '🏀',
      '배구': '🏐',
      '테니스': '🎾',
      '배드민턴': '🏸',
      '등산': '⛰️',
      '댄스': '💃',
      '춤': '💃',
      '격투기': '🥊',
      '복싱': '🥊',
      '기타': '🎯',
    };
    
    // 키워드 매칭
    for (final entry in typeMap.entries) {
      if (type.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return '🏃'; // 기본값
  }
  
  // 강도에 따른 색상 반환 (주황색 테마)
  Color _getIntensityColor(String? intensity) {
    switch (intensity) {
      case '낮음':
        return const Color(0xFFFFD54F);  // 연한 노란 오렌지
      case '중간':
        return exerciseOrangeMedium;
      case '높음':
        return exerciseOrange;
      case '매우 높음':
        return exerciseOrangeDark;
      default:
        return exerciseOrangeMedium;
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
      return _buildNoDataState();
    }
    
    return SingleChildScrollView(
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
          
          const SizedBox(height: 20),
        ],
      ),
    );
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
                gradient: isToday 
                    ? LinearGradient(
                        colors: [
                          exerciseOrange,
                          exerciseOrangeMedium,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          ModernColors.textTertiary.withOpacity(0.2),
                          ModernColors.textTertiary.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isToday 
                        ? exerciseOrange.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
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
                          color: isToday ? Colors.white : ModernColors.textPrimary,
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
    ).animate()
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
          color: isToday 
              ? Colors.white.withOpacity(0.3)
              : ModernColors.border,
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
          color: isToday 
              ? Colors.white.withOpacity(0.3)
              : ModernColors.border,
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
          style: const TextStyle(fontSize: 35),  // 50 -> 35로 줄임
        ),
        
        const SizedBox(height: 8),  // 12 -> 8로 줄임
        
        // 칼로리
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$calories',
              style: GoogleFonts.notoSans(
                fontSize: 28,  // 40 -> 28로 줄임
                fontWeight: FontWeight.w700,
                color: isToday ? Colors.white : ModernColors.textPrimary,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 3),  // bottom: 6 -> 4로 조정
              child: Text(
                'kcal',
                style: GoogleFonts.notoSans(
                  fontSize: 14,  // 16 -> 14로 줄임
                  fontWeight: FontWeight.w500,
                  color: isToday 
                      ? Colors.white.withOpacity(0.8)
                      : ModernColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 2),  // 4 -> 2로 줄임
        
        Text(
          '소모 칼로리',
          style: GoogleFonts.notoSans(
            fontSize: 11,  // 12 -> 11로 줄임
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
  
  /// 현대적인 비교 분석 섹션 (개선된 디자인)
  Widget _buildModernComparisonSection() {
    final content = _isLoading 
        ? '분석 중...'
        : (_analysisData?.comparison ?? _getDefaultComparisonMessage());
    
    // 텍스트를 bullet points로 분리
    final points = _splitIntoPoints(content);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: exerciseOrange.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  exerciseOrangeLight.withOpacity(0.8),
                  exerciseOrangeLight.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // 아이콘 컨테이너
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: exerciseOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.compare_arrows_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // 타이틀
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '지난번과 비교',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '운동 성과 분석',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: exerciseOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                // 비교 데이터가 있으면 차트 표시
                if (widget.previousData != null && !_isLoading)
                  _buildMiniChart(),
              ],
            ),
          ),
          
          // 컨텐츠 섹션
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: points.map((point) => _buildBulletPoint(point)).toList(),
            ),
          ),
        ],
      ),
    ).animate()
      .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 400.ms)
      .fadeIn(duration: 600.ms, delay: 400.ms);
  }
  
  /// 현대적인 효과 섹션 (개선된 디자인)
  Widget _buildModernBenefitsSection() {
    final content = _isLoading 
        ? '분석 중...'
        : (_analysisData?.benefits ?? '운동의 효과를 분석하고 있어요...');
    
    final points = _splitIntoPoints(content);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            exerciseOrangeLight.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: exerciseOrange.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: exerciseOrange.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: exerciseOrangeMedium.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: exerciseOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '오늘 운동의 효과',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // 효과 리스트 (카드 스타일)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              children: points.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                return _buildEffectCard(point, index);
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate()
      .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 600.ms)
      .fadeIn(duration: 600.ms, delay: 600.ms);
  }
  
  /// 현대적인 추천 섹션 (개선된 디자인)
  Widget _buildModernRecommendationSection() {
    final content = _isLoading 
        ? '분석 중...'
        : (_analysisData?.recommendation ?? '맞춤형 추천을 준비하고 있어요...');
    
    final points = _splitIntoPoints(content);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: exerciseOrange.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  exerciseOrange.withOpacity(0.9),
                  exerciseOrangeMedium.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: exerciseOrange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '셰르피의 추천',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '맞춤형 운동 가이드',
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
          
          // 추천 카드들
          Padding(
            padding: const EdgeInsets.all(18),
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
    ).animate()
      .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 800.ms)
      .fadeIn(duration: 600.ms, delay: 800.ms);
  }
  
  /// 현대적인 응원 섹션 (개선된 디자인)
  Widget _buildModernEncouragementSection() {
    final encouragement = _isLoading 
        ? '응원 메시지를 준비하고 있어요...'
        : (_analysisData?.encouragement ?? '오늘도 정말 수고하셨어요! 💪');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            exerciseOrangeLight.withOpacity(0.5),
            Colors.white,
            exerciseOrangeLight.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: exerciseOrange.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 셰르피 아이콘 (애니메이션)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [exerciseOrange, exerciseOrangeMedium],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: exerciseOrange.withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 18),
          
          // 제목
          Text(
            '오늘도 수고하셨어요! 🌟',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: exerciseOrange,
            ),
          ),
          
          const SizedBox(height: 14),
          
          // 응원 메시지
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              encouragement,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
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
    ).animate()
      .slideY(begin: 0.1, end: 0, duration: 800.ms, delay: 1000.ms)
      .fadeIn(duration: 800.ms, delay: 1000.ms);
  }
  
  // ============ 헬퍼 위젯들 ============
  
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
            color: isIncrease ? exerciseOrange : ModernColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '${isIncrease ? '+' : ''}$diff kcal',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isIncrease ? exerciseOrange : ModernColors.textSecondary,
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
              color: exerciseOrange,
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
            color: exerciseOrange.withOpacity(0.05),
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
              color: exerciseOrangeLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icons[index % icons.length],
              color: exerciseOrange,
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
    ).animate()
      .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: (100 * index).ms)
      .fadeIn(duration: 400.ms, delay: (100 * index).ms);
  }
  
  /// 추천 카드 위젯
  Widget _buildRecommendationCard(String text, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            exerciseOrangeLight.withOpacity(0.3),
            exerciseOrangeLight.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: exerciseOrange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 번호 뱃지
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: exerciseOrange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
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
    ).animate()
      .slideX(begin: 0.1, end: 0, duration: 400.ms, delay: (100 * index).ms)
      .fadeIn(duration: 400.ms, delay: (100 * index).ms);
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
            color: exerciseOrange.withOpacity(0.1),
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
              color: exerciseOrange,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 텍스트를 포인트로 분리하는 헬퍼 메서드
  List<String> _splitIntoPoints(String text) {
    // 문장 단위로 분리 (. ! ? 기준)
    final sentences = text.split(RegExp(r'[.!?]\s*'));
    
    // 빈 문자열 제거하고 3-4개씩 그룹화
    final filtered = sentences.where((s) => s.trim().isNotEmpty).toList();
    
    if (filtered.length <= 2) {
      // 짧은 텍스트는 그대로 반환
      return [text];
    }
    
    // 긴 텍스트는 2-3개 포인트로 분리
    final points = <String>[];
    for (int i = 0; i < filtered.length; i += 2) {
      final end = (i + 2 > filtered.length) ? filtered.length : i + 2;
      points.add(filtered.sublist(i, end).join('. '));
    }
    
    return points.take(3).toList(); // 최대 3개 포인트
  }
  
  /// 기본 비교 메시지
  String _getDefaultComparisonMessage() {
    if (widget.previousData == null) {
      return '오늘이 첫 운동 기록이에요! 🎉\n훌륭한 시작입니다. 꾸준히 운동하면 건강한 몸과 마음을 만들 수 있어요.';
    }
    return '운동 데이터를 분석하고 있어요...';
  }
  
  /// 데이터 없음 상태
  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: exerciseOrangeLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: exerciseOrange,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '운동 데이터가 없습니다',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '운동을 기록해주세요',
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
}