import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../models/sherpi_quick_response_model.dart';
import '../providers/global_sherpi_provider.dart';
import '../../core/constants/sherpi_dialogues.dart';
import '../../core/constants/sherpi_emotions.dart';

/// 🚀 셰르피 빠른 응답 위젯
/// 
/// 사용자가 셰르피에게 빠르게 응답할 수 있는 버튼들을 표시합니다.
/// 메시지 카드 아래에 슬라이드업 애니메이션과 함께 나타납니다.
class SherpiQuickResponseWidget extends ConsumerStatefulWidget {
  /// 메시지 표시 위치 (화면 하단에서의 오프셋)
  final double bottomOffset;
  
  /// 빠른 응답 선택 시 호출할 콜백
  final Function(QuickResponseOption)? onResponseSelected;

  const SherpiQuickResponseWidget({
    super.key,
    this.bottomOffset = 60, // 메시지 카드 아래
    this.onResponseSelected,
  });

  @override
  ConsumerState<SherpiQuickResponseWidget> createState() => _SherpiQuickResponseWidgetState();
}

class _SherpiQuickResponseWidgetState extends ConsumerState<SherpiQuickResponseWidget> 
    with TickerProviderStateMixin {
      
  late AnimationController _slideController;
  late AnimationController _fadeController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 슬라이드 애니메이션 컨트롤러
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 페이드 애니메이션 컨트롤러  
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // 애니메이션 설정
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // 아래에서 시작
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sherpiState = ref.watch(sherpiProvider);
    
    // 빠른 응답이 표시되지 않으면 숨김
    if (!sherpiState.showQuickResponseOptions || sherpiState.quickResponseOptions.isEmpty) {
      // 애니메이션 되돌리기
      if (_slideController.isCompleted) {
        _slideController.reverse();
        _fadeController.reverse();
      }
      return const SizedBox.shrink();
    }
    
    // 새로 표시되는 경우 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_slideController.isCompleted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });
    
    return Positioned(
      bottom: widget.bottomOffset,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildQuickResponseButtons(sherpiState.quickResponseOptions),
        ),
      ),
    );
  }
  
  /// 빠른 응답 버튼들 구성
  Widget _buildQuickResponseButtons(List<QuickResponseOption> options) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                '빠른 응답',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              // 닫기 버튼
              GestureDetector(
                onTap: () => ref.hideSherpiQuickResponses(),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 빠른 응답 버튼들
          _buildResponseButtonsGrid(options),
        ],
      ),
    );
  }
  
  /// 응답 버튼들을 그리드로 배치
  Widget _buildResponseButtonsGrid(List<QuickResponseOption> options) {
    // 최대 4개까지만 표시
    final displayOptions = options.take(4).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: displayOptions.map((option) => _buildResponseButton(option)).toList(),
    );
  }
  
  /// 개별 응답 버튼 위젯
  Widget _buildResponseButton(QuickResponseOption option) {
    return GestureDetector(
      onTap: () => _onResponseSelected(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getButtonColor(option.type).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getButtonColor(option.type).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 (있는 경우)
            if (option.icon != null) ...[
              Text(
                option.icon!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
            ],
            // 텍스트
            Flexible(
              child: Text(
                option.text,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _getButtonColor(option.type),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 응답 타입별 버튼 색상
  Color _getButtonColor(QuickResponseType type) {
    switch (type) {
      case QuickResponseType.positive:
        return Colors.green.shade600;
      case QuickResponseType.appreciation:
        return Colors.blue.shade600;
      case QuickResponseType.motivation:
        return Colors.orange.shade600;
      case QuickResponseType.inquiry:
        return Colors.purple.shade600;
      case QuickResponseType.negative:
        return Colors.grey.shade600;
      default:
        return Colors.teal.shade600;
    }
  }
  
  /// 빠른 응답 선택 처리
  Future<void> _onResponseSelected(QuickResponseOption option) async {
    // 햅틱 피드백
    // HapticFeedback.lightImpact(); // 필요 시 추가
    
    // 콜백 호출
    if (widget.onResponseSelected != null) {
      widget.onResponseSelected!(option);
    }
    
    // 프로바이더를 통한 처리
    await ref.selectSherpiQuickResponse(option);
  }
}

/// 🎯 빠른 응답 위젯 표시를 위한 유틸리티 확장
extension SherpiQuickResponseExtension on WidgetRef {
  /// 메시지 카드와 함께 빠른 응답 위젯 표시
  Future<void> showSherpiWithQuickResponse(
    SherpiContext context, {
    SherpiEmotion? emotion,
    Duration? duration,
    Duration? quickResponseDuration,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? gameContext,
  }) async {
    // 먼저 메시지 표시
    await read(sherpiProvider.notifier).showMessage(
      context: context,
      emotion: emotion,
      duration: duration ?? const Duration(seconds: 4),
      userContext: userContext,
      gameContext: gameContext,
      forceShow: true,
    );
    
    // 빠른 응답 옵션들은 _maybeShowQuickResponseOptions에 의해 자동으로 표시됨
  }
}