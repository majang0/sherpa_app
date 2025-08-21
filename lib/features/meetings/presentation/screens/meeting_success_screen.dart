import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../models/available_meeting_model.dart';
import '../widgets/success_confetti_widget.dart';
import '../widgets/reward_display_widget.dart';

/// 🎉 모임 참여 성공 화면
/// 참여 확정 후 축하 및 정보 안내 화면
class MeetingSuccessScreen extends ConsumerStatefulWidget {
  final AvailableMeeting meeting;

  const MeetingSuccessScreen({
    super.key,
    required this.meeting,
  });

  @override
  ConsumerState<MeetingSuccessScreen> createState() => _MeetingSuccessScreenState();
}

class _MeetingSuccessScreenState extends ConsumerState<MeetingSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    // 애니메이션 시작
    _mainAnimationController.forward();
    _confettiController.repeat();

    // 🎯 성공 셰르피 메시지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showMessage(
        context: SherpiContext.levelUp,
        emotion: SherpiEmotion.cheering,
        userContext: {
          'screen': 'meeting_success',
          'meeting_title': widget.meeting.title,
          'experience_gained': widget.meeting.experienceReward,
          'points_gained': widget.meeting.participationReward,
        },
        duration: const Duration(seconds: 6),
      );
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SherpaCleanAppBar(
        title: '참여 완료',
      ),
      body: Stack(
        children: [
          // 🎊 배경 컨페티 애니메이션
          SuccessConfettiWidget(
            controller: _confettiController,
            colors: [
              widget.meeting.category.color,
              AppColors.primary,
              AppColors.accent,
              AppColors.success,
            ],
          ),
          
          // 메인 컨텐츠
          AnimatedBuilder(
            animation: _mainAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // 🎉 성공 헤더
                        _buildSuccessHeader(),
                        
                        const SizedBox(height: 30),
                        
                        // 📊 보상 표시
                        RewardDisplayWidget(
                          meeting: widget.meeting,
                          animationController: _mainAnimationController,
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // 📋 모임 정보 요약
                        _buildMeetingInfoSummary(),
                        
                        const SizedBox(height: 30),
                        
                        // 🎯 다음 액션들
                        _buildNextActions(),
                        
                        const SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      
      // 🎯 하단 액션 버튼들
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  /// 🎉 성공 헤더
  Widget _buildSuccessHeader() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              widget.meeting.category.color.withValues(alpha: 0.2),
              widget.meeting.category.color.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          shape: BoxShape.circle,
        ),
        child: Column(
          children: [
            // 성공 아이콘
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.meeting.category.color,
                    widget.meeting.category.color.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.meeting.category.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 축하 메시지
            Text(
              '🎉 모험 참여 완료!',
              style: GoogleFonts.notoSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '${widget.meeting.title}',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: widget.meeting.category.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '모임에 성공적으로 참여했어요!\n새로운 경험과 인연을 만나보세요.',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 모임 정보 요약
  Widget _buildMeetingInfoSummary() {
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
          Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '📋 모임 일정',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 일정 정보
          _buildInfoRow(
            icon: Icons.schedule_rounded,
            label: '일시',
            value: widget.meeting.formattedDate,
            color: AppColors.primary,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            label: '장소',
            value: widget.meeting.location,
            color: AppColors.accent,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            icon: Icons.person_rounded,
            label: '호스트',
            value: widget.meeting.hostName,
            color: AppColors.success,
          ),
          
          const SizedBox(height: 16),
          
          // 알림 설정
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '모임 시작 1시간 전에 알림을 보내드릴게요!',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
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
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🎯 다음 액션들
  Widget _buildNextActions() {
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
            '🎯 다음 할 일',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 캘린더 추가
          _buildActionButton(
            icon: Icons.event_rounded,
            title: '캘린더에 추가',
            subtitle: '일정을 놓치지 않도록 캘린더에 저장하세요',
            onTap: () {
              // TODO: 캘린더 앱 연동
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('캘린더 추가 기능 (구현 예정)'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // 친구에게 공유
          _buildActionButton(
            icon: Icons.share_rounded,
            title: '친구에게 공유',
            subtitle: '함께 참여할 친구들에게 알려보세요',
            onTap: () {
              // TODO: 공유 기능
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('공유 기능 (구현 예정)'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 하단 액션 버튼들
  Widget _buildBottomActions() {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 메인 액션 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/', // 홈으로 이동
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.meeting.category.color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '홈으로 돌아가기',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 서브 액션 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/meeting_review',
                    arguments: widget.meeting,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.rate_review_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '미리 후기 작성하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
