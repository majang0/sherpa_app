import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/app_colors.dart';

class RepresentativeDashboard extends ConsumerWidget {
  const RepresentativeDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(globalUserProvider);
    final pointData = ref.watch(globalPointProvider);
    
    // ✅ 실제 데이터 계산
    final totalReadingPages = user.dailyRecords.totalReadingPages;
    final totalMeetings = user.dailyRecords.totalMeetings;
    final climbingCount = user.dailyRecords.climbingLogs.length;
    final successfulClimbings = user.dailyRecords.successfulClimbings;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E3A8A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Row(
                  children: [
                    Text(
                      '${user.name}님의 대표 기록',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.trending_up,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // ✅ 실제 데이터 기반 대표 기록 카드들
                Row(
                  children: [
                    Expanded(
                      child: _buildRecordCard(
                        '걸음수',
                        '${user.dailyRecords.todaySteps}',
                        '오늘',
                        Icons.directions_walk,
                        Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRecordCard(
                        '등반',
                        '$climbingCount회',
                        '전체',
                        Icons.terrain,
                        Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildRecordCard(
                        '모임',
                        '$totalMeetings회',
                        '전체',
                        Icons.people,
                        Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRecordCard(
                        '포인트',
                        '${pointData.totalPoints}P',
                        '보유중',
                        Icons.paid,
                        Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // ✅ 추가: 연속 접속과 성공률 카드
                Row(
                  children: [
                    Expanded(
                      child: _buildRecordCard(
                        '연속접속',
                        '${user.dailyRecords.consecutiveDays}일',
                        '현재',
                        Icons.calendar_today,
                        Color(0xFF06B6D4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRecordCard(
                        '등반성공',
                        '${(user.dailyRecords.climbingSuccessRate * 100).toInt()}%',
                        '성공률',
                        Icons.trending_up,
                        Color(0xFF84CC16),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // ✅ 실제 데이터 기반 요약 메시지
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insights,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getMotivationalMessage(user),
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 사용자 데이터에 기반한 동기부여 메시지
  String _getMotivationalMessage(GlobalUser user) {
    final consecutiveDays = user.dailyRecords.consecutiveDays;
    final level = user.level;
    final climbingCount = user.dailyRecords.climbingLogs.length;
    
    if (consecutiveDays >= 30) {
      return '타지하는 일관성! $consecutiveDays일 연속 접속 중 🔥';
    } else if (level >= 20) {
      return '레벨 $level 달성! 전문가의 길을 걸어가고 있어요 ✨';
    } else if (climbingCount >= 10) {
      return '등반 $climbingCount회 달성! 전설의 등반가가 되어가고 있어요 🏄‍♂️';
    } else {
      return '꿋꿋한 성장을 이어가고 있습니다! 💪';
    }
  }

  Widget _buildRecordCard(String title, String value, String period, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
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
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          
          Text(
            period,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
