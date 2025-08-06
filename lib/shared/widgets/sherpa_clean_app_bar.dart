import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ 글로벌 데이터 시스템 Import
import '../../core/constants/app_colors.dart';
import '../providers/global_user_provider.dart';
import '../providers/global_point_provider.dart';
import '../providers/global_user_title_provider.dart';
import '../../features/profile/presentation/screens/my_info_screen.dart';
import '../../features/shop/presentation/screens/enhanced_point_shop_screen.dart';

class SherpaCleanAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onProfileTap;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SherpaCleanAppBar({
    Key? key,
    this.title,
    this.showBackButton = false,
    this.onProfileTap,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<SherpaCleanAppBar> createState() => _SherpaCleanAppBarState();
}

class _SherpaCleanAppBarState extends ConsumerState<SherpaCleanAppBar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _notificationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _notificationAnimation;

  @override
  void initState() {
    super.initState();

    // 초록색 불빛 펄스 애니메이션
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // 알림 빨간 불빛 애니메이션
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _notificationAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _notificationController, curve: Curves.easeInOut),
    );
    _notificationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 글로벌 데이터 시스템에서 데이터 가져오기
    final user = ref.watch(globalUserProvider);
    final pointData = ref.watch(globalPointProvider);
    final userTitle = ref.watch(globalUserTitleProvider);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,

      // ✅ 왼쪽: 프로필 아바타 + 초록색 불빛 + 네비게이션
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // ✅ 프로필 터치 시 내정보 화면으로 이동
            if (widget.onProfileTap != null) {
              widget.onProfileTap!();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyInfoScreen(),
                ),
              );
            }
          },
          child: Stack(
            children: [
              // 프로필 아바타
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '셰',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),

              // ✅ 초록색 온라인 불빛 (애니메이션)
              Positioned(
                right: 2,
                bottom: 2,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: _pulseAnimation.value),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ 중앙: 사용자 정보 + 레벨 표시 (실제 데이터 사용)
      title: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 인사말
            Text(
              '안녕하세요! 👋',
              style: GoogleFonts.notoSans(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),

            // 닉네임 + 레벨 배지
            Row(
              children: [
                Flexible(
                  child: Text(
                    user.name, // ✅ 실제 사용자 이름
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),

                // ✅ 레벨 배지 (실제 레벨 데이터)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Level ${user.level}', // ✅ 실제 레벨 데이터
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
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

      // ✅ 오른쪽: 컴포넌트 뷰어 + 알림 + 포인트 + 네비게이션
      actions: [
        // ✅ 컴포넌트 뷰어 버튼
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, '/component_viewer');
          },
          icon: Icon(
            Icons.widgets_outlined,
            color: Colors.grey[600],
            size: 22,
          ),
        ),

        // ✅ 알림 버튼 + 빨간 불빛
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showNotificationDialog(context);
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey[600],
                  size: 22,
                ),
              ),

              // ✅ 빨간 알림 불빛 (애니메이션)
              Positioned(
                right: 8,
                top: 8,
                child: AnimatedBuilder(
                  animation: _notificationAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: _notificationAnimation.value),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ✅ 포인트 버튼 + 네비게이션 (실제 포인트 데이터)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              // ✅ 포인트 터치 시 포인트샵으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnhancedPointShopScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${pointData.totalPoints.toInt()}P', // ✅ 실제 포인트 데이터
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Stack(
              children: [
                Icon(Icons.notifications, color: AppColors.primary, size: 24),
                // 빨간 불빛 표시
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              '알림',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            // 새 알림 개수 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '3',
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem('🎉', '레벨업!', 'Level 12에 도달했습니다!', '방금 전', true),
            _buildNotificationItem('💪', '퀘스트 완료', '운동 퀘스트를 완료했습니다', '1시간 전', true),
            _buildNotificationItem('👥', '모임 알림', '아침 운동 모임이 곧 시작됩니다', '2시간 전', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '닫기',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('전체보기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String emoji, String title, String content, String time, bool isNew) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isNew
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: isNew
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // 새 알림 표시
                    if (isNew)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Text(
                  content,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.notoSans(
              fontSize: 8,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
