import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';

/// 일기 분석 페이지 - 추후 구현 예정
class DiaryAnalysisPage extends StatelessWidget {
  final Map<String, dynamic>? todayData;
  final Map<String, dynamic>? previousData;
  final String? analysisText;
  
  const DiaryAnalysisPage({
    super.key,
    this.todayData,
    this.previousData,
    this.analysisText,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: ModernColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '일기 분석',
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '준비 중입니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1, 1),
        duration: 500.ms,
        curve: Curves.easeOutBack,
      );
  }
}