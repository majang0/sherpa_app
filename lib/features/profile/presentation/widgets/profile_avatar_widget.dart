import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ 글로벌 데이터 시스템 Import
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileAvatarWidget extends ConsumerWidget {
  final GlobalUser user;
  final double size;
  final bool showLevelBadge;
  final VoidCallback? onTap;

  const ProfileAvatarWidget({
    Key? key,
    required this.user,
    this.size = 60,
    this.showLevelBadge = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTitle = ref.watch(globalUserTitleProvider);
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 메인 아바타
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildDefaultAvatar(),
          ),

          // 레벨 배지
          if (showLevelBadge)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: size * 0.35,
                height: size * 0.35,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${user.level}', // ✅ GlobalUser.level 사용
                    style: GoogleFonts.notoSans(
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // 온라인 상태 표시 (선택사항)
          if (size > 40)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: size * 0.2,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '셰', // ✅ GlobalUser.name 사용
        style: GoogleFonts.notoSans(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
