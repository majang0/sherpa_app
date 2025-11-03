import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/modern_colors.dart';

/// 🚨 Sherpa App 공통 에러 상태 위젯
///
/// 일관된 error state 디자인을 제공합니다.
/// 데이터 로딩 실패, 네트워크 오류 등 다양한 에러 상황에서 재사용 가능합니다.
///
/// **사용 예시**:
/// ```dart
/// SherpaErrorState(
///   title: '퀘스트를 불러올 수 없어요',
///   subtitle: '잠시 후 다시 시도해주세요',
///   onRetry: () {
///     ref.read(questProviderV2.notifier).refresh();
///   },
/// )
/// ```
class SherpaErrorState extends StatelessWidget {
  /// 에러 제목
  final String title;

  /// 에러 설명
  final String subtitle;

  /// 재시도 콜백
  final VoidCallback onRetry;

  const SherpaErrorState({
    super.key,
    this.title = '데이터를 불러올 수 없어요',
    this.subtitle = '잠시 후 다시 시도해주세요',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: ModernColors.softShadow(
            primaryColor: ModernColors.modernError,
          ),
          border: Border.all(
            color: ModernColors.modernError.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 에러 아이콘
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ModernColors.modernError.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: ModernColors.modernError,
              ),
            ),
            const SizedBox(height: 24),

            // 에러 제목
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 에러 설명
            Text(
              subtitle,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: ModernColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 재시도 버튼
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                '다시 시도',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.modernPrimary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
