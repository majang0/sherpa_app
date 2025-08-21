import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_colors_2025.dart';
import '../../widgets/sherpa_clean_app_bar.dart';
import '../../widgets/components/components.dart';
import '../../widgets/components/molecules/sherpa_smart_filter_2025.dart';
import '../../widgets/components/molecules/sherpa_quick_filter_2025.dart';

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
    {'name': '입력', 'icon': Icons.edit, 'color': AppColors.success},
    {'name': '칩', 'icon': Icons.label, 'color': AppColors.warning},
    {'name': '아바타', 'icon': Icons.account_circle, 'color': AppColors.info},
    
    // ==================== 2025 컴포넌트 (Atoms) ====================
    {'name': '2025 입력', 'icon': Icons.input, 'color': AppColors2025.secondary},
    {'name': '2025 진행률', 'icon': Icons.trending_up, 'color': AppColors2025.success},
    {'name': '2025 배지', 'icon': Icons.notifications, 'color': AppColors2025.error},
    {'name': '2025 차트', 'icon': Icons.bar_chart, 'color': AppColors2025.warning},
    
    // ==================== 2025 모임 컴포넌트 ====================
    {'name': '모임 필터', 'icon': Icons.filter_list, 'color': AppColors2025.secondary},
    
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
                  Text(
                    '셰르파 컴포넌트 라이브러리',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '2025 디자인 시스템 컴포넌트 모음',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 카테고리 탭
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategoryIndex == index;
                
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                        ? LinearGradient(
                            colors: [
                              category['color'],
                              category['color'].withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                      color: isSelected ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                          ? category['color'] 
                          : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: category['color'].withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          color: isSelected ? Colors.white : category['color'],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['name'],
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 컴포넌트 리스트
          Expanded(
            child: _buildComponentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentList() {
    switch (selectedCategoryIndex) {
      // ==================== 기존 컴포넌트 ====================
      case 0: // 카드
        return _buildCardsTab();
      case 1: // 입력
        return _buildInputsTab();
      case 2: // 칩
        return _buildChipsTab();
      case 3: // 아바타
        return _buildAvatarsTab();
        
      // ==================== 2025 컴포넌트 (Atoms) ====================
      case 4: // 2025 입력
        return _build2025InputsTab();
      case 5: // 2025 진행률
        return _build2025ProgressTab();
      case 6: // 2025 배지
        return _build2025BadgeTab();
      case 7: // 2025 차트
        return _build2025ChartTab();
        
      // ==================== 2025 모임 컴포넌트 ====================
      case 8: // 모임 필터
        return _buildMeetingFiltersTab();
        
      // ==================== 기존 프로그레스 ====================
      case 9: // 프로그레스
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

  // 2025 입력 탭
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

  // 2025 진행률 탭
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

  // 2025 배지 탭
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

  // 2025 차트 탭
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

  // 모임 필터 탭
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

  // 프로그레스 탭
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

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors2025.primary,
      ),
    );
  }

  // 추가 컴포넌트 섹션 헬퍼
  Widget ComponentSection({
    required String title,
    required Widget child,
  }) {
    return _buildComponentSection(title, '', child);
  }
}