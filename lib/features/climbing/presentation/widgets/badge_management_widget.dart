// lib/features/my_growth/presentation/widgets/badge_management_widget.dart

import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/sherpa_card.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_game_provider.dart';
import '../../../../shared/models/global_badge_model.dart'; // ✅ GlobalBadge 사용
import '../../../../shared/providers/global_badge_provider.dart';

class BadgeManagementWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<BadgeManagementWidget> createState() => _BadgeManagementWidgetState();
}

class _BadgeManagementWidgetState extends ConsumerState<BadgeManagementWidget>
    with TickerProviderStateMixin {
  late AnimationController _equipController;
  GlobalBadgeTier? selectedFilter; // ✅ GlobalBadgeTier 사용

  @override
  void initState() {
    super.initState();
    _equipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _equipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final equippedBadges = ref.watch(globalEquippedBadgesProvider);
    final ownedBadges = ref.watch(globalOwnedBadgesProvider);
    final maxBadgeSlots = ref.watch(globalBadgeSlotCountProvider);

    final filteredBadges = selectedFilter == null
        ? ownedBadges
        : ownedBadges.where((badge) => badge.tier == selectedFilter).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SherpaCard(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.7,
          ),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(equippedBadges.length, maxBadgeSlots, screenWidth),
              SizedBox(height: 16),
              _buildTotalEffectsSummary(equippedBadges, screenWidth),
              SizedBox(height: 16),
              _buildEquippedSlots(equippedBadges, maxBadgeSlots, screenWidth),
              SizedBox(height: 16),
              _buildFilterButtons(screenWidth),
              SizedBox(height: 8),
              Text(
                '보유 뱃지 (${filteredBadges.length})',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: _buildBadgeList(filteredBadges, equippedBadges, maxBadgeSlots, screenWidth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int equippedCount, int maxSlots, double screenWidth) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text('🏅', style: TextStyle(fontSize: 18))),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '뱃지 장비창',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '능력을 강화하는 특별한 효과',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: equippedCount == maxSlots ? AppColors.success : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$equippedCount / $maxSlots',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: equippedCount == maxSlots ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ 총 효과 요약 카드 (타입별 분류 개선)
  Widget _buildTotalEffectsSummary(List<GlobalBadge> equippedBadges, double screenWidth) {
    Map<String, double> effectsByType = {};

    for (final badge in equippedBadges) {
      effectsByType[badge.effectType] = (effectsByType[badge.effectType] ?? 0) + badge.effectValue;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '✨ 장착 효과',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Spacer(),
              if (effectsByType.isEmpty)
                Text(
                  '효과 없음',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          if (effectsByType.isNotEmpty) ...[
            SizedBox(height: 8),
            ...effectsByType.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '• ${_getEffectTypeName(entry.key)}',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '+${entry.value.toStringAsFixed(1)}%',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  // ✅ 효과 타입 번역 확장
  String _getEffectTypeName(String effectType) {
    switch (effectType) {
      case 'CLIMBING_POWER_MULTIPLY':
        return '등반력';
      case 'success_rate':
      case 'success_rate_bonus':
        return '등반 성공률';
      case 'exp_bonus':
      case 'experience_bonus':
        return '경험치 보너스';
      case 'point_bonus':
        return '포인트 보너스';
      case 'stamina_bonus':
        return '체력 보너스';
      case 'knowledge_bonus':
        return '지식 보너스';
      case 'technique_bonus':
        return '기술 보너스';
      case 'sociality_bonus':
        return '사교성 보너스';
      case 'willpower_bonus':
        return '의지 보너스';
      case 'climbing_time_reduction':
        return '등반 시간 단축';
      default:
        return effectType.replaceAll('_', ' '); // 기본적으로 언더스코어를 공백으로 변경
    }
  }

  // ✅ 게임 스타일 장착 슬롯 (개선)
  Widget _buildEquippedSlots(List<GlobalBadge> equippedBadges, int maxSlots, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '장착 슬롯',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(maxSlots, (index) {
              final isOccupied = index < equippedBadges.length;
              if (isOccupied) {
                final badge = equippedBadges[index];
                return _buildEquippedBadgeSlot(badge, screenWidth);
              } else {
                return _buildEmptySlot(screenWidth);
              }
            }),
          ),
        ],
      ),
    );
  }

  // ✅ 장착된 뱃지 슬롯 (심플화)
  Widget _buildEquippedBadgeSlot(GlobalBadge badge, double screenWidth) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        _showBadgeDetails(badge);
      },
      onLongPress: () {
        HapticFeedbackManager.mediumImpact();
        ref.read(globalUserProvider.notifier).unequipBadge(badge.id);
        _equipController.forward(from: 0);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badge.tier.color,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                badge.iconEmoji,
                style: TextStyle(fontSize: 24),
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: badge.tier.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButtons(double screenWidth) {
    final filters = [
      {'label': '전체', 'tier': null},
      {'label': '일반', 'tier': GlobalBadgeTier.common},
      {'label': '희귀', 'tier': GlobalBadgeTier.rare},
      {'label': '영웅', 'tier': GlobalBadgeTier.epic},
      {'label': '전설', 'tier': GlobalBadgeTier.legendary},
    ];

    return SizedBox(
      height: 28,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['tier'];
          final tier = filter['tier'] as GlobalBadgeTier?;

          return Container(
            margin: EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = tier;
                });
                HapticFeedbackManager.lightImpact();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  filter['label'] as String,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ 리스트 형태의 뱃지 목록 (그리드 대신)
  Widget _buildBadgeList(
      List<GlobalBadge> ownedBadges,
      List<GlobalBadge> equippedBadges,
      int maxSlots,
      double screenWidth
      ) {
    return ListView.builder(
      itemCount: ownedBadges.length,
      itemBuilder: (context, index) {
        final badge = ownedBadges[index];
        final isEquipped = equippedBadges.any((b) => b.id == badge.id);
        final canEquip = equippedBadges.length < maxSlots;
        
        return _buildBadgeListItem(badge, isEquipped, canEquip, screenWidth);
      },
    );
  }

  // ✅ 심플한 뱃지 리스트 아이템
  Widget _buildBadgeListItem(GlobalBadge badge, bool isEquipped, bool canEquip, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedbackManager.lightImpact();
          _showBadgeDetails(badge);
        },
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEquipped ? badge.tier.color : AppColors.primary.withOpacity(0.2),
              width: isEquipped ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // 뱃지 아이콘
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badge.tier.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badge.tier.color, width: 1),
                ),
                child: Center(
                  child: Text(
                    badge.iconEmoji,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(width: 8),
              
              // 뱃지 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.name,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '+${badge.effectValue}% ${_getEffectTypeName(badge.effectType)}',
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 등급 표시
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: badge.tier.color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              
              // 장착/해제 버튼
              SizedBox(
                width: 40,
                height: 24,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedbackManager.mediumImpact();
                    if (isEquipped) {
                      ref.read(globalUserProvider.notifier).unequipBadge(badge.id);
                    } else if (canEquip) {
                      ref.read(globalUserProvider.notifier).equipBadge(badge.id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('뱃지 슬롯이 가득 찼습니다!'),
                          backgroundColor: AppColors.error,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                    _equipController.forward(from: 0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEquipped
                        ? AppColors.error
                        : (canEquip ? AppColors.success : AppColors.textLight),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: Text(
                    isEquipped ? '해제' : (canEquip ? '장착' : '가득'),
                    style: GoogleFonts.notoSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySlot(double screenWidth) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textLight.withOpacity(0.5),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add,
          color: AppColors.textLight,
          size: 20,
        ),
      ),
    );
  }

  // ✅ 팝업으로 뱃지 상세정보 표시 (기존 방식 복원)
  void _showBadgeDetails(GlobalBadge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badge.tier.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: badge.tier.color, width: 2),
              ),
              child: Center(
                child: Text(badge.iconEmoji, style: TextStyle(fontSize: 20)),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.name,
                    style: GoogleFonts.notoSans(fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badge.tier.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badge.tier.color),
                    ),
                    child: Text(
                      badge.tier.displayName,
                      style: GoogleFonts.notoSans(
                        color: badge.tier.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge.description,
                style: GoogleFonts.notoSans(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('✨', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      '효과: ${_getEffectTypeName(badge.effectType)} +${badge.effectValue}%',
                      style: GoogleFonts.notoSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '확인',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
