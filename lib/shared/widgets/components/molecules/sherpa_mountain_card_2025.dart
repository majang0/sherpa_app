// lib/shared/widgets/components/molecules/sherpa_mountain_card_2025.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 셰르파 산 등반 카드 컴포넌트
/// 산 등반 메타포를 통한 진행도 시각화와 성취 추적 전용 카드
class SherpaMountainCard2025 extends StatefulWidget {
  final String mountainName;
  final String? subtitle;
  final double progress; // 0.0 - 1.0
  final int currentLevel;
  final int totalLevels;
  final String? currentActivity;
  final Map<String, dynamic>? stats;
  final SherpaMountainStatus status;
  final SherpaMountainDifficulty difficulty;
  final VoidCallback? onTap;
  final VoidCallback? onClimb;
  final List<SherpaMountainBadge>? badges;
  final SherpaMountainCardVariant2025 variant;
  final SherpaMountainCardSize2025 size;
  final bool showWeather;
  final bool showElevation;
  final bool enableMicroInteractions;
  final String? category;
  final Color? customColor;
  final Widget? backgroundWidget;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SherpaMountainCard2025({
    Key? key,
    required this.mountainName,
    this.subtitle,
    this.progress = 0.0,
    this.currentLevel = 1,
    this.totalLevels = 10,
    this.currentActivity,
    this.stats,
    this.status = SherpaMountainStatus.available,
    this.difficulty = SherpaMountainDifficulty.beginner,
    this.onTap,
    this.onClimb,
    this.badges,
    this.variant = SherpaMountainCardVariant2025.glass,
    this.size = SherpaMountainCardSize2025.medium,
    this.showWeather = true,
    this.showElevation = true,
    this.enableMicroInteractions = true,
    this.category,
    this.customColor,
    this.backgroundWidget,
    this.padding,
    this.margin,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 초급 산
  factory SherpaMountainCard2025.beginner({
    Key? key,
    required String mountainName,
    String? subtitle,
    double progress = 0.0,
    int currentLevel = 1,
    String? currentActivity,
    VoidCallback? onTap,
    VoidCallback? onClimb,
  }) {
    return SherpaMountainCard2025(
      key: key,
      mountainName: mountainName,
      subtitle: subtitle ?? '쉬운 등반로',
      progress: progress,
      currentLevel: currentLevel,
      totalLevels: 5,
      currentActivity: currentActivity,
      difficulty: SherpaMountainDifficulty.beginner,
      onTap: onTap,
      onClimb: onClimb,
      category: 'beginner',
    );
  }

  /// 중급 산
  factory SherpaMountainCard2025.intermediate({
    Key? key,
    required String mountainName,
    String? subtitle,
    double progress = 0.0,
    int currentLevel = 1,
    String? currentActivity,
    VoidCallback? onTap,
    VoidCallback? onClimb,
  }) {
    return SherpaMountainCard2025(
      key: key,
      mountainName: mountainName,
      subtitle: subtitle ?? '도전적인 등반로',
      progress: progress,
      currentLevel: currentLevel,
      totalLevels: 8,
      currentActivity: currentActivity,
      difficulty: SherpaMountainDifficulty.intermediate,
      onTap: onTap,
      onClimb: onClimb,
      category: 'intermediate',
    );
  }

  /// 고급 산
  factory SherpaMountainCard2025.advanced({
    Key? key,
    required String mountainName,
    String? subtitle,
    double progress = 0.0,
    int currentLevel = 1,
    String? currentActivity,
    VoidCallback? onTap,
    VoidCallback? onClimb,
  }) {
    return SherpaMountainCard2025(
      key: key,
      mountainName: mountainName,
      subtitle: subtitle ?? '극한의 등반로',
      progress: progress,
      currentLevel: currentLevel,
      totalLevels: 12,
      currentActivity: currentActivity,
      difficulty: SherpaMountainDifficulty.advanced,
      onTap: onTap,
      onClimb: onClimb,
      category: 'advanced',
    );
  }

  /// 특별 이벤트 산
  factory SherpaMountainCard2025.special({
    Key? key,
    required String mountainName,
    String? subtitle,
    double progress = 0.0,
    int currentLevel = 1,
    String? currentActivity,
    VoidCallback? onTap,
    VoidCallback? onClimb,
  }) {
    return SherpaMountainCard2025(
      key: key,
      mountainName: mountainName,
      subtitle: subtitle ?? '특별 이벤트 산',
      progress: progress,
      currentLevel: currentLevel,
      totalLevels: 7,
      currentActivity: currentActivity,
      difficulty: SherpaMountainDifficulty.special,
      onTap: onTap,
      onClimb: onClimb,
      category: 'special',
      variant: SherpaMountainCardVariant2025.floating,
    );
  }

  @override
  State<SherpaMountainCard2025> createState() => _SherpaMountainCard2025State();
}

class _SherpaMountainCard2025State extends State<SherpaMountainCard2025>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _progressController;
  late AnimationController _weatherController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _weatherAnimation;
  
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

    _weatherController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
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

    _weatherAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _weatherController,
      curve: MicroInteractions.easeInOutSine,
    ));

    _progressController.forward();
    if (widget.showWeather) {
      _weatherController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SherpaMountainCard2025 oldWidget) {
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
    final config = _getMountainCardConfiguration();

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

  Widget _buildCardContent(MountainCardConfiguration config) {
    return Stack(
      children: [
        // 배경 위젯
        if (widget.backgroundWidget != null)
          Positioned.fill(child: widget.backgroundWidget!),
        
        // 산 실루엣 배경
        Positioned.fill(
          child: _buildMountainSilhouette(config),
        ),
        
        // 메인 콘텐츠
        Padding(
          padding: widget.padding ?? config.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(config),
              SizedBox(height: config.spacing),
              _buildProgressSection(config),
              if (widget.currentActivity != null) ...[
                SizedBox(height: config.spacing),
                _buildCurrentActivity(config),
              ],
              if (widget.stats != null) ...[
                SizedBox(height: config.spacing),
                _buildStats(config),
              ],
              if (widget.onClimb != null) ...[
                SizedBox(height: config.spacing * 1.5),
                _buildClimbButton(config),
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
        
        // 날씨 인디케이터
        if (widget.showWeather)
          Positioned(
            top: 12,
            left: 12,
            child: _buildWeatherIndicator(config),
          ),
        
        // 뱃지들
        if (widget.badges != null && widget.badges!.isNotEmpty)
          Positioned(
            bottom: 12,
            right: 12,
            child: _buildBadges(config),
          ),
        
        // 고도 표시
        if (widget.showElevation)
          Positioned(
            bottom: 12,
            left: 12,
            child: _buildElevation(config),
          ),
      ],
    );
  }

  Widget _buildHeader(MountainCardConfiguration config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.mountainName,
                style: GoogleFonts.notoSans(
                  fontSize: config.titleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors2025.textOnPrimary.withOpacity(0.95),
                  shadows: [
                    Shadow(
                      color: AppColors2025.shadowDark,
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildDifficultyChip(config),
          ],
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            style: GoogleFonts.notoSans(
              fontSize: config.subtitleSize,
              color: AppColors2025.textOnPrimary.withOpacity(0.8),
              shadows: [
                Shadow(
                  color: AppColors2025.shadowDark,
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection(MountainCardConfiguration config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '레벨 ${widget.currentLevel}/${widget.totalLevels}',
              style: GoogleFonts.notoSans(
                fontSize: config.progressTextSize,
                fontWeight: FontWeight.w600,
                color: AppColors2025.textOnPrimary.withOpacity(0.9),
                shadows: [
                  Shadow(
                    color: AppColors2025.shadowDark,
                    offset: const Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
            Text(
              '${(widget.progress * 100).toInt()}%',
              style: GoogleFonts.notoSans(
                fontSize: config.progressTextSize,
                fontWeight: FontWeight.w700,
                color: AppColors2025.textOnPrimary,
                shadows: [
                  Shadow(
                    color: AppColors2025.shadowDark,
                    offset: const Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors2025.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors2025.success,
                        AppColors2025.success.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors2025.success.withOpacity(0.5),
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

  Widget _buildCurrentActivity(MountainCardConfiguration config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors2025.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: AppColors2025.textOnPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            size: 16,
            color: AppColors2025.textOnPrimary.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.currentActivity!,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors2025.textOnPrimary.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(MountainCardConfiguration config) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.stats!.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatIcon(entry.key),
              size: 14,
              color: AppColors2025.textOnPrimary.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              entry.value.toString(),
              style: GoogleFonts.notoSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors2025.textOnPrimary.withOpacity(0.8),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildClimbButton(MountainCardConfiguration config) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.status == SherpaMountainStatus.locked ? null : widget.onClimb,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.status == SherpaMountainStatus.locked
              ? AppColors2025.textQuaternary
              : AppColors2025.success,
          foregroundColor: AppColors2025.textOnPrimary,
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.status == SherpaMountainStatus.locked 
                  ? Icons.lock 
                  : Icons.terrain,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.status == SherpaMountainStatus.locked 
                  ? '잠김' 
                  : '등반 시작',
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

  Widget _buildDifficultyChip(MountainCardConfiguration config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDifficultyColor().withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors2025.textOnPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getDifficultyText(),
        style: GoogleFonts.notoSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors2025.textOnPrimary,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(MountainCardConfiguration config) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors2025.textOnPrimary,
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

  Widget _buildWeatherIndicator(MountainCardConfiguration config) {
    return AnimatedBuilder(
      animation: _weatherAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors2025.surface.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors2025.textOnPrimary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.wb_sunny,
            size: 16,
            color: AppColors2025.warning.withOpacity(
              0.7 + 0.3 * _weatherAnimation.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadges(MountainCardConfiguration config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.badges!.take(3).map((badge) {
        return Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: badge.color.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors2025.textOnPrimary.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(
            badge.icon,
            size: 12,
            color: AppColors2025.textOnPrimary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildElevation(MountainCardConfiguration config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors2025.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: AppColors2025.textOnPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.height,
            size: 12,
            color: AppColors2025.textOnPrimary.withOpacity(0.8),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.currentLevel * 100}m',
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors2025.textOnPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMountainSilhouette(MountainCardConfiguration config) {
    return CustomPaint(
      painter: _MountainSilhouettePainter(
        progress: widget.progress,
        primaryColor: config.primaryColor,
      ),
    );
  }

  MountainCardConfiguration _getMountainCardConfiguration() {
    final primaryColor = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : _getDifficultyColor());

    switch (widget.size) {
      case SherpaMountainCardSize2025.small:
        return MountainCardConfiguration(
          padding: const EdgeInsets.all(12),
          spacing: 8,
          titleSize: 14,
          subtitleSize: 12,
          progressTextSize: 11,
          primaryColor: primaryColor,
        );
      case SherpaMountainCardSize2025.medium:
        return MountainCardConfiguration(
          padding: const EdgeInsets.all(16),
          spacing: 12,
          titleSize: 18,
          subtitleSize: 14,
          progressTextSize: 12,
          primaryColor: primaryColor,
        );
      case SherpaMountainCardSize2025.large:
        return MountainCardConfiguration(
          padding: const EdgeInsets.all(20),
          spacing: 16,
          titleSize: 22,
          subtitleSize: 16,
          progressTextSize: 14,
          primaryColor: primaryColor,
        );
    }
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case SherpaMountainDifficulty.beginner:
        return AppColors2025.success;
      case SherpaMountainDifficulty.intermediate:
        return AppColors2025.warning;
      case SherpaMountainDifficulty.advanced:
        return AppColors2025.error;
      case SherpaMountainDifficulty.special:
        return AppColors2025.secondary;
    }
  }

  String _getDifficultyText() {
    switch (widget.difficulty) {
      case SherpaMountainDifficulty.beginner:
        return '초급';
      case SherpaMountainDifficulty.intermediate:
        return '중급';
      case SherpaMountainDifficulty.advanced:
        return '고급';
      case SherpaMountainDifficulty.special:
        return '특별';
    }
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case SherpaMountainStatus.locked:
        return AppColors2025.textQuaternary;
      case SherpaMountainStatus.available:
        return AppColors2025.info;
      case SherpaMountainStatus.inProgress:
        return AppColors2025.warning;
      case SherpaMountainStatus.completed:
        return AppColors2025.success;
    }
  }

  IconData _getStatIcon(String statKey) {
    switch (statKey) {
      case 'attempts':
        return Icons.replay;
      case 'bestTime':
        return Icons.timer;
      case 'difficulty':
        return Icons.trending_up;
      case 'elevation':
        return Icons.height;
      case 'weather':
        return Icons.wb_sunny;
      default:
        return Icons.info;
    }
  }

  BoxDecoration _getDecoration(MountainCardConfiguration config) {
    switch (widget.variant) {
      case SherpaMountainCardVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.medium,
          color: config.primaryColor,
          borderRadius: AppSizes.radiusL,
          opacity: 0.15,
        );

      case SherpaMountainCardVariant2025.neu:
        return GlassNeuStyle.softNeumorphism(
          baseColor: config.primaryColor,
          borderRadius: AppSizes.radiusL,
          intensity: 0.05,
        );

      case SherpaMountainCardVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.primaryColor,
          borderRadius: AppSizes.radiusL,
          elevation: 16,
        );

      case SherpaMountainCardVariant2025.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              config.primaryColor,
              config.primaryColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: config.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _progressController.dispose();
    _weatherController.dispose();
    super.dispose();
  }
}

// ==================== 산 실루엣 페인터 ====================

class _MountainSilhouettePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  _MountainSilhouettePainter({
    required this.progress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.1),
          primaryColor.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    
    // 산 실루엣 그리기
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.4,
      size.width * 0.4, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.2,
      size.width * 0.8, size.height * 0.4,
    );
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // 진행도 오버레이
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            primaryColor.withOpacity(0.3),
            primaryColor.withOpacity(0.1),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final progressPath = Path();
      final progressHeight = size.height * (1 - progress);
      
      progressPath.moveTo(0, size.height);
      progressPath.lineTo(0, progressHeight);
      progressPath.lineTo(size.width, progressHeight);
      progressPath.lineTo(size.width, size.height);
      progressPath.close();

      canvas.drawPath(progressPath, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _MountainSilhouettePainter &&
        (oldDelegate.progress != progress ||
         oldDelegate.primaryColor != primaryColor);
  }
}

// ==================== 모델 클래스들 ====================

class SherpaMountainBadge {
  final IconData icon;
  final Color color;
  final String name;

  const SherpaMountainBadge({
    required this.icon,
    required this.color,
    required this.name,
  });
}

// ==================== 열거형 정의 ====================

enum SherpaMountainStatus {
  locked,      // 잠김
  available,   // 이용 가능
  inProgress,  // 진행 중
  completed,   // 완료
}

enum SherpaMountainDifficulty {
  beginner,     // 초급
  intermediate, // 중급
  advanced,     // 고급
  special,      // 특별
}

enum SherpaMountainCardVariant2025 {
  glass,        // 글래스모피즘
  neu,          // 뉴모피즘
  floating,     // 플로팅
  gradient,     // 그라데이션
}

enum SherpaMountainCardSize2025 {
  small,        // 작은 크기
  medium,       // 중간 크기
  large,        // 큰 크기
}

// ==================== 도우미 클래스들 ====================

class MountainCardConfiguration {
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double titleSize;
  final double subtitleSize;
  final double progressTextSize;
  final Color primaryColor;

  const MountainCardConfiguration({
    required this.padding,
    required this.spacing,
    required this.titleSize,
    required this.subtitleSize,
    required this.progressTextSize,
    required this.primaryColor,
  });
}