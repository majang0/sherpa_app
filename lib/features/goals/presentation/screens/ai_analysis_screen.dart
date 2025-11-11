import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/animation/micro_interactions.dart';
import 'package:sherpa_app/core/constants/sherpi_emotions.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_point_provider.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/features/goals/providers/goal_provider.dart';
import 'package:sherpa_app/features/goals/providers/routine_provider.dart';
import 'package:sherpa_app/features/goals/models/achievement_analysis_model.dart';
import 'package:sherpa_app/features/goals/services/ai_analysis_data_collector.dart';
import 'package:sherpa_app/features/goals/services/ai_prompt_builder.dart';
import 'package:sherpa_app/core/ai/services/openai_service.dart';

/// AI 분석 화면 (Blue-Tone Design with Sherpi)
///
/// 레이아웃:
/// 1. Blue Gradient Background
/// 2. Header - Glassmorphism 뒤로가기 버튼
/// 3. Info Card - Sherpi thinking 이미지 포함
/// 4. Category Cards - 압축된 레이아웃
/// 5. Analysis Button - 한 화면에 모두 표시
/// 6. Loading - ai_analysis_loading_widget 스타일
class AiAnalysisScreen extends ConsumerStatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen>
    with TickerProviderStateMixin {
  String? _selectedCategory;
  bool _isLoading = false;
  AchievementAnalysisModel? _analysisResult;

  // 로딩 애니메이션 컨트롤러
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _textController;

  int _currentTextIndex = 0;
  final List<String> _loadingTexts = [
    '목표 달성 패턴을 분석하고 있어요...',
    '운동, 학습, 대회 기록을 살펴보는 중...',
    '성장 지표와 관심사를 파악하고 있어요...',
    '가장 효과적인 개선 방안을 찾고 있어요...',
    'AI가 맞춤 분석을 생성하는 중...',
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _startTextCycle() async {
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);

    while (mounted && _isLoading) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_isLoading) break;

      await _textController.forward();
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
        });
      }
      await _textController.reverse();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPoints = ref.watch(globalTotalPointsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFBBDEFB), // Lighter blue
              Colors.white,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: _isLoading
            ? _buildLoadingState()
            : _analysisResult != null
                ? _buildAnalysisResult()
                : _buildCategorySelection(totalPoints),
      ),
    );
  }

  /// 카테고리 선택 화면 - 압축된 레이아웃
  Widget _buildCategorySelection(int totalPoints) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header - 뒤로가기 버튼
        SliverToBoxAdapter(
          child: _buildCleanHeader(context),
        ),

        // Info Card - Sherpi 이미지 포함
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _buildSherpiInfoCard(totalPoints),
          ),
        ),

        // Section Header
        SliverToBoxAdapter(
          child: _buildSectionHeader()
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideX(begin: -0.05, end: 0, delay: 150.ms),
        ),

        // Category Cards - 압축된 디자인
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildCompactCategoryCard(
                '운동',
                Icons.fitness_center,
                ModernColors.exercise,
                '운동 목표 달성 분석',
                0,
              ),
              const SizedBox(height: 10),
              _buildCompactCategoryCard(
                '대회',
                Icons.emoji_events,
                ModernColors.primary,
                '대회 참여 목표 분석',
                1,
              ),
              const SizedBox(height: 10),
              _buildCompactCategoryCard(
                '학습',
                Icons.school,
                ModernColors.reading,
                '학습 목표 달성 분석',
                2,
              ),
              const SizedBox(height: 10),
              _buildCompactCategoryCard(
                '자격증',
                Icons.workspace_premium,
                ModernColors.focus,
                '자격증 취득 목표 분석',
                3,
              ),
              const SizedBox(height: 16),

              // 분석 시작 버튼
              if (_selectedCategory != null)
                _buildAnalysisButton(totalPoints)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      duration: 300.ms,
                      curve: Curves.easeOut,
                    ),
            ]),
          ),
        ),
      ],
    );
  }

  /// Clean Header - 블루톤
  Widget _buildCleanHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
      child: Row(
        children: [
          // 뒤로가기 버튼
          MicroInteractions.tapResponse(
            onTap: () => Navigator.pop(context),
            scaleDownTo: 0.95,
            enableHaptic: true,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: ModernColors.primary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  /// Sherpi Info Card - Sherpi thinking 이미지 포함
  Widget _buildSherpiInfoCard(int totalPoints) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
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
      child: Row(
        children: [
          // Sherpi 이미지
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  ModernColors.primary.withValues(alpha: 0.15),
                  ModernColors.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                SherpiEmotion.thinking.imagePath,
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
              ),
          const SizedBox(width: 16),

          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타이틀 + 포인트 뱃지
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '셰르피 AI 분석',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ModernColors.primary,
                            ModernColors.primary.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: ModernColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '30P',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 설명
                Text(
                  '목표 달성 패턴 분석 및\n개선 방안 제시',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                    height: 1.4,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 10),

                // 보유 포인트
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: ModernColors.primary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '보유: $totalPoints P',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.primary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 600.ms, curve: Curves.easeOut)
        .scale(
            begin: const Offset(0.96, 0.96),
            duration: 500.ms,
            curve: Curves.easeOutBack);
  }

  /// Section Header - 블루톤
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  ModernColors.primary,
                  ModernColors.secondary,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '분석 카테고리',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Compact Category Card - 압축된 레이아웃 (세련된 블루/회색 톤)
  Widget _buildCompactCategoryCard(
    String category,
    IconData icon,
    Color color,
    String description,
    int index,
  ) {
    final isSelected = _selectedCategory == category;

    return MicroInteractions.tapResponse(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      scaleDownTo: 0.98,
      enableHaptic: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    const Color(0xFFE3F2FD), // Light Blue 50
                    const Color(0xFFBBDEFB), // Light Blue 100
                  ]
                : [
                    const Color(0xFFF5F5F5), // Grey 100
                    Colors.white,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? ModernColors.primary
                : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? ModernColors.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 16 : 8,
              offset: Offset(0, isSelected ? 6 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: isSelected
                      ? [
                          ModernColors.primary.withValues(alpha: 0.25),
                          ModernColors.primary.withValues(alpha: 0.12),
                        ]
                      : [
                          Colors.grey.shade300.withValues(alpha: 0.3),
                          Colors.grey.shade200.withValues(alpha: 0.2),
                        ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? ModernColors.primary : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 14),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: GoogleFonts.notoSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.grey.shade900
                          : Colors.grey.shade700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.grey.shade700
                          : Colors.grey.shade600,
                      height: 1.3,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),

            // 선택 표시
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.primary,
                      ModernColors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: (200 + (index * 60)).ms,
            duration: 500.ms,
            curve: Curves.easeOutCubic)
        .slideX(
            begin: 0.05,
            end: 0,
            delay: (150 + (index * 50)).ms,
            curve: Curves.easeOutQuart)
        .scale(
            begin: const Offset(0.97, 0.97),
            end: const Offset(1.0, 1.0),
            delay: (150 + (index * 50)).ms)
        .animate(
            target: isSelected ? 1 : 0,
            autoPlay: false,
        )
        .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.02, 1.02),
            duration: 300.ms,
            curve: Curves.easeOut,
        );
  }

  /// 분석 시작 버튼 - 블루톤
  Widget _buildAnalysisButton(int totalPoints) {
    return MicroInteractions.tapResponse(
      onTap: () => _startAnalysis(totalPoints),
      scaleDownTo: 0.97,
      enableHaptic: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernColors.primary,
              ModernColors.primary.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ModernColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '분석 시작하기',
              style: GoogleFonts.notoSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '30P',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
            duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3));
  }

  /// 로딩 상태 - ai_analysis_loading_widget 스타일
  Widget _buildLoadingState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sherpi + 회전하는 링
            Stack(
              alignment: Alignment.center,
              children: [
                // 배경 원형 애니메이션
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.2),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ModernColors.primary.withValues(alpha: 0.15),
                              ModernColors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 회전하는 링
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(100, 100),
                        painter: _AIRingPainter(),
                      ),
                    );
                  },
                ),

                // Sherpi 이미지
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    SherpiEmotion.thinking.imagePath,
                    fit: BoxFit.contain,
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: 2000.ms,
                    ),
              ],
            ),

            const SizedBox(height: 24),

            // AI 라벨
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ModernColors.primary,
                    ModernColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI 분석 중',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .shimmer(
                  duration: 2000.ms,
                  color: Colors.white.withValues(alpha: 0.3),
                ),

            const SizedBox(height: 16),

            // 로딩 텍스트 (순환)
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: 1.0 - _textController.value,
                  child: Text(
                    _loadingTexts[_currentTextIndex],
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 프로그레스 바
            _buildProgressBar(),

            const SizedBox(height: 12),

            // 추가 정보
            Text(
              '잠시만 기다려주세요',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // 소요 시간 안내
            Text(
              '전문적인 분석을 위해 15~20초 정도 소요됩니다',
              style: GoogleFonts.notoSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary.withValues(alpha: 0.7),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      width: 200,
      decoration: BoxDecoration(
        color: ModernColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 움직이는 프로그레스
              Container(
                width: constraints.maxWidth * 0.3,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.primary.withValues(alpha: 0.0),
                      ModernColors.primary,
                      ModernColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .slideX(
                    begin: -0.3,
                    end: 1.3,
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  ),
            ],
          );
        },
      ),
    );
  }

  /// 분석 결과 화면 - 블루톤
  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return const SizedBox.shrink();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildCleanHeader(context),
        ),

        // 결과 컨텐츠
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 결과 헤더 카드
                _buildResultHeaderCard()
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 600.ms)
                    .slideY(begin: 0.1, end: 0, delay: 100.ms),
                const SizedBox(height: 20),

                // Section Header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ModernColors.primary,
                            ModernColors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '분석 내용',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideX(begin: -0.05, end: 0, delay: 150.ms),
                const SizedBox(height: 14),

                // 분석 내용 카드
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    _analysisResult!.analysisContent,
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textPrimary,
                      height: 1.7,
                      letterSpacing: -0.2,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .scale(
                        begin: const Offset(0.98, 0.98),
                        duration: 500.ms,
                        curve: Curves.easeOut),
                const SizedBox(height: 24),

                // 다시 분석하기 버튼
                MicroInteractions.tapResponse(
                  onTap: () {
                    setState(() {
                      _analysisResult = null;
                      _selectedCategory = null;
                    });
                  },
                  scaleDownTo: 0.97,
                  enableHaptic: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.95),
                          Colors.white.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ModernColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh,
                          color: ModernColors.primary.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '다시 분석하기',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.primary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.05, end: 0, delay: 350.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 결과 헤더 카드 - 블루톤
  Widget _buildResultHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.primary,
            ModernColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 + 타이틀
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '셰르피 분석 결과',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 구분선
          Container(
            height: 1,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 14),

          // 카테고리 + 일시
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _analysisResult!.category,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.schedule,
                size: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _analysisResult!.analyzedAt.toString().split('.')[0],
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 분석 시작 확인 다이얼로그
  void _startAnalysis(int totalPoints) {
    // 포인트 부족 체크
    if (totalPoints < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '포인트가 부족합니다. (필요: 30P, 보유: ${totalPoints}P)',
            style: GoogleFonts.notoSans(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: ModernColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // 확인 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          '셰르피 분석 시작',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
        content: Text(
          '30 포인트를 사용하여 "$_selectedCategory" 카테고리의 목표를 분석하시겠습니까?',
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
                color: ModernColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performAnalysis();
            },
            style: TextButton.styleFrom(
              backgroundColor: ModernColors.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                '분석 시작',
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.w700,
                  color: ModernColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🏃 러닝 전문 AI 분석 수행 (OpenAI GPT-5 연동)
  Future<void> _performAnalysis() async {
    // 로딩 시작
    setState(() {
      _isLoading = true;
    });

    // 텍스트 순환 시작
    _startTextCycle();

    try {
      // 1. 사용자 데이터 가져오기
      final user = ref.read(globalUserProvider);
      final goals = ref.read(goalProvider);
      final routines = ref.read(routineProvider);

      // 2. 러닝 데이터 수집 (RunningRecord 사용)
      final runningData = await AIAnalysisDataCollector.collectRunningData(
        user,
        goals,
        routines,
      );

      // 3. 데이터 유효성 검증
      if (!AIAnalysisDataCollector.validateRunningData(runningData)) {
        final reasons =
            AIAnalysisDataCollector.getRunningValidationFailureReasons(
                runningData);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showDataIncompleteDialog(reasons);
        }
        return;
      }

      // 4. 러닝 전문 프롬프트 생성
      final prompt = AIPromptBuilder.buildRunningPrompt(runningData);

      // 5. OpenAI GPT-5 API 호출 (러닝 전문가 분석)
      final aiResponse = await OpenAIService.instance.createChatCompletion(
        systemPrompt: '당신은 15년 경력의 전문 러닝 코치입니다.',
        userPrompt: prompt,
        temperature: 0.7, // 전문적이면서 약간의 창의성
        maxTokens: 2000, // 10개 섹션 상세 분석을 위해 충분한 토큰 할당
        topP: 0.95,
      );

      // 6. AI 응답 처리
      if (aiResponse == null || aiResponse.isEmpty) {
        throw Exception('AI 분석 응답이 비어있습니다.');
      }

      // 7. 포인트 차감 (성공 시에만)
      ref.read(globalPointProvider.notifier).addPoints(
            -30,
            'AI 러닝 분석 - $_selectedCategory 카테고리',
            type: PointTransactionType.spent,
          );

      // 8. 분석 결과 생성
      final analysisResult = AchievementAnalysisModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory!,
        relatedGoalIds: (runningData['goals'] as List)
            .map((g) => g.id as String)
            .toList(),
        relatedRoutineIds: (runningData['routines'] as List)
            .map((r) => r.id as String)
            .toList(),
        analysisContent: aiResponse,
        analyzedAt: DateTime.now(),
      );

      // 9. 로딩 중지 및 결과 표시
      if (mounted) {
        setState(() {
          _analysisResult = analysisResult;
          _isLoading = false;
        });
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI 분석 중 오류가 발생했습니다: $e',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: ModernColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  /// 데이터 부족 다이얼로그 표시
  void _showDataIncompleteDialog(List<String> reasons) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          '데이터 부족',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI 분석을 위한 데이터가 부족합니다:',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ...reasons.map((reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: ModernColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          reason,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: ModernColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: ModernColors.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                '확인',
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.w700,
                  color: ModernColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// AI 링 페인터 (ai_analysis_loading_widget 스타일)
class _AIRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 여러 개의 호 그리기
    const arcCount = 4;
    const arcLength = math.pi / 3;
    const gap = (2 * math.pi - arcCount * arcLength) / arcCount;

    for (int i = 0; i < arcCount; i++) {
      final startAngle = i * (arcLength + gap);

      paint.shader = SweepGradient(
        colors: [
          ModernColors.primary.withValues(alpha: 0.0),
          ModernColors.primary,
          ModernColors.primary.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        startAngle: startAngle,
        endAngle: startAngle + arcLength,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcLength,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
