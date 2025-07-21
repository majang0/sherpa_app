import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../providers/global_sherpi_provider.dart';
import '../../core/constants/sherpi_dialogues.dart';
import '../../core/constants/app_colors.dart';

// 메인 셰르피 위젯 - 전역에서 사용 가능한 애니메이션 캐릭터
class SherpiWidget extends ConsumerStatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final bool showDialogue;
  final Duration animationDuration;
  final bool enableInteraction;

  const SherpiWidget({
    Key? key,
    this.width = 120,
    this.height = 120,
    this.margin,
    this.showDialogue = true,
    this.animationDuration = const Duration(milliseconds: 400),
    this.enableInteraction = true,
  }) : super(key: key);

  @override
  ConsumerState<SherpiWidget> createState() => _SherpiWidgetState();
}

class _SherpiWidgetState extends ConsumerState<SherpiWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late AnimationController _dialogueController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _dialogueOpacity;
  late Animation<Offset> _dialogueSlide;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _dialogueController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticInOut,
    ));

    _dialogueOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogueController,
      curve: Curves.easeOut,
    ));

    _dialogueSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dialogueController,
      curve: Curves.easeOutBack,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    _dialogueController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sherpiState = ref.watch(sherpiProvider);
    final isVisible = ref.watch(sherpiVisibilityProvider);

    // 가시성 변화 감지 및 애니메이션 트리거
    ref.listen(sherpiVisibilityProvider, (previous, next) {
      if (next && !_scaleController.isCompleted) {
        _scaleController.forward();
        _bounceController.repeat(reverse: true);
        _glowController.repeat(reverse: true);

        if (widget.showDialogue && sherpiState.dialogue.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _dialogueController.forward();
          });
        }
      } else if (!next && _scaleController.isCompleted) {
        _scaleController.reverse();
        _bounceController.stop();
        _glowController.stop();
        _dialogueController.reverse();
      }
    });

    // 감정 변화 감지 및 반응
    ref.listen(sherpiEmotionProvider, (previous, next) {
      if (previous != next && isVisible) {
        _triggerEmotionChange();
      }
    });

    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 대화창 (위에 표시)
          if (widget.showDialogue && sherpiState.dialogue.isNotEmpty)
            AnimatedBuilder(
              animation: _dialogueController,
              builder: (context, child) {
                return SlideTransition(
                  position: _dialogueSlide,
                  child: FadeTransition(
                    opacity: _dialogueOpacity,
                    child: _buildDialogueBubble(sherpiState.dialogue, sherpiState.emotion),
                  ),
                );
              },
            ),

          const SizedBox(height: 8),

          // 셰르피 캐릭터
          AnimatedBuilder(
            animation: Listenable.merge([_scaleController, _bounceController, _glowController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value * (1.0 + _bounceAnimation.value * 0.08),
                child: _buildSherpiCharacter(sherpiState),
              );
            },
          ),
        ],
      ),
    );
  }

  // 대화 말풍선 위젯 (감정에 따른 색상 변화)
  Widget _buildDialogueBubble(String dialogue, SherpiEmotion emotion) {
    final bubbleColor = _getEmotionBubbleColor(emotion);

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bubbleColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bubbleColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dialogue,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _getEmotionTextColor(emotion),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          // 말풍선 꼬리
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: CustomPaint(
              size: const Size(16, 8),
              painter: BubbleTailPainter(bubbleColor),
            ),
          ),
        ],
      ),
    );
  }

  // 셰르피 캐릭터 위젯 (감정별 글로우 효과)
  Widget _buildSherpiCharacter(SherpiState state) {
    final emotionColor = _getEmotionColor(state.emotion);

    return GestureDetector(
      onTap: widget.enableInteraction ? () => _onSherpiTap(state) : null,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 외부 글로우 효과
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: widget.width! + (20 * _glowAnimation.value),
                  height: widget.height! + (20 * _glowAnimation.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        emotionColor.withOpacity(0.3 * _glowAnimation.value),
                        emotionColor.withOpacity(0.1 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),

            // 중간 링 효과
            Container(
              width: widget.width! * 0.9,
              height: widget.height! * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: emotionColor.withOpacity(0.4),
                  width: 2,
                ),
              ),
            ),

            // 셰르피 이미지
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: ClipOval(
                key: ValueKey(state.emotion),
                child: Container(
                  width: widget.width! * 0.8,
                  height: widget.height! * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: emotionColor.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    SherpiDialogueUtils.getImagePath(state.emotion),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackSherpi(state.emotion);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 이미지 로드 실패 시 대체 위젯
  Widget _buildFallbackSherpi(SherpiEmotion emotion) {
    final emotionColor = _getEmotionColor(emotion);

    return Container(
      width: widget.width! * 0.8,
      height: widget.height! * 0.8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            emotionColor.withOpacity(0.3),
            emotionColor.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: emotionColor.withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getEmotionEmoji(emotion),
              style: TextStyle(fontSize: widget.width! * 0.25),
            ),
            Text(
              'Sherpi',
              style: GoogleFonts.notoSans(
                fontSize: widget.width! * 0.08,
                fontWeight: FontWeight.w700,
                color: emotionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 셰르피 클릭 시 반응 (호출 시스템 적용)
  void _onSherpiTap(SherpiState state) {
    // 바운스 애니메이션
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    // ✅ 셰르피 호출 시스템 활용
    /*
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.guidance,
      customDialogue: "안녕하세요! 무엇을 도와드릴까요? 😊",
      emotion: SherpiEmotion.happy,
    );
    */

  }

  // 감정 변화 시 특별 애니메이션
  void _triggerEmotionChange() {
    _scaleController.forward(from: 0.8).then((_) {
      _scaleController.forward();
    });
  }

  // 감정에 따른 색상 반환
  Color _getEmotionColor(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.happy:
      case SherpiEmotion.cheering:
        return Colors.amber;
      case SherpiEmotion.sad:
        return Colors.blue;
      case SherpiEmotion.surprised:
        return Colors.orange;
      case SherpiEmotion.thinking:
        return Colors.purple;
      case SherpiEmotion.guiding:
        return AppColors.primary;
      case SherpiEmotion.warning:
        return Colors.red;
      case SherpiEmotion.sleeping:
        return Colors.indigo;
      case SherpiEmotion.special:
        return Colors.pink;
      default:
        return AppColors.primary;
    }
  }

  // 말풍선 색상 반환
  Color _getEmotionBubbleColor(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.happy:
      case SherpiEmotion.cheering:
        return Colors.yellow.shade100;
      case SherpiEmotion.sad:
        return Colors.blue.shade100;
      case SherpiEmotion.surprised:
        return Colors.orange.shade100;
      case SherpiEmotion.thinking:
        return Colors.purple.shade100;
      case SherpiEmotion.guiding:
        return AppColors.primary.withOpacity(0.1);
      case SherpiEmotion.warning:
        return Colors.red.shade100;
      case SherpiEmotion.sleeping:
        return Colors.indigo.shade100;
      case SherpiEmotion.special:
        return Colors.pink.shade100;
      default:
        return Colors.white;
    }
  }

  // 텍스트 색상 반환
  Color _getEmotionTextColor(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.warning:
        return Colors.red.shade800;
      case SherpiEmotion.sad:
        return Colors.blue.shade800;
      default:
        return AppColors.textPrimary;
    }
  }

  // 감정에 따른 이모지 반환
  String _getEmotionEmoji(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.happy:
        return '😊';
      case SherpiEmotion.sad:
        return '😢';
      case SherpiEmotion.surprised:
        return '😮';
      case SherpiEmotion.thinking:
        return '🤔';
      case SherpiEmotion.guiding:
        return '👋';
      case SherpiEmotion.cheering:
        return '🎉';
      case SherpiEmotion.warning:
        return '⚠️';
      case SherpiEmotion.sleeping:
        return '😴';
      case SherpiEmotion.special:
        return '✨';
      default:
        return '🏔️';
    }
  }
}

// 말풍선 꼬리 페인터
class BubbleTailPainter extends CustomPainter {
  final Color color;

  BubbleTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2 - 8, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2 + 8, 0);
    path.close();

    canvas.drawPath(path, paint);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ✅ 전역 오버레이 셰르피 위젯 (셰르피 호출 시스템 적용)
class GlobalSherpiOverlay extends ConsumerWidget {
  final Alignment alignment;
  final EdgeInsets margin;

  const GlobalSherpiOverlay({
    Key? key,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(sherpiVisibilityProvider);
    final sherpiState = ref.watch(sherpiProvider);

    // ✅ 조건부 반환 제거 - 항상 렌더링하되 내부에서 조건 처리
    return Positioned.fill(
      child: Stack(
        children: [
          // ✅ 셰르피 캐릭터 (간단한 Container로 안정성 확보)
          if (isVisible)
            Positioned(
              bottom: 120,
              right: 20,
              child: GestureDetector(
                onTap: () => ref.read(sherpiProvider.notifier).hideMessage(),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFFF8FAFC),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getEmotionColor(sherpiState.emotion).withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: _getEmotionColor(sherpiState.emotion).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval( // ✅ ClipOval로 오버플로우 방지
                    child: Stack( // ✅ Stack으로 레이어 관리
                      children: [
                        // ✅ 배경 컨테이너
                        Container(
                          width: 100,
                          height: 100,
                          color: _getEmotionColor(sherpiState.emotion).withOpacity(0.05),
                        ),
                        // ✅ 셰르피 이미지 (중앙 정렬)
                        Center(
                          child: Container(
                            width: 100, // ✅ 이미지 크기는 그대로
                            height: 100, // ✅ 이미지 크기는 그대로
                            child: ClipOval(
                              child: Image.asset(
                                SherpiDialogueUtils.getImagePath(sherpiState.emotion),
                                width: 85,
                                height: 85,
                                fit: BoxFit.cover, // ✅ 검색 결과[6]의 해결책
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 85,
                                    height: 85,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          _getEmotionColor(sherpiState.emotion).withOpacity(0.2),
                                          _getEmotionColor(sherpiState.emotion).withOpacity(0.05),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getEmotionEmoji(sherpiState.emotion),
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // ✅ 텍스트 (하단 고정 위치)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'Sherpi',
                              style: TextStyle(
                                color: _getEmotionColor(sherpiState.emotion).withOpacity(0.8),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ✅ 대화창 (Global Provider에서 가져온 대화 내용)
          if (isVisible && sherpiState.dialogue.isNotEmpty)
            Positioned(
              bottom: 240,
              right: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getEmotionColor(sherpiState.emotion).withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: _getEmotionColor(sherpiState.emotion).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ 감정별 색상 인디케이터
                    Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _getEmotionColor(sherpiState.emotion).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ✅ Global Provider에서 가져온 대화 내용
                    Text(
                      sherpiState.dialogue,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                        height: 1.5,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // ✅ 감정별 색상 말풍선 꼬리
                    CustomPaint(
                      size: const Size(16, 8),
                      painter: ModernBubbleTailPainter(
                        color: Colors.white,
                        borderColor: _getEmotionColor(sherpiState.emotion).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ 감정별 색상 반환 메서드
  Color _getEmotionColor(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.happy:
      case SherpiEmotion.cheering:
        return const Color(0xFFF59E0B);
      case SherpiEmotion.sad:
        return const Color(0xFF3B82F6);
      case SherpiEmotion.surprised:
        return const Color(0xFFEF4444);
      case SherpiEmotion.thinking:
        return const Color(0xFF8B5CF6);
      case SherpiEmotion.guiding:
        return const Color(0xFF10B981);
      case SherpiEmotion.warning:
        return const Color(0xFFF97316);
      case SherpiEmotion.special:
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6366F1);
    }
  }

  // ✅ 감정별 이모지 반환 메서드
  String _getEmotionEmoji(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.happy:
        return '😊';
      case SherpiEmotion.cheering:
        return '🎉';
      case SherpiEmotion.sad:
        return '😢';
      case SherpiEmotion.surprised:
        return '😮';
      case SherpiEmotion.thinking:
        return '🤔';
      case SherpiEmotion.guiding:
        return '👋';
      case SherpiEmotion.warning:
        return '⚠️';
      case SherpiEmotion.special:
        return '✨';
      default:
        return '🏔️';
    }
  }
}

// 모던 말풍선 꼬리 페인터
class ModernBubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  ModernBubbleTailPainter({
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    path.moveTo(size.width / 2 - 8, 0);
    path.quadraticBezierTo(size.width / 2, size.height - 2, size.width / 2, size.height);
    path.quadraticBezierTo(size.width / 2, size.height - 2, size.width / 2 + 8, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


