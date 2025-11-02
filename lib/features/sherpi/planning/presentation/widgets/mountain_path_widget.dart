import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/models/global_user_model.dart';
import '../../../../../core/theme/modern_colors.dart';

/// 산 경로 비주얼 위젯
/// 목표를 산으로, 진행 상황을 등반 경로로 시각화
class MountainPathWidget extends StatelessWidget {
  final List<UserGoal> goals;
  final Function(String) onGoalTap;

  const MountainPathWidget({
    required this.goals,
    required this.onGoalTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF87CEEB).withValues(alpha: 0.3), // 하늘색
            const Color(0xFF90EE90).withValues(alpha: 0.2), // 연한 초록
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 배경 구름 효과
          Positioned(
            top: 20,
            right: 30,
            child: Icon(
              Icons.cloud,
              size: 40,
              color: Colors.white.withValues(alpha: 0.6),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .moveX(
                  begin: 0,
                  end: 20,
                  duration: 3.seconds,
                  curve: Curves.easeInOut,
                )
                .then()
                .moveX(
                  begin: 20,
                  end: 0,
                  duration: 3.seconds,
                  curve: Curves.easeInOut,
                ),
          ),

          // 태양
          Positioned(
            top: 20,
            left: 30,
            child: Icon(
              Icons.wb_sunny,
              size: 36,
              color: Colors.orange[300],
            )
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 10.seconds),
          ),

          // 산 경로 그리기
          CustomPaint(
            painter: MountainPathPainter(goals: goals),
            child: Container(),
          ),

          // 현재 위치 (등반자)
          if (goals.isNotEmpty) _buildClimberPosition(),

          // 목표 산봉우리들
          ...goals.asMap().entries.map((entry) {
            final index = entry.key;
            final goal = entry.value;
            return _buildPeakMarker(context, goal, index);
          }),
        ],
      ),
    );
  }

  // 현재 등반자 위치
  Widget _buildClimberPosition() {
    // 전체 진행률 계산
    double totalProgress = 0;
    int activeGoals = 0;

    for (final goal in goals) {
      if (goal.isActive) {
        totalProgress += goal.progress;
        activeGoals++;
      }
    }

    final averageProgress = activeGoals > 0
        ? (totalProgress / activeGoals) / 100
        : 0; // 100으로 나누어 0~1 범위로 정규화

    return Positioned(
      left: 30 + (averageProgress * 200), // 진행률에 따라 위치 조정
      bottom: 40 + (averageProgress * 100), // 고도 상승
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ModernColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/sherpi/sherpi_confidence.png', // 자신감 있는 셰르피
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
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

  // 산봉우리 마커
  Widget _buildPeakMarker(BuildContext context, UserGoal goal, int index) {
    final progress = goal.progress;
    final isCompleted = progress >= 100.0;
    final isActive = goal.isActive;
    final daysLeft = goal.daysRemaining;

    // 위치 계산 (목표별로 분산 배치 - 더 균등하게)
    final totalGoals = goals.length;
    final screenWidth = MediaQuery.of(context).size.width - 32; // 좌우 마진 제외
    final double xPosition =
        30 + ((screenWidth - 60) / (totalGoals + 1)) * (index + 1);
    final double yPosition = 60 + (index % 2 == 0 ? 0 : 30);

    return Positioned(
      left: xPosition,
      top: yPosition,
      child: GestureDetector(
        onTap: () => onGoalTap(goal.id),
        child: Column(
          children: [
            // 카테고리별 셰르피 이미지
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.2)
                    : (isActive
                        ? _getCategoryColor(goal.category)
                            .withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  _getCategorySherpiImage(goal.category, isCompleted),
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            )
                .animate()
                .scale(delay: (100 * index).ms, duration: 300.ms)
                .fadeIn(),

            const SizedBox(height: 4),

            // 목표 이름과 진행률
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    goal.title.length > 8
                        ? '${goal.title.substring(0, 8)}...'
                        : goal.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 진행률 바
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green : ModernColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${progress.toInt()}%',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'D-$daysLeft',
                        style: TextStyle(
                          fontSize: 9,
                          color: daysLeft <= 3 ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 산 이름 (카테고리)
            const SizedBox(height: 4),
            Text(
              _getCategoryMountain(goal.category),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryMountain(String category) {
    switch (category) {
      case 'health':
        return '🏔️ 건강봉';
      case 'study':
        return '⛰️ 지식봉';
      case 'habit':
        return '🗻 성찰봉';
      case 'social':
        return '🏔️ 우정봉';
      default:
        return '⛰️ 목표봉';
    }
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

  // 카테고리별 셰르피 이미지
  String _getCategorySherpiImage(String category, bool isCompleted) {
    if (isCompleted) {
      return 'assets/images/sherpi/sherpi_special.png'; // 완료시 특별한 표정
    }

    switch (category) {
      case 'health':
        return 'assets/images/sherpi/sherpi_cheering.png'; // 건강 목표는 응원하는 표정
      case 'study':
        return 'assets/images/sherpi/sherpi_thinking.png'; // 학습 목표는 생각하는 표정
      case 'habit':
        return 'assets/images/sherpi/sherpi_guiding.png'; // 습관 목표는 안내하는 표정
      case 'social':
        return 'assets/images/sherpi/sherpi_happy.png'; // 사교 목표는 행복한 표정
      default:
        return 'assets/images/sherpi/sherpi_default.png'; // 기본 표정
    }
  }
}

/// 산 경로를 그리는 CustomPainter
class MountainPathPainter extends CustomPainter {
  final List<UserGoal> goals;

  MountainPathPainter({required this.goals});

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 산 실루엣 그리기
    final backgroundPaint = Paint()
      ..color = ModernColors.primary.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final backgroundPath = Path();
    backgroundPath.moveTo(0, size.height);
    backgroundPath.lineTo(0, size.height * 0.5);

    // 배경 산봉우리들
    backgroundPath.quadraticBezierTo(size.width * 0.25, size.height * 0.3,
        size.width * 0.5, size.height * 0.4);
    backgroundPath.quadraticBezierTo(
        size.width * 0.75, size.height * 0.2, size.width, size.height * 0.35);
    backgroundPath.lineTo(size.width, size.height);
    backgroundPath.close();
    canvas.drawPath(backgroundPath, backgroundPaint);

    if (goals.isEmpty) return;

    final pathPaint = Paint()
      ..color = ModernColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dottedPaint = Paint()
      ..color = ModernColors.primary.withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // 시작점 (베이스 캠프)
    path.moveTo(30, size.height - 40);

    // 목표들을 연결하는 경로 그리기
    for (int i = 0; i < goals.length; i++) {
      final totalGoals = goals.length;
      final xPosition = 30 + ((size.width - 60) / (totalGoals + 1)) * (i + 1);
      final yPosition = 60 + (i % 2 == 0 ? 0 : 30) + 50;

      // 곡선으로 연결
      if (i == 0) {
        path.quadraticBezierTo(
          45,
          size.height - 60,
          xPosition.toDouble(),
          yPosition.toDouble(),
        );
      } else {
        final prevIndex = i - 1;
        final prevX =
            30 + ((size.width - 60) / (totalGoals + 1)) * (prevIndex + 1);
        final prevY = 60 + (prevIndex % 2 == 0 ? 0 : 30) + 50;

        path.quadraticBezierTo(
          (prevX + xPosition) / 2,
          (prevY + yPosition) / 2 - 20,
          xPosition.toDouble(),
          yPosition.toDouble(),
        );
      }
    }

    // 점선 경로 그리기
    _drawDashedPath(canvas, path, dottedPaint);

    // 완료된 부분 실선으로 그리기
    double totalProgress = 0;
    int activeGoals = 0;
    for (final goal in goals) {
      if (goal.isActive) {
        totalProgress += goal.progress;
        activeGoals++;
      }
    }
    final averageProgress = activeGoals > 0
        ? (totalProgress / activeGoals) / 100
        : 0; // 0~1 범위로 정규화

    if (averageProgress > 0) {
      final metrics = path.computeMetrics().first;
      final extractPath =
          metrics.extractPath(0, metrics.length * averageProgress);
      canvas.drawPath(extractPath, pathPaint);
    }

    // 베이스 캠프 그리기
    final baseCampPaint = Paint()
      ..color = ModernColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(0, 8), 8, baseCampPaint);

    // 베이스 캠프 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'START',
        style: GoogleFonts.notoSans(
          fontSize: 10,
          color: Colors.orange[800],
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0, 0));
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final extractPath = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
