// lib/features/meetings/presentation/widgets/meeting_creation_steps/quick_final_review.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/sherpi_emotions.dart';
import '../../../providers/meeting_creation_provider.dart';

/// ✅ 최종 검토 화면 - Step 4
/// 생성할 모임의 모든 정보를 한눈에 확인하는 요약 화면
class QuickFinalReview extends StatelessWidget {
  final MeetingCreationData data;
  final VoidCallback onComplete;

  const QuickFinalReview({
    super.key,
    required this.data,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 셰르피 축하 메시지
          _buildSherpiMessage()
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          const SizedBox(height: 24),
          
          // 모임 미리보기 카드
          _buildMeetingPreviewCard()
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          const SizedBox(height: 24),
          
          // 세부 정보
          _buildDetailsList()
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms),
          
          const SizedBox(height: 32),
          
          // 생성 완료 버튼
          _buildCompleteButton()
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .scale(delay: 300.ms, duration: 200.ms),
        ],
      ),
    );
  }

  /// 🤖 셰르피 축하 메시지
  Widget _buildSherpiMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // 셰르피 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                SherpiEmotion.cheering.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 메시지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '와! 거의 다 완성됐어요! 🎉',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '마지막으로 한 번 확인하고 모임을 만들어볼까요?',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 모임 미리보기 카드
  Widget _buildMeetingPreviewCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더 이미지
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.selectedCategory!.color.withOpacity(0.8),
                  data.selectedCategory!.color,
                ],
              ),
            ),
            child: Stack(
              children: [
                // 카테고리 이모지
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Text(
                    data.selectedCategory!.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
                
                // 카테고리 태그
                Positioned(
                  left: 20,
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.selectedCategory!.displayName,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: data.selectedCategory!.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  data.title,
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 설명
                Text(
                  data.description,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 간단한 정보
                Row(
                  children: [
                    // 날짜
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(data.dateTime!),
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // 참가비
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.price == null || data.price == 0
                        ? '무료' 
                        : '${data.price!.toInt()}P',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: data.price == null || data.price == 0
                          ? AppColors.success
                          : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 세부 정보 리스트
  Widget _buildDetailsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '모임 상세 정보',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.grey.shade200, height: 1),
          
          // 정보 항목들
          _buildDetailItem(
            icon: Icons.category_outlined,
            label: '카테고리',
            value: data.selectedCategory!.displayName,
            color: data.selectedCategory!.color,
          ),
          
          _buildDetailItem(
            icon: data.isOnline 
              ? Icons.videocam_outlined 
              : Icons.location_on_outlined,
            label: '장소',
            value: data.isOnline 
              ? '온라인 모임' 
              : (data.locationName ?? '미정'),
            color: AppColors.secondary,
          ),
          
          _buildDetailItem(
            icon: Icons.group_outlined,
            label: '최대 참가 인원',
            value: '${data.maxParticipants}명',
            color: AppColors.success,
          ),
          
          _buildDetailItem(
            icon: Icons.account_balance_wallet_outlined,
            label: '참가비',
            value: data.price == null || data.price == 0
              ? '무료 (수수료 1,000P)'
              : '${data.price!.toInt()}P',
            color: data.price == null || data.price == 0
              ? AppColors.success
              : AppColors.warning,
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 📋 세부 정보 항목
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 완료 버튼
  Widget _buildCompleteButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              '모임 만들기 완료!',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📅 날짜/시간 포맷
  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dateTime.weekday - 1];
    
    final now = DateTime.now();
    final daysDiff = DateTime(dateTime.year, dateTime.month, dateTime.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    
    String dateStr;
    if (daysDiff == 0) {
      dateStr = '오늘';
    } else if (daysDiff == 1) {
      dateStr = '내일';
    } else if (daysDiff == 2) {
      dateStr = '모레';
    } else {
      dateStr = '${dateTime.month}월 ${dateTime.day}일';
    }
    
    final period = dateTime.hour < 12 ? '오전' : '오후';
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final hourStr = hour == 0 ? 12 : hour;
    final minuteStr = dateTime.minute.toString().padLeft(2, '0');
    
    return '$dateStr ($weekday) $period ${hourStr}:${minuteStr}';
  }
}