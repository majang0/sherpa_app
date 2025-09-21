// lib/features/daily_record/presentation/screens/focus_timer_record_screen.dart

import 'package:flutter/material.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:flutter/services.dart'; // SystemChrome 추가
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart'; // 셰르피 컨텍스트 + 감정 포함
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart'; // 셰르피 Provider 추가
import '../../../../shared/providers/global_point_provider.dart'; // 포인트 Provider 추가

// 🎯 집중 유형 enum
enum FocusType {
  light('가벼운 집중', '30분', '짧고 집중적인 몰입', SherpiEmotion.happy),
  deep('깊은 집중', '60분', '깊이 있는 장시간 몰입', SherpiEmotion.thinking),
  challenge('도전 집중', '120분', '극한의 초집중 도전', SherpiEmotion.cheering);

  const FocusType(
      this.title, this.timeRange, this.description, this.sherpiEmotion);

  final String title;
  final String timeRange;
  final String description;
  final SherpiEmotion sherpiEmotion;
}

class FocusTimerRecordScreen extends ConsumerStatefulWidget {
  const FocusTimerRecordScreen({super.key});

  @override
  ConsumerState<FocusTimerRecordScreen> createState() =>
      _FocusTimerRecordScreenState();
}

class _FocusTimerRecordScreenState extends ConsumerState<FocusTimerRecordScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // 애니메이션 컨트롤러
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  // 타이머 관련
  Timer? _timer;
  Timer? _backgroundTimer;
  int _selectedMinutes = 30;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  // 🎮 게이미피케이션 시스템
  int _focusHP = 100; // HP 시스템
  int _exitAttempts = 0; // 이탈 시도 횟수
  bool _isInFocusMode = false; // 몰입 모드 상태
  int _backgroundSeconds = 0; // 백그라운드 시간

  // UI 관련
  bool _isExitDialogShowing = false;

  // 🎨 새로운 카드 기반 UI 상태
  FocusType? _selectedFocusType;
  bool _showTimeAdjustment = false;

  @override
  void initState() {
    super.initState();

    // 🎮 생명주기 옵저버 등록
    WidgetsBinding.instance.addObserver(this);

    // 애니메이션 컨트롤러 초기화
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _remainingSeconds = _selectedMinutes * 60;
  }

  @override
  void dispose() {
    // 🎮 정리 순서 중요
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _backgroundTimer?.cancel();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  // 🎮 앱 생명주기 변화 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!_isInFocusMode) return;

    switch (state) {
      case AppLifecycleState.paused:
        // 앱이 백그라운드로
        _onAppBackground();
        break;

      case AppLifecycleState.resumed:
        // 앱이 다시 활성화
        _onAppResumed();
        break;

      case AppLifecycleState.inactive:
        // 앱이 비활성 상태 (다이얼로그, 다른 앱 오버레이 등)
        _onAppInactive();
        break;

      default:
        break;
    }
  }

  void _onAppBackground() {
    if (!_isInFocusMode) return;

    _backgroundSeconds = 0;
    _backgroundTimer?.cancel();

    // 10초 카운트다운
    _backgroundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _backgroundSeconds++;

      if (_backgroundSeconds >= 10) {
        timer.cancel();
        // 몰입 실패 처리
        _handleFocusFailure();
      }
    });
  }

  void _onAppResumed() {
    _backgroundTimer?.cancel();

    if (_backgroundSeconds > 0 && _backgroundSeconds < 10) {
      // HP 감소 (백그라운드 전환 시 30 감소)
      setState(() {
        _focusHP = math.max(0, _focusHP - 30);
      });

      // HP가 0이 되면 실패 처리
      if (_focusHP <= 0) {
        _handleHPFailure('백그라운드 전환으로 인한 HP 소진');
        return;
      }

      // 셰르피 반응
      ref.read(sherpiProvider.notifier).showInstantMessage(
            context: SherpiContext.general,
            customDialogue: '다시 오셨네요! HP가 $_focusHP% 남았어요!',
            emotion:
                _focusHP > 50 ? SherpiEmotion.happy : SherpiEmotion.warning,
            duration: const Duration(seconds: 3),
          );
    }

    _backgroundSeconds = 0;
  }

  void _onAppInactive() {
    // iOS 특수 상태 처리 (전화 등)
    if (_isInFocusMode && !_isPaused) {
      setState(() {
        _isPaused = true;
      });
      _pulseController.stop();
    }
  }

  void _handleFocusFailure() {
    if (!mounted) return;

    // 타이머 정지
    _timer?.cancel();
    _backgroundTimer?.cancel();
    _pulseController.stop();
    _rippleController.stop();

    setState(() {
      _isRunning = false;
      _isInFocusMode = false;
      _focusHP = 0;
    });

    // 전체화면 모드 종료
    _exitImmersiveMode();

    // 실패 패널티 (10초 이탈은 20포인트)
    ref.read(globalPointProvider.notifier).spendPoints(
          20,
          '10초 이탈 실패 패널티',
        );

    // 실패 알림창 표시
    _showBackgroundFailureDialog();
  }

  // 🎮 HP 소진으로 인한 실패 처리
  void _handleHPFailure(String reason) {
    if (!mounted) return;

    // 타이머 정지
    _timer?.cancel();
    _backgroundTimer?.cancel();
    _pulseController.stop();
    _rippleController.stop();

    setState(() {
      _isRunning = false;
      _isInFocusMode = false;
      _focusHP = 0;
    });

    // 전체화면 모드 종료
    _exitImmersiveMode();

    // 실패 패널티
    ref.read(globalPointProvider.notifier).spendPoints(
          20,
          'HP 소진 패널티',
        );

    // 실패 알림창 표시
    _showHPFailureDialog(reason);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor:
            _isRunning ? const Color(0xFF1A1A2E) : const Color(0xFFF7F9FB),
        appBar: _isRunning
            ? null
            : SherpaCleanAppBar(
                title: '몰입 타이머',
                backgroundColor: Colors.white,
                foregroundColor: null,
              ),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          child:
              _isRunning ? _buildImmersiveRunningTimer() : _buildTimerSetup(),
        ),
      ),
    );
  }

  // 🎮 뒤로가기 처리
  Future<bool> _onWillPop() async {
    if (!_isInFocusMode) return true;

    _exitAttempts++;

    // HP 감소
    setState(() {
      _focusHP = math.max(0, _focusHP - 20);
    });

    // HP가 0이 되면 실패 처리
    if (_focusHP <= 0) {
      _handleHPFailure('뒤로가기 시도로 인한 HP 소진');
      return true;
    }

    // 셰르피 걱정 표현
    if (_exitAttempts == 1) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
            context: SherpiContext.tiredWarning,
            customDialogue: '벌써 포기하시려구요? 조금만 더 해봐요! 😢',
            emotion: SherpiEmotion.warning,
            duration: const Duration(seconds: 3),
          );
      return false;
    }

    // 3번째 시도 시 확인 다이얼로그
    if (_exitAttempts >= 3) {
      final shouldExit = await _showExitConfirmDialog();
      if (shouldExit) {
        _handleGiveUp();
      }
      return shouldExit;
    }

    return false;
  }

  Widget _buildTimerSetup() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            ModernColors.background,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSimpleHeader(),
            const SizedBox(height: 24),
            _buildFocusTypeCards(),
            const SizedBox(height: 20),
            _buildTimeAdjustment(),
            const SizedBox(height: 16),
            _buildSherpiEncouragement(),
            const SizedBox(height: 16),
            _buildWarningMessage(),
            const SizedBox(height: 20),
            _buildModernStartButton(),
          ],
        ),
      ),
    );
  }

  // 🎨 새로운 간단한 헤더
  Widget _buildSimpleHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.psychology_rounded,
            size: 28,
            color: ModernColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '몰입 스타일을 선택하세요',
          style: GoogleFonts.notoSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ModernColors.primary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '나에게 맞는 집중 방식으로 몰입해보세요',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: ModernColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  // 🎯 집중 유형 카드들
  Widget _buildFocusTypeCards() {
    return Column(
      children: FocusType.values
          .map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFocusTypeCard(type),
              ))
          .toList(),
    );
  }

  Widget _buildFocusTypeCard(FocusType type) {
    final isSelected = _selectedFocusType == type;

    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        setState(() {
          _selectedFocusType = type;
          _showTimeAdjustment = true;
          // 기본 시간 설정
          switch (type) {
            case FocusType.light:
              _selectedMinutes = 30;
              break;
            case FocusType.deep:
              _selectedMinutes = 60;
              break;
            case FocusType.challenge:
              _selectedMinutes = 120;
              break;
          }
          _remainingSeconds = _selectedMinutes * 60;
        });

        // 셰르피 반응
        ref.read(sherpiProvider.notifier).showInstantMessage(
              context: SherpiContext.general,
              customDialogue: '${type.title}을 선택하셨네요! 좋은 선택이에요!',
              emotion: type.sherpiEmotion,
              duration: const Duration(seconds: 2),
            );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAFBFC) : Colors.white,
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF0EA5E9).withOpacity(0.2),
                  width: 1.5,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF0EA5E9).withOpacity(0.15)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isSelected ? 20 : 8,
              offset: Offset(0, isSelected ? 6 : 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // 셰르피 감정 아이콘
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE0F2FE)
                    : const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Hero(
                tag: 'sherpi_${type.name}',
                child: Image.asset(
                  type.sherpiEmotion.imagePath,
                  width: 64, // 56 * 1.15 = 64.4
                  height: 64,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? ModernColors.primary
                          : ModernColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    type.timeRange,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? ModernColors.primary.withOpacity(0.9)
                          : ModernColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.description,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: ModernColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Container(
                      key: const ValueKey('selected'),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey('unselected'),
                      width: 24,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ⏱️ 시간 조정 위젯
  Widget _buildTimeAdjustment() {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              offset: const Offset(0, -2),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 20,
                      color: ModernColors.primary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '시간 설정',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_selectedMinutes}분',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildTimeAdjustButton('-', () {
                  if (_selectedMinutes > 5) {
                    setState(() {
                      _selectedMinutes -= 5;
                      _remainingSeconds = _selectedMinutes * 60;
                    });
                    HapticFeedbackManager.lightImpact();
                  }
                }),
                Expanded(
                  child: Slider(
                    value: _selectedMinutes.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23, // 5분 간격
                    activeColor: ModernColors.primary,
                    inactiveColor: ModernColors.primary.withOpacity(0.2),
                    onChanged: (value) {
                      setState(() {
                        _selectedMinutes = value.round();
                        // 5분 단위로 스냅
                        _selectedMinutes = ((_selectedMinutes / 5).round() * 5);
                        _remainingSeconds = _selectedMinutes * 60;
                      });
                    },
                  ),
                ),
                _buildTimeAdjustButton('+', () {
                  if (_selectedMinutes < 120) {
                    setState(() {
                      _selectedMinutes += 5;
                      _remainingSeconds = _selectedMinutes * 60;
                    });
                    HapticFeedbackManager.lightImpact();
                  }
                }),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFocusType != null
                  ? '추천: ${_selectedFocusType!.timeRange}'
                  : '원하는 시간을 설정하세요',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAdjustButton(String text, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ModernColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💬 셰르피 격려 메시지 (시간 기반)
  Widget _buildSherpiEncouragement() {
    // 시간에 따른 집중 유형 결정
    FocusType currentType;
    SherpiEmotion currentEmotion;
    List<String> messages;

    if (_selectedMinutes >= 5 && _selectedMinutes <= 45) {
      // 가벼운 집중 (5분~45분)
      currentType = FocusType.light;
      currentEmotion = SherpiEmotion.happy;
      messages = [
        '가벼운 몰입으로 시작해보세요! 🌱',
        '짧고 집중적인 시간이 될 거예요!',
        '완벽한 시작이에요! 화이팅! 💪'
      ];
    } else if (_selectedMinutes >= 50 && _selectedMinutes <= 90) {
      // 깊은 집중 (50분~90분)
      currentType = FocusType.deep;
      currentEmotion = SherpiEmotion.thinking;
      messages = [
        '깊은 집중의 시간이네요! 🌊',
        '진정한 몰입을 경험해보세요!',
        '깊이 있는 성장이 기다리고 있어요! ✨'
      ];
    } else {
      // 도전 집중 (95분~120분)
      currentType = FocusType.challenge;
      currentEmotion = SherpiEmotion.cheering;
      messages = [
        '와! 진정한 도전자시네요! 🔥',
        '극한의 집중력을 보여주세요!',
        '당신의 한계를 뛰어넘어보세요! 🚀'
      ];
    }

    final randomMessage =
        messages[DateTime.now().millisecond % messages.length];

    return AnimatedOpacity(
      opacity: 1.0, // 항상 표시
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              currentEmotion == SherpiEmotion.happy
                  ? const Color(0xFFE6F7FF).withOpacity(0.7)
                  : currentEmotion == SherpiEmotion.thinking
                      ? const Color(0xFFF0F4FF).withOpacity(0.7)
                      : const Color(0xFFFFF0E6).withOpacity(0.7),
              Colors.white.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: ModernColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Hero(
                tag: 'sherpi_encouragement',
                child: Image.asset(
                  currentEmotion.imagePath,
                  width: 84, // 73 * 1.15 = 83.95
                  height: 84,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                randomMessage,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⚠️ 포기 시 포인트 차감 경고 메시지
  Widget _buildWarningMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFDDEAFE),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF3B82F6),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '중도 포기 시 ',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  TextSpan(
                    text: '20포인트',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: const Color(0xFF3B82F6),
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  TextSpan(
                    text: '가 차감됩니다',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
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

  Widget _buildModernHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ModernColors.secondary.withOpacity(0.1),
                ModernColors.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.timer_outlined,
            size: 32,
            color: ModernColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '몰입 시간 설정',
          style: GoogleFonts.notoSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: ModernColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '목표 시간을 선택하세요',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularTimePicker() {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: ModernColors.primary.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 원형 시간 표시
          Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.secondary.withOpacity(0.1),
                      ModernColors.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: ModernColors.primary.withOpacity(0.1),
                    width: 2,
                  ),
                ),
              ),
              // 시간 표시
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _selectedMinutes.toString(),
                        style: GoogleFonts.notoSans(
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          color: ModernColors.primary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '분',
                        style: GoogleFonts.notoSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedMinutes >= 30
                          ? ModernColors.success.withOpacity(0.1)
                          : ModernColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedMinutes >= 30 ? '목표 달성 가능!' : '조금 더 도전해보세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedMinutes >= 30
                            ? ModernColors.success
                            : ModernColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              // 조절 버튼들
              Positioned(
                right: 0,
                child: _buildAdjustButton(
                  icon: Icons.add,
                  onTap: () {
                    setState(() {
                      _selectedMinutes = math.min(_selectedMinutes + 5, 180);
                      _remainingSeconds = _selectedMinutes * 60;
                    });
                    HapticFeedbackManager.lightImpact();
                  },
                ),
              ),
              Positioned(
                left: 0,
                child: _buildAdjustButton(
                  icon: Icons.remove,
                  onTap: () {
                    setState(() {
                      _selectedMinutes = math.max(_selectedMinutes - 5, 5);
                      _remainingSeconds = _selectedMinutes * 60;
                    });
                    HapticFeedbackManager.lightImpact();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 슬라이더
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: ModernColors.primary,
              inactiveTrackColor: ModernColors.primary.withOpacity(0.1),
              thumbColor: ModernColors.primary,
              overlayColor: ModernColors.primary.withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _selectedMinutes.toDouble(),
              min: 5,
              max: 180,
              divisions: 35,
              onChanged: (value) {
                setState(() {
                  _selectedMinutes = value.round();
                  _remainingSeconds = _selectedMinutes * 60;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ModernColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: ModernColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '빠른 선택',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final presetMinutes = [15, 30, 45, 60, 90, 120];
              final minutes = presetMinutes[index];
              final isSelected = _selectedMinutes == minutes;
              final isRecommended = minutes == 30;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMinutes = minutes;
                    _remainingSeconds = minutes * 60;
                  });
                  HapticFeedbackManager.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isRecommended ? 100 : 80,
                  decoration: BoxDecoration(
                    color: isSelected ? ModernColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? ModernColors.primary
                          : isRecommended
                              ? ModernColors.success.withOpacity(0.5)
                              : ModernColors.primary.withOpacity(0.15),
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? ModernColors.primary.withOpacity(0.25)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 15 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${minutes}분',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : ModernColors.textPrimary,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(height: 2),
                        Text(
                          '추천',
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : ModernColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.secondary.withOpacity(0.05),
            ModernColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tips_and_updates_outlined,
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
                  '오늘의 몰입 팁',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '타이머를 시작하기 전에 물 한 잔을 준비하고,\n편안한 자세를 잡아보세요.',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    height: 1.4,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStartButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            ModernColors.primary,
            ModernColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _startTimer,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '몰입 시작하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImmersiveRunningTimer() {
    final progress = 1.0 - (_remainingSeconds / (_selectedMinutes * 60));
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return GestureDetector(
      // 빈 공간 터치를 무시
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              Colors.black87,
            ],
          ),
        ),
        child: Stack(
          children: [
            // 배경 효과
            _buildParticleBackground(),

            // 메인 UI
            SafeArea(
              child: Column(
                children: [
                  // 포기 버튼
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildGiveUpButton(),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // 타이머
                  _buildCircularTimer(progress, minutes, seconds),

                  const SizedBox(height: 30),

                  // HP 바
                  _buildFocusHPBar(),

                  const SizedBox(height: 30),

                  // 시간 텍스트
                  Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: GoogleFonts.robotoMono(
                      fontSize: 52,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 상태 텍스트
                  Text(
                    _isPaused ? '일시정지됨' : _getMotivationalText(),
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // 컨트롤 버튼들
                  _buildSimpleControlButtons(),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            // 셰르피 (오른쪽 하단)
          ],
        ),
      ),
    );
  }

  // 심플한 컨트롤 버튼 (새로운 메서드)
  Widget _buildSimpleControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 일시정지/재개 버튼
        ElevatedButton(
          onPressed: () {
            LoggerService.instance.d('⏯️ 일시정지 버튼 클릭!');
            HapticFeedback.lightImpact();
            _togglePause();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPaused ? Colors.green : Colors.white24,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: Icon(
            _isPaused ? Icons.play_arrow : Icons.pause,
            size: 32,
          ),
        ),

        const SizedBox(width: 40),

        // 정지 버튼
        ElevatedButton(
          onPressed: () {
            LoggerService.instance.d('⏹️ 정지 버튼 클릭!');
            HapticFeedback.mediumImpact();
            _showStopConfirmDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.3),
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Icon(
            Icons.stop,
            size: 32,
          ),
        ),
      ],
    );
  }

  // 🎮 HP 바 위젯 (강화된 색상 시스템)
  Widget _buildFocusHPBar() {
    // HP 상태별 색상 및 아이콘
    Color hpColor;
    IconData hpIcon;
    String hpStatus;

    if (_focusHP > 60) {
      hpColor = const Color(0xFF10B981); // 초록색 (안전)
      hpIcon = Icons.favorite;
      hpStatus = '안전';
    } else if (_focusHP > 30) {
      hpColor = const Color(0xFFF59E0B); // 노란색 (주의)
      hpIcon = Icons.warning_amber;
      hpStatus = '주의';
    } else {
      hpColor = const Color(0xFFEF4444); // 빨간색 (위험)
      hpIcon = Icons.warning;
      hpStatus = '위험';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    hpIcon,
                    color: hpColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Focus HP',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hpColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: hpColor.withOpacity(0.5), width: 1),
                    ),
                    child: Text(
                      hpStatus,
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: hpColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '$_focusHP%',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: hpColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: _focusHP / 100, end: _focusHP / 100),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: hpColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(hpColor),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 동기부여 텍스트
  String _getMotivationalText() {
    final progress = 1.0 - (_remainingSeconds / (_selectedMinutes * 60));
    if (progress < 0.25) return '몰입 중... 집중하세요!';
    if (progress < 0.5) return '잘하고 있어요! 계속 해봐요!';
    if (progress < 0.75) return '절반 이상 왔어요! 훌륭해요!';
    return '거의 다 왔어요! 조금만 더!';
  }

  Widget _buildCircularTimer(double progress, int minutes, int seconds) {
    return IgnorePointer(
      // 터치 이벤트 무시
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  // 배경 원
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // 진행률 원
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ModernColors.primary,
                      ),
                    ),
                  ),
                  // 중앙 아이콘
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Icon(
                        _isPaused ? Icons.pause : Icons.self_improvement,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticleBackground() {
    return IgnorePointer(
      // 터치 이벤트 무시
      child: AnimatedBuilder(
        animation: _rippleAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: ParticlePainter(_rippleAnimation.value),
          );
        },
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 일시정지/재시작 버튼
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              LoggerService.instance.d('⏯️ 일시정지 버튼 클릭됨! 현재 상태: $_isPaused');
              HapticFeedback.lightImpact();
              _togglePause();
            },
            borderRadius: BorderRadius.circular(40),
            splashColor: _isPaused
                ? Colors.green.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
            highlightColor: _isPaused
                ? Colors.green.withOpacity(0.1)
                : Colors.white.withOpacity(0.1),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isPaused
                    ? Colors.green.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isPaused
                      ? Colors.green.withOpacity(0.8)
                      : Colors.white.withOpacity(0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isPaused
                        ? Colors.green.withOpacity(0.4)
                        : Colors.white.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 45,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 60),

        // 정지 버튼
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              LoggerService.instance.d('🛑 정지 버튼 클릭됨!');
              HapticFeedback.mediumImpact();
              _showStopConfirmDialog();
            },
            borderRadius: BorderRadius.circular(40),
            splashColor: Colors.red.withOpacity(0.3),
            highlightColor: Colors.red.withOpacity(0.1),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withOpacity(0.7),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.stop_rounded,
                  size: 45,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 정지 확인 다이얼로그
  Future<void> _showStopConfirmDialog() async {
    LoggerService.instance.d('📋 정지 확인 다이얼로그 표시');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '정말 그만두시겠어요?',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '지금까지의 몰입 시간이 저장되지 않습니다.',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• 포인트 20P가 차감됩니다',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: Colors.red.withOpacity(0.9),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                LoggerService.instance.d('❌ 정지 취소됨');
                Navigator.of(context).pop(false);
              },
              child: Text(
                '계속하기',
                style: GoogleFonts.notoSans(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                LoggerService.instance.i('✅ 정지 확인됨');
                Navigator.of(context).pop(true);
              },
              child: Text(
                '그만두기',
                style: GoogleFonts.notoSans(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _handleGiveUp();
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isInFocusMode = true;
      _focusHP = 100; // HP 초기화
      _exitAttempts = 0;
    });

    // 🎯 전체화면 모드 진입
    _enterImmersiveMode();

    // 🎮 셰르피 응원 모드
    ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.focusComplete,
          customDialogue: '$_selectedMinutes분 몰입 시작! 제가 옆에서 응원할게요! 💪',
          emotion: SherpiEmotion.cheering,
          duration: const Duration(seconds: 4),
        );

    HapticFeedbackManager.heavyImpact();
    _pulseController.repeat(reverse: true);
    _rippleController.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _isInFocusMode) {
        setState(() {
          _remainingSeconds--;

          // 진행 상황에 따른 셰르피 반응
          _updateSherpiByProgress();
        });

        if (_remainingSeconds <= 0) {
          _completeTimer();
        }
      }
    });
  }

  // 🎯 전체화면 몰입 모드 진입
  void _enterImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [], // 모든 시스템 UI 숨기기
    );

    // 화면 방향 고정 (세로)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // 상태바 스타일 (다크 모드)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  // 🎯 몰입 모드 종료
  void _exitImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values, // 모든 UI 복원
    );

    // 화면 방향 제한 해제
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // 기본 상태바 스타일
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // 진행 상황에 따른 셰르피 업데이트
  void _updateSherpiByProgress() {
    final progress = 1.0 - (_remainingSeconds / (_selectedMinutes * 60));

    // 25% 달성
    if (progress >= 0.25 && progress < 0.26) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
            context: SherpiContext.encouragement,
            customDialogue: '25% 완료! 잘하고 있어요! 🎯',
            emotion: SherpiEmotion.happy,
            duration: const Duration(seconds: 3),
          );
    }

    // 50% 달성
    else if (progress >= 0.50 && progress < 0.51) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
            context: SherpiContext.encouragement,
            customDialogue: '절반 왔어요! 조금만 더 힘내요! 💙',
            emotion: SherpiEmotion.cheering,
            duration: const Duration(seconds: 3),
          );
    }

    // 75% 달성
    else if (progress >= 0.75 && progress < 0.76) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
            context: SherpiContext.encouragement,
            customDialogue: '거의 다 왔어요! 마지막 스퍼트! 🔥',
            emotion: SherpiEmotion.confidence,
            duration: const Duration(seconds: 3),
          );
    }
  }

  void _togglePause() {
    LoggerService.instance.d('🎮 일시정지 토글: 현재 상태 = $_isPaused');

    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _pulseController.stop();
      _rippleController.stop();
      LoggerService.instance.d('⏸️ 일시정지됨');
    } else {
      _pulseController.repeat(reverse: true);
      _rippleController.repeat();
      LoggerService.instance.d('▶️ 재시작됨');
    }

    HapticFeedbackManager.mediumImpact();
  }

  void _stopTimer() {
    LoggerService.instance.d('🛑 타이머 정지 시작');

    _timer?.cancel();
    _pulseController.stop();
    _rippleController.stop();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isInFocusMode = false;
      _remainingSeconds = _selectedMinutes * 60;
      _focusHP = 100;
      _exitAttempts = 0;
    });

    // 전체화면 모드 종료
    _exitImmersiveMode();

    HapticFeedbackManager.mediumImpact();
    LoggerService.instance.i('✅ 타이머 정지 완료');
  }

  void _completeTimer() async {
    _timer?.cancel();
    _pulseController.stop();
    _rippleController.stop();

    // 🎮 성공 포인트 계산
    final basePoints = _selectedMinutes * 2; // 분당 2포인트
    final hpBonus = (_focusHP / 100 * 50).round(); // HP 보너스 최대 50점
    final totalPoints = basePoints + hpBonus;

    // 🎮 globalUserProvider로 데이터 업데이트
    ref.read(globalUserProvider.notifier).handleActivityCompletion(
          activityType: 'focus',
          xp: _selectedMinutes.toDouble(), // 분당 1 XP
          points: totalPoints,
          statIncreases: {'willpower': 0.2, 'technique': 0.1},
          message: '몰입 시간 완료! $_selectedMinutes분 집중',
          additionalData: {
            'minutes': _selectedMinutes,
            'hp_remaining': _focusHP,
            'completed_at': DateTime.now().toIso8601String(),
          },
        );

    // 🎮 셰르피 축하
    ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.achievement,
          customDialogue:
              '대단해요! $_selectedMinutes분 몰입 완료! 🎉\n$totalPoints 포인트를 획득했어요!',
          emotion: SherpiEmotion.special,
          duration: const Duration(seconds: 5),
        );

    // 전체화면 모드 종료
    _exitImmersiveMode();

    HapticFeedbackManager.heavyImpact();

    // 완료 다이얼로그
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: ModernColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '몰입 완료!',
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedMinutes}분간의 깊은 몰입을 마쳤습니다.\n정말 훌륭해요! 🎉',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: ModernColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '확인',
                  style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // 🎮 포기 버튼
  Widget _buildGiveUpButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          LoggerService.instance.d('🚪 포기 버튼 클릭됨');
          HapticFeedback.mediumImpact();
          final shouldGiveUp = await _showExitConfirmDialog();
          if (shouldGiveUp) {
            _handleGiveUp();
          }
        },
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.red.withOpacity(0.3),
        highlightColor: Colors.red.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.red.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.close,
            color: Colors.red.withOpacity(0.8),
            size: 24,
          ),
        ),
      ),
    );
  }

  // 🎮 종료 확인 다이얼로그
  Future<bool> _showExitConfirmDialog() async {
    if (_isExitDialogShowing) return false;
    _isExitDialogShowing = true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: ModernColors.warning, size: 28),
            const SizedBox(width: 12),
            Text(
              '정말 포기하시겠어요?',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '아직 ${_remainingSeconds ~/ 60}분이 남았어요.\n포기하면 20포인트가 차감됩니다.',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                height: 1.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 20, color: ModernColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '포기 시 20포인트가 차감됩니다',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              // 계속하기 보상
              _exitAttempts = 0;
              ref.read(sherpiProvider.notifier).showInstantMessage(
                    context: SherpiContext.encouragement,
                    customDialogue: '잘 선택하셨어요! 계속 힘내봐요! 💪',
                    emotion: SherpiEmotion.cheering,
                    duration: const Duration(seconds: 3),
                  );
            },
            child: Text(
              '계속하기',
              style: GoogleFonts.notoSans(
                color: ModernColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '포기하기',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    _isExitDialogShowing = false;
    return result ?? false;
  }

  // 🎮 포기 처리
  void _handleGiveUp() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isInFocusMode = false;
    });

    // 포기 패널티
    final penalty = 20; // 20포인트 차감

    ref.read(globalPointProvider.notifier).spendPoints(
          penalty,
          '몰입 포기 패널티',
        );

    // 셰르피 실망
    ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.climbingFailure,
          customDialogue: '아쉬워요... 다음엔 꼭 성공해봐요! 😢\n${penalty}포인트가 차감되었어요.',
          emotion: SherpiEmotion.sad,
          duration: const Duration(seconds: 4),
        );

    // 전체화면 모드 종료
    _exitImmersiveMode();

    Navigator.of(context).pop();
  }

  // 🎮 HP 실패 알림창
  void _showHPFailureDialog(String reason) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFEF4444),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '몰입 실패',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: const Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HP가 0이 되었습니다',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '실패 사유: $reason',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '패널티 내역:',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• 20 포인트 차감',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: Colors.red.withOpacity(0.9),
              ),
            ),
            Text(
              '• 몰입 기록이 저장되지 않습니다',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: Colors.red.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '팁: 몰입 중에는 화면을 벗어나지 말고, 뒤로가기를 자주 누르지 마세요!',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: const Color(0xFF10B981),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 타이머 화면 닫기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                '다시 도전하기',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎮 백그라운드 10초 이탈 실패 알림창
  void _showBackgroundFailureDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: const Color(0xFFEF4444),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '몰입 실패',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: const Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '10초 이상 화면을 벗어났습니다',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '실패 사유: 앱을 백그라운드로 전환한 후 10초가 경과하여 자동으로 실패 처리되었습니다.',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '패널티 내역:',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• 20 포인트 차감',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: Colors.red.withOpacity(0.9),
              ),
            ),
            Text(
              '• 몰입 기록이 저장되지 않습니다',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: Colors.red.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '팁: 몰입 중에는 다른 앱으로 전환하지 마세요. 잠시 나가더라도 10초 안에 돌아오세요!',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: const Color(0xFF10B981),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 타이머 화면 닫기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                '다시 도전하기',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 파티클 배경 페인터
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 배경에 떠다니는 파티클들
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i +
          math.sin(animationValue * 2 * math.pi + i) * 30;
      final y = (size.height / 10) * (i % 10) +
          math.cos(animationValue * 2 * math.pi + i) * 20;

      canvas.drawCircle(
        Offset(x, y),
        2 + math.sin(animationValue * 4 * math.pi + i) * 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
