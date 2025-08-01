import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/available_meeting_model.dart';
import '../../../providers/meeting_creation_provider.dart';

/// 🎯 Step 1: 카테고리 선택 화면
/// 한국 모임 앱 스타일의 대형 카드 기반 카테고리 선택
class Step1CategorySelection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingData = ref.watch(meetingCreationProvider);
    final notifier = ref.read(meetingCreationProvider.notifier);

    // 전체 카테고리 제외
    final categories = MeetingCategory.values.where((cat) => cat != MeetingCategory.all).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 안내 메시지
          _buildGuideMessage(),
          
          const SizedBox(height: 24),
          
          // 카테고리 그리드
          _buildCategoryGrid(categories, meetingData.selectedCategory, notifier),
          
          const SizedBox(height: 32),
          
          // 선택된 카테고리 정보 (선택 시에만 표시)
          if (meetingData.selectedCategory != null)
            _buildSelectedCategoryInfo(meetingData.selectedCategory!),
        ],
      ),
    );
  }

  Widget _buildGuideMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
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
                  '카테고리 선택 팁',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '모임의 주요 활동에 가장 적합한 카테고리를 선택해주세요.\n참가자들이 쉽게 찾을 수 있어요!',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(
    List<MeetingCategory> categories,
    MeetingCategory? selectedCategory,
    MeetingCreationNotifier notifier,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategory == category;
        
        return _CategoryCard(
          category: category,
          isSelected: isSelected,
          onTap: () => notifier.selectCategory(category),
        );
      },
    );
  }

  Widget _buildSelectedCategoryInfo(MeetingCategory category) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${category.displayName} 선택됨',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: category.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getCategoryDescription(category),
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDescription(MeetingCategory category) {
    switch (category) {
      case MeetingCategory.exercise:
        return '운동, 스포츠, 요가, 피트니스 등 몸을 움직이는 활동 모임입니다.';
      case MeetingCategory.study:
        return '공부, 자격증, 언어교환, 토론 등 학습을 위한 모임입니다.';
      case MeetingCategory.reading:
        return '독서, 북클럽, 작가와의 만남 등 책과 관련된 모임입니다.';
      case MeetingCategory.networking:
        return '네트워킹, 친목, 파티, 만남 등 사교활동 모임입니다.';
      case MeetingCategory.culture:
        return '영화, 뮤지컬, 전시회, 공연 등 문화생활 모임입니다.';
      case MeetingCategory.outdoor:
        return '등산, 캠핑, 산책, 여행 등 야외활동 모임입니다.';
      case MeetingCategory.all:
      default:
        return '';
    }
  }
}

/// 카테고리 선택 카드 위젯
class _CategoryCard extends StatefulWidget {
  final MeetingCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onTap();
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: widget.isSelected
                        ? LinearGradient(
                            colors: [
                              widget.category.color,
                              widget.category.color.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: widget.isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isSelected
                          ? widget.category.color
                          : Colors.grey.shade300,
                      width: widget.isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isSelected
                            ? widget.category.color.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: widget.isSelected ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 카테고리 아이콘
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.2)
                              : widget.category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            widget.category.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 카테고리 이름
                      Text(
                        widget.category.displayName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      
                      // 선택됨 표시
                      if (widget.isSelected) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '선택됨',
                                style: GoogleFonts.notoSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}