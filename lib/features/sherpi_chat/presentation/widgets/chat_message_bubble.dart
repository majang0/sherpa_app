import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Models
import '../../models/chat_message.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_emotions.dart';

/// 💬 채팅 메시지 말풍선 위젯
/// 
/// 사용자와 셰르피의 메시지를 구분하여 표시하는 말풍선 위젯
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool showTimestamp;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showTimestamp = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUserMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          // 셰르피 아바타 (왼쪽)
          if (message.isSherpiMessage && showAvatar) ...[
            _buildSherpiAvatar(),
            const SizedBox(width: 8),
          ],
          
          // 메시지 말풍선
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Column(
                  crossAxisAlignment: message.isUserMessage
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // 메시지 말풍선
                    _buildMessageBubble(context),
                    
                    // 타임스탬프
                    if (showTimestamp) ...[
                      const SizedBox(height: 4),
                      _buildTimestamp(context),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // 사용자 아바타 (오른쪽)  
          if (message.isUserMessage && showAvatar) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(),
          ],
        ],
      ),
    )
    .animate()
    .slideY(begin: 0.5, end: 0, duration: 300.ms)
    .fade(duration: 300.ms);
  }

  /// 🎭 셰르피 아바타
  Widget _buildSherpiAvatar() {
    final emotion = message.emotion ?? SherpiEmotion.happy;
    
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getEmotionGradient(emotion),
        boxShadow: [
          BoxShadow(
            color: _getEmotionColor(emotion).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          emotion.imagePath,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.face,
              size: 20,
              color: Colors.white,
            );
          },
        ),
      ),
    );
  }

  /// 👤 사용자 아바타
  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  /// 💭 메시지 말풍선
  Widget _buildMessageBubble(BuildContext context) {
    final isUser = message.isUserMessage;
    final isSpecial = message.isSpecialMessage;
    final isTyping = message.metadata?['is_typing'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBubbleColor(isUser, isSpecial),
        borderRadius: _getBorderRadius(isUser),
        border: isSpecial ? Border.all(
          color: _getSpecialBorderColor(),
          width: 1.5,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메시지 타입 표시
          if (isSpecial) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.type.icon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  message.type.description,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getSpecialTextColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // 메시지 내용
          if (isTyping)
            _buildTypingIndicator()
          else
            Text(
              message.content,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: _getTextColor(isUser),
                height: 1.4,
              ),
            ),

          // 메타데이터 정보 (디버그용)
          if (message.metadata?['response_source'] != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getSourceIcon(message.metadata!['response_source']),
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  _getSourceText(message.metadata!['response_source']),
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// ⌨️ 타이핑 인디케이터
  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 3; i++) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.2, 1.2),
            duration: 600.ms,
            delay: (i * 200).ms,
          ),
          if (i < 2) const SizedBox(width: 4),
        ],
      ],
    );
  }

  /// ⏰ 타임스탬프
  Widget _buildTimestamp(BuildContext context) {
    return Text(
      _formatTimestamp(message.timestamp),
      style: GoogleFonts.notoSans(
        fontSize: 11,
        color: Colors.grey.shade500,
      ),
    );
  }

  /// 🎨 말풍선 색상 결정
  Color _getBubbleColor(bool isUser, bool isSpecial) {
    if (isUser) {
      return AppColors.primary;
    }
    
    if (isSpecial) {
      return Colors.orange.shade50;
    }
    
    return Colors.grey.shade100;
  }

  /// 🎨 텍스트 색상 결정
  Color _getTextColor(bool isUser) {
    return isUser ? Colors.white : AppColors.textPrimary;
  }

  /// 🎨 특별 메시지 테두리 색상
  Color _getSpecialBorderColor() {
    switch (message.type) {
      case MessageType.celebration:
        return Colors.orange.shade300;
      case MessageType.encouragement:
        return Colors.blue.shade300;
      case MessageType.suggestion:
        return Colors.purple.shade300;
      case MessageType.milestone:
        return Colors.amber.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  /// 🎨 특별 메시지 텍스트 색상
  Color _getSpecialTextColor() {
    switch (message.type) {
      case MessageType.celebration:
        return Colors.orange.shade700;
      case MessageType.encouragement:
        return Colors.blue.shade700;
      case MessageType.suggestion:
        return Colors.purple.shade700;
      case MessageType.milestone:
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  /// 📐 말풍선 모서리 둥글기
  BorderRadius _getBorderRadius(bool isUser) {
    if (isUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(4),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    }
  }

  /// 🎨 감정에 따른 그라데이션
  Gradient _getEmotionGradient(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.cheering:
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.amber.shade400],
        );
      case SherpiEmotion.happy:
      case SherpiEmotion.defaults:
        return LinearGradient(
          colors: [Colors.green.shade400, Colors.blue.shade400],
        );
      case SherpiEmotion.thinking:
        return LinearGradient(
          colors: [Colors.purple.shade400, Colors.indigo.shade400],
        );
      case SherpiEmotion.sad:
        return LinearGradient(
          colors: [Colors.brown.shade300, Colors.orange.shade300],
        );
      default:
        return LinearGradient(
          colors: [Colors.blue.shade400, Colors.teal.shade400],
        );
    }
  }

  /// 🎨 감정에 따른 메인 색상
  Color _getEmotionColor(SherpiEmotion emotion) {
    switch (emotion) {
      case SherpiEmotion.cheering:
        return Colors.orange;
      case SherpiEmotion.happy:
      case SherpiEmotion.defaults:
        return Colors.green;
      case SherpiEmotion.thinking:
        return Colors.purple;
      case SherpiEmotion.sad:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  /// 🔗 응답 소스 아이콘
  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'static':
        return Icons.flash_on;
      case 'aiCached':
        return Icons.cached;
      case 'aiRealtime':
        return Icons.psychology;
      default:
        return Icons.message;
    }
  }

  /// 🔗 응답 소스 텍스트
  String _getSourceText(String source) {
    switch (source) {
      case 'static':
        return '⚡';
      case 'aiCached':
        return '🚀';
      case 'aiRealtime':
        return '🤖';
      default:
        return '💬';
    }
  }

  /// ⏰ 시간 포맷팅
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}