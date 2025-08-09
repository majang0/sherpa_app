import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/animation/micro_interactions.dart';

// Shared
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/models/point_system_model.dart';
import '../../../../core/constants/sherpi_emotions.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../shared/widgets/sherpa_button.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';

// Widgets  
import '../widgets/mountain_path_widget.dart';
import '../widgets/quick_goal_input_widget.dart';
import '../widgets/checkpoint_tile_widget.dart';

/// 단순화된 플래너 화면
/// 산 경로 메타포로 목표를 시각화하는 메인 화면
class SimplePlannerScreen extends ConsumerStatefulWidget {
  const SimplePlannerScreen({super.key});

  @override
  ConsumerState<SimplePlannerScreen> createState() => _SimplePlannerScreenState();
}

class _SimplePlannerScreenState extends ConsumerState<SimplePlannerScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  bool _showQuickInput = false;
  
  // 체크포인트 완료 상태를 관리하는 Map
  final Map<String, bool> _checkpointCompletions = {};
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 처음 진입시 셰르피 인사
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeMessage();
    });
  }
  
  void _showWelcomeMessage() {
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.general,
      customDialogue: '함께 목표를 달성해봐요! 어떤 산을 정복하고 싶으신가요? 🏔️',
      emotion: SherpiEmotion.happy,
      duration: const Duration(seconds: 3),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final goals = user.planningData?.goals ?? [];
    final todayCheckpoints = _getTodayCheckpoints(user);
    final overallProgress = _calculateOverallProgress(goals);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: SherpaCleanAppBar(
        title: '나의 등반 계획',
        backgroundColor: Colors.transparent,
        actions: [
          // 진행률 배지
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 메인 비주얼 - 산 경로
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16),
                child: MountainPathWidget(
                  goals: goals,
                  onGoalTap: _onGoalTapped,
                ),
              ).animate().fadeIn(duration: 600.ms),
            ),
            
            // 오늘의 체크포인트
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(
                            '📍 오늘의 체크포인트',
                            style: GoogleFonts.notoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3142),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${todayCheckpoints.where((c) => c['completed'] == true).length}/${todayCheckpoints.length} 완료',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 체크포인트 리스트
                    Expanded(
                      child: todayCheckpoints.isEmpty
                          ? _buildEmptyCheckpoints()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: todayCheckpoints.length,
                              itemBuilder: (context, index) {
                                final checkpoint = todayCheckpoints[index];
                                return CheckpointTileWidget(
                                  checkpoint: checkpoint,
                                  onToggle: () => _toggleCheckpoint(checkpoint),
                                ).animate()
                                  .fadeIn(delay: (100 * index).ms)
                                  .slideX(begin: -0.1, end: 0);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // 플로팅 액션 버튼 - 목표 추가
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickGoalInput,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          '새 목표',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ).animate()
        .scale(delay: 300.ms, duration: 300.ms)
        .fadeIn(),
    );
  }
  
  // 빈 체크포인트 화면
  Widget _buildEmptyCheckpoints() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '아직 체크포인트가 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 목표를 추가해보세요!',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showQuickGoalInput,
            icon: const Icon(Icons.add),
            label: const Text('첫 목표 만들기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 오늘의 체크포인트 가져오기
  List<Map<String, dynamic>> _getTodayCheckpoints(GlobalUser user) {
    final checkpoints = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    // 목표에서 오늘 해야 할 체크포인트 추출
    if (user.planningData != null) {
      for (final goal in user.planningData!.goals) {
        if (goal.isActive) {
          final checkpointId = '${goal.id}_${now.day}';
          // 목표별로 오늘의 체크포인트 생성
          checkpoints.add({
            'id': checkpointId,
            'goalId': goal.id,
            'title': goal.title,
            'mountain': _getCategoryMountain(goal.category),
            'points': _getCategoryPoints(goal.category),
            'completed': _checkpointCompletions[checkpointId] ?? false,
            'category': goal.category,
          });
        }
      }
    }
    
    // 일일 활동 체크포인트 추가
    final dailyRecord = user.dailyRecords;
    
    // 운동 체크포인트
    if (!_hasExercisedToday(dailyRecord)) {
      final exerciseId = 'exercise_${now.day}';
      checkpoints.add({
        'id': exerciseId,
        'title': '운동 30분',
        'mountain': '건강봉',
        'points': 50,
        'completed': _checkpointCompletions[exerciseId] ?? false,
        'linkedActivity': 'exercise',
        'category': 'health',
      });
    }
    
    // 독서 체크포인트
    if (!_hasReadToday(dailyRecord)) {
      final readingId = 'reading_${now.day}';
      checkpoints.add({
        'id': readingId,
        'title': '독서 1장',
        'mountain': '지식봉',
        'points': 30,
        'completed': _checkpointCompletions[readingId] ?? false,
        'linkedActivity': 'reading',
        'category': 'study',
      });
    }
    
    // 일기 체크포인트
    if (!_hasWrittenDiaryToday(dailyRecord)) {
      final diaryId = 'diary_${now.day}';
      checkpoints.add({
        'id': diaryId,
        'title': '일기 작성',
        'mountain': '성찰봉',
        'points': 20,
        'completed': _checkpointCompletions[diaryId] ?? false,
        'linkedActivity': 'diary',
        'category': 'habit',
      });
    }
    
    return checkpoints;
  }
  
  // 카테고리별 산 이름
  String _getCategoryMountain(String category) {
    switch (category) {
      case 'health':
        return '건강봉';
      case 'study':
        return '지식봉';
      case 'habit':
        return '성찰봉';
      case 'social':
        return '우정봉';
      default:
        return '목표봉';
    }
  }
  
  // 카테고리별 포인트
  int _getCategoryPoints(String category) {
    switch (category) {
      case 'health':
        return 50;
      case 'study':
        return 30;
      case 'habit':
        return 20;
      case 'social':
        return 40;
      default:
        return 25;
    }
  }
  
  // 오늘 운동했는지 확인
  bool _hasExercisedToday(DailyRecordData dailyRecord) {
    final today = DateTime.now();
    return dailyRecord.exerciseLogs.any((log) =>
      log.date.year == today.year &&
      log.date.month == today.month &&
      log.date.day == today.day
    );
  }
  
  // 오늘 독서했는지 확인
  bool _hasReadToday(DailyRecordData dailyRecord) {
    final today = DateTime.now();
    return dailyRecord.readingLogs.any((log) =>
      log.date.year == today.year &&
      log.date.month == today.month &&
      log.date.day == today.day
    );
  }
  
  // 오늘 일기 썼는지 확인
  bool _hasWrittenDiaryToday(DailyRecordData dailyRecord) {
    final today = DateTime.now();
    return dailyRecord.diaryLogs.any((log) =>
      log.date.year == today.year &&
      log.date.month == today.month &&
      log.date.day == today.day
    );
  }
  
  // 전체 진행률 계산
  double _calculateOverallProgress(List<UserGoal> goals) {
    if (goals.isEmpty) return 0;
    
    double totalProgress = 0;
    int activeGoals = 0;
    
    for (final goal in goals) {
      if (goal.isActive) {
        totalProgress += goal.progress;
        activeGoals++;
      }
    }
    
    return activeGoals > 0 ? totalProgress / activeGoals : 0;
  }
  
  // 빠른 목표 입력 보여주기
  void _showQuickGoalInput() {
    HapticFeedbackManager.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickGoalInputWidget(
        onGoalCreated: (goal) {
          _createGoal(goal);
          Navigator.pop(context);
        },
      ),
    );
  }
  
  // 목표 생성
  void _createGoal(Map<String, dynamic> goalData) {
    // 목표 데이터를 바로 Map 형태로 준비
    final goalMap = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': goalData['title'],
      'description': goalData['description'] ?? '',
      'category': goalData['category'],
      'duration': goalData['duration'],
      'createdAt': DateTime.now(),
      'progress': 0.0,
      'isActive': true,
    };
    
    // 글로벌 프로바이더에 저장
    ref.read(globalUserProvider.notifier).saveGoals([goalMap]);
    
    // 포인트 지급
    ref.read(globalPointProvider.notifier).earnPoints(
      10,
      PointSource.goalCompletion,
      '새로운 목표 설정',
    );
    
    // 셰르피 반응
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.general,
      customDialogue: '좋아요! "${goalData['title']}" 목표를 향해 함께 올라가봐요! 🚀',
      emotion: SherpiEmotion.cheering,
      duration: const Duration(seconds: 3),
    );
    
    // 애니메이션 재생
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }
  
  // 체크포인트 토글
  void _toggleCheckpoint(Map<String, dynamic> checkpoint) {
    HapticFeedbackManager.lightImpact();
    
    final checkpointId = checkpoint['id'] as String;
    final newCompletedState = !checkpoint['completed'];
    
    setState(() {
      checkpoint['completed'] = newCompletedState;
      _checkpointCompletions[checkpointId] = newCompletedState;
    });
    
    if (newCompletedState) {
      // 포인트 지급
      ref.read(globalPointProvider.notifier).earnPoints(
        checkpoint['points'],
        PointSource.goalCompletion,
        '체크포인트 완료: ${checkpoint['title']}',
      );
      
      // 경험치 추가
      ref.read(globalUserProvider.notifier).addExperience(checkpoint['points'] ~/ 2);
      
      // 목표 진행률 업데이트
      if (checkpoint['goalId'] != null) {
        // 현재 진행률을 가져와서 10% 증가시킴
        final goal = ref.read(globalUserProvider).planningData?.goals
            .firstWhere((g) => g.id == checkpoint['goalId'], 
                        orElse: () => UserGoal(
                          id: '', title: '', category: '', duration: 0, 
                          createdAt: DateTime.now(), progress: 0, isActive: false));
        
        if (goal != null && goal.id.isNotEmpty) {
          final newProgress = (goal.progress + 10).clamp(0.0, 100.0);
          ref.read(globalUserProvider.notifier).updateGoalProgress(
            checkpoint['goalId'],
            newProgress,
          );
        }
      }
      
      // 셰르피 축하 메시지
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.general,
        customDialogue: '체크포인트 도달! 조금만 더 올라가면 정상이에요! ⛰️',
        emotion: SherpiEmotion.happy,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  // 목표 탭 이벤트
  void _onGoalTapped(String goalId) {
    // 목표 상세 보기 (향후 구현)
    HapticFeedbackManager.lightImpact();
    
    final goal = ref.read(globalUserProvider).planningData?.goals
        .firstWhere((g) => g.id == goalId,
                    orElse: () => UserGoal(
                      id: '', title: '', category: '', duration: 0,
                      createdAt: DateTime.now(), progress: 0, isActive: false));
    
    if (goal != null && goal.id.isNotEmpty) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.general,
        customDialogue: '${goal.title} - 진행률: ${goal.progress.toInt()}%',
        emotion: SherpiEmotion.guiding,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}