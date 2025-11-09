import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';

/// Action Buttons Section Widget
///
/// 2025 Material Design 3: Clean buttons with solid colors
/// NO gradients, NO multiple shadows, flat design principles
class ActionButtonsSectionWidget extends StatelessWidget {
  final VoidCallback onUserInfoTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onAIAnalysisTap;

  const ActionButtonsSectionWidget({
    super.key,
    required this.onUserInfoTap,
    required this.onHistoryTap,
    required this.onAIAnalysisTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 1. User Info Action (Outlined)
          _buildOutlinedButton(
            icon: Icons.person_outline,
            label: '내 정보',
            color: ModernColors.climbing,
            onTap: onUserInfoTap,
          ),
          const SizedBox(width: 12),

          // 2. History Action (Outlined)
          _buildOutlinedButton(
            icon: Icons.history,
            label: '이전 기록',
            color: ModernColors.meeting,
            onTap: onHistoryTap,
          ),
          const SizedBox(width: 12),

          // 3. AI Analysis Action (Primary)
          _buildPrimaryButton(
            icon: Icons.psychology_outlined,
            label: 'AI 분석',
            sublabel: '30P',
            color: ModernColors.climbing,
            onTap: onAIAnalysisTap,
          ),
        ],
      ),
    );
  }

  /// Primary Elevated Button - 2025 Material Design 3
  /// Solid color, single shadow, no gradients
  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    String? sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sublabel,
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Outlined Button - 2025 Material Design 3
  /// Clean outline, no fills, no shadows
  Widget _buildOutlinedButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
