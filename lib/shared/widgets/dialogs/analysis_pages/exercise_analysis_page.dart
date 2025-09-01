import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/ai/activity_analysis_service.dart';

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
  
  /// 비교 분석 섹션 (말풍선 스타일)
  Widget _buildModernComparisonSection() {
    final content = _isLoading 
        ? '"잠시만요... 데이터를 보고 있어요..."'
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
                        '지난번이랑 비교해볼까요?',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '셰르피가 분석해드려요',
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
  
  /// 효과 섹션 (구체적 수치와 시각화)
  Widget _buildModernBenefitsSection() {
    if (_isLoading) {
      return _buildLoadingBenefitsSection();
    }
    
    // 실제 운동 데이터 기반 효과 계산
    final todayData = widget.todayData!;
    final duration = todayData['duration'] as int? ?? 0;
    final calories = todayData['calories'] as int? ?? 0;
    final intensity = todayData['intensity'] as String? ?? '중간';
    final exerciseType = todayData['type'] as String? ?? '운동';
    
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
            color: exerciseOrange.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  exerciseOrange.withOpacity(0.1),
                  exerciseOrangeLight.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: exerciseOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎉 오! 이런 효과가?',
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '생각보다 더 대단한 변화들',
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: exerciseOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 메인 임팩트 수치
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: exerciseOrange.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildImpactMetric(
                        icon: '🔥',
                        value: '${calories}kcal',
                        label: '소모',
                        subtitle: '도넛 ${(calories / 250).toStringAsFixed(1)}개 분량!',
                      ),
                      _buildVerticalDivider(),
                      _buildImpactMetric(
                        icon: '💓',
                        value: '${duration * 2}회',
                        label: '심박수 증가',
                        subtitle: '혈액순환 UP!',
                      ),
                      _buildVerticalDivider(),
                      _buildImpactMetric(
                        icon: '🧠',
                        value: '${(duration * 1.5).toInt()}%',
                        label: '뇌 활성화',
                        subtitle: '집중력 향상!',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 구체적 효과 카드들
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSpecificEffectCard(
                  icon: '🫀',
                  title: '심혈관 건강',
                  mainEffect: '혈압 ${_getBloodPressureEffect(intensity)} 감소',
                  details: [
                    '혈액순환이 ${duration}% 향상되었어요',
                    '심장 근육이 더 강해졌어요',
                    '혈관 탄력성이 증가했어요'
                  ],
                  progress: _getIntensityLevel(intensity) / 4,
                  index: 0,
                ),
                
                const SizedBox(height: 12),
                
                _buildSpecificEffectCard(
                  icon: '🧠',
                  title: '뇌 기능 향상',
                  mainEffect: '기억력 ${_getCognitiveEffect(duration)}% UP',
                  details: [
                    '스트레스 호르몬 ${((duration / 60) * 30).toInt()}% 감소',
                    '행복 호르몬(엔돌핀) 대량 분비',
                    '집중력이 ${(duration / 10).toInt()}시간 지속'
                  ],
                  progress: math.min(duration / 60, 1.0),
                  index: 1,
                ),
                
                const SizedBox(height: 12),
                
                _buildSpecificEffectCard(
                  icon: '💪',
                  title: '근육 & 대사',
                  mainEffect: '기초대사율 ${_getMetabolicEffect(calories)}kcal 증가',
                  details: [
                    '근육량 ${_getMuscleGrowth(exerciseType)} 증가',
                    '24시간 동안 지속적 칼로리 소모',
                    '인슐린 민감도 향상으로 당뇨 예방'
                  ],
                  progress: math.min(calories / 500, 1.0),
                  index: 2,
                ),
                
                const SizedBox(height: 16),
                
                // 놀라운 사실 섹션
                _buildSurprisingFactCard(duration, calories, intensity),
              ],
            ),
          ),
        ],
      ),
    ).animate()
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
                        '셰르피의 꿀팁이에요!',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                        color: exerciseOrange.withOpacity(0.3),
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
              color: exerciseOrange,
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
                    color: exerciseOrange.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  encouragement.replaceAll('"', ''),  // 따옴표 제거
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
                      borderColor: exerciseOrange.withOpacity(0.2),
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
    ).animate()
      .slideY(begin: 0.1, end: 0, duration: 800.ms, delay: 1000.ms)
      .fadeIn(duration: 800.ms, delay: 1000.ms);
  }
  
  // ============ 헬퍼 메서드들 ============
  
  /// 혈압 감소 효과 계산
  String _getBloodPressureEffect(String intensity) {
    switch (intensity) {
      case '높음':
      case '매우 높음':
        return '7-10mmHg';
      case '중간':
        return '5-7mmHg';
      case '낮음':
      default:
        return '3-5mmHg';
    }
  }
  
  /// 인지 능력 향상 효과 계산
  int _getCognitiveEffect(int duration) {
    return math.min(15 + (duration ~/ 10) * 5, 40);
  }
  
  /// 대사율 증가 효과 계산
  int _getMetabolicEffect(int calories) {
    return (calories * 0.15).round();
  }
  
  /// 근육 성장 효과 계산 (운동 타입별)
  String _getMuscleGrowth(String exerciseType) {
    final typeMap = {
      '근력운동': '0.3-0.5%',
      '웨이트': '0.3-0.5%',
      '헬스': '0.3-0.5%',
      '달리기': '0.1-0.2%',
      '런닝': '0.1-0.2%',
      '자전거': '0.2-0.3%',
      '수영': '0.2-0.4%',
      '요가': '0.1-0.2%',
    };
    
    for (final entry in typeMap.entries) {
      if (exerciseType.contains(entry.key)) {
        return entry.value;
      }
    }
    return '0.1-0.3%';
  }

  // ============ 헬퍼 위젯들 ============

  /// 로딩 중 효과 섹션
  Widget _buildLoadingBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: exerciseOrange.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: exerciseOrange,
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
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: exerciseOrange,
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

  /// 구체적 효과 카드
  Widget _buildSpecificEffectCard({
    required String icon,
    required String title,
    required String mainEffect,
    required List<String> details,
    required double progress,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: exerciseOrange.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: exerciseOrange.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: exerciseOrangeLight.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    Text(
                      mainEffect,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: exerciseOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 프로그레스 바
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: ModernColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [exerciseOrange, exerciseOrangeMedium],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 상세 효과들
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: exerciseOrangeMedium,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    detail,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    ).animate()
      .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: (200 * index).ms)
      .fadeIn(duration: 400.ms, delay: (200 * index).ms);
  }

  /// 놀라운 사실 카드
  Widget _buildSurprisingFactCard(int duration, int calories, String intensity) {
    // 재미있는 비교 팩트들
    final facts = [
      '🏃 ${duration}분 운동 = 계단 ${(duration * 15).toInt()}층 오르기',
      '🍎 ${calories}kcal = 사과 ${(calories / 95).toStringAsFixed(1)}개 칼로리',
      '💓 심장이 약 ${(duration * 80).toInt()}번 더 뛰었어요',
      '🧠 뇌에 산소 공급이 ${(duration * 2).toInt()}% 증가',
    ];
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            exerciseOrange.withOpacity(0.1),
            exerciseOrangeLight.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: exerciseOrange.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: exerciseOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '💡 알고 계셨나요?',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 14),
          
          ...facts.take(3).map((fact) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              fact,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: exerciseOrange.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          )).toList(),
        ],
      ),
    ).animate()
      .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 800.ms)
      .fadeIn(duration: 500.ms, delay: 800.ms);
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
          // 셰르피 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: exerciseOrange.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/sherpi/sherpi_thinking.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"아직 운동 기록이 없네요"',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"오늘의 운동을 기록해볼까요?"',
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