import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/shared/models/global_user_model.dart';

// Core
import '../../core/theme/modern_colors.dart';
import '../../core/constants/sherpi_dialogues.dart';
import '../../core/animation/micro_interactions.dart';

// Features
import '../../features/sherpi/chat/presentation/screens/sherpi_chat_screen.dart';
import 'package:sherpa_app/features/sherpi/intelligence/services/analysis/user_data_analyzer.dart';
// import 'package:sherpa_app/features/sherpi/intelligence/services/analysis/ai_insight_generator.dart'; // AI 시스템 비활성화 - 사용하지 않는 import 제거
import '../../features/sherpi/analysis/presentation/screens/analysis_result_screen.dart';
import '../../features/sherpi/planning/presentation/screens/simple_planner_screen.dart';

// Shared
import 'package:sherpa_app/shared/providers/level_3_ai/global_sherpi_provider.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import '../../features/sherpi/relationship/providers/relationship_provider.dart';
import '../../features/sherpi/relationship/presentation/widgets/intimacy_level_widget.dart';
import 'sherpi_relationship_growth_widget.dart';
import 'sherpi_personalization_dialog.dart';
import 'dialogs/enhanced_today_analysis_dialog.dart';

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

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300), // 더 빠른 피드백
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  /// 셰르피 탭 이벤트 처리
  void _onSherpiTapped() {
    // 🔔 메시지를 읽음으로 표시 (알림 배지 숨김)
    final sherpiState = ref.read(sherpiProvider);
    if (sherpiState.isVisible && sherpiState.dialogue.isNotEmpty) {
      ref.read(sherpiProvider.notifier).markMessageAsRead();
    }

    // 즉시 다이얼로그 표시 - 애니메이션 지연 제거
    _showExpandedDialog();

    // 피드백 애니메이션은 비동기로 처리
    _bounceController.forward().then((_) {
      _bounceController.reset();
    });
  }

  /// 확장 대화 다이얼로그 표시
  void _showExpandedDialog() {
    // 안전성을 위한 mounted 체크
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const SherpiExpandedDialog(),
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

  @override
  Widget build(BuildContext context) {
    final sherpiState = ref.watch(sherpiProvider);

    // 셰르피가 메시지를 가지고 있으면 맥동 애니메이션
    if (sherpiState.isVisible && !_pulseController.isAnimating) {
      _startPulseAnimation();
    } else if (!sherpiState.isVisible && _pulseController.isAnimating) {
      _stopPulseAnimation();
    }

    return Stack(
      children: [
        // 메인 셰르피 플로팅 위젯
        Positioned(
          bottom: 100, // 더 눈에 띄는 위치로 상향 조정
          right: 20, // 오른쪽 여백 증가
          child: GestureDetector(
            onTap: _onSherpiTapped,
            behavior: HitTestBehavior.opaque, // 터치 영역 확대
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _pulseController,
                _bounceController,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 +
                      (_pulseController.value * 0.1) + // 부드러운 맥동
                      (_bounceController.value * 0.15), // 적절한 터치 피드백
                  child: _buildSherpiAvatar(sherpiState),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 셰르피 아바타 위젯 구성
  Widget _buildSherpiAvatar(SherpiState state) {
    final currentEmotion = state.emotion;
    final emotionTheme = SherpiEmotionMapper.getThemeForEmotion(currentEmotion);

    return Container(
      width: 76, // 더 큰 크기로 조정 (기존 60→76)
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getEmotionGradient(emotionTheme),
        boxShadow: [
          BoxShadow(
            color: _getEmotionColor(emotionTheme)
                .withValues(alpha: 0.4), // 더 진한 그림자
            blurRadius: 16, // 더 큰 블러 효과 (12→16)
            offset: const Offset(0, 6), // 더 깊은 그림자 (4→6)
          ),
          BoxShadow(
            color: _getEmotionColor(emotionTheme).withValues(alpha: 0.2),
            blurRadius: 24, // 추가 외부 그림자로 입체감 증가
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
                width: 90, // 셰르피 이미지만 90x90 유지
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.face,
                    size: 40, // 폴백 아이콘 크기도 증가
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),

          // 메시지 알림 배지 (새로운 메시지가 있을 때만 표시)
          if (state.isVisible && state.dialogue.isNotEmpty)
            Positioned(
              top: 4, // 더 여유로운 위치
              right: 4,
              child: Container(
                width: 20, // 더 큰 배지 (16→20)
                height: 20,
                decoration: BoxDecoration(
                  color: ModernColors.error, // 앱 색상 시스템 사용
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.error.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_active, // 더 명확한 알림 아이콘
                  size: 12, // 아이콘 크기 증가 (8→12)
                  color: Colors.white,
                ),
              ),
            ),

          // 친밀도 레벨 배지
          Consumer(
            builder: (context, ref, child) {
              final relationship = ref.watch(relationshipProvider);
              return Positioned(
                bottom: 4, // 더 여유로운 위치
                right: 4,
                child: Container(
                  width: 22, // 더 큰 친밀도 배지 (18→22)
                  height: 22,
                  decoration: BoxDecoration(
                    color: _getIntimacyLevelColor(relationship.intimacyLevel),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color:
                            _getIntimacyLevelColor(relationship.intimacyLevel)
                                .withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${relationship.intimacyLevel}',
                      style: const TextStyle(
                        fontSize: 11, // 텍스트 크기 증가 (9→11)
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
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
              ),
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
        return ModernColors.primary;
    }
  }
}

/// 🎭 확장 대화 다이얼로그
class SherpiExpandedDialog extends ConsumerStatefulWidget {
  const SherpiExpandedDialog({super.key});

  @override
  ConsumerState<SherpiExpandedDialog> createState() =>
      _SherpiExpandedDialogState();
}

class _SherpiExpandedDialogState extends ConsumerState<SherpiExpandedDialog>
    with TickerProviderStateMixin {
  final int _currentTabIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sherpiState = ref.watch(sherpiProvider);
    final currentEmotion = sherpiState.emotion;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primary.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더 섹션
                  Container(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ModernColors.primary.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 셰르피 아바타 with glassmorphism
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.9),
                                Colors.white.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    ModernColors.primary.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: ClipOval(
                              child: Image.asset(
                                currentEmotion.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '셰르피와 함께해요!',
                                style: GoogleFonts.notoSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: ModernColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getEmotionDescription(currentEmotion),
                                style: GoogleFonts.notoSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ModernColors.textSecondary
                                      .withValues(alpha: 0.8),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              const CompactIntimacyWidget(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 컨텐츠 영역
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                    child: Column(
                      children: [
                        // 현재 메시지 표시 - 다이얼로그에서는 실시간 메시지 표시
                        if (sherpiState.dialogue.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.7),
                                  Colors.white.withValues(alpha: 0.5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      ModernColors.primary.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          size: 20,
                                          color: ModernColors.primary
                                              .withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '셰르피의 메시지',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: ModernColors.primary
                                                .withValues(alpha: 0.8),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // 설정 버튼 (셰르피 개인화)
                                        _buildSettingsButton(context),
                                        const SizedBox(width: 8),
                                        // 전체보기 버튼
                                        _buildViewAllButton(context),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  sherpiState.dialogue,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: ModernColors.textPrimary
                                        .withValues(alpha: 0.9),
                                    height: 1.6,
                                    letterSpacing: -0.2,
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          // 메시지가 없을 때 기본 환영 메시지
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.7),
                                  Colors.white.withValues(alpha: 0.5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '안녕하세요! 언제든지 도움이 필요하면 말씀해 주세요. 함께 목표를 달성해 나가요! 💪',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: ModernColors.textPrimary
                                    .withValues(alpha: 0.9),
                                height: 1.6,
                                letterSpacing: -0.2,
                              ),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 액션 버튼들 - Modern card design with staggered animations
                        // 오늘의 분석 버튼 (새로 추가 - 첫 번째)
                        _buildModernActionButton(
                          context,
                          icon: Icons.analytics_outlined,
                          title: '오늘의 분석',
                          subtitle: '하루를 돌아보며 성장하기',
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade400,
                              Colors.indigo.shade600
                            ],
                          ),
                          onTap: () => _showTodayAnalysis(context),
                          index: 0,
                        ),
                        const SizedBox(height: 12),
                        _buildModernActionButton(
                          context,
                          icon: Icons.chat_bubble_outline,
                          title: '자세한 대화하기',
                          subtitle: '셰르피와 깊이 있는 대화',
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600
                            ],
                          ),
                          onTap: () => _openChatScreen(context),
                          index: 1,
                        ),
                        const SizedBox(height: 12),
                        _buildModernActionButton(
                          context,
                          icon: Icons.insights_outlined,
                          title: '분석하기',
                          subtitle: '나의 패턴을 분석',
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.purple.shade600
                            ],
                          ),
                          onTap: () => _showPatternAnalysis(context),
                          index: 2,
                        ),
                        const SizedBox(height: 12),
                        _buildModernActionButton(
                          context,
                          icon: Icons.event_note_outlined,
                          title: '계획하기',
                          subtitle: '목표 달성을 위한 계획',
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade400,
                              Colors.orange.shade600
                            ],
                          ),
                          onTap: () => _showPlanningMode(context),
                          index: 3,
                        ),
                        const SizedBox(height: 12),
                        _buildModernActionButton(
                          context,
                          icon: Icons.favorite_outline,
                          title: '격려 받기',
                          subtitle: '응원 메시지',
                          gradient: LinearGradient(
                            colors: [
                              Colors.pink.shade400,
                              Colors.pink.shade600
                            ],
                          ),
                          onTap: () => _showEncouragement(context),
                          index: 4,
                        ),
                        const SizedBox(height: 24),

                        // Phase 2: 관계 성장 시각화 위젯
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          child: const SherpiRelationshipGrowthWidget(
                              showFullStats: false),
                        ),
                        const SizedBox(height: 24),

                        // 닫기 버튼 - Modern style
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade300,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.of(context).pop(),
                              child: Center(
                                child: Text(
                                  '닫기',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.98, 0.98),
          curve: Curves.easeOut,
          duration: 200.ms,
        )
        .fade(
          curve: Curves.easeOut,
          duration: 150.ms,
        );
  }

  /// 모던 액션 버튼 위젯 구성 - Glassmorphism style
  Widget _buildModernActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    int index = 0, // For staggered animations
  }) {
    return MicroInteractions.tapResponse(
      onTap: onTap,
      scaleDownTo: 0.97,
      duration: MicroInteractions.fast,
      enableHaptic: true,
      child: Container(
        width: double.infinity,
        height: 88,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.first.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color:
                                ModernColors.textSecondary.withValues(alpha: 0.8),
                            height: 1.3,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: gradient.colors.first.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: gradient.colors.first,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(
              delay: (150 + (index * 100)).ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic)
          .slideX(
              begin: 0.05,
              end: 0,
              delay: (100 + (index * 80)).ms,
              curve: MicroInteractions.easeOutQuart)
          .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.0, 1.0),
              delay: (100 + (index * 80)).ms),
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
  void _openChatScreen(BuildContext context) {
    Navigator.of(context).pop();

    // 지연 없이 즉시 화면 전환
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SherpiChatScreen(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// 패턴 분석 표시
  void _showPatternAnalysis(BuildContext context) async {
    // ✅ ref 사용을 Widget dispose 전에 미리 실행
    late final GlobalUser globalUser;
    try {
      globalUser = ref.read(globalUserProvider);
    } catch (e) {
      // 사용자 데이터 로드 실패
      Navigator.of(context).pop(); // 에러 시에만 다이얼로그 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사용자 데이터를 불러올 수 없습니다: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    // 먼저 다이얼로그를 닫고 새 context를 얻기 위해 약간의 딜레이 추가
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 100));

    // 진행상황을 추적할 ValueNotifier 생성
    final progressNotifier = ValueNotifier<double>(0.0);
    final statusNotifier = ValueNotifier<String>('분석 준비 중...');

    // BuildContext를 저장하기 위해 Navigator의 context를 사용
    final navigatorContext = Navigator.of(context).context;

    // 프로그레스 다이얼로그 표시
    showDialog(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 셰르피 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.primary,
                      ModernColors.primary.withValues(alpha: 0.7)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                '데이터 분석 중',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),

              // 상태 텍스트
              ValueListenableBuilder<String>(
                valueListenable: statusNotifier,
                builder: (context, status, child) {
                  return Text(
                    status,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 20),

              // 프로그레스 바
              ValueListenableBuilder<double>(
                valueListenable: progressNotifier,
                builder: (context, progress, child) {
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            const AlwaysStoppedAnimation(ModernColors.primary),
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // 1단계: 데이터 검증 (20%)
      statusNotifier.value = '사용자 데이터 검증 중...';
      progressNotifier.value = 0.2;
      await Future.delayed(const Duration(milliseconds: 300));

      // 데이터 검증 (이미 로드된 globalUser 사용)
      if (globalUser.dailyRecords.exerciseLogs.isEmpty &&
          globalUser.dailyRecords.readingLogs.isEmpty &&
          globalUser.dailyRecords.diaryLogs.isEmpty) {
        // 경고: 활동 데이터가 없습니다
      }

      // mounted 상태 확인
      if (!navigatorContext.mounted) {
        // Widget이 dispose되어 분석 중단
        return;
      }

      // 2단계: 활동 패턴 분석 (40%)
      statusNotifier.value = '활동 패턴 분석 중...';
      progressNotifier.value = 0.4;
      await Future.delayed(const Duration(milliseconds: 400));

      if (!navigatorContext.mounted) {
        // Widget이 dispose되어 분석 중단
        return;
      }

      // 3단계: 기분 분석 (60%)
      statusNotifier.value = '기분 패턴 분석 중...';
      progressNotifier.value = 0.6;
      await Future.delayed(const Duration(milliseconds: 300));

      if (!navigatorContext.mounted) {
        // Widget이 dispose되어 분석 중단
        return;
      }

      // 4단계: 성과 지표 계산 (80%)
      statusNotifier.value = '성과 지표 계산 중...';
      progressNotifier.value = 0.8;
      await Future.delayed(const Duration(milliseconds: 400));

      if (!navigatorContext.mounted) {
        // Widget이 dispose되어 분석 중단
        return;
      }

      // 실제 기본 분석 수행
      final baseAnalysisResult = UserDataAnalyzer.analyzeUserData(globalUser);

      if (!navigatorContext.mounted) {
        // Widget이 dispose되어 분석 중단
        return;
      }

      // 5단계: 기본 인사이트 완성 (95%) - AI 기능 임시 비활성화
      statusNotifier.value = '인사이트 완성 중...';
      progressNotifier.value = 0.95;
      await Future.delayed(const Duration(milliseconds: 400));

      if (!navigatorContext.mounted) {
        // Widget이 dispose되어 분석 중단
        return;
      }

      // AI 기능을 임시로 비활성화하고 기본 분석 결과만 사용
      AnalysisResult finalAnalysisResult = baseAnalysisResult;

      // 6단계: 완료 (100%) with success animation
      statusNotifier.value = '🎉 분석 완료! ✨';
      progressNotifier.value = 1.0;
      await Future.delayed(
          const Duration(milliseconds: 800)); // Extra time for success feeling

      if (!navigatorContext.mounted) {
        // Widget이 dispose되어 화면 전환 건너뛰기
        return;
      }

      // 로딩 다이얼로그 닫기
      if (navigatorContext.mounted) {
        Navigator.of(navigatorContext).pop();

        // 분석 결과 화면으로 이동 with enhanced animation
        Navigator.of(navigatorContext).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AnalysisResultScreen(analysisResult: finalAnalysisResult),
            transitionDuration: const Duration(
                milliseconds: 400), // Slightly longer for smoother feel
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05), // Subtle slide
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: MicroInteractions.easeOutQuart, // Custom easing
                  )),
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.98,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: MicroInteractions.easeOutBack,
                    )),
                    child: child,
                  ),
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      // 오류 발생 시 로딩 다이얼로그 닫기
      if (navigatorContext.mounted) {
        Navigator.of(navigatorContext).pop();

        // 오류 메시지 표시
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          SnackBar(
            content: Text('데이터 분석 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: '다시 시도',
              textColor: Colors.white,
              onPressed: () => _showPatternAnalysis(context),
            ),
          ),
        );
      }
    }
  }

  /// 계획 모드 표시 - 즉시 입력 화면으로 이동
  void _showPlanningMode(BuildContext context) async {
    // 다이얼로그 닫기
    Navigator.of(context).pop();

    // 즉시 계획 입력 화면으로 이동 (로딩 없음)
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SimplePlannerScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: MicroInteractions.easeOutQuart,
              )),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.98,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: MicroInteractions.easeOutBack,
                )),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 격려 메시지 표시
  void _showEncouragement(BuildContext context) {
    Navigator.of(context).pop();

    // 격려 메시지 표시 (다이얼로그 버튼은 항상 새 메시지 생성)
    ref.read(sherpiProvider.notifier).showMessage(
          context: SherpiContext.encouragement,
          duration: const Duration(seconds: 5),
          forceShow: true, // 다이얼로그 액션 버튼은 항상 표시
        );
  }

  /// 오늘의 분석 화면 표시
  void _showTodayAnalysis(BuildContext context) {
    Navigator.of(context).pop();

    // 오늘의 분석 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => const EnhancedTodayAnalysisDialog(),
    );
  }

  /// 개인화 설정 화면 표시 - 오버레이 방식으로 기존 다이얼로그 위에 표시
  void _showPersonalizationSettings(BuildContext context) {
    // 기존 다이얼로그는 닫지 않고 그 위에 설정창을 오버레이로 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3), // 더 어둡게 하여 계층 구분
      builder: (context) => const SherpiPersonalizationDialog(),
    );
  }

  /// 메시지 히스토리 화면 표시
  void _showMessageHistory(BuildContext context) {
    Navigator.of(context).pop(); // 다이얼로그 닫기
    Navigator.pushNamed(context, '/sherpi_message_history');
  }

  /// ⚙️ 셰르피 설정 버튼 (메시지 카드 내)
  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 1,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showPersonalizationSettings(context),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings,
              size: 16,
              color: ModernColors.primary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }

  /// 💎 깔끔하고 모던한 전체보기 버튼 - 다이얼로그 분위기에 맞춤
  Widget _buildViewAllButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 1,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showMessageHistory(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 16,
                  color: ModernColors.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  '전체보기',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.primary.withValues(alpha: 0.9),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
