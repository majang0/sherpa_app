/// AI 추천 버튼 위젯
/// "좀 더 세밀한 추천" 버튼을 제공하여 AI 기반 추천을 트리거

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/theme/modern_colors.dart';
import '../../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../../shared/models/global_user_model.dart';
import '../../../../../shared/providers/global_user_provider.dart';
import '../../../../../shared/providers/global_meeting_provider.dart';
import '../../../ai/meeting_recommendation_ai.dart';
import '../../../ai/models/ai_recommended_meeting.dart';
import 'ai_analysis_loading_widget.dart';
import 'ai_recommendation_result_cards.dart';

/// AI 추천 상태 관리
class AIRecommendationState {
  final bool isLoading;
  final List<AIRecommendedMeeting> recommendations;
  final String? error;

  const AIRecommendationState({
    this.isLoading = false,
    this.recommendations = const [],
    this.error,
  });

  AIRecommendationState copyWith({
    bool? isLoading,
    List<AIRecommendedMeeting>? recommendations,
    String? error,
  }) {
    return AIRecommendationState(
      isLoading: isLoading ?? this.isLoading,
      recommendations: recommendations ?? this.recommendations,
      error: error,
    );
  }
}

/// AI 추천 상태 프로바이더
class AIRecommendationNotifier extends StateNotifier<AIRecommendationState> {
  final MeetingRecommendationAI _aiEngine = MeetingRecommendationAI();
  
  AIRecommendationNotifier() : super(const AIRecommendationState()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _aiEngine.initialize();
  }
  
  /// AI 추천 생성
  Future<void> generateRecommendations({
    required GlobalUser user,
    required List<dynamic> availableMeetings,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // AvailableMeeting 타입으로 변환
      final meetings = availableMeetings
          .whereType<dynamic>()
          .where((m) => m != null)
          .toList();
      
      if (meetings.isEmpty) {
        throw Exception('참여 가능한 모임이 없습니다');
      }
      
      // AI 추천 생성
      final recommendations = await _aiEngine.getAIRecommendations(
        user: user,
        availableMeetings: meetings.cast(),
        useCache: true,
      );
      
      if (recommendations.isEmpty) {
        throw Exception('추천할 모임을 찾을 수 없습니다');
      }
      
      state = state.copyWith(
        isLoading: false,
        recommendations: recommendations,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// 상태 초기화
  void reset() {
    state = const AIRecommendationState();
  }
}

/// AI 추천 프로바이더
final aiRecommendationProvider = 
    StateNotifierProvider<AIRecommendationNotifier, AIRecommendationState>((ref) {
  return AIRecommendationNotifier();
});

/// AI 추천 버튼 위젯
class AIRecommendationButton extends ConsumerWidget {
  const AIRecommendationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiRecommendationProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: aiState.isLoading 
              ? null 
              : () => _handleAIRecommendation(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ModernColors.primary,
                  ModernColors.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // AI 아이콘 (애니메이션)
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ).animate(
                  onPlay: (controller) => controller.repeat(),
                ).shimmer(
                  duration: const Duration(seconds: 2),
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                
                const SizedBox(width: 8),
                
                // 버튼 텍스트
                Text(
                  aiState.isLoading ? 'AI가 분석 중...' : '좀 더 세밀한 추천',
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                
                if (aiState.isLoading) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
  
  /// AI 추천 처리
  Future<void> _handleAIRecommendation(BuildContext context, WidgetRef ref) async {
    // 햅틱 피드백
    HapticFeedbackManager.mediumImpact();
    
    // 사용자 및 모임 데이터 가져오기
    final user = ref.read(globalUserProvider);
    final meetingState = ref.read(globalMeetingProvider);
    
    if (meetingState.availableMeetings.isEmpty) {
      _showError(context, '현재 참여 가능한 모임이 없습니다');
      return;
    }
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AIAnalysisLoadingWidget(),
    );
    
    // AI 추천 생성
    await ref.read(aiRecommendationProvider.notifier).generateRecommendations(
      user: user,
      availableMeetings: meetingState.availableMeetings,
    );
    
    // 로딩 다이얼로그 닫기
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    // 결과 확인
    final aiState = ref.read(aiRecommendationProvider);
    
    if (aiState.error != null) {
      if (context.mounted) {
        _showError(context, aiState.error!);
      }
      return;
    }
    
    if (aiState.recommendations.isNotEmpty && context.mounted) {
      // 추천 결과 표시
      _showRecommendationResults(context, aiState.recommendations);
    }
  }
  
  /// 에러 표시
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.notoSans(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: ModernColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  /// 추천 결과 표시
  void _showRecommendationResults(
    BuildContext context,
    List<AIRecommendedMeeting> recommendations,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIRecommendationResultCards(
        recommendations: recommendations,
      ),
    );
  }
}

/// 간단한 AI 추천 버튼 (작은 버전)
class CompactAIRecommendationButton extends ConsumerWidget {
  const CompactAIRecommendationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiRecommendationProvider);
    
    return GestureDetector(
      onTap: aiState.isLoading 
          ? null 
          : () async {
              HapticFeedbackManager.lightImpact();
              
              // 동일한 로직 실행
              final user = ref.read(globalUserProvider);
              final meetingState = ref.read(globalMeetingProvider);
              
              if (meetingState.availableMeetings.isEmpty) {
                return;
              }
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AIAnalysisLoadingWidget(),
              );
              
              await ref.read(aiRecommendationProvider.notifier)
                  .generateRecommendations(
                user: user,
                availableMeetings: meetingState.availableMeetings,
              );
              
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              
              final updatedState = ref.read(aiRecommendationProvider);
              if (updatedState.recommendations.isNotEmpty && context.mounted) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AIRecommendationResultCards(
                    recommendations: updatedState.recommendations,
                  ),
                );
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ModernColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ModernColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 14,
              color: ModernColors.primary,
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).shimmer(
              duration: const Duration(seconds: 2),
              color: ModernColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              'AI 추천',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ModernColors.primary,
              ),
            ),
            if (aiState.isLoading) ...[
              const SizedBox(width: 4),
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ModernColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}