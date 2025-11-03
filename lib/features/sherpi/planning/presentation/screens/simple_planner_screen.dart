import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../../core/theme/modern_colors.dart';

// Shared
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_point_provider.dart';
import '../../../../../shared/models/global_user_model.dart';
import '../../../../../shared/models/point_system_model.dart';
import '../../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../../shared/utils/haptic_feedback_manager.dart';

// Widgets
import '../widgets/mountain_path_widget.dart';
import '../widgets/quick_goal_input_widget.dart';
import '../widgets/checkpoint_tile_widget.dart';

/// 단순화된 플래너 화면
/// 산 경로 메타포로 목표를 시각화하는 메인 화면
class SimplePlannerScreen extends ConsumerStatefulWidget {
  const SimplePlannerScreen({super.key});

  @override
  ConsumerState<SimplePlannerScreen> createState() =>
      _SimplePlannerScreenState();
}

class _SimplePlannerScreenState extends ConsumerState<SimplePlannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final bool _showQuickInput = false;

  // 체크포인트 완료 상태를 관리하는 Map
  final Map<String, bool> _checkpointCompletions = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 셰르피 환영 메시지 제거 (루틴 관리는 독립적으로 운영)
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
        title: '루틴 관리',
        backgroundColor: Colors.transparent,
        actions: [
          // 진행률 배지
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ModernColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  size: 16,
                  color: ModernColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ModernColors.primary,
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
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: MountainPathWidget(
                      goals: goals,
                      onGoalTap: _onGoalTapped,
                    ),
                  ).animate().fadeIn(duration: 600.ms),

                  // 목표 리스트 버튼
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _showGoalsList,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.list_alt,
                                size: 18,
                                color: ModernColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '루틴 관리',
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ModernColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),
                ],
              ),
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 0)),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: todayCheckpoints.length,
                              itemBuilder: (context, index) {
                                final checkpoint = todayCheckpoints[index];
                                return CheckpointTileWidget(
                                  checkpoint: checkpoint,
                                  onToggle: () => _toggleCheckpoint(checkpoint),
                                )
                                    .animate()
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
        backgroundColor: ModernColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          '새 목표',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ).animate().scale(delay: 300.ms, duration: 300.ms).fadeIn(),
    );
  }

  // 목표 리스트 보기 모달
  void _showGoalsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final goals = ref.read(globalUserProvider).planningData?.goals ?? [];

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // 핸들바
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // 헤더
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          '🎯 내 루틴',
                          style: GoogleFonts.notoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3142),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${goals.length}개',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // 목표 리스트
                  Expanded(
                    child: goals.isEmpty
                        ? Center(
                            child: Text(
                              '아직 설정한 루틴이 없어요',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(20),
                            itemCount: goals.length,
                            itemBuilder: (context, index) {
                              final goal = goals[index];
                              return _buildGoalCard(goal);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 목표 카드 위젯
  Widget _buildGoalCard(UserGoal goal) {
    final daysLeft = goal.daysRemaining;
    final progressPercent = goal.progress.toInt();

    return Dismissible(
      key: Key(goal.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('루틴 삭제'),
            content: Text('${goal.title} 루틴을 삭제하시겠어요?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  '삭제',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(globalUserProvider.notifier).deleteGoal(goal.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${goal.title} 루틴이 삭제되었어요'),
            backgroundColor: Colors.grey[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 카테고리 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getCategoryColor(goal.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(goal.category),
                color: _getCategoryColor(goal.category),
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // 목표 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'D-$daysLeft',
                        style: TextStyle(
                          fontSize: 12,
                          color: daysLeft <= 3 ? Colors.red : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.trending_up,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$progressPercent%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 진행률 원형 차트
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: goal.progress / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCategoryColor(goal.category),
                    ),
                    strokeWidth: 3,
                  ),
                  Text(
                    '$progressPercent%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(goal.category),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 삭제 버튼
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey[400],
                size: 20,
              ),
              onPressed: () => _confirmDeleteGoal(goal),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  // 루틴 삭제 확인 다이얼로그
  void _confirmDeleteGoal(UserGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('루틴 삭제'),
        content: Text('${goal.title} 루틴을 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(globalUserProvider.notifier).deleteGoal(goal.id);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${goal.title} 루틴이 삭제되었어요'),
                  backgroundColor: Colors.grey[800],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리별 색상
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'health':
        return Colors.green;
      case 'study':
        return Colors.blue;
      case 'habit':
        return Colors.purple;
      case 'social':
        return Colors.orange;
      default:
        return ModernColors.primary;
    }
  }

  // 카테고리별 아이콘
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'health':
        return Icons.fitness_center;
      case 'study':
        return Icons.school;
      case 'habit':
        return Icons.psychology;
      case 'social':
        return Icons.people;
      default:
        return Icons.flag;
    }
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
              backgroundColor: ModernColors.primary,
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

    // 일일 활동 체크포인트는 제거 - 목표에서 설정한 것만 표시

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
      ref
          .read(globalUserProvider.notifier)
          .addExperience(checkpoint['points'] ~/ 2);

      // 목표 진행률 업데이트
      if (checkpoint['goalId'] != null) {
        // 현재 진행률을 가져와서 10% 증가시킴
        final goal = ref
            .read(globalUserProvider)
            .planningData
            ?.goals
            .firstWhere((g) => g.id == checkpoint['goalId'],
                orElse: () => UserGoal(
                    id: '',
                    title: '',
                    category: '',
                    duration: 0,
                    createdAt: DateTime.now(),
                    progress: 0,
                    isActive: false));

        if (goal != null && goal.id.isNotEmpty) {
          final newProgress = (goal.progress + 10).clamp(0.0, 100.0);
          ref.read(globalUserProvider.notifier).updateGoalProgress(
                checkpoint['goalId'],
                newProgress,
              );
        }
      }

    }
  }

  // 목표 탭 이벤트
  void _onGoalTapped(String goalId) {
    // 목표 상세 보기 (향후 구현)
    HapticFeedbackManager.lightImpact();
    // 셰르피 반응 제거 - 루틴 관리는 독립적으로 운영
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
