// lib/features/my_growth/presentation/widgets/user_stats_summary_widget.dart

import 'package:flutter/material.dart' hide Badge;
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_game_provider.dart';

class UserStatsSummaryWidget extends ConsumerStatefulWidget {
  const UserStatsSummaryWidget({super.key});

  @override
  ConsumerState<UserStatsSummaryWidget> createState() =>
      _UserStatsSummaryWidgetState();
}

class _UserStatsSummaryWidgetState extends ConsumerState<UserStatsSummaryWidget>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _glowController;
  late AnimationController _statBarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _statBarController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 애니메이션 시작
    _radarController.forward();
    _statBarController.forward();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _glowController.dispose();
    _statBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final gameSystem = ref.watch(globalGameProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return _buildStatsCard(user, gameSystem, screenWidth);
  }

  Widget _buildStatsCard(user, gameSystem, double screenWidth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // 메인 카드
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // 헤더
                  _buildRPGHeader(screenWidth),

                  // 레이더 차트 섹션
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: _buildRPGRadarChart(user, screenWidth),
                  ),

                  // RPG 스타일 구분선
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.primary.withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            Icons.star,
                            color: AppColors.primary.withValues(alpha: 0.3),
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 능력치 리스트
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: _buildRPGStatsList(user, gameSystem, screenWidth),
                  ),
                ],
              ),
            ),
          ),

          // 글로우 효과
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: 0.05 * _glowController.value),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRPGHeader(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 타이틀 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '능력치 현황',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CHARACTER STATS',
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // 장식용 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // RPG 스타일 레이더 차트 (최대값 동적 조정)
  Widget _buildRPGRadarChart(user, double screenWidth) {
    final stats = user.stats;
    final labels = ['체력', '지식', '기술', '사교성', '의지'];
    final List<double> values = [
      stats.stamina.toDouble(),
      stats.knowledge.toDouble(),
      stats.technique.toDouble(),
      stats.sociality.toDouble(),
      stats.willpower.toDouble()
    ];

    // 가장 높은 스탯 찾기
    final maxValue = values.reduce(math.max);
    // 차트의 최대값을 가장 높은 스탯의 120%로 설정 (여유 공간 확보)
    final chartMaxValue = maxValue * 1.2;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: AnimatedBuilder(
        animation: _radarController,
        builder: (context, child) {
          return RadarChart(
            RadarChartData(
              radarTouchData: RadarTouchData(
                enabled: true,
                touchCallback:
                    (FlTouchEvent event, RadarTouchResponse? touchResponse) {
                  if (event is FlTapUpEvent &&
                      touchResponse?.touchedSpot != null) {
                    final touchedDataSetIndex =
                        touchResponse!.touchedSpot!.touchedDataSetIndex;
                    if (touchedDataSetIndex == 2) {
                      final touchedRadarEntry =
                          touchResponse.touchedSpot!.touchedRadarEntry;
                      final index =
                          touchResponse.touchedSpot!.touchedRadarEntryIndex;
                      if (index >= 0 && index < labels.length) {
                        HapticFeedbackManager.lightImpact();
                        _showStatQuickInfo(labels[index], values[index]);
                      }
                    }
                  }
                },
              ),
              dataSets: [
                // 배경 가이드 (최대값 기준)
                RadarDataSet(
                  fillColor: Colors.transparent,
                  borderColor: AppColors.divider,
                  borderWidth: 1,
                  entryRadius: 0,
                  dataEntries: List.generate(
                      5, (index) => RadarEntry(value: chartMaxValue)),
                ),
                // 중간 가이드 (최대값의 50%)
                RadarDataSet(
                  fillColor: Colors.transparent,
                  borderColor: AppColors.divider.withValues(alpha: 0.5),
                  borderWidth: 0.5,
                  entryRadius: 0,
                  dataEntries: List.generate(
                      5, (index) => RadarEntry(value: chartMaxValue / 2)),
                ),
                // 실제 데이터
                RadarDataSet(
                  fillColor: AppColors.primary.withValues(alpha: 0.15),
                  borderColor: AppColors.primary,
                  borderWidth: 2,
                  entryRadius: 4,
                  dataEntries: values
                      .map((value) =>
                          RadarEntry(value: value * _radarController.value))
                      .toList(),
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.5), width: 1),
              titlePositionPercentageOffset: 0.15,
              titleTextStyle: GoogleFonts.notoSans(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              getTitle: (index, angle) {
                return RadarChartTitle(
                  text: labels[index],
                  angle: 0,
                );
              },
              tickCount: 5,
              ticksTextStyle: const TextStyle(fontSize: 0),
              tickBorderData: const BorderSide(color: Colors.transparent),
              gridBorderData: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.3),
                width: 0.5,
              ),
              radarShape: RadarShape.polygon,
            ),
          );
        },
      ),
    );
  }

  // RPG 스타일 능력치 리스트 - 터치 문제 해결
  Widget _buildRPGStatsList(user, gameSystem, double screenWidth) {
    final stats = user.stats;
    final statItems = [
      {'name': '체력', 'value': stats.stamina.toDouble(), 'icon': '💪'},
      {'name': '지식', 'value': stats.knowledge.toDouble(), 'icon': '🧠'},
      {'name': '기술', 'value': stats.technique.toDouble(), 'icon': '🛠️'},
      {'name': '사교성', 'value': stats.sociality.toDouble(), 'icon': '🤝'},
      {'name': '의지', 'value': stats.willpower.toDouble(), 'icon': '🔥'},
    ];

    return Column(
      children: statItems.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        final value = stat['value'] as double;
        final grade = gameSystem.getStatGrade(value);
        final gradeColor = _getGradeColor(grade);

        // ✅ Material + InkWell로 터치 이벤트 안정화
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                LoggerService.instance
                    .d('🎯 능력치 터치됨: ${stat['name']}'); // 디버그 로그
                HapticFeedbackManager.lightImpact();
                _showRPGStatDetails(
                  context,
                  stat['name'] as String,
                  value,
                  grade,
                );
              },
              child: AnimatedBuilder(
                animation: _statBarController,
                builder: (context, child) {
                  final delayedAnimation = Interval(
                    index * 0.1,
                    0.6 + index * 0.1,
                    curve: Curves.easeOutCubic,
                  ).transform(_statBarController.value);

                  return Stack(
                    children: [
                      // 배경
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                      ),

                      // 프로그레스 바
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            // 프로그레스 바 배경
                            Container(
                              height: 60,
                              width: (screenWidth - 72) *
                                  (value / 100) *
                                  delayedAnimation,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    gradeColor.withValues(alpha: 0.2),
                                    gradeColor.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),

                            // 프로그레스 바 전경
                            Container(
                              height: 60,
                              width: (screenWidth - 72) *
                                  (value / 100) *
                                  delayedAnimation,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    gradeColor.withValues(alpha: 0.05),
                                    gradeColor.withValues(alpha: 0.02),
                                  ],
                                ),
                                border: Border(
                                  right: BorderSide(
                                    color: gradeColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 콘텐츠
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // 아이콘
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: gradeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: gradeColor.withValues(alpha: 0.3),
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
                            const SizedBox(width: 12),

                            // 이름과 등급
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stat['name'] as String,
                                    style: GoogleFonts.notoSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    grade,
                                    style: GoogleFonts.notoSans(
                                      fontSize: 11,
                                      color: gradeColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 수치
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  value.toStringAsFixed(1),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: gradeColor,
                                  ),
                                ),
                                Text(
                                  'POINT',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 등급별 색상
  Color _getGradeColor(String grade) {
    if (grade.contains('전문가')) {
      return const Color(0xFF9C27B0); // 보라색 (전설)
    } else if (grade.contains('고급')) {
      return AppColors.success; // 초록색 (고급)
    } else if (grade.contains('중급')) {
      return AppColors.warning; // 주황색 (중급)
    } else {
      return AppColors.textSecondary; // 회색 (초급)
    }
  }

  // 빠른 정보 표시 (레이더 차트 터치 시)
  void _showStatQuickInfo(String statName, double value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              '$statName: ${value.toStringAsFixed(1)}%',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ✅ 개선된 RPG 스타일 상세 정보 다이얼로그 (BuildContext 추가)
  void _showRPGStatDetails(
      BuildContext context, String statName, double value, String grade) {
    final statDetails = _getStatDetails(statName);
    final gradeColor = _getGradeColor(grade);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: gradeColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradeColor.withValues(alpha: 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ 개선된 헤더 - RPG 스타일
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            gradeColor.withValues(alpha: 0.1),
                            gradeColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: gradeColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // ✅ 개선된 아이콘 컨테이너
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  gradeColor.withValues(alpha: 0.2),
                                  gradeColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: gradeColor.withValues(alpha: 0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: gradeColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                statDetails['icon'],
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ 능력치 이름
                                Text(
                                  '$statName 상세정보',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // ✅ 수치와 등급 - 개선된 디자인 (오버플로우 방지)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            gradeColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              gradeColor.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            value.toStringAsFixed(1),
                                            style: GoogleFonts.notoSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: gradeColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'POINT',
                                            style: GoogleFonts.notoSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: gradeColor.withValues(
                                                  alpha: 0.8),
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            gradeColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color:
                                              gradeColor.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        grade,
                                        style: GoogleFonts.notoSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: gradeColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ 개선된 컨텐츠 영역
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildRPGInfoSection(
                            '핵심 역할',
                            statDetails['role'],
                            Icons.star_rounded,
                            AppColors.warning,
                          ),
                          const SizedBox(height: 16),
                          _buildRPGInfoSection(
                            '성장 방법',
                            statDetails['growth'],
                            Icons.trending_up_rounded,
                            AppColors.success,
                          ),
                          const SizedBox(height: 16),
                          _buildRPGInfoSection(
                            '등반에서의 의미',
                            statDetails['meaning'],
                            Icons.terrain_rounded,
                            AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    // ✅ 개선된 버튼 영역
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradeColor,
                                gradeColor.withValues(alpha: 0.8)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: gradeColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              '확인',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // ✅ 닫기 버튼 - Stack의 Positioned로 우측 상단에 고정
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 개선된 정보 섹션
  Widget _buildRPGInfoSection(
      String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatDetails(String statName) {
    final details = {
      '체력': {
        'icon': '💪',
        'role': '등반력 공식에 직접 적용되는 3대 핵심 능력치 중 하나입니다.',
        'growth': '• 달리기, 헬스 등 신체 활동 모임 참여\n• 운동 관련 퀘스트 완료\n• 체력 챌린지 성공',
        'meaning': '"긴 등반에서의 지구력과 체력적 한계를 극복하는 힘"',
      },
      '지식': {
        'icon': '🧠',
        'role': '등반력 공식에 직접 적용되는 3대 핵심 능력치 중 하나입니다.',
        'growth': '• 독서, 학습 등 지적 활동 모임 참여\n• 지식 관련 퀘스트 완료\n• 30일 글쓰기 챌린지 성공',
        'meaning': '"등반 경로 선택과 위험 상황 대처 능력"',
      },
      '기술': {
        'icon': '🛠️',
        'role': '등반력 공식에 직접 적용되는 3대 핵심 능력치 중 하나입니다.',
        'growth': '• 모든 퀘스트 완료 시 낮은 확률로 획득\n• 기술적 숙련이 필요한 활동 참여\n• 연속 퀘스트 완료',
        'meaning': '"등반 효율성과 어려운 구간에서의 기술적 돌파력"',
      },
      '사교성': {
        'icon': '🤝',
        'role': '등반 시간을 단축시키고 길드 보너스 효과를 증가시킵니다.',
        'growth': '• 모든 모임 참여\n• 소셜 활동 (칭찬, 친구 추가)\n• 길드 퀘스트 참여',
        'meaning': '"팀 등반에서의 협력과 정보 공유를 통한 효율성"',
      },
      '의지': {
        'icon': '🔥',
        'role': '등반 성공 확률을 직접적으로 보정합니다. (의지% × 0.1)',
        'growth': '• 챌린지 성공\n• 연속 접속 달성\n• 퀘스트 올클리어',
        'meaning': '"극한 상황에서도 굴복하지 않는 불굴의 정신력"',
      },
    };

    return details[statName] ?? details['체력']!;
  }
}
