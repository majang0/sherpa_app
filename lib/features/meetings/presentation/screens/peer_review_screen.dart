import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/constants/sherpi_dialogues.dart';
import 'package:sherpa_app/core/constants/sherpi_emotions.dart';
import 'package:sherpa_app/shared/providers/lazy_loaded/peer_review_provider.dart';
import 'package:sherpa_app/shared/providers/level_3_ai/global_sherpi_provider.dart';
import 'package:sherpa_app/shared/widgets/sherpa_clean_app_bar.dart';
import 'package:sherpa_app/shared/widgets/sherpa_button.dart';

/// 동료 평가 화면
///
/// 모임 참석 후 다른 참석자를 평가할 수 있는 화면입니다.
/// **포인트 보상**: 평가 완료 시 100 Point 자동 지급
class PeerReviewScreen extends ConsumerStatefulWidget {
  final String meetingId;
  final String meetingName;
  final String revieweeId;
  final String revieweeName;

  const PeerReviewScreen({
    super.key,
    required this.meetingId,
    required this.meetingName,
    required this.revieweeId,
    required this.revieweeName,
  });

  @override
  ConsumerState<PeerReviewScreen> createState() => _PeerReviewScreenState();
}

class _PeerReviewScreenState extends ConsumerState<PeerReviewScreen> {
  double _rating = 3.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final success = await ref.read(peerReviewProvider.notifier).addReview(
          meetingId: widget.meetingId,
          revieweeId: widget.revieweeId,
          rating: _rating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      // ✅ Sherpi 반응 표시
      ref.read(sherpiProvider.notifier).showInstantMessage(
            context: SherpiContext.questComplete,
            customDialogue: '동료 평가를 완료했어요! 100 포인트를 받았어요! 🎉',
            emotion: SherpiEmotion.cheering,
          );

      // 화면 닫기
      Navigator.of(context).pop(true);
    } else {
      // 중복 평가 등의 오류
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 평가를 완료했거나 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: SherpaCleanAppBar(
        title: '동료 평가',
        backgroundColor: ModernColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 모임 정보
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: ModernColors.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: ModernColors.border,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '모임',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      widget.meetingName,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      '평가 대상',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      widget.revieweeName,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32.0),

              // 별점 선택
              Text(
                '별점을 선택해주세요',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16.0),

              // 별점 UI
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1.0;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starValue),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        _rating >= starValue ? Icons.star : Icons.star_border,
                        size: 48.0,
                        color: _rating >= starValue
                            ? ModernColors.warning
                            : ModernColors.border,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 8.0),

              Center(
                child: Text(
                  '${_rating.toInt()}점',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32.0),

              // 코멘트 입력 (선택 사항)
              Text(
                '코멘트 (선택사항)',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12.0),

              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: '모임에서의 경험을 간단히 공유해주세요...',
                  hintStyle: TextStyle(color: ModernColors.textSecondary),
                  filled: true,
                  fillColor: ModernColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: ModernColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: ModernColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: ModernColors.primary),
                  ),
                ),
                style: TextStyle(color: ModernColors.textPrimary),
              ),

              const SizedBox(height: 32.0),

              // 제출 버튼
              SizedBox(
                width: double.infinity,
                child: SherpaButton(
                  text: _isSubmitting ? '제출 중...' : '평가 완료 (+100 포인트)',
                  onPressed: _isSubmitting ? null : _submitReview,
                  backgroundColor: ModernColors.primary,
                ),
              ),

              const SizedBox(height: 16.0),

              // 취소 버튼
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: ModernColors.textSecondary,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
