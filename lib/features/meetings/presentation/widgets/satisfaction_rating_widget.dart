import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// ⭐ 만족도 평가 위젯
class SatisfactionRatingWidget extends StatefulWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  const SatisfactionRatingWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  State<SatisfactionRatingWidget> createState() => _SatisfactionRatingWidgetState();
}

class _SatisfactionRatingWidgetState extends State<SatisfactionRatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 별점 슬라이더
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.warning,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: AppColors.warning,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            trackHeight: 6,
          ),
          child: Slider(
            value: widget.rating,
            min: 1.0,
            max: 5.0,
            divisions: 8, // 0.5 단위로 설정
            onChanged: (value) {
              _animationController.forward().then((_) {
                _animationController.reverse();
              });
              widget.onRatingChanged(value);
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 별 표시
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      starValue <= widget.rating
                          ? Icons.star_rounded
                          : starValue - 0.5 <= widget.rating
                              ? Icons.star_half_rounded
                              : Icons.star_outline_rounded,
                      size: 32,
                      color: starValue <= widget.rating + 0.5
                          ? AppColors.warning
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        // 점수 표시
        Text(
          '${widget.rating.toStringAsFixed(1)}/5.0',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}
