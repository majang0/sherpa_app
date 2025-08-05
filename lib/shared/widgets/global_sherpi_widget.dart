import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../core/constants/app_colors.dart';
import '../../core/constants/sherpi_dialogues.dart';

// Features
import '../../features/sherpi_chat/presentation/screens/sherpi_chat_screen.dart';

// Shared
import '../providers/global_sherpi_provider.dart';
import '../../features/sherpi_relationship/providers/relationship_provider.dart';
import '../../features/sherpi_relationship/presentation/widgets/intimacy_level_widget.dart';

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
    // 햅틱 피드백 추가
    try {
      // HapticFeedback.mediumImpact();
      print("셰르피 터치됨"); // 햅틱 피드백 대신 로그
    } catch (e) {
      // 햅틱 피드백이 지원되지 않는 경우 무시
    }
    
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
      bottom: 100, // 더 눈에 띄는 위치로 상향 조정
      right: 20,   // 오른쪽 여백 증가
      child: GestureDetector(
        onTap: _onSherpiTapped,
        onLongPress: () => _startShakeAnimation(), // 길게 눌러서 주의 끌기
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseController,
            _bounceController,
            _shakeController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + 
                (_pulseController.value * 0.15) + // 더 강한 맥동 효과 (0.1→0.15)
                (_bounceController.value * 0.2),  // 더 강한 터치 피드백 (0.15→0.2)
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
      width: 76,   // 더 큰 크기로 조정 (기존 60→76)
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getEmotionGradient(emotionTheme),
        boxShadow: [
          BoxShadow(
            color: _getEmotionColor(emotionTheme).withOpacity(0.4), // 더 진한 그림자
            blurRadius: 16,  // 더 큰 블러 효과 (12→16)
            offset: const Offset(0, 6),  // 더 깊은 그림자 (4→6)
          ),
          BoxShadow(
            color: _getEmotionColor(emotionTheme).withOpacity(0.2),
            blurRadius: 24,  // 추가 외부 그림자로 입체감 증가
            offset: const Offset(0, 8),
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
                width: 60,   // 이미지 크기도 증가 (48→60)
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.face,
                    size: 40,   // 폴백 아이콘 크기도 증가
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
              top: 4,   // 더 여유로운 위치
              right: 4,
              child: Container(
                width: 20,  // 더 큰 배지 (16→20)
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.error,    // 앱 색상 시스템 사용
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_active,  // 더 명확한 알림 아이콘
                  size: 12,  // 아이콘 크기 증가 (8→12)
                  color: Colors.white,
                ),
              )
                .animate()
                .scale(begin: const Offset(0, 0))
                .then()
                .shimmer(duration: 1000.ms, color: Colors.white.withValues(alpha: 0.5)),
            ),
          
          // 친밀도 레벨 배지
          Consumer(
            builder: (context, ref, child) {
              final relationship = ref.watch(sherpiRelationshipProvider);
              return Positioned(
                bottom: 4,  // 더 여유로운 위치
                right: 4,
                child: Container(
                  width: 22,   // 더 큰 친밀도 배지 (18→22)
                  height: 22,
                  decoration: BoxDecoration(
                    color: _getIntimacyLevelColor(relationship.intimacyLevel),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _getIntimacyLevelColor(relationship.intimacyLevel).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${relationship.intimacyLevel}',
                      style: const TextStyle(
                        fontSize: 11,  // 텍스트 크기 증가 (9→11)
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
          .animate()
          .fadeIn(delay: 800.ms)
          .scale(begin: const Offset(0.5, 0.5)),
          
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
  
  /// 친밀도 레벨별 색상 반환
  Color _getIntimacyLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.blue.shade300;
      case 3:
        return Colors.green.shade400;
      case 4:
        return Colors.orange.shade400;
      case 5:
        return Colors.purple.shade400;
      case 6:
        return Colors.pink.shade400;
      case 7:
        return Colors.red.shade400;
      case 8:
        return Colors.indigo.shade500;
      case 9:
        return Colors.amber.shade500;
      case 10:
        return Colors.deepPurple.shade600;
      default:
        return AppColors.primary;
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
      backgroundColor: Colors.transparent,  // 투명 배경으로 커스텀 디자인
      insetPadding: const EdgeInsets.all(20),  // 화면 여백
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 650),  // 더 큰 크기
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),  // 더 둥근 모서리
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),  // 더 넓은 패딩
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 - 셰르피 이미지와 인사
            Row(
              children: [
                Container(
                  width: 80,   // 더 큰 아바타 (64→80)
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 3,  // 더 굵은 테두리
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      currentEmotion.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),  // 더 넓은 간격 (16→20)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '셰르피와 함께해요!',
                        style: GoogleFonts.notoSans(
                          fontSize: 22,    // 더 큰 타이틀 (20→22)
                          fontWeight: FontWeight.w800,  // 더 굵은 폰트 (w700→w800)
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _getEmotionDescription(currentEmotion),
                        style: GoogleFonts.notoSans(
                          fontSize: 15,    // 더 큰 서브타이틀 (14→15)
                          fontWeight: FontWeight.w500,  // 폰트 두께 추가
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 친밀도 표시
                      CompactIntimacyWidget(),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 28),  // 더 넓은 간격 (24→28)
            
            // 현재 메시지 표시
            if (sherpiState.dialogue.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),  // 더 넓은 패딩 (16→20)
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.05),
                      AppColors.primary.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),  // 더 둥근 모서리 (12→16)
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  sherpiState.dialogue,
                  style: GoogleFonts.notoSans(
                    fontSize: 17,     // 더 큰 메시지 텍스트 (16→17)
                    fontWeight: FontWeight.w500,  // 폰트 두께 추가
                    color: AppColors.textPrimary,
                    height: 1.6,      // 더 넓은 줄 간격 (1.5→1.6)
                  ),
                ),
              ),
            
            const SizedBox(height: 32),  // 더 넓은 간격 (24→32)
            
            // 액션 버튼들
            Column(
              children: [
                _buildActionButton(
                  context,
                  ref,
                  icon: Icons.chat_bubble,
                  title: '자세한 대화하기',
                  subtitle: '셰르피와 깊이 있는 대화를 나눠보세요',
                  onTap: () => _openChatScreen(context, ref),
                ),
                const SizedBox(height: 16),  // 더 넓은 버튼 간격 (12→16)
                _buildActionButton(
                  context,
                  ref,
                  icon: Icons.psychology,
                  title: '더 자세한 분석',
                  subtitle: '나의 패턴을 분석해보세요',
                  onTap: () => _showPatternAnalysis(context, ref),
                ),
                const SizedBox(height: 16),  // 더 넓은 버튼 간격 (12→16)
                _buildActionButton(
                  context,
                  ref,
                  icon: Icons.calendar_today,
                  title: '계획 세우기',
                  subtitle: '목표 달성을 위한 계획을 세워보세요',
                  onTap: () => _showPlanningMode(context, ref),
                ),
                const SizedBox(height: 16),  // 더 넓은 버튼 간격 (12→16)
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
          padding: const EdgeInsets.all(20),  // 더 넓은 패딩 (16→20)
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),  // 더 둥근 모서리 (12→16)
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,   // 더 큰 아이콘 컨테이너 (48→56)
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primary.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),  // 더 둥근 모서리 (12→16)
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 28,   // 더 큰 아이콘 (24→28)
                ),
              ),
              const SizedBox(width: 20),  // 더 넓은 간격 (16→20)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        fontSize: 17,    // 더 큰 타이틀 (16→17)
                        fontWeight: FontWeight.w700,  // 더 굵은 폰트 (w600→w700)
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),  // 타이틀과 서브타이틀 간격 추가
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSans(
                        fontSize: 15,    // 더 큰 서브타이틀 (14→15)
                        fontWeight: FontWeight.w500,  // 폰트 두께 추가
                        color: AppColors.textSecondary,
                        height: 1.3,     // 줄 간격 추가
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,   // 더 큰 화살표 아이콘 (16→18)
                color: AppColors.primary.withOpacity(0.6),  // 더 선명한 색상
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
  
  /// 채팅 화면 열기
  void _openChatScreen(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();
    
    // 채팅 화면으로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SherpiChatScreen(),
      ),
    );
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