// lib/shared/widgets/components/molecules/sherpa_activity_card_2025.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 셰르파 활동 카드 컴포넌트
/// 운동, 독서, 일기, 집중 등의 활동을 추적하고 표시하는 전용 카드
class SherpaActivityCard2025 extends StatefulWidget {
  final SherpaActivityType activityType;
  final String title;
  final String? subtitle;
  final Widget? icon;
  final double progress;
  final String? progressText;
  final String? targetText;
  final int? streakCount;
  final SherpaActivityStatus status;
  final DateTime? lastCompleted;
  final Map<String, dynamic>? stats;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final List<SherpaActivityAction>? actions;
  final SherpaActivityCardVariant2025 variant;
  final SherpaActivityCardSize2025 size;
  final bool showStats;
  final bool showStreak;
  final bool enableMicroInteractions;
  final String? category;
  final Color? customColor;
  final Widget? backgroundWidget;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SherpaActivityCard2025({
    Key? key,
    required this.activityType,
    required this.title,
    this.subtitle,
    this.icon,
    this.progress = 0.0,
    this.progressText,
    this.targetText,
    this.streakCount,
    this.status = SherpaActivityStatus.pending,
    this.lastCompleted,
    this.stats,
    this.onTap,
    this.onStart,
    this.onComplete,
    this.actions,
    this.variant = SherpaActivityCardVariant2025.glass,
    this.size = SherpaActivityCardSize2025.medium,
    this.showStats = true,
    this.showStreak = true,
    this.enableMicroInteractions = true,
    this.category,
    this.customColor,
    this.backgroundWidget,
    this.padding,
    this.margin,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 운동 활동 카드
  factory SherpaActivityCard2025.exercise({
    Key? key,
    required String title,
    String? subtitle,
    double progress = 0.0,
    String? duration,
    int? calories,
    int? streakCount,
    SherpaActivityStatus status = SherpaActivityStatus.pending,
    VoidCallback? onTap,
    VoidCallback? onStart,
  }) {
    return SherpaActivityCard2025(
      key: key,
      activityType: SherpaActivityType.exercise,
      title: title,
      subtitle: subtitle,
      progress: progress,
      progressText: duration,
      streakCount: streakCount,
      status: status,
      onTap: onTap,
      onStart: onStart,
      icon: const Icon(Icons.fitness_center, size: 24),
      stats: calories != null ? {'calories': calories} : null,
      category: 'exercise',
    );
  }

  /// 독서 활동 카드
  factory SherpaActivityCard2025.reading({
    Key? key,
    required String title,
    String? subtitle,
    double progress = 0.0,
    String? pages,
    String? timeSpent,
    int? streakCount,
    SherpaActivityStatus status = SherpaActivityStatus.pending,
    VoidCallback? onTap,
    VoidCallback? onStart,
  }) {
    return SherpaActivityCard2025(
      key: key,
      activityType: SherpaActivityType.reading,
      title: title,
      subtitle: subtitle,
      progress: progress,
      progressText: pages,
      streakCount: streakCount,
      status: status,
      onTap: onTap,
      onStart: onStart,
      icon: const Icon(Icons.menu_book, size: 24),
      stats: timeSpent != null ? {'timeSpent': timeSpent} : null,
      category: 'reading',
    );
  }

  /// 일기 활동 카드
  factory SherpaActivityCard2025.diary({
    Key? key,
    required String title,
    String? subtitle,
    double progress = 0.0,
    String? wordCount,
    String? mood,
    int? streakCount,
    SherpaActivityStatus status = SherpaActivityStatus.pending,
    VoidCallback? onTap,
    VoidCallback? onStart,
  }) {
    return SherpaActivityCard2025(
      key: key,
      activityType: SherpaActivityType.diary,
      title: title,
      subtitle: subtitle,
      progress: progress,
      progressText: wordCount,
      streakCount: streakCount,
      status: status,
      onTap: onTap,
      onStart: onStart,
      icon: const Icon(Icons.edit_note, size: 24),
      stats: mood != null ? {'mood': mood} : null,
      category: 'diary',
    );
  }

  /// 집중 활동 카드
  factory SherpaActivityCard2025.focus({
    Key? key,
    required String title,
    String? subtitle,
    double progress = 0.0,
    String? focusTime,
    int? sessions,
    int? streakCount,
    SherpaActivityStatus status = SherpaActivityStatus.pending,
    VoidCallback? onTap,
    VoidCallback? onStart,
  }) {
    return SherpaActivityCard2025(
      key: key,
      activityType: SherpaActivityType.focus,
      title: title,
      subtitle: subtitle,
      progress: progress,
      progressText: focusTime,
      streakCount: streakCount,
      status: status,
      onTap: onTap,
      onStart: onStart,
      icon: const Icon(Icons.psychology, size: 24),
      stats: sessions != null ? {'sessions': sessions} : null,
      category: 'focus',
    );
  }

  /// 모임 활동 카드
  factory SherpaActivityCard2025.meeting({
    Key? key,
    required String title,
    String? subtitle,
    double progress = 0.0,
    String? participants,
    String? location,
    int? streakCount,
    SherpaActivityStatus status = SherpaActivityStatus.pending,
    VoidCallback? onTap,
    VoidCallback? onStart,
  }) {
    return SherpaActivityCard2025(
      key: key,
      activityType: SherpaActivityType.meeting,
      title: title,
      subtitle: subtitle,
      progress: progress,
      progressText: participants,
      streakCount: streakCount,
      status: status,
      onTap: onTap,
      onStart: onStart,
      icon: const Icon(Icons.people, size: 24),
      stats: location != null ? {'location': location} : null,
      category: 'meeting',
    );
  }

  @override
  State<SherpaActivityCard2025> createState() => _SherpaActivityCard2025State();
}

class _SherpaActivityCard2025State extends State<SherpaActivityCard2025>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  
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

    _progressController.forward();
  }

  @override
  void didUpdateWidget(SherpaActivityCard2025 oldWidget) {
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
    final config = _getActivityCardConfiguration();

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

  Widget _buildCardContent(ActivityCardConfiguration config) {
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
              if (widget.progress > 0) ...[ 
                SizedBox(height: config.spacing),
                _buildProgress(config),
              ],
              if (widget.showStats && widget.stats != null) ...[ 
                SizedBox(height: config.spacing),
                _buildStats(config),
              ],
              if (widget.actions != null && widget.actions!.isNotEmpty) ...[ 
                SizedBox(height: config.spacing * 1.5),
                _buildActions(config),
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
        
        // 스트릭 뱃지
        if (widget.showStreak && widget.streakCount != null && widget.streakCount! > 0)
          Positioned(
            top: 8,
            left: 8,
            child: _buildStreakBadge(config),
          ),
      ],
    );
  }

  Widget _buildHeader(ActivityCardConfiguration config) {
    return Row(
      children: [
        if (widget.icon != null) ...[ 
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: config.iconBackgroundColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: IconTheme(
              data: IconThemeData(
                color: config.iconColor,
                size: config.iconSize,
              ),
              child: widget.icon!,
            ),
          ),
          SizedBox(width: config.spacing),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.notoSans(
                  fontSize: config.titleSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors2025.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle != null) ...[ 
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: GoogleFonts.notoSans(
                    fontSize: config.subtitleSize,
                    color: AppColors2025.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(ActivityCardConfiguration config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.progressText != null)
              Text(
                widget.progressText!,
                style: GoogleFonts.notoSans(
                  fontSize: config.progressTextSize,
                  fontWeight: FontWeight.w600,
                  color: config.primaryColor,
                ),
              ),
            if (widget.targetText != null)
              Text(
                widget.targetText!,
                style: GoogleFonts.notoSans(
                  fontSize: config.progressTextSize,
                  color: AppColors2025.textTertiary,
                ),
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
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStats(ActivityCardConfiguration config) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.stats!.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatIcon(entry.key),
              size: 16,
              color: AppColors2025.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              entry.value.toString(),
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors2025.textTertiary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActions(ActivityCardConfiguration config) {
    if (widget.actions!.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: _buildActionButton(widget.actions!.first, config),
      );
    }

    return Row(
      children: widget.actions!.map((action) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: action == widget.actions!.last ? 0 : 8,
            ),
            child: _buildActionButton(action, config),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(SherpaActivityAction action, ActivityCardConfiguration config) {
    return ElevatedButton(
      onPressed: action.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: action.isPrimary 
            ? config.primaryColor 
            : AppColors2025.surface,
        foregroundColor: action.isPrimary 
            ? AppColors2025.textOnPrimary 
            : AppColors2025.textSecondary,
        elevation: action.isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          side: action.isPrimary 
              ? BorderSide.none 
              : BorderSide(color: AppColors2025.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (action.icon != null) ...[ 
            Icon(action.icon, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            action.text,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ActivityCardConfiguration config) {
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
      ),
    );
  }

  Widget _buildStreakBadge(ActivityCardConfiguration config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors2025.warning,
            AppColors2025.warning.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 14,
            color: AppColors2025.textOnPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.streakCount}',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors2025.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  ActivityCardConfiguration _getActivityCardConfiguration() {
    final primaryColor = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : _getActivityTypeColor());

    switch (widget.size) {
      case SherpaActivityCardSize2025.small:
        return ActivityCardConfiguration(
          padding: const EdgeInsets.all(12),
          spacing: 8,
          titleSize: 14,
          subtitleSize: 12,
          progressTextSize: 11,
          iconSize: 20,
          primaryColor: primaryColor,
          iconColor: primaryColor,
          iconBackgroundColor: primaryColor.withOpacity(0.1),
        );
      case SherpaActivityCardSize2025.medium:
        return ActivityCardConfiguration(
          padding: const EdgeInsets.all(16),
          spacing: 12,
          titleSize: 16,
          subtitleSize: 14,
          progressTextSize: 12,
          iconSize: 24,
          primaryColor: primaryColor,
          iconColor: primaryColor,
          iconBackgroundColor: primaryColor.withOpacity(0.1),
        );
      case SherpaActivityCardSize2025.large:
        return ActivityCardConfiguration(
          padding: const EdgeInsets.all(20),
          spacing: 16,
          titleSize: 18,
          subtitleSize: 16,
          progressTextSize: 14,
          iconSize: 28,
          primaryColor: primaryColor,
          iconColor: primaryColor,
          iconBackgroundColor: primaryColor.withOpacity(0.1),
        );
    }
  }

  Color _getActivityTypeColor() {
    switch (widget.activityType) {
      case SherpaActivityType.exercise:
        return AppColors2025.success;
      case SherpaActivityType.reading:
        return AppColors2025.info;
      case SherpaActivityType.diary:
        return AppColors2025.warning;
      case SherpaActivityType.focus:
        return AppColors2025.primary;
      case SherpaActivityType.meeting:
        return AppColors2025.secondary;
    }
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case SherpaActivityStatus.pending:
        return AppColors2025.textQuaternary;
      case SherpaActivityStatus.inProgress:
        return AppColors2025.info;
      case SherpaActivityStatus.completed:
        return AppColors2025.success;
      case SherpaActivityStatus.paused:
        return AppColors2025.warning;
      case SherpaActivityStatus.failed:
        return AppColors2025.error;
    }
  }

  IconData _getStatIcon(String statKey) {
    switch (statKey) {
      case 'calories':
        return Icons.local_fire_department;
      case 'timeSpent':
        return Icons.access_time;
      case 'pages':
        return Icons.auto_stories;
      case 'mood':
        return Icons.mood;
      case 'sessions':
        return Icons.psychology;
      case 'participants':
        return Icons.people;
      case 'location':
        return Icons.location_on;
      default:
        return Icons.info;
    }
  }

  BoxDecoration _getDecoration(ActivityCardConfiguration config) {
    switch (widget.variant) {
      case SherpaActivityCardVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.medium,
          color: config.primaryColor,
          borderRadius: AppSizes.radiusL,
          opacity: 0.08,
        );

      case SherpaActivityCardVariant2025.neu:
        return GlassNeuStyle.softNeumorphism(
          baseColor: AppColors2025.surface,
          borderRadius: AppSizes.radiusL,
          intensity: 0.03,
        );

      case SherpaActivityCardVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.primaryColor,
          borderRadius: AppSizes.radiusL,
          elevation: 12,
        );

      case SherpaActivityCardVariant2025.outlined:
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
    super.dispose();
  }
}

// ==================== 모델 클래스들 ====================

class SherpaActivityAction {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const SherpaActivityAction({
    required this.text,
    this.icon,
    this.onPressed,
    this.isPrimary = true,
  });
}

// ==================== 열거형 정의 ====================

enum SherpaActivityType {
  exercise,     // 운동
  reading,      // 독서
  diary,        // 일기
  focus,        // 집중
  meeting,      // 모임
}

enum SherpaActivityStatus {
  pending,      // 대기 중
  inProgress,   // 진행 중
  completed,    // 완료
  paused,       // 일시정지
  failed,       // 실패
}

enum SherpaActivityCardVariant2025 {
  glass,        // 글래스모피즘
  neu,          // 뉴모피즘
  floating,     // 플로팅
  outlined,     // 아웃라인
}

enum SherpaActivityCardSize2025 {
  small,        // 작은 크기
  medium,       // 중간 크기
  large,        // 큰 크기
}

// ==================== 도우미 클래스들 ====================

class ActivityCardConfiguration {
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double titleSize;
  final double subtitleSize;
  final double progressTextSize;
  final double iconSize;
  final Color primaryColor;
  final Color iconColor;
  final Color iconBackgroundColor;

  const ActivityCardConfiguration({
    required this.padding,
    required this.spacing,
    required this.titleSize,
    required this.subtitleSize,
    required this.progressTextSize,
    required this.iconSize,
    required this.primaryColor,
    required this.iconColor,
    required this.iconBackgroundColor,
  });
}