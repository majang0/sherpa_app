// lib/shared/widgets/components/molecules/sherpa_quest_card_2025.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 셰르파 퀘스트/도전과제 카드 컴포넌트
/// 게임화 요소를 통한 목표 설정과 성취 추적 전용 카드
class SherpaQuestCard2025 extends StatefulWidget {
  final String questTitle;
  final String? description;
  final SherpaQuestType questType;
  final SherpaQuestStatus status;
  final SherpaQuestDifficulty difficulty;
  final double progress; // 0.0 - 1.0
  final int? currentValue;
  final int? targetValue;
  final String? progressUnit;
  final List<SherpaQuestReward>? rewards;
  final DateTime? deadline;
  final Duration? timeLeft;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onClaim;
  final SherpaQuestCardVariant2025 variant;
  final SherpaQuestCardSize2025 size;
  final bool showTimer;
  final bool showRewards;
  final bool enableMicroInteractions;
  final String? category;
  final Color? customColor;
  final Widget? backgroundWidget;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SherpaQuestCard2025({
    Key? key,
    required this.questTitle,
    this.description,
    this.questType = SherpaQuestType.daily,
    this.status = SherpaQuestStatus.available,
    this.difficulty = SherpaQuestDifficulty.easy,
    this.progress = 0.0,
    this.currentValue,
    this.targetValue,
    this.progressUnit,
    this.rewards,
    this.deadline,
    this.timeLeft,
    this.onTap,
    this.onStart,
    this.onClaim,
    this.variant = SherpaQuestCardVariant2025.glass,
    this.size = SherpaQuestCardSize2025.medium,
    this.showTimer = true,
    this.showRewards = true,
    this.enableMicroInteractions = true,
    this.category,
    this.customColor,
    this.backgroundWidget,
    this.padding,
    this.margin,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 일일 퀘스트
  factory SherpaQuestCard2025.daily({
    Key? key,
    required String questTitle,
    String? description,
    double progress = 0.0,
    int? currentValue,
    int? targetValue,
    String? progressUnit,
    List<SherpaQuestReward>? rewards,
    VoidCallback? onTap,
    VoidCallback? onStart,
    VoidCallback? onClaim,
  }) {
    return SherpaQuestCard2025(
      key: key,
      questTitle: questTitle,
      description: description,
      questType: SherpaQuestType.daily,
      difficulty: SherpaQuestDifficulty.easy,
      progress: progress,
      currentValue: currentValue,
      targetValue: targetValue,
      progressUnit: progressUnit,
      rewards: rewards,
      onTap: onTap,
      onStart: onStart,
      onClaim: onClaim,
      category: 'daily',
      timeLeft: const Duration(hours: 24),
    );
  }

  /// 주간 퀘스트
  factory SherpaQuestCard2025.weekly({
    Key? key,
    required String questTitle,
    String? description,
    double progress = 0.0,
    int? currentValue,
    int? targetValue,
    String? progressUnit,
    List<SherpaQuestReward>? rewards,
    VoidCallback? onTap,
    VoidCallback? onStart,
    VoidCallback? onClaim,
  }) {
    return SherpaQuestCard2025(
      key: key,
      questTitle: questTitle,
      description: description,
      questType: SherpaQuestType.weekly,
      difficulty: SherpaQuestDifficulty.medium,
      progress: progress,
      currentValue: currentValue,
      targetValue: targetValue,
      progressUnit: progressUnit,
      rewards: rewards,
      onTap: onTap,
      onStart: onStart,
      onClaim: onClaim,
      category: 'weekly',
      timeLeft: const Duration(days: 7),
      variant: SherpaQuestCardVariant2025.neu,
    );
  }

  /// 업적 퀘스트
  factory SherpaQuestCard2025.achievement({
    Key? key,
    required String questTitle,
    String? description,
    double progress = 0.0,
    int? currentValue,
    int? targetValue,
    String? progressUnit,
    List<SherpaQuestReward>? rewards,
    VoidCallback? onTap,
    VoidCallback? onStart,
    VoidCallback? onClaim,
  }) {
    return SherpaQuestCard2025(
      key: key,
      questTitle: questTitle,
      description: description,
      questType: SherpaQuestType.achievement,
      difficulty: SherpaQuestDifficulty.hard,
      progress: progress,
      currentValue: currentValue,
      targetValue: targetValue,
      progressUnit: progressUnit,
      rewards: rewards,
      onTap: onTap,
      onStart: onStart,
      onClaim: onClaim,
      category: 'achievement',
      showTimer: false,
      variant: SherpaQuestCardVariant2025.floating,
    );
  }

  /// 특별 이벤트 퀘스트
  factory SherpaQuestCard2025.special({
    Key? key,
    required String questTitle,
    String? description,
    double progress = 0.0,
    int? currentValue,
    int? targetValue,
    String? progressUnit,
    List<SherpaQuestReward>? rewards,
    Duration? timeLeft,
    VoidCallback? onTap,
    VoidCallback? onStart,
    VoidCallback? onClaim,
  }) {
    return SherpaQuestCard2025(
      key: key,
      questTitle: questTitle,
      description: description,
      questType: SherpaQuestType.special,
      difficulty: SherpaQuestDifficulty.legendary,
      progress: progress,
      currentValue: currentValue,
      targetValue: targetValue,
      progressUnit: progressUnit,
      rewards: rewards,
      timeLeft: timeLeft,
      onTap: onTap,
      onStart: onStart,
      onClaim: onClaim,
      category: 'special',
      variant: SherpaQuestCardVariant2025.glow,
    );
  }

  @override
  State<SherpaQuestCard2025> createState() => _SherpaQuestCard2025State();
}

class _SherpaQuestCard2025State extends State<SherpaQuestCard2025>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _progressController;
  late AnimationController _glowController;
  late AnimationController _timerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _timerAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: MicroInteractions.fast,
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: MicroInteractions.slow,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: MicroInteractions.easeOutQuart,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: MicroInteractions.easeOutQuart,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: MicroInteractions.easeInOutSine,
    ));

    _timerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: MicroInteractions.easeInOutSine,
    ));

    _progressController.forward();
    
    if (widget.variant == SherpaQuestCardVariant2025.glow) {
      _glowController.repeat(reverse: true);
    }

    if (widget.showTimer && widget.timeLeft != null) {
      _timerController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SherpaQuestCard2025 oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: MicroInteractions.easeOutQuart,
      ));
      _progressController.forward(from: 0);
    }
  }

  void _handleTap() {
    widget.onTap?.call();
  }

  void _handleHoverEnter() {
    if (!widget.enableMicroInteractions) return;
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _handleHoverExit() {
    if (!widget.enableMicroInteractions) return;
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getQuestCardConfiguration();

    Widget card = Container(
      margin: widget.margin,
      decoration: _getDecoration(config),
      child: _buildCardContent(config),
    );

    // 인터랙티브 래퍼 추가
    if (widget.onTap != null) {
      card = MouseRegion(
        onEnter: (_) => _handleHoverEnter(),
        onExit: (_) => _handleHoverExit(),
        child: GestureDetector(
          onTap: _handleTap,
          child: card,
        ),
      );
    }

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      card = AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: card,
      );
    }

    return card;
  }

  Widget _buildCardContent(QuestCardConfiguration config) {
    return Stack(
      children: [
        // 배경 위젯
        if (widget.backgroundWidget != null)
          Positioned.fill(child: widget.backgroundWidget!),
        
        // 메인 콘텐츠
        Padding(
          padding: widget.padding ?? config.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(config),
              if (widget.description != null) ...[
                SizedBox(height: config.spacing * 0.5),
                _buildDescription(config),
              ],
              SizedBox(height: config.spacing),
              _buildProgressSection(config),
              if (widget.showRewards && widget.rewards != null && widget.rewards!.isNotEmpty) ...[
                SizedBox(height: config.spacing),
                _buildRewards(config),
              ],
              if (widget.showTimer && widget.timeLeft != null) ...[
                SizedBox(height: config.spacing),
                _buildTimer(config),
              ],
              if (_shouldShowActionButton()) ...[
                SizedBox(height: config.spacing * 1.5),
                _buildActionButton(config),
              ],
            ],
          ),
        ),
        
        // 상태 인디케이터
        Positioned(
          top: 12,
          right: 12,
          child: _buildStatusIndicator(config),
        ),
        
        // 퀘스트 타입 뱃지
        Positioned(
          top: 12,
          left: 12,
          child: _buildQuestTypeBadge(config),
        ),
        
        // 난이도 표시
        Positioned(
          bottom: 12,
          right: 12,
          child: _buildDifficultyIndicator(config),
        ),
      ],
    );
  }

  Widget _buildHeader(QuestCardConfiguration config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.questTitle,
          style: GoogleFonts.notoSans(
            fontSize: config.titleSize,
            fontWeight: FontWeight.w700,
            color: AppColors2025.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDescription(QuestCardConfiguration config) {
    return Text(
      widget.description!,
      style: GoogleFonts.notoSans(
        fontSize: config.subtitleSize,
        color: AppColors2025.textSecondary,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressSection(QuestCardConfiguration config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '진행률',
              style: GoogleFonts.notoSans(
                fontSize: config.progressTextSize,
                fontWeight: FontWeight.w600,
                color: AppColors2025.textSecondary,
              ),
            ),
            Row(
              children: [
                if (widget.currentValue != null && widget.targetValue != null) ...[
                  Text(
                    '${widget.currentValue}/${widget.targetValue}',
                    style: GoogleFonts.notoSans(
                      fontSize: config.progressTextSize,
                      fontWeight: FontWeight.w600,
                      color: config.primaryColor,
                    ),
                  ),
                  if (widget.progressUnit != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      widget.progressUnit!,
                      style: GoogleFonts.notoSans(
                        fontSize: config.progressTextSize - 2,
                        color: AppColors2025.textTertiary,
                      ),
                    ),
                  ],
                ],
                const SizedBox(width: 8),
                Text(
                  '${(widget.progress * 100).toInt()}%',
                  style: GoogleFonts.notoSans(
                    fontSize: config.progressTextSize,
                    fontWeight: FontWeight.w700,
                    color: config.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors2025.neuBase,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        config.primaryColor,
                        config.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: config.primaryColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRewards(QuestCardConfiguration config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '보상',
          style: GoogleFonts.notoSans(
            fontSize: config.progressTextSize,
            fontWeight: FontWeight.w600,
            color: AppColors2025.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.rewards!.map((reward) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: reward.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(
                  color: reward.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    reward.icon,
                    size: 14,
                    color: reward.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reward.amount.toString(),
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: reward.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimer(QuestCardConfiguration config) {
    return AnimatedBuilder(
      animation: _timerAnimation,
      builder: (context, child) {
        final isUrgent = widget.timeLeft!.inHours < 2;
        final timerColor = isUrgent 
            ? AppColors2025.error.withOpacity(0.7 + 0.3 * _timerAnimation.value)
            : AppColors2025.warning;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: timerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            border: Border.all(
              color: timerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                size: 16,
                color: timerColor,
              ),
              const SizedBox(width: 6),
              Text(
                _formatTimeLeft(),
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: timerColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(QuestCardConfiguration config) {
    final isCompleted = widget.status == SherpaQuestStatus.completed;
    final isClaimable = widget.status == SherpaQuestStatus.claimable;
    final isLocked = widget.status == SherpaQuestStatus.locked;

    String buttonText;
    VoidCallback? onPressed;
    Color backgroundColor;

    if (isLocked) {
      buttonText = '잠김';
      onPressed = null;
      backgroundColor = AppColors2025.textQuaternary;
    } else if (isCompleted) {
      buttonText = '완료됨';
      onPressed = null;
      backgroundColor = AppColors2025.success;
    } else if (isClaimable) {
      buttonText = '보상 받기';
      onPressed = widget.onClaim;
      backgroundColor = config.primaryColor;
    } else {
      buttonText = '시작하기';
      onPressed = widget.onStart;
      backgroundColor = config.primaryColor;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: AppColors2025.textOnPrimary,
          elevation: onPressed != null ? 2 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getActionIcon(),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestTypeBadge(QuestCardConfiguration config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getQuestTypeColor().withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getQuestTypeColor().withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getQuestTypeIcon(),
            size: 12,
            color: AppColors2025.textOnPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            _getQuestTypeText(),
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors2025.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(QuestCardConfiguration config) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors2025.surface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyIndicator(QuestCardConfiguration config) {
    final starCount = _getDifficultyStars();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        return Icon(
          Icons.star,
          size: 12,
          color: _getDifficultyColor(),
        );
      }),
    );
  }

  // ==================== 헬퍼 메서드들 ====================

  bool _shouldShowActionButton() {
    return widget.onStart != null || 
           widget.onClaim != null || 
           widget.status == SherpaQuestStatus.locked;
  }

  String _formatTimeLeft() {
    if (widget.timeLeft == null) return '';
    
    final duration = widget.timeLeft!;
    if (duration.inDays > 0) {
      return '${duration.inDays}일 ${duration.inHours % 24}시간';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간 ${duration.inMinutes % 60}분';
    } else {
      return '${duration.inMinutes}분';
    }
  }

  IconData _getActionIcon() {
    switch (widget.status) {
      case SherpaQuestStatus.locked:
        return Icons.lock;
      case SherpaQuestStatus.completed:
        return Icons.check_circle;
      case SherpaQuestStatus.claimable:
        return Icons.redeem;
      default:
        return Icons.play_arrow;
    }
  }

  Color _getQuestTypeColor() {
    switch (widget.questType) {
      case SherpaQuestType.daily:
        return AppColors2025.info;
      case SherpaQuestType.weekly:
        return AppColors2025.warning;
      case SherpaQuestType.achievement:
        return AppColors2025.secondary;
      case SherpaQuestType.special:
        return AppColors2025.primary;
    }
  }

  IconData _getQuestTypeIcon() {
    switch (widget.questType) {
      case SherpaQuestType.daily:
        return Icons.today;
      case SherpaQuestType.weekly:
        return Icons.date_range;
      case SherpaQuestType.achievement:
        return Icons.emoji_events;
      case SherpaQuestType.special:
        return Icons.stars;
    }
  }

  String _getQuestTypeText() {
    switch (widget.questType) {
      case SherpaQuestType.daily:
        return '일일';
      case SherpaQuestType.weekly:
        return '주간';
      case SherpaQuestType.achievement:
        return '업적';
      case SherpaQuestType.special:
        return '특별';
    }
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case SherpaQuestStatus.locked:
        return AppColors2025.textQuaternary;
      case SherpaQuestStatus.available:
        return AppColors2025.info;
      case SherpaQuestStatus.inProgress:
        return AppColors2025.warning;
      case SherpaQuestStatus.completed:
        return AppColors2025.success;
      case SherpaQuestStatus.claimable:
        return AppColors2025.secondary;
      case SherpaQuestStatus.claimed:
        return AppColors2025.success;
    }
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case SherpaQuestDifficulty.easy:
        return AppColors2025.success;
      case SherpaQuestDifficulty.medium:
        return AppColors2025.warning;
      case SherpaQuestDifficulty.hard:
        return AppColors2025.error;
      case SherpaQuestDifficulty.legendary:
        return AppColors2025.secondary;
    }
  }

  int _getDifficultyStars() {
    switch (widget.difficulty) {
      case SherpaQuestDifficulty.easy:
        return 1;
      case SherpaQuestDifficulty.medium:
        return 2;
      case SherpaQuestDifficulty.hard:
        return 3;
      case SherpaQuestDifficulty.legendary:
        return 4;
    }
  }

  QuestCardConfiguration _getQuestCardConfiguration() {
    final primaryColor = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : _getQuestTypeColor());

    switch (widget.size) {
      case SherpaQuestCardSize2025.small:
        return QuestCardConfiguration(
          padding: const EdgeInsets.all(12),
          spacing: 8,
          titleSize: 14,
          subtitleSize: 12,
          progressTextSize: 11,
          primaryColor: primaryColor,
        );
      case SherpaQuestCardSize2025.medium:
        return QuestCardConfiguration(
          padding: const EdgeInsets.all(16),
          spacing: 12,
          titleSize: 16,
          subtitleSize: 14,
          progressTextSize: 12,
          primaryColor: primaryColor,
        );
      case SherpaQuestCardSize2025.large:
        return QuestCardConfiguration(
          padding: const EdgeInsets.all(20),
          spacing: 16,
          titleSize: 18,
          subtitleSize: 16,
          progressTextSize: 14,
          primaryColor: primaryColor,
        );
    }
  }

  BoxDecoration _getDecoration(QuestCardConfiguration config) {
    switch (widget.variant) {
      case SherpaQuestCardVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.medium,
          color: config.primaryColor,
          borderRadius: AppSizes.radiusL,
          opacity: 0.1,
        );

      case SherpaQuestCardVariant2025.neu:
        return GlassNeuStyle.softNeumorphism(
          baseColor: AppColors2025.surface,
          borderRadius: AppSizes.radiusL,
          intensity: 0.03,
        );

      case SherpaQuestCardVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.primaryColor,
          borderRadius: AppSizes.radiusL,
          elevation: 12,
        );

      case SherpaQuestCardVariant2025.glow:
        final glowIntensity = 0.1 + 0.05 * _glowAnimation.value;
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              config.primaryColor.withOpacity(glowIntensity),
              config.primaryColor.withOpacity(glowIntensity * 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: config.primaryColor.withOpacity(0.3 * _glowAnimation.value),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        );

      case SherpaQuestCardVariant2025.outlined:
        return BoxDecoration(
          color: AppColors2025.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: config.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        );
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _progressController.dispose();
    _glowController.dispose();
    _timerController.dispose();
    super.dispose();
  }
}

// ==================== 모델 클래스들 ====================

class SherpaQuestReward {
  final IconData icon;
  final Color color;
  final int amount;
  final String type;

  const SherpaQuestReward({
    required this.icon,
    required this.color,
    required this.amount,
    required this.type,
  });
}

// ==================== 열거형 정의 ====================

enum SherpaQuestType {
  daily,        // 일일 퀘스트
  weekly,       // 주간 퀘스트
  achievement,  // 업적
  special,      // 특별 이벤트
}

enum SherpaQuestStatus {
  locked,       // 잠김
  available,    // 이용 가능
  inProgress,   // 진행 중
  completed,    // 완료
  claimable,    // 보상 수령 가능
  claimed,      // 보상 수령 완료
}

enum SherpaQuestDifficulty {
  easy,         // 쉬움 (1성)
  medium,       // 보통 (2성)
  hard,         // 어려움 (3성)
  legendary,    // 전설 (4성)
}

enum SherpaQuestCardVariant2025 {
  glass,        // 글래스모피즘
  neu,          // 뉴모피즘
  floating,     // 플로팅
  glow,         // 글로우 효과
  outlined,     // 아웃라인
}

enum SherpaQuestCardSize2025 {
  small,        // 작은 크기
  medium,       // 중간 크기
  large,        // 큰 크기
}

// ==================== 도우미 클래스들 ====================

class QuestCardConfiguration {
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double titleSize;
  final double subtitleSize;
  final double progressTextSize;
  final Color primaryColor;

  const QuestCardConfiguration({
    required this.padding,
    required this.spacing,
    required this.titleSize,
    required this.subtitleSize,
    required this.progressTextSize,
    required this.primaryColor,
  });
}