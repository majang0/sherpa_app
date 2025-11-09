import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/modern_colors.dart';
import '../../../../core/animation/micro_interactions.dart';

/// Goal Hero Widget - 현재 목표 시각화 (280px Glassmorphism 카드)
///
/// 2025 Design: 큰 숫자, 그라데이션, 이중 그림자, Glassmorphism
/// 가장 눈에 띄는 섹션으로 사용자의 현재 상태를 임팩트 있게 표현
class GoalHeroWidget extends StatelessWidget {
  final int activeGoalsCount;
  final int achievedCount;
  final int inProgressCount;
  final int upcomingCount;
  final int totalCount;
  final double completionRate;
  final VoidCallback onAIAnalysisTap;

  const GoalHeroWidget({
    super.key,
    required this.activeGoalsCount,
    required this.achievedCount,
    required this.inProgressCount,
    required this.upcomingCount,
    required this.totalCount,
    required this.completionRate,
    required this.onAIAnalysisTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      height: 280,
      decoration: BoxDecoration(
        // Glassmorphism!
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.climbing.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 장식 (원형 그라데이션 오버레이)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ModernColors.climbing.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 타이틀
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 20,
                      color: ModernColors.climbing,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '현재 진행중인 목표',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textSecondary.withValues(alpha: 0.8),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. 큰 숫자 표시 (임팩트!)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          ModernColors.climbing,
                          ModernColors.climbing.withValues(alpha: 0.7),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        '$activeGoalsCount',
                        style: GoogleFonts.notoSans(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: Colors.white, // ShaderMask가 색상 적용
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '개',
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 3. 진행률 바 (두껍게!)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '전체 달성률',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 12,
                        child: Stack(
                          children: [
                            // 배경
                            Container(
                              color: Colors.black.withValues(alpha: 0.08),
                            ),
                            // 진행률 (그라데이션)
                            FractionallySizedBox(
                              widthFactor: completionRate.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ModernColors.climbing,
                                      ModernColors.success,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(completionRate * 100).toInt()}%',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.climbing,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // 4. 하단: 3개 스탯 + AI 버튼
                Row(
                  children: [
                    _buildMiniStat(
                      Icons.check_circle,
                      '$achievedCount',
                      '달성',
                      ModernColors.success,
                    ),
                    const SizedBox(width: 8),
                    _buildMiniStat(
                      Icons.pending,
                      '$inProgressCount',
                      '진행중',
                      ModernColors.climbing,
                    ),
                    const SizedBox(width: 8),
                    _buildMiniStat(
                      Icons.upcoming,
                      '$upcomingCount',
                      '예정',
                      ModernColors.meeting,
                    ),
                    const Spacer(),
                    _buildAIButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mini Stat - 작은 통계 표시
  Widget _buildMiniStat(IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// AI 분석 버튼
  Widget _buildAIButton() {
    return MicroInteractions.tapResponse(
      onTap: onAIAnalysisTap,
      scaleDownTo: 0.95,
      enableHaptic: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernColors.primary.withValues(alpha: 0.15),
              ModernColors.primary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ModernColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: ModernColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'AI 분석',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ModernColors.primary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
