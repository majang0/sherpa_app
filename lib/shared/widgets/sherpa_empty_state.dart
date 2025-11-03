import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/modern_colors.dart';

/// 🎯 Sherpa App 공통 빈 상태 위젯
///
/// 일관된 empty state 디자인을 제공합니다.
/// 퀘스트, 챌린지, 모임 등 다양한 화면에서 재사용 가능합니다.
///
/// **사용 예시**:
/// ```dart
/// SherpaEmptyState(
///   emoji: '📅',
///   title: '오늘의 모험이 준비되고 있어요',
///   subtitle: '셰르피와 함께 매일 새로운 도전을 만나보세요!',
///   accentColor: ModernColors.modernPrimary,
///   actionButton: ElevatedButton(...),
/// )
/// ```
class SherpaEmptyState extends StatelessWidget {
  /// 이모지 아이콘
  final String emoji;

  /// 메인 타이틀
  final String title;

  /// 설명 텍스트
  final String subtitle;

  /// 액센트 색상 (그림자, 테두리)
  final Color? accentColor;

  /// 선택적 액션 버튼 (예: 프리미엄 잠금 해제)
  final Widget? actionButton;

  const SherpaEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.accentColor,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? ModernColors.modernPrimary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ModernColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: ModernColors.softShadow(primaryColor: effectiveColor),
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이모지 아이콘
              Text(
                emoji,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),

              // 메인 타이틀
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // 설명 텍스트
              Text(
                subtitle,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: ModernColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // 선택적 액션 버튼
              if (actionButton != null) ...[
                const SizedBox(height: 32),
                actionButton!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
