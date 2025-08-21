# 🚀 Phase 1: 기초 구조 구현 가이드
*셰르파 플래너 단순화 - 1주차 실행 계획*

## 📋 Phase 1 체크리스트

### 즉시 실행 (Day 1-2)
- [ ] 기존 복잡한 3탭 구조 제거
- [ ] 단일 화면 레이아웃으로 전환
- [ ] 빠른 목표 입력 위젯 구현
- [ ] 글로벌 데이터와 연동

### 비주얼 기초 (Day 3-4)
- [ ] 산 경로 기본 UI 구현
- [ ] 체크포인트 마커 디자인
- [ ] 진행률 표시 바

### 통합 작업 (Day 5-7)
- [ ] 일일 활동과 연결
- [ ] 포인트 시스템 연동
- [ ] 기본 애니메이션 추가

---

## 🗂️ 1. 파일 구조 변경

### 1.1 제거할 파일
```bash
# 복잡한 기존 구조 제거
❌ lib/features/sherpi_planning/presentation/screens/planning_input_screen.dart
❌ lib/features/sherpi_planning/services/ai_suggestion_service.dart
```

### 1.2 새로 만들 파일
```bash
# 새로운 단순화된 구조
✅ lib/features/planning/
  ├── screens/
  │   └── simple_planner_screen.dart       # 메인 플래너 화면
  ├── widgets/
  │   ├── mountain_path_widget.dart        # 산 경로 비주얼
  │   ├── checkpoint_tile.dart             # 체크포인트 위젯
  │   ├── quick_goal_input.dart            # 빠른 목표 입력
  │   └── progress_indicator.dart          # 진행률 표시
  ├── models/
  │   └── mountain_goal_model.dart         # 새로운 데이터 모델
  └── providers/
      └── planner_provider.dart            # 상태 관리
```

---

## 💻 2. 코드 구현

### 2.1 새로운 메인 화면 (simple_planner_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/mountain_path_widget.dart';
import '../widgets/quick_goal_input.dart';
import '../widgets/checkpoint_tile.dart';

class SimplePlannerScreen extends ConsumerStatefulWidget {
  const SimplePlannerScreen({super.key});

  @override
  ConsumerState<SimplePlannerScreen> createState() => _SimplePlannerScreenState();
}

class _SimplePlannerScreenState extends ConsumerState<SimplePlannerScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  bool _showQuickInput = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(plannerProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 - 심플한 타이틀
            _buildHeader(),
            
            // 메인 비주얼 - 산 경로
            Expanded(
              flex: 2,
              child: MountainPathWidget(
                goals: goals,
                onGoalTap: _onGoalTapped,
              ),
            ),
            
            // 오늘의 체크포인트
            Expanded(
              flex: 3,
              child: _buildTodayCheckpoints(),
            ),
          ],
        ),
      ),
      
      // 플로팅 액션 버튼 - 목표 추가
      floatingActionButton: _buildQuickAddButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            '🏔️ 나의 등반 계획',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          // 간단한 진행률 표시
          _buildProgressBadge(),
        ],
      ),
    );
  }

  Widget _buildProgressBadge() {
    final progress = ref.watch(plannerProvider.select((state) => state.overallProgress));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCheckpoints() {
    final todayTasks = ref.watch(todayCheckpointsProvider);
    
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '📍 오늘의 체크포인트',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: todayTasks.length,
              itemBuilder: (context, index) {
                return CheckpointTile(
                  checkpoint: todayTasks[index],
                  onToggle: () => _toggleCheckpoint(todayTasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton() {
    return FloatingActionButton.extended(
      onPressed: _showQuickGoalInput,
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add),
      label: const Text('새 목표'),
    );
  }

  void _showQuickGoalInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickGoalInput(
        onGoalCreated: (goal) {
          ref.read(plannerProvider.notifier).addGoal(goal);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _onGoalTapped(String goalId) {
    // 목표 상세 보기 또는 수정
  }

  void _toggleCheckpoint(Checkpoint checkpoint) {
    ref.read(plannerProvider.notifier).toggleCheckpoint(checkpoint.id);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
```

### 2.2 산 경로 비주얼 위젯 (mountain_path_widget.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MountainPathWidget extends StatelessWidget {
  final List<MountainGoal> goals;
  final Function(String) onGoalTap;

  const MountainPathWidget({
    required this.goals,
    required this.onGoalTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: CustomPaint(
        painter: MountainPathPainter(goals: goals),
        child: Stack(
          children: [
            // 현재 위치 표시
            _buildCurrentPosition(),
            
            // 목표 봉우리들
            ...goals.map((goal) => _buildPeakMarker(goal)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildCurrentPosition() {
    return Positioned(
      left: 50,
      bottom: 30,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ).animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1.seconds,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1, 1),
          duration: 1.seconds,
        ),
    );
  }

  Widget _buildPeakMarker(MountainGoal goal) {
    final progress = goal.currentAltitude / goal.targetAltitude;
    final isCompleted = progress >= 1.0;
    
    return Positioned(
      left: goal.positionX,
      top: goal.positionY,
      child: GestureDetector(
        onTap: () => onGoalTap(goal.id),
        child: Column(
          children: [
            // 깃발 또는 산 아이콘
            Icon(
              isCompleted ? Icons.flag : Icons.terrain,
              color: isCompleted ? Colors.green : Colors.grey,
              size: 30,
            ),
            const SizedBox(height: 4),
            // 목표 이름
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                goal.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 산 경로를 그리는 CustomPainter
class MountainPathPainter extends CustomPainter {
  final List<MountainGoal> goals;

  MountainPathPainter({required this.goals});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // 시작점
    path.moveTo(50, size.height - 30);
    
    // 목표들을 연결하는 경로 그리기
    for (final goal in goals) {
      path.quadraticBezierTo(
        goal.positionX - 20,
        goal.positionY + 20,
        goal.positionX,
        goal.positionY,
      );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### 2.3 빠른 목표 입력 위젯 (quick_goal_input.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickGoalInput extends ConsumerStatefulWidget {
  final Function(MountainGoal) onGoalCreated;

  const QuickGoalInput({
    required this.onGoalCreated,
    super.key,
  });

  @override
  ConsumerState<QuickGoalInput> createState() => _QuickGoalInputState();
}

class _QuickGoalInputState extends ConsumerState<QuickGoalInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  
  String _selectedCategory = 'health';
  int _duration = 7; // 기본 7일
  
  @override
  void initState() {
    super.initState();
    // 자동으로 키보드 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(globalUserProvider);
    final aiHint = _getAIHint(userData);
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀
            Text(
              '🏔️ 어떤 산을 정복하시겠어요?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // 입력 필드
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '예: 매일 30분 운동하기',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.flag, color: AppColors.primary),
              ),
              onSubmitted: (_) => _createGoal(),
            ),
            
            // AI 힌트 (작게 표시)
            if (aiHint != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        aiHint,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // 빠른 옵션들
            Row(
              children: [
                // 카테고리 선택
                _buildCategoryChip('건강', 'health', Icons.favorite),
                const SizedBox(width: 8),
                _buildCategoryChip('학습', 'study', Icons.book),
                const SizedBox(width: 8),
                _buildCategoryChip('습관', 'habit', Icons.repeat),
                const Spacer(),
                // 기간 선택
                _buildDurationSelector(),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 생성 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '목표 생성',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value, IconData icon) {
    final isSelected = _selectedCategory == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        value: _duration,
        isDense: true,
        underline: const SizedBox(),
        items: [7, 14, 30, 60, 90].map((days) {
          return DropdownMenuItem(
            value: days,
            child: Text('${days}일'),
          );
        }).toList(),
        onChanged: (value) => setState(() => _duration = value!),
      ),
    );
  }

  String? _getAIHint(GlobalUser user) {
    // 사용자 데이터 기반 스마트 힌트
    if (user.currentStreak > 7) {
      return "연속 ${user.currentStreak}일째 활동 중! '더 높은 산 도전' 어떠세요?";
    }
    
    if (user.totalExerciseMinutes < 100) {
      return "운동이 부족하네요. '주 3회 30분 운동' 목표는 어떠세요?";
    }
    
    if (user.totalBooksRead < 5) {
      return "독서 습관을 만들어보세요. '월 2권 독서' 도전!";
    }
    
    return null;
  }

  void _createGoal() {
    if (_controller.text.isEmpty) return;
    
    final goal = MountainGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _controller.text,
      category: _selectedCategory,
      duration: _duration,
      createdAt: DateTime.now(),
      targetDate: DateTime.now().add(Duration(days: _duration)),
    );
    
    widget.onGoalCreated(goal);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

---

## 🔗 3. 기존 시스템과의 연동

### 3.1 GlobalUserProvider 연동

```dart
// lib/shared/providers/global_user_provider.dart 수정

// 플래너 데이터 추가
class GlobalUser {
  // ... 기존 필드들 ...
  
  final List<MountainGoal> mountainGoals;
  final Map<String, double> goalProgress;
  
  // 일일 활동을 체크포인트로 자동 변환
  List<Checkpoint> get todayCheckpoints {
    final checkpoints = <Checkpoint>[];
    
    // 운동 체크포인트
    if (todayExerciseMinutes == 0) {
      checkpoints.add(Checkpoint(
        id: 'exercise_today',
        title: '운동 30분',
        linkedActivity: 'exercise',
        points: 50,
        mountain: '건강봉',
      ));
    }
    
    // 독서 체크포인트
    if (!hasReadToday) {
      checkpoints.add(Checkpoint(
        id: 'reading_today',
        title: '독서 1장',
        linkedActivity: 'reading',
        points: 30,
        mountain: '지식봉',
      ));
    }
    
    // 일기 체크포인트
    if (!hasWrittenDiaryToday) {
      checkpoints.add(Checkpoint(
        id: 'diary_today',
        title: '일기 작성',
        linkedActivity: 'diary',
        points: 20,
        mountain: '성찰봉',
      ));
    }
    
    return checkpoints;
  }
}
```

### 3.2 포인트 시스템 연동

```dart
// 체크포인트 완료시 포인트 지급
void completeCheckpoint(String checkpointId) {
  final checkpoint = getCheckpointById(checkpointId);
  
  // 포인트 지급
  ref.read(globalPointProvider.notifier).earnPoints(
    checkpoint.points,
    PointSource.goalCompletion,
    '체크포인트 완료: ${checkpoint.title}',
  );
  
  // 경험치 추가
  ref.read(globalUserProvider.notifier).addExperience(checkpoint.points ~/ 2);
  
  // 진행률 업데이트
  updateGoalProgress(checkpoint.linkedGoal);
}
```

### 3.3 셰르피 AI 연동

```dart
// 목표 생성시 셰르피 반응
void onGoalCreated(MountainGoal goal) {
  ref.read(sherpiProvider.notifier).showInstantMessage(
    context: SherpiContext.general,
    customDialogue: '새로운 산을 정복하러 가요! ${goal.title} 화이팅! 🏔️',
    emotion: SherpiEmotion.cheering,
  );
}

// 체크포인트 달성시
void onCheckpointCompleted(Checkpoint checkpoint) {
  ref.read(sherpiProvider.notifier).showInstantMessage(
    context: SherpiContext.general,
    customDialogue: '체크포인트 도달! 조금만 더 올라가면 정상이에요! ⛰️',
    emotion: SherpiEmotion.happy,
  );
}
```

---

## 🎨 4. UI/UX 개선 포인트

### 4.1 색상 팔레트
```dart
class PlannerColors {
  static const Color mountainBrown = Color(0xFF8B4513);
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color grassGreen = Color(0xFF90EE90);
  static const Color peakWhite = Color(0xFFFFFAFA);
  static const Color pathGray = Color(0xFFD3D3D3);
}
```

### 4.2 애니메이션
- 목표 생성시: 산이 솟아오르는 애니메이션
- 체크포인트 완료: 깃발 꽂기 애니메이션
- 진행률 증가: 캐릭터 이동 애니메이션
- 정상 도달: 폭죽 + 셰르피 축하

### 4.3 마이크로 인터랙션
- 햅틱 피드백: 체크포인트 체크시
- 사운드: 완료시 "띵" 소리
- 비주얼: 완료 체크시 체크마크 애니메이션

---

## 📝 5. 다음 단계 준비

### Phase 2 예고
- 날씨 시스템 (달성률에 따라 맑음/흐림)
- 친구와 함께 등반
- 월간/연간 산맥 뷰
- 업적 시스템

### 테스트 포인트
- [ ] 목표 생성 시간 < 30초
- [ ] 일일 확인 시간 < 10초
- [ ] 앱 크래시 없음
- [ ] 데이터 저장 정상 작동

---

*Phase 1 예상 소요 시간: 40시간*
*예상 완료일: 1주 이내*