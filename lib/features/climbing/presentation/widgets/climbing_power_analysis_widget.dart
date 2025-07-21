// lib/features/my_growth/presentation/widgets/climbing_power_analysis_widget.dart

import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/sherpa_card.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/providers/global_game_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_badge_provider.dart';
import '../../../../shared/models/global_badge_model.dart';

class ClimbingPowerAnalysisWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ClimbingPowerAnalysisWidget> createState() => _ClimbingPowerAnalysisWidgetState();
}

class _ClimbingPowerAnalysisWidgetState extends ConsumerState<ClimbingPowerAnalysisWidget>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late AnimationController _starController;
  late AnimationController _crystalController;
  late AnimationController _powerController;
  double _previousPower = 0;

  @override
  void initState() {
    super.initState();

    _auroraController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _starController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _crystalController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _powerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _starController.dispose();
    _crystalController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final userTitle = ref.watch(globalUserTitleProvider);
    final gameSystem = ref.watch(globalGameProvider);
    final totalPoints = ref.watch(globalTotalPointsProvider);

    final equippedBadges = ref.watch(globalEquippedBadgesProvider);

    final userPower = gameSystem.calculateFinalClimbingPower(
      level: user.level,
      titleBonus: gameSystem.getTitleBonus(user.level),
      stamina: user.stats.stamina,
      knowledge: user.stats.knowledge,
      technique: user.stats.technique,
      equippedBadges: equippedBadges,
    );

    final history = user.dailyRecords.climbingLogs.map((log) => {
      'mountainId': log.mountainId,
      'success': log.isSuccess,
      'experience': log.rewards.experience,
      'points': log.rewards.points,
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 📱 반응형 사이즈 계산
    final ResponsiveSizes sizes = _calculateResponsiveSizes(screenWidth, screenHeight);

    if (_previousPower != userPower) {
      _previousPower = userPower;
      _powerController.forward(from: 0);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: sizes.margin, vertical: 8),
      child: SherpaCard(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: BoxConstraints(
              minHeight: sizes.minHeight,
              maxHeight: sizes.maxHeight,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFE4B5),
                  Color(0xFF87CEEB),
                  Color(0xFFE0F6FF),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                _buildWarmAuroraWaves(),
                _buildGoldenSparkles(),
                _buildFlexibleContent(user, userPower, history, totalPoints, sizes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📱 반응형 사이즈 계산 클래스
  ResponsiveSizes _calculateResponsiveSizes(double screenWidth, double screenHeight) {
    final isSmallPhone = screenWidth < 360;
    final isMediumPhone = screenWidth < 400;
    final isSmallHeight = screenHeight < 600;

    return ResponsiveSizes(
      // 화면 크기별 여백
      margin: isSmallPhone ? 12.0 : 16.0,
      padding: isSmallPhone ? 12.0 : 16.0,

      // 최소/최대 높이
      minHeight: isSmallHeight ? 350.0 : 400.0,
      maxHeight: screenHeight * 0.8,

      // 폰트 크기 (통일된 시스템)
      titleFont: isSmallPhone ? 16.0 : 18.0,
      subtitleFont: isSmallPhone ? 13.0 : 14.0,
      bodyFont: isSmallPhone ? 11.0 : 12.0,
      captionFont: isSmallPhone ? 9.0 : 10.0,

      // 컴포넌트 크기
      iconSize: isSmallPhone ? 16.0 : 20.0,
      buttonHeight: isSmallPhone ? 32.0 : 36.0,
      cardMinHeight: isSmallHeight ? 60.0 : 70.0,

      // 간격
      sectionSpacing: isSmallPhone ? 10.0 : 12.0,
      itemSpacing: isSmallPhone ? 6.0 : 8.0,

      // 크리스탈 크기
      crystalSize: isSmallPhone ? 100.0 : 120.0,
      powerNumberSize: isSmallPhone ? 24.0 : 30.0,
    );
  }

  // 🌈 오로라 웨이브 (변경 없음)
  Widget _buildWarmAuroraWaves() {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, child) {
        return Stack(
          children: [
            _buildAuroraWave(
              colors: [
                Color(0x55FFDAB9).withOpacity(0.4 + 0.2 * math.sin(_auroraController.value * math.pi * 2)),
                Color(0x55FFE4B5).withOpacity(0.3 + 0.1 * math.sin(_auroraController.value * math.pi * 2)),
                Colors.transparent,
              ],
              offset: _auroraController.value * 100,
              waveHeight: 0.3,
            ),
            _buildAuroraWave(
              colors: [
                Color(0x55FFB6C1).withOpacity(0.3 + 0.15 * math.sin((_auroraController.value + 0.3) * math.pi * 2)),
                Color(0x55FFC0CB).withOpacity(0.2 + 0.1 * math.sin((_auroraController.value + 0.3) * math.pi * 2)),
                Colors.transparent,
              ],
              offset: (_auroraController.value + 0.5) * 80,
              waveHeight: 0.4,
            ),
            _buildAuroraWave(
              colors: [
                Color(0x55FFA07A).withOpacity(0.35 + 0.15 * math.sin((_auroraController.value + 0.6) * math.pi * 2)),
                Color(0x55FFCCCB).withOpacity(0.25 + 0.1 * math.sin((_auroraController.value + 0.6) * math.pi * 2)),
                Colors.transparent,
              ],
              offset: (_auroraController.value + 0.8) * 120,
              waveHeight: 0.35,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuroraWave({
    required List<Color> colors,
    required double offset,
    required double waveHeight,
  }) {
    return CustomPaint(
      size: Size.infinite,
      painter: AuroraWavePainter(
        colors: colors,
        offset: offset,
        waveHeight: waveHeight,
      ),
    );
  }

  // ✨ 황금빛 반짝임 효과 (변경 없음)
  Widget _buildGoldenSparkles() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: GoldenSparklePainter(_starController.value),
        );
      },
    );
  }

  // 📱 반응형 콘텐츠
  Widget _buildFlexibleContent(user, double userPower, List<Map<String, dynamic>> history, int totalPoints, ResponsiveSizes sizes) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBrightFrostedHeader(sizes),
            SizedBox(height: sizes.sectionSpacing),
            Flexible(
              flex: 3,
              child: _buildAdaptiveCrystalCore(userPower, sizes),
            ),
            SizedBox(height: sizes.sectionSpacing),
            Flexible(
              flex: 2,
              child: _buildBrightFrostedCards(user, sizes),
            ),
            SizedBox(height: sizes.sectionSpacing),
            Flexible(
              flex: 3,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: sizes.cardMinHeight * 2 + sizes.itemSpacing,
                ),
                child: _buildCompactFrostedStats(history, totalPoints, sizes),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📜 헤더 (반응형 적용)
  Widget _buildBrightFrostedHeader(ResponsiveSizes sizes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(sizes.padding),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFFD700).withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: sizes.iconSize * 2,
                height: sizes.iconSize * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFFFD700).withOpacity(0.4),
                      AppColors.primary.withOpacity(0.3),
                    ],
                  ),
                  border: Border.all(
                    color: Color(0xFFFFD700).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_graph_rounded,
                    color: AppColors.primaryDark,
                    size: sizes.iconSize,
                  ),
                ),
              ),
              SizedBox(width: sizes.itemSpacing * 1.5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '성장의 기록',
                      style: GoogleFonts.notoSans(
                        fontSize: sizes.titleFont,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        shadows: [
                          Shadow(
                            color: Color(0xFFFFD700).withOpacity(0.3),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '위대한 여정을 향하여',
                      style: GoogleFonts.notoSans(
                        fontSize: sizes.bodyFont,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedbackManager.lightImpact();
                  _showLegendaryJourney();
                },
                child: Container(
                  height: sizes.buttonHeight,
                  padding: EdgeInsets.symmetric(horizontal: sizes.itemSpacing * 1.5, vertical: sizes.itemSpacing),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '여정',
                      style: GoogleFonts.notoSans(
                        fontSize: sizes.bodyFont,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💎 크리스탈 코어 (반응형 적용)
  Widget _buildAdaptiveCrystalCore(double power, ResponsiveSizes sizes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(
            math.min(constraints.maxHeight * 0.8, constraints.maxWidth * 0.5),
            sizes.crystalSize * 2
        );

        return Center(
          child: AnimatedBuilder(
            animation: _crystalController,
            builder: (context, child) {
              return Container(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: size * 0.9 + 8 * _crystalController.value,
                      height: size * 0.9 + 8 * _crystalController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFFFD700).withOpacity(0.3 * _crystalController.value),
                            Color(0xFFFFA500).withOpacity(0.2 * _crystalController.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: size * 0.7,
                      height: size * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFFFFD700).withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: size * 0.5,
                      height: size * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                        border: Border.all(
                          color: Color(0xFFFFD700).withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _powerController,
                            builder: (context, child) {
                              final animatedValue = Tween<double>(
                                begin: _previousPower,
                                end: power,
                              ).animate(CurvedAnimation(
                                parent: _powerController,
                                curve: Curves.easeOutCubic,
                              )).value;

                              return Text(
                                animatedValue.toInt().toString(),
                                style: GoogleFonts.notoSans(
                                  fontSize: sizes.powerNumberSize,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDark,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFFFFD700).withOpacity(0.6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Text(
                            'POWER',
                            style: GoogleFonts.notoSans(
                              fontSize: sizes.bodyFont,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 💎 능력치 카드들 (반응형 적용)
  Widget _buildBrightFrostedCards(user, ResponsiveSizes sizes) {
    final titleBonus = _getTitleBonus(user.level).toDouble();
    final basePower = (user.level * 10).toDouble() + titleBonus;
    final statsBonus = user.stats.stamina + user.stats.knowledge + user.stats.technique;

    final equippedBadges = ref.watch(globalEquippedBadgesProvider);
    final badgeBonus = _calculateRealBadgeBonus(equippedBadges);

    final cards = [
      {
        'title': '기본력',
        'value': basePower,
        'icon': Icons.flash_on_rounded,
        'color': Color(0xFF2196F3),
        'isPercentage': false,
      },
      {
        'title': '능력치',
        'value': statsBonus,
        'icon': Icons.health_and_safety_rounded,
        'color': Color(0xFF4CAF50),
        'isPercentage': true,
      },
      {
        'title': '뱃지',
        'value': badgeBonus,
        'icon': Icons.shield_rounded,
        'color': Color(0xFFFF9800),
        'isPercentage': true,
      },
    ];

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.itemSpacing * 1.5, vertical: sizes.itemSpacing * 0.75),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Color(0xFFFFD700).withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            '힘의 근원',
            style: GoogleFonts.notoSans(
              fontSize: sizes.subtitleFont,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        SizedBox(height: sizes.itemSpacing),
        Expanded(
          child: Row(
            children: cards.map((card) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: sizes.itemSpacing * 0.5),
                  child: _buildBrightFrostedCard(card, sizes),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBrightFrostedCard(Map<String, dynamic> card, ResponsiveSizes sizes) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        _showPowerExplanation(card['title'] as String, card);
      },
      child: Container(
        padding: EdgeInsets.all(sizes.itemSpacing * 1.5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (card['color'] as Color).withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (card['color'] as Color).withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: sizes.iconSize * 1.6,
              height: sizes.iconSize * 1.6,
              decoration: BoxDecoration(
                color: (card['color'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                card['icon'] as IconData,
                color: card['color'] as Color,
                size: sizes.iconSize,
              ),
            ),
            SizedBox(height: sizes.itemSpacing),
            Text(
              card['title'] as String,
              style: GoogleFonts.notoSans(
                fontSize: sizes.bodyFont,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: sizes.itemSpacing * 0.75),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                card['isPercentage'] as bool
                    ? (card['value'] as double) > 0
                    ? '+${(card['value'] as double).toStringAsFixed(1)}%'
                    : '0%'
                    : (card['value'] as double).toInt().toString(),
                style: GoogleFonts.notoSans(
                  fontSize: sizes.subtitleFont,
                  fontWeight: FontWeight.w800,
                  color: (card['value'] as double) > 0
                      ? card['color'] as Color
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 통계 (반응형 개선)
  Widget _buildCompactFrostedStats(List<Map<String, dynamic>> history, int totalPoints, ResponsiveSizes sizes) {
    final totalClimbs = history.length;
    final successfulClimbs = history.where((s) => s['success'] == true).length;
    final successRate = totalClimbs > 0 ? (successfulClimbs / totalClimbs) * 100 : 0.0;
    final totalXp = history.fold<double>(0, (sum, session) => sum + ((session['experience'] as num?)?.toDouble() ?? 0));
    final earnedPoints = history.fold<double>(0, (sum, session) => sum + ((session['points'] as num?)?.toDouble() ?? 0));

    final stats = [
      {'icon': '🏔️', 'value': totalClimbs.toString(), 'label': '총 등반'},
      {'icon': '📈', 'value': '${successRate.toStringAsFixed(1)}%', 'label': '성공률'},
      {'icon': '⭐', 'value': totalXp.toStringAsFixed(0), 'label': '획득 XP'},
      {'icon': '💰', 'value': earnedPoints.toStringAsFixed(0), 'label': '누적 포인트'},
    ];

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: sizes.itemSpacing * 1.5,
              vertical: sizes.itemSpacing * 0.75
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Color(0xFFFFD700).withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            '탐험의 결과',
            style: GoogleFonts.notoSans(
              fontSize: sizes.subtitleFont,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        SizedBox(height: sizes.itemSpacing),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: sizes.cardMinHeight),
                        child: _buildCompactStatCard(stats[0], sizes),
                      ),
                    ),
                    SizedBox(width: sizes.itemSpacing),
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: sizes.cardMinHeight),
                        child: _buildCompactStatCard(stats[1], sizes),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sizes.itemSpacing),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: sizes.cardMinHeight),
                        child: _buildCompactStatCard(stats[2], sizes),
                      ),
                    ),
                    SizedBox(width: sizes.itemSpacing),
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: sizes.cardMinHeight),
                        child: _buildCompactStatCard(stats[3], sizes),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatCard(Map<String, dynamic> stat, ResponsiveSizes sizes) {
    return Container(
      padding: EdgeInsets.all(sizes.itemSpacing),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat['icon'] as String,
            style: TextStyle(fontSize: sizes.subtitleFont),
          ),
          SizedBox(height: sizes.itemSpacing * 0.5),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                stat['value'] as String,
                style: GoogleFonts.notoSans(
                  fontSize: sizes.bodyFont,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          SizedBox(height: sizes.itemSpacing * 0.5),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                stat['label'] as String,
                style: GoogleFonts.notoSans(
                  fontSize: sizes.captionFont,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 나머지 메서드들은 기존과 동일...
  void _showPowerExplanation(String type, Map<String, dynamic> card) {
    String title = '';
    String explanation = '';
    String formula = '';
    Color iconColor = card['color'] as Color;

    switch (type) {
      case '기본력':
        title = '🔥 기본 등반력';
        explanation = '레벨과 칭호에 따른 순수한 힘입니다.\n\n꾸준한 등반으로 레벨을 올리고, 10레벨마다 새로운 칭호를 획득하여 기본력을 강화하세요!';
        formula = '계산식: (레벨 × 10) + 칭호 보너스';
        break;
      case '능력치':
        title = '💪 능력치 보너스';
        explanation = '체력, 지식, 기술의 조화로 만들어지는 핵심 보너스입니다.\n\n각 능력치의 퍼센트를 모두 더해 최종 등반력에 곱하기로 적용됩니다.';
        formula = '계산식: (체력% + 지식% + 기술%) × 기본력';
        break;
      case '뱃지':
        title = '🏅 뱃지 보너스';

        final equippedBadges = ref.read(globalEquippedBadgesProvider);
        final badgeList = equippedBadges.where((badge) =>
        badge.effectType == 'climbing_power_bonus' ||
            badge.effectType == 'CLIMBING_POWER_MULTIPLY'
        ).toList();

        if (badgeList.isNotEmpty) {
          explanation = '특별한 성취와 전략적 선택의 결과입니다.\n\n현재 장착 중인 등반력 보너스 뱃지:\n';
          for (final badge in badgeList) {
            explanation += '• ${badge.name}: +${badge.effectValue}%\n';
          }
        } else {
          explanation = '아직 등반력 보너스를 주는 뱃지를 장착하지 않았습니다.\n\n다양한 활동을 통해 뱃지를 얻어 등반력을 강화해보세요!';
        }

        formula = '계산식: 모든 등반력 뱃지 보너스% 합산';
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    iconColor.withOpacity(0.3),
                    iconColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withOpacity(0.5)),
              ),
              child: Icon(
                card['icon'] as IconData,
                color: iconColor,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          constraints: BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '현재 값: ',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      card['isPercentage'] as bool
                          ? '+${(card['value'] as double).toStringAsFixed(1)}%'
                          : (card['value'] as double).toInt().toString(),
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                explanation,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Text(
                  formula,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '이해했어요!',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getTitleBonus(int level) {
    if (level < 10) return 0.0;
    if (level < 20) return 50.0;
    if (level < 30) return 120.0;
    return 250.0;
  }

  double _calculateRealBadgeBonus(List<GlobalBadge> equippedBadges) {
    double bonus = 0.0;

    for (final badge in equippedBadges) {
      if (badge.effectType == 'climbing_power_bonus' ||
          badge.effectType == 'CLIMBING_POWER_MULTIPLY') {
        bonus += badge.effectValue;
      }
    }

    return bonus;
  }

  double _calculateBadgeBonus(List<String> badgeIds) {
    final equippedBadges = ref.read(globalEquippedBadgesProvider);
    return _calculateRealBadgeBonus(equippedBadges);
  }

  void _showLegendaryJourney() {
    final user = ref.read(globalUserProvider);
    final history = user.dailyRecords.climbingLogs.map((log) => {
      'mountainId': log.mountainId,
      'success': log.isSuccess,
      'experience': log.rewards.experience,
      'points': log.rewards.points,
    }).toList();

    final mountains = [
      {'id': 1, 'name': '북한산'},
      {'id': 2, 'name': '관악산'},
      {'id': 3, 'name': '지리산'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Color(0xFFE0F6FF),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFFD700).withOpacity(0.8),
                    AppColors.primary.withOpacity(0.4),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.7)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.history_edu_rounded, color: AppColors.primaryDark, size: 20),
              ),
            ),
            SizedBox(width: 12),
            Text(
              '전설의 여정',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: 400),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: history.length,
            itemBuilder: (context, index) {
              final session = history[index];
              final mountainName = mountains.firstWhere(
                    (m) => m['id'] == (session['mountainId'] ?? 1),
                orElse: () => {'name': '알 수 없는 산'},
              )['name'] as String;

              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (session['success'] == true)
                        ? AppColors.success.withOpacity(0.5)
                        : AppColors.error.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (session['success'] == true) ? AppColors.success : AppColors.error,
                      ),
                      child: Center(
                        child: Icon(
                          (session['success'] == true) ? Icons.check_rounded : Icons.close_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mountainName,
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                (session['success'] == true) ? '성공' : '실패',
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: (session['success'] == true) ? AppColors.success : AppColors.error,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '+${((session['experience'] as num?)?.toStringAsFixed(0)) ?? '0'} XP',
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '+${((session['points'] as num?)?.toStringAsFixed(0)) ?? '0'} P',
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '확인',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎯 반응형 사이즈 관리 클래스
class ResponsiveSizes {
  final double margin;
  final double padding;
  final double minHeight;
  final double maxHeight;
  final double titleFont;
  final double subtitleFont;
  final double bodyFont;
  final double captionFont;
  final double iconSize;
  final double buttonHeight;
  final double cardMinHeight;
  final double sectionSpacing;
  final double itemSpacing;
  final double crystalSize;
  final double powerNumberSize;

  const ResponsiveSizes({
    required this.margin,
    required this.padding,
    required this.minHeight,
    required this.maxHeight,
    required this.titleFont,
    required this.subtitleFont,
    required this.bodyFont,
    required this.captionFont,
    required this.iconSize,
    required this.buttonHeight,
    required this.cardMinHeight,
    required this.sectionSpacing,
    required this.itemSpacing,
    required this.crystalSize,
    required this.powerNumberSize,
  });
}

// 🌈 오로라 웨이브 페인터 (기존과 동일)
class AuroraWavePainter extends CustomPainter {
  final List<Color> colors;
  final double offset;
  final double waveHeight;

  AuroraWavePainter({
    required this.colors,
    required this.offset,
    required this.waveHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveWidth = size.width / 4;
    final baseHeight = size.height * waveHeight;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final y = baseHeight +
          math.sin((x / waveWidth + offset / 50) * math.pi) * 30 +
          math.sin((x / (waveWidth * 0.7) + offset / 30) * math.pi) * 20 +
          math.sin((x / (waveWidth * 1.3) + offset / 70) * math.pi) * 15;

      path.lineTo(x, size.height - y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ✨ 황금빛 반짝임 페인터 (기존과 동일)
class GoldenSparklePainter extends CustomPainter {
  final double animationValue;

  GoldenSparklePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFFFD700).withOpacity(0.6 + 0.4 * animationValue)
      ..style = PaintingStyle.fill;

    final sparkles = [
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.15),
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.35),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.85, size.height * 0.55),
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.6, size.height * 0.75),
    ];

    for (final sparkle in sparkles) {
      canvas.drawCircle(sparkle, 1.2 + 0.8 * animationValue, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}