import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../core/constants/app_colors.dart';
import '../../core/constants/sherpi_dialogues.dart';

// Shared
import '../providers/global_sherpi_provider.dart';

/// 🌟 전역 셰르피 위젯
/// 
/// 모든 화면에서 우측 하단에 표시되는 셰르피 컴패니언.
/// 현재 감정 상태를 표시하고 사용자와의 상호작용을 처리합니다.
class GlobalSherpiWidget extends ConsumerStatefulWidget {
  const GlobalSherpiWidget({super.key});

  @override
  ConsumerState<GlobalSherpiWidget> createState() => _GlobalSherpiWidgetState();
}

class _GlobalSherpiWidgetState extends ConsumerState<GlobalSherpiWidget>
    with TickerProviderStateMixin {
      
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _shakeController;
  
  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// 셰르피 탭 이벤트 처리
  void _onSherpiTapped() async {
    // 터치 피드백 애니메이션
    await _bounceController.forward();
    _bounceController.reset();
    
    final sherpiState = ref.read(sherpiProvider);
    
    // 현재 메시지가 있으면 확장 대화 표시
    if (sherpiState.isVisible && sherpiState.dialogue.isNotEmpty) {
      _showExpandedDialog();
    } else {
      // 새로운 인사 메시지 표시
      await ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.general,
        duration: const Duration(seconds: 4),
      );
    }
  }
  
  /// 확장 대화 다이얼로그 표시
  void _showExpandedDialog() {
    showDialog(
      context: context,
      builder: (context) => SherpiExpandedDialog(),
    );
  }
  
  /// 맥동 애니메이션 시작
  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }
  
  /// 맥동 애니메이션 중지
  void _stopPulseAnimation() {
    _pulseController.stop();
    _pulseController.reset();
  }
  
  /// 주의 끌기 애니메이션 (흔들기)
  void _startShakeAnimation() async {
    await _shakeController.forward();
    _shakeController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final sherpiState = ref.watch(sherpiProvider);
    
    // 셰르피가 메시지를 가지고 있으면 맥동 애니메이션
    if (sherpiState.isVisible && !_pulseController.isAnimating) {
      _startPulseAnimation();
    } else if (!sherpiState.isVisible && _pulseController.isAnimating) {
      _stopPulseAnimation();
    }
    
    return Positioned(
      bottom: 80, // FloatingActionButton 위치보다 약간 위
      right: 16,
      child: GestureDetector(
        onTap: _onSherpiTapped,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseController,
            _bounceController,
            _shakeController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + 
                (_pulseController.value * 0.1) + // 맥동 효과
                (_bounceController.value * 0.15), // 터치 피드백
              child: Transform.translate(
                offset: Offset(
                  _shakeController.value * 10 * 
                  (0.5 - ((_shakeController.value * 4) % 1).abs()), // 흔들기 효과
                  0,
                ),
                child: _buildSherpiAvatar(sherpiState),
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// 셰르피 아바타 위젯 구성
  Widget _buildSherpiAvatar(SherpiState state) {
    final currentEmotion = state.emotion;
    final emotionTheme = SherpiEmotionMapper.getThemeForEmotion(currentEmotion);
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getEmotionGradient(emotionTheme),
        boxShadow: [
          BoxShadow(
            color: _getEmotionColor(emotionTheme).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 셰르피 이미지
          Center(
            child: ClipOval(
              child: Image.asset(
                currentEmotion.imagePath,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.face,
                    size: 32,
                    color: Colors.white,
                  );
                },
              )
                .animate(key: ValueKey(currentEmotion))
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
            ),
          ),
          
          // 메시지 알림 배지
          if (state.isVisible && state.dialogue.isNotEmpty)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.chat,
                  size: 8,
                  color: Colors.white,
                ),
              )
                .animate()
                .scale(begin: const Offset(0, 0))
                .then()
                .shimmer(duration: 1000.ms, color: Colors.white.withValues(alpha: 0.5)),
            ),
          
          // 특별한 상황 이펙트
          if (currentEmotion == SherpiEmotion.special)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.yellow.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 2000.ms,
                )
                .fade(begin: 0.5, end: 0.0),
            ),
        ],
      ),
    );
  }
  
  /// 감정 테마에 따른 그라데이션 반환
  Gradient _getEmotionGradient(EmotionTheme theme) {
    switch (theme) {
      case EmotionTheme.celebration:
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.amber.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.positive:
        return LinearGradient(
          colors: [Colors.green.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.analytical:
        return LinearGradient(
          colors: [Colors.purple.shade400, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.helpful:
        return LinearGradient(
          colors: [Colors.blue.shade400, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.surprise:
        return LinearGradient(
          colors: [Colors.pink.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.special:
        return LinearGradient(
          colors: [
            Colors.purple.shade400,
            Colors.pink.shade400,
            Colors.orange.shade400,
            Colors.yellow.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.supportive:
        return LinearGradient(
          colors: [Colors.brown.shade300, Colors.orange.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.warning:
        return LinearGradient(
          colors: [Colors.orange.shade500, Colors.red.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EmotionTheme.calm:
        return LinearGradient(
          colors: [Colors.grey.shade400, Colors.purple.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
  
  /// 감정 테마에 따른 메인 색상 반환
  Color _getEmotionColor(EmotionTheme theme) {
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

/// 🎭 확장 대화 다이얼로그
class SherpiExpandedDialog extends ConsumerWidget {
  const SherpiExpandedDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sherpiState = ref.watch(sherpiProvider);
    final currentEmotion = sherpiState.emotion;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 - 셰르피 이미지와 인사
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      currentEmotion.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '셰르피와 함께해요!',
                        style: GoogleFonts.notoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _getEmotionDescription(currentEmotion),
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 현재 메시지 표시
            if (sherpiState.dialogue.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  sherpiState.dialogue,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // 액션 버튼들
            Column(
              children: [
                _buildActionButton(
                  context,
                  ref,
                  icon: Icons.psychology,
                  title: '더 자세한 분석',
                  subtitle: '나의 패턴을 분석해보세요',
                  onTap: () => _showPatternAnalysis(context, ref),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  context,
                  ref,
                  icon: Icons.calendar_today,
                  title: '계획 세우기',
                  subtitle: '목표 달성을 위한 계획을 세워보세요',
                  onTap: () => _showPlanningMode(context, ref),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  context,
                  ref,
                  icon: Icons.favorite,
                  title: '격려 받기',
                  subtitle: '힘이 되는 메시지를 들어보세요',
                  onTap: () => _showEncouragement(context, ref),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '닫기',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
      .animate()
      .scale(begin: const Offset(0.8, 0.8))
      .fade();
  }
  
  /// 액션 버튼 위젯 구성
  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 감정 상태 설명 반환
  String _getEmotionDescription(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.cheering:
        return '축하할 일이 있어요!';
      case SherpiEmotion.happy:
        return '오늘도 좋은 하루네요!';
      case SherpiEmotion.thinking:
        return '생각에 잠겨 있어요';
      case SherpiEmotion.guiding:
        return '도움이 필요하신가요?';
      case SherpiEmotion.surprised:
        return '놀라운 발견이 있어요!';
      case SherpiEmotion.special:
        return '특별한 순간이에요!';
      case SherpiEmotion.sad:
        return '괜찮아요, 함께해요';
      case SherpiEmotion.warning:
        return '중요한 알림이 있어요';
      case SherpiEmotion.sleeping:
        return '조용히 기다리고 있어요';
      default:
        return '안녕하세요!';
    }
  }
  
  /// 패턴 분석 표시
  void _showPatternAnalysis(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();
    // TODO: 패턴 분석 화면으로 이동 또는 상세 분석 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('패턴 분석 기능을 준비 중입니다')),
    );
  }
  
  /// 계획 모드 표시
  void _showPlanningMode(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();
    // TODO: 계획 세우기 모드 활성화
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('계획 세우기 기능을 준비 중입니다')),
    );
  }
  
  /// 격려 메시지 표시
  void _showEncouragement(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    await ref.read(sherpiProvider.notifier).showMessage(
      context: SherpiContext.encouragement,
      duration: const Duration(seconds: 5),
    );
  }
}