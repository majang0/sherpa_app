import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Models
import '../../models/chat_message.dart';
import '../../models/conversation_state.dart';

// Providers
import '../../providers/enhanced_chat_conversation_provider.dart';
// Personalization imports removed

// Widgets
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
// Feedback collection widget import removed

// Core
import '../../../../../core/theme/modern_colors.dart';
import '../../../../../shared/widgets/sherpa_clean_app_bar.dart';

/// 💬 셰르피 채팅 화면
///
/// 셰르피와 실시간으로 대화할 수 있는 전체 화면 채팅 인터페이스
class SherpiChatScreen extends ConsumerStatefulWidget {
  final ConversationContext? initialContext;
  final String? initialMessage;

  const SherpiChatScreen({
    super.key,
    this.initialContext,
    this.initialMessage,
  });

  @override
  ConsumerState<SherpiChatScreen> createState() => _SherpiChatScreenState();
}

class _SherpiChatScreenState extends ConsumerState<SherpiChatScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _backgroundAnimationController;
  bool _showScrollToBottom = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _scrollController.addListener(_onScroll);

    // 초기 대화 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _initializeConversation() {
    final chatNotifier = ref.read(enhancedChatConversationProvider.notifier);

    // 새 대화 세션 시작
    chatNotifier.startNewConversation(
      context: widget.initialContext ?? ConversationContext.general,
      metadata: {
        'screen_entry': 'sherpi/chat_screen',
        'initial_message': widget.initialMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // 초기 메시지가 있다면 자동 전송
    if (widget.initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _sendMessage(widget.initialMessage!);
      });
    }

    // 배경 애니메이션 시작
    _backgroundAnimationController.repeat();
  }

  void _onScroll() {
    final showButton =
        _scrollController.hasClients && _scrollController.offset > 200;

    if (showButton != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showButton;
      });
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(enhancedChatConversationProvider.notifier)
          .sendUserMessage(message);

      // 새 메시지 후 스크롤 이동
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });

      // 햅틱 피드백
      HapticFeedback.lightImpact();
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('메시지 전송에 실패했습니다: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showConversationMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildConversationMenu(),
    );
  }

  void _endConversation() {
    ref.read(enhancedChatConversationProvider.notifier).endConversation();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(enhancedChatConversationProvider);

    return Scaffold(
      backgroundColor: _getBackgroundColor(conversationState.context),
      appBar: SherpaCleanAppBar(
        title: _getAppBarTitle(conversationState.context),
        backgroundColor: _getBackgroundColor(conversationState.context),
        actions: [
          // 셰르피 감정 표시
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: ClipOval(
              child: Image.asset(
                conversationState.currentEmotion.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.face,
                    color: Colors.white,
                    size: 20,
                  );
                },
              ),
            ),
          ),

          // 메뉴 버튼
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showConversationMenu,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 배경 그라데이션
          _buildAnimatedBackground(conversationState.context),

          // 메인 콘텐츠
          Column(
            children: [
              // 대화 상태 표시 (선택적)
              if (conversationState.context != ConversationContext.general)
                _buildContextBanner(conversationState.context),

              // 메시지 목록
              Expanded(
                child: _buildMessageList(conversationState.messages),
              ),

              // 입력창
              ChatInputField(
                onSendMessage: _sendMessage,
                isEnabled: conversationState.isActive,
                isLoading: _isLoading,
                placeholder: _getInputPlaceholder(conversationState.context),
                suggestions: _getSuggestions(conversationState.context),
              ),
            ],
          ),

          // 스크롤 투 바텀 버튼
          if (_showScrollToBottom) _buildScrollToBottomButton(),
        ],
      ),
    );
  }

  /// 🎨 배경 색상 결정
  Color _getBackgroundColor(ConversationContext context) {
    switch (context) {
      case ConversationContext.celebration:
        return Colors.orange.shade400;
      case ConversationContext.encouragement:
        return Colors.blue.shade400;
      case ConversationContext.planning:
        return Colors.purple.shade400;
      case ConversationContext.deep:
        return Colors.indigo.shade400;
      case ConversationContext.crisis:
        return Colors.red.shade400;
      default:
        return ModernColors.primary;
    }
  }

  /// 📱 앱바 제목 결정
  String _getAppBarTitle(ConversationContext context) {
    switch (context) {
      case ConversationContext.celebration:
        return '🎉 축하해요!';
      case ConversationContext.encouragement:
        return '💙 함께해요';
      case ConversationContext.planning:
        return '🎯 계획세우기';
      case ConversationContext.deep:
        return '💭 깊은 대화';
      case ConversationContext.crisis:
        return '🤗 괜찮아요';
      default:
        return '셰르피와 대화';
    }
  }

  /// 📝 입력창 플레이스홀더 결정
  String _getInputPlaceholder(ConversationContext context) {
    switch (context) {
      case ConversationContext.celebration:
        return '기쁜 마음을 나눠주세요!';
      case ConversationContext.encouragement:
        return '힘든 마음을 털어놓으세요...';
      case ConversationContext.planning:
        return '어떤 계획을 세워볼까요?';
      case ConversationContext.deep:
        return '깊은 생각을 나눠주세요...';
      default:
        return '셰르피에게 말해보세요...';
    }
  }

  /// 💡 제안 목록 가져오기
  List<String>? _getSuggestions(ConversationContext context) {
    // 컨텍스트에 맞는 제안들 반환
    switch (context) {
      case ConversationContext.celebration:
        return [
          '목표를 달성했어!',
          '오늘 정말 뿌듯해',
          '이 기쁨을 나누고 싶어',
          '다음 목표도 세우고 싶어',
        ];
      case ConversationContext.encouragement:
        return [
          '요즘 힘들어',
          '다시 시작하고 싶어',
          '용기가 필요해',
          '포기하고 싶지 않아',
        ];
      case ConversationContext.planning:
        return [
          '새로운 목표를 세우고 싶어',
          '어떻게 시작할까?',
          '계획을 구체화하고 싶어',
          '습관을 만들고 싶어',
        ];
      default:
        return [
          '오늘 하루는 어땠어?',
          '요즘 기분이 어때?',
          '조언이 필요해',
          '함께 이야기하자',
        ];
    }
  }

  /// 🌈 애니메이션 배경
  Widget _buildAnimatedBackground(ConversationContext conversationContext) {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform:
                  GradientRotation(_backgroundAnimationController.value * 0.5),
              colors: _getGradientColors(conversationContext),
            ),
          ),
        );
      },
    );
  }

  /// 🎨 그라데이션 색상 목록
  List<Color> _getGradientColors(ConversationContext context) {
    switch (context) {
      case ConversationContext.celebration:
        return [
          Colors.orange.shade400,
          Colors.amber.shade400,
          Colors.yellow.shade300,
        ];
      case ConversationContext.encouragement:
        return [
          Colors.blue.shade400,
          Colors.teal.shade400,
          Colors.cyan.shade300,
        ];
      case ConversationContext.planning:
        return [
          Colors.purple.shade400,
          Colors.indigo.shade400,
          Colors.blue.shade400,
        ];
      case ConversationContext.deep:
        return [
          Colors.indigo.shade500,
          Colors.purple.shade500,
          Colors.pink.shade400,
        ];
      default:
        return [
          ModernColors.primary,
          ModernColors.primary.withValues(alpha: 0.8),
          ModernColors.primary.withValues(alpha: 0.6),
        ];
    }
  }

  /// 🏷️ 컨텍스트 배너
  Widget _buildContextBanner(ConversationContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withValues(alpha: 0.1),
      child: Text(
        context.description,
        textAlign: TextAlign.center,
        style: GoogleFonts.notoSans(
          fontSize: 13,
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 📜 메시지 목록
  Widget _buildMessageList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '대화를 시작해보세요!',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isLastMessage = index == messages.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatMessageBubble(
              message: message,
              showAvatar: true,
              showTimestamp: isLastMessage ||
                  (index < messages.length - 1 &&
                      messages[index + 1]
                              .timestamp
                              .difference(message.timestamp)
                              .inMinutes >
                          5),
              onTap: () => _onMessageTap(message),
              onLongPress: () => _onMessageLongPress(message),
            ),

            // 피드백 버튼 추가 (셰르피 메시지만)
            if (message.isSherpiMessage &&
                message.metadata?['is_typing'] != true &&
                message.metadata?['is_error'] != true)
              _buildFeedbackButtons(message),
          ],
        );
      },
    );
  }

  /// 🔽 스크롤 투 바텀 버튼
  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 80,
      right: 16,
      child: FloatingActionButton.small(
        onPressed: () => _scrollToBottom(),
        backgroundColor: Colors.white,
        foregroundColor: ModernColors.primary,
        elevation: 4,
        child: const Icon(Icons.keyboard_arrow_down),
      ).animate().slideY(begin: 1, end: 0, duration: 300.ms).fade(),
    );
  }

  /// 👍 피드백 버튼들
  Widget _buildFeedbackButtons(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(left: 44, top: 4, bottom: 8),
      child: Row(
        children: [
          // 빠른 피드백 버튼들
          _buildQuickFeedbackButton(
            icon: Icons.thumb_up_outlined,
            activeIcon: Icons.thumb_up,
            label: '좋아요',
            onTap: () => _addQuickFeedback(message, 5.0, '좋아요'),
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _buildQuickFeedbackButton(
            icon: Icons.thumb_down_outlined,
            activeIcon: Icons.thumb_down,
            label: '별로예요',
            onTap: () => _addQuickFeedback(message, 2.0, '별로예요'),
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          _buildQuickFeedbackButton(
            icon: Icons.comment_outlined,
            activeIcon: Icons.comment,
            label: '상세 피드백',
            onTap: () => _showDetailedFeedback(message),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  /// 🔘 빠른 피드백 버튼
  Widget _buildQuickFeedbackButton({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
  }

  /// ⚡ 빠른 피드백 추가
  Future<void> _addQuickFeedback(
      ChatMessage message, double rating, String comment) async {
    try {
      await ref
          .read(enhancedChatConversationProvider.notifier)
          .addMessageFeedback(
            messageId: message.id,
            rating: rating,
            comment: comment,
            // feedbackType 제거됨
          );

      // 성공 메시지 표시 (선택적)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('피드백 감사합니다! 💚'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade600,
        ),
      );

      // 햅틱 피드백
      HapticFeedback.lightImpact();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('피드백 전송에 실패했습니다: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  /// 📝 상세 피드백 표시
  void _showDetailedFeedback(ChatMessage message) {
    // FeedbackDialog removed - show simple dialog instead
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 상세 피드백'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('메시지: ${message.content}'),
            const SizedBox(height: 16),
            const Text('이 메시지에 대한 피드백을 주셔서 감사합니다!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('피드백이 성공적으로 전송되었습니다! 💚'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  /// 📋 대화 메뉴
  Widget _buildConversationMenu() {
    // 대화 통계를 간단하게 처리 (enhancedConversationStatsProvider 제거됨)
    final conversationState = ref.read(enhancedChatConversationProvider);
    final messageCount = conversationState.messages.length;
    final duration = conversationState.isActive
        ? DateTime.now().difference(conversationState.startTime).inMinutes
        : 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // 대화 통계
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '대화 정보',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '총 $messageCount개 메시지 • $duration분간 대화',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 메뉴 항목들
          _buildMenuTile(
            icon: Icons.save_alt,
            title: '대화 저장',
            onTap: () {
              ref
                  .read(enhancedChatConversationProvider.notifier)
                  .saveConversation();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('대화가 저장되었습니다')),
              );
            },
          ),

          _buildMenuTile(
            icon: Icons.refresh,
            title: '새 대화 시작',
            onTap: () {
              Navigator.pop(context);
              ref
                  .read(enhancedChatConversationProvider.notifier)
                  .startNewConversation();
            },
          ),

          _buildMenuTile(
            icon: Icons.close,
            title: '대화 종료',
            textColor: Colors.red.shade600,
            onTap: () {
              Navigator.pop(context);
              _endConversation();
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 📋 메뉴 타일
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? ModernColors.textPrimary),
      title: Text(
        title,
        style: GoogleFonts.notoSans(
          fontWeight: FontWeight.w500,
          color: textColor ?? ModernColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  /// 💬 메시지 탭 처리
  void _onMessageTap(ChatMessage message) {
    // 메시지 상세 정보 표시나 다른 액션
    if (message.type == MessageType.suggestion) {
      // 제안 메시지라면 관련 액션 실행
    }
  }

  /// 📱 메시지 롱 프레스 처리
  void _onMessageLongPress(ChatMessage message) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '메시지 옵션',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            if (message.isUserMessage)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('메시지 삭제'),
                onTap: () {
                  ref
                      .read(enhancedChatConversationProvider.notifier)
                      .deleteMessage(message.id);
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('메시지 정보'),
              onTap: () {
                Navigator.pop(context);
                _showMessageInfo(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ℹ️ 메시지 정보 표시
  void _showMessageInfo(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('발신자: ${message.sender.name}'),
            Text('시간: ${message.timestamp}'),
            Text('타입: ${message.type.description}'),
            if (message.emotion != null) Text('감정: ${message.emotion!.name}'),
            if (message.metadata != null) Text('메타데이터: ${message.metadata}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
