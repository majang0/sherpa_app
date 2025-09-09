import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../../shared/widgets/sherpa_card.dart';
import '../../../../../shared/providers/global_point_provider.dart';
import '../../../../../shared/providers/global_user_provider.dart';
import '../../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../../shared/models/global_user_model.dart';
import '../../../../../core/constants/sherpi_dialogues.dart';

class EnhancedPointShopScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointData = ref.watch(globalPointProvider);
    final userData = ref.watch(globalUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SherpaCleanAppBar(
        title: '포인트샵',
        backgroundColor: AppColors.background,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${pointData.totalPoints}P',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointSummary(pointData, userData),
            const SizedBox(height: 24),
            _buildShopCategory(
              context,
              ref,
              '모임 & 챌린지',
              Icons.people,
              [
                ShopItem('무료 모임 참여', '새로운 사람들과 만나보세요', 1000, Icons.people_outline, () {
                  _purchaseFreeMeeting(context, ref);
                }),
                ShopItem('무료 챌린지 참여', '자신에게 도전해보세요', 500, Icons.flag_outlined, () {
                  _purchaseFreeChallenge(context, ref);
                }),
                ShopItem('모임 홍보 부스트', '더 많은 사람에게 모임 노출', 3000, Icons.rocket_launch, () {
                  _purchaseMeetingBoost(context, ref);
                }),
              ],
            ),
            const SizedBox(height: 24),
            _buildShopCategory(
              context,
              ref,
              '프리미엄 기능',
              Icons.star,
              [
                ShopItem('프리미엄 퀘스트 팩', '한 달간 고급 퀘스트 언락', 2000, Icons.auto_awesome, () {
                  _purchasePremiumQuestPack(context, ref);
                }),
                ShopItem('고급 분석 리포트', '나만의 성장 일기 (전자책)', 3000, Icons.analytics, () {
                  _purchaseAnalysisReport(context, ref);
                }),
              ],
            ),
            const SizedBox(height: 24),
            _buildShopCategory(
              context,
              ref,
              '부스터 & 도구',
              Icons.build,
              [
                ShopItem('퀘스트 완료 티켓', '어려운 퀘스트 즉시 완료', 1000, Icons.confirmation_number, () {
                  _purchaseQuestTicket(context, ref);
                }),
                ShopItem('연속 기록 보호권', '연속 기록이 깨지지 않도록 보호', 500, Icons.shield, () {
                  _purchaseStreakProtection(context, ref);
                }),
              ],
            ),
            const SizedBox(height: 24),
            _buildShopCategory(
              context,
              ref,
              '기프트 & 기부',
              Icons.card_giftcard,
              [
                ShopItem('친구에게 포인트 선물', '친구에게 포인트를 선물하세요', 0, Icons.send, () {
                  _showGiftDialog(context, ref);
                }),
                ShopItem('신규 유저 지원 팩', '친구에게 스타터 패키지 선물', 1000, Icons.volunteer_activism, () {
                  _showNewUserSupportDialog(context, ref);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointSummary(PointData pointData, GlobalUser userData) {
    return SherpaCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              '💰 보유 포인트',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${pointData.totalPoints.toInt()}P',
              style: GoogleFonts.notoSans(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              '= ${pointData.totalPoints.toInt()}원',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPointStat('오늘', _getTodayPoints(pointData)),
                _buildPointStat('이번 주', _getWeeklyPoints(pointData)),
                _buildPointStat('이번 달', _getMonthlyPoints(pointData)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointStat(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Text(
          '+${value}P',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildShopCategory(
      BuildContext context,
      WidgetRef ref,
      String title,
      IconData icon,
      List<ShopItem> items,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildShopItemCard(context, ref, item)),
      ],
    );
  }

  Widget _buildShopItemCard(BuildContext context, WidgetRef ref, ShopItem item) {
    final pointData = ref.watch(globalPointProvider);
    final canAfford = item.price == 0 || pointData.totalPoints >= item.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SherpaCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.description,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  if (item.price > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.price}P',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    onPressed: canAfford ? item.onPurchase : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford ? AppColors.primary : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      item.price == 0 ? '선물하기' : (canAfford ? '구매' : '부족'),
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGiftDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController friendController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('친구에게 포인트 선물'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: friendController,
              decoration: InputDecoration(
                labelText: '친구 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '선물할 포인트',
                border: OutlineInputBorder(),
                suffixText: 'P',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(amountController.text) ?? 0;
              final friendName = friendController.text.trim();

              if (amount > 0 && friendName.isNotEmpty) {
                final success = ref.read(globalPointProvider.notifier).spendPoints(
                  amount,
                  '친구 선물: $friendName',
                );
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${friendName}님에게 ${amount}P를 선물했습니다!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('포인트가 부족합니다!')),
                  );
                }
              }
            },
            child: Text('선물하기'),
          ),
        ],
      ),
    );
  }

  void _showNewUserSupportDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController friendController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('신규 유저 지원 팩'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('포함 내용:'),
            Text('• 한 달간 프리미엄 퀘스트팩'),
            Text('• 무료 모임 참여 수수료 제외 (3회)'),
            Text('• 무료 챌린지 참여 수수료 제외 (3회)'),
            Text('• 퀘스트 완료 티켓 1개'),
            Text('• 연속 기록 보호권 1개'),
            const SizedBox(height: 16),
            TextField(
              controller: friendController,
              decoration: InputDecoration(
                labelText: '친구 이름',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final friendName = friendController.text.trim();

              if (friendName.isNotEmpty) {
                final success = ref.read(globalPointProvider.notifier).spendPoints(
                  1000,
                  '신규 유저 지원 팩: $friendName',
                );
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${friendName}님에게 신규 유저 지원 팩을 선물했습니다!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('포인트가 부족합니다!')),
                  );
                }
              }
            },
            child: Text('1000P로 선물하기'),
          ),
        ],
      ),
    );
  }
}

class ShopItem {
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final VoidCallback onPurchase;

  ShopItem(this.name, this.description, this.price, this.icon, this.onPurchase);
}

  // === 포인트 통계 계산 메서드 ===
  int _getTodayPoints(PointData pointData) {
    final today = DateTime.now();
    return pointData.transactions
        .where((transaction) => 
            transaction.timestamp.year == today.year &&
            transaction.timestamp.month == today.month &&
            transaction.timestamp.day == today.day &&
            transaction.amount > 0)
        .fold(0, (sum, transaction) => sum + transaction.amount.toInt());
  }

  int _getWeeklyPoints(PointData pointData) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return pointData.transactions
        .where((transaction) => 
            transaction.timestamp.isAfter(weekStart) &&
            transaction.amount > 0)
        .fold(0, (sum, transaction) => sum + transaction.amount.toInt());
  }

  int _getMonthlyPoints(PointData pointData) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return pointData.transactions
        .where((transaction) => 
            transaction.timestamp.isAfter(monthStart) &&
            transaction.amount > 0)
        .fold(0, (sum, transaction) => sum + transaction.amount.toInt());
  }

  // === 구매 기능 메서드 ===
  void _purchaseFreeMeeting(BuildContext context, WidgetRef ref) {
    final success = ref.read(globalPointProvider.notifier).payFreeMeetingFee('무료 모임 참여');
    if (success) {
      _showSuccessMessage(context, ref, '무료 모임 참여가 완료되었습니다! 🤝');
      // 글로벌 시스템에 모임 참여 기록
      ref.read(globalUserProvider.notifier).completeMeeting(
        meetingId: 'shop_meeting_${DateTime.now().millisecondsSinceEpoch}',
        meetingType: '무료 모임',
        isHost: false,
      );
    } else {
      _showErrorMessage(context, ref, '포인트가 부족합니다! 😢');
    }
  }

  void _purchaseFreeChallenge(BuildContext context, WidgetRef ref) {
    final success = ref.read(globalPointProvider.notifier).spendPoints(500, '무료 챌린지 참여');
    if (success) {
      _showSuccessMessage(context, ref, '챌린지 참여가 완료되었습니다! 🏆');
      // 글로벌 시스템에 챌린지 참여 기록
      ref.read(globalUserProvider.notifier).completeChallenge(
        challengeId: 'shop_challenge_${DateTime.now().millisecondsSinceEpoch}',
        challengeType: '무료 챌린지',
        duration: 7,
      );
    } else {
      _showErrorMessage(context, ref, '포인트가 부족합니다! 😢');
    }
  }

  void _purchaseMeetingBoost(BuildContext context, WidgetRef ref) {
    final success = ref.read(globalPointProvider.notifier).spendPoints(3000, '모임 홍보 부스트');
    if (success) {
      _showSuccessMessage(context, ref, '모임 홍보 부스트가 적용되었습니다! 🚀');
    } else {
      _showErrorMessage(context, ref, '포인트가 부족합니다! 😢');
    }
  }

  void _purchasePremiumQuestPack(BuildContext context, WidgetRef ref) {
    final success = ref.read(globalPointProvider.notifier).spendPoints(2000, '프리미엄 퀘스트 팩');
    if (success) {
      _showSuccessMessage(context, ref, '프리미엄 퀘스트 팩이 활성화되었습니다! ✨');
      // 퀘스트 시스템에 프리미엄 활성화 알림
      // TODO: 퀘스트 시스템과 연동
    } else {
      _showErrorMessage(context, ref, '포인트가 부족합니다! 😢');
    }
  }

  void _purchaseAnalysisReport(BuildContext context, WidgetRef ref) {
    final success = ref.read(globalPointProvider.notifier).spendPoints(3000, '고급 분석 리포트');
    if (success) {
      _showSuccessMessage(context, ref, '고급 분석 리포트가 생성되었습니다! 📈');
    } else {
      _showErrorMessage(context, ref, '포인트가 부족합니다! 😢');
    }
  }

  void _purchaseQuestTicket(BuildContext context, WidgetRef ref) {
    final success = ref.read(globalPointProvider.notifier).spendPoints(1000, '퀘스트 완료 티켓');
    if (success) {
      _showSuccessMessage(context, ref, '퀘스트 완료 티켓을 구매했습니다! 🎫');
    } else {
      _showErrorMessage(context, ref, '포인트가 부족합니다! 😢');
    }
  }

  void _purchaseStreakProtection(BuildContext context, WidgetRef ref) {
    final success = ref.read(globalPointProvider.notifier).spendPoints(500, '연속 기록 보호권');
    if (success) {
      _showSuccessMessage(context, ref, '연속 기록 보호권을 구매했습니다! 🛡️');
    } else {
      _showErrorMessage(context, ref, '포인트가 부족합니다! 😢');
    }
  }

  // === 성공/오류 메시지 표시 ===
  void _showSuccessMessage(BuildContext context, WidgetRef ref, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // 셰르피 성공 피드백
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: message,
      emotion: SherpiEmotion.cheering,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorMessage(BuildContext context, WidgetRef ref, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // 셰르피 오류 피드백
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: message,
      emotion: SherpiEmotion.warning,
      duration: const Duration(seconds: 3),
    );
  }
