// lib/shared/widgets/components/atoms/sherpa_chart_2025.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 차트 컴포넌트
/// 다양한 데이터 시각화를 지원하는 고급 차트 라이브러리
class SherpaChart2025 extends StatefulWidget {
  final List<SherpaChartData> data;
  final SherpaChartType type;
  final SherpaChartStyle style;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? title;
  final String? subtitle;
  final List<Color>? colors;
  final bool showLabels;
  final bool showValues;
  final bool showLegend;
  final bool animated;
  final Duration animationDuration;
  final String? category;
  final Color? customColor;
  final bool enableMicroInteractions;
  final bool enableTooltip;
  final SherpaChartLegendPosition legendPosition;
  final double? maxValue;
  final double? minValue;
  final int? gridLines;
  final bool showGrid;
  final bool enableGradient;

  const SherpaChart2025({
    Key? key,
    required this.data,
    this.type = SherpaChartType.bar,
    this.style = SherpaChartStyle.glass,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.title,
    this.subtitle,
    this.colors,
    this.showLabels = true,
    this.showValues = false,
    this.showLegend = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.category,
    this.customColor,
    this.enableMicroInteractions = true,
    this.enableTooltip = false,
    this.legendPosition = SherpaChartLegendPosition.bottom,
    this.maxValue,
    this.minValue,
    this.gridLines,
    this.showGrid = true,
    this.enableGradient = false,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 막대 차트 (세로형)
  factory SherpaChart2025.bar({
    Key? key,
    required List<SherpaChartData> data,
    String? title,
    String? category,
    bool showLabels = true,
    bool showValues = true,
    double? height,
  }) {
    return SherpaChart2025(
      key: key,
      data: data,
      type: SherpaChartType.bar,
      title: title,
      category: category,
      showLabels: showLabels,
      showValues: showValues,
      height: height ?? 300,
      style: SherpaChartStyle.glass,
    );
  }

  /// 선 차트 (트렌드)
  factory SherpaChart2025.line({
    Key? key,
    required List<SherpaChartData> data,
    String? title,
    String? category,
    bool showLabels = true,
    bool enableGradient = true,
    double? height,
  }) {
    return SherpaChart2025(
      key: key,
      data: data,
      type: SherpaChartType.line,
      title: title,
      category: category,
      showLabels: showLabels,
      enableGradient: enableGradient,
      height: height ?? 250,
      style: SherpaChartStyle.gradient,
    );
  }

  /// 원형 차트 (파이)
  factory SherpaChart2025.pie({
    Key? key,
    required List<SherpaChartData> data,
    String? title,
    String? category,
    bool showLegend = true,
    bool showValues = true,
    double? size,
  }) {
    return SherpaChart2025(
      key: key,
      data: data,
      type: SherpaChartType.pie,
      title: title,
      category: category,
      showLegend: showLegend,
      showValues: showValues,
      width: size ?? 200,
      height: size ?? 200,
      style: SherpaChartStyle.neu,
    );
  }

  /// 도넛 차트
  factory SherpaChart2025.donut({
    Key? key,
    required List<SherpaChartData> data,
    String? title,
    String? category,
    bool showLegend = true,
    bool showValues = true,
    double? size,
  }) {
    return SherpaChart2025(
      key: key,
      data: data,
      type: SherpaChartType.donut,
      title: title,
      category: category,
      showLegend: showLegend,
      showValues: showValues,
      width: size ?? 200,
      height: size ?? 200,
      style: SherpaChartStyle.glass,
    );
  }

  /// 영역 차트 (면적)
  factory SherpaChart2025.area({
    Key? key,
    required List<SherpaChartData> data,
    String? title,
    String? category,
    bool showLabels = true,
    bool enableGradient = true,
    double? height,
  }) {
    return SherpaChart2025(
      key: key,
      data: data,
      type: SherpaChartType.area,
      title: title,
      category: category,
      showLabels: showLabels,
      enableGradient: enableGradient,
      height: height ?? 250,
      style: SherpaChartStyle.gradient,
    );
  }

  /// 방사형 차트 (레이더)
  factory SherpaChart2025.radar({
    Key? key,
    required List<SherpaChartData> data,
    String? title,
    String? category,
    bool showLabels = true,
    double? size,
  }) {
    return SherpaChart2025(
      key: key,
      data: data,
      type: SherpaChartType.radar,
      title: title,
      category: category,
      showLabels: showLabels,
      width: size ?? 250,
      height: size ?? 250,
      style: SherpaChartStyle.glass,
    );
  }

  @override
  State<SherpaChart2025> createState() => _SherpaChart2025State();
}

class _SherpaChart2025State extends State<SherpaChart2025>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MicroInteractions.easeOutQuart,
    ));

    if (widget.animated) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getChartConfiguration();

    Widget chart = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding,
      decoration: _getContainerDecoration(config),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null || widget.subtitle != null)
            _buildHeader(config),
          Expanded(
            child: widget.showLegend && 
                   widget.legendPosition == SherpaChartLegendPosition.top
                ? Column(
                    children: [
                      _buildLegend(config),
                      const SizedBox(height: 16),
                      Expanded(child: _buildChart(config)),
                    ],
                  )
                : widget.showLegend && 
                          widget.legendPosition == SherpaChartLegendPosition.bottom
                    ? Column(
                        children: [
                          Expanded(child: _buildChart(config)),
                          const SizedBox(height: 16),
                          _buildLegend(config),
                        ],
                      )
                    : _buildChart(config),
          ),
        ],
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.enableMicroInteractions) {
      chart = MicroInteractions.slideInFade(
        child: chart,
        direction: SlideDirection.bottom,
      );
    }

    return chart;
  }

  Widget _buildHeader(ChartConfiguration config) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors2025.textPrimary,
              ),
            ),
          if (widget.subtitle != null) ...[ 
            const SizedBox(height: 4),
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
    );
  }

  Widget _buildChart(ChartConfiguration config) {
    return AnimatedBuilder(
      animation: widget.animated ? _animation : AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        switch (widget.type) {
          case SherpaChartType.bar:
            return _BarChart(
              data: widget.data,
              config: config,
              animation: _animation,
              showLabels: widget.showLabels,
              showValues: widget.showValues,
              showGrid: widget.showGrid,
            );
          case SherpaChartType.line:
            return _LineChart(
              data: widget.data,
              config: config,
              animation: _animation,
              showLabels: widget.showLabels,
              enableGradient: widget.enableGradient,
              showGrid: widget.showGrid,
            );
          case SherpaChartType.pie:
            return _PieChart(
              data: widget.data,
              config: config,
              animation: _animation,
              showValues: widget.showValues,
            );
          case SherpaChartType.donut:
            return _DonutChart(
              data: widget.data,
              config: config,
              animation: _animation,
              showValues: widget.showValues,
            );
          case SherpaChartType.area:
            return _AreaChart(
              data: widget.data,
              config: config,
              animation: _animation,
              showLabels: widget.showLabels,
              enableGradient: widget.enableGradient,
            );
          case SherpaChartType.radar:
            return _RadarChart(
              data: widget.data,
              config: config,
              animation: _animation,
              showLabels: widget.showLabels,
            );
        }
      },
    );
  }

  Widget _buildLegend(ChartConfiguration config) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final color = config.colors[index % config.colors.length];
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              data.label,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors2025.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  ChartConfiguration _getChartConfiguration() {
    final primaryColor = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    final colors = widget.colors ?? _generateColors(primaryColor);

    return ChartConfiguration(
      colors: colors,
      primaryColor: primaryColor,
      maxValue: widget.maxValue ?? _calculateMaxValue(),
      minValue: widget.minValue ?? 0,
    );
  }

  List<Color> _generateColors(Color baseColor) {
    if (widget.data.length == 1) {
      return [baseColor];
    }

    final colors = <Color>[];
    for (int i = 0; i < widget.data.length; i++) {
      final hue = (baseColor.computeLuminance() * 360 + (i * 45)) % 360;
      colors.add(HSVColor.fromAHSV(1.0, hue.toDouble(), 0.7, 0.8).toColor());
    }
    return colors;
  }

  double _calculateMaxValue() {
    if (widget.data.isEmpty) return 100;
    return widget.data.map((d) => d.value).reduce(math.max) * 1.1;
  }

  BoxDecoration? _getContainerDecoration(ChartConfiguration config) {
    switch (widget.style) {
      case SherpaChartStyle.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.low,
          color: AppColors2025.surface,
          borderRadius: AppSizes.radiusM,
          opacity: 0.05,
        );
      case SherpaChartStyle.neu:
        return GlassNeuStyle.softNeumorphism(
          baseColor: AppColors2025.surface,
          borderRadius: AppSizes.radiusM,
          intensity: 0.02,
        );
      case SherpaChartStyle.gradient:
      case SherpaChartStyle.flat:
        return null;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// ==================== 차트 구현 위젯들 ====================

class _BarChart extends StatelessWidget {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showLabels;
  final bool showValues;
  final bool showGrid;

  const _BarChart({
    required this.data,
    required this.config,
    required this.animation,
    required this.showLabels,
    required this.showValues,
    required this.showGrid,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _BarChartPainter(
        data: data,
        config: config,
        animation: animation,
        showLabels: showLabels,
        showValues: showValues,
        showGrid: showGrid,
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showLabels;
  final bool enableGradient;
  final bool showGrid;

  const _LineChart({
    required this.data,
    required this.config,
    required this.animation,
    required this.showLabels,
    required this.enableGradient,
    required this.showGrid,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _LineChartPainter(
        data: data,
        config: config,
        animation: animation,
        showLabels: showLabels,
        enableGradient: enableGradient,
        showGrid: showGrid,
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showValues;

  const _PieChart({
    required this.data,
    required this.config,
    required this.animation,
    required this.showValues,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _PieChartPainter(
        data: data,
        config: config,
        animation: animation,
        showValues: showValues,
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showValues;

  const _DonutChart({
    required this.data,
    required this.config,
    required this.animation,
    required this.showValues,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _DonutChartPainter(
        data: data,
        config: config,
        animation: animation,
        showValues: showValues,
      ),
    );
  }
}

class _AreaChart extends StatelessWidget {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showLabels;
  final bool enableGradient;

  const _AreaChart({
    required this.data,
    required this.config,
    required this.animation,
    required this.showLabels,
    required this.enableGradient,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _AreaChartPainter(
        data: data,
        config: config,
        animation: animation,
        showLabels: showLabels,
        enableGradient: enableGradient,
      ),
    );
  }
}

class _RadarChart extends StatelessWidget {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showLabels;

  const _RadarChart({
    required this.data,
    required this.config,
    required this.animation,
    required this.showLabels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _RadarChartPainter(
        data: data,
        config: config,
        animation: animation,
        showLabels: showLabels,
      ),
    );
  }
}

// ==================== 커스텀 페인터들 ====================

class _BarChartPainter extends CustomPainter {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showLabels;
  final bool showValues;
  final bool showGrid;

  _BarChartPainter({
    required this.data,
    required this.config,
    required this.animation,
    required this.showLabels,
    required this.showValues,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartRect = Rect.fromLTWH(
      40, 20, 
      size.width - 80, 
      size.height - (showLabels ? 60 : 40),
    );

    // 그리드와 축 그리기
    if (showGrid) {
      _drawGrid(canvas, chartRect);
    }

    // 막대 그리기
    final barWidth = chartRect.width / data.length * 0.7;
    final barSpacing = chartRect.width / data.length * 0.3;

    for (int i = 0; i < data.length; i++) {
      final x = chartRect.left + (i * chartRect.width / data.length) + barSpacing / 2;
      final barHeight = (data[i].value / config.maxValue) * 
                       chartRect.height * animation.value;
      final y = chartRect.bottom - barHeight;

      final barRect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final paint = Paint()
        ..color = config.colors[i % config.colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
        paint,
      );

      // 값 표시
      if (showValues) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: data[i].value.toStringAsFixed(0),
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors2025.textSecondary,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x + (barWidth - textPainter.width) / 2,
            y - textPainter.height - 4,
          ),
        );
      }

      // 라벨 표시
      if (showLabels) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: data[i].label,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              color: AppColors2025.textTertiary,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x + (barWidth - textPainter.width) / 2,
            chartRect.bottom + 8,
          ),
        );
      }
    }
  }

  void _drawGrid(Canvas canvas, Rect chartRect) {
    final paint = Paint()
      ..color = AppColors2025.border
      ..strokeWidth = 0.5;

    // 수평 그리드 라인
    for (int i = 0; i <= 4; i++) {
      final y = chartRect.bottom - (i / 4) * chartRect.height;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// 다른 차트 페인터들은 비슷한 패턴으로 구현 (간단한 구현)
class _LineChartPainter extends CustomPainter {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showLabels;
  final bool enableGradient;
  final bool showGrid;

  _LineChartPainter({
    required this.data,
    required this.config,
    required this.animation,
    required this.showLabels,
    required this.enableGradient,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartRect = Rect.fromLTWH(40, 20, size.width - 80, size.height - 60);
    final path = Path();
    final paint = Paint()
      ..color = config.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 첫 번째 점으로 이동
    final firstX = chartRect.left;
    final firstY = chartRect.bottom - 
                  (data[0].value / config.maxValue) * chartRect.height;
    path.moveTo(firstX, firstY);

    // 선 그리기
    for (int i = 1; i < data.length; i++) {
      final x = chartRect.left + (i / (data.length - 1)) * chartRect.width;
      final y = chartRect.bottom - 
               (data[i].value / config.maxValue) * chartRect.height * animation.value;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _PieChartPainter extends CustomPainter {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showValues;

  _PieChartPainter({
    required this.data,
    required this.config,
    required this.animation,
    required this.showValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final total = data.fold(0.0, (sum, item) => sum + item.value);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * math.pi * animation.value;
      final paint = Paint()
        ..color = config.colors[i % config.colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showValues;

  _DonutChartPainter({
    required this.data,
    required this.config,
    required this.animation,
    required this.showValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2 - 20;
    final innerRadius = outerRadius * 0.6;
    final total = data.fold(0.0, (sum, item) => sum + item.value);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * math.pi * animation.value;
      final paint = Paint()
        ..color = config.colors[i % config.colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerRadius - innerRadius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (outerRadius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showLabels;
  final bool enableGradient;

  _AreaChartPainter({
    required this.data,
    required this.config,
    required this.animation,
    required this.showLabels,
    required this.enableGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartRect = Rect.fromLTWH(40, 20, size.width - 80, size.height - 60);
    final path = Path();

    // 시작점
    path.moveTo(chartRect.left, chartRect.bottom);

    // 데이터 포인트들
    for (int i = 0; i < data.length; i++) {
      final x = chartRect.left + (i / (data.length - 1)) * chartRect.width;
      final y = chartRect.bottom - 
               (data[i].value / config.maxValue) * chartRect.height * animation.value;
      path.lineTo(x, y);
    }

    // 끝점으로 닫기
    path.lineTo(chartRect.right, chartRect.bottom);
    path.close();

    final paint = Paint()
      ..style = PaintingStyle.fill;

    if (enableGradient) {
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          config.primaryColor.withOpacity(0.3),
          config.primaryColor.withOpacity(0.05),
        ],
      ).createShader(chartRect);
    } else {
      paint.color = config.primaryColor.withOpacity(0.2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_AreaChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<SherpaChartData> data;
  final ChartConfiguration config;
  final Animation<double> animation;
  final bool showLabels;

  _RadarChartPainter({
    required this.data,
    required this.config,
    required this.animation,
    required this.showLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    final angles = List.generate(
      data.length,
      (i) => (i * 2 * math.pi / data.length) - math.pi / 2,
    );

    // 배경 웹 그리기
    _drawRadarWeb(canvas, center, radius, data.length);

    // 데이터 영역 그리기
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final angle = angles[i];
      final value = (data[i].value / config.maxValue) * radius * animation.value;
      final x = center.dx + math.cos(angle) * value;
      final y = center.dy + math.sin(angle) * value;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..color = config.primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // 테두리 그리기
    final borderPaint = Paint()
      ..color = config.primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint);
  }

  void _drawRadarWeb(Canvas canvas, Offset center, double radius, int sides) {
    final paint = Paint()
      ..color = AppColors2025.border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 동심원 그리기
    for (int i = 1; i <= 4; i++) {
      final webRadius = radius * i / 4;
      canvas.drawCircle(center, webRadius, paint);
    }

    // 축 그리기
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final endX = center.dx + math.cos(angle) * radius;
      final endY = center.dy + math.sin(angle) * radius;
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(_RadarChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// ==================== 모델 클래스들 ====================

class SherpaChartData {
  final String label;
  final double value;
  final Color? color;

  const SherpaChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

// ==================== 열거형 정의 ====================

enum SherpaChartType {
  bar,          // 막대 차트
  line,         // 선 차트
  pie,          // 원형 차트
  donut,        // 도넛 차트
  area,         // 영역 차트
  radar,        // 방사형 차트
}

enum SherpaChartStyle {
  glass,        // 글래스모피즘
  neu,          // 뉴모피즘
  gradient,     // 그라데이션
  flat,         // 플랫
}

enum SherpaChartLegendPosition {
  top,          // 상단
  bottom,       // 하단
  left,         // 왼쪽
  right,        // 오른쪽
}

// ==================== 도우미 클래스들 ====================

class ChartConfiguration {
  final List<Color> colors;
  final Color primaryColor;
  final double maxValue;
  final double minValue;

  const ChartConfiguration({
    required this.colors,
    required this.primaryColor,
    required this.maxValue,
    required this.minValue,
  });
}