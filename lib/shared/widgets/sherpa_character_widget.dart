import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../providers/global_sherpi_provider.dart';
import '../models/sherpa_character.dart';

class SherpaCharacterWidget extends ConsumerStatefulWidget {
  final bool showMessage;
  final double size;
  final VoidCallback? onTap;

  const SherpaCharacterWidget({
    Key? key,
    this.showMessage = true,
    this.size = 32,
    this.onTap,
  }) : super(key: key);

  @override
  ConsumerState<SherpaCharacterWidget> createState() => _SherpaCharacterWidgetState();
}

class _SherpaCharacterWidgetState extends ConsumerState<SherpaCharacterWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _messageController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _messageAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _messageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sherpa = ref.watch(sherpiProvider);

    // 셰르피 상태가 변경될 때 애니메이션 실행
    ref.listen<SherpiState>(sherpiProvider, (previous, next) {
      if (previous?.emotion != next.emotion) {
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });

        if (widget.showMessage) {
          _messageController.forward();
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _messageController.reverse();
            }
          });
        }
      }
    });

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 셰르피 캐릭터
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: SherpiState.getEmotionColor(sherpa.emotion).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(widget.size / 2),
                  ),
                  child: Center(
                    child: Text(
                      sherpa.emoji,
                      style: TextStyle(fontSize: widget.size * 0.6),
                    ),
                  ),
                ),
              );
            },
          ),

          // 메시지 말풍선
          if (widget.showMessage)
            AnimatedBuilder(
              animation: _messageAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _messageAnimation.value,
                  child: Opacity(
                    opacity: _messageAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: SherpiState.getEmotionColor(sherpa.emotion),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        sherpa.message,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
