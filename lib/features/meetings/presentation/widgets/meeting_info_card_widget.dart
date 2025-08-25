import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../models/available_meeting_model.dart';

/// 📋 모임 기본 정보 카드 위젯
class MeetingInfoCardWidget extends StatelessWidget {
  final AvailableMeeting meeting;

  const MeetingInfoCardWidget({
    super.key,
    required this.meeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 모임 정보',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 일정 정보
          _buildInfoRow(
            icon: Icons.event_rounded,
            label: '일시',
            value: meeting.formattedDate,
            color: ModernColors.primary,
          ),
          
          const SizedBox(height: 12),
          
          // 소요 시간 (반복 모임인 경우)
          if (meeting.isRecurring)
            Column(
              children: [
                _buildInfoRow(
                  icon: Icons.repeat_rounded,
                  label: '반복',
                  value: '정기 모임',
                  color: ModernColors.accent,
                ),
                const SizedBox(height: 12),
              ],
            ),
          
          // 모임 유형
          _buildInfoRow(
            icon: meeting.type == MeetingType.free 
                ? Icons.monetization_on_outlined 
                : Icons.attach_money_rounded,
            label: '유형',
            value: meeting.type.displayName,
            color: meeting.type == MeetingType.free 
                ? ModernColors.success 
                : ModernColors.warning,
          ),
          
          const SizedBox(height: 12),
          
          // 참가비 (유료 모임인 경우)
          if (meeting.type == MeetingType.paid && meeting.price != null)
            Column(
              children: [
                _buildInfoRow(
                  icon: Icons.payments_rounded,
                  label: '참가비',
                  value: '${meeting.price!.toStringAsFixed(0)}원',
                  color: ModernColors.warning,
                ),
                const SizedBox(height: 12),
              ],
            ),
          
          // 참가자 정보
          _buildInfoRow(
            icon: Icons.people_rounded,
            label: '참가자',
            value: '${meeting.currentParticipants}/${meeting.maxParticipants}명',
            color: meeting.participationRate >= 0.8 
                ? ModernColors.warning 
                : ModernColors.success,
          ),
          
          // 태그 정보
          if (meeting.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '🏷️ 태그',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: meeting.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: meeting.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: meeting.category.color,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: ModernColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
