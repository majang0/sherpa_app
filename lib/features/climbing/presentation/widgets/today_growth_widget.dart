import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';

// 오늘의 등반 성장 데이터 모델
class TodayClimbingGrowthData {
  final int todayClimbingCount;
  final int successfulClimbs;
  final double totalExpGained;
  final int totalPointsEarned;
  final double climbingSuccessRate;
  final bool isCurrentlyClimbing;
  final String? currentMountainName;
  final double? currentProgress;

  const TodayClimbingGrowthData({
    required this.todayClimbingCount,
    required this.successfulClimbs,
    required this.totalExpGained,
    required this.totalPointsEarned,
    required this.climbingSuccessRate,
    required this.isCurrentlyClimbing,
    this.currentMountainName,
    this.currentProgress,
  });
}

// 오늘의 등반 성장 Provider
final todayClimbingGrowthProvider = Provider<TodayClimbingGrowthData>((ref) {
  final user = ref.watch(globalUserProvider);
  final currentSession = ref.watch(currentClimbingSessionProvider);
  final todayRecords = ref.watch(todayClimbingRecordsProvider);

  // 오늘의 등반 통계 계산
  final successfulCount =
      todayRecords.where((r) => r.isSuccess ?? false).length;
  final totalExp = todayRecords.fold<double>(
      0, (sum, r) => sum + (r.rewards?.experience ?? 0));
  final totalPoints = todayRecords.fold<int>(
      0, (sum, r) => sum + (r.rewards?.points ?? 0).toInt());
  final successRate =
      todayRecords.isEmpty ? 0.0 : successfulCount / todayRecords.length;

  return TodayClimbingGrowthData(
    todayClimbingCount: todayRecords.length,
    successfulClimbs: successfulCount,
    totalExpGained: totalExp,
    totalPointsEarned: totalPoints,
    climbingSuccessRate: successRate,
    isCurrentlyClimbing: currentSession?.isActive ?? false,
    currentMountainName: currentSession?.mountainName,
    currentProgress: currentSession?.progress,
  );
});

class TodayGrowthWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<TodayGrowthWidget> createState() => _TodayGrowthWidgetState();
}

class _TodayGrowthWidgetState extends ConsumerState<TodayGrowthWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _numberController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _numberController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _scaleController.forward();
    _numberController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final climbingGrowth = ref.watch(todayClimbingGrowthProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.textLight.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(climbingGrowth),
                  if (climbingGrowth.isCurrentlyClimbing)
                    _buildCurrentClimbingStatus(climbingGrowth),
                  _buildTodayStats(climbingGrowth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(TodayClimbingGrowthData data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20), // 상단 패딩 증가
      child: Row(
        children: [
          // 아이콘 컨테이너
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.terrain,
                  color: Colors.white.withOpacity(0.2),
                  size: 28,
                ),
                Text(
                  '⛰️',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 등반 요약',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '성공률 ${(data.climbingSuccessRate * 100).toInt()}%',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
    );
  }

  Widget _buildCurrentClimbingStatus(TodayClimbingGrowthData data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '등반 진행 중',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.currentMountainName ?? '',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // 프로그레스 바
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                width: MediaQuery.of(context).size.width *
                    (data.currentProgress ?? 0) *
                    0.8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${((data.currentProgress ?? 0) * 100).toInt()}% 완료',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats(TodayClimbingGrowthData data) {
    final stats = [
      {
        'icon': '🏔️',
        'value': data.todayClimbingCount,
        'label': '등반 시도',
        'color': AppColors.primary,
      },
      {
        'icon': '🎯',
        'value': data.successfulClimbs,
        'label': '성공 등반',
        'color': AppColors.success,
      },
      {
        'icon': '⭐',
        'value': data.totalExpGained.toInt(),
        'label': '획득 경험치',
        'color': AppColors.warning,
      },
      {
        'icon': '💎',
        'value': data.totalPointsEarned,
        'label': '획득 포인트',
        'color': AppColors.accent,
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 구분선
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.star,
                    color: AppColors.primary.withOpacity(0.3),
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 통계 그리드
          Row(
            children: stats.map((stat) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildStatCard(stat),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final value = stat['value'] as int;
    final color = stat['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                stat['icon'] as String,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 숫자 애니메이션
          AnimatedBuilder(
            animation: _numberController,
            builder: (context, child) {
              final animatedValue = (value * _numberController.value).toInt();
              return Text(
                animatedValue.toString(),
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            stat['label'] as String,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
