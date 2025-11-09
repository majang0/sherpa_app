import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/modern_colors.dart';

/// Action Buttons Section Widget
///
/// IconButton을 매력적인 카드로 변환: 사용자 정보, 이전 기록, AI 분석
/// 2025 Material Design 3: Icon + Label, Gradients, Premium shadows
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
          // 1. User Info Action
          _buildActionCard(
            icon: Icons.person_outline,
            gradient: LinearGradient(
              colors: [
                ModernColors.climbing,
                ModernColors.climbing.withValues(alpha: 0.8),
              ],
            ),
            label: '내 정보',
            onTap: onUserInfoTap,
            flex: 2,
          ),
          const SizedBox(width: 12),

          // 2. History Action
          _buildActionCard(
            icon: Icons.history,
            gradient: LinearGradient(
              colors: [
                ModernColors.meeting,
                ModernColors.meeting.withValues(alpha: 0.8),
              ],
            ),
            label: '이전 기록',
            onTap: onHistoryTap,
            flex: 2,
          ),
          const SizedBox(width: 12),

          // 3. AI Analysis Action (NEW!)
          _buildActionCard(
            icon: Icons.psychology_outlined,
            gradient: LinearGradient(
              colors: [
                ModernColors.diary,
                ModernColors.diary.withValues(alpha: 0.8),
              ],
            ),
            label: 'AI 분석',
            sublabel: '30P',
            onTap: onAIAnalysisTap,
            flex: 3,
            isPremium: true,
          ),
        ],
      ),
    );
  }

  /// Action Card Helper
  Widget _buildActionCard({
    required IconData icon,
    required LinearGradient gradient,
    required String label,
    String? sublabel,
    required VoidCallback onTap,
    int flex = 1,
    bool isPremium = false,
  }) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: gradient.colors.last.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  if (isPremium)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: ModernColors.joyBright,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
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
                Text(
                  sublabel,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
