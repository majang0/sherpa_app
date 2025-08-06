import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class UniversityGuildWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<UniversityGuildWidget> createState() => _UniversityGuildWidgetState();
}

class _UniversityGuildWidgetState extends ConsumerState<UniversityGuildWidget>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러들
  late AnimationController _sunriseController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  late AnimationController _tapController;

  late Animation<double> _sunriseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();

    // 일출 애니메이션
    _sunriseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _sunriseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sunriseController,
      curve: Curves.easeInOut,
    ));
    _sunriseController.repeat(reverse: true);

    // 빛나는 효과 애니메이션
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    _glowController.repeat(reverse: true);

    // 부유 효과 애니메이션
    _floatController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: -3,
      end: 3,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    _floatController.repeat(reverse: true);

    // 탭 애니메이션
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _sunriseController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedbackManager.lightImpact();
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _sunriseAnimation,
        _glowAnimation,
        _floatAnimation,
        _tapAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _tapAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                decoration: BoxDecoration(
                  // Dark Slate Blue 배경
                  color: const Color(0xFF483D8B),
                  borderRadius: BorderRadius.circular(24),
                  // 세련된 테두리
                  border: Border.all(
                    color: const Color(0xFFFF7F50).withOpacity(0.3),
                    width: 1.5,
                  ),
                  // 고급스러운 그림자
                  boxShadow: [
                    // 코랄색 글로우
                    BoxShadow(
                      color: const Color(0xFFFF7F50).withOpacity(0.15 * _glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                    // 깊이감 있는 그림자
                    BoxShadow(
                      color: const Color(0xFF483D8B).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // 여명 배경 효과
                      _buildDawnBackground(),
                      // 메인 컨텐츠
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildGuildHeader(),
                            const SizedBox(height: 24),
                            _buildGuildStats(),
                            const SizedBox(height: 24),
                            _buildGuildGoal(),
                            const SizedBox(height: 24),
                            _buildTopMembers(),
                          ],
                        ),
                      ),
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

  // 여명 배경 효과
  Widget _buildDawnBackground() {
    return Stack(
      children: [
        // 그라데이션 배경
        AnimatedBuilder(
          animation: _sunriseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFF7F50).withOpacity(0.15 * _sunriseAnimation.value),
                    const Color(0xFF483D8B),
                    const Color(0xFF483D8B).withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),
        // 정상의 빛 효과
        Positioned(
          top: -100,
          left: -100,
          right: -100,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF7F50).withOpacity(0.2 * _glowAnimation.value),
                  const Color(0xFFFFB347).withOpacity(0.1 * _glowAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // 라일락 미스트 효과
        Positioned.fill(
          child: CustomPaint(
            painter: MistPainter(
              animation: _sunriseAnimation.value,
              glowValue: _glowAnimation.value,
            ),
          ),
        ),
      ],
    );
  }

  // 길드 헤더
  Widget _buildGuildHeader() {
    return Row(
      children: [
        // 길드 문장 (정상의 빛)
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF7F50),
                const Color(0xFFFFB347),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7F50).withOpacity(0.5 * _glowAnimation.value),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 내부 원
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF483D8B),
                      const Color(0xFF483D8B).withOpacity(0.8),
                      const Color(0xFFFF7F50).withOpacity(0.2),
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE6E6FA).withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              // 산 정상 아이콘
              Icon(
                Icons.terrain,
                size: 32,
                color: const Color(0xFFFF7F50),
                shadows: [
                  Shadow(
                    color: const Color(0xFFFF7F50).withOpacity(0.8),
                    blurRadius: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // 길드 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF7F50).withOpacity(0.2),
                          const Color(0xFFFFB347).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF7F50).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'GUILD',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF7F50),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          const Color(0xFFE6E6FA),
                          Colors.white,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        '영남이공대학교',
                        style: GoogleFonts.notoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.people_alt,
                    size: 16,
                    color: const Color(0xFFE6E6FA).withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '847명의 셰르파',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE6E6FA).withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 온라인 상태 (여명의 빛)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFB347).withOpacity(0.2),
                          const Color(0xFFFF7F50).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFB347).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB347),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB347),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '67 활동중',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFB347),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 길드 통계
  Widget _buildGuildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.military_tech,
            title: '길드 레벨',
            value: '8',
            unit: 'LV',
            isMain: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            title: '내 순위',
            value: '5',
            unit: '위',
            isMain: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.auto_awesome,
            title: '주간 XP',
            value: '12.5',
            unit: 'K',
            isMain: false,
          ),
        ),
      ],
    );
  }

  // 통계 카드
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required bool isMain,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isMain ? [
            const Color(0xFFFF7F50).withOpacity(0.15),
            const Color(0xFFFFB347).withOpacity(0.1),
          ] : [
            const Color(0xFF6B5B95).withOpacity(0.3),
            const Color(0xFF6B5B95).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMain
              ? const Color(0xFFFF7F50).withOpacity(0.3)
              : const Color(0xFFE6E6FA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: isMain ? const Color(0xFFFF7F50) : const Color(0xFFE6E6FA),
            shadows: isMain ? [
              Shadow(
                color: const Color(0xFFFF7F50).withOpacity(0.5),
                blurRadius: 10,
              ),
            ] : null,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isMain ? const Color(0xFFFF7F50) : const Color(0xFFE6E6FA),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isMain
                      ? const Color(0xFFFF7F50).withOpacity(0.8)
                      : const Color(0xFFE6E6FA).withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE6E6FA).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // 길드 목표
  Widget _buildGuildGoal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6B5B95).withOpacity(0.4),
            const Color(0xFF6B5B95).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE6E6FA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF7F50).withOpacity(0.2),
                      const Color(0xFFFFB347).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.flag,
                    size: 20,
                    color: const Color(0xFFFF7F50),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이번 주 길드 목표',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE6E6FA).withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '총 15,000 XP 달성',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE6E6FA),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF7F50),
                      const Color(0xFFFFB347),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7F50).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  '83%',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 여명의 프로그레스 바
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF483D8B).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFFE6E6FA).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.83,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF7F50),
                        const Color(0xFFFFB347),
                        const Color(0xFFFF7F50),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7F50).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12,500 XP',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF7F50),
                ),
              ),
              Text(
                '15,000 XP',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE6E6FA).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TOP 3 멤버
  Widget _buildTopMembers() {
    final members = [
      {
        'rank': 1,
        'name': '김민수',
        'dept': '사이버보안과',
        'level': 14,
        'weeklyXP': 1850,
        'avatar': '👨‍🎓',
      },
      {
        'rank': 2,
        'name': '이영희',
        'dept': '컴퓨터정보과',
        'level': 11,
        'weeklyXP': 1620,
        'avatar': '👩‍🎓',
      },
      {
        'rank': 3,
        'name': '최준호',
        'dept': '사이버보안과',
        'level': 14,
        'weeklyXP': 1450,
        'avatar': '👨‍💻',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events,
              size: 20,
              color: const Color(0xFFFF7F50),
            ),
            const SizedBox(width: 8),
            Text(
              '이번 주 TOP 3',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE6E6FA),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF69B4).withOpacity(0.3),
                    const Color(0xFFFF1493).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFFF69B4).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                'LIVE',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF69B4),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...members.map((member) => _buildMemberRow(member)).toList(),
      ],
    );
  }

  // 멤버 행
  Widget _buildMemberRow(Map<String, dynamic> member) {
    final rank = member['rank'] as int;
    final isFirst = rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFirst ? [
            const Color(0xFFFF7F50).withOpacity(0.1),
            const Color(0xFFFFB347).withOpacity(0.05),
          ] : [
            const Color(0xFF6B5B95).withOpacity(0.2),
            const Color(0xFF6B5B95).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFirst
              ? const Color(0xFFFF7F50).withOpacity(0.3)
              : const Color(0xFFE6E6FA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 순위 표시
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getRankColors(rank),
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: isFirst ? [
                BoxShadow(
                  color: const Color(0xFFFF7F50).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 아바타
          Text(
            member['avatar'] as String,
            style: const TextStyle(fontSize: 26),
          ),
          const SizedBox(width: 12),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member['name'] as String,
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE6E6FA),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E6FA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE6E6FA).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Lv.${member['level']}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE6E6FA),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member['dept'] as String,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE6E6FA).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isFirst ? [
                    const Color(0xFFFF7F50),
                    const Color(0xFFFFB347),
                  ] : [
                    const Color(0xFFE6E6FA),
                    const Color(0xFFE6E6FA),
                  ],
                ).createShader(bounds),
                child: Text(
                  '+${member['weeklyXP']}',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'XP',
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE6E6FA).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 순위별 색상
  List<Color> _getRankColors(int rank) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFF7F50), const Color(0xFFFFB347)]; // 코랄-골드
      case 2:
        return [const Color(0xFFB8B8D0), const Color(0xFFC8C8E8)]; // 실버 라일락
      case 3:
        return [const Color(0xFFCD853F), const Color(0xFFDEB887)]; // 브론즈
      default:
        return [const Color(0xFF8B7D99), const Color(0xFF9D8CAB)]; // 디폴트 보라
    }
  }
}

// 미스트 페인터 (라일락 안개 효과)
class MistPainter extends CustomPainter {
  final double animation;
  final double glowValue;

  MistPainter({
    required this.animation,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    // 라일락 미스트 효과
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * (0.3 + animation * 0.2),
      size.height * (0.6 + animation * 0.1),
      size.width * 0.6,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * (0.8 - animation * 0.1),
      size.height * (0.9 - animation * 0.1),
      size.width,
      size.height,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    paint.shader = ui.Gradient.linear(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height),
      [
        const Color(0xFFE6E6FA).withOpacity(0.1 * glowValue),
        const Color(0xFFE6E6FA).withOpacity(0.05 * glowValue),
        Colors.transparent,
      ],
      [0.0, 0.5, 1.0],
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}