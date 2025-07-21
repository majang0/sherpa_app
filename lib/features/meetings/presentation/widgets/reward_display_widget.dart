import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/available_meeting_model.dart';

/// 📊 보상 표시 위젯
/// 모임 참여로 받은 보상들을 시각적으로 표시
class RewardDisplayWidget extends StatefulWidget {
  final AvailableMeeting meeting;
  final AnimationController animationController;

  const RewardDisplayWidget({
    super.key,
    required this.meeting,
    required this.animationController,
  });

  @override
  State<RewardDisplayWidget> createState() => _RewardDisplayWidgetState();
}

class _RewardDisplayWidgetState extends State<RewardDisplayWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _rewardAnimations;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    
    // 보상별 개별 애니메이션 생성
    _rewardAnimations = List.generate(3, (index) => AnimationController(
      duration: Duration(milliseconds: 600 + (index * 200)),
      vsync: this,
    ));

    _scaleAnimations = _rewardAnimations.map((controller) => 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      )
    ).toList();

    _fadeAnimations = _rewardAnimations.map((controller) => 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      )
    ).toList();

    // 순차적 애니메이션 시작
    _startSequentialAnimations();
  }

  void _startSequentialAnimations() async {
    for (int i = 0; i < _rewardAnimations.length; i++) {
      await Future.delayed(Duration(milliseconds: 300 + (i * 200)));
      if (mounted) {
        _rewardAnimations[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _rewardAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expReward = widget.meeting.experienceReward;
    final pointReward = widget.meeting.participationReward;
    final statRewards = widget.meeting.statRewards;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Text(
            '🏆 획득한 보상',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 주요 보상들 (경험치, 포인트)
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _rewardAnimations[0],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimations[0].value,
                      child: FadeTransition(
                        opacity: _fadeAnimations[0],
                        child: _buildMainRewardCard(
                          icon: '⭐',
                          title: '경험치',
                          value: '+${expReward.toStringAsFixed(0)}',
                          subtitle: '성장의 힘',
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: AnimatedBuilder(
                  animation: _rewardAnimations[1],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimations[1].value,
                      child: FadeTransition(
                        opacity: _fadeAnimations[1],
                        child: _buildMainRewardCard(
                          icon: '💎',
                          title: '포인트',
                          value: '+${pointReward.toStringAsFixed(0)}',
                          subtitle: '모험의 대가',
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          // 능력치 보상
          if (statRewards.isNotEmpty) ...[
            const SizedBox(height: 20),
            
            AnimatedBuilder(
              animation: _rewardAnimations[2],
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimations[2].value,
                  child: FadeTransition(
                    opacity: _fadeAnimations[2],
                    child: _buildStatRewardsSection(statRewards),
                  ),
                );
              },
            ),
          ],
          
          const SizedBox(height: 20),
          
          // 특별 메시지
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.meeting.category.color.withValues(alpha: 0.1),
                  widget.meeting.category.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.meeting.category.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '🌟',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '모험을 통해 더 강해졌어요!\n계속해서 새로운 도전을 해보세요!',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.meeting.category.color,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 메인 보상 카드
  Widget _buildMainRewardCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 값
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // 제목
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 2),
          
          // 부제목
          Text(
            subtitle,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 능력치 보상 섹션
  Widget _buildStatRewardsSection(Map<String, double> statRewards) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '💪 능력치 성장',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 능력치 보상 그리드
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statRewards.entries.map((entry) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getStatEmoji(entry.key),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatDisplayName(entry.key),
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${entry.value.toStringAsFixed(1)}',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  String _getStatDisplayName(String statKey) {
    switch (statKey) {
      case 'stamina': return '체력';
      case 'knowledge': return '지식';
      case 'technique': return '기술';
      case 'sociality': return '사교성';
      case 'willpower': return '의지력';
      default: return statKey;
    }
  }

  String _getStatEmoji(String statKey) {
    switch (statKey) {
      case 'stamina': return '💪';
      case 'knowledge': return '🧠';
      case 'technique': return '🛠️';
      case 'sociality': return '🤝';
      case 'willpower': return '🔥';
      default: return '⭐';
    }
  }
}
