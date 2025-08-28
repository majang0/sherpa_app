import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/modern_colors.dart';
import '../models/notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool showDetail;

  const NotificationItemWidget({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.showDetail = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // timeago 한국어 설정
    timeago.setLocaleMessages('ko', timeago.KoMessages());
    
    return Dismissible(
      key: Key(notification.id),
      direction: onDismiss != null ? DismissDirection.endToStart : DismissDirection.none,
      onDismissed: onDismiss != null ? (_) => onDismiss!() : null,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ModernColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: ModernColors.error,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          margin: EdgeInsets.only(bottom: showDetail ? 12 : 8),  // 프리뷰에서는 마진 축소
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.white
                : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead 
                  ? ModernColors.borderLight
                  : ModernColors.primary.withValues(alpha: 0.3),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: notification.isRead 
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: ModernColors.primary.withValues(alpha: 0.15),
                    blurRadius: 0,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
          ),
          child: Padding(
            padding: EdgeInsets.all(showDetail ? 16 : 12),  // 프리뷰에서는 패딩 축소
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 (아이콘, 제목, 시간)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 아이콘
                    Stack(
                      children: [
                        Container(
                          width: showDetail ? 40 : 36,  // 프리뷰에서는 크기 축소
                          height: showDetail ? 40 : 36,
                          decoration: BoxDecoration(
                            color: notification.isRead 
                                ? notification.type.color.withValues(alpha: 0.08)
                                : notification.type.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: notification.isRead
                                  ? notification.type.color.withValues(alpha: 0.2)
                                  : notification.type.color.withValues(alpha: 0.3),
                              width: notification.isRead ? 1 : 1.5,
                            ),
                          ),
                          child: Icon(
                            notification.type.icon,
                            color: notification.isRead
                                ? notification.type.color.withValues(alpha: 0.8)
                                : notification.type.color,
                            size: showDetail ? 20 : 18,  // 프리뷰에서는 크기 축소
                          ),
                        ),
                        if (!notification.isRead)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: ModernColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    
                    // 제목과 메시지
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 제목과 읽지 않음 표시
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: ModernColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (!notification.isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ModernColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: showDetail ? 4 : 2),  // 프리뷰에서는 간격 축소
                          
                          // 메시지
                          Text(
                            notification.message,
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ModernColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                          
                          // 상세 내용 (showDetail이 true일 때만)
                          if (showDetail && notification.detail != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
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
                                  fontSize: 12,
                                  color: ModernColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          
                          // 메타데이터 표시
                          if (notification.metadata != null && notification.metadata!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _buildMetadataChips(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                // 시간 표시
                SizedBox(height: showDetail ? 8 : 6),  // 프리뷰에서는 간격 축소
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: notification.isRead 
                              ? ModernColors.textTertiary
                              : ModernColors.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeago.format(notification.createdAt, locale: 'ko'),
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                            color: notification.isRead 
                                ? ModernColors.textTertiary
                                : ModernColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    
                    // 화살표 아이콘 (탭 가능한 경우)
                    if (onTap != null && !showDetail)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: notification.isRead 
                              ? Colors.transparent
                              : ModernColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: notification.isRead 
                              ? ModernColors.textTertiary
                              : ModernColors.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 메타데이터 칩 생성
  List<Widget> _buildMetadataChips() {
    final chips = <Widget>[];
    final metadata = notification.metadata!;
    
    // XP (경험치)
    if (metadata['xp'] != null) {
      chips.add(_buildChip(
        icon: Icons.trending_up,  // 퀘스트 완료창과 동일한 아이콘
        label: '${metadata['xp']} XP',
        color: ModernColors.primary,
      ));
    }
    
    // 포인트
    if (metadata['points'] != null) {
      chips.add(_buildChip(
        icon: Icons.monetization_on,  // 퀘스트 완료창과 동일한 아이콘
        label: '${metadata['points']}P',
        color: ModernColors.warning,
      ));
    }
    
    // 보상 타입
    if (metadata['reward'] != null) {
      String rewardLabel = '';
      switch (metadata['reward']) {
        case 'bronze_chest':
          rewardLabel = '브론즈 상자';
          break;
        case 'silver_chest':
          rewardLabel = '실버 상자';
          break;
        case 'gold_chest':
          rewardLabel = '골드 상자';
          break;
        default:
          rewardLabel = metadata['reward'];
      }
      chips.add(_buildChip(
        icon: Icons.card_giftcard_rounded,
        label: rewardLabel,
        color: ModernColors.accent,
      ));
    }
    
    // 참가자 수
    if (metadata['participants'] != null) {
      chips.add(_buildChip(
        icon: Icons.group_rounded,
        label: '${metadata['participants']}명',
        color: ModernColors.success,
      ));
    }
    
    // 고도
    if (metadata['altitude'] != null) {
      chips.add(_buildChip(
        icon: Icons.terrain_rounded,
        label: '${metadata['altitude']}m',
        color: ModernColors.primary,
      ));
    }
    
    return chips;
  }
  
  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}