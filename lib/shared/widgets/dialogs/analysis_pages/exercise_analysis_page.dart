import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/ai/activity_analysis_service.dart';

/// 운동 분석 페이지 - 시각적 배지와 AI 기반 인사이트
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
  
  // 강도에 따른 색상 반환
  Color _getIntensityColor(String? intensity) {
    switch (intensity) {
      case '낮음':
        return ModernColors.success;
      case '중간':
        return ModernColors.primary;
      case '높음':
        return ModernColors.warning;
      case '매우 높음':
        return ModernColors.error;
      default:
        return ModernColors.primary;
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
          
          // 3. 비교 분석 섹션
          _buildComparisonSection(),
          
          const SizedBox(height: 20),
          
          // 4. 오늘 운동의 장점
          _buildBenefitsSection(),
          
          const SizedBox(height: 20),
          
          // 5. 셰르피의 추천
          _buildRecommendationSection(),
          
          const SizedBox(height: 20),
          
          // 6. 응원의 말
          _buildEncouragementSection(),
          
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
  
  /// 개별 운동 배지
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
                    ? ModernColors.primaryGradient
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
                        ? ModernColors.primary.withOpacity(0.3)
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
  
  /// 비교 분석 섹션
  Widget _buildComparisonSection() {
    // AI 분석이 로딩 중이거나 없을 때 기본 메시지 사용
    final content = _isLoading 
        ? '분석 중...'
        : (_analysisData?.comparison ?? _getDefaultComparisonMessage());
    
    return _buildSectionCard(
      title: '지난번과 비교',
      icon: Icons.compare_arrows_rounded,
      color: ModernColors.warning,
      content: content,
    );
  }
  
  /// 기본 비교 메시지
  String _getDefaultComparisonMessage() {
    if (widget.previousData == null) {
      return '오늘이 첫 운동 기록이에요! 🎉\n훌륭한 시작입니다. 꾸준히 운동하면 건강한 몸과 마음을 만들 수 있어요.';
    }
    return '운동 데이터를 분석하고 있어요...';
  }
  
  /// 오늘 운동의 장점 섹션
  Widget _buildBenefitsSection() {
    final content = _isLoading 
        ? '분석 중...'
        : (_analysisData?.benefits ?? '운동의 효과를 분석하고 있어요...');
    
    return _buildSectionCard(
      title: '오늘 운동의 효과',
      icon: Icons.favorite_rounded,
      color: ModernColors.error,
      content: content,
    );
  }
  
  /// [Deprecated] 운동 효과 생성 - AI 분석으로 대체됨
  @deprecated
  String _generateBenefits(String type, int duration, String intensity) {
    String benefits = '';
    
    // 운동 타입별 효과
    if (type.contains('달리기') || type.contains('런닝') || type.contains('조깅')) {
      benefits = '🏃 달리기는 심폐 지구력을 향상시키고 전신 근육을 강화합니다.\n';
      if (duration >= 30) {
        benefits += '30분 이상 달리기로 엔돌핀이 분비되어 기분이 좋아집니다.\n';
      }
    } else if (type.contains('걷기') || type.contains('산책')) {
      benefits = '🚶 걷기는 관절에 무리 없이 건강을 유지하는 최고의 운동입니다.\n';
      benefits += '스트레스 해소와 창의력 향상에도 도움이 됩니다.\n';
    } else if (type.contains('자전거') || type.contains('사이클')) {
      benefits = '🚴 자전거는 하체 근력을 강화하고 균형 감각을 향상시킵니다.\n';
      benefits += '무릎 관절에 부담이 적어 지속 가능한 운동입니다.\n';
    } else if (type.contains('수영')) {
      benefits = '🏊 수영은 전신 운동으로 모든 근육을 균형있게 발달시킵니다.\n';
      benefits += '물의 저항으로 근력과 지구력이 동시에 향상됩니다.\n';
    } else if (type.contains('요가') || type.contains('필라테스')) {
      benefits = '🧘 요가는 유연성과 균형감을 향상시키고 마음을 안정시킵니다.\n';
      benefits += '코어 근육이 강화되어 자세 교정에도 효과적입니다.\n';
    } else if (type.contains('헬스') || type.contains('웨이트') || type.contains('근력')) {
      benefits = '💪 근력 운동은 기초 대사량을 높이고 뼈를 튼튼하게 합니다.\n';
      benefits += '근육량 증가로 일상 생활이 더 활기차집니다.\n';
    } else {
      benefits = '🎯 ${type}은(는) 신체 활동량을 늘리고 건강을 증진시킵니다.\n';
    }
    
    // 강도별 추가 효과
    switch (intensity) {
      case '낮음':
        benefits += '\n💚 낮은 강도로 부담 없이 운동하여 회복과 지속성에 좋습니다.';
        break;
      case '중간':
        benefits += '\n💙 적절한 강도로 체력 향상과 체중 관리에 효과적입니다.';
        break;
      case '높음':
        benefits += '\n🧡 높은 강도로 심폐 기능과 운동 능력이 크게 향상됩니다.';
        break;
      case '매우 높음':
        benefits += '\n❤️ 최고 강도로 운동하여 한계를 극복하고 있습니다. 대단해요!';
        break;
    }
    
    // 시간별 추가 효과
    if (duration >= 60) {
      benefits += '\n⏰ 1시간 이상 운동으로 지구력이 크게 향상되고 있어요!';
    } else if (duration >= 30) {
      benefits += '\n⏰ 30분 이상 운동으로 건강한 습관을 만들고 있어요!';
    }
    
    return benefits;
  }
  
  /// 셰르피의 추천 섹션
  Widget _buildRecommendationSection() {
    final content = _isLoading 
        ? '분석 중...'
        : (_analysisData?.recommendation ?? '맞춤형 추천을 준비하고 있어요...');
    
    return _buildSectionCard(
      title: '셰르피의 추천',
      icon: Icons.lightbulb_rounded,
      color: ModernColors.warning,
      content: content,
      hasGradient: true,
    );
  }
  
  /// [Deprecated] 추천 메시지 생성 - AI 분석으로 대체됨
  @deprecated
  String _generateRecommendation() {
    final exerciseType = widget.todayData!['type'] as String? ?? '운동';
    final duration = widget.todayData!['duration'] as int? ?? 0;
    final intensity = widget.todayData!['intensity'] as String? ?? '중간';
    
    String recommendation = '';
    
    // 지난번 데이터와 비교
    if (widget.previousData != null) {
      final previousDuration = widget.previousData!['duration'] as int? ?? 0;
      final previousIntensity = widget.previousData!['intensity'] as String? ?? '중간';
      
      if (duration > previousDuration && intensity == '높음' || intensity == '매우 높음') {
        recommendation = '💡 운동량이 늘어났네요! 충분한 휴식도 중요해요.\n'
            '• 운동 후 스트레칭을 10분 정도 해주세요\n'
            '• 단백질과 수분 섭취를 충분히 하세요\n'
            '• 다음 운동 전 충분한 수면을 취하세요';
      } else if (duration < 20) {
        recommendation = '💡 짧은 운동도 좋지만, 점진적으로 늘려보세요!\n'
            '• 매주 5분씩 운동 시간을 늘려보세요\n'
            '• 좋아하는 음악을 들으며 운동해보세요\n'
            '• 운동 친구를 만들어 함께 해보세요';
      } else {
        recommendation = '💡 꾸준한 운동 습관이 만들어지고 있어요!\n'
            '• 다양한 운동을 시도해보세요\n'
            '• 운동 전후 영양 섭취에 신경쓰세요\n'
            '• 목표를 세우고 도전해보세요';
      }
    } else {
      recommendation = '💡 첫 운동을 시작하셨군요! 이렇게 해보세요:\n'
          '• 무리하지 말고 천천히 시작하세요\n'
          '• 매일 같은 시간에 운동하는 습관을 만드세요\n'
          '• 운동 일지를 작성하며 발전을 확인하세요\n'
          '• 작은 목표부터 달성해나가세요';
    }
    
    // 운동 타입별 추가 팁
    if (exerciseType.contains('달리기') || exerciseType.contains('런닝')) {
      recommendation += '\n\n🏃 러닝 팁: 올바른 자세와 호흡법을 익히면 더 오래 달릴 수 있어요!';
    } else if (exerciseType.contains('헬스') || exerciseType.contains('웨이트')) {
      recommendation += '\n\n💪 근력 운동 팁: 근육 부위별로 휴식일을 가지며 운동하세요!';
    }
    
    return recommendation;
  }
  
  /// 응원의 말 섹션
  Widget _buildEncouragementSection() {
    final encouragement = _isLoading 
        ? '응원 메시지를 준비하고 있어요...'
        : (_analysisData?.encouragement ?? '오늘도 정말 수고하셨어요! 💪');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.primary.withOpacity(0.1),
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
          // 셰르피 아이콘
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: ModernColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '오늘도 수고하셨어요! 🌟',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            encouragement,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
      .slideY(
        begin: 0.1,
        end: 0,
        duration: 800.ms,
        delay: 800.ms,
        curve: Curves.easeOutBack,
      )
      .fadeIn(
        duration: 800.ms,
        delay: 800.ms,
      );
  }
  
  /// [Deprecated] 응원 메시지 생성 - AI 분석으로 대체됨
  @deprecated
  String _generateEncouragement(int duration, int calories) {
    List<String> messages = [
      '오늘 ${duration}분 동안 ${calories}kcal를 소모했어요! 당신의 노력이 빛나고 있어요. 내일도 함께 운동해요!',
      '운동을 완료한 당신, 정말 멋져요! 건강한 몸과 마음을 위한 투자는 절대 헛되지 않아요.',
      '한 걸음 한 걸음이 모여 큰 변화를 만들어요. 오늘의 운동이 더 나은 내일을 만들고 있어요!',
      '포기하지 않고 꾸준히 운동하는 당신이 자랑스러워요. 이 기세를 계속 유지해봐요!',
      '오늘도 자신과의 약속을 지켰네요! 스스로에게 박수를 보내주세요. 👏',
    ];
    
    // 운동 시간에 따른 특별 메시지
    if (duration >= 60) {
      return '와! 1시간 이상 운동하셨네요! 정말 대단해요. '
          '이런 열정과 끈기라면 무엇이든 이룰 수 있어요. '
          '충분한 휴식도 잊지 마세요!';
    } else if (duration >= 30) {
      return messages[DateTime.now().millisecond % messages.length];
    } else {
      return '짧은 시간이라도 운동한 것이 중요해요! '
          '꾸준함이 가장 큰 힘이에요. '
          '내일은 조금 더 도전해보는 건 어떨까요?';
    }
  }
  
  /// 섹션 카드 위젯
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    bool hasGradient = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasGradient 
              ? color.withOpacity(0.3)
              : ModernColors.borderLight,
          width: 1,
        ),
        gradient: hasGradient 
            ? LinearGradient(
                colors: [
                  color.withOpacity(0.05),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // 컨텐츠
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
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
              color: ModernColors.textTertiary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: ModernColors.textTertiary,
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