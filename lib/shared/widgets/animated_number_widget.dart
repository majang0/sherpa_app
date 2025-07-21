import 'package:flutter/material.dart';
import 'package:countup/countup.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/haptic_feedback_manager.dart';

class AnimatedNumberWidget extends StatefulWidget {
  final int value;
  final String suffix;
  final Color color;
  final double fontSize;
  final bool enableHaptic;
  final bool enableGlow;
  final Duration animationDuration;

  const AnimatedNumberWidget({
    Key? key,
    required this.value,
    this.suffix = '',
    required this.color,
    this.fontSize = 24,
    this.enableHaptic = true,
    this.enableGlow = true,
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<AnimatedNumberWidget> createState() => _AnimatedNumberWidgetState();
}

class _AnimatedNumberWidgetState extends State<AnimatedNumberWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedNumberWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      // 값이 증가했을 때만 애니메이션과 햅틱 피드백
      if (widget.value > _previousValue) {
        if (widget.enableHaptic) {
          HapticFeedbackManager.mediumImpact();
        }

        // 펄스 애니메이션
        _pulseController.forward().then((_) {
          _pulseController.reverse();
        });

        // 글로우 애니메이션
        if (widget.enableGlow) {
          _glowController.forward().then((_) {
            _glowController.reverse();
          });
        }
      }
      _previousValue = widget.value;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: widget.enableGlow ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: _glowAnimation.value * 0.6),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
            ) : null,
            child: Countup(
              begin: _previousValue.toDouble(),
              end: widget.value.toDouble(),
              duration: widget.animationDuration,
              separator: ',',
              style: GoogleFonts.notoSans(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w800,
                color: widget.color,
                shadows: widget.enableGlow ? [
                  Shadow(
                    color: widget.color.withValues(alpha: _glowAnimation.value * 0.8),
                    blurRadius: 10 * _glowAnimation.value,
                  ),
                ] : null,
              ),
              suffix: widget.suffix,
            ),
          ),
        );
      },
    );
  }
}
