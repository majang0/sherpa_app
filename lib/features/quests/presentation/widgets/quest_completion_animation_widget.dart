import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../core/theme/modern_colors.dart';
import '../../models/quest_instance_model.dart';
import '../../models/quest_template_model.dart';

/// 퀘스트 완료 애니메이션 위젯 (내부 컨트롤러 사용)
class QuestCompletionAnimationWidget extends ConsumerStatefulWidget {
  final AnimationController? animationController; // 선택사항 (사용안함)

  const QuestCompletionAnimationWidget({
    Key? key,
    this.animationController, // 선택사항으로 변경
  }) : super(key: key);

  @override
  ConsumerState<QuestCompletionAnimationWidget> createState() =>
      QuestCompletionAnimationState();
}

class QuestCompletionAnimationState
    extends ConsumerState<QuestCompletionAnimationWidget>
    with SingleTickerProviderStateMixin {
  QuestInstance? _completedQuest;
  QuestCompletionBonus? _completionBonus;
  String? _bonusTitle;
  late AnimationController _internalController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<_ParticleData> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    _internalController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _internalController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _internalController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _internalController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    _internalController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 자동으로 사라지지 않고 클릭을 기다림
      }
    });
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  void showCompletionAnimation(QuestInstance quest) {
    setState(() {
      _completedQuest = quest;
      _completionBonus = null;
      _bonusTitle = null;
      _generateParticles();
    });

    // 내부 컨트롤러만 사용 (외부 컨트롤러 조작 제거)
    _internalController.forward(from: 0.0);
  }

  /// 🎁 보상상자 애니메이션 표시 (일일/주간 퀘스트 마스터 보상)
  void showBonusAnimation(QuestCompletionBonus bonus, String title) {
    setState(() {
      _completedQuest = null;
      _completionBonus = bonus;
      _bonusTitle = title;
      _generateParticles();
    });

    _internalController.forward(from: 0.0);
  }

  void _hideAnimation() {
    _internalController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _completedQuest = null;
          _completionBonus = null;
          _bonusTitle = null;
          _particles.clear();
        });
      }
    });
    // 외부 컨트롤러 조작 제거 (전체 화면 fadeOut 방지)
  }

  void _generateParticles() {
    _particles.clear();

    // 다양한 색상의 파티클 생성
    final colors = [
      ModernColors.primary,
      ModernColors.accent,
      ModernColors.success,
      ModernColors.warning,
      Colors.purple,
      Colors.pink,
    ];

    for (int i = 0; i < 30; i++) {
      _particles.add(_ParticleData(
        x: _random.nextDouble() * 2 - 1,
        y: _random.nextDouble() * 2 - 1,
        size: _random.nextDouble() * 4 + 2,
        color: colors[_random.nextInt(colors.length)],
        velocity: _random.nextDouble() * 2 + 1,
        angle: _random.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completedQuest == null && _completionBonus == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _internalController,
      builder: (context, child) {
        return Stack(
          children: [
            // 배경 오버레이 (클릭 가능)
            if (_fadeAnimation.value > 0)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _hideAnimation,
                  child: Container(
                    color: Colors.black
                        .withValues(alpha: _fadeAnimation.value * 0.5),
                  ),
                ),
              ),

            // 파티클 효과
            ..._buildParticles(),

            // 메인 완료 카드
            Center(
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: GestureDetector(
                      onTap: _hideAnimation,
                      child: _buildCompletionCard(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      final progress = _internalController.value;
      final x = particle.x * 200 * progress * particle.velocity;
      final y = particle.y * 200 * progress * particle.velocity +
          (progress * progress * 100);
      final opacity = math.max(0.0, 1.0 - progress);

      return Positioned(
        left: MediaQuery.of(context).size.width / 2 + x,
        top: MediaQuery.of(context).size.height / 2 + y,
        child: Transform.rotate(
          angle: particle.angle + progress * math.pi * 2,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: particle.color.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCompletionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 완료 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ModernColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernColors.success.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),

          const SizedBox(height: 20),

          // 퀘스트 완료 메시지
          Text(
            _completionBonus != null ? '보상상자 오픈!' : '퀘스트 완료!',
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _getDisplayTitle(),
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 보상 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ModernColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '획득한 보상',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // XP 보상
                    _buildRewardItem(
                      Icons.trending_up,
                      '+${_getExperienceReward()} XP',
                      ModernColors.primary,
                    ),
                    if (_getPointsReward() > 0) ...[
                      const SizedBox(width: 24),
                      // 포인트 보상
                      _buildRewardItem(
                        Icons.monetization_on,
                        '+${_getPointsReward()} P',
                        ModernColors.warning,
                      ),
                    ],
                  ],
                ),
                if (_hasStatReward() && _isStatGranted()) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ModernColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ModernColors.success.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: ModernColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_getStatEmojiForReward()} ${_getStatNameForReward()} +${_getStatIncrease()}',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getStatEmoji(String statType) {
    switch (statType) {
      case 'stamina':
        return '💪';
      case 'knowledge':
        return '🧠';
      case 'technique':
        return '🛠️';
      case 'sociality':
        return '🤝';
      case 'willpower':
        return '🔥';
      default:
        return '📊';
    }
  }

  String _getStatName(String statType) {
    switch (statType) {
      case 'stamina':
        return '체력';
      case 'knowledge':
        return '지식';
      case 'technique':
        return '기술';
      case 'sociality':
        return '사교성';
      case 'willpower':
        return '의지';
      default:
        return '능력치';
    }
  }

  /// 헬퍼 메서드들 - V1/V2 시스템 호환성 + 보상상자 지원
  String _getDisplayTitle() {
    if (_completedQuest != null) {
      return _completedQuest!.title;
    } else if (_completionBonus != null && _bonusTitle != null) {
      return _bonusTitle!;
    }
    return '';
  }

  int _getExperienceReward() {
    if (_completedQuest != null) {
      return _completedQuest!.rewards.experience.toInt();
    } else if (_completionBonus != null) {
      return _completionBonus!.experienceBonus.toInt();
    }
    return 0;
  }

  int _getPointsReward() {
    if (_completedQuest != null) {
      return _completedQuest!.rewards.points.toInt();
    } else if (_completionBonus != null) {
      return _completionBonus!.pointsBonus.toInt();
    }
    return 0;
  }

  bool _hasStatReward() {
    if (_completedQuest != null) {
      return _completedQuest!.rewards.statType != null;
    }
    // 보상상자에는 능력치 보상이 없음
    return false;
  }

  bool _isStatGranted() {
    if (_completedQuest != null) {
      return _completedQuest!.statGranted == true;
    }
    // 보상상자에는 능력치 보상이 없음
    return false;
  }

  String _getStatEmojiForReward() {
    return _completedQuest?.categoryEmoji ?? '📊';
  }

  String _getStatNameForReward() {
    return _completedQuest?.category.displayName ?? '능력치';
  }

  double _getStatIncrease() {
    return _completedQuest?.rewards.statIncrease ?? 0.0;
  }
}

class _ParticleData {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double velocity;
  final double angle;

  _ParticleData({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
    required this.angle,
  });
}
