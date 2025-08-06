import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/haptic_feedback_manager.dart';

class AnimatedProgressWidget extends StatefulWidget {
  final double progress;
  final double total;
  final String label;
  final Color progressColor;
  final Color backgroundColor;
  final bool showPercentage;
  final bool enableParticles;

  const AnimatedProgressWidget({
    Key? key,
    required this.progress,
    required this.total,
    required this.label,
    required this.progressColor,
    required this.backgroundColor,
    this.showPercentage = true,
    this.enableParticles = true,
  }) : super(key: key);

  @override
  State<AnimatedProgressWidget> createState() => _AnimatedProgressWidgetState();
}

class _AnimatedProgressWidgetState extends State<AnimatedProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress;

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress) {
      if (widget.progress > _previousProgress) {
        // 진행률이 증가했을 때 반짝임 효과와 햅틱 피드백
        HapticFeedbackManager.selection();
        _sparkleController.forward().then((_) {
          _sparkleController.reverse();
        });
      }
      _previousProgress = widget.progress;
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.progress / widget.total * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            if (widget.showPercentage)
              Text(
                '${percentage.toInt()}%',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.progressColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        Stack(
          children: [
            // 기본 진행률 바
            SimpleAnimationProgressBar(
              height: 8,
              width: double.infinity,
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.progressColor,
              ratio: widget.progress / widget.total,
              direction: Axis.horizontal,
              curve: Curves.easeOutCubic,
              duration: const Duration(milliseconds: 1000),
              borderRadius: BorderRadius.circular(4),
              gradientColor: LinearGradient(
                colors: [
                  widget.progressColor,
                  widget.progressColor.withOpacity(0.7),
                ],
              ),
            ),

            // 반짝임 효과
            if (widget.enableParticles)
              AnimatedBuilder(
                animation: _sparkleAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: (widget.progress / widget.total) *
                        (MediaQuery.of(context).size.width - 40) * _sparkleAnimation.value,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.progressColor.withOpacity(_sparkleAnimation.value),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
