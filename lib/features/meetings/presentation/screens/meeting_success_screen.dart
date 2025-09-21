import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../models/available_meeting_model.dart';

/// 🎉 모임 참여 성공 화면
/// 참여 확정 후 축하 및 정보 안내 화면
class MeetingSuccessScreen extends ConsumerStatefulWidget {
  final AvailableMeeting meeting;

  const MeetingSuccessScreen({
    super.key,
    required this.meeting,
  });

  @override
  ConsumerState<MeetingSuccessScreen> createState() =>
      _MeetingSuccessScreenState();
}

class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;
  final List<_ConfettiParticle> _particles;

  _ConfettiPainter({
    required this.animation,
    required this.colors,
  })  : _particles = List.generate(
          50,
          (_) => _ConfettiParticle(colors),
        ),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      particle.update(size);
      particle.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}

class _ConfettiParticle {
  final math.Random _random = math.Random();
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double rotation;
  late double rotationSpeed;
  late Color color;
  late double particleSize;
  late double opacity;

  _ConfettiParticle(List<Color> colors) {
    reset(colors);
  }

  void reset(List<Color> colors) {
    x = _random.nextDouble();
    y = -0.1;
    vx = (_random.nextDouble() - 0.5) * 0.02;
    vy = _random.nextDouble() * 0.02 + 0.01;
    rotation = _random.nextDouble() * math.pi * 2;
    rotationSpeed = (_random.nextDouble() - 0.5) * 0.2;
    color = colors[_random.nextInt(colors.length)];
    particleSize = _random.nextDouble() * 8 + 4;
    opacity = _random.nextDouble() * 0.8 + 0.2;
  }

  void update(Size canvasSize) {
    if (y > 1.2) {
      reset([color]);
    }

    x += vx;
    y += vy;
    rotation += rotationSpeed;

    if (x < -0.1 || x > 1.1) {
      vx *= -1;
    }
  }

  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(x * canvasSize.width, y * canvasSize.height);
    canvas.rotate(rotation);

    switch (_random.nextInt(3)) {
      case 0:
        canvas.drawCircle(Offset.zero, particleSize / 2, paint);
        break;
      case 1:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particleSize,
            height: particleSize,
          ),
          paint,
        );
        break;
      default:
        final path = Path()
          ..moveTo(0, -particleSize / 2)
          ..lineTo(-particleSize / 2, particleSize / 2)
          ..lineTo(particleSize / 2, particleSize / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }

    canvas.restore();
  }
}

class _MeetingSuccessScreenState extends ConsumerState<MeetingSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<AnimationController> _rewardControllers;
  late List<Animation<double>> _rewardScaleAnimations;
  late List<Animation<double>> _rewardFadeAnimations;
  late _ConfettiPainter _confettiPainter;

  @override
  void initState() {
    super.initState();

    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rewardControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 200)),
        vsync: this,
      ),
    );

    _rewardScaleAnimations = _rewardControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    _rewardFadeAnimations = _rewardControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOut),
          ),
        )
        .toList();

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    // 애니메이션 시작
    _mainAnimationController.forward();
    _startSequentialRewardAnimations();

    _confettiPainter = _ConfettiPainter(
      animation: _confettiController,
      colors: [
        widget.meeting.category.color,
        ModernColors.primary,
        ModernColors.accent,
        ModernColors.success,
      ],
    );
    _confettiController.repeat();

    // 🎯 성공 셰르피 메시지 (카테고리별 맞춤 메시지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showMessage(
            context:
                SherpiContext.meetingJoined, // levelUp이 아닌 meetingJoined 사용
            emotion: SherpiEmotion.talking, // talking 감정 사용 (카테고리별 메시지와 어울림)
            userContext: {
              'screen': 'meeting_success',
              'meeting_title': widget.meeting.title,
              'category': widget.meeting.category.name, // 카테고리 정보 추가
              'experience_gained': widget.meeting.experienceReward,
              'points_gained': widget.meeting.participationReward,
            },
            duration: const Duration(seconds: 6),
          );
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _confettiController.dispose();
    for (final controller in _rewardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _startSequentialRewardAnimations() async {
    for (var i = 0; i < _rewardControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 300 + (i * 200)));
      if (!mounted) {
        return;
      }
      _rewardControllers[i].forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);

    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: const SherpaCleanAppBar(
        title: '참여 완료',
      ),
      body: Stack(
        children: [
          // 🎊 배경 컨페티 애니메이션
          Positioned.fill(
            child: CustomPaint(
              painter: _confettiPainter,
            ),
          ),

          // 메인 컨텐츠
          AnimatedBuilder(
            animation: _mainAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // 🎉 성공 헤더
                        _buildSuccessHeader(),

                        const SizedBox(height: 30),

                        // 📊 보상 표시
                        _buildRewardDisplay(),

                        const SizedBox(height: 30),

                        // 📋 모임 정보 요약
                        _buildMeetingInfoSummary(),

                        const SizedBox(height: 30),

                        // 🎯 다음 액션들
                        _buildNextActions(),

                        const SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // 🎯 하단 액션 버튼들
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  /// 🎉 성공 헤더
  Widget _buildSuccessHeader() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              widget.meeting.category.color.withValues(alpha: 0.2),
              widget.meeting.category.color.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          shape: BoxShape.circle,
        ),
        child: Column(
          children: [
            // 성공 아이콘
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.meeting.category.color,
                    widget.meeting.category.color.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.meeting.category.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // 축하 메시지
            Text(
              '🎉 모험 참여 완료!',
              style: GoogleFonts.notoSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: ModernColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              widget.meeting.title,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: widget.meeting.category.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              '모임에 성공적으로 참여했어요!\n새로운 경험과 인연을 만나보세요.',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardDisplay() {
    final expReward = widget.meeting.experienceReward;
    final pointReward = widget.meeting.participationReward;
    final statRewards = widget.meeting.statRewards;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🏆 획득한 보상',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _rewardControllers[0],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _rewardScaleAnimations[0].value,
                      child: FadeTransition(
                        opacity: _rewardFadeAnimations[0],
                        child: child,
                      ),
                    );
                  },
                  child: _buildMainRewardCard(
                    icon: '⭐',
                    title: '경험치',
                    value: '+${expReward.toStringAsFixed(0)}',
                    subtitle: '성장의 힘',
                    color: ModernColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedBuilder(
                  animation: _rewardControllers[1],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _rewardScaleAnimations[1].value,
                      child: FadeTransition(
                        opacity: _rewardFadeAnimations[1],
                        child: child,
                      ),
                    );
                  },
                  child: _buildMainRewardCard(
                    icon: '💎',
                    title: '포인트',
                    value: '+${pointReward.toStringAsFixed(0)}',
                    subtitle: '모험의 대가',
                    color: ModernColors.accent,
                  ),
                ),
              ),
            ],
          ),
          if (statRewards.isNotEmpty) ...[
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _rewardControllers[2],
              builder: (context, child) {
                return Transform.scale(
                  scale: _rewardScaleAnimations[2].value,
                  child: FadeTransition(
                    opacity: _rewardFadeAnimations[2],
                    child: child,
                  ),
                );
              },
              child: _buildStatRewardsSection(statRewards),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.meeting.category.color.withValues(alpha: 0.1),
                  widget.meeting.category.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.meeting.category.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Text('🌟', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '모험을 통해 더 강해졌어요!\n계속해서 새로운 도전을 해보세요!',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.meeting.category.color,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainRewardCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRewardsSection(Map<String, double> statRewards) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: ModernColors.success,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '💪 능력치 성장',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statRewards.entries.map((entry) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ModernColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ModernColors.success.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getStatEmoji(entry.key),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatDisplayName(entry.key),
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.success,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${entry.value.toStringAsFixed(1)}',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.success,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getStatDisplayName(String statKey) {
    switch (statKey) {
      case 'stamina':
        return '체력';
      case 'knowledge':
        return '지식';
      case 'technique':
        return '기술';
      case 'sociality':
        return '사교성';
      case 'willpower':
        return '의지력';
      default:
        return statKey;
    }
  }

  String _getStatEmoji(String statKey) {
    switch (statKey) {
      case 'stamina':
        return '💪';
      case 'knowledge':
        return '🧠';
      case 'technique':
        return '🛠️';
      case 'sociality':
        return '🤝';
      case 'willpower':
        return '🔥';
      default:
        return '⭐';
    }
  }

  /// 📋 모임 정보 요약
  Widget _buildMeetingInfoSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note_rounded,
                color: ModernColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '📋 모임 일정',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 일정 정보
          _buildInfoRow(
            icon: Icons.schedule_rounded,
            label: '일시',
            value: widget.meeting.formattedDate,
            color: ModernColors.primary,
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            icon: Icons.location_on_rounded,
            label: '장소',
            value: widget.meeting.location,
            color: ModernColors.accent,
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            icon: Icons.person_rounded,
            label: '호스트',
            value: widget.meeting.hostName,
            color: ModernColors.success,
          ),

          const SizedBox(height: 16),

          // 알림 설정
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: ModernColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '모임 시작 1시간 전에 알림을 보내드릴게요!',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: ModernColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  color: ModernColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🎯 다음 액션들
  Widget _buildNextActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 다음 할 일',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // 캘린더 추가
          _buildActionButton(
            icon: Icons.event_rounded,
            title: '캘린더에 추가',
            subtitle: '일정을 놓치지 않도록 캘린더에 저장하세요',
            onTap: () {
              // TODO: 캘린더 앱 연동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('캘린더 추가 기능 (구현 예정)'),
                  backgroundColor: ModernColors.primary,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // 친구에게 공유
          _buildActionButton(
            icon: Icons.share_rounded,
            title: '친구에게 공유',
            subtitle: '함께 참여할 친구들에게 알려보세요',
            onTap: () {
              // TODO: 공유 기능
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('공유 기능 (구현 예정)'),
                  backgroundColor: ModernColors.accent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ModernColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ModernColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: ModernColors.primary,
                size: 20,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: ModernColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 하단 액션 버튼들
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 메인 액션 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/', // 홈으로 이동
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.meeting.category.color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '홈으로 돌아가기',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 서브 액션 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/meeting_review',
                    arguments: {'meetingId': widget.meeting.id},
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: ModernColors.textSecondary,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.rate_review_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '미리 후기 작성하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
