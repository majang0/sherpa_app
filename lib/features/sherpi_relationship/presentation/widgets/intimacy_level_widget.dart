import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../providers/relationship_provider.dart';
import '../../../../shared/models/sherpi_relationship_model.dart';

/// 💝 친밀도 레벨 표시 위젯
/// 
/// 셰르피와의 관계 진행 상황을 시각적으로 표시합니다.
class IntimacyLevelWidget extends ConsumerWidget {
  final bool showDetails;
  final double height;

  const IntimacyLevelWidget({
    super.key,
    this.showDetails = true,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relationship = ref.watch(sherpiRelationshipProvider);
    final stats = ref.watch(relationshipStatsProvider);
    final progress = ref.watch(nextLevelProgressProvider);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getIntimacyColor(relationship.intimacyLevel).withOpacity(0.1),
            _getIntimacyColor(relationship.intimacyLevel).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getIntimacyColor(relationship.intimacyLevel).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 친밀도 레벨 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getIntimacyColor(relationship.intimacyLevel),
              boxShadow: [
                BoxShadow(
                  color: _getIntimacyColor(relationship.intimacyLevel).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${relationship.intimacyLevel}',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          )
          .animate()
          .scale(
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),
          
          const SizedBox(width: 16),
          
          // 관계 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 관계 타이틀
                Text(
                  relationship.relationshipTitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                if (showDetails) ...[
                  // 진행률 바
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getIntimacyColor(relationship.intimacyLevel),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideX(begin: -0.2, duration: 400.ms),
                  
                  const SizedBox(height: 4),
                  
                  // 통계 정보
                  Text(
                    '함께한 ${stats['daysTogether']}일 • ${stats['totalInteractions']}번의 만남',
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // 감정 동기화 표시
          if (showDetails && relationship.emotionalSync > 0.1)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmotionalSyncIcon(relationship.emotionalSync),
                  color: _getIntimacyColor(relationship.intimacyLevel),
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  relationship.emotionalSyncDescription,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 600.ms)
            .scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
    )
    .animate()
    .fadeIn()
    .slideY(begin: 0.3, duration: 500.ms);
  }

  /// 친밀도 레벨별 색상
  Color _getIntimacyColor(int level) {
    switch (level) {
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.blue.shade300;
      case 3:
        return Colors.green.shade400;
      case 4:
        return Colors.orange.shade400;
      case 5:
        return Colors.purple.shade400;
      case 6:
        return Colors.pink.shade400;
      case 7:
        return Colors.red.shade400;
      case 8:
        return Colors.indigo.shade500;
      case 9:
        return Colors.amber.shade500;
      case 10:
        return Colors.deepPurple.shade600;
      default:
        return AppColors.primary;
    }
  }

  /// 감정 동기화 레벨별 아이콘
  IconData _getEmotionalSyncIcon(double sync) {
    if (sync >= 0.8) return Icons.favorite;
    if (sync >= 0.6) return Icons.favorite_border;
    if (sync >= 0.4) return Icons.emoji_emotions;
    if (sync >= 0.2) return Icons.sentiment_satisfied;
    return Icons.sentiment_neutral;
  }
}

/// 🎯 간단한 친밀도 표시 (작은 공간용)
class CompactIntimacyWidget extends ConsumerWidget {
  const CompactIntimacyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relationship = ref.watch(sherpiRelationshipProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getIntimacyColor(relationship.intimacyLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getIntimacyColor(relationship.intimacyLevel).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getIntimacyColor(relationship.intimacyLevel),
            ),
            child: Center(
              child: Text(
                '${relationship.intimacyLevel}',
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            relationship.relationshipTitle,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntimacyColor(int level) {
    switch (level) {
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.blue.shade300;
      case 3:
        return Colors.green.shade400;
      case 4:
        return Colors.orange.shade400;
      case 5:
        return Colors.purple.shade400;
      case 6:
        return Colors.pink.shade400;
      case 7:
        return Colors.red.shade400;
      case 8:
        return Colors.indigo.shade500;
      case 9:
        return Colors.amber.shade500;
      case 10:
        return Colors.deepPurple.shade600;
      default:
        return Colors.blue.shade400;
    }
  }
}