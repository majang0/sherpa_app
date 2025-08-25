// lib/features/meetings/presentation/widgets/meeting_creation_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../providers/meeting_creation_provider.dart';
import 'meeting_creation_steps/quick_category_selector.dart';
import 'meeting_creation_steps/quick_details_form.dart';
import 'meeting_creation_steps/quick_datetime_picker.dart';
import 'meeting_creation_steps/quick_final_review.dart';

/// 📝 모임 생성 다이얼로그 - 간소화된 4단계 프로세스
/// 문토 스타일의 직관적이고 빠른 모임 생성 경험
class MeetingCreationDialog extends ConsumerStatefulWidget {
  const MeetingCreationDialog({super.key});

  @override
  ConsumerState<MeetingCreationDialog> createState() => 
      _MeetingCreationDialogState();
}

class _MeetingCreationDialogState 
    extends ConsumerState<MeetingCreationDialog> 
    with SingleTickerProviderStateMixin {
  
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  
  // 단계별 타이틀
  final List<String> _stepTitles = [
    '어떤 모임인가요?',
    '모임 정보를 알려주세요',
    '언제 만날까요?',
    '마지막 확인',
  ];
  
  // 단계별 아이콘
  final List<IconData> _stepIcons = [
    Icons.category_rounded,
    Icons.edit_rounded,
    Icons.calendar_today_rounded,
    Icons.check_circle_rounded,
  ];

  @override
  void initState() {
    super.initState();
    
    
    // 모임 생성 시작 시 셰르피 안내
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.encouragement,
        customDialogue: '모임을 만들어볼까요? 간단하게 4단계만 거치면 돼요! 🎯',
        emotion: SherpiEmotion.guiding,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creationData = ref.watch(meetingCreationProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // 🎯 핸들바
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // 📊 진행률 표시
          _buildProgressIndicator(),
          
          // 📝 단계별 콘텐츠
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                QuickCategorySelector(
                  selectedCategory: creationData.selectedCategory,
                  onCategorySelected: (category) {
                    ref.read(meetingCreationProvider.notifier)
                        .selectCategory(category);
                    _goToNextStep();
                  },
                ),
                QuickDetailsForm(
                  data: creationData,
                  onComplete: () => _goToNextStep(),
                ),
                QuickDateTimePicker(
                  selectedDateTime: creationData.dateTime,
                  onDateTimeSelected: (dateTime) {
                    ref.read(meetingCreationProvider.notifier)
                        .setDateTime(dateTime);
                    _goToNextStep();
                  },
                ),
                QuickFinalReview(
                  data: creationData,
                  onComplete: _createMeeting,
                ),
              ],
            ),
          ),
          
          // 🔄 네비게이션 버튼
          _buildNavigationButtons(creationData),
        ],
      ),
    ).animate()
      .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  /// 📊 진행률 표시
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // 단계 표시
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    // 단계 아이콘
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive 
                          ? ModernColors.primary 
                          : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isActive 
                                  ? Colors.white 
                                  : ModernColors.textSecondary,
                              ),
                            ),
                      ),
                    ),
                    
                    // 연결선
                    if (index < 3)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isCompleted 
                              ? ModernColors.primary 
                              : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        
        // 현재 단계 제목
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _stepIcons[_currentStep],
                color: ModernColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _stepTitles[_currentStep],
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        
        Divider(
          color: Colors.grey.shade200,
          height: 1,
        ),
      ],
    );
  }

  /// 🔄 네비게이션 버튼
  Widget _buildNavigationButtons(MeetingCreationData data) {
    final canProceed = _canProceed(data);
    
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 이전 버튼
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '이전',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 12),
          
          // 다음/완료 버튼
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: canProceed 
                ? (_currentStep == 3 ? _createMeeting : _goToNextStep)
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 3 ? '모임 만들기' : '다음',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 진행 가능 여부 확인
  bool _canProceed(MeetingCreationData data) {
    switch (_currentStep) {
      case 0:
        return data.selectedCategory != null;
      case 1:
        return data.title.isNotEmpty && 
               data.description.isNotEmpty &&
               data.title.length >= 5 &&
               data.description.length >= 10;
      case 2:
        return data.dateTime != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  /// ⏭️ 다음 단계로
  void _goToNextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      
      // 햅틱 피드백
      HapticFeedback.lightImpact();
      
      // 단계별 셰르피 메시지
      _showStepMessage(_currentStep + 1);
    }
  }

  /// ⏮️ 이전 단계로
  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      
      // 햅틱 피드백
      HapticFeedback.lightImpact();
    }
  }

  /// 💬 단계별 셰르피 메시지
  void _showStepMessage(int step) {
    String message;
    SherpiEmotion emotion;
    
    switch (step) {
      case 1:
        message = '좋아요! 이제 모임 정보를 입력해주세요 📝';
        emotion = SherpiEmotion.happy;
        break;
      case 2:
        message = '거의 다 왔어요! 날짜와 시간을 정해볼까요? 📅';
        emotion = SherpiEmotion.cheering;
        break;
      case 3:
        message = '마지막으로 한 번 확인해주세요! 완벽한 모임이 될 거예요 ✨';
        emotion = SherpiEmotion.guiding;
        break;
      default:
        return;
    }
    
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: message,
      emotion: emotion,
    );
  }

  /// ✅ 모임 생성
  void _createMeeting() async {
    try {
      final meetingData = ref.read(meetingCreationProvider);
      final user = ref.read(globalUserProvider);
      
      // 데이터 유효성 검사
      if (!meetingData.isAllDataValid()) {
        _showError('모임 정보를 모두 입력해주세요.');
        return;
      }
      
      // AvailableMeeting으로 변환 (async 메서드)
      final newMeeting = await meetingData.toAvailableMeeting(
        hostId: user.id,
        hostName: user.name,
      );
      
      // GlobalMeetingProvider에 추가
      final success = await ref.read(globalMeetingProvider.notifier).addMeeting(newMeeting);
      
      if (success) {
        // 성공 피드백
        ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.levelUp,
          customDialogue: '모임이 성공적으로 만들어졌어요! 🎉 많은 사람들이 참여할 거예요!',
          emotion: SherpiEmotion.cheering,
        );
        
        // MeetingCreationData 초기화
        ref.read(meetingCreationProvider.notifier).reset();
        
        // 다이얼로그 닫기
        if (mounted) Navigator.pop(context);
        
        // 생성된 모임 상세 화면으로 이동
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/meeting_detail',
            arguments: newMeeting,
          );
        }
      } else {
        _showError('모임 생성에 실패했습니다. 다시 시도해주세요.');
      }
      
    } catch (e) {
      // Error creating meeting: $e
      _showError('모임 생성 중 오류가 발생했습니다.');
    }
  }
  
  /// 에러 메시지 표시
  void _showError(String message) {
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.tiredWarning,
      customDialogue: message,
      emotion: SherpiEmotion.warning,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}