import 'package:flutter/material.dart';
import '../utils/haptic_feedback_manager.dart';

class RotatingIconWidget extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final bool autoRotate;
  final Duration rotationDuration;

  const RotatingIconWidget({
    Key? key,
    required this.icon,
    required this.color,
    this.size = 24,
    this.onTap,
    this.autoRotate = false,
    this.rotationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<RotatingIconWidget> createState() => _RotatingIconWidgetState();
}

class _RotatingIconWidgetState extends State<RotatingIconWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: widget.rotationDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    if (widget.autoRotate) {
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedbackManager.lightImpact();

    // 스케일 애니메이션
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // 회전 애니메이션
    if (!widget.autoRotate) {
      _rotationController.forward().then((_) {
        _rotationController.reset();
      });
    }

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.size,
              ),
            ),
          );
        },
      ),
    );
  }
}
