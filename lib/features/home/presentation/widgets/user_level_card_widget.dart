import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/models/user_level_progress.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';

class UserLevelCardWidget extends ConsumerStatefulWidget {
  const UserLevelCardWidget({super.key});

  @override
  ConsumerState<UserLevelCardWidget> createState() => _UserLevelCardWidgetState();
}

class _UserLevelCardWidgetState extends ConsumerState<UserLevelCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final progressData = ref.watch(userLevelProgressProvider);
    // ✅ 글로벌 칭호 데이터 가져오기 (검색 결과[3-4] Provider 패턴)
    final userTitle = ref.watch(globalUserTitleProvider);

    if (user == null) {
      return _buildLoadingCard(context);
    }

    final isNearLevelUp = progressData.progress >= 0.9;

    if (isNearLevelUp && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isNearLevelUp && _pulseController.isAnimating) {
      _pulseController.stop(canceled: false);
    }

    return _buildCardContent(context, user, progressData, userTitle);
  }

  // ✅ 메서드 시그니처에 titleState 추가
  Widget _buildCardContent(BuildContext context, GlobalUser user, UserLevelProgress progressData, UserTitle userTitle) {
    // ✅ 글로벌 데이터 기반 칭호 계산 (검색 결과[5-6] 상태 관리 패턴)
    final userTitleText = _getUserTitle(user.level, userTitle);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey[200] ?? Colors.grey, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildProfileAvatar(user.level),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        user.name,
                        style: GoogleFonts.notoSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5
                        )
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)
                      ),
                      // ✅ 글로벌 데이터 기반 칭호 표시 (메모리[8-9] 등반 배지 시스템)
                      child: Text(
                          userTitleText,
                          style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildExperienceBar(context, progressData),
        ],
      ),
    );
  }

  // ✅ 글로벌 데이터 기반 칭호 계산 메서드 (검색 결과[7] Provider 로직)
  String _getUserTitle(int userLevel, UserTitle userTitle) {
    // 1. 먼저 titleState에서 활성 칭호 확인
    if (userTitle.title.isNotEmpty) {
      return userTitle.title;
    }

    // 2. titleState가 비어있으면 GameConstants에서 레벨 기반 칭호 계산
    try {
      return GameConstants.getTitleName(userLevel);
    } catch (e) {
      // 3. GameConstants에 getTitleName이 없으면 기본 칭호 시스템 사용
      return _getDefaultTitleByLevel(userLevel);
    }
  }

  // ✅ 기본 칭호 시스템 (메모리[8] 등반 배지 전문성 반영)
  String _getDefaultTitleByLevel(int level) {
    if (level >= 30) {
      return '셰르파';
    } else if (level >= 20) {
      return '전문 산악인';
    } else if (level >= 10) {
      return '숙련된 등반가';
    } else {
      return '초보 등반가';
    }
  }

  Widget _buildProfileAvatar(int level) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1
              )
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle
            ),
            child: Center(
                child: Text(
                    '👨‍🎓',
                    style: TextStyle(
                        fontSize: 42,
                        shadows: [
                          Shadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 4
                          )
                        ]
                    )
                )
            ),
          ),
        ),
        Positioned(
          bottom: -5,
          right: -5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: AppColors.accent.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1
                )
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
                'Lv.$level',
                style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white
                )
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceBar(BuildContext context, UserLevelProgress progressData) {
    final bool isNearLevelUp = progressData.progress >= 0.9;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                '경험치',
                style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary
                )
            ),
            Text(
                '${progressData.currentLevelExp} / ${progressData.requiredExpForNextLevel} XP',
                style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary
                )
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
                height: 14,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)
                )
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: constraints.maxWidth * progressData.progress,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: isNearLevelUp ? AppColors.accentGradient : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isNearLevelUp)
              Text(
                  '🔥 레벨업 임박!',
                  style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentDark
                  )
              ),
            if (isNearLevelUp) const Spacer(),
            Text(
                '다음 레벨까지 ${progressData.requiredExpForNextLevel - progressData.currentLevelExp} XP',
                style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500
                )
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 42),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 150, height: 24, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 20, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                )
            ),
          ],
        ),
      ),
    );
  }
}
