/// AI 분석 중 로딩 위젯
/// AI가 사용자 데이터를 분석하는 동안 표시되는 애니메이션 로딩 화면

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

import '../../../../../core/theme/modern_colors.dart';
import '../../../../../core/constants/sherpi_emotions.dart';

/// AI 분석 로딩 위젯
class AIAnalysisLoadingWidget extends StatefulWidget {
  const AIAnalysisLoadingWidget({super.key});

  @override
  State<AIAnalysisLoadingWidget> createState() =>
      _AIAnalysisLoadingWidgetState();
}

class _AIAnalysisLoadingWidgetState extends State<AIAnalysisLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _textController;

  int _currentTextIndex = 0;
  final List<String> _loadingTexts = [
    '당신의 활동 패턴을 분석하고 있어요...',
    '운동, 독서, 모임 기록을 살펴보는 중...',
    '성장 지표와 관심사를 파악하고 있어요...',
    '가장 적합한 모임을 찾고 있어요...',
    'AI가 맞춤 추천을 생성하는 중...',
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 텍스트 순환
    _startTextCycle();
  }

  void _startTextCycle() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) break;

      await _textController.forward();
      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
      });
      await _textController.reverse();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 셰르피 캐릭터 + AI 이펙트
            Stack(
              alignment: Alignment.center,
              children: [
                // 배경 원형 애니메이션
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.2),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ModernColors.primary.withValues(alpha: 0.1),
                              ModernColors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 회전하는 링
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(100, 100),
                        painter: _AIRingPainter(),
                      ),
                    );
                  },
                ),

                // 셰르피 이미지
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    SherpiEmotion.thinking.imagePath,
                    fit: BoxFit.contain,
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: const Duration(seconds: 2),
                    ),
              ],
            ),

            const SizedBox(height: 24),

            // AI 라벨
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.primary,
                    ModernColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI 분석 중',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .shimmer(
                  duration: const Duration(seconds: 2),
                  color: Colors.white.withValues(alpha: 0.3),
                ),

            const SizedBox(height: 16),

            // 로딩 텍스트
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: 1.0 - _textController.value,
                  child: Text(
                    _loadingTexts[_currentTextIndex],
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 프로그레스 바
            _buildProgressBar(),

            const SizedBox(height: 12),

            // 추가 정보
            Text(
              '잠시만 기다려주세요',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      width: 200,
      decoration: BoxDecoration(
        color: ModernColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 움직이는 프로그레스
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Container(
                    width: constraints.maxWidth * 0.3,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ModernColors.primary.withValues(alpha: 0.0),
                          ModernColors.primary,
                          ModernColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .slideX(
                        begin: -0.3,
                        end: 1.3,
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                      );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// AI 링 페인터
class _AIRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 그라데이션 링
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 여러 개의 호 그리기
    const arcCount = 4;
    const arcLength = math.pi / 3;
    const gap = (2 * math.pi - arcCount * arcLength) / arcCount;

    for (int i = 0; i < arcCount; i++) {
      final startAngle = i * (arcLength + gap);

      // 그라데이션 색상
      paint.shader = SweepGradient(
        colors: [
          ModernColors.primary.withValues(alpha: 0.0),
          ModernColors.primary,
          ModernColors.primary.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        startAngle: startAngle,
        endAngle: startAngle + arcLength,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcLength,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 간단한 로딩 인디케이터 (인라인용)
class SimpleAILoadingIndicator extends StatelessWidget {
  final String text;

  const SimpleAILoadingIndicator({
    super.key,
    this.text = 'AI가 분석 중...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ModernColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(ModernColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ModernColors.textPrimary,
            ),
          ),
        ],
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: const Duration(seconds: 2),
          color: ModernColors.primary.withValues(alpha: 0.1),
        );
  }
}
