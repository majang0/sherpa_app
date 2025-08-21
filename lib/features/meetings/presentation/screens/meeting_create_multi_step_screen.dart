import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
// import '../../../../shared/widgets/sherpa_clean_app_bar.dart'; // 사용하지 않음
import '../../providers/meeting_creation_provider.dart';
import '../widgets/meeting_creation_steps/step_1_category_selection.dart';
import '../widgets/meeting_creation_steps/step_2_visibility_location.dart';
import '../widgets/meeting_creation_steps/step_3_participants_pricing.dart';
import '../widgets/meeting_creation_steps/step_4_details_photo.dart';

/// 🎯 모임 개설 4단계 플로우 메인 스크린
/// 한국 모임 앱 스타일의 단계별 진행 방식 구현
class MeetingCreateMultiStepScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MeetingCreateMultiStepScreen> createState() => _MeetingCreateMultiStepScreenState();
}

class _MeetingCreateMultiStepScreenState extends ConsumerState<MeetingCreateMultiStepScreen> 
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  
  int _currentStep = 0;
  final int _totalSteps = 4;
  
  // 단계별 제목들
  final List<String> _stepTitles = [
    '어떤 모임을 만들고 싶나요?',
    '모임 성격을 설정해주세요',
    '참여 조건을 정해주세요', 
    '모임 정보를 완성해주세요',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // 초기 진행률 설정
    _updateProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final targetProgress = (_currentStep + 1) / _totalSteps;
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: targetProgress,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    _progressAnimationController.forward(from: 0);
  }

  void _nextStep() {
    // 현재 단계 유효성 검사
    final validationError = ref.read(meetingCreationProvider.notifier)
        .validateStep(_currentStep + 1);
    
    if (validationError != null) {
      _showValidationError(validationError);
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    } else {
      // 마지막 단계에서 모임 생성 완료
      _completeMeetingCreation();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _completeMeetingCreation() {
    final meetingData = ref.read(meetingCreationProvider);
    
    if (!meetingData.isAllDataValid()) {
      _showValidationError('모든 정보를 올바르게 입력해주세요');
      return;
    }

    // TODO: 실제 모임 생성 로직 구현
    // 현재는 성공 다이얼로그만 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '모임 개설 완료!',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${meetingData.title} 모임이 성공적으로 개설되었습니다!\n다른 사용자들이 참가할 수 있도록 모임을 홍보해보세요.',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // 상태 초기화
                    ref.read(meetingCreationProvider.notifier).reset();
                    
                    Navigator.pop(context); // 다이얼로그 닫기
                    Navigator.pop(context); // 모임 개설 화면 닫기
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Text(
                      '확인',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '모임 개설',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              // 첫 번째 단계에서 나가기 확인
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(
                    '모임 개설 취소',
                    style: GoogleFonts.notoSans(fontWeight: FontWeight.w700),
                  ),
                  content: Text(
                    '작성 중인 내용이 사라집니다.\n정말 취소하시겠습니까?',
                    style: GoogleFonts.notoSans(height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('계속 작성'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(meetingCreationProvider.notifier).reset();
                        Navigator.pop(context); // 다이얼로그 닫기
                        Navigator.pop(context); // 모임 개설 화면 닫기
                      },
                      child: Text('취소', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // 단계 표시
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentStep + 1}/$_totalSteps',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행률 표시 영역
          _buildProgressSection(),
          
          // 메인 콘텐츠 영역
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
              children: [
                Step1CategorySelection(),
                Step2VisibilityLocation(),
                Step3ParticipantsPricing(),
                Step4DetailsPhoto(),
              ],
            ),
          ),
          
          // 하단 네비게이션 버튼들
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 진행률 바
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isCompleted || isCurrent 
                        ? AppColors.primary 
                        : AppColors.primary.withOpacity(0.2),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      if (isCurrent) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                              stops: [_progressAnimation.value, _progressAnimation.value],
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // 현재 단계 제목
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _stepTitles[_currentStep],
              key: ValueKey(_currentStep),
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 이전 버튼
            if (_currentStep > 0) ...[
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _previousStep,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          '이전',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            // 다음/완료 버튼
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _nextStep,
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep < _totalSteps - 1 ? '다음' : '완료',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (_currentStep < _totalSteps - 1) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ] else ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}