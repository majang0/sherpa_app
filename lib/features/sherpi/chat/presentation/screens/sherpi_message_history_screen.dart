import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Core
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/sherpi_emotions.dart';

// Shared
import '../../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../../shared/models/sherpi_message_history.dart';
import '../../../../../shared/widgets/sherpa_clean_app_bar.dart';

/// 💬 셰르피 메시지 히스토리 화면
///
/// 셰르피의 메시지를 깔끔하고 단순하게 보여주는 화면
class SherpiMessageHistoryScreen extends ConsumerStatefulWidget {
  const SherpiMessageHistoryScreen({super.key});

  @override
  ConsumerState<SherpiMessageHistoryScreen> createState() =>
      _SherpiMessageHistoryScreenState();
}

class _SherpiMessageHistoryScreenState
    extends ConsumerState<SherpiMessageHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 화면이 빌드된 후 맨 아래로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 📍 맨 아래로 스크롤 (최신 메시지로)
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageHistory =
        ref.read(sherpiProvider.notifier).getMessageHistory();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const SherpaCleanAppBar(
        title: '셰르피와의 대화',
        backgroundColor: Colors.white,
      ),
      body: messageHistory.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              // 역순으로 표시 (오래된 메시지가 위로)
              itemCount: messageHistory.length,
              itemBuilder: (context, index) {
                // 역순 인덱스 계산
                final reverseIndex = messageHistory.length - 1 - index;
                final message = messageHistory[reverseIndex];
                return _buildMessageBubble(message, index == 0);
              },
            ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            SherpiEmotion.defaults.imagePath,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 24),
          Text(
            '아직 대화 기록이 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '셰르피가 곧 대화를 시작할 거예요!',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 메시지 버블 위젯
  Widget _buildMessageBubble(SherpiMessageHistory message, bool isFirst) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 16,
        top: isFirst ? 8 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 셰르피 아바타
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                message.emotion.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 메시지 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 시간 표시
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),

                // 메시지 버블
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  /// 시간 포맷팅
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
