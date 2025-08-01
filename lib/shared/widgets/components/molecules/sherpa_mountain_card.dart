// lib/shared/widgets/components/molecules/sherpa_mountain_card.dart

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

/// 산악 등반을 시각화하는 테마 카드 컴포넌트
/// 사용자의 진행도, 레벨, 성취를 산 등반 메타포로 표현
class SherpaMountainCard extends StatefulWidget {
  final int currentLevel;
  final double progressPercent; // 0.0 ~ 1.0
  final int totalPoints;
  final String mountainName;
  final WeatherType weather;
  final MountainTimeOfDay timeOfDay;
  final List<String> badges;
  final VoidCallback? onTap;
  final MountainCardSize size;
  final bool showAnimations;
  final String? subtitle;

  const SherpaMountainCard({
    Key? key,
    required this.currentLevel,
    required this.progressPercent,
    required this.totalPoints,
    this.mountainName = '에베레스트',
    this.weather = WeatherType.clear,
    this.timeOfDay = MountainTimeOfDay.day,
    this.badges = const [],
    this.onTap,
    this.size = MountainCardSize.large,
    this.showAnimations = true,
    this.subtitle,
  }) : super(key: key);

  @override
  State<SherpaMountainCard> createState() => _SherpaMountainCardState();
}

class _SherpaMountainCardState extends State<SherpaMountainCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _cloudsController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _cloudsController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progressPercent,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutQuart,
    ));

    if (widget.showAnimations) {
      _progressController.forward();
      _cloudsController.repeat();
    } else {
      _progressController.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getCardConfiguration();
    
    Widget card = Container(
      width: double.infinity,
      height: config.height,
      decoration: GlassNeuStyle.glassMorphism(
        elevation: GlassNeuElevation.medium,
        color: AppColors2025.primary,
        borderRadius: AppSizes.radiusL,
        opacity: 0.1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Stack(
          children: [
            // 배경 그라데이션 (시간대 기반)
            _buildBackgroundGradient(),
            
            // 산의 실루엣들
            _buildMountainSilhouettes(),
            
            // 구름 효과
            if (widget.weather == WeatherType.cloudy || 
                widget.weather == WeatherType.foggy)
              _buildClouds(),
            
            // 진행도 오버레이
            _buildProgressOverlay(),
            
            // 콘텐츠 레이어
            _buildContentLayer(config),
            
            // 터치 효과
            if (widget.onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    onTap: widget.onTap,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    // 마이크로 인터랙션 적용
    if (widget.showAnimations && widget.onTap != null) {
      card = MicroInteractions.hoverEffect(
        scaleUpTo: 1.02,
        elevationIncrease: 4,
        child: card,
      );
    }

    return card;
  }

  MountainCardConfiguration _getCardConfiguration() {
    switch (widget.size) {
      case MountainCardSize.small:
        return const MountainCardConfiguration(
          height: 120,
          titleSize: 16,
          subtitleSize: 12,
          levelSize: 24,
          badgeSize: SherpaChipSize.small,
        );
      case MountainCardSize.medium:
        return const MountainCardConfiguration(
          height: 160,
          titleSize: 18,
          subtitleSize: 14,
          levelSize: 28,
          badgeSize: SherpaChipSize.medium,
        );
      case MountainCardSize.large:
        return const MountainCardConfiguration(
          height: 200,
          titleSize: 20,
          subtitleSize: 16,
          levelSize: 32,
          badgeSize: SherpaChipSize.large,
        );
      case MountainCardSize.extraLarge:
        return const MountainCardConfiguration(
          height: 240,
          titleSize: 24,
          subtitleSize: 18,
          levelSize: 36,
          badgeSize: SherpaChipSize.large,
        );
    }
  }

  Widget _buildBackgroundGradient() {
    LinearGradient gradient;
    
    switch (widget.timeOfDay) {
      case MountainTimeOfDay.dawn:
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2D1B69),  // 어두운 보라
            Color(0xFF8B5CF6),  // 보라
            Color(0xFFFBBF24),  // 황금색
          ],
          stops: [0.0, 0.6, 1.0],
        );
        break;
      case MountainTimeOfDay.day:
        gradient = AppColors2025.skyGradient;
        break;
      case MountainTimeOfDay.sunset:
        gradient = AppColors2025.sunriseGradient;
        break;
      case MountainTimeOfDay.night:
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),  // 어두운 파랑
            Color(0xFF1E293B),  // 중간 파랑
            Color(0xFF334155),  // 밝은 회색
          ],
          stops: [0.0, 0.7, 1.0],
        );
        break;
    }

    return Container(
      decoration: BoxDecoration(gradient: gradient),
    );
  }

  Widget _buildMountainSilhouettes() {
    return Stack(
      children: [
        // 뒷산 (멀리 있는 산)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(double.infinity, 120),
            painter: MountainSilhouettePainter(
              color: AppColors2025.deepMountainBlue.withOpacity(0.3),
              mountainIndex: 0,
            ),
          ),
        ),
        
        // 중간산
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(double.infinity, 100),
            painter: MountainSilhouettePainter(
              color: AppColors2025.mountainBlue.withOpacity(0.5),
              mountainIndex: 1,
            ),
          ),
        ),
        
        // 앞산 (가까운 산)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(double.infinity, 80),
            painter: MountainSilhouettePainter(
              color: AppColors2025.deepMountainBlue.withOpacity(0.7),
              mountainIndex: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClouds() {
    return AnimatedBuilder(
      animation: _cloudsController,
      builder: (context, child) {
        return Stack(
          children: [
            // 구름 1
            Positioned(
              top: 20,
              left: -50 + (_cloudsController.value * 400),
              child: CustomPaint(
                size: const Size(100, 40),
                painter: CloudPainter(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            
            // 구름 2 (다른 속도)
            Positioned(
              top: 50,
              left: -80 + (_cloudsController.value * 500),
              child: CustomPaint(
                size: const Size(120, 50),
                painter: CloudPainter(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressOverlay() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200 * _progressAnimation.value,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors2025.success.withOpacity(0.1),
                  AppColors2025.success.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentLayer(MountainCardConfiguration config) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 제목과 날씨
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mountainName,
                      style: GoogleFonts.notoSans(
                        fontSize: config.titleSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors2025.textOnDark,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: GoogleFonts.notoSans(
                          fontSize: config.subtitleSize,
                          color: AppColors2025.textOnDark.withOpacity(0.8),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // 날씨 아이콘
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors2025.glassWhite20,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  border: Border.all(
                    color: AppColors2025.glassBorder,
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getWeatherIcon(),
                  color: AppColors2025.textOnDark,
                  size: 20,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // 중앙: 레벨과 진행도
          Column(
            children: [
              // 현재 레벨
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LEVEL',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors2025.textOnDark.withOpacity(0.8),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors2025.glassWhite30,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color: AppColors2025.glassBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${widget.currentLevel}',
                      style: GoogleFonts.notoSans(
                        fontSize: config.levelSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors2025.textOnDark,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 진행도 바
              _buildProgressBar(),
            ],
          ),
          
          const Spacer(),
          
          // 하단: 포인트와 배지
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 포인트
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors2025.glassBlue20,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors2025.glassBorderBlue,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars,
                      size: 16,
                      color: AppColors2025.textOnDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.totalPoints}P',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors2025.textOnDark,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 배지들
              if (widget.badges.isNotEmpty)
                Row(
                  children: widget.badges.take(3).map((badge) {
                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: SherpaChip(
                        label: badge,
                        size: config.badgeSize,
                        variant: SherpaChipVariant.soft,
                        color: AppColors2025.warning,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors2025.glassWhite20,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors2025.glassBorder,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                AppColors2025.success,
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getWeatherIcon() {
    switch (widget.weather) {
      case WeatherType.clear:
        return widget.timeOfDay == MountainTimeOfDay.night 
            ? Icons.nightlight_round 
            : Icons.wb_sunny;
      case WeatherType.cloudy:
        return Icons.cloud;
      case WeatherType.rainy:
        return Icons.umbrella;
      case WeatherType.snowy:
        return Icons.ac_unit;
      case WeatherType.foggy:
        return Icons.foggy;
      case WeatherType.stormy:
        return Icons.thunderstorm;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cloudsController.dispose();
    super.dispose();
  }
}

// ==================== 열거형 정의 ====================

enum WeatherType {
  clear,    // 맑음
  cloudy,   // 흐림
  rainy,    // 비
  snowy,    // 눈
  foggy,    // 안개
  stormy,   // 폭풍
}

enum MountainTimeOfDay {
  dawn,     // 새벽
  day,      // 낮
  sunset,   // 석양
  night,    // 밤
}

enum MountainCardSize {
  small,       // 120px 높이
  medium,      // 160px 높이
  large,       // 200px 높이
  extraLarge,  // 240px 높이
}

// ==================== 도우미 클래스들 ====================

class MountainCardConfiguration {
  final double height;
  final double titleSize;
  final double subtitleSize;
  final double levelSize;
  final SherpaChipSize badgeSize;

  const MountainCardConfiguration({
    required this.height,
    required this.titleSize,
    required this.subtitleSize,
    required this.levelSize,
    required this.badgeSize,
  });
}

// ==================== 커스텀 페인터들 ====================

/// 산 실루엣 페인터
class MountainSilhouettePainter extends CustomPainter {
  final Color color;
  final int mountainIndex;

  MountainSilhouettePainter({
    required this.color,
    required this.mountainIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 산의 모양을 mountainIndex에 따라 다르게 생성
    switch (mountainIndex) {
      case 0: // 뒷산 (완만한 곡선)
        path.moveTo(0, size.height);
        path.quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width * 0.4, size.height * 0.5);
        path.quadraticBezierTo(size.width * 0.6, size.height * 0.7, size.width * 0.8, size.height * 0.4);
        path.quadraticBezierTo(size.width * 0.9, size.height * 0.3, size.width, size.height * 0.6);
        path.lineTo(size.width, size.height);
        path.close();
        break;
        
      case 1: // 중간산 (중간 급경사)
        path.moveTo(0, size.height);
        path.lineTo(size.width * 0.1, size.height * 0.7);
        path.lineTo(size.width * 0.3, size.height * 0.2);
        path.lineTo(size.width * 0.5, size.height * 0.4);
        path.lineTo(size.width * 0.7, size.height * 0.1);
        path.lineTo(size.width * 0.9, size.height * 0.5);
        path.lineTo(size.width, size.height * 0.3);
        path.lineTo(size.width, size.height);
        path.close();
        break;
        
      case 2: // 앞산 (험준한 봉우리)
        path.moveTo(0, size.height);
        path.lineTo(size.width * 0.15, size.height * 0.6);
        path.lineTo(size.width * 0.25, size.height * 0.1);
        path.lineTo(size.width * 0.35, size.height * 0.3);
        path.lineTo(size.width * 0.5, 0);
        path.lineTo(size.width * 0.65, size.height * 0.2);
        path.lineTo(size.width * 0.8, size.height * 0.4);
        path.lineTo(size.width * 0.95, size.height * 0.7);
        path.lineTo(size.width, size.height * 0.5);
        path.lineTo(size.width, size.height);
        path.close();
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MountainSilhouettePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.mountainIndex != mountainIndex;
  }
}

/// 구름 페인터
class CloudPainter extends CustomPainter {
  final Color color;

  CloudPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 구름 모양 생성
    final radius1 = size.height * 0.3;
    final radius2 = size.height * 0.4;
    final radius3 = size.height * 0.35;
    final radius4 = size.height * 0.25;
    
    path.addOval(Rect.fromCircle(
      center: Offset(radius1, size.height - radius1),
      radius: radius1,
    ));
    
    path.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.3, size.height - radius2),
      radius: radius2,
    ));
    
    path.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.6, size.height - radius3),
      radius: radius3,
    ));
    
    path.addOval(Rect.fromCircle(
      center: Offset(size.width - radius4, size.height - radius4),
      radius: radius4,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}