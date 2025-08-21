import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/available_meeting_model.dart';

/// 👥 모임 참가자 정보 위젯
class MeetingParticipantsWidget extends StatelessWidget {
  final AvailableMeeting meeting;

  const MeetingParticipantsWidget({
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
            '👥 참가자 정보',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 호스트 정보
          _buildHostInfo(context),
          
          const SizedBox(height: 20),
          
          // 참가자 현황
          _buildParticipantStatus(),
          
          const SizedBox(height: 16),
          
          // 참가자 아바타 (Mock)
          _buildParticipantAvatars(),
        ],
      ),
    );
  }

  /// 🎯 호스트 정보
  Widget _buildHostInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            meeting.category.color.withValues(alpha: 0.1),
            meeting.category.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: meeting.category.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 호스트 아바타
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  meeting.category.color.withValues(alpha: 0.8),
                  meeting.category.color.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                meeting.hostName.isNotEmpty ? meeting.hostName[0] : 'H',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: meeting.category.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '👑 호스트',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  meeting.hostName,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '모임 주최자',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // 호스트 프로필 버튼
          IconButton(
            onPressed: () {
              // TODO: 호스트 프로필 보기
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${meeting.hostName} 프로필 보기 (구현 예정)'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            iconSize: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  /// 📊 참가자 현황
  Widget _buildParticipantStatus() {
    final ratio = meeting.participationRate;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '참가 현황',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${meeting.currentParticipants}/${meeting.maxParticipants}',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ratio >= 0.8 ? AppColors.warning : AppColors.success,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ratio >= 0.8 
                      ? [AppColors.warning, AppColors.warning.withValues(alpha: 0.7)]
                      : [AppColors.success, AppColors.success.withValues(alpha: 0.7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          ratio >= 0.8 
              ? '🔥 인기 모임! 마감 임박'
              : ratio >= 0.5 
                  ? '✨ 적당한 인원 모집 중'
                  : '🌟 여유롭게 참가 가능',
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ratio >= 0.8 ? AppColors.warning : AppColors.success,
          ),
        ),
      ],
    );
  }

  /// 👤 참가자 아바타들 (Mock 데이터)
  Widget _buildParticipantAvatars() {
    // Mock 참가자 데이터
    final mockParticipants = List.generate(
      meeting.currentParticipants.clamp(0, 6),
      (index) => 'User${index + 1}',
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참가자 목록',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        if (mockParticipants.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '아직 참가자가 없어요. 첫 번째 참가자가 되어보세요!',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 참가자 아바타들
              ...mockParticipants.map((participant) => _buildParticipantAvatar(participant)),
              
              // 더보기 버튼 (참가자가 6명 이상인 경우)
              if (meeting.currentParticipants > 6)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+${meeting.currentParticipants - 6}',
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildParticipantAvatar(String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.7),
            Colors.purple.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : 'U',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
