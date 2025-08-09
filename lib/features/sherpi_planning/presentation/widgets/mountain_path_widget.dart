import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/app_colors.dart';

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
            const Color(0xFF87CEEB).withOpacity(0.3), // 하늘색
            const Color(0xFF90EE90).withOpacity(0.2), // 연한 초록
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
              color: Colors.white.withOpacity(0.6),
            ).animate(onPlay: (controller) => controller.repeat())
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
            ).animate(onPlay: (controller) => controller.repeat())
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
    
    final averageProgress = activeGoals > 0 ? totalProgress / activeGoals : 0;
    
    return Positioned(
      left: 30 + (averageProgress * 200), // 진행률에 따라 위치 조정
      bottom: 40 + (averageProgress * 100), // 고도 상승
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
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
  
  // 산봉우리 마커
  Widget _buildPeakMarker(BuildContext context, UserGoal goal, int index) {
    final progress = goal.progress;
    final isCompleted = progress >= 1.0;
    final isActive = goal.isActive;
    
    // 위치 계산 (목표별로 분산 배치)
    final double xPosition = 60 + (index * 80.0);
    final double yPosition = 80 - (index * 20.0);
    
    return Positioned(
      left: xPosition,
      top: yPosition,
      child: GestureDetector(
        onTap: () => onGoalTap(goal.id),
        child: Column(
          children: [
            // 산 또는 깃발 아이콘
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green.withOpacity(0.2)
                    : (isActive ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.2)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isCompleted ? Icons.flag : Icons.terrain,
                  color: isCompleted 
                      ? Colors.green 
                      : (isActive ? AppColors.primary : Colors.grey),
                  size: 28,
                ),
              ),
            ).animate()
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
                    color: Colors.black.withOpacity(0.1),
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
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green : AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                    ),
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
}

/// 산 경로를 그리는 CustomPainter
class MountainPathPainter extends CustomPainter {
  final List<UserGoal> goals;

  MountainPathPainter({required this.goals});

  @override
  void paint(Canvas canvas, Size size) {
    if (goals.isEmpty) return;
    
    final pathPaint = Paint()
      ..color = Colors.brown.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final dottedPaint = Paint()
      ..color = Colors.brown.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    // 시작점 (베이스 캠프)
    path.moveTo(30, size.height - 40);
    
    // 목표들을 연결하는 경로 그리기
    for (int i = 0; i < goals.length; i++) {
      final xPosition = 60 + (i * 80.0);
      final yPosition = 80 + (i * 20.0);
      
      // 곡선으로 연결
      if (i == 0) {
        path.quadraticBezierTo(
          45,
          size.height - 60,
          xPosition + 25,
          yPosition + 50,
        );
      } else {
        final prevX = 60 + ((i - 1) * 80.0);
        final prevY = 80 + ((i - 1) * 20.0);
        
        path.quadraticBezierTo(
          (prevX + xPosition) / 2 + 25,
          (prevY + yPosition) / 2 + 30,
          xPosition + 25,
          yPosition + 50,
        );
      }
    }
    
    // 실선 경로 그리기
    canvas.drawPath(path, pathPaint);
    
    // 점선 효과 추가
    for (double i = 0; i < 1; i += 0.02) {
      final metric = path.computeMetrics().first;
      final offset = metric.getTangentForOffset(metric.length * i)?.position;
      if (offset != null && i % 0.04 < 0.02) {
        canvas.drawCircle(offset, 1, dottedPaint);
      }
    }
    
    // 베이스 캠프 그리기
    final baseCampPaint = Paint()
      ..color = Colors.orange[700]!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(30, size.height - 40), 8, baseCampPaint);
    
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
    textPainter.paint(canvas, Offset(15, size.height - 25));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}