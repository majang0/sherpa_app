import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/modern_colors.dart';

/// ⏳ Sherpa App 공통 로딩 상태 위젯
///
/// 일관된 loading state 디자인을 제공합니다.
/// 데이터 로딩, 초기화 등 다양한 로딩 상황에서 재사용 가능합니다.
///
/// **사용 예시**:
/// ```dart
/// SherpaLoadingState(
///   title: '새로운 모험 준비 중...',
///   subtitle: '셰르피가 특별한 퀘스트를 준비하고 있어요!',
///   icon: Icons.auto_stories,
///   accentColor: ModernColors.modernPrimary,
/// )
/// ```
class SherpaLoadingState extends StatelessWidget {
  /// 로딩 제목
  final String title;

  /// 로딩 설명
  final String subtitle;

  /// 아이콘
  final IconData icon;

  /// 액센트 색상
  final Color? accentColor;

  const SherpaLoadingState({
    super.key,
    this.title = '✨ 새로운 모험 준비 중...',
    this.subtitle = '셰르피가 특별한 퀘스트를 준비하고 있어요!',
    this.icon = Icons.auto_stories,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? ModernColors.modernPrimary;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: ModernColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: ModernColors.softShadow(
                  primaryColor: effectiveColor,
                ),
              ),
              child: Column(
                children: [
                  // 로딩 아이콘
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          effectiveColor,
                          effectiveColor.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 로딩 제목
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

                  // 로딩 설명
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: ModernColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // 진행 바
                  SizedBox(
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      backgroundColor: ModernColors.inactive,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
