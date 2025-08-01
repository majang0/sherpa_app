import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/available_meeting_model.dart';

/// 📝 모임 참여 조건 및 준비물 위젯
class MeetingRequirementsWidget extends StatelessWidget {
  final AvailableMeeting meeting;

  const MeetingRequirementsWidget({
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
            '📝 참여 안내',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 준비물 섹션
          _buildRequirementsSection(),
          
          const SizedBox(height: 20),
          
          // 참여 조건 섹션  
          _buildConditionsSection(),
          
          const SizedBox(height: 20),
          
          // 주의사항 섹션
          _buildNoticesSection(),
        ],
      ),
    );
  }

  /// 🎒 준비물 섹션
  Widget _buildRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.backpack_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '준비물',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        if (meeting.requirements.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
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
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '특별한 준비물이 필요하지 않아요',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        else
          ...meeting.requirements.map((requirement) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    requirement,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
      ],
    );
  }

  /// ✅ 참여 조건 섹션
  Widget _buildConditionsSection() {
    final conditions = _getConditions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.rule_rounded,
                size: 16,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '참여 조건',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        ...conditions.map((condition) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  condition,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// ⚠️ 주의사항 섹션
  Widget _buildNoticesSection() {
    final notices = _getNotices();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '주의사항',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        ...notices.map((notice) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notice,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// 참여 조건 목록 생성
  List<String> _getConditions() {
    final conditions = <String>[];
    
    // 기본 조건
    conditions.add('모임 시간 10분 전까지 도착');
    conditions.add('다른 참가자들과 친근하게 대화');
    
    // 카테고리별 조건
    switch (meeting.category) {
      case MeetingCategory.exercise:
        conditions.add('운동 가능한 복장 착용');
        conditions.add('본인의 체력 수준 고려');
        break;
      case MeetingCategory.study:
        conditions.add('적극적인 토론 참여');
        conditions.add('필기도구 지참');
        break;
      case MeetingCategory.reading:
        conditions.add('해당 책 미리 읽고 참석');
        conditions.add('토론 주제 1개 이상 준비');
        break;
      case MeetingCategory.networking:
        conditions.add('명함 또는 자기소개 준비');
        conditions.add('적극적인 네트워킹 참여');
        break;
      case MeetingCategory.culture:
        conditions.add('시간 엄수');
        conditions.add('관람 예절 준수');
        break;
      case MeetingCategory.outdoor:
        conditions.add('날씨에 맞는 복장');
        conditions.add('안전 수칙 준수');
        break;
      case MeetingCategory.all:
      default:
        conditions.add('모임 주제에 관심과 열정');
    }
    
    // 유료 모임 조건
    if (meeting.type == MeetingType.paid) {
      conditions.add('별도 참가비 현장 결제');
    }
    
    return conditions;
  }

  /// 주의사항 목록 생성
  List<String> _getNotices() {
    final notices = <String>[
      '모임 시간 변경이나 취소 시 24시간 전 공지',
      '무단 불참 시 향후 모임 참여에 제한이 있을 수 있음',
      '모임 중 촬영된 사진은 홍보용으로 사용될 수 있음',
    ];
    
    // 카테고리별 주의사항
    switch (meeting.category) {
      case MeetingCategory.exercise:
        notices.add('운동 중 부상 발생 시 개인 책임');
        notices.add('컨디션이 좋지 않을 때는 무리하지 말 것');
        break;
      case MeetingCategory.study:
        notices.add('시끄럽게 하거나 다른 사람에게 방해되는 행동 금지');
        break;
      case MeetingCategory.reading:
        notices.add('해당 책을 미리 읽지 않으면 토론 참여 불가');
        break;
      case MeetingCategory.networking:
        notices.add('과도한 영업이나 홍보 활동 자제');
        break;
      case MeetingCategory.culture:
        notices.add('공연 중 휴대폰 무음 필수');
        notices.add('중간 퇴장 금지');
        break;
      case MeetingCategory.outdoor:
        notices.add('날씨 악화 시 일정 변경 가능');
        notices.add('안전사고 발생 시 개인 책임');
        break;
      case MeetingCategory.all:
      default:
        break;
    }
    
    // 학교 모임 주의사항
    if (meeting.scope == MeetingScope.university) {
      notices.add('같은 학교 학생만 참여 가능');
      notices.add('학생증 지참 필수');
    }
    
    return notices;
  }
}
