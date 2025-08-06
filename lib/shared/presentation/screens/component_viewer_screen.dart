import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_colors_2025.dart';
import '../../../features/meetings/models/available_meeting_model.dart';
import '../../widgets/sherpa_clean_app_bar.dart';
import '../../widgets/sherpa_button.dart';
import '../../widgets/components/components.dart';
import '../../widgets/components/molecules/sherpa_meeting_card_2025.dart';
import '../../widgets/components/molecules/sherpa_smart_filter_2025.dart';
import '../../widgets/components/molecules/sherpa_quick_filter_2025.dart';
import '../../widgets/components/molecules/sherpa_category_selector_2025.dart';
import '../../widgets/components/molecules/sherpa_meeting_stats_2025.dart';
import '../../widgets/components/molecules/sherpa_create_meeting_fab_2025.dart';
import '../../widgets/components/molecules/sherpa_ai_recommendation_2025.dart';

// New 2025 Meeting Components
import '../../widgets/components/molecules/meeting_card_2025.dart';
import '../../widgets/components/molecules/meeting_card_hero_2025.dart';
import '../../widgets/components/molecules/meeting_card_compact_2025.dart';
import '../../widgets/components/molecules/meeting_card_list_2025.dart';
import '../../widgets/components/molecules/category_selector_2025.dart';
import '../../widgets/components/molecules/search_bar_2025.dart';
import '../../widgets/components/molecules/create_meeting_fab_2025.dart';
import '../../widgets/components/molecules/participant_avatars_2025.dart';
import '../../utils/meeting_image_manager.dart';

class ComponentViewerScreen extends StatefulWidget {
  const ComponentViewerScreen({Key? key}) : super(key: key);

  @override
  State<ComponentViewerScreen> createState() => _ComponentViewerScreenState();
}

class _ComponentViewerScreenState extends State<ComponentViewerScreen> {
  int selectedCategoryIndex = 0;
  
  final List<Map<String, dynamic>> categories = [
    // ==================== 기존 컴포넌트 ====================
    {'name': '카드', 'icon': Icons.credit_card, 'color': AppColors.primary},
    {'name': '버튼', 'icon': Icons.smart_button, 'color': AppColors.secondary},
    {'name': '입력', 'icon': Icons.edit, 'color': AppColors.success},
    {'name': '칩', 'icon': Icons.label, 'color': AppColors.warning},
    {'name': '아바타', 'icon': Icons.account_circle, 'color': AppColors.info},
    {'name': '다이얼로그', 'icon': Icons.chat_bubble, 'color': AppColors.error},
    
    // ==================== 2025 컴포넌트 (Atoms) ====================
    {'name': '2025 버튼', 'icon': Icons.auto_awesome, 'color': AppColors2025.primary},
    {'name': '2025 입력', 'icon': Icons.input, 'color': AppColors2025.secondary},
    {'name': '2025 검색', 'icon': Icons.search, 'color': AppColors2025.info},
    {'name': '2025 선택', 'icon': Icons.arrow_drop_down_circle, 'color': AppColors2025.warning},
    {'name': '2025 컨테이너', 'icon': Icons.crop_square, 'color': AppColors2025.neuBase},
    {'name': '2025 그리드', 'icon': Icons.grid_view, 'color': AppColors2025.primary},
    {'name': '2025 스택', 'icon': Icons.layers, 'color': AppColors2025.secondary},
    {'name': '2025 진행률', 'icon': Icons.trending_up, 'color': AppColors2025.success},
    {'name': '2025 배지', 'icon': Icons.notifications, 'color': AppColors2025.error},
    {'name': '2025 차트', 'icon': Icons.bar_chart, 'color': AppColors2025.warning},
    {'name': '2025 토스트', 'icon': Icons.message, 'color': AppColors2025.info},
    {'name': '2025 알림', 'icon': Icons.info, 'color': AppColors2025.warning},
    {'name': '2025 모달', 'icon': Icons.open_in_new, 'color': AppColors2025.primary},
    
    // ==================== 2025 컴포넌트 (Molecules) ====================
    {'name': '산악 카드', 'icon': Icons.landscape, 'color': AppColors2025.mountainBlue},
    {'name': '퀘스트 카드', 'icon': Icons.emoji_events, 'color': AppColors2025.warning},
    
    // ==================== 2025 모임 컴포넌트 ====================
    {'name': '모임 카드', 'icon': Icons.group, 'color': AppColors2025.primary},
    {'name': '모임 필터', 'icon': Icons.filter_list, 'color': AppColors2025.secondary},
    {'name': '모임 통계', 'icon': Icons.bar_chart, 'color': AppColors2025.info},
    {'name': '모임 FAB', 'icon': Icons.add, 'color': AppColors2025.success},
    
    // ==================== 새로운 2025 모임 컴포넌트 ====================
    {'name': '2025 모임카드', 'icon': Icons.style, 'color': AppColors2025.primaryLight},
    {'name': '가상 모임탭', 'icon': Icons.preview, 'color': AppColors2025.glassBlue20},
    
    // ==================== 기존 프로그레스 ====================
    {'name': '프로그레스', 'icon': Icons.trending_up, 'color': AppColors2025.success},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SherpaCleanAppBar(
        title: '셰르파 디자인 시스템',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // 헤더 설명
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: SherpaCard.filled(
              backgroundColor: AppColors.primary.withOpacity(0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '셰르파 컴포넌트 라이브러리',
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '일관되고 재사용 가능한 UI 컴포넌트들을 둘러보세요',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 카테고리 칩들
          _buildCategoryChips(),
          
          // 컴포넌트 목록
          Expanded(
            child: _buildComponentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == selectedCategoryIndex;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: SherpaChip(
              label: category['name'],
              variant: SherpaChipVariant.outlined,
              size: SherpaChipSize.large,
              isSelected: isSelected,
              color: category['color'],
              leading: Icon(
                category['icon'],
                size: 16,
                color: isSelected ? Colors.white : category['color'],
              ),
              onTap: () {
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildComponentList() {
    switch (selectedCategoryIndex) {
      // ==================== 기존 컴포넌트 ====================
      case 0: // 카드
        return _buildCardsTab();
      case 1: // 버튼
        return _buildButtonsTab();
      case 2: // 입력
        return _buildInputsTab();
      case 3: // 칩
        return _buildChipsTab();
      case 4: // 아바타
        return _buildAvatarsTab();
      case 5: // 다이얼로그
        return _buildDialogsTab();
        
      // ==================== 2025 컴포넌트 (Atoms) ====================
      case 6: // 2025 버튼
        return _build2025ButtonsTab();
      case 7: // 2025 입력
        return _build2025InputsTab();
      case 8: // 2025 검색
        return _build2025SearchTab();
      case 9: // 2025 선택
        return _build2025SelectTab();
      case 10: // 2025 컨테이너
        return _build2025ContainerTab();
      case 11: // 2025 그리드
        return _build2025GridTab();
      case 12: // 2025 스택
        return _build2025StackTab();
      case 13: // 2025 진행률
        return _build2025ProgressTab();
      case 14: // 2025 배지
        return _build2025BadgeTab();
      case 15: // 2025 차트
        return _build2025ChartTab();
      case 16: // 2025 토스트
        return _build2025ToastTab();
      case 17: // 2025 알림
        return _build2025AlertTab();
      case 18: // 2025 모달
        return _build2025ModalTab();
        
      // ==================== 2025 컴포넌트 (Molecules) ====================
      case 19: // 산악 카드
        return _buildMountainCardsTab();
      case 20: // 퀘스트 카드
        return _build2025QuestCardTab();
        
      // ==================== 2025 모임 컴포넌트 ====================
      case 21: // 모임 카드
        return _buildMeetingCardsTab();
      case 22: // 모임 필터
        return _buildMeetingFiltersTab();
      case 23: // 모임 통계
        return _buildMeetingStatsTab();
      case 24: // 모임 FAB
        return _buildMeetingFABTab();
        
      // ==================== 새로운 2025 모임 컴포넌트 ====================
      case 25: // 2025 모임카드
        return _build2025MeetingCardsTab();
      case 26: // 가상 모임탭
        return _buildVirtualMeetingTab();
        
      // ==================== 기존 프로그레스 ====================
      case 27: // 프로그레스
        return _buildProgressTab();
      default:
        return _buildCardsTab();
    }
  }

  Widget _buildComponentSection(String title, String subtitle, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: SherpaCard.elevated(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  // 카드 탭
  Widget _buildCardsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaCard Variants',
          '다양한 스타일의 카드 컴포넌트',
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SherpaCard.elevated(
                      child: Column(
                        children: [
                          Icon(Icons.favorite, color: AppColors.error, size: 32),
                          const SizedBox(height: 8),
                          Text('Elevated', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SherpaCard.outlined(
                      borderColor: AppColors.success,
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 32),
                          const SizedBox(height: 8),
                          Text('Outlined', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SherpaCard.filled(
                      backgroundColor: AppColors.warning.withOpacity(0.1),
                      child: Column(
                        children: [
                          Icon(Icons.star, color: AppColors.warning, size: 32),
                          const SizedBox(height: 8),
                          Text('Filled', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SherpaCard.glass(
                      child: Column(
                        children: [
                          Icon(Icons.blur_on, color: AppColors.info, size: 32),
                          const SizedBox(height: 8),
                          Text('Glass', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'Special Cards',
          '특수 목적 카드들',
          Column(
            children: [
              SherpaInfoCard(
                title: '운동 완료',
                subtitle: '오늘 30분 운동을 완료했습니다',
                icon: Icon(Icons.fitness_center, color: AppColors.exercise),
                color: AppColors.exercise,
                onTap: () => _showToast('운동 카드 클릭!'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SherpaStatsCard(
                      label: '레벨',
                      value: '12',
                      icon: Icon(Icons.star, color: AppColors.primary),
                      color: AppColors.primary,
                      trend: '+2 이번 주',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SherpaStatsCard(
                      label: '포인트',
                      value: '2,450',
                      icon: Icon(Icons.monetization_on, color: AppColors.success),
                      color: AppColors.success,
                      trend: '+120 오늘',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 버튼 탭
  Widget _buildButtonsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaButton',
          '기본 버튼 컴포넌트',
          Column(
            children: [
              SherpaButton(
                text: '기본 버튼',
                onPressed: () => _showToast('기본 버튼 클릭!'),
              ),
              const SizedBox(height: 12),
              SherpaButton(
                text: '그라데이션 버튼',
                gradient: AppColors.primaryGradient,
                onPressed: () => _showToast('그라데이션 버튼 클릭!'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SherpaButton(
                      text: '성공',
                      backgroundColor: AppColors.success,
                      onPressed: () => _showToast('성공 버튼!'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SherpaButton(
                      text: '경고',
                      backgroundColor: AppColors.warning,
                      onPressed: () => _showToast('경고 버튼!'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SherpaButton(
                text: '로딩 중...',
                isLoading: true,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              SherpaButton(
                text: '비활성화됨',
                onPressed: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 입력 탭
  Widget _buildInputsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaInput',
          '다양한 입력 필드 컴포넌트',
          Column(
            children: [
              SherpaInput.text(
                label: '이름',
                hint: '이름을 입력하세요',
                prefixIcon: Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              SherpaInput.email(
                label: '이메일',
                hint: 'example@email.com',
              ),
              const SizedBox(height: 16),
              SherpaInput.password(
                label: '비밀번호',
                hint: '비밀번호를 입력하세요',
              ),
              const SizedBox(height: 16),
              SherpaInput.search(
                hint: '검색어를 입력하세요',
              ),
              const SizedBox(height: 16),
              SherpaDropdown<String>(
                label: '카테고리',
                hint: '카테고리를 선택하세요',
                prefixIcon: Icon(Icons.category),
                items: ['운동', '독서', '모임', '일기', '기타']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) => _showToast('$value 선택'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 칩 탭
  Widget _buildChipsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaChip Variants',
          '다양한 스타일의 칩 컴포넌트',
          Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SherpaChip(
                    label: 'Filled',
                    variant: SherpaChipVariant.filled,
                    isSelected: true,
                  ),
                  SherpaChip(
                    label: 'Outlined',
                    variant: SherpaChipVariant.outlined,
                    color: AppColors.success,
                  ),
                  SherpaChip(
                    label: 'Soft',
                    variant: SherpaChipVariant.soft,
                    color: AppColors.warning,
                  ),
                  SherpaChip(
                    label: 'Gradient',
                    variant: SherpaChipVariant.gradient,
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'Special Chips',
          '특수 목적 칩들',
          Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SherpaLevelChip(level: 12),
                  SherpaPointChip(points: 2450),
                  SherpaActivityChip(activity: '운동', isCompleted: true),
                  SherpaActivityChip(activity: '독서', isCompleted: false),
                  SherpaChip.category(
                    label: '모임',
                    category: 'meeting',
                    isSelected: true,
                  ),
                  SherpaChip.status(
                    label: '완료',
                    color: AppColors.success,
                    leading: Icon(Icons.check, size: 14, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 아바타 탭
  Widget _buildAvatarsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaAvatar',
          '다양한 크기와 스타일의 아바타',
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      SherpaAvatar.user(
                        name: '김철수',
                        size: SherpaAvatarSize.extraSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('XS', style: GoogleFonts.notoSans(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      SherpaAvatar.user(
                        name: '이영희',
                        size: SherpaAvatarSize.small,
                        showOnlineStatus: true,
                        isOnline: true,
                      ),
                      const SizedBox(height: 8),
                      Text('S', style: GoogleFonts.notoSans(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      SherpaAvatar.user(
                        name: '박민수',
                        size: SherpaAvatarSize.medium,
                      ),
                      const SizedBox(height: 8),
                      Text('M', style: GoogleFonts.notoSans(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      SherpaAvatar.user(
                        name: '정수진',
                        size: SherpaAvatarSize.large,
                        showOnlineStatus: true,
                        isOnline: false,
                      ),
                      const SizedBox(height: 8),
                      Text('L', style: GoogleFonts.notoSans(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      SherpaAvatar.sherpi(
                        size: SherpaAvatarSize.extraLarge,
                        badge: SherpaLevelChip(level: 12, size: SherpaChipSize.small),
                      ),
                      const SizedBox(height: 8),
                      Text('XL', style: GoogleFonts.notoSans(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SherpaAvatar.icon(
                    icon: Icons.person,
                    backgroundColor: AppColors2025.primary,
                  ),
                  const SizedBox(width: 12),
                  SherpaAvatar.icon(
                    icon: Icons.group,
                    backgroundColor: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  SherpaAvatar.icon(
                    icon: Icons.star,
                    backgroundColor: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SherpaGroupAvatar(
                      names: ['김철수', '이영희', '박민수', '정수진', '최영수'],
                      maxDisplay: 3,
                      onTap: () => _showToast('그룹 아바타 클릭!'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 다이얼로그 탭
  Widget _buildDialogsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaDialog',
          '다양한 다이얼로그 컴포넌트',
          Column(
            children: [
              SherpaButton(
                text: '알림 다이얼로그',
                onPressed: () {
                  SherpaDialog.showAlert(
                    context: context,
                    title: '알림',
                    message: '이것은 알림 다이얼로그입니다.',
                    onConfirm: () => _showToast('확인됨!'),
                  );
                },
              ),
              const SizedBox(height: 12),
              SherpaButton(
                text: '확인 다이얼로그',
                backgroundColor: AppColors.warning,
                onPressed: () {
                  SherpaDialog.showConfirm(
                    context: context,
                    title: '확인',
                    message: '정말로 삭제하시겠습니까?',
                    onConfirm: () => _showToast('삭제됨!'),
                    onCancel: () => _showToast('취소됨!'),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SherpaButton(
                      text: '성공',
                      backgroundColor: AppColors.success,
                      onPressed: () {
                        SherpaDialog.showSuccess(
                          context: context,
                          message: '작업이 성공적으로 완료되었습니다!',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SherpaButton(
                      text: '오류',
                      backgroundColor: AppColors.error,
                      onPressed: () {
                        SherpaDialog.showError(
                          context: context,
                          message: '오류가 발생했습니다.',
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SherpaButton(
                text: '로딩 다이얼로그',
                onPressed: () {
                  SherpaLoadingDialog.show(context, message: '처리 중...');
                  Future.delayed(Duration(seconds: 2), () {
                    SherpaLoadingDialog.hide(context);
                    _showToast('완료!');
                  });
                },
              ),
              const SizedBox(height: 12),
              SherpaButton(
                text: '사용자 다이얼로그',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SherpaUserDialog(
                      userName: '김철수',
                      title: '프로필 확인',
                      message: '이 사용자의 프로필을 확인하시겠습니까?',
                      actions: [
                        SherpaDialogAction.secondary(
                          text: '취소',
                          onPressed: () => Navigator.pop(context),
                        ),
                        SherpaDialogAction.primary(
                          text: '확인',
                          onPressed: () {
                            Navigator.pop(context);
                            _showToast('프로필 확인!');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== 새로운 2025 컴포넌트 탭들 ====================

  // 2025 버튼 탭
  Widget _build2025ButtonsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaButton2025 Variants',
          '2025 디자인 트렌드가 반영된 새로운 버튼 시스템',
          Column(
            children: [
              SherpaButton2025.primary(
                text: '프라이머리 버튼',
                onPressed: () => _showToast('프라이머리 버튼 클릭!'),
                icon: Icon(Icons.star),
              ),
              const SizedBox(height: 12),
              SherpaButton2025.secondary(
                text: '세컨더리 버튼',
                onPressed: () => _showToast('세컨더리 버튼 클릭!'),
                icon: Icon(Icons.favorite),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SherpaButton2025.outlined(
                      text: '아웃라인',
                      onPressed: () => _showToast('아웃라인 버튼!'),
                      size: SherpaButtonSize2025.medium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SherpaButton2025.text(
                      text: '텍스트',
                      onPressed: () => _showToast('텍스트 버튼!'),
                      size: SherpaButtonSize2025.medium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SherpaButton2025.floating(
                text: '플로팅 버튼',
                onPressed: () => _showToast('플로팅 버튼!'),
                icon: Icon(Icons.rocket_launch),
              ),
              const SizedBox(height: 12),
              SherpaButton2025.hybrid(
                text: '하이브리드 버튼',
                onPressed: () => _showToast('하이브리드 버튼!'),
                icon: Icon(Icons.auto_awesome),
              ),
              const SizedBox(height: 12),
              SherpaButton2025.gradient(
                text: '그라데이션 버튼',
                onPressed: () => _showToast('그라데이션 버튼!'),
                category: 'exercise',
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'Button Sizes',
          '다양한 크기의 버튼들',
          Column(
            children: [
              SherpaButton2025.primary(
                text: '스몰',
                size: SherpaButtonSize2025.small,
                onPressed: () => _showToast('스몰 버튼!'),
              ),
              const SizedBox(height: 8),
              SherpaButton2025.primary(
                text: '미디움',
                size: SherpaButtonSize2025.medium,
                onPressed: () => _showToast('미디움 버튼!'),
              ),
              const SizedBox(height: 8),
              SherpaButton2025.primary(
                text: '라지',
                size: SherpaButtonSize2025.large,
                onPressed: () => _showToast('라지 버튼!'),
              ),
              const SizedBox(height: 8),
              SherpaButton2025.primary(
                text: '엑스트라 라지',
                size: SherpaButtonSize2025.extraLarge,
                onPressed: () => _showToast('엑스트라 라지 버튼!'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 산악 카드 탭
  Widget _buildMountainCardsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaMountainCard2025',
          '2025 디자인 트렌드 산악 카드',
          Column(
            children: [
              SherpaMountainCard2025.advanced(
                mountainName: '에베레스트',
                progress: 0.65,
                currentLevel: 12,
                onTap: () => _showToast('에베레스트 카드 클릭!'),
              ),
              const SizedBox(height: 16),
              SherpaMountainCard2025.intermediate(
                mountainName: '한라산',
                progress: 0.35,
                currentLevel: 8,
                onTap: () => _showToast('한라산 카드 클릭!'),
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'Different Mountain Types',
          '다양한 산 타입과 스타일',
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SherpaMountainCard2025.beginner(
                      mountainName: '설악산',
                      progress: 0.8,
                      currentLevel: 5,
                      onTap: () => _showToast('설악산 카드 클릭!'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SherpaMountainCard2025.special(
                      mountainName: '지리산',
                      progress: 0.9,
                      currentLevel: 15,
                      onTap: () => _showToast('지리산 카드 클릭!'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 프로그레스 & 성취 탭
  Widget _buildProgressTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'Circular Progress',
          '원형 진행도 표시기',
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SherpaCircularProgress(
                progress: 0.75,
                currentValue: 15,
                targetValue: 20,
                label: '일일 목표',
                color: AppColors2025.success,
                size: 100,
                unit: 'km',
              ),
              SherpaCircularProgress(
                progress: 0.45,
                currentValue: 450,
                targetValue: 1000,
                label: '경험치',
                color: AppColors2025.primary,
                size: 100,
                unit: 'XP',
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'Linear Progress',
          '선형 진행도 바',
          Column(
            children: [
              SherpaLinearProgress(
                progress: 0.68,
                label: '오늘의 운동',
                subtitle: '68% 완료',
                color: AppColors2025.exercise2025,
                style: LinearProgressStyle.glass,
              ),
              const SizedBox(height: 16),
              SherpaLinearProgress(
                progress: 0.9,
                label: '독서 목표',
                subtitle: '90% 완료',
                color: AppColors2025.reading2025,
                style: LinearProgressStyle.neu,
              ),
              const SizedBox(height: 16),
              SherpaXPBar(
                currentXP: 750,
                requiredXP: 1000,
                currentLevel: 12,
                color: AppColors2025.primary,
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'Achievement Badges',
          '성취 배지 시스템',
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SherpaAchievementBadge(
                title: '첫 등반',
                description: '첫 번째 산 등반 완료',
                icon: Icons.landscape,
                color: AppColors2025.success,
                isUnlocked: true,
                rarity: BadgeRarity.common,
                unlockedDate: DateTime.now().subtract(Duration(days: 5)),
                onTap: () => _showToast('첫 등반 배지!'),
              ),
              SherpaAchievementBadge(
                title: '마라토너',
                description: '42km 러닝 완주',
                icon: Icons.directions_run,
                color: AppColors2025.exercise2025,
                isUnlocked: true,
                rarity: BadgeRarity.rare,
                unlockedDate: DateTime.now().subtract(Duration(days: 2)),
                onTap: () => _showToast('마라토너 배지!'),
              ),
              SherpaAchievementBadge(
                title: '독서왕',
                description: '100권 독서 달성',
                icon: Icons.menu_book,
                color: AppColors2025.reading2025,
                isUnlocked: true,
                rarity: BadgeRarity.epic,
                unlockedDate: DateTime.now().subtract(Duration(days: 1)),
                onTap: () => _showToast('독서왕 배지!'),
              ),
              SherpaAchievementBadge(
                title: '전설의 셰르파',
                description: '모든 산 정복',
                icon: Icons.emoji_events,
                color: AppColors2025.sunriseOrange,
                isUnlocked: false,
                rarity: BadgeRarity.legendary,
                onTap: () => _showToast('잠금된 배지!'),
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'Streak Indicator',
          '연속 달성 표시기',
          Row(
            children: [
              Expanded(
                child: SherpaStreakIndicator(
                  streakCount: 15,
                  maxStreak: 28,
                  label: '연속 운동',
                  showFire: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SherpaStreakIndicator(
                  streakCount: 7,
                  maxStreak: 15,
                  label: '일일 목표',
                  showFire: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== 2025 Atoms 컴포넌트 빌더들 ====================
  
  Widget _build2025InputsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaInput2025',
          '2025 디자인 입력 필드',
          Column(
            children: [
              SherpaInput2025(
                label: '사용자명',
                hint: '사용자명을 입력하세요',
                onChanged: (value) => print('입력: $value'),
              ),
              const SizedBox(height: 16),
              SherpaInput2025.password(
                label: '비밀번호',
                hint: '비밀번호를 입력하세요',
                onChanged: (value) => print('비밀번호: $value'),
              ),
              const SizedBox(height: 16),
              SherpaInput2025.multiline(
                label: '메모',
                hint: '메모를 입력하세요',
                maxLines: 3,
                onChanged: (value) => print('메모: $value'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025SearchTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaSearchBar2025',
          '2025 디자인 검색 바',
          Column(
            children: [
              SherpaSearchBar2025(
                hint: '산 이름으로 검색...',
                onChanged: (query) => _showToast('검색: $query'),
                suggestions: ['지리산', '한라산', '설악산', '백두산'],
              ),
              const SizedBox(height: 16),
              SherpaSearchBar2025.floating(
                hint: '운동 종류 검색...',
                onChanged: (query) => _showToast('필터 검색: $query'),
                onFilterTap: () => _showToast('필터 옵션 열기'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025SelectTab() {
    final items = [
      SherpaSelectItem(value: '초급', label: '초급'),
      SherpaSelectItem(value: '중급', label: '중급'),
      SherpaSelectItem(value: '고급', label: '고급'),
      SherpaSelectItem(value: '전문가', label: '전문가'),
    ];
    
    final categoryItems = [
      SherpaSelectItem(value: '운동', label: '운동'),
      SherpaSelectItem(value: '독서', label: '독서'),
      SherpaSelectItem(value: '모임', label: '모임'),
      SherpaSelectItem(value: '일기', label: '일기'),
    ];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaSelect2025',
          '2025 디자인 선택 드롭다운',
          Column(
            children: [
              SherpaSelect2025<String>(
                label: '난이도 선택',
                hint: '난이도를 선택하세요',
                items: items,
                onChanged: (value) => _showToast('선택됨: $value'),
              ),
              const SizedBox(height: 16),
              SherpaSelect2025<String>.single(
                label: '카테고리',
                hint: '카테고리를 선택하세요',
                items: categoryItems,
                onChanged: (value) => _showToast('카테고리: $value'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025ContainerTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaContainer2025',
          '2025 디자인 컨테이너',
          Column(
            children: [
              SherpaContainer2025.basic(
                child: const SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: Center(
                    child: Text('글래스모피즘 컨테이너'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SherpaContainer2025.neu(
                child: const SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: Center(
                    child: Text('뉴모피즘 컨테이너'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SherpaContainer2025.floating(
                child: const SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: Center(
                    child: Text('플로팅 컨테이너'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025GridTab() {
    final items = List.generate(8, (index) => 
      Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors2025.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('Item ${index + 1}'),
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaGrid2025',
          '2025 디자인 그리드',
          SherpaGrid2025(
            children: items,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
        ),
      ],
    );
  }

  Widget _build2025StackTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaStack2025',
          '2025 디자인 스택',
          Column(
            children: [
              SizedBox(
                height: 150,
                child: SherpaStack2025.glass(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors2025.primary.withOpacity(0.1),
                    ),
                    const Center(
                      child: Text('글래스 스택'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: SherpaStack2025.floating(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors2025.secondary.withOpacity(0.1),
                    ),
                    const Center(
                      child: Text('플로팅 스택'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025ProgressTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaProgress2025',
          '2025 디자인 진행률',
          Column(
            children: [
              SherpaProgress2025.linear(
                value: 0.7,
                label: '등반 진행률',
                showPercentage: true,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SherpaProgress2025.circular(
                    value: 0.6,
                    size: SherpaProgressSize2025.small,
                    label: '운동',
                  ),
                  SherpaProgress2025.circular(
                    value: 0.8,
                    size: SherpaProgressSize2025.small,
                    label: '독서',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025BadgeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaNotificationBadge2025',
          '2025 디자인 알림 배지',
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SherpaNotificationBadge2025.count(
                    count: 5,
                    child: const Icon(Icons.notifications, size: 30),
                  ),
                  SherpaNotificationBadge2025.notification(
                    child: const Icon(Icons.message, size: 30),
                  ),
                  SherpaNotificationBadge2025(
                    text: 'NEW',
                    variant: SherpaNotificationBadgeVariant2025.pill,
                    child: const Icon(Icons.star, size: 30),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025ChartTab() {
    final data = [
      SherpaChartData(label: '월', value: 30, color: AppColors2025.primary),
      SherpaChartData(label: '화', value: 45, color: AppColors2025.secondary),
      SherpaChartData(label: '수', value: 25, color: AppColors2025.success),
      SherpaChartData(label: '목', value: 60, color: AppColors2025.warning),
      SherpaChartData(label: '금', value: 35, color: AppColors2025.error),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaChart2025',
          '2025 디자인 차트',
          Column(
            children: [
              SherpaChart2025.bar(
                data: data,
                height: 200,
                title: '주간 운동량',
              ),
              const SizedBox(height: 20),
              SherpaChart2025.line(
                data: data,
                height: 200,
                title: '진행률 추이',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025ToastTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaToast2025',
          '2025 디자인 토스트',
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  SherpaToast2025.success(
                    context,
                    message: '성공적으로 완료되었습니다!',
                  );
                },
                child: const Text('성공 토스트'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  SherpaToast2025.error(
                    context,
                    message: '오류가 발생했습니다.',
                  );
                },
                child: const Text('오류 토스트'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  SherpaToast2025.info(
                    context,
                    message: '새로운 정보가 있습니다.',
                  );
                },
                child: const Text('정보 토스트'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025AlertTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaAlert2025',
          '2025 디자인 알림',
          Column(
            children: [
              SherpaButton2025.primary(
                text: '성공 알림 표시',
                onPressed: () {
                  SherpaAlert2025.success(
                    context,
                    title: '성공',
                    content: '작업이 성공적으로 완료되었습니다.',
                  );
                },
              ),
              const SizedBox(height: 16),
              SherpaButton2025.secondary(
                text: '경고 알림 표시',
                onPressed: () {
                  SherpaAlert2025.warning(
                    context,
                    title: '주의',
                    content: '이 작업은 되돌릴 수 없습니다.',
                  );
                },
              ),
              const SizedBox(height: 16),
              SherpaButton2025.outlined(
                text: '오류 알림 표시',
                onPressed: () {
                  SherpaAlert2025.error(
                    context,
                    title: '오류',
                    content: '네트워크 연결을 확인해주세요.',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build2025ModalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaModal2025',
          '2025 디자인 모달',
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  SherpaModal2025.bottomSheet(
                    context,
                    title: '확인',
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('정말로 삭제하시겠습니까?'),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showToast('삭제됨');
                                },
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('모달 열기'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== 2025 Molecules 컴포넌트 빌더들 ====================


  Widget _build2025QuestCardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaQuestCard2025',
          '2025 디자인 퀘스트 카드',
          Column(
            children: [
              SherpaQuestCard2025.daily(
                questTitle: '오늘의 운동 목표',
                description: '30분 이상 운동하기',
                progress: 0.7,
                currentValue: 21,
                targetValue: 30,
                progressUnit: '분',
                onStart: () => _showToast('퀘스트 시작'),
              ),
              const SizedBox(height: 16),
              SherpaQuestCard2025.weekly(
                questTitle: '주간 독서 챌린지',
                description: '3권 이상 책 읽기',
                progress: 0.33,
                currentValue: 1,
                targetValue: 3,
                progressUnit: '권',
                onStart: () => _showToast('주간 퀘스트 시작'),
              ),
              const SizedBox(height: 16),
              SherpaQuestCard2025.special(
                questTitle: '특별 등반 이벤트',
                description: '백두산 정상 정복하기',
                progress: 0.15,
                timeLeft: const Duration(days: 5, hours: 12),
                onStart: () => _showToast('특별 퀘스트 시작'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== 2025 모임 컴포넌트 빌더들 ====================

  Widget _buildMeetingCardsTab() {
    // Sample meeting data
    final sampleMeeting = AvailableMeeting(
      id: 'meeting_001',
      title: '한강 러닝 모임',
      description: '한강공원에서 함께 러닝하며 건강한 하루를 시작해보세요!',
      category: MeetingCategory.exercise,
      type: MeetingType.free,
      scope: MeetingScope.public,
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 6)),
      location: '한강공원 반포지구',
      detailedLocation: '한강공원 반포지구 잠수교 아래',
      hostId: 'user_123',
      hostName: '김러너',
      maxParticipants: 12,
      currentParticipants: 8,
      price: 0,
      requirements: ['운동화 착용', '개인 물병'],
      tags: ['운동', '러닝', '한강', '아침'],
    );

    final sampleMeetingPaid = AvailableMeeting(
      id: 'meeting_002',
      title: '스타트업 네트워킹 모임',
      description: '스타트업 창업자들과 예비창업자들이 모여 네트워킹하는 시간',
      category: MeetingCategory.networking,
      type: MeetingType.paid,
      scope: MeetingScope.university,
      dateTime: DateTime.now().add(const Duration(days: 5, hours: 19)),
      location: '강남역 근처 카페',
      detailedLocation: '강남역 2번 출구 앞 스타벅스',
      hostId: 'user_456',
      hostName: '박스타트업',
      maxParticipants: 20,
      currentParticipants: 15,
      price: 15000,
      requirements: ['명함 지참', '사업계획서 개요'],
      tags: ['네트워킹', '스타트업', '창업', '비즈니스'],
    );

    final sampleMeetingReading = AvailableMeeting(
      id: 'meeting_003',
      title: '독서 토론 모임',
      description: '책을 통한 성장과 사람들과의 소통을 경험해보세요',
      category: MeetingCategory.reading,
      type: MeetingType.paid,
      scope: MeetingScope.public,
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
      location: '홍대 카페',
      detailedLocation: '홍대입구역 9번 출구 앞 책읽는곰 카페',
      hostId: 'user_789',
      hostName: '이독서',
      maxParticipants: 10,
      currentParticipants: 6,
      price: 5000,
      requirements: ['읽을 책 지참', '노트 준비'],
      tags: ['독서', '토론', '자기계발', '소통'],
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaMeetingCard2025 Variants',
          '2025 디자인 트렌드를 반영한 모임 카드 컴포넌트',
          Column(
            children: [
              SherpaMeetingCard2025.standard(
                meeting: sampleMeeting,
                onTap: () => _showToast('한강 러닝 모임 클릭!'),
                onLike: () => _showToast('좋아요!'),
                isLiked: false,
                category: 'exercise',
              ),
              const SizedBox(height: 16),
              SherpaMeetingCard2025.recommended(
                meeting: sampleMeetingPaid,
                onTap: () => _showToast('스타트업 네트워킹 모임 클릭!'),
                onLike: () => _showToast('추천 모임 좋아요!'),
                isLiked: true,
                category: 'networking',
              ),
              const SizedBox(height: 16),
              SherpaMeetingCard2025.compact(
                meeting: sampleMeeting,
                onTap: () => _showToast('컴팩트 카드 클릭!'),
                category: 'exercise',
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'Meeting Card Sizes',
          '다양한 크기의 모임 카드',
          Column(
            children: [
              SherpaMeetingCard2025(
                meeting: sampleMeeting,
                onTap: () => _showToast('스몰 카드!'),
                size: SherpaMeetingCardSize.small,
                category: 'exercise',
              ),
              const SizedBox(height: 12),
              SherpaMeetingCard2025(
                meeting: sampleMeetingPaid,
                onTap: () => _showToast('미디움 카드!'),
                size: SherpaMeetingCardSize.medium,
                category: 'networking',
              ),
              const SizedBox(height: 12),
              SherpaMeetingCard2025(
                meeting: sampleMeeting,
                onTap: () => _showToast('라지 카드!'),
                size: SherpaMeetingCardSize.large,
                onLike: () => _showToast('라지 카드 좋아요!'),
                onShare: () => _showToast('공유하기!'),
                onBookmark: () => _showToast('북마크!'),
                category: 'exercise',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingFiltersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaSmartFilter2025',
          '스마트 검색 및 필터링 시스템',
          Column(
            children: [
              SherpaSmartFilter2025.standard(
                searchQuery: '',
                onSearchChanged: (query) => _showToast('검색: $query'),
                onOnlineToggle: (value) => _showToast('온라인 필터: $value'),
                onDetailedFiltersToggle: (value) => _showToast('상세 필터: $value'),
                category: 'exercise',
              ),
              const SizedBox(height: 20),
              SherpaSmartFilter2025.modern(
                searchQuery: '',
                onSearchChanged: (query) => _showToast('모던 검색: $query'),
                onVoiceSearch: () => _showToast('음성 검색 시작!'),
                category: 'networking',
              ),
              const SizedBox(height: 20),
              SherpaSmartFilter2025.compact(
                searchQuery: '',
                onSearchChanged: (query) => _showToast('컴팩트 검색: $query'),
                onOnlineToggle: (value) => _showToast('온라인 토글: $value'),
                category: 'study',
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'SherpaQuickFilter2025',
          '빠른 필터링 시스템',
          Column(
            children: [
              SherpaQuickFilter2025.korean(
                activeFilters: {'weekend', 'free'},
                onFiltersChanged: (filters) => _showToast('필터 변경: ${filters.join(', ')}'),
                onFilterToggle: (filter) => _showToast('필터 토글: $filter'),
                category: 'all',
              ),
              const SizedBox(height: 20),
              SherpaQuickFilter2025.modern(
                items: [
                  const SherpaQuickFilterItem2025(
                    key: 'beginner',
                    label: '초보자',
                    icon: Icons.star_border,
                    color: Colors.blue,
                  ),
                  const SherpaQuickFilterItem2025(
                    key: 'advanced',
                    label: '고수',
                    icon: Icons.star,
                    color: Colors.orange,
                  ),
                  const SherpaQuickFilterItem2025(
                    key: 'premium',
                    label: '프리미엄',
                    icon: Icons.diamond,
                    color: Colors.purple,
                  ),
                ],
                activeFilters: {'beginner'},
                onFiltersChanged: (filters) => _showToast('모던 필터: ${filters.join(', ')}'),
                category: 'exercise',
              ),
            ],
          ),
        ),
        
      ],
    );
  }

  Widget _buildMeetingStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaMeetingStats2025',
          '모임 통계 대시보드 컴포넌트',
          Column(
            children: [
              SherpaMeetingStats2025.meeting(
                joinedMeetings: 24,
                thisMonthCount: 8,
                socialityLevel: 7,
                userName: '김셰르파',
                onTap: () => _showToast('모임 통계 클릭!'),
                category: 'networking',
              ),
              const SizedBox(height: 20),
              SherpaMeetingStats2025.detailed(
                statsItems: [
                  const SherpaStatsItem2025(
                    key: 'total_meetings',
                    label: '총 참여',
                    value: '45회',
                    icon: Icons.group,
                    color: Colors.blue,
                    trend: StatsTrend.up,
                  ),
                  const SherpaStatsItem2025(
                    key: 'this_week',
                    label: '이번 주',
                    value: '3회',
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    trend: StatsTrend.up,
                  ),
                  const SherpaStatsItem2025(
                    key: 'favorite_category',
                    label: '운동',
                    value: '18회',
                    icon: Icons.fitness_center,
                    color: Colors.orange,
                    trend: StatsTrend.neutral,
                  ),
                  const SherpaStatsItem2025(
                    key: 'social_level',
                    label: '사교성',
                    value: 'Lv.9',
                    icon: Icons.emoji_people,
                    color: Colors.purple,
                    trend: StatsTrend.up,
                    currentValue: 9.0,
                    maxValue: 10.0,
                  ),
                ],
                title: '상세 모임 통계',
                subtitle: '더 많은 정보가 포함된 통계',
                onTap: () => _showToast('상세 통계 클릭!'),
                category: 'all',
              ),
              const SizedBox(height: 20),
              SherpaMeetingStats2025.compact(
                statsItems: [
                  const SherpaStatsItem2025(
                    key: 'quick_stat1',
                    label: '참여',
                    value: '12',
                    icon: Icons.people,
                  ),
                  const SherpaStatsItem2025(
                    key: 'quick_stat2',
                    label: '레벨',
                    value: '5',
                    icon: Icons.star,
                  ),
                ],
                category: 'exercise',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingFABTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          'SherpaCreateMeetingFAB2025',
          '모임 생성 플로팅 액션 버튼',
          Column(
            children: [
              Container(
                height: 200,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors2025.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors2025.border),
                      ),
                      child: const Center(
                        child: Text('모임 생성 FAB 예시 영역'),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: SherpaCreateMeetingFAB2025.standard(
                        onPressed: () => _showToast('모임 생성 FAB 클릭!'),
                        category: 'exercise',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors2025.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors2025.border),
                      ),
                      child: const Center(
                        child: Text('확장형 FAB 예시 영역'),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: SherpaCreateMeetingFAB2025.extended(
                        onPressed: () => _showToast('확장형 FAB 클릭!'),
                        label: '새 모임 만들기',
                        category: 'networking',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors2025.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors2025.border),
                      ),
                      child: const Center(
                        child: Text('미니 FAB 예시 영역'),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: SherpaCreateMeetingFAB2025.mini(
                        onPressed: () => _showToast('미니 FAB 클릭!'),
                        category: 'study',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'AI 추천 컴포넌트',
          'AI 기반 모임 추천 시스템',
          Column(
            children: [
              SherpaAIRecommendation2025.personalized(
                recommendations: [
                  SherpaAIRecommendationItem2025(
                    id: 'rec_001',
                    meeting: AvailableMeeting(
                      id: 'ai_meeting_001',
                      title: '한강 러닝 모임',
                      description: '한강공원에서 함께 러닝하며 건강한 하루를 시작해보세요!',
                      category: MeetingCategory.exercise,
                      type: MeetingType.free,
                      scope: MeetingScope.public,
                      dateTime: DateTime.now().add(const Duration(days: 2, hours: 6)),
                      location: '한강공원 반포지구',
                      detailedLocation: '한강공원 반포지구 잠수교 아래',
                      hostId: 'user_123',
                      hostName: '김러너',
                      maxParticipants: 12,
                      currentParticipants: 8,
                      price: 0,
                      requirements: ['운동화 착용', '개인 물병'],
                      tags: ['운동', '러닝', '한강', '아침'],
                    ),
                    reason: '당신의 운동 패턴과 95% 일치합니다',
                    confidenceScore: 0.92,
                    type: SherpaAIRecommendationType.personalized,
                  ),
                  SherpaAIRecommendationItem2025(
                    id: 'rec_002',
                    meeting: AvailableMeeting(
                      id: 'ai_meeting_002',
                      title: '스타트업 네트워킹 모임',
                      description: '스타트업 창업자들과 예비창업자들이 모여 네트워킹하는 시간',
                      category: MeetingCategory.networking,
                      type: MeetingType.paid,
                      scope: MeetingScope.university,
                      dateTime: DateTime.now().add(const Duration(days: 5, hours: 19)),
                      location: '강남역 근처 카페',
                      detailedLocation: '강남역 2번 출구 앞 스타벅스',
                      hostId: 'user_456',
                      hostName: '박스타트업',
                      maxParticipants: 20,
                      currentParticipants: 15,
                      price: 15000,
                      requirements: ['명함 지참', '사업계획서 개요'],
                      tags: ['네트워킹', '스타트업', '창업', '비즈니스'],
                    ),
                    reason: '비슷한 관심사를 가진 사람들과 만나보세요',
                    confidenceScore: 0.87,
                    type: SherpaAIRecommendationType.personalized,
                  ),
                ],
                onRecommendationTap: (item) => _showToast('AI 추천: ${item.meeting.title}'),
                onRefresh: () => _showToast('추천 새로고침!'),
                category: 'all',
              ),
              const SizedBox(height: 20),
              SherpaAIRecommendation2025.similar(
                recommendations: [
                  SherpaAIRecommendationItem2025(
                    id: 'rec_003',
                    meeting: AvailableMeeting(
                      id: 'ai_meeting_003',
                      title: '독서 토론 모임',
                      description: '책을 통한 성장과 사람들과의 소통을 경험해보세요',
                      category: MeetingCategory.reading,
                      type: MeetingType.paid,
                      scope: MeetingScope.public,
                      dateTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
                      location: '홍대 카페',
                      detailedLocation: '홍대입구역 9번 출구 앞 책읽는곰 카페',
                      hostId: 'user_789',
                      hostName: '이독서',
                      maxParticipants: 10,
                      currentParticipants: 6,
                      price: 5000,
                      requirements: ['읽을 책 지참', '노트 준비'],
                      tags: ['독서', '토론', '자기계발', '소통'],
                    ),
                    reason: '책을 통한 성장을 추구하시는군요',
                    confidenceScore: 0.89,
                    type: SherpaAIRecommendationType.similar,
                  ),
                ],
                onRecommendationTap: (item) => _showToast('컴팩트 추천: ${item.meeting.title}'),
                category: 'reading',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingSelectorsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        ComponentSection(
          title: 'Category Selector - Meeting',
          child: SherpaCategorySelector2025.meeting(
            selectedCategoryKey: 'exercise',
            onCategoryChanged: (category) {
              print('Selected category: $category');
            },
            categoryCounts: {
              'all': 42,
              'exercise': 12,
              'study': 8,
              'hobby': 15,
              'culture': 7,
            },
          ),
        ),
        SizedBox(height: 24),
        ComponentSection(
          title: 'Category Selector - Modern',
          child: SherpaCategorySelector2025.modern(
            categories: [
              SherpaCategoryItem2025(
                key: 'all',
                label: '전체',
                emoji: '🌟',
                color: AppColors2025.primary,
                count: 42,
              ),
              SherpaCategoryItem2025(
                key: 'exercise',
                label: '운동',
                emoji: '💪',
                color: AppColors2025.success,
                count: 12,
              ),
              SherpaCategoryItem2025(
                key: 'study',
                label: '공부',
                emoji: '📚',
                color: Colors.blue,
                count: 8,
              ),
            ],
            selectedCategoryKey: 'study',
            onCategoryChanged: (category) {
              print('Selected category: $category');
            },
          ),
        ),
        SizedBox(height: 24),
        ComponentSection(
          title: 'Category Selector - Compact',
          child: SherpaCategorySelector2025.compact(
            categories: [
              SherpaCategoryItem2025(
                key: 'all',
                label: '전체',
                emoji: '🌟',
                color: AppColors2025.primary,
                count: 42,
              ),
              SherpaCategoryItem2025(
                key: 'exercise',
                label: '운동',
                emoji: '💪',
                color: AppColors2025.success,
                count: 12,
              ),
            ],
            selectedCategoryKey: 'exercise',
            onCategoryChanged: (category) {
              print('Selected category: $category');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingFABsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        ComponentSection(
          title: 'Create Meeting FAB - Standard',
          child: Container(
            height: 200,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors2025.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors2025.border),
                  ),
                  child: Center(
                    child: Text('모임 생성 FAB 예시 영역'),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: SherpaCreateMeetingFAB2025.standard(
                    onPressed: () => _showToast('모임 생성 FAB 클릭!'),
                    category: 'exercise',
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),
        ComponentSection(
          title: 'Create Meeting FAB - Extended',
          child: Container(
            height: 200,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors2025.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors2025.border),
                  ),
                  child: Center(
                    child: Text('확장형 FAB 예시 영역'),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: SherpaCreateMeetingFAB2025.extended(
                    onPressed: () => _showToast('확장형 FAB 클릭!'),
                    label: '새 모임 만들기',
                    category: 'networking',
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),
        ComponentSection(
          title: 'Create Meeting FAB - Mini',
          child: Container(
            height: 200,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors2025.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors2025.border),
                  ),
                  child: Center(
                    child: Text('미니 FAB 예시 영역'),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: SherpaCreateMeetingFAB2025.mini(
                    onPressed: () => _showToast('미니 FAB 클릭!'),
                    category: 'study',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingAITab() {
    // Sample meeting data for AI recommendations
    final sampleMeeting = AvailableMeeting(
      id: 'meeting_ai_001',
      title: 'JavaScript 스터디 모임',
      description: 'JavaScript 기초부터 고급까지 함께 공부해요',
      category: MeetingCategory.study,
      type: MeetingType.free,
      scope: MeetingScope.public,
      dateTime: DateTime.now().add(const Duration(days: 4, hours: 19)),
      location: '강남역 스터디카페',
      detailedLocation: '강남역 2번 출구 토즈 스터디센터',
      hostId: 'user_ai_001',
      hostName: '김개발',
      maxParticipants: 15,
      currentParticipants: 8,
      price: 0,
      requirements: ['개인 노트북', '기본 프로그래밍 지식'],
      tags: ['JavaScript', '스터디', '개발', '프로그래밍'],
    );
    
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        ComponentSection(
          title: 'AI Recommendation - Personalized',
          child: SherpaAIRecommendation2025.personalized(
            recommendations: [
              SherpaAIRecommendationItem2025(
                id: 'rec1',
                meeting: sampleMeeting,
                reason: 'JavaScript 관련 활동을 자주 하셔서 추천드려요',
                confidenceScore: 0.85,
                type: SherpaAIRecommendationType.personalized,
              ),
            ],
            onRecommendationTap: (item) {
              print('AI recommendation tapped: ${item.meeting.title}');
            },
          ),
        ),
        SizedBox(height: 24),
        ComponentSection(
          title: 'AI Recommendation - Trending',
          child: SherpaAIRecommendation2025.trending(
            recommendations: [
              SherpaAIRecommendationItem2025(
                id: 'rec2',
                meeting: sampleMeeting,
                reason: '지금 가장 인기있는 모임이에요',
                confidenceScore: 0.92,
                type: SherpaAIRecommendationType.trending,
              ),
            ],
            onRecommendationTap: (item) {
              print('AI recommendation tapped: ${item.meeting.title}');
            },
          ),
        ),
        SizedBox(height: 24),
        ComponentSection(
          title: 'AI Recommendation - Nearby',
          child: SherpaAIRecommendation2025.nearby(
            recommendations: [
              SherpaAIRecommendationItem2025(
                id: 'rec3',
                meeting: sampleMeeting,
                reason: '집 근처에서 진행되는 모임이에요',
                confidenceScore: 0.78,
                type: SherpaAIRecommendationType.nearby,
              ),
            ],
            onRecommendationTap: (item) {
              print('AI recommendation tapped: ${item.meeting.title}');
            },
          ),
        ),
        SizedBox(height: 24),
        ComponentSection(
          title: 'AI Recommendation - Similar',
          child: SherpaAIRecommendation2025.similar(
            recommendations: [
              SherpaAIRecommendationItem2025(
                id: 'rec4',
                meeting: sampleMeeting,
                reason: '비슷한 관심사를 가진 사람들과 만나보세요',
                confidenceScore: 0.88,
                type: SherpaAIRecommendationType.similar,
              ),
            ],
            onRecommendationTap: (item) {
              print('AI recommendation tapped: ${item.meeting.title}');
            },
          ),
        ),
        SizedBox(height: 24),
        ComponentSection(
          title: 'AI Recommendation - Loading',
          child: SherpaAIRecommendation2025.loading(),
        ),
      ],
    );
  }

  // Helper widget for component sections
  Widget ComponentSection({required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ==================== 새로운 2025 모임 컴포넌트 ====================
  Widget _build2025MeetingCardsTab() {
    // Sample meeting data with various images
    final sampleMeetings = [
      AvailableMeeting(
        id: 'meeting_2025_001',
        title: '한강 일출 러닝 모임',
        description: '새벽 한강에서 함께 러닝하며 건강한 하루를 시작해보세요! 일출과 함께하는 특별한 경험이 기다립니다.',
        category: MeetingCategory.exercise,
        type: MeetingType.free,
        scope: MeetingScope.public,
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 6)),
        location: '한강공원 반포지구',
        detailedLocation: '한강공원 반포지구 잠수교 아래 분수대 앞',
        hostId: 'user_2025_001',
        hostName: '김러닝',
        maxParticipants: 15,
        currentParticipants: 8,
        price: 0,
        requirements: ['운동화 착용', '개인 물병', '운동복'],
        tags: ['운동', '러닝', '한강', '일출', '건강'],
      ),
      AvailableMeeting(
        id: 'meeting_2025_002',
        title: 'AI 스타트업 네트워킹',
        description: 'AI 분야 스타트업 창업자들과 예비창업자들이 모여 인사이트를 나누는 프리미엄 네트워킹 모임입니다.',
        category: MeetingCategory.networking,
        type: MeetingType.paid,
        scope: MeetingScope.university,
        dateTime: DateTime.now().add(const Duration(days: 5, hours: 19)),
        location: '강남 테헤란로',
        detailedLocation: '강남역 2번 출구 앞 스타벅스 리저브',
        hostId: 'user_2025_002',
        hostName: '박AI',
        maxParticipants: 20,
        currentParticipants: 18,
        price: 25000,
        requirements: ['명함 지참', '사업계획서 개요', '노트북'],
        tags: ['네트워킹', 'AI', '스타트업', '창업', '기술'],
      ),
      AvailableMeeting(
        id: 'meeting_2025_003',
        title: '북촌 한옥마을 사진 워크샵',
        description: '북촌 한옥마을을 배경으로 한 사진 촬영 기법을 배우고 실습하는 문화 모임입니다.',
        category: MeetingCategory.culture,
        type: MeetingType.paid,
        scope: MeetingScope.public,
        dateTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
        location: '북촌 한옥마을',
        detailedLocation: '안국역 3번 출구 북촌문화센터 앞',
        hostId: 'user_2025_003',
        hostName: '이사진',
        maxParticipants: 12,
        currentParticipants: 6,
        price: 15000,
        requirements: ['카메라 또는 스마트폰', '편한 신발', '충전기'],
        tags: ['사진', '문화', '한옥', '워크샵', '예술'],
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComponentSection(
          '2025 Meeting Cards - Modern Design',
          'Glassmorphism, Neumorphism, 3D 효과를 적용한 최신 모임 카드 컴포넌트',
          Column(
            children: [
              // Glassmorphism Card
              MeetingCard2025(
                meeting: sampleMeetings[0],
                imageAsset: 'assets/images/meeting/1.jpg',
                onTap: () => _showToast('${sampleMeetings[0].title} 카드 클릭!'),
                onBookmark: () => _showToast('북마크 추가!'),
                isBookmarked: false,
              ),
              
              const SizedBox(height: 20),
              
              // Hero Card with 3D effects
              MeetingCardHero2025(
                meeting: sampleMeetings[1],
                imageAsset: 'assets/images/meeting/2.jpg',
                onTap: () => _showToast('${sampleMeetings[1].title} 히어로 카드 클릭!'),
                onShare: () => _showToast('공유하기!'),
                onBookmark: () => _showToast('북마크 토글!'),
                isBookmarked: true,
              ),
              
              const SizedBox(height: 20),
              
              // Compact Neumorphism Card
              MeetingCardCompact2025(
                meeting: sampleMeetings[2],
                imageAsset: 'assets/images/meeting/3.jpg',
                onTap: () => _showToast('${sampleMeetings[2].title} 컴팩트 카드 클릭!'),
                onQuickJoin: () => _showToast('빠른 참여!'),
                showQuickJoin: true,
              ),
              
              const SizedBox(height: 20),
              
              // List Style Cards
              MeetingCardList2025(
                meeting: sampleMeetings[0],
                imageAsset: 'assets/images/meeting/4.jpg',
                onTap: () => _showToast('${sampleMeetings[0].title} 리스트 카드 클릭!'),
                onBookmark: () => _showToast('리스트 북마크!'),
                isBookmarked: false,
                showDivider: true,
              ),
              
              MeetingCardList2025(
                meeting: sampleMeetings[1],
                imageAsset: 'assets/images/meeting/5.jpg',
                onTap: () => _showToast('${sampleMeetings[1].title} 리스트 카드 클릭!'),
                onBookmark: () => _showToast('리스트 북마크!'),
                isBookmarked: true,
                showDivider: true,
              ),
              
              MeetingCardList2025(
                meeting: sampleMeetings[2],
                imageAsset: 'assets/images/meeting/6.jpg',
                onTap: () => _showToast('${sampleMeetings[2].title} 리스트 카드 클릭!'),
                onBookmark: () => _showToast('리스트 북마크!'),
                isBookmarked: false,
                showDivider: false,
              ),
            ],
          ),
        ),
        
        _buildComponentSection(
          'Interactive Components',
          '검색, 카테고리 선택, FAB 등 상호작용 컴포넌트',
          Column(
            children: [
              // Modern Search Bar
              SearchBar2025(
                hintText: '모임을 검색해보세요...',
                onChanged: (query) => _showToast('검색: $query'),
                onSubmitted: (query) => _showToast('검색 실행: $query'),
                onFilterTap: () => _showToast('필터 버튼 클릭!'),
                onMicTap: () => _showToast('음성 검색!'),
                showFilter: true,
                showMic: true,
                showSuggestions: true,
                suggestions: ['한강 러닝', 'AI 스타트업', '북촌 사진', '독서 모임', '요가 클래스'],
              ),
              
              const SizedBox(height: 20),
              
              // Category Selector
              CategorySelector2025(
                categories: MeetingCategory.values,
                selectedCategory: MeetingCategory.exercise,
                onCategorySelected: (category) => _showToast('카테고리 선택: ${(category as MeetingCategory).displayName}'),
                isScrollable: true,
              ),
              
              const SizedBox(height: 20),
              
              // FAB Examples
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Text('FAB 예시 영역'),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: CreateMeetingFAB2025(
                        onTap: () => _showToast('모임 생성 FAB 클릭!'),
                        showPulse: true,
                        tooltip: '새 모임 만들기',
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: CircularActionButton2025(
                        icon: Icons.filter_list,
                        onTap: () => _showToast('필터 버튼!'),
                        backgroundColor: Colors.blue,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualMeetingTab() {
    // Complete virtual meeting tab implementation
    final imageManager = MeetingImageManager();
    final sampleMeetings = [
      AvailableMeeting(
        id: 'virtual_001',
        title: '새벽 요가 & 명상 모임',
        description: '하루를 평온하게 시작하는 요가와 명상 시간을 함께해요.',
        category: MeetingCategory.exercise,
        type: MeetingType.free,
        scope: MeetingScope.public,
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 7)),
        location: '한강공원 여의도',
        detailedLocation: '여의도 한강공원 물빛광장',
        hostId: 'yoga_master',
        hostName: '김요가',
        maxParticipants: 20,
        currentParticipants: 12,
        price: 0,
        requirements: ['요가매트', '편한 복장', '물병'],
        tags: ['요가', '명상', '새벽', '힐링'],
      ),
      AvailableMeeting(
        id: 'virtual_002',
        title: 'React Native 개발 스터디',
        description: 'React Native로 실제 앱을 만들어보는 실무 중심 스터디입니다.',
        category: MeetingCategory.study,
        type: MeetingType.paid,
        scope: MeetingScope.university,
        dateTime: DateTime.now().add(const Duration(days: 3, hours: 19)),
        location: '강남역 스터디카페',
        detailedLocation: '강남역 2번 출구 토즈 스터디센터 5층',
        hostId: 'dev_guru',
        hostName: '박개발',
        maxParticipants: 12,
        currentParticipants: 10,
        price: 20000,
        requirements: ['노트북', '개발환경 세팅', 'JavaScript 기초지식'],
        tags: ['React Native', '앱개발', '스터디', '실무'],
      ),
      AvailableMeeting(
        id: 'virtual_003',
        title: '한남동 카페투어 & 독서모임',
        description: '감성 가득한 한남동 카페들을 돌아다니며 책에 대해 이야기해요.',
        category: MeetingCategory.reading,
        type: MeetingType.paid,
        scope: MeetingScope.public,
        dateTime: DateTime.now().add(const Duration(days: 4, hours: 15)),
        location: '한남동 일대',
        detailedLocation: '한남동 블루보틀 카페 앞 집합',
        hostId: 'book_lover',
        hostName: '이독서',
        maxParticipants: 8,
        currentParticipants: 5,
        price: 15000,
        requirements: ['이달의 선정 도서', '노트', '카페비 개인부담'],
        tags: ['독서', '카페투어', '한남동', '토론'],
      ),
      AvailableMeeting(
        id: 'virtual_004',
        title: '홍대 힙합 댄스 배틀',
        description: '홍대에서 열리는 힙합 댄스 배틀! 초보자도 환영합니다.',
        category: MeetingCategory.culture,
        type: MeetingType.free,
        scope: MeetingScope.public,
        dateTime: DateTime.now().add(const Duration(days: 6, hours: 20)),
        location: '홍대 놀이터',
        detailedLocation: '홍익대학교 정문 앞 놀이터',
        hostId: 'dance_battle',
        hostName: '최힙합',
        maxParticipants: 30,
        currentParticipants: 18,
        price: 0,
        requirements: ['편한 복장', '운동화', '타올'],
        tags: ['힙합', '댄스', '배틀', '홍대'],
      ),
      AvailableMeeting(
        id: 'virtual_005',
        title: '남산 등반 & 야경감상',
        description: '남산을 함께 등반하고 서울의 아름다운 야경을 감상하는 모임입니다.',
        category: MeetingCategory.outdoor,
        type: MeetingType.free,
        scope: MeetingScope.public,
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 18)),
        location: '남산 입구',
        detailedLocation: '명동역 3번 출구 남산 케이블카 입구',
        hostId: 'mountain_lover',
        hostName: '김등반',
        maxParticipants: 15,
        currentParticipants: 9,
        price: 0,
        requirements: ['등산화', '물병', '간단한 간식'],
        tags: ['등반', '남산', '야경', '아웃도어'],
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Search
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                child: SearchBar2025(
                  hintText: '러닝, 스터디, 독서모임... 함께할 사람들 찾기',
                  onChanged: (query) => _showToast('검색: $query'),
                  onFilterTap: () => _showToast('필터'),
                  showFilter: true,
                  showMic: false,
                  margin: EdgeInsets.zero, // 마진 제거로 오버플로우 방지
                ),
              ),
            ),
          ),
          
          // Category Selector
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CategorySelector2025(
                categories: MeetingCategory.values,
                selectedCategory: MeetingCategory.all,
                onCategorySelected: (category) => _showToast('카테고리: ${(category as MeetingCategory).displayName}'),
                isScrollable: true,
              ),
            ),
          ),
          
          // Featured Meeting (Hero Card)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: MeetingCardHero2025(
                meeting: sampleMeetings[0],
                imageAsset: imageManager.getImageForMeeting(sampleMeetings[0]),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/meeting_detail',
                  arguments: sampleMeetings[0],
                ),
                onShare: () => _showToast('공유하기'),
                onBookmark: () => _showToast('북마크'),
                isBookmarked: false,
              ),
            ),
          ),
          
          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🎯 나에게 딱 맞는 모임',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/meeting_list_all',
                        arguments: {
                          'sectionTitle': '나에게 딱 맞는 모임',
                          'category': null,
                        },
                      );
                    },
                    child: Text(
                      '전체보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors2025.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Regular Meeting Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= 2) return null; // 2개만 표시
                final meeting = sampleMeetings[index + 1];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MeetingCard2025(
                    meeting: meeting,
                    imageAsset: imageManager.getOptimizedImageForSection(meeting.category, 1, index),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/meeting_detail',
                      arguments: meeting,
                    ),
                    onBookmark: () => _showToast('북마크 ${meeting.title}'),
                    isBookmarked: index % 2 == 0,
                  ),
                );
              },
              childCount: 2, // 2개만 표시
            ),
          ),
          
          // 빠른 참여 섹션 헤더
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1), // 디버깅용 배경색
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '⚡ 빠른 참여',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // 명확한 색상 설정
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors2025.meeting2025.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors2025.meeting2025.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '지금 바로 참여 🚀',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        color: AppColors2025.meeting2025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= 2) return null;
                
                // 안전한 인덱스 접근을 위해 확인
                final meetingIndex = index + 2;
                if (meetingIndex >= sampleMeetings.length) return null;
                
                final meeting = sampleMeetings[meetingIndex];
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: MeetingCardCompact2025(
                    meeting: meeting,
                    imageAsset: imageManager.getOptimizedImageForSection(meeting.category, 2, index),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/meeting_detail',
                      arguments: meeting,
                    ),
                    onQuickJoin: () => _showQuickJoinDialog(meeting),
                    showQuickJoin: true,
                  ),
                );
              },
              childCount: 2,
            ),
          ),
          
          // List Style Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🕒 놓치면 아쉬운 모임',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/meeting_list_all',
                        arguments: {
                          'sectionTitle': '놓치면 아쉬운 모임',
                          'category': null,
                        },
                      );
                    },
                    child: Text(
                      '전체보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors2025.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= sampleMeetings.length) return null;
                final meeting = sampleMeetings[index];
                
                return MeetingCardList2025(
                  meeting: meeting,
                  imageAsset: imageManager.getOptimizedImageForSection(meeting.category, 3, index),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/meeting_detail',
                    arguments: meeting,
                  ),
                  onBookmark: () => _showToast('${meeting.title} 북마크'),
                  isBookmarked: index % 3 == 0,
                  showDivider: index < sampleMeetings.length - 1,
                );
              },
              childCount: sampleMeetings.length,
            ),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: CreateMeetingFAB2025(
        onTap: () => _showToast('새 모임 만들기!'),
        showPulse: true,
        tooltip: '새 모임 만들기',
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors2025.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // 🚀 Korean UX Enhancement: Quick Join Dialog
  void _showQuickJoinDialog(AvailableMeeting meeting) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick join header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors2025.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: AppColors2025.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '바로 참여하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors2025.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Meeting info
              Text(
                meeting.title,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '${meeting.location} · ${meeting.formattedDate}',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Participation info with Korean social proof
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${meeting.currentParticipants}명',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors2025.primary,
                          ),
                        ),
                        Text(
                          '참여 중',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey[300],
                    ),
                    Column(
                      children: [
                        Text(
                          '${meeting.maxParticipants - meeting.currentParticipants}명',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: meeting.maxParticipants - meeting.currentParticipants <= 3 
                              ? Colors.red : Colors.green,
                          ),
                        ),
                        Text(
                          '남은 자리',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          '/meeting_application',
                          arguments: meeting,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors2025.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flash_on, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '바로 신청하기',
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  // 🎯 Korean UX Enhancement: Urgency Badge Widget
  Widget _buildUrgencyBadge(AvailableMeeting meeting) {
    final remainingSpots = meeting.maxParticipants - meeting.currentParticipants;
    final isUrgent = remainingSpots <= 3;
    final isPopular = meeting.currentParticipants >= (meeting.maxParticipants * 0.7);
    
    if (!isUrgent && !isPopular) return const SizedBox.shrink();
    
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isUrgent ? Colors.red : AppColors2025.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isUrgent ? Colors.red : AppColors2025.primary).withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          isUrgent ? '마감임박' : '인기',
          style: GoogleFonts.notoSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}