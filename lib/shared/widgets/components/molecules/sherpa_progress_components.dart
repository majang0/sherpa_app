// lib/shared/widgets/components/molecules/sherpa_progress_components.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';
import '../atoms/sherpa_card.dart';
import '../atoms/sherpa_chip.dart';

// ==================== 원형 진행도 컴포넌트 ====================

/// 원형 진행도 표시기 (레벨업, 목표 달성용)
class SherpaCircularProgress extends StatefulWidget {
  final double progress; // 0.0 ~ 1.0
  final int currentValue;
  final int targetValue;
  final String label;
  final Color? color;
  final double size;
  final double strokeWidth;
  final bool showAnimation;
  final Widget? centerWidget;
  final String? unit;

  const SherpaCircularProgress({
    Key? key,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
    required this.label,
    this.color,
    this.size = 120,
    this.strokeWidth = 8,
    this.showAnimation = true,
    this.centerWidget,
    this.unit,
  }) : super(key: key);

  @override
  State<SherpaCircularProgress> createState() => _SherpaCircularProgressState();
}

class _SherpaCircularProgressState extends State<SherpaCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    if (widget.showAnimation) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors2025.primary;
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: GlassNeuStyle.softNeumorphism(
        baseColor: AppColors2025.neuBase,
        borderRadius: widget.size / 2,
        intensity: 0.03,
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.strokeWidth),
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size - widget.strokeWidth * 2, widget.size - widget.strokeWidth * 2),
              painter: CircularProgressPainter(
                progress: _progressAnimation.value,
                color: color,
                strokeWidth: widget.strokeWidth,
                backgroundColor: AppColors2025.neuShadowLight,
              ),
              child: Center(
                child: widget.centerWidget ?? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.currentValue}',
                      style: GoogleFonts.notoSans(
                        fontSize: widget.size * 0.15,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    if (widget.unit != null)
                      Text(
                        widget.unit!,
                        style: GoogleFonts.notoSans(
                          fontSize: widget.size * 0.08,
                          color: AppColors2025.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      style: GoogleFonts.notoSans(
                        fontSize: widget.size * 0.08,
                        color: AppColors2025.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ==================== 선형 진행도 바 ====================

/// 선형 진행도 바 (일일 목표, 경험치용)
class SherpaLinearProgress extends StatefulWidget {
  final double progress; // 0.0 ~ 1.0
  final String label;
  final String? subtitle;
  final Color? color;
  final double height;
  final bool showPercentage;
  final bool showAnimation;
  final LinearProgressStyle style;
  final Widget? leading;
  final Widget? trailing;

  const SherpaLinearProgress({
    Key? key,
    required this.progress,
    required this.label,
    this.subtitle,
    this.color,
    this.height = 8,
    this.showPercentage = true,
    this.showAnimation = true,
    this.style = LinearProgressStyle.glass,
    this.leading,
    this.trailing,
  }) : super(key: key);

  @override
  State<SherpaLinearProgress> createState() => _SherpaLinearProgressState();
}

class _SherpaLinearProgressState extends State<SherpaLinearProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    if (widget.showAnimation) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors2025.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨과 퍼센티지
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors2025.textPrimary,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors2025.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.showPercentage)
              Text(
                '${(widget.progress * 100).round()}%',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 진행도 바
        Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 8),
            ],
            
            Expanded(
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    height: widget.height,
                    decoration: _getProgressBarDecoration(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ],
        ),
      ],
    );
  }

  BoxDecoration _getProgressBarDecoration() {
    switch (widget.style) {
      case LinearProgressStyle.glass:
        return BoxDecoration(
          color: AppColors2025.glassWhite20,
          borderRadius: BorderRadius.circular(widget.height / 2),
          border: Border.all(
            color: AppColors2025.glassBorder,
            width: 1,
          ),
        );
      case LinearProgressStyle.neu:
        return GlassNeuStyle.neumorphism(
          elevation: GlassNeuElevation.subtle,
          baseColor: AppColors2025.neuBase,
          borderRadius: widget.height / 2,
          isInverted: true,
        );
      case LinearProgressStyle.flat:
        return BoxDecoration(
          color: AppColors2025.background,
          borderRadius: BorderRadius.circular(widget.height / 2),
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ==================== 성취 배지 컴포넌트 ====================

/// 성취 배지 컴포넌트
class SherpaAchievementBadge extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final BadgeRarity rarity;
  final VoidCallback? onTap;

  const SherpaAchievementBadge({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedDate,
    this.rarity = BadgeRarity.common,
    this.onTap,
  }) : super(key: key);

  @override
  State<SherpaAchievementBadge> createState() => _SherpaAchievementBadgeState();
}

class _SherpaAchievementBadgeState extends State<SherpaAchievementBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    if (widget.isUnlocked) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !widget.isUnlocked;
    final badgeColor = isLocked ? AppColors2025.neuShadowMedium : widget.color;
    
    Widget badge = Container(
      width: 100,
      child: Column(
        children: [
          // 배지 아이콘
          Container(
            width: 64,
            height: 64,
            decoration: _getBadgeDecoration(badgeColor, isLocked),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 아이콘
                Icon(
                  widget.icon,
                  size: 32,
                  color: isLocked 
                      ? AppColors2025.textDisabled 
                      : AppColors2025.textOnPrimary,
                ),
                
                // 잠금 표시
                if (isLocked)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors2025.textSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 12,
                        color: AppColors2025.textOnDark,
                      ),
                    ),
                  ),
                
                // 레어도 표시
                if (!isLocked && widget.rarity != BadgeRarity.common)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getRarityColor(),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors2025.textOnPrimary,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getRarityIcon(),
                        size: 10,
                        color: AppColors2025.textOnPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 제목
          Text(
            widget.title,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLocked 
                  ? AppColors2025.textDisabled 
                  : AppColors2025.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // 설명
          Text(
            widget.description,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              color: isLocked 
                  ? AppColors2025.textDisabled 
                  : AppColors2025.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // 달성 날짜
          if (!isLocked && widget.unlockedDate != null) ...[
            const SizedBox(height: 4),
            Text(
              '${widget.unlockedDate!.month}/${widget.unlockedDate!.day}',
              style: GoogleFonts.notoSans(
                fontSize: 9,
                color: AppColors2025.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );

    // 터치 인터랙션
    if (widget.onTap != null) {
      badge = MicroInteractions.tapResponse(
        onTap: widget.onTap,
        child: badge,
      );
    }

    // 언락 애니메이션
    if (!isLocked) {
      badge = badge
          .animate(controller: _controller)
          .scale(
            begin: const Offset(0.8, 0.8),
            duration: 300.ms,
            curve: Curves.elasticOut,
          )
          .fadeIn(duration: 200.ms);
    }

    return badge;
  }

  BoxDecoration _getBadgeDecoration(Color color, bool isLocked) {
    if (isLocked) {
      return GlassNeuStyle.neumorphism(
        elevation: GlassNeuElevation.subtle,
        baseColor: AppColors2025.neuShadowLight,
        borderRadius: 32,
      );
    }

    switch (widget.rarity) {
      case BadgeRarity.common:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.medium,
          color: color,
          borderRadius: 32,
          opacity: 0.8,
        );
      case BadgeRarity.rare:
        return GlassNeuStyle.gradientGlass(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: 32,
          elevation: GlassNeuElevation.high,
        );
      case BadgeRarity.epic:
        return GlassNeuStyle.floatingGlass(
          color: color,
          borderRadius: 32,
          elevation: 16,
        );
      case BadgeRarity.legendary:
        return BoxDecoration(
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        );
    }
  }

  Color _getRarityColor() {
    switch (widget.rarity) {
      case BadgeRarity.common:
        return AppColors2025.textSecondary;
      case BadgeRarity.rare:
        return AppColors2025.info;
      case BadgeRarity.epic:
        return AppColors2025.twilightPurple;
      case BadgeRarity.legendary:
        return AppColors2025.sunriseOrange;
    }
  }

  IconData _getRarityIcon() {
    switch (widget.rarity) {
      case BadgeRarity.common:
        return Icons.circle;
      case BadgeRarity.rare:
        return Icons.diamond;
      case BadgeRarity.epic:
        return Icons.star;
      case BadgeRarity.legendary:
        return Icons.auto_awesome;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ==================== 스트릭 표시기 ====================

/// 연속 달성 표시기
class SherpaStreakIndicator extends StatelessWidget {
  final int streakCount;
  final int maxStreak;
  final String label;
  final Color? color;
  final bool showFire;

  const SherpaStreakIndicator({
    Key? key,
    required this.streakCount,
    required this.maxStreak,
    this.label = '연속 달성',
    this.color,
    this.showFire = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final streakColor = color ?? _getStreakColor();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GlassNeuStyle.glassMorphism(
        elevation: GlassNeuElevation.medium,
        color: streakColor,
        borderRadius: AppSizes.radiusM,
        opacity: 0.1,
      ),
      child: Column(
        children: [
          // 불꽃 아이콘과 숫자
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showFire)
                Icon(
                  Icons.local_fire_department,
                  color: streakColor,
                  size: 24,
                ),
              const SizedBox(width: 8),
              Text(
                '$streakCount',
                style: GoogleFonts.notoSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: streakColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '일',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors2025.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 라벨
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors2025.textSecondary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 최고 기록
          Text(
            '최고: $maxStreak일',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: AppColors2025.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStreakColor() {
    if (streakCount >= 30) return AppColors2025.sunriseOrange;
    if (streakCount >= 14) return AppColors2025.twilightPurple;
    if (streakCount >= 7) return AppColors2025.success;
    if (streakCount >= 3) return AppColors2025.warning;
    return AppColors2025.info;
  }
}

// ==================== 경험치 바 ====================

/// 경험치 바 컴포넌트
class SherpaXPBar extends StatelessWidget {
  final int currentXP;
  final int requiredXP;
  final int currentLevel;
  final Color? color;

  const SherpaXPBar({
    Key? key,
    required this.currentXP,
    required this.requiredXP,
    required this.currentLevel,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = currentXP / requiredXP;
    final xpColor = color ?? AppColors2025.primary;
    
    return SherpaLinearProgress(
      progress: progress.clamp(0.0, 1.0),
      label: 'Level $currentLevel',
      subtitle: '$currentXP / $requiredXP XP',
      color: xpColor,
      height: 12,
      style: LinearProgressStyle.glass,
      leading: Container(
        width: 32,
        height: 32,
        decoration: GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.medium,
          color: xpColor,
          borderRadius: 16,
          opacity: 0.2,
        ),
        child: Center(
          child: Text(
            '$currentLevel',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: xpColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 열거형 정의 ====================

enum LinearProgressStyle {
  glass,    // 글래스모피즘
  neu,      // 뉴모피즘
  flat,     // 플랫
}

enum BadgeRarity {
  common,     // 일반
  rare,       // 레어
  epic,       // 에픽
  legendary,  // 전설
}

// ==================== 커스텀 페인터 ====================

/// 원형 진행도 페인터
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // 배경 원
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 진행도 호
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 시작점을 위쪽으로
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}