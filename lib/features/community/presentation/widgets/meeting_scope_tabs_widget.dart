import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';

/// 🔍 모임/챌린지 범위 선택 탭 위젯
/// [전체] vs [우리 학교] 필터링을 위한 하위 탭바
class MeetingScopeTabsWidget extends StatelessWidget {
  final TabController controller;
  final bool isChallenge;

  const MeetingScopeTabsWidget({
    super.key,
    required this.controller,
    required this.isChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ModernColors.textTertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.textTertiary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: controller,
        labelColor: isChallenge ? ModernColors.secondary : ModernColors.primary,
        unselectedLabelColor: ModernColors.textSecondary,
        labelStyle: GoogleFonts.notoSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          _buildScopeTab(
            icon: '🌍',
            label: '전체',
            description: '모든 공개 ${isChallenge ? '챌린지' : '모임'}',
          ),
          _buildScopeTab(
            icon: '🏫',
            label: '우리 학교',
            description: '같은 학교 ${isChallenge ? '챌린지' : '모임'}',
          ),
        ],
      ),
    );
  }

  /// 📋 개별 범위 탭 빌더
  Widget _buildScopeTab({
    required String icon,
    required String label,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.notoSans(
                  fontSize: 9,
                  color: ModernColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
