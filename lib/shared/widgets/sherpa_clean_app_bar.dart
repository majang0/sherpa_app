import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

// ✅ 글로벌 데이터 시스템 Import
import '../../core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_point_provider.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_title_provider.dart';
import 'package:sherpa_app/shared/providers/lazy_loaded/notification_provider.dart';
import '../widgets/notification_item_widget.dart';
import '../../features/profile/presentation/screens/my_info_screen.dart';
import '../../features/profile/shop/presentation/screens/enhanced_point_shop_screen.dart';
import '../notification/screens/notification_screen.dart';

class SherpaCleanAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onProfileTap;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SherpaCleanAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.onProfileTap,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  });

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
    final unreadCount = ref.watch(unreadNotificationCountProvider);

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
                  builder: (context) => const MyInfoScreen(),
                ),
              );
            }
          },
          child: Stack(
            children: [
              // 프로필 아바타 (이미지 지원 추가)
              CircleAvatar(
                radius: 20,
                backgroundColor: ModernColors.primary,
                backgroundImage: _getProfileImage(user.profileImageUrl),
                child: _getProfileImage(user.profileImageUrl) == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '셰',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                    : null,
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
                        color: ModernColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: ModernColors.success
                                .withValues(alpha: _pulseAnimation.value),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: ModernColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
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
                  _showNotificationPreview(context);
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey[600],
                  size: 22,
                ),
              ),

              // ✅ 빨간 알림 불빛 (읽지 않은 알림이 있을 때만)
              if (unreadCount > 0)
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
                          color: ModernColors.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ModernColors.error.withValues(
                                  alpha: _notificationAnimation.value),
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
                  builder: (context) => const EnhancedPointShopScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.accent,
                    ModernColors.accent.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.accent.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
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

  // 프로필 이미지 처리 헬퍼 메서드
  ImageProvider? _getProfileImage(String? profileImageUrl) {
    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      return null;
    }

    // 로컬 파일 경로인지 확인
    if (profileImageUrl.startsWith('/') ||
        profileImageUrl.contains(':\\') ||
        !profileImageUrl.startsWith('http')) {
      // 로컬 파일
      final file = File(profileImageUrl);
      if (file.existsSync()) {
        return FileImage(file);
      }
      return null;
    } else {
      // 네트워크 이미지
      return NetworkImage(profileImageUrl);
    }
  }

  // 알림 미리보기 다이얼로그 표시
  void _showNotificationPreview(BuildContext context) {
    final notifications = ref.read(notificationProvider);
    final unreadNotifications =
        notifications.where((n) => !n.isRead).take(3).toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        elevation: 2,
        child: Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.5, // 0.6 → 0.5로 축소
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ModernColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: ModernColors.background,
                  border: Border(
                    bottom: BorderSide(
                      color: ModernColors.borderLight,
                      width: 1,
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: ModernColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '알림',
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          if (unreadNotifications.isNotEmpty)
                            Text(
                              '읽지 않은 알림 ${unreadNotifications.length}개',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: ModernColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: ModernColors.textTertiary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // 알림 목록
              if (unreadNotifications.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: ModernColors.gray100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 40,
                          color: ModernColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '새로운 알림이 없습니다',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '활동을 완료하면 여기에 알림이 표시됩니다',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: ModernColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: unreadNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = unreadNotifications[index];
                      return NotificationItemWidget(
                        notification: notification,
                        showDetail: false, // 프리뷰에서는 상세 내용 숨김
                        onTap: () {
                          // 읽음 처리
                          ref
                              .read(notificationProvider.notifier)
                              .markAsRead(notification.id);
                          // 다이얼로그 닫고 전체보기로 이동
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                        // 미리보기에서는 스와이프 삭제 비활성화
                        onDismiss: null,
                      );
                    },
                  ),
                ),

              // 전체보기 버튼
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: ModernColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.view_list_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '전체 알림 보기',
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
