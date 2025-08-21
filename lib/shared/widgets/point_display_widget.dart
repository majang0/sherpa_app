import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../providers/global_point_provider.dart';


class PointDisplayWidget extends ConsumerWidget {
  final bool showDetails;
  final bool isCompact; // ✅ 새로운 컴팩트 모드
  final VoidCallback? onTap;

  const PointDisplayWidget({
    Key? key,
    this.showDetails = false,
    this.isCompact = false, // ✅ 기본값 false
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointData = ref.watch(globalPointProvider);
    final totalPoints = pointData.totalPoints.toInt();
    final todayEarned = _calculateTodayEarned(pointData); // 오늘 획득 포인트 계산

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 10, // ✅ 컴팩트 모드에서 더 작게
          vertical: isCompact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: isCompact ? 0.2 : 0.3), // ✅ 그림자 조절
              blurRadius: isCompact ? 4 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              color: Colors.white,
              size: isCompact ? 12 : 14, // ✅ 아이콘 크기 조절
            ),
            SizedBox(width: isCompact ? 3 : 4),
            Text(
              '${totalPoints}P',
              style: GoogleFonts.notoSans(
                fontSize: isCompact ? 10 : 12, // ✅ 폰트 크기 조절
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (showDetails && todayEarned > 0) ...[
              SizedBox(width: isCompact ? 4 : 6),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 3 : 4,
                    vertical: isCompact ? 1 : 1
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                ),
                child: Text(
                  '+${todayEarned}',
                  style: GoogleFonts.notoSans(
                    fontSize: isCompact ? 8 : 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 오늘 획득한 포인트 계산 (간단 버전)
  int _calculateTodayEarned(PointData pointData) {
    final today = DateTime.now();
    final todayTransactions = pointData.transactions.where((transaction) {
      final transactionDate = transaction.timestamp;
      return transactionDate.year == today.year &&
             transactionDate.month == today.month &&
             transactionDate.day == today.day &&
             transaction.amount > 0; // 양수만 (획득)
    });
    
    return todayTransactions.fold(0, (sum, transaction) => sum + transaction.amount.toInt());
  }
}
