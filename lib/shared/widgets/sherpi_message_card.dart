import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../core/constants/sherpi_dialogues.dart';

// Shared
import '../providers/global_sherpi_provider.dart';

/// 🎭 셰르피 메시지 카드 위젯
/// 
/// 셰르피의 메시지를 슬라이드업 애니메이션과 함께 표시하는 향상된 카드 위젯.
/// 감정 상태에 따른 시각적 피드백과 사용자 상호작용을 제공합니다.
class SherpiMessageCard extends ConsumerStatefulWidget {
  /// 메시지 표시 위치 (화면 하단에서의 오프셋)
  final double bottomOffset;
  
  /// 카드가 표시되는 지속 시간
  final Duration duration;
  
  /// 자동 숨김 여부
  final bool autoHide;
  
  /// 탭 시 호출할 콜백 함수
  final VoidCallback? onTap;
  
  /// 닫기 버튼 표시 여부
  final bool showCloseButton;

  const SherpiMessageCard({
    super.key,
    this.bottomOffset = 140, // BottomNavigationBar 위 약간의 여백
    this.duration = const Duration(seconds: 4),
    this.autoHide = true,
    this.onTap,
    this.showCloseButton = true,
  });

  @override
  ConsumerState<SherpiMessageCard> createState() => _SherpiMessageCardState();
}

class _SherpiMessageCardState extends ConsumerState<SherpiMessageCard> 
    with TickerProviderStateMixin {
      
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 슬라이드 애니메이션 컨트롤러
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // 페이드 애니메이션 컨트롤러  
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // 스케일 애니메이션 컨트롤러 (터치 피드백용)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    // 애니메이션 설정
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // 아래에서 시작
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    // 초기 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCard();
    });
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  /// 카드 표시 애니메이션
  Future<void> _showCard() async {
    await Future.wait([
      _slideController.forward(),
      _fadeController.forward(),
    ]);
    
    // 자동 숨김이 활성화된 경우 일정 시간 후 숨김
    if (widget.autoHide) {
      await Future.delayed(widget.duration);
      if (mounted) {
        _hideCard();
      }
    }
  }
  
  /// 카드 숨김 애니메이션
  Future<void> _hideCard() async {
    await Future.wait([
      _slideController.reverse(),
      _fadeController.reverse(),
    ]);
    
    // 셰르피 상태를 숨김으로 변경
    if (mounted) {
      ref.read(sherpiProvider.notifier).hideMessage();
    }
  }
  
  /// 터치 피드백 애니메이션
  Future<void> _onTapDown() async {
    await _scaleController.forward();
  }
  
  /// 터치 해제 애니메이션
  Future<void> _onTapUp() async {
    await _scaleController.reverse();
    
    // 사용자 정의 콜백 실행
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sherpiState = ref.watch(sherpiProvider);
    
    // 셰르피가 보이지 않으면 카드도 표시하지 않음
    if (!sherpiState.isVisible || sherpiState.dialogue.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final currentEmotion = sherpiState.emotion;
    final emotionTheme = SherpiEmotionMapper.getThemeForEmotion(currentEmotion);
    
    return Positioned(
      bottom: widget.bottomOffset,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTapDown: (_) => _onTapDown(),
              onTapUp: (_) => _onTapUp(),
              onTapCancel: () => _scaleController.reverse(),
              child: _buildMessageCard(sherpiState, currentEmotion, emotionTheme),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 메시지 카드 UI 구성
  Widget _buildMessageCard(
    SherpiState state, 
    SherpiEmotion emotion, 
    EmotionTheme theme
  ) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 350,
        minHeight: 80,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _getThemeGradient(theme),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getThemeColor(theme).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 셰르피 아바타
          _buildSherpiAvatar(emotion),
          
          const SizedBox(width: 12),
          
          // 메시지 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 메시지 텍스트
                Text(
                  state.dialogue,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 메시지 소스 및 시간 정보
                if (state.metadata != null)
                  _buildMessageMetadata(state.metadata!),
              ],
            ),
          ),
          
          // 닫기 버튼
          if (widget.showCloseButton)
            _buildCloseButton(),
        ],
      ),
    );
  }
  
  /// 셰르피 아바타 위젯
  Widget _buildSherpiAvatar(SherpiEmotion emotion) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          emotion.imagePath,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.face,
              size: 24,
              color: Colors.white.withValues(alpha: 0.8),
            );
          },
        ),
      ),
    );
  }
  
  /// 메시지 메타데이터 표시
  Widget _buildMessageMetadata(Map<String, dynamic> metadata) {
    final source = metadata['response_source'] as String?;
    final isFast = metadata['is_fast_response'] as bool? ?? false;
    
    String sourceIcon = '⚡';
    String sourceText = '정적';
    
    if (source != null) {
      switch (source) {
        case 'static':
          sourceIcon = '⚡';
          sourceText = '정적';
          break;
        case 'aiCached':
          sourceIcon = '🚀';
          sourceText = '캐시';
          break;
        case 'aiRealtime':
          sourceIcon = '🤖';
          sourceText = 'AI';
          break;
      }
    }
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sourceIcon,
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 2),
              Text(
                sourceText,
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        
        if (isFast) ...[
          const SizedBox(width: 6),
          Icon(
            Icons.flash_on,
            size: 14,
            color: Colors.yellow.shade300,
          ),
        ],
      ],
    );
  }
  
  /// 닫기 버튼
  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: _hideCard,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Icon(
          Icons.close,
          size: 16,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
  
  /// 테마별 그라데이션 반환
  Gradient _getThemeGradient(EmotionTheme theme) {
    switch (theme) {
      case EmotionTheme.celebration:
        return LinearGradient(
          colors: [Colors.orange.shade500, Colors.amber.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.positive:
        return LinearGradient(
          colors: [Colors.green.shade500, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.analytical:
        return LinearGradient(
          colors: [Colors.purple.shade500, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.helpful:
        return LinearGradient(
          colors: [Colors.blue.shade500, Colors.cyan.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.surprise:
        return LinearGradient(
          colors: [Colors.pink.shade500, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.special:
        return LinearGradient(
          colors: [
            Colors.purple.shade500,
            Colors.pink.shade500,
            Colors.orange.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.supportive: 
        return LinearGradient(
          colors: [Colors.brown.shade400, Colors.orange.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.warning:
        return LinearGradient(
          colors: [Colors.orange.shade600, Colors.red.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.calm:
        return LinearGradient(
          colors: [Colors.grey.shade500, Colors.blueGrey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
  
  /// 테마별 메인 색상 반환
  Color _getThemeColor(EmotionTheme theme) {
    switch (theme) {
      case EmotionTheme.celebration:
        return Colors.orange;
      case EmotionTheme.positive:
        return Colors.green;
      case EmotionTheme.analytical:
        return Colors.purple;
      case EmotionTheme.helpful:
        return Colors.blue;
      case EmotionTheme.surprise:
        return Colors.pink;
      case EmotionTheme.special:
        return Colors.purple;
      case EmotionTheme.supportive:
        return Colors.brown;
      case EmotionTheme.warning:
        return Colors.orange;
      case EmotionTheme.calm:
        return Colors.grey;
    }
  }
}

/// 🎯 셰르피 메시지 카드 표시를 위한 유틸리티 확장
extension SherpiMessageCardExtension on WidgetRef {
  /// 향상된 메시지 카드로 셰르피 메시지 표시
  Future<void> showSherpiCard(
    SherpiContext context, {
    SherpiEmotion? emotion,
    Duration? duration,
    double? bottomOffset,
    bool autoHide = true,
    VoidCallback? onTap,
  }) async {
    // 먼저 셰르피 메시지를 설정
    await read(sherpiProvider.notifier).showMessage(
      context: context,
      emotion: emotion,
      duration: duration ?? const Duration(seconds: 4),
      forceShow: true,
    );
  }
  
  /// 커스텀 메시지로 셰르피 카드 표시
  void showCustomSherpiCard(
    SherpiContext context,
    String dialogue, {
    SherpiEmotion? emotion,
    Duration? duration,
    double? bottomOffset,
    bool autoHide = true,
    VoidCallback? onTap,
  }) {
    read(sherpiProvider.notifier).showInstantMessage(
      context: context,
      customDialogue: dialogue,
      emotion: emotion,
      duration: duration ?? const Duration(seconds: 4),
    );
  }
}