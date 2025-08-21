// lib/shared/widgets/components/atoms/sherpa_progress_2025.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 진행률 표시 컴포넌트
/// 다양한 스타일의 진행률 표시기를 지원하는 고급 프로그레스 인디케이터
class SherpaProgress2025 extends StatefulWidget {
  final double value;
  final double? secondaryValue;
  final SherpaProgressVariant2025 variant;
  final SherpaProgressSize2025 size;
  final Color? backgroundColor;
  final Color? color;
  final Color? secondaryColor;
  final String? label;
  final bool showLabel;
  final bool showPercentage;
  final bool animated;
  final Duration animationDuration;
  final Curve animationCurve;
  final double? strokeWidth;
  final String? category;
  final Color? customColor;
  final bool enableMicroInteractions;
  final Widget? centerWidget;
  final SherpaProgressStyle style;
  final List<Color>? gradientColors;
  final bool enableGlow;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const SherpaProgress2025({
    Key? key,
    required this.value,
    this.secondaryValue,
    this.variant = SherpaProgressVariant2025.linear,
    this.size = SherpaProgressSize2025.medium,
    this.backgroundColor,
    this.color,
    this.secondaryColor,
    this.label,
    this.showLabel = false,
    this.showPercentage = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationCurve = Curves.easeOutCubic,
    this.strokeWidth,
    this.category,
    this.customColor,
    this.enableMicroInteractions = true,
    this.centerWidget,
    this.style = SherpaProgressStyle.glass,
    this.gradientColors,
    this.enableGlow = false,
    this.width,
    this.height,
    this.padding,
  }) : assert(value >= 0.0 && value <= 1.0), super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 선형 진행률 바 (기본)
  factory SherpaProgress2025.linear({
    Key? key,
    required double value,
    String? label,
    String? category,
    bool showPercentage = true,
    double? width,
    SherpaProgressSize2025 size = SherpaProgressSize2025.medium,
  }) {
    return SherpaProgress2025(
      key: key,
      value: value,
      label: label,
      category: category,
      showPercentage: showPercentage,
      width: width,
      size: size,
      variant: SherpaProgressVariant2025.linear,
      style: SherpaProgressStyle.glass,
    );
  }

  /// 원형 진행률 (서클)
  factory SherpaProgress2025.circular({
    Key? key,
    required double value,
    String? label,
    String? category,
    bool showPercentage = true,
    Widget? centerWidget,
    SherpaProgressSize2025 size = SherpaProgressSize2025.medium,
  }) {
    return SherpaProgress2025(
      key: key,
      value: value,
      label: label,
      category: category,
      showPercentage: showPercentage,
      centerWidget: centerWidget,
      size: size,
      variant: SherpaProgressVariant2025.circular,
      style: SherpaProgressStyle.glass,
    );
  }

  /// 반원형 진행률 (게이지)
  factory SherpaProgress2025.gauge({
    Key? key,
    required double value,
    String? label,
    String? category,
    bool showPercentage = true,
    SherpaProgressSize2025 size = SherpaProgressSize2025.large,
  }) {
    return SherpaProgress2025(
      key: key,
      value: value,
      label: label,
      category: category,
      showPercentage: showPercentage,
      size: size,
      variant: SherpaProgressVariant2025.gauge,
      style: SherpaProgressStyle.neu,
    );
  }

  /// 링 진행률 (도넛)
  factory SherpaProgress2025.ring({
    Key? key,
    required double value,
    String? label,
    String? category,
    Widget? centerWidget,
    bool showPercentage = true,
    bool enableGlow = true,
    SherpaProgressSize2025 size = SherpaProgressSize2025.medium,
  }) {
    return SherpaProgress2025(
      key: key,
      value: value,
      label: label,
      category: category,
      centerWidget: centerWidget,
      showPercentage: showPercentage,
      enableGlow: enableGlow,
      size: size,
      variant: SherpaProgressVariant2025.ring,
      style: SherpaProgressStyle.gradient,
    );
  }

  /// 스텝 진행률 (단계별)
  factory SherpaProgress2025.stepped({
    Key? key,
    required double value,
    String? label,
    String? category,
    bool showPercentage = false,
    SherpaProgressSize2025 size = SherpaProgressSize2025.medium,
  }) {
    return SherpaProgress2025(
      key: key,
      value: value,
      label: label,
      category: category,
      showPercentage: showPercentage,
      size: size,
      variant: SherpaProgressVariant2025.stepped,
      style: SherpaProgressStyle.glass,
    );
  }

  /// 웨이브 진행률 (물결)
  factory SherpaProgress2025.wave({
    Key? key,
    required double value,
    String? label,
    String? category,
    bool showPercentage = true,
    List<Color>? gradientColors,
    SherpaProgressSize2025 size = SherpaProgressSize2025.large,
  }) {
    return SherpaProgress2025(
      key: key,
      value: value,
      label: label,
      category: category,
      showPercentage: showPercentage,
      gradientColors: gradientColors,
      size: size,
      variant: SherpaProgressVariant2025.wave,
      style: SherpaProgressStyle.gradient,
    );
  }

  @override
  State<SherpaProgress2025> createState() => _SherpaProgress2025State();
}

class _SherpaProgress2025State extends State<SherpaProgress2025>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: widget.animationCurve,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.animated) {
      _progressController.forward();
    }

    if (widget.enableGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SherpaProgress2025 oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.value != widget.value) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: widget.animationCurve,
      ));
      
      if (widget.animated) {
        _progressController.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getProgressConfiguration();

    Widget progress = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLabel && widget.label != null) ...[ 
            Text(
              widget.label!,
              style: GoogleFonts.notoSans(
                fontSize: config.labelSize,
                fontWeight: FontWeight.w600,
                color: AppColors2025.textSecondary,
              ),
            ),
            SizedBox(height: config.spacing),
          ],
          _buildProgressIndicator(config),
          if (widget.showPercentage) ...[
            SizedBox(height: config.spacing / 2),
            _buildPercentageLabel(config),
          ],
        ],
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      progress = MicroInteractions.slideInFade(
        child: progress,
        direction: SlideDirection.left,
      );
    }

    return progress;
  }

  Widget _buildProgressIndicator(ProgressConfiguration config) {
    switch (widget.variant) {
      case SherpaProgressVariant2025.linear:
        return _buildLinearProgress(config);
      case SherpaProgressVariant2025.circular:
        return _buildCircularProgress(config);
      case SherpaProgressVariant2025.gauge:
        return _buildGaugeProgress(config);
      case SherpaProgressVariant2025.ring:
        return _buildRingProgress(config);
      case SherpaProgressVariant2025.stepped:
        return _buildSteppedProgress(config);
      case SherpaProgressVariant2025.wave:
        return _buildWaveProgress(config);
    }
  }

  Widget _buildLinearProgress(ProgressConfiguration config) {
    return Container(
      height: config.height,
      decoration: _getTrackDecoration(config),
      child: AnimatedBuilder(
        animation: widget.animated ? _progressAnimation : 
                   AlwaysStoppedAnimation(widget.value),
        builder: (context, child) {
          return Stack(
            children: [
              FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: _getProgressDecoration(config),
                ),
              ),
              if (widget.secondaryValue != null)
                FractionallySizedBox(
                  widthFactor: widget.secondaryValue!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (widget.secondaryColor ?? config.color)
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(config.borderRadius),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircularProgress(ProgressConfiguration config) {
    return SizedBox(
      width: config.size,
      height: config.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: widget.animated ? _progressAnimation : 
                       AlwaysStoppedAnimation(widget.value),
            builder: (context, child) {
              return CustomPaint(
                size: Size(config.size, config.size),
                painter: _CircularProgressPainter(
                  progress: _progressAnimation.value,
                  backgroundColor: config.backgroundColor,
                  color: config.color,
                  strokeWidth: config.strokeWidth,
                  style: widget.style,
                  enableGlow: widget.enableGlow,
                  glowAnimation: widget.enableGlow ? _glowAnimation : null,
                ),
              );
            },
          ),
          if (widget.centerWidget != null)
            widget.centerWidget!
          else if (widget.showPercentage)
            Text(
              '${(_progressAnimation.value * 100).round()}%',
              style: GoogleFonts.notoSans(
                fontSize: config.centerTextSize,
                fontWeight: FontWeight.w700,
                color: config.color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGaugeProgress(ProgressConfiguration config) {
    return SizedBox(
      width: config.size,
      height: config.size * 0.6,
      child: AnimatedBuilder(
        animation: widget.animated ? _progressAnimation : 
                   AlwaysStoppedAnimation(widget.value),
        builder: (context, child) {
          return CustomPaint(
            size: Size(config.size, config.size * 0.6),
            painter: _GaugeProgressPainter(
              progress: _progressAnimation.value,
              backgroundColor: config.backgroundColor,
              color: config.color,
              strokeWidth: config.strokeWidth,
              style: widget.style,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRingProgress(ProgressConfiguration config) {
    return SizedBox(
      width: config.size,
      height: config.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              widget.animated ? _progressAnimation : 
                               AlwaysStoppedAnimation(widget.value),
              widget.enableGlow ? _glowAnimation : 
                                 AlwaysStoppedAnimation(1.0),
            ]),
            builder: (context, child) {
              return CustomPaint(
                size: Size(config.size, config.size),
                painter: _RingProgressPainter(
                  progress: _progressAnimation.value,
                  backgroundColor: config.backgroundColor,
                  color: config.color,
                  strokeWidth: config.strokeWidth,
                  style: widget.style,
                  gradientColors: widget.gradientColors,
                  enableGlow: widget.enableGlow,
                  glowAnimation: widget.enableGlow ? _glowAnimation : null,
                ),
              );
            },
          ),
          if (widget.centerWidget != null)
            widget.centerWidget!
          else if (widget.showPercentage)
            Text(
              '${(_progressAnimation.value * 100).round()}%',
              style: GoogleFonts.notoSans(
                fontSize: config.centerTextSize,
                fontWeight: FontWeight.w700,
                color: config.color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSteppedProgress(ProgressConfiguration config) {
    const stepCount = 5;
    final completedSteps = (_progressAnimation.value * stepCount).floor();
    
    return Row(
      children: List.generate(stepCount, (index) {
        final isCompleted = index < completedSteps;
        final isActive = index == completedSteps && 
                        _progressAnimation.value < 1.0;
        
        return Expanded(
          child: Container(
            height: config.height,
            margin: EdgeInsets.only(
              right: index < stepCount - 1 ? config.spacing : 0,
            ),
            decoration: BoxDecoration(
              color: isCompleted
                  ? config.color
                  : (isActive
                      ? config.color.withOpacity(0.5)
                      : config.backgroundColor),
              borderRadius: BorderRadius.circular(config.borderRadius),
              border: isActive
                  ? Border.all(color: config.color, width: 2)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWaveProgress(ProgressConfiguration config) {
    return Container(
      height: config.height,
      decoration: _getTrackDecoration(config),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(config.borderRadius),
        child: AnimatedBuilder(
          animation: widget.animated ? _progressAnimation : 
                     AlwaysStoppedAnimation(widget.value),
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _WaveProgressPainter(
                progress: _progressAnimation.value,
                colors: widget.gradientColors ?? [
                  config.color,
                  config.color.withOpacity(0.7),
                ],
                waveHeight: 8,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPercentageLabel(ProgressConfiguration config) {
    return AnimatedBuilder(
      animation: widget.animated ? _progressAnimation : 
                 AlwaysStoppedAnimation(widget.value),
      builder: (context, child) {
        return Text(
          '${(_progressAnimation.value * 100).round()}%',
          style: GoogleFonts.notoSans(
            fontSize: config.percentageSize,
            fontWeight: FontWeight.w600,
            color: config.color,
          ),
        );
      },
    );
  }

  ProgressConfiguration _getProgressConfiguration() {
    final color = widget.customColor ??
        widget.color ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    switch (widget.size) {
      case SherpaProgressSize2025.small:
        return ProgressConfiguration(
          size: 60,
          height: 6,
          strokeWidth: widget.strokeWidth ?? 4,
          borderRadius: AppSizes.radiusS,
          labelSize: 12,
          percentageSize: 11,
          centerTextSize: 10,
          spacing: 6,
          color: color,
          backgroundColor: widget.backgroundColor ?? AppColors2025.surface,
        );
      case SherpaProgressSize2025.medium:
        return ProgressConfiguration(
          size: 80,
          height: 8,
          strokeWidth: widget.strokeWidth ?? 6,
          borderRadius: AppSizes.radiusM,
          labelSize: 14,
          percentageSize: 12,
          centerTextSize: 12,
          spacing: 8,
          color: color,
          backgroundColor: widget.backgroundColor ?? AppColors2025.surface,
        );
      case SherpaProgressSize2025.large:
        return ProgressConfiguration(
          size: 120,
          height: 12,
          strokeWidth: widget.strokeWidth ?? 8,
          borderRadius: AppSizes.radiusL,
          labelSize: 16,
          percentageSize: 14,
          centerTextSize: 16,
          spacing: 10,
          color: color,
          backgroundColor: widget.backgroundColor ?? AppColors2025.surface,
        );
    }
  }

  BoxDecoration _getTrackDecoration(ProgressConfiguration config) {
    switch (widget.style) {
      case SherpaProgressStyle.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.low,
          color: AppColors2025.neuBase,
          borderRadius: config.borderRadius,
          opacity: 0.3,
        );
      case SherpaProgressStyle.neu:
        return GlassNeuStyle.neumorphism(
          elevation: GlassNeuElevation.low,
          baseColor: config.backgroundColor,
          borderRadius: config.borderRadius,
          isPressed: true,
        );
      case SherpaProgressStyle.gradient:
        return BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(config.borderRadius),
        );
      case SherpaProgressStyle.solid:
        return BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(config.borderRadius),
        );
    }
  }

  BoxDecoration _getProgressDecoration(ProgressConfiguration config) {
    switch (widget.style) {
      case SherpaProgressStyle.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.medium,
          color: config.color,
          borderRadius: config.borderRadius,
          opacity: 0.8,
        );
      case SherpaProgressStyle.neu:
        return GlassNeuStyle.softNeumorphism(
          baseColor: config.color,
          borderRadius: config.borderRadius,
        );
      case SherpaProgressStyle.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradientColors ?? [
              config.color,
              config.color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(config.borderRadius),
        );
      case SherpaProgressStyle.solid:
        return BoxDecoration(
          color: config.color,
          borderRadius: BorderRadius.circular(config.borderRadius),
        );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}

// ==================== 커스텀 페인터들 ====================

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color color;
  final double strokeWidth;
  final SherpaProgressStyle style;
  final bool enableGlow;
  final Animation<double>? glowAnimation;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.color,
    required this.strokeWidth,
    required this.style,
    required this.enableGlow,
    this.glowAnimation,
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

    // 진행률 호
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (enableGlow && glowAnimation != null) {
      progressPaint.maskFilter = MaskFilter.blur(
        BlurStyle.solid,
        2.0 * glowAnimation!.value,
      );
    }

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.glowAnimation != glowAnimation;
  }
}

class _GaugeProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color color;
  final double strokeWidth;
  final SherpaProgressStyle style;

  _GaugeProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.color,
    required this.strokeWidth,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 호 (반원)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // 진행률 호
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugeProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _RingProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color color;
  final double strokeWidth;
  final SherpaProgressStyle style;
  final List<Color>? gradientColors;
  final bool enableGlow;
  final Animation<double>? glowAnimation;

  _RingProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.color,
    required this.strokeWidth,
    required this.style,
    this.gradientColors,
    required this.enableGlow,
    this.glowAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 링
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행률 링
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradientColors != null && gradientColors!.length > 1) {
      progressPaint.shader = SweepGradient(
        colors: gradientColors!,
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * progress,
      ).createShader(rect);
    } else {
      progressPaint.color = color;
    }

    if (enableGlow && glowAnimation != null) {
      progressPaint.maskFilter = MaskFilter.blur(
        BlurStyle.solid,
        3.0 * glowAnimation!.value,
      );
    }

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.glowAnimation != glowAnimation;
  }
}

class _WaveProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double waveHeight;

  _WaveProgressPainter({
    required this.progress,
    required this.colors,
    required this.waveHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final progressWidth = size.width * progress;
    final waveY = size.height * (1 - progress);

    path.moveTo(0, size.height);
    path.lineTo(0, waveY);

    // 웨이브 효과 생성
    for (double x = 0; x <= progressWidth; x += 2) {
      final y = waveY + 
                math.sin((x / 20) * 2 * math.pi) * waveHeight * 
                (1 - progress); // 진행률에 따라 웨이브 감소
      path.lineTo(x, y);
    }

    path.lineTo(progressWidth, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ==================== 열거형 정의 ====================

enum SherpaProgressVariant2025 {
  linear,       // 선형 프로그레스 바
  circular,     // 원형 프로그레스
  gauge,        // 게이지형 (반원)
  ring,         // 링형 (도넛)
  stepped,      // 단계별 프로그레스
  wave,         // 웨이브 프로그레스
}

enum SherpaProgressSize2025 {
  small,        // 작은 크기
  medium,       // 중간 크기
  large,        // 큰 크기
}

enum SherpaProgressStyle {
  glass,        // 글래스모피즘
  neu,          // 뉴모피즘
  gradient,     // 그라데이션
  solid,        // 솔리드
}

// ==================== 도우미 클래스들 ====================

class ProgressConfiguration {
  final double size;
  final double height;
  final double strokeWidth;
  final double borderRadius;
  final double labelSize;
  final double percentageSize;
  final double centerTextSize;
  final double spacing;
  final Color color;
  final Color backgroundColor;

  const ProgressConfiguration({
    required this.size,
    required this.height,
    required this.strokeWidth,
    required this.borderRadius,
    required this.labelSize,
    required this.percentageSize,
    required this.centerTextSize,
    required this.spacing,
    required this.color,
    required this.backgroundColor,
  });
}