import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../models/available_meeting_model.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../widgets/satisfaction_rating_widget.dart';
import '../widgets/mood_selector_widget.dart';

/// 🌟 모임 만족도 평가 화면
/// 모임 참여 후 후기 작성 및 최종 보상 획득
class MeetingReviewScreen extends ConsumerStatefulWidget {
  final AvailableMeeting meeting;

  const MeetingReviewScreen({
    super.key,
    required this.meeting,
  });

  @override
  ConsumerState<MeetingReviewScreen> createState() => _MeetingReviewScreenState();
}

class _MeetingReviewScreenState extends ConsumerState<MeetingReviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double _satisfaction = 4.0;
  String _selectedMood = 'happy';
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // 🚫 화면 진입 시 셰르피 안내 제거 - 단순 화면 진입은 조용히 처리
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(sherpiProvider.notifier).showMessage(
    //     context: SherpiContext.encouragement,
    //     emotion: SherpiEmotion.cheering,
    //     userContext: {
    //       'screen': 'meeting_review',
    //       'meeting_title': widget.meeting.title,
    //     },
    //   );
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SherpaCleanAppBar(
        title: '모험 후기',
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🎨 헤더
                    _buildHeader(),
                    
                    const SizedBox(height: 30),
                    
                    // ⭐ 만족도 평가
                    _buildSatisfactionSection(),
                    
                    const SizedBox(height: 30),
                    
                    // 😊 기분 선택
                    _buildMoodSection(),
                    
                    const SizedBox(height: 30),
                    
                    // 📝 한마디 작성
                    _buildNoteSection(),
                    
                    const SizedBox(height: 30),
                    
                    // 🎁 추가 보상 안내
                    _buildBonusRewardSection(),
                    
                    const SizedBox(height: 100), // 하단 버튼 공간
                  ],
                ),
              ),
            ),
          );
        },
      ),
      
      // 🎯 하단 제출 버튼
      bottomNavigationBar: _buildSubmitBar(),
    );
  }

  /// 🎨 헤더
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.meeting.category.color.withValues(alpha: 0.1),
            widget.meeting.category.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.meeting.category.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.meeting.category.color,
                  widget.meeting.category.color.withValues(alpha: 0.8),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.meeting.category.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '🌟 모험은 어떠셨나요?',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.meeting.title,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.meeting.category.color,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '여러분의 소중한 후기가 다른 모험가들에게 큰 도움이 돼요!',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// ⭐ 만족도 평가 섹션
  Widget _buildSatisfactionSection() {
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
            '⭐ 만족도 평가',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          SatisfactionRatingWidget(
            rating: _satisfaction,
            onRatingChanged: (rating) {
              setState(() {
                _satisfaction = rating;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          Text(
            _getSatisfactionText(_satisfaction),
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getSatisfactionColor(_satisfaction),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 😊 기분 선택 섹션
  Widget _buildMoodSection() {
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
            '😊 지금 기분은?',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          MoodSelectorWidget(
            selectedMood: _selectedMood,
            onMoodChanged: (mood) {
              setState(() {
                _selectedMood = mood;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 📝 한마디 작성 섹션
  Widget _buildNoteSection() {
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
            '📝 한마디 남기기',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '모임에 대한 소감을 자유롭게 적어주세요 (선택사항)',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _noteController,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '예) 새로운 친구들을 만나서 즐거웠어요!',
              hintStyle: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎁 추가 보상 안내 섹션
  Widget _buildBonusRewardSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.1),
            AppColors.success.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎁 후기 작성 보너스',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '후기를 작성하면 추가 경험치와 능력치를 받아요!',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 보상 미리보기
          Row(
            children: [
              Expanded(
                child: _buildBonusItem('⭐', '경험치', '+25'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBonusItem('🔥', '의지력', '+0.1'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBonusItem(String icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 하단 제출 바
  Widget _buildSubmitBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.meeting.category.color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '후기 완성하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// 🎯 후기 제출 처리
  Future<void> _handleSubmitReview() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 글로벌 시스템을 통한 후기 완료 처리
      ref.read(globalMeetingProvider.notifier).completeMeetingReview(
        meetingId: widget.meeting.id,
        satisfaction: _satisfaction,
        mood: _selectedMood,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      // 성공 시 홈으로 이동
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/', // 홈으로 이동
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('후기 작성 완료! 추가 보상을 받았어요! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('후기 제출에 실패했습니다: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getSatisfactionText(double rating) {
    if (rating >= 4.5) return '정말 만족해요! 🤩';
    if (rating >= 4.0) return '만족해요! 😊';
    if (rating >= 3.5) return '괜찮았어요 🙂';
    if (rating >= 3.0) return '보통이에요 😐';
    if (rating >= 2.5) return '아쉬워요 😔';
    return '별로였어요 😞';
  }

  Color _getSatisfactionColor(double rating) {
    if (rating >= 4.0) return AppColors.success;
    if (rating >= 3.0) return AppColors.warning;
    return AppColors.error;
  }
}
