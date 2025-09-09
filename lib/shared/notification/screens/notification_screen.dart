import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_colors.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../widgets/notification_item_widget.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();
    final readNotifications = notifications.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: ModernColors.textPrimary),
        ),
        title: Text(
          '알림',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
        actions: [
          // 설정 메뉴
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  ref.read(notificationProvider.notifier).markAllAsRead();
                  _showSnackBar('모든 알림을 읽음으로 표시했습니다');
                  break;
                case 'remove_read':
                  ref.read(notificationProvider.notifier).removeReadNotifications();
                  _showSnackBar('읽은 알림을 모두 삭제했습니다');
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
              }
            },
            icon: Icon(Icons.more_vert, color: ModernColors.textSecondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              _buildPopupMenuItem(
                value: 'mark_all_read',
                icon: Icons.done_all_rounded,
                title: '모두 읽음 표시',
              ),
              _buildPopupMenuItem(
                value: 'remove_read',
                icon: Icons.clear_all_rounded,
                title: '읽은 알림 삭제',
              ),
              _buildPopupMenuItem(
                value: 'clear_all',
                icon: Icons.delete_sweep_rounded,
                title: '모든 알림 삭제',
                isDestructive: true,
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: ModernColors.primary,
          unselectedLabelColor: ModernColors.textTertiary,
          labelStyle: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          indicatorColor: ModernColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              text: '읽지 않음 (${unreadNotifications.length})',
            ),
            Tab(
              text: '모든 알림 (${notifications.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 읽지 않은 알림 탭
          _buildNotificationList(unreadNotifications, isUnreadTab: true),
          
          // 모든 알림 탭
          _buildNotificationList(notifications, isUnreadTab: false),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> notifications, {required bool isUnreadTab}) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ModernColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: ModernColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isUnreadTab ? '새로운 알림이 없습니다' : '알림이 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUnreadTab 
                  ? '새로운 활동이 있으면 여기에 표시됩니다'
                  : '활동 알림이 여기에 표시됩니다',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: ModernColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationItemWidget(
          notification: notification,
          onTap: () => _showNotificationDetail(notification),
          onDismiss: () {
            ref.read(notificationProvider.notifier).removeNotification(notification.id);
            _showSnackBar('알림을 삭제했습니다');
          },
        );
      },
    );
  }

  // 알림 상세 보기
  void _showNotificationDetail(NotificationItem notification) {
    // 읽음 처리
    if (!notification.isRead) {
      ref.read(notificationProvider.notifier).markAsRead(notification.id);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ModernColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 헤더
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: notification.type.color.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: notification.type.color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      notification.type.icon,
                      color: notification.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 상세 내용
            if (notification.detail != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ModernColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ModernColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Text(
                  notification.detail!,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: ModernColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            
            // 메타데이터
            if (notification.metadata != null && notification.metadata!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _buildDetailMetadata(notification.metadata!),
                ),
              ),
            ],
            
            // 액션 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(notificationProvider.notifier).removeNotification(notification.id);
                        Navigator.pop(context);
                        _showSnackBar('알림을 삭제했습니다');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernColors.gray100,
                        foregroundColor: ModernColors.textSecondary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '삭제',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '확인',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailMetadata(Map<String, dynamic> metadata) {
    final widgets = <Widget>[];
    
    if (metadata['points'] != null) {
      widgets.add(_buildMetadataCard(
        icon: Icons.star_rounded,
        title: '획득 포인트',
        value: '${metadata['points']}P',
        color: ModernColors.warning,
      ));
    }
    
    if (metadata['goalName'] != null) {
      widgets.add(_buildMetadataCard(
        icon: Icons.flag_rounded,
        title: '목표',
        value: metadata['goalName'],
        color: ModernColors.success,
      ));
    }
    
    if (metadata['questName'] != null) {
      widgets.add(_buildMetadataCard(
        icon: Icons.task_alt_rounded,
        title: '퀘스트',
        value: metadata['questName'],
        color: ModernColors.primary,
      ));
    }
    
    if (metadata['mountain'] != null) {
      widgets.add(_buildMetadataCard(
        icon: Icons.terrain_rounded,
        title: '등반 산',
        value: '${metadata['mountain']} (${metadata['altitude']}m)',
        color: ModernColors.accent,
      ));
    }
    
    if (metadata['meetingName'] != null) {
      widgets.add(_buildMetadataCard(
        icon: Icons.group_rounded,
        title: '모임',
        value: metadata['meetingName'],
        color: ModernColors.secondary,
      ));
    }
    
    return widgets;
  }

  Widget _buildMetadataCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  color: ModernColors.textTertiary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 모든 알림 삭제 확인 다이얼로그
  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '모든 알림 삭제',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
        content: Text(
          '모든 알림을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: ModernColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.notoSans(
                color: ModernColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(notificationProvider.notifier).clearAll();
              Navigator.pop(context);
              _showSnackBar('모든 알림을 삭제했습니다');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '삭제',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String title,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? ModernColors.error : ModernColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: isDestructive ? ModernColors.error : ModernColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(),
        ),
        backgroundColor: ModernColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}