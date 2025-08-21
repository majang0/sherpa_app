import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_badge_provider.dart';
import '../../../../shared/providers/global_game_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_constants.dart';

class GrowthSummaryCard extends ConsumerWidget {
  const GrowthSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    final userTitle = ref.watch(globalUserTitleProvider);
    final pointData = ref.watch(globalPointProvider);
    final gameSystem = ref.watch(globalGameProvider);
    final equippedBadges = ref.watch(globalEquippedBadgesProvider);

    // ✅ 실제 등반력 계산 (글로벌 데이터 기반)
    final climbingPower = gameSystem.calculateFinalClimbingPower(
      level: user.level,
      titleBonus: userTitle.bonus,
      stamina: user.stats.stamina,
      knowledge: user.stats.knowledge,
      technique: user.stats.technique,
      equippedBadges: equippedBadges,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E3A8A).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 섹션 제목
                Text(
                  '성장 요약',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    // 왼쪽: 레이더 차트
                    Expanded(
                      flex: 1,
                      child: _buildRadarChart(user.stats),
                    ),
                    
                    const SizedBox(width: 24),
                    
                    // 오른쪽: 핵심 스탯
                    Expanded(
                      flex: 1,
                      child: _buildCoreStats(user, climbingPower, pointData.totalPoints),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadarChart(GlobalStats stats) {
    return Container(
      height: 180,
      child: CustomPaint(
        painter: RadarChartPainter(stats),
        child: Center(
          child: Text(
            '',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoreStats(GlobalUser user, double climbingPower, int totalPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 등반력
        _buildStatItem(
          '등반력',
          '${climbingPower.toInt()}',
          Icons.trending_up,
          Color(0xFF10B981),
          isMain: true,
        ),
        
        const SizedBox(height: 16),
        
        // 현재 레벨
        _buildStatItem(
          '레벨',
          '${user.level}',
          Icons.star,
          Color(0xFFF59E0B),
        ),
        
        const SizedBox(height: 12),
        
        // 보유 뱃지
        _buildStatItem(
          '뱃지',
          '${user.ownedBadgeIds.length}개',
          Icons.emoji_events,
          Color(0xFF8B5CF6),
        ),
        
        const SizedBox(height: 12),
        
        // 포인트
        _buildStatItem(
          '포인트',
          '${totalPoints}P',
          Icons.paid,
          Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, {bool isMain = false}) {
    return Row(
      children: [
        Container(
          width: isMain ? 40 : 32,
          height: isMain ? 40 : 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isMain ? 12 : 10),
          ),
          child: Icon(
            icon,
            color: color,
            size: isMain ? 20 : 16,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: isMain ? 20 : 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: isMain ? 12 : 10,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final GlobalStats stats;
  
  RadarChartPainter(this.stats);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // 배경 원들 그리기
    final backgroundPaint = Paint()
      ..color = Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, (radius * i / 5), backgroundPaint);
    }
    
    // 축 그리기
    final axisPaint = Paint()
      ..color = Color(0xFFCBD5E1)
      ..strokeWidth = 1;
    
    final angles = [
      -math.pi / 2, // 체력 (위)
      -math.pi / 10, // 지식 (오른쪽 위)
      math.pi / 2, // 기술 (오른쪽 아래)
      math.pi - math.pi / 10, // 사교성 (왼쪽 아래)
      math.pi + math.pi / 10, // 의지 (왼쪽 위)
    ];
    
    for (double angle in angles) {
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, end, axisPaint);
    }
    
    // 데이터 다각형 그리기
    final values = [
      stats.stamina / 10, // 0-1 범위로 정규화
      stats.knowledge / 10,
      stats.technique / 10,
      stats.sociality / 10,
      stats.willpower / 10,
    ];
    
    final path = Path();
    final fillPaint = Paint()
      ..color = Color(0xFF3B82F6).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < values.length; i++) {
      final value = values[i].clamp(0.0, 1.0);
      final angle = angles[i];
      final point = Offset(
        center.dx + radius * value * math.cos(angle),
        center.dy + radius * value * math.sin(angle),
      );
      
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
    
    // 데이터 포인트 그리기
    final pointPaint = Paint()
      ..color = Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < values.length; i++) {
      final value = values[i].clamp(0.0, 1.0);
      final angle = angles[i];
      final point = Offset(
        center.dx + radius * value * math.cos(angle),
        center.dy + radius * value * math.sin(angle),
      );
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
