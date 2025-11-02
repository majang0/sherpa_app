import 'package:flutter/material.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/providers/global_game_provider.dart';
import '../../../../shared/providers/global_badge_provider.dart';
import '../../../../shared/models/global_badge_model.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/constants/mountain_data.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../core/constants/sherpi_emotions.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/models/mountain.dart';

class AscentDashboardWidget extends ConsumerStatefulWidget {
  const AscentDashboardWidget({super.key});

  @override
  ConsumerState<AscentDashboardWidget> createState() =>
      _AscentDashboardWidgetState();
}

class _AscentDashboardWidgetState extends ConsumerState<AscentDashboardWidget>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러들
  late AnimationController _basecampController;
  late AnimationController _climbingProgressController;
  late AnimationController _sherpiFloatController;
  late AnimationController _successAnimationController;
  late AnimationController _cardHoverController;
  late AnimationController _rewardAnimationController;

  // 애니메이션
  late Animation<double> _basecampFadeIn;
  late Animation<double> _sherpiFloat;
  late Animation<double> _rewardScale;
  late Animation<double> _rewardOpacity;
  late Animation<Offset> _rewardSlide;

  // 타이머
  Timer? _progressTimer;
  Timer? _autoClimbTimer;
  Timer? _sherpiMessageTimer;

  static const bool _debugMode = true;

  // 상태 변수
  bool _isAutoClimbEnabled = false;
  double _currentProgress = 0.0;
  bool _showSuccessAnimation = false;
  ClimbingRewards? _lastRewards;
  bool? _lastClimbSuccess;
  String _selectedMountainId = '';
  bool _showSherpiMessage = false;
  int _sherpiMessageIndex = 0;
  Mountain? _lastClimbedMountain; // 🔧 추가: 마지막 등반한 산 저장

  // 셰르피 메시지 배열
  final List<String> _sherpiMessages = [
    '화이팅! 조금씩 올라가요! 🏔️',
    '잘하고 있어요! 계속 올라가요! 💪',
    '멋진 페이스예요! 포기하지 마세요! ⭐',
    '거의 다 왔어요! 정상이 가까워요! 🎯',
    '당신은 할 수 있어요! 최선을 다해요! 🔥',
    '훌륭해요! 이 속도면 금방이에요! ✨',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAndResumeClimbing();
  }

  void _initializeAnimations() {
    _basecampController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _basecampFadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _basecampController,
      curve: Curves.easeOut,
    ));

    _climbingProgressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sherpiFloatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _sherpiFloat = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _sherpiFloatController,
      curve: Curves.easeInOut,
    ));

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rewardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rewardScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rewardAnimationController,
      curve: Curves.easeOutBack,
    ));

    _rewardOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rewardAnimationController,
      curve: const Interval(0.0, 0.5),
    ));

    _rewardSlide = Tween<Offset>(
      begin: const Offset(0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _rewardAnimationController,
      curve: Curves.easeOut,
    ));

    _cardHoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _basecampController.dispose();
    _climbingProgressController.dispose();
    _sherpiFloatController.dispose();
    _successAnimationController.dispose();
    _cardHoverController.dispose();
    _rewardAnimationController.dispose();
    _progressTimer?.cancel();
    _autoClimbTimer?.cancel();
    _sherpiMessageTimer?.cancel();
    super.dispose();
  }

  void _checkAndResumeClimbing() {
    final session = ref.read(globalUserProvider).currentClimbingSession;
    if (session?.isActive == true) {
      _startProgressTracking();
      _startSherpiMessages();
    }
  }

  void _startProgressTracking() {
    _progressTimer?.cancel();
    _currentProgress = 0.0;

    final session = ref.read(globalUserProvider).currentClimbingSession;
    if (session == null) return;

    final startTime = session.startTime;
    final durationMs = (session.durationHours * 3600 * 1000).round();

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final currentSession =
          ref.read(globalUserProvider).currentClimbingSession;
      if (currentSession == null || !currentSession.isActive) {
        timer.cancel();
        setState(() => _currentProgress = 0.0);
        return;
      }

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final progress = (elapsed / durationMs).clamp(0.0, 1.0);

      setState(() {
        _currentProgress = progress;
      });

      // 완료 체크
      if (progress >= 1.0) {
        timer.cancel();
        _handleClimbingComplete();
      }
    });
  }

  // 🔧 수정: 셰르피 메시지 타이머 시작
  void _startSherpiMessages() {
    setState(() {
      _showSherpiMessage = true;
      _sherpiMessageIndex = 0;
    });

    _sherpiMessageTimer?.cancel();
    _sherpiMessageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final session = ref.read(globalUserProvider).currentClimbingSession;
      if (session == null || !session.isActive) {
        timer.cancel();
        setState(() => _showSherpiMessage = false);
        return;
      }

      setState(() {
        _sherpiMessageIndex =
            (_sherpiMessageIndex + 1) % _sherpiMessages.length;
      });
    });
  }

  void _handleClimbingComplete() {
    final session = ref.read(globalUserProvider).currentClimbingSession;
    if (session == null) return;

    // 완료 전 세션 정보 저장
    // final mountainId = session.mountainId; // Not used currently
    // final difficulty = session.metadata?['difficulty'] ?? 1; // Not used currently

    // completeClimbing 호출
    ref.read(globalUserProvider.notifier).completeClimbing();

    // 보상 지급 확인 및 표시
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      final records = ref.read(globalUserProvider).dailyRecords.climbingLogs;
      if (records.isNotEmpty) {
        final lastRecord = records.last;

        // 디버그 로그 추가
        LoggerService.instance.d('🎯 등반 완료 - 산: ${lastRecord.mountainName}');
        LoggerService.instance.i('✅ 성공 여부: ${lastRecord.isSuccess}');
        LoggerService.instance.d(
            '🎁 보상 - XP: ${lastRecord.rewards.experience}, Points: ${lastRecord.rewards.points}');

        // 보상이 없는 경우 경고
        if (!lastRecord.rewards.hasRewards) {
          LoggerService.instance.w('⚠️ 경고: 보상이 계산되지 않았습니다!');
        }

        _showCompletionAnimation(lastRecord.isSuccess);
      }
    });

    // 셰르피 메시지 중지
    _sherpiMessageTimer?.cancel();
    setState(() => _showSherpiMessage = false);

    // 자동 등반 처리
    if (_isAutoClimbEnabled) {
      _scheduleNextClimb();
    }
  }

  void _showCompletionAnimation(bool isSuccess) {
    // 마지막 등반 기록에서 실제 보상 가져오기
    final records = ref.read(globalUserProvider).dailyRecords.climbingLogs;
    if (records.isNotEmpty) {
      final lastRecord = records.last;
      setState(() {
        _lastRewards = lastRecord.rewards;
        _lastClimbSuccess = lastRecord.isSuccess;
        _showSuccessAnimation = true;
      });
    }

    _rewardAnimationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessAnimation = false;
          _lastRewards = null;
          _lastClimbSuccess = null;
        });
        _rewardAnimationController.reset();
      }
    });

    // 햅틱 피드백
    if (isSuccess) {
      HapticFeedbackManager.heavyImpact();
    } else {
      HapticFeedbackManager.lightImpact();
    }
  }

  // 🔧 수정: 마지막 등반한 산으로 자동 등반 진행
  void _scheduleNextClimb() {
    _autoClimbTimer?.cancel();
    _autoClimbTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      final user = ref.read(globalUserProvider);
      if (user.currentClimbingSession?.isActive == true) return;

      // 마지막 등반한 산이 있으면 그 산으로, 없으면 추천 산 중 첫 번째로
      if (_lastClimbedMountain != null) {
        _startClimbing(_lastClimbedMountain!);
      } else {
        final userPower = ref.read(userClimbingPowerProvider);
        final mountains =
            MountainData.getRecommendedMountainsByPower(userPower);
        if (mountains.isNotEmpty) {
          _startClimbing(mountains.first);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final globalUser = ref.watch(globalUserProvider);
    final session = globalUser.currentClimbingSession;
    final isClimbing = session?.isActive == true;

    return FadeTransition(
      opacity: _basecampFadeIn,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 베이스캠프 타이틀
                _buildBasecampHeader(globalUser),
                const SizedBox(height: 24),

                // 메인 콘텐츠: 상태에 따라 다른 UI
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: isClimbing
                      ? _buildClimbingMonitor(session!)
                      : _buildExpeditionPlanning(),
                ),

                const SizedBox(height: 20),

                // 자동 등반 토글
                _buildAutoClimbControl(),

                const SizedBox(height: 24),

                // 등반 기록
                _buildClimbingRecords(globalUser),
              ],
            ),
          ),

          // 보상 애니메이션 오버레이 (상단에 표시)
          if (_showSuccessAnimation && _lastRewards != null)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: _buildRewardAnimation(
                  _lastRewards!, _lastClimbSuccess ?? false),
            ),
        ],
      ),
    );
  }

  Widget _buildBasecampHeader(GlobalUser user) {
    final titleData = ref.watch(globalUserTitleProvider);
    final userPower = ref.watch(userClimbingPowerProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.primary.withValues(alpha: 0.1),
            ModernColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 베이스캠프 아이콘
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: ModernColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text('🏕️', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),

          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name}의 베이스캠프',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatChip('Lv.${user.level}', ModernColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      titleData.title,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 등반력 표시
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on,
                      color: ModernColors.primary, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${userPower.toInt()}',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: ModernColors.primary,
                    ),
                  ),
                ],
              ),
              Text(
                '등반력',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: ModernColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpeditionPlanning() {
    final userPower = ref.watch(userClimbingPowerProvider);
    final mountains = MountainData.getRecommendedMountainsByPower(userPower);
    final user = ref.watch(globalUserProvider);
    final badges = ref.watch(globalEquippedBadgesProvider);

    return Column(
      key: const ValueKey('expedition'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 타이틀
        Row(
          children: [
            const Icon(Icons.map, color: ModernColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              '등반 계획', // 🔧 수정: 원정 -> 등반
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '추천 등반지 ${mountains.length}개', // 🔧 수정: 원정지 -> 등반지
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 산 카드 리스트 (오버플로우 방지)
        SizedBox(
          height: 310, // 🔧 수정: 높이를 다시 280으로 축소
          child: mountains.isEmpty
              ? Center(
                  child: Text(
                    '추천 등반지가 없습니다', // 🔧 수정: 원정지 -> 등반지
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: mountains.length,
                  padding: const EdgeInsets.only(right: 4),
                  itemBuilder: (context, index) {
                    final mountain = mountains[index];
                    return _buildMountainCard(
                        mountain, userPower, user, badges);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMountainCard(Mountain mountain, double userPower,
      GlobalUser user, List<GlobalBadge> badges) {
    final successProb = GameConstants.calculateSuccessProbability(
      userPower: userPower,
      mountainPower: mountain.requiredPower,
      willpower: user.stats.willpower,
      equippedBadges: badges,
    );

    final canClimb = userPower >= mountain.requiredPower * 0.5;
    final isSelected = _selectedMountainId == mountain.id.toString();
    final difficultyColor = _getDifficultyColor(mountain.difficultyLevel);

    // 🔧 추가: 사교성에 따른 시간 단축 계산
    final originalTime = mountain.durationHours;
    final adjustedTime = GameConstants.calculateAdjustedClimbingTime(
      originalTime,
      user.stats.sociality,
    );
    final timeReduction = originalTime > adjustedTime;
    final reductionPercent = timeReduction
        ? ((originalTime - adjustedTime) / originalTime * 100).round()
        : 0;

    return MouseRegion(
      onEnter: (_) =>
          setState(() => _selectedMountainId = mountain.id.toString()),
      onExit: (_) => setState(() => _selectedMountainId = ''),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        transform: Matrix4.identity()..translate(0.0, isSelected ? -8.0 : 0.0),
        child: GestureDetector(
          onTap: canClimb ? () => _startClimbing(mountain) : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      difficultyColor.withValues(alpha: isSelected ? 0.4 : 0.2),
                  blurRadius: isSelected ? 20 : 12,
                  offset: Offset(0, isSelected ? 8 : 4),
                ),
              ],
              border: Border.all(
                color: difficultyColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 산 이미지 영역
                Container(
                  height: 70, // 🔧 수정: 80에서 70으로 더 축소
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        difficultyColor.withValues(alpha: 0.3),
                        difficultyColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          '🏔️',
                          style: TextStyle(fontSize: 36), // 🔧 수정: 40에서 36으로 축소
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lv.${mountain.difficultyLevel}',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 콘텐츠
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 산 이름과 지역
                        Text(
                          mountain.name,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          mountain.region,
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 전투력과 성공률
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPowerComparison(
                                userPower, mountain.requiredPower),
                            _buildCompactSuccessRate(successProb),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // 🔧 수정: 시간 표시 개선
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer,
                                    size: 12, color: ModernColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDuration(originalTime),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 11,
                                    color: timeReduction
                                        ? ModernColors.inactive
                                        : ModernColors.textSecondary,
                                    decoration: timeReduction
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (timeReduction) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '→ ${_formatDuration(adjustedTime)}',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: ModernColors.success,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (timeReduction)
                              Text(
                                '사교성 효과 -$reductionPercent%',
                                style: GoogleFonts.notoSans(
                                  fontSize: 9,
                                  color: ModernColors.success,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),

                        // 🔧 수정: 보상 정보를 하단에 조화롭게 배치
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: ModernColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMiniReward(
                                  '✨',
                                  GameConstants.calculateDisplayXp(
                                    mountain.difficultyLevel,
                                    mountain.durationHours,
                                    playerLevel: user.level,
                                  ).toInt()),
                              const SizedBox(width: 16),
                              _buildMiniReward(
                                  '💰',
                                  GameConstants.calculateDisplayPoints(
                                    mountain.difficultyLevel,
                                    mountain.durationHours,
                                    playerLevel: user.level,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 액션 버튼
                Container(
                  margin: const EdgeInsets.all(12),
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: canClimb ? ModernColors.primaryGradient : null,
                    color: canClimb ? null : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: canClimb ? () => _startClimbing(mountain) : null,
                      child: Center(
                        child: Text(
                          canClimb ? '등반 시작' : '등반력 부족', // 🔧 수정: 원정 -> 등반
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                canClimb ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔧 추가: 시간 포맷팅 함수
  String _formatDuration(double hours) {
    if (hours < 1) {
      return '${(hours * 60).toInt()}분';
    } else if (hours % 1 == 0) {
      return '${hours.toInt()}시간';
    } else {
      final h = hours.floor();
      final m = ((hours - h) * 60).round();
      return '$h시간 $m분';
    }
  }

  // 🔧 추가: 미니 보상 위젯
  Widget _buildMiniReward(String emoji, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // 🔧 추가: 컴팩트한 성공률 표시
  Widget _buildCompactSuccessRate(double probability) {
    final color = _getSuccessColor(probability);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${(probability * 100).toInt()}%',
        style: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildClimbingMonitor(ClimbingSession session) {
    final mountain =
        ref.watch(globalGameProvider).getMountainById(session.mountainId);
    if (mountain == null) return const SizedBox();

    return Container(
      key: const ValueKey('climbing'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.primary.withValues(alpha: 0.9),
            ModernColors.primaryHover.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상태 표시
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '등반 진행중', // 🔧 수정: 원정 -> 등반
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _cancelClimbing,
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 산 정보
          Row(
            children: [
              const Text(
                '🏔️',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mountain.name,
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${mountain.region} • Lv.${mountain.difficultyLevel}',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 진행 상황 시각화
          _buildClimbingProgress(),
          const SizedBox(height: 24),

          // 등반 중 셰르피 격려 메시지
          if (_showSherpiMessage) _buildSherpiEncouragement(),
          const SizedBox(height: 20),

          // 실시간 상태
          _buildRealtimeStats(session),
        ],
      ),
    );
  }

  Widget _buildClimbingProgress() {
    return Column(
      children: [
        // 산 실루엣과 캐릭터
        SizedBox(
          height: 120,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 산 실루엣
              CustomPaint(
                size: const Size(double.infinity, 120),
                painter: MountainSilhouettePainter(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              // 등반 경로
              Positioned.fill(
                child: CustomPaint(
                  painter: ClimbingPathPainter(
                    progress: _currentProgress,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
              // 캐릭터 (산 정상에서 내려오기)
              Positioned(
                left: _calculateCharacterX(),
                bottom: _calculateCharacterY(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text('🧗', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 진행률 바
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _currentProgress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(_currentProgress * 100).toInt()}% 완료',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // 캐릭터 X 좌표 계산
  double _calculateCharacterX() {
    final screenWidth = MediaQuery.of(context).size.width - 80; // 패딩 제외
    return screenWidth * 0.1 + (screenWidth * 0.8 * _currentProgress);
  }

  // 캐릭터 Y 좌표 계산 (올라갔다가 내려오기)
  double _calculateCharacterY() {
    if (_currentProgress <= 0.5) {
      // 0~50%: 올라가기
      return 20 + (60 * (_currentProgress * 2));
    } else {
      // 50~100%: 내려오기
      return 80 - (60 * ((_currentProgress - 0.5) * 2));
    }
  }

  // 🔧 수정: 셰르피 격려 위젯 개선
  Widget _buildSherpiEncouragement() {
    return AnimatedBuilder(
      animation: _sherpiFloat,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _sherpiFloat.value),
          child: Row(
            children: [
              // 셰르피 이미지
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Transform.scale(
                    scale: 1.4,
                    child: Image.asset(
                      SherpiEmotion.thinking.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('🎯', style: TextStyle(fontSize: 28)),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 격려 메시지
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _sherpiMessages[_sherpiMessageIndex],
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealtimeStats(ClimbingSession session) {
    final remainingSeconds = session.remainingTime.inSeconds;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.timer,
          label: '남은 시간',
          value: '$minutes:${seconds.toString().padLeft(2, '0')}',
          color: Colors.white,
        ),
        Container(width: 1, height: 40, color: Colors.white24),
        _buildStatItem(
          icon: Icons.trending_up,
          label: '성공 확률',
          value: '${(session.successProbability * 100).toInt()}%',
          color: _getSuccessColor(session.successProbability),
        ),
      ],
    );
  }

  Widget _buildAutoClimbControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ModernColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.loop,
              color: ModernColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '자동 연속 등반', // 🔧 수정: 원정 -> 등반
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                Text(
                  '등반 완료 후 자동으로 다음 등반 시작', // 🔧 수정: 원정 -> 등반
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAutoClimbEnabled,
            onChanged: (value) {
              setState(() => _isAutoClimbEnabled = value);
              HapticFeedbackManager.lightImpact();
            },
            activeColor: ModernColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildClimbingRecords(GlobalUser user) {
    final records = user.dailyRecords.climbingLogs;
    if (records.isEmpty) return const SizedBox();

    final recentRecords = records.reversed.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: ModernColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              '최근 등반 기록', // 🔧 수정: 원정 -> 등반
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentRecords.map((record) => _buildRecordItem(record)),
      ],
    );
  }

  Widget _buildRecordItem(ClimbingRecord record) {
    final isSuccess = record.isSuccess;
    final statusColor = isSuccess ? ModernColors.success : ModernColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isSuccess ? Icons.flag : Icons.close,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.mountainName,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
                Text(
                  'Lv.${record.difficulty} • ${record.formattedDuration}',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (record.rewards.hasRewards) ...[
            if (record.rewards.experience > 0)
              _buildRewardChip(
                  '+${record.rewards.experience.toInt()} XP', ModernColors.quest),
            const SizedBox(width: 4),
            if (record.rewards.points > 0)
              _buildRewardChip('+${record.rewards.points} P', ModernColors.success),
          ],
        ],
      ),
    );
  }

  // 🔧 수정: 보상 애니메이션 위치 조정
  Widget _buildRewardAnimation(ClimbingRewards rewards, bool isSuccess) {
    return AnimatedBuilder(
      animation: _rewardAnimationController,
      builder: (context, child) {
        return SlideTransition(
          position: _rewardSlide,
          child: FadeTransition(
            opacity: _rewardOpacity,
            child: Transform.scale(
              scale: _rewardScale.value,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isSuccess ? ModernColors.success : ModernColors.error)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: (isSuccess ? ModernColors.success : ModernColors.error)
                          .withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSuccess ? '🎉 ' : '💪 ',
                            style: const TextStyle(fontSize: 24),
                          ),
                          Text(
                            isSuccess ? '등반 성공!' : '등반 실패', // 🔧 수정: 원정 -> 등반
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isSuccess
                                  ? ModernColors.success
                                  : ModernColors.error,
                            ),
                          ),
                        ],
                      ),
                      if (rewards.hasRewards) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (rewards.experience > 0) ...[
                              _buildInlineReward(
                                  '✨', '+${rewards.experience.toInt()} XP'),
                              if (rewards.points > 0) const SizedBox(width: 20),
                            ],
                            if (rewards.points > 0)
                              _buildInlineReward('💰', '+${rewards.points} P'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInlineReward(String emoji, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // 유틸리티 위젯들
  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPowerComparison(double userPower, double requiredPower) {
    final ratio = userPower / requiredPower;
    final color = ratio >= 1.0
        ? ModernColors.success
        : ratio >= 0.7
            ? ModernColors.warning
            : ModernColors.error;

    return Row(
      children: [
        Icon(Icons.flash_on, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '${userPower.toInt()} / ${requiredPower.toInt()}',
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // 유틸리티 메서드들
  Color _getDifficultyColor(int difficulty) {
    if (difficulty >= 100) return const Color(0xFFE91E63);
    if (difficulty >= 50) return const Color(0xFFFF5722);
    if (difficulty >= 20) return const Color(0xFFFFC107);
    if (difficulty >= 10) return const Color(0xFF4CAF50);
    return const Color(0xFF2196F3);
  }

  Color _getSuccessColor(double probability) {
    if (probability >= 0.7) return ModernColors.success;
    if (probability >= 0.5) return ModernColors.warning;
    return ModernColors.error;
  }

  void _startClimbing(Mountain mountain) {
    HapticFeedbackManager.mediumImpact();
    _lastClimbedMountain = mountain;

    // 디버그 모드에서는 시간 단축
    final adjustedDuration = _debugMode
        ? mountain.durationHours / 360 // 10초로 변환 (테스트용)
        : mountain.durationHours; // 실제 시간

    if (_debugMode) {
      LoggerService.instance.d('🏔️ 등반 시작 - ${mountain.name}');
      LoggerService.instance.d('📊 난이도: ${mountain.difficultyLevel}');
      LoggerService.instance.d(
          '⏱️ 원래 시간: ${mountain.durationHours}h → 테스트: ${(adjustedDuration * 3600).toInt()}초');
    }

    ref.read(globalUserProvider.notifier).startClimbing(
          mountainId: mountain.id,
          mountainName: mountain.name,
          region: mountain.region,
          difficulty: mountain.difficultyLevel,
          durationHours: adjustedDuration, // 테스트용 짧은 시간
          mountainPower: mountain.requiredPower,
          originalDuration: mountain.durationHours,
        );

    _startProgressTracking();
    _startSherpiMessages(); // 등반 중 격려 메시지는 유지
  }

  void _cancelClimbing() {
    HapticFeedbackManager.mediumImpact();
    ref.read(globalUserProvider.notifier).cancelClimbing();
    _progressTimer?.cancel();
    _sherpiMessageTimer?.cancel(); // 🔧 수정: 셰르피 타이머 취소
    setState(() {
      _currentProgress = 0.0;
      _showSherpiMessage = false;
    });
  }
}

// 커스텀 페인터들
class MountainSilhouettePainter extends CustomPainter {
  final Color color;

  MountainSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.35, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.65, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ClimbingPathPainter extends CustomPainter {
  final double progress;
  final Color color;

  ClimbingPathPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = size.width * 0.1;
    final startY = size.height - 20;
    final endX = size.width * 0.5;
    final endY = size.height * 0.2;

    path.moveTo(startX, startY);

    // 지그재그 경로 생성
    const steps = 5;
    for (int i = 1; i <= steps; i++) {
      final t = (i / steps) * progress;
      final x = startX + (endX - startX) * t;
      final y = startY - (startY - endY) * t;
      final offsetX = (i % 2 == 0) ? 20 : -20;

      if (t <= progress) {
        path.lineTo(x + offsetX, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
