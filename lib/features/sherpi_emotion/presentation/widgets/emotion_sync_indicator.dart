import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../providers/emotion_analysis_provider.dart';
import '../../models/emotion_analysis_model.dart';
import '../../../sherpi_relationship/providers/relationship_provider.dart';

/// 💕 감정 동기화 지표 위젯
/// 
/// 사용자와 Sherpi의 감정 동기화 상태를 시각적으로 표시합니다.
class EmotionSyncIndicator extends ConsumerWidget {
  final bool isCompact;
  final bool showLabel;

  const EmotionSyncIndicator({
    super.key,
    this.isCompact = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotionState = ref.watch(emotionAnalysisProvider);
    final relationship = ref.watch(sherpiRelationshipProvider);
    
    final syncLevel = EmotionalSyncLevelExtension.fromValue(relationship.emotionalSync);
    final currentEmotion = emotionState.currentAnalysis?.primaryEmotion;
    
    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSyncColor(syncLevel).withOpacity(0.1),
            _getSyncColor(syncLevel).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
        border: Border.all(
          color: _getSyncColor(syncLevel).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: isCompact ? _buildCompactView(syncLevel, currentEmotion) : _buildFullView(syncLevel, currentEmotion, relationship),
    );
  }

  /// 🎯 간단한 뷰 (컴팩트 모드)
  Widget _buildCompactView(EmotionalSyncLevel syncLevel, UserEmotionState? currentEmotion) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 동기화 상태 아이콘
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getSyncColor(syncLevel),
          ),
          child: Center(
            child: Text(
              syncLevel.emoji,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            syncLevel.description,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  /// 📊 전체 뷰
  Widget _buildFullView(EmotionalSyncLevel syncLevel, UserEmotionState? currentEmotion, relationship) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getSyncColor(syncLevel),
                boxShadow: [
                  BoxShadow(
                    color: _getSyncColor(syncLevel).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  syncLevel.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '감정 동기화',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    syncLevel.description,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 동기화 퍼센트
            Text(
              '${(relationship.emotionalSync * 100).toInt()}%',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getSyncColor(syncLevel),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 진행률 바
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: relationship.emotionalSync,
            child: Container(
              decoration: BoxDecoration(
                color: _getSyncColor(syncLevel),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms)
        .slideX(begin: -0.2, duration: 400.ms),
        
        // 현재 감정 상태 (있는 경우)
        if (currentEmotion != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _getEmotionIcon(currentEmotion),
                size: 16,
                color: _getEmotionColor(currentEmotion),
              ),
              const SizedBox(width: 6),
              Text(
                '현재 기분: ${_getEmotionText(currentEmotion)}',
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 🎨 동기화 수준별 색상
  Color _getSyncColor(EmotionalSyncLevel level) {
    switch (level) {
      case EmotionalSyncLevel.none:
        return Colors.grey.shade400;
      case EmotionalSyncLevel.basic:
        return Colors.blue.shade300;
      case EmotionalSyncLevel.good:
        return Colors.green.shade400;
      case EmotionalSyncLevel.strong:
        return Colors.purple.shade400;
      case EmotionalSyncLevel.perfect:
        return Colors.pink.shade500;
    }
  }

  /// 😊 감정별 아이콘
  IconData _getEmotionIcon(UserEmotionState emotion) {
    switch (emotion) {
      case UserEmotionState.positive:
        return Icons.sentiment_very_satisfied;
      case UserEmotionState.negative:
        return Icons.sentiment_dissatisfied;
      case UserEmotionState.neutral:
        return Icons.sentiment_neutral;
      case UserEmotionState.motivated:
        return Icons.local_fire_department;
      case UserEmotionState.tired:
        return Icons.bedtime;
      case UserEmotionState.excited:
        return Icons.celebration;
      case UserEmotionState.stressed:
        return Icons.psychology_alt;
      case UserEmotionState.contemplative:
        return Icons.lightbulb_outline;
    }
  }

  /// 🎨 감정별 색상
  Color _getEmotionColor(UserEmotionState emotion) {
    switch (emotion) {
      case UserEmotionState.positive:
        return Colors.green.shade500;
      case UserEmotionState.negative:
        return Colors.red.shade400;
      case UserEmotionState.neutral:
        return Colors.grey.shade500;
      case UserEmotionState.motivated:
        return Colors.orange.shade500;
      case UserEmotionState.tired:
        return Colors.indigo.shade300;
      case UserEmotionState.excited:
        return Colors.amber.shade500;
      case UserEmotionState.stressed:
        return Colors.red.shade300;
      case UserEmotionState.contemplative:
        return Colors.purple.shade400;
    }
  }

  /// 📱 감정별 텍스트
  String _getEmotionText(UserEmotionState emotion) {
    switch (emotion) {
      case UserEmotionState.positive:
        return '긍정적';
      case UserEmotionState.negative:
        return '힘들어함';
      case UserEmotionState.neutral:
        return '평온함';
      case UserEmotionState.motivated:
        return '의욕적';
      case UserEmotionState.tired:
        return '피곤함';
      case UserEmotionState.excited:
        return '신남';
      case UserEmotionState.stressed:
        return '스트레스';
      case UserEmotionState.contemplative:
        return '고민중';
    }
  }
}