import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/utils/haptic_feedback_manager.dart';

/// 체크포인트 타일 위젯
/// 일일 체크포인트를 표시하는 리스트 아이템
class CheckpointTileWidget extends StatefulWidget {
  final Map<String, dynamic> checkpoint;
  final VoidCallback onToggle;

  const CheckpointTileWidget({
    required this.checkpoint,
    required this.onToggle,
    super.key,
  });

  @override
  State<CheckpointTileWidget> createState() => _CheckpointTileWidgetState();
}

class _CheckpointTileWidgetState extends State<CheckpointTileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.checkpoint['completed'] ?? false;
    final title = widget.checkpoint['title'] ?? '';
    final mountain = widget.checkpoint['mountain'] ?? '';
    final points = widget.checkpoint['points'] ?? 0;
    final category = widget.checkpoint['category'] ?? 'default';

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        HapticFeedbackManager.lightImpact();
        widget.onToggle();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isCompleted ? Colors.green.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.3)
                      : Colors.grey[200]!,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 체크박스
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? Colors.green : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          )
                            .animate()
                            .scale(duration: 200.ms, curve: Curves.elasticOut)
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // 콘텐츠
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 타이틀
                        Text(
                          title,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? Colors.grey[600]
                                : const Color(0xFF2D3142),
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 산 이름과 카테고리
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 14,
                              color: _getCategoryColor(category),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              mountain,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 상태 표시 (완료 또는 오늘)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle : Icons.schedule,
                              size: 14,
                              color: isCompleted
                                  ? Colors.green
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCompleted ? '완료' : '오늘',
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? Colors.green
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(height: 4),
                        Text(
                          '완료!',
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn().scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1, 1),
                            ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'health':
        return Colors.red[400]!;
      case 'study':
        return Colors.blue[400]!;
      case 'habit':
        return Colors.green[400]!;
      case 'social':
        return Colors.orange[400]!;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'health':
        return Icons.favorite;
      case 'study':
        return Icons.book;
      case 'habit':
        return Icons.repeat;
      case 'social':
        return Icons.people;
      default:
        return Icons.flag;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
