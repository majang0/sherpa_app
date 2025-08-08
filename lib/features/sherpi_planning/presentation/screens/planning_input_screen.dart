import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/animation/micro_interactions.dart';

// Features
import '../../services/smart_planner_service.dart';
import '../../services/ai_suggestion_service.dart';
import '../../constants/planning_constants.dart';

// Shared
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/widgets/sherpa_button.dart';

/// 계획 입력 화면
/// 사용자가 직접 목표와 계획을 입력하는 인터랙티브 화면
class PlanningInputScreen extends ConsumerStatefulWidget {
  const PlanningInputScreen({super.key});

  @override
  ConsumerState<PlanningInputScreen> createState() => _PlanningInputScreenState();
}

class _PlanningInputScreenState extends ConsumerState<PlanningInputScreen> 
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  
  // 입력 컨트롤러들
  final _goalTitleController = TextEditingController();
  final _goalDescriptionController = TextEditingController();
  final _scheduleController = TextEditingController();
  
  // 선택된 카테고리
  String _selectedCategory = 'health';
  
  // 목표 기간
  int _goalDuration = 7; // 기본 7일
  
  // AI 제안 목록
  List<GoalSuggestion> _aiSuggestions = [];
  bool _isLoadingSuggestions = false;
  
  // 저장된 목표들
  List<Map<String, dynamic>> _savedGoals = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialSuggestions();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _goalTitleController.dispose();
    _goalDescriptionController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }
  
  // 초기 AI 제안 로드
  void _loadInitialSuggestions() async {
    setState(() => _isLoadingSuggestions = true);
    
    try {
      final globalUser = ref.read(globalUserProvider);
      
      // AI 서비스를 통한 스마트 제안 생성
      final suggestions = AiSuggestionService.generateSmartSuggestions(
        globalUser,
        selectedCategory: _selectedCategory,
      );
      
      setState(() {
        _aiSuggestions = suggestions;
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      setState(() => _isLoadingSuggestions = false);
    }
  }
  
  // 목표 저장
  void _saveGoal() {
    // 목표 유효성 검사
    if (_goalTitleController.text.isEmpty) {
      _showValidationMessage('목표를 입력해주세요', isError: true);
      return;
    }
    
    if (_goalTitleController.text.length < 3) {
      _showValidationMessage('목표는 3자 이상 입력해주세요', isError: true);
      return;
    }
    
    // 중복 목표 체크
    final isDuplicate = _savedGoals.any(
      (goal) => goal['title'].toString().toLowerCase() == 
                _goalTitleController.text.toLowerCase()
    );
    
    if (isDuplicate) {
      _showValidationMessage('이미 동일한 목표가 있습니다', isError: true);
      return;
    }
    
    final newGoal = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _goalTitleController.text.trim(),
      'description': _goalDescriptionController.text.trim(),
      'category': _selectedCategory,
      'duration': _goalDuration,
      'schedule': _scheduleController.text.trim(),
      'createdAt': DateTime.now(),
      'progress': 0.0,
      'isActive': true,
    };
    
    setState(() {
      _savedGoals.add(newGoal);
      _goalTitleController.clear();
      _goalDescriptionController.clear();
      _scheduleController.clear();
      // 다음 목표를 위한 카테고리 초기화
      if (_savedGoals.length > 1) {
        _selectedCategory = 'health';
      }
    });
    
    // 성공 피드백 with haptic
    HapticFeedback.mediumImpact();
    _showValidationMessage(
      '목표가 저장되었습니다! (${_savedGoals.length}개)',
      isError: false,
    );
    
    // 3개 이상 목표 설정 시 자동으로 저장된 목표 탭으로 이동
    if (_savedGoals.length == 3) {
      _tabController.animateTo(2);
    }
  }
  
  // 유효성 검사 메시지 표시
  void _showValidationMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }
  
  // 전체 계획 완료
  void _completePlanning() {
    if (_savedGoals.isEmpty) {
      _showValidationMessage('최소 1개 이상의 목표를 설정해주세요', isError: true);
      return;
    }
    
    // 글로벌 데이터에 저장
    ref.read(globalUserProvider.notifier).saveGoals(_savedGoals);
    
    // 햅틱 피드백
    HapticFeedback.heavyImpact();
    
    // 성공 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ).animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text(
                '계획 수립 완료!',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_savedGoals.length}개의 목표가 설정되었습니다.',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '이제 하나씩 달성해보세요!',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).pop(); // 화면 닫기
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '확인',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '나만의 계획 세우기',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: '목표 설정'),
            Tab(text: '일정 계획'),
            Tab(text: '저장된 목표'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 첫 번째 탭: 목표 설정
          _buildGoalSettingTab(),
          
          // 두 번째 탭: 일정 계획
          _buildScheduleTab(),
          
          // 세 번째 탭: 저장된 목표
          _buildSavedGoalsTab(),
        ],
      ),
      
      // 하단 저장 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SherpaButton(
                onPressed: _saveGoal,
                text: '목표 추가',
                backgroundColor: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SherpaButton(
                onPressed: _completePlanning,
                text: '계획 완료 (${_savedGoals.length})',
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 목표 설정 탭
  Widget _buildGoalSettingTab() {
    return Row(
      children: [
        // 왼쪽: 입력 폼
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 선택
                Text(
                  '카테고리 선택',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: PlanningConstants.goalCategories.entries.map((entry) {
                    final isSelected = _selectedCategory == entry.key;
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = entry.key);
                        _loadInitialSuggestions(); // 카테고리 변경 시 제안 업데이트
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // 목표 제목
                Text(
                  '목표',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _goalTitleController,
                  decoration: InputDecoration(
                    hintText: '달성하고 싶은 목표를 입력하세요',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.flag, color: Colors.orange),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 상세 설명
                Text(
                  '상세 설명 (선택)',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _goalDescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '목표를 달성하기 위한 구체적인 계획을 적어보세요',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 목표 기간
                Text(
                  '목표 기간',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDurationChip('7일', 7),
                    const SizedBox(width: 8),
                    _buildDurationChip('30일', 30),
                    const SizedBox(width: 8),
                    _buildDurationChip('90일', 90),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),
        ),
        
        // 오른쪽: AI 제안
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: _buildAiSuggestionsPanel(),
        ),
      ],
    );
  }
  
  // 일정 계획 탭
  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '언제 실행하시겠습니까?',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // 시간대 선택
          _buildTimeSelectionGrid(),
          
          const SizedBox(height: 24),
          
          // 요일 선택
          Text(
            '실행 요일',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildWeekdaySelector(),
          
          const SizedBox(height: 24),
          
          // 알림 설정
          _buildReminderSettings(),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
  
  // 저장된 목표 탭
  Widget _buildSavedGoalsTab() {
    if (_savedGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '아직 저장된 목표가 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '목표 설정 탭에서 목표를 추가해보세요',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedGoals.length,
      itemBuilder: (context, index) {
        final goal = _savedGoals[index];
        final bool isActive = goal['isActive'] ?? true;
        
        return Dismissible(
          key: Key(goal['id'] ?? index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade500,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            setState(() => _savedGoals.removeAt(index));
            _showValidationMessage('목표가 삭제되었습니다', isError: false);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isActive ? 2 : 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive 
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: ExpansionTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive 
                      ? [AppColors.primary, AppColors.primaryLight]
                      : [Colors.grey.shade400, Colors.grey.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                goal['title'],
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.black87 : Colors.grey.shade600,
                  decoration: isActive ? null : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(goal['category']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          PlanningConstants.goalCategories[goal['category']] ?? '',
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            color: _getCategoryColor(goal['category']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${goal['duration']}일',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (goal['schedule'] != null && goal['schedule'].toString().isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          goal['schedule'],
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (goal['progress'] != null && goal['progress'] > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (goal['progress'] as double) / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isActive ? AppColors.primary : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '진행률: ${goal['progress'].toStringAsFixed(0)}%',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              children: [
                if (goal['description'] != null && goal['description'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '상세 설명',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          goal['description'],
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _savedGoals[index]['isActive'] = !(goal['isActive'] ?? true);
                                });
                              },
                              icon: Icon(
                                isActive ? Icons.pause : Icons.play_arrow,
                                size: 16,
                              ),
                              label: Text(isActive ? '일시중지' : '재개'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                _editGoal(index, goal);
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('수정'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ).animate()
          .fadeIn(delay: (index * 100).ms)
          .slideX(begin: 0.2, end: 0);
      },
    );
  }
  
  // AI 제안 패널
  Widget _buildAiSuggestionsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary.withOpacity(0.05),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI 추천 목표',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        
        if (_isLoadingSuggestions)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _aiSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _aiSuggestions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: suggestion.relevanceScore > 0.8 ? 2 : 1,
                  child: InkWell(
                    onTap: () {
                      _goalTitleController.text = suggestion.title;
                      _goalDescriptionController.text = suggestion.description;
                      setState(() {
                        _selectedCategory = suggestion.category;
                        _goalDuration = suggestion.estimatedDays;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                suggestion.icon,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  suggestion.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (suggestion.relevanceScore > 0.8)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '추천',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 10,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion.description,
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (suggestion.reason != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              suggestion.reason!,
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                color: AppColors.primary.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(delay: (index * 100).ms)
                  .slideX(begin: 0.1, end: 0);
              },
            ),
          ),
        
        // 새로고침 버튼
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextButton.icon(
            onPressed: _loadInitialSuggestions,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('다른 추천 보기'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
  
  // 기간 선택 칩
  Widget _buildDurationChip(String label, int days) {
    final isSelected = _goalDuration == days;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _goalDuration = days);
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
  
  // 시간대 선택 그리드
  Widget _buildTimeSelectionGrid() {
    final times = ['아침', '점심', '저녁', '자기 전'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) {
        return OutlinedButton(
          onPressed: () {
            _scheduleController.text = times[index];
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(times[index]),
        );
      },
    );
  }
  
  // 요일 선택기
  Widget _buildWeekdaySelector() {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekdays.map((day) {
        return GestureDetector(
          onTap: () {
            // TODO: 요일 선택 로직
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                day,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  // 알림 설정
  Widget _buildReminderSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_outlined, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림 설정',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '목표 실행 시간에 알림을 받습니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (value) {
              // TODO: 알림 설정
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
  
  // 카테고리별 색상 가져오기
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'health':
        return Colors.green;
      case 'growth':
        return Colors.purple;
      case 'relationship':
        return Colors.pink;
      case 'productivity':
        return Colors.blue;
      case 'hobby':
        return Colors.orange;
      case 'learning':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }
  
  // 목표 수정
  void _editGoal(int index, Map<String, dynamic> goal) {
    _goalTitleController.text = goal['title'];
    _goalDescriptionController.text = goal['description'] ?? '';
    _scheduleController.text = goal['schedule'] ?? '';
    setState(() {
      _selectedCategory = goal['category'];
      _goalDuration = goal['duration'];
      _savedGoals.removeAt(index);
    });
    _tabController.animateTo(0);
    _showValidationMessage('목표를 수정해주세요', isError: false);
  }
}