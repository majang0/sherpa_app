import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../providers/global_sherpi_provider.dart';
import '../models/sherpa_character.dart';

class SherpaAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? sherpaMessage;  // 기존 호환성 유지
  final bool showSherpa;
  final List<Widget>? actions;

  const SherpaAppBar({
    Key? key,
    required this.title,
    this.sherpaMessage,  // 선택적 매개변수로 유지
    this.showSherpa = true,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sherpa = ref.watch(sherpiProvider);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          if (showSherpa) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: SherpiState.getEmotionColor(sherpa.emotion).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  sherpa.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // sherpaMessage가 있으면 그것을, 없으면 Provider 메시지 사용
                  Text(
                    sherpaMessage ?? sherpa.message,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ] else
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
      actions: actions ?? [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () {
            // 알림 화면으로 이동
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
