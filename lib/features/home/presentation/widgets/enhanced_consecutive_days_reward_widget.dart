import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';

// Shared Providers
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';

// Shared Models
import '../../../../shared/models/point_system_model.dart';

// Shared Widgets
import '../../../../shared/widgets/animated_number_widget.dart';

class EnhancedConsecutiveDaysRewardWidget extends ConsumerStatefulWidget {
  final VoidCallback onClaimReward;

  const EnhancedConsecutiveDaysRewardWidget({
    Key? key,
    required this.onClaimReward,
  }) : super(key: key);

  @override
  ConsumerState<EnhancedConsecutiveDaysRewardWidget> createState() =>
      _EnhancedConsecutiveDaysRewardWidgetState();
}

class _EnhancedConsecutiveDaysRewardWidgetState
    extends ConsumerState<EnhancedConsecutiveDaysRewardWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _floatAnimation;

  bool _isClaimable = true;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_sparkleController);

    _floatAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _checkClaimStatus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _checkClaimStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayRewardClaimed = prefs.getBool('today_reward_claimed_$todayString') ?? false;

    if (todayRewardClaimed && mounted) {
      setState(() {
        _isClaimable = false;
      });
    }
  }

  Future<void> _claimReward() async {
    if (!_isClaimable || _isClaiming) return;

    setState(() => _isClaiming = true);

    // 햅틱 피드백
    HapticFeedback.mediumImpact();

    // 애니메이션 효과
    await Future.delayed(const Duration(milliseconds: 300));

    final user = ref.read(globalUserProvider);
    final consecutiveDays = user.dailyRecords.consecutiveDays;
    
    // 연속 접속일에 따른 보상 계산
    final rewardPoints = _calculateDailyRewardPoints(consecutiveDays);
    final rewardExperience = _calculateDailyRewardExperience(user.level);

    // 포인트 지급
    ref.read(globalPointProvider.notifier).earnPoints(
      rewardPoints,
      PointSource.dailyGoalAd,
      '일일 접속 보상 ($consecutiveDays일 연속)',
    );

    // 경험치 지급
    ref.read(globalUserProvider.notifier).addExperience(rewardExperience.toDouble());

    // 셰르피 반응
    ref.read(sherpiProvider.notifier).showMessage(
      context: SherpiContext.dailyGreeting,
      emotion: SherpiEmotion.cheering,
      userContext: {
        'consecutiveDays': consecutiveDays,
      },
    );

    // SharedPreferences에 오늘 보상 수령 기록
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await prefs.setBool('today_reward_claimed_$todayString', true);

    setState(() {
      _isClaimable = false;
      _isClaiming = false;
    });

    widget.onClaimReward.call();
  }

  // 일일 보상 포인트 계산 (연속 접속일 보너스)
  int _calculateDailyRewardPoints(int consecutiveDays) {
    int baseReward = 50;
    int streakBonus = 0;
    
    if (consecutiveDays >= 365) {
      streakBonus = 1000; // 1년 연속
    } else if (consecutiveDays >= 100) {
      streakBonus = 500;  // 100일 연속
    } else if (consecutiveDays >= 30) {
      streakBonus = 200;  // 30일 연속
    } else if (consecutiveDays >= 7) {
      streakBonus = 100;  // 7일 연속
    } else {
      streakBonus = consecutiveDays * 10; // 일반 보너스
    }
    
    return baseReward + streakBonus;
  }

  // 일일 보상 경험치 계산 (레벨 기반)
  int _calculateDailyRewardExperience(int userLevel) {
    return 20 + (userLevel * 5);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final consecutiveDays = user.dailyRecords.consecutiveDays;
    final rewardPoints = _calculateDailyRewardPoints(consecutiveDays);
    final rewardExperience = _calculateDailyRewardExperience(user.level);

    return GestureDetector(
      onTap: _isClaimable ? _claimReward : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _floatAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Transform.scale(
              scale: _isClaimable ? _pulseAnimation.value : 1.0,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 140,
                  maxHeight: 180,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF7C3AED),
                      const Color(0xFF6D28D9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF6D28D9).withOpacity(0.2),
                      blurRadius: 48,
                      offset: const Offset(0, 24),
                      spreadRadius: -12,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 배경 패턴
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CustomPaint(
                          painter: _PatternPainter(
                            sparkleAnimation: _sparkleAnimation,
                          ),
                        ),
                      ),
                    ),

                    // 메인 콘텐츠
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          // 왼쪽 아이콘 영역
                          _buildIconSection(consecutiveDays),
                          const SizedBox(width: 20),

                          // 중앙 텍스트 영역
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '연속 접속 보상',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '$consecutiveDays일째 함께해요!',
                                      style: GoogleFonts.notoSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildRewardInfo(rewardPoints, rewardExperience),
                              ],
                            ),
                          ),

                          // 오른쪽 버튼 영역
                          _buildClaimButton(),
                        ],
                      ),
                    ),

                    // 반짝임 효과
                    if (_isClaimable) ..._buildSparkles(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconSection(int days) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 메인 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '🔥',
                style: TextStyle(
                  fontSize: 32,
                  shadows: [
                    Shadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 일수 표시
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D28D9).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$days',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6D28D9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardInfo(int points, int experience) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 6),
          Text(
            '${points}P + ${experience}XP',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        minWidth: _isClaimable ? 80 : 70,
        maxWidth: 100,
      ),
      height: 40,
      decoration: BoxDecoration(
        gradient: _isClaimable
            ? LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.9),
                ],
              )
            : null,
        color: _isClaimable ? null : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _isClaimable
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: _isClaiming
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF6D28D9),
                  ),
                ),
              )
            : Text(
                _isClaimable ? '받기' : '완료',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _isClaimable
                      ? const Color(0xFF6D28D9)
                      : Colors.white.withOpacity(0.6),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildSparkles() {
    return List.generate(6, (index) {
      final random = math.Random(index);
      final size = 4.0 + random.nextDouble() * 4;
      final top = random.nextDouble() * 140;
      final left = random.nextDouble() * 300;

      return Positioned(
        top: top,
        left: left,
        child: AnimatedBuilder(
          animation: _sparkleAnimation,
          builder: (context, child) {
            final opacity = math.sin(_sparkleAnimation.value * math.pi * 2 + 
                (index * math.pi / 3)) * 0.5 + 0.5;
            
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity * 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(opacity * 0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

// 배경 패턴 페인터
class _PatternPainter extends CustomPainter {
  final Animation<double> sparkleAnimation;

  _PatternPainter({required this.sparkleAnimation}) : super(repaint: sparkleAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 육각형 패턴
    const hexSize = 30.0;
    final rows = (size.height / hexSize).ceil() + 1;
    final cols = (size.width / hexSize).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = col * hexSize * 1.5;
        final y = row * hexSize * math.sqrt(3) + 
            (col % 2 == 1 ? hexSize * math.sqrt(3) / 2 : 0);

        final opacity = (math.sin(sparkleAnimation.value * math.pi * 2 + 
            (row + col) * 0.2) + 1) / 2;

        paint.color = Colors.white.withOpacity(opacity * 0.1);

        _drawHexagon(canvas, Offset(x, y), hexSize / 2, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
