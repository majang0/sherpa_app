import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ 글로벌 데이터 시스템 Import
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../core/constants/app_colors.dart';

class LevelBadgeWidget extends ConsumerWidget {
  final GlobalUser user;
  final bool isCompact;
  final VoidCallback? onTap;

  const LevelBadgeWidget({
    Key? key,
    required this.user,
    this.isCompact = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTitle = ref.watch(globalUserTitleProvider);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 레벨 아이콘
            Container(
              width: isCompact ? 16 : 20,
              height: isCompact ? 16 : 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
              ),
              child: Center(
                child: Icon(
                  Icons.star,
                  size: isCompact ? 10 : 12,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: isCompact ? 4 : 6),

            // 레벨 텍스트
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level ${user.level}', // ✅ GlobalUser.level 사용
                  style: GoogleFonts.notoSans(
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (!isCompact)
                  Text(
                    userTitle.title, // ✅ 실제 칭호 데이터 사용
                    style: GoogleFonts.notoSans(
                      fontSize: 8,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),

            // 뱃지들 (보유 뱃지 개수 표시)
            if (user.ownedBadgeIds.isNotEmpty && !isCompact) ...[
              SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${user.ownedBadgeIds.length}🏆', // ✅ 실제 뱃지 개수
                  style: GoogleFonts.notoSans(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
