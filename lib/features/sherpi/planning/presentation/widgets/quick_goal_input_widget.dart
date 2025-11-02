import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import '../../../../../shared/models/global_user_model.dart';
import '../../../../../shared/utils/haptic_feedback_manager.dart';

/// 빠른 목표 입력 위젯
/// 30초 내에 목표를 생성할 수 있는 간단한 입력 폼
class QuickGoalInputWidget extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onGoalCreated;

  const QuickGoalInputWidget({
    required this.onGoalCreated,
    super.key,
  });

  @override
  ConsumerState<QuickGoalInputWidget> createState() =>
      _QuickGoalInputWidgetState();
}

class _QuickGoalInputWidgetState extends ConsumerState<QuickGoalInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String _selectedCategory = 'health';
  int _duration = 7; // 기본 7일
  bool _showAIHint = false;

  @override
  void initState() {
    super.initState();
    // 자동으로 키보드 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _checkAndShowAIHint();
    });
  }

  void _checkAndShowAIHint() {
    // 사용자 데이터 기반 AI 힌트 표시 여부 결정
    final user = ref.read(globalUserProvider);

    // 최근 활동 패턴 분석
    if (user.dailyRecords.exerciseLogs.isEmpty &&
        _selectedCategory == 'health') {
      setState(() => _showAIHint = true);
    } else if (user.dailyRecords.readingLogs.isEmpty &&
        _selectedCategory == 'study') {
      setState(() => _showAIHint = true);
    }
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
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들 바
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 타이틀
            Row(
              children: [
                Text(
                  '🏔️ 어떤 산을 정복하시겠어요?',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3142),
                  ),
                ),
              ],
            ).animate().fadeIn().slideX(begin: -0.1, end: 0),

            const SizedBox(height: 20),

            // 입력 필드
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '예: 매일 30분 운동하기',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.flag_outlined,
                  color: ModernColors.primary,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                          });
                        },
                      )
                    : null,
              ),
              style: GoogleFonts.notoSans(fontSize: 16),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (_) => _createGoal(),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            // AI 힌트 (작고 비침투적)
            if (_showAIHint && aiHint != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.primary.withValues(alpha: 0.05),
                      ModernColors.primary.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ModernColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 14,
                      color: ModernColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        aiHint,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: ModernColors.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _showAIHint = false);
                      },
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.1, end: 0),
            ],

            const SizedBox(height: 20),

            // 카테고리 선택
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '카테고리',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(
                          '건강', 'health', Icons.favorite, Colors.red),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                          '학습', 'study', Icons.book, Colors.blue),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                          '습관', 'habit', Icons.repeat, Colors.green),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                          '소셜', 'social', Icons.people, Colors.orange),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // 기간 선택
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '목표 기간',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDurationChip('1주', 7),
                      const SizedBox(width: 8),
                      _buildDurationChip('2주', 14),
                      const SizedBox(width: 8),
                      _buildDurationChip('1달', 30),
                      const SizedBox(width: 8),
                      _buildDurationChip('2달', 60),
                      const SizedBox(width: 8),
                      _buildDurationChip('3달', 90),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            // 생성 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _controller.text.isNotEmpty ? _createGoal : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '목표 생성하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
      String label, String value, IconData icon, Color color) {
    final isSelected = _selectedCategory == value;

    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        setState(() {
          _selectedCategory = value;
          _checkAndShowAIHint();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(String label, int days) {
    final isSelected = _duration == days;

    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        setState(() => _duration = days);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ModernColors.primary.withValues(alpha: 0.15)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? ModernColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            color: isSelected ? ModernColors.primary : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String? _getAIHint(GlobalUser user) {
    // 카테고리별 스마트 힌트
    switch (_selectedCategory) {
      case 'health':
        if (user.dailyRecords.exerciseLogs.isEmpty) {
          return "운동을 시작해보세요! '주 3회 30분 운동' 어떠세요?";
        } else if (user.dailyRecords.exerciseLogs.length > 10) {
          return "꾸준히 운동 중이시네요! '운동 강도 높이기' 도전!";
        }
        break;

      case 'study':
        if (user.dailyRecords.readingLogs.isEmpty) {
          return "독서 습관을 만들어보세요. '매일 10페이지 읽기' 추천!";
        } else if (user.dailyRecords.readingLogs.length > 5) {
          return "독서가 익숙해지셨네요! '월 2권 완독' 도전!";
        }
        break;

      case 'habit':
        if (user.dailyRecords.diaryLogs.isEmpty) {
          return "일기 쓰기로 하루를 정리해보세요.";
        } else {
          return "새로운 습관에 도전해보세요!";
        }

      case 'social':
        if (user.dailyRecords.meetingLogs.isEmpty) {
          return "모임에 참여해 새로운 사람들을 만나보세요!";
        } else {
          return "정기 모임을 만들어보는 건 어떨까요?";
        }
    }

    // 연속 기록 기반 힌트
    final streak = user.dailyRecords.consecutiveDays;
    if (streak > 7) {
      return "연속 $streak일째! 더 높은 목표에 도전해보세요!";
    }

    return null;
  }

  void _createGoal() {
    if (_controller.text.isEmpty) return;

    HapticFeedbackManager.mediumImpact();

    final goalData = {
      'title': _controller.text.trim(),
      'description': '',
      'category': _selectedCategory,
      'duration': _duration,
    };

    widget.onGoalCreated(goalData);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
