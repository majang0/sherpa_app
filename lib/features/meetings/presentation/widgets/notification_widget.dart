// lib/features/meetings/presentation/widgets/notification_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../models/notification_model.dart';

/// 🔔 실시간 알림 위젯 - 한국형 프리미엄 알림 시스템
/// 스마트한 우선순위 + 맞춤형 액션 + 직관적인 UI
class NotificationWidget extends ConsumerStatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const NotificationWidget({
    super.key,
    this.isExpanded = false,
    this.onToggleExpanded,
  });

  @override
  ConsumerState<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends ConsumerState<NotificationWidget>
    with TickerProviderStateMixin {
  
  // 🎯 상태 관리
  NotificationFilter _selectedFilter = NotificationFilter.all;
  final Set<String> _dismissedNotifications = {};
  final Set<String> _readNotifications = {};
  
  // 🎨 애니메이션
  late AnimationController _badgeAnimationController;
  late Animation<double> _badgeAnimation;
  late AnimationController _refreshAnimationController;
  
  // 📊 알림 데이터
  List<NotificationItem> _notifications = [];
  NotificationStats _stats = const NotificationStats(
    totalCount: 0,
    unreadCount: 0,
    todayCount: 0,
    typeCounts: {},
    priorityCounts: {},
  );

  @override
  void initState() {
    super.initState();
    
    // 뱃지 펄스 애니메이션
    _badgeAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _badgeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _badgeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // 새로고침 애니메이션
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 샘플 데이터 로드
    _loadNotifications();
    
    // 실시간 업데이트 시뮬레이션
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _badgeAnimationController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  /// 📊 데이터 로드
  void _loadNotifications() {
    setState(() {
      _notifications = NotificationDataGenerator.generateSampleNotifications();
      _stats = NotificationDataGenerator.generateStats(_notifications);
    });
    
    // 새 알림이 있으면 뱃지 애니메이션
    if (_stats.unreadCount > 0) {
      _badgeAnimationController.forward().then((_) {
        _badgeAnimationController.reverse();
      });
    }
  }

  /// ⚡ 실시간 업데이트
  void _startRealTimeUpdates() {
    // TODO: 실제 알림 스트림 연결
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _loadNotifications();
        _startRealTimeUpdates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📱 헤더
          _buildHeader(),
          
          // 📊 통계 (확장 모드에서만)
          if (widget.isExpanded) _buildStatsSection(),
          
          // 🏷️ 필터 탭 (확장 모드에서만)
          if (widget.isExpanded) _buildFilterTabs(),
          
          // 🔔 알림 리스트
          _buildNotificationList(filteredNotifications),
          
          // 더보기 버튼 (축소 모드에서만)
          if (!widget.isExpanded && _stats.unreadCount > 3) _buildExpandButton(),
        ],
      ),
    );
  }

  /// 📱 헤더 섹션
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 아이콘 & 제목
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.warning,
                      AppColors.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              // 읽지 않은 알림 뱃지
              if (_stats.unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: ScaleTransition(
                    scale: _badgeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        _stats.unreadCount > 99 ? '99+' : '${_stats.unreadCount}',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  _stats.unreadCount > 0 
                    ? '읽지 않은 알림 ${_stats.unreadCount}개'
                    : '모든 알림을 확인했습니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: _stats.unreadCount > 0 
                      ? AppColors.error 
                      : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // 새로고침 버튼
          RotationTransition(
            turns: _refreshAnimationController,
            child: IconButton(
              onPressed: _refreshNotifications,
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          // 설정 버튼
          IconButton(
            onPressed: _showNotificationSettings,
            icon: Icon(
              Icons.settings_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 통계 섹션
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '전체 알림',
            '${_stats.totalCount}개',
            Icons.all_inclusive_rounded,
            AppColors.primary,
          ),
          _buildStatItem(
            '읽지 않음',
            '${_stats.unreadCount}개',
            Icons.mark_email_unread_rounded,
            AppColors.error,
          ),
          _buildStatItem(
            '오늘',
            '${_stats.todayCount}개',
            Icons.today_rounded,
            AppColors.success,
          ),
          _buildStatItem(
            '중요함',
            '${_stats.importantCount}개',
            Icons.priority_high_rounded,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  /// 📊 통계 아이템
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 🏷️ 필터 탭
  Widget _buildFilterTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: NotificationFilter.values.length,
        itemBuilder: (context, index) {
          final filter = NotificationFilter.values[index];
          final isSelected = _selectedFilter == filter;
          final count = _getFilterCount(filter);
          
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = filter);
              HapticFeedback.lightImpact();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.warning : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                    ? AppColors.warning 
                    : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.displayName,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? Colors.white.withOpacity(0.2)
                          : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected 
                            ? Colors.white 
                            : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔔 알림 리스트
  Widget _buildNotificationList(List<NotificationItem> notifications) {
    final maxItems = widget.isExpanded ? notifications.length : 5;
    final displayNotifications = notifications.take(maxItems).toList();
    
    if (displayNotifications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Image.asset(
                'assets/images/sherpi/sherpi_happy.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFilter == NotificationFilter.all
                  ? '새로운 알림이 없습니다'
                  : '${_selectedFilter.displayName} 알림이 없습니다',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: displayNotifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = displayNotifications[index];
        final isRead = _readNotifications.contains(notification.id) || notification.isRead;
        final isDismissed = _dismissedNotifications.contains(notification.id);
        
        if (isDismissed) return const SizedBox.shrink();
        
        return _buildNotificationItem(notification, isRead, index);
      },
    );
  }

  /// 📄 알림 아이템
  Widget _buildNotificationItem(NotificationItem notification, bool isRead, int index) {
    final isUrgent = notification.type.priority.level >= 3;
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _dismissNotification(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onTap: () => _onNotificationTap(notification),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead 
              ? Colors.grey.shade50 
              : (isUrgent 
                ? AppColors.error.withOpacity(0.05) 
                : AppColors.primary.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead 
                ? Colors.grey.shade200 
                : (isUrgent 
                  ? AppColors.error.withOpacity(0.2) 
                  : AppColors.primary.withOpacity(0.1)),
              width: isUrgent ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 정보
              Row(
                children: [
                  // 타입 아이콘
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: notification.type.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification.type.icon,
                      size: 18,
                      color: notification.type.color,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // 시간
                            Text(
                              notification.relativeTime,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 2),
                        
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: notification.type.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                notification.type.displayName,
                                style: GoogleFonts.notoSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: notification.type.color,
                                ),
                              ),
                            ),
                            
                            if (isUrgent) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  notification.type.priority.displayName,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                            
                            if (!isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 더보기 메뉴
                  IconButton(
                    onPressed: () => _showNotificationMenu(notification),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 메시지
              Text(
                notification.message,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: widget.isExpanded ? null : 2,
                overflow: widget.isExpanded ? null : TextOverflow.ellipsis,
              ),
              
              // 이미지 (있는 경우)
              if (notification.imageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    notification.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              
              // 액션 버튼들
              if (notification.actionData.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildActionButtons(notification),
              ],
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms)
      .slideX(begin: 0.1, end: 0, delay: Duration(milliseconds: 50 * index), duration: 200.ms);
  }

  /// 🎬 액션 버튼들
  Widget _buildActionButtons(NotificationItem notification) {
    return Row(
      children: [
        // 주 액션 (알림 타입에 따라 다름)
        if (notification.type == NotificationType.meetingInvite) ...[
          _buildActionButton(
            '수락',
            AppColors.success,
            Icons.check_rounded,
            () => _acceptInvite(notification),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            '거절',
            AppColors.error,
            Icons.close_rounded,
            () => _declineInvite(notification),
          ),
        ] else if (notification.type == NotificationType.meetingReminder) ...[
          _buildActionButton(
            '참여하기',
            AppColors.primary,
            Icons.login_rounded,
            () => _joinMeeting(notification),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            '나중에',
            AppColors.textSecondary,
            Icons.schedule_rounded,
            () => _snoozeReminder(notification),
          ),
        ] else ...[
          _buildActionButton(
            '보기',
            AppColors.primary,
            Icons.visibility_rounded,
            () => _viewNotification(notification),
          ),
        ],
      ],
    );
  }

  /// 🎬 액션 버튼
  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 📂 더보기 버튼
  Widget _buildExpandButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ElevatedButton(
          onPressed: widget.onToggleExpanded,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '모든 알림 보기 (${_stats.unreadCount})',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔍 필터링된 알림 가져오기
  List<NotificationItem> _getFilteredNotifications() {
    var filtered = _notifications.where((n) => !n.isExpired).toList();
    
    switch (_selectedFilter) {
      case NotificationFilter.unread:
        filtered = filtered.where((n) => 
          !_readNotifications.contains(n.id) && !n.isRead
        ).toList();
        break;
      case NotificationFilter.meetings:
        filtered = filtered.where((n) => [
          NotificationType.meetingInvite,
          NotificationType.meetingReminder,
          NotificationType.meetingStarted,
          NotificationType.meetingCanceled,
        ].contains(n.type)).toList();
        break;
      case NotificationFilter.social:
        filtered = filtered.where((n) => [
          NotificationType.friendJoined,
          NotificationType.socialActivity,
        ].contains(n.type)).toList();
        break;
      case NotificationFilter.achievements:
        filtered = filtered.where((n) => [
          NotificationType.levelUp,
          NotificationType.badgeEarned,
        ].contains(n.type)).toList();
        break;
      case NotificationFilter.system:
        filtered = filtered.where((n) => [
          NotificationType.systemUpdate,
          NotificationType.sherpiMessage,
        ].contains(n.type)).toList();
        break;
      case NotificationFilter.all:
      default:
        break;
    }
    
    // 우선순위와 시급성으로 정렬
    filtered.sort((a, b) {
      // 읽지 않은 알림 우선
      final aUnread = !_readNotifications.contains(a.id) && !a.isRead;
      final bUnread = !_readNotifications.contains(b.id) && !b.isRead;
      if (aUnread != bUnread) return bUnread ? 1 : -1;
      
      // 긴급도 비교
      return b.urgencyScore.compareTo(a.urgencyScore);
    });
    
    return filtered;
  }

  /// 📊 필터별 카운트
  int _getFilterCount(NotificationFilter filter) {
    return _getFilteredNotifications().length;
  }

  /// 🎬 액션 함수들
  void _onNotificationTap(NotificationItem notification) {
    // 읽음 처리
    setState(() {
      _readNotifications.add(notification.id);
    });
    
    // 타입별 액션
    switch (notification.type) {
      case NotificationType.meetingInvite:
      case NotificationType.meetingReminder:
        _navigateToMeeting(notification);
        break;
      case NotificationType.levelUp:
      case NotificationType.badgeEarned:
        _showAchievementDetails(notification);
        break;
      case NotificationType.friendJoined:
        _showFriendProfile(notification);
        break;
      default:
        _viewNotification(notification);
        break;
    }
  }

  void _dismissNotification(String notificationId) {
    setState(() {
      _dismissedNotifications.add(notificationId);
      _stats = NotificationDataGenerator.generateStats(
        _notifications.where((n) => !_dismissedNotifications.contains(n.id)).toList(),
      );
    });
    
    HapticFeedback.lightImpact();
    
    // 셰르피 메시지
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.general,
      customDialogue: '알림을 삭제했어요 ✓',
      emotion: SherpiEmotion.defaults,
    );
  }

  void _refreshNotifications() {
    _refreshAnimationController.forward().then((_) {
      _refreshAnimationController.reset();
    });
    
    _loadNotifications();
    
    HapticFeedback.lightImpact();
  }

  void _acceptInvite(NotificationItem notification) {
    // TODO: 모임 초대 수락 로직
    _showSuccessMessage('모임 초대를 수락했습니다!');
    _dismissNotification(notification.id);
  }

  void _declineInvite(NotificationItem notification) {
    // TODO: 모임 초대 거절 로직
    _showSuccessMessage('모임 초대를 거절했습니다.');
    _dismissNotification(notification.id);
  }

  void _joinMeeting(NotificationItem notification) {
    // TODO: 모임 참여 로직
    _showSuccessMessage('모임에 참여했습니다!');
  }

  void _snoozeReminder(NotificationItem notification) {
    // TODO: 알림 스누즈 로직
    _showSuccessMessage('10분 후에 다시 알려드릴게요.');
    _dismissNotification(notification.id);
  }

  void _viewNotification(NotificationItem notification) {
    // TODO: 알림 상세 보기
    _showSuccessMessage('상세 내용을 확인했습니다.');
  }

  void _navigateToMeeting(NotificationItem notification) {
    // TODO: 모임 상세 화면으로 이동
    Navigator.pushNamed(
      context,
      '/meeting_detail',
      arguments: notification.relatedMeetingId,
    );
  }

  void _showAchievementDetails(NotificationItem notification) {
    // TODO: 성취 상세 화면
    _showSuccessMessage('축하합니다! 성취를 확인했습니다 🎉');
  }

  void _showFriendProfile(NotificationItem notification) {
    // TODO: 친구 프로필 화면
    _showSuccessMessage('친구 프로필을 보고 있습니다.');
  }

  void _showNotificationMenu(NotificationItem notification) {
    // TODO: 알림 옵션 메뉴
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.mark_email_read_rounded),
              title: Text('읽음으로 표시'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _readNotifications.add(notification.id));
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded),
              title: Text('삭제'),
              onTap: () {
                Navigator.pop(context);
                _dismissNotification(notification.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    // TODO: 알림 설정 화면
    _showSuccessMessage('알림 설정은 준비 중입니다!');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}