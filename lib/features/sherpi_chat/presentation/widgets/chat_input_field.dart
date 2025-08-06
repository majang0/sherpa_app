import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../core/constants/app_colors.dart';

/// ⌨️ 채팅 입력창 위젯
/// 
/// 사용자가 셰르피에게 메시지를 입력할 수 있는 입력창과 전송 버튼
class ChatInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;
  final bool isLoading;
  final String? placeholder;
  final int maxLines;
  final List<String>? suggestions;

  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
    this.isLoading = false,
    this.placeholder,
    this.maxLines = 4,
    this.suggestions,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _buttonAnimationController;
  late AnimationController _suggestionsAnimationController;
  
  bool _showSuggestions = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _suggestionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _buttonAnimationController.dispose();
    _suggestionsAnimationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      
      if (hasText) {
        _buttonAnimationController.forward();
      } else {
        _buttonAnimationController.reverse();
      }
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && widget.suggestions != null && widget.suggestions!.isNotEmpty) {
      setState(() {
        _showSuggestions = true;
      });
      _suggestionsAnimationController.forward();
    } else {
      setState(() {
        _showSuggestions = false;
      });
      _suggestionsAnimationController.reverse();
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && widget.isEnabled && !widget.isLoading) {
      widget.onSendMessage(text);
      _textController.clear();
      
      // 햅틱 피드백
      HapticFeedback.lightImpact();
      
      // 포커스 유지 (연속 대화를 위해)
      _focusNode.requestFocus();
    }
  }

  void _selectSuggestion(String suggestion) {
    _textController.text = suggestion;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    setState(() {
      _showSuggestions = false;
    });
    _suggestionsAnimationController.reverse();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 제안 목록
        if (_showSuggestions && widget.suggestions != null)
          _buildSuggestions(),
        
        // 입력창 영역
        Container(
          padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 입력창
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 48,
                      maxHeight: widget.maxLines * 24.0 + 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _focusNode.hasFocus 
                            ? AppColors.primary.withOpacity(0.5)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: widget.isEnabled && !widget.isLoading,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.placeholder ?? '셰르피에게 말해보세요...',
                        hintStyle: GoogleFonts.notoSans(
                          fontSize: 15,
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        // 로딩 중일 때 표시
                        suffixIcon: widget.isLoading 
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 전송 버튼
                AnimatedBuilder(
                  animation: _buttonAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_buttonAnimationController.value * 0.2),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _hasText && widget.isEnabled && !widget.isLoading
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                          boxShadow: _hasText && widget.isEnabled && !widget.isLoading ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _hasText && widget.isEnabled && !widget.isLoading 
                                ? _sendMessage 
                                : null,
                            child: Icon(
                              Icons.send_rounded,
                              color: _hasText && widget.isEnabled && !widget.isLoading
                                  ? Colors.white
                                  : Colors.grey.shade500,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 💡 제안 목록 위젯
  Widget _buildSuggestions() {
    return AnimatedBuilder(
      animation: _suggestionsAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _suggestionsAnimationController.value)),
          child: Opacity(
            opacity: _suggestionsAnimationController.value,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.suggestions!.length,
                itemBuilder: (context, index) {
                  final suggestion = widget.suggestions![index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectSuggestion(suggestion),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎯 채팅 제안 도우미 클래스
class ChatSuggestionHelper {
  /// 일반적인 대화 시작 제안들
  static const List<String> generalSuggestions = [
    '오늘 하루는 어땠어?',
    '요즘 기분이 어때?',
    '새로운 목표를 세우고 싶어',
    '조언이 필요해',
    '격려해줘',
    '함께 계획을 세워보자',
  ];

  /// 축하 상황 제안들
  static const List<String> celebrationSuggestions = [
    '목표를 달성했어!',
    '오늘 정말 뿌듯한 일이 있었어',
    '드디어 해냈어!',
    '성취감이 느껴져',
  ];

  /// 격려가 필요한 상황 제안들
  static const List<String> encouragementSuggestions = [
    '요즘 힘들어',
    '포기하고 싶어',
    '다시 시작하고 싶어',
    '용기가 필요해',
    '위로해줘',
  ];

  /// 계획 관련 제안들
  static const List<String> planningSuggestions = [
    '새로운 목표를 세우고 싶어',
    '계획을 어떻게 세울까?',
    '습관을 만들고 싶어',
    '시간 관리가 어려워',
  ];

  /// 컨텍스트에 맞는 제안 반환
  static List<String> getSuggestionsForContext(String context) {
    switch (context.toLowerCase()) {
      case 'celebration':
        return celebrationSuggestions;
      case 'encouragement':
        return encouragementSuggestions;
      case 'planning':
        return planningSuggestions;
      default:
        return generalSuggestions;
    }
  }
}