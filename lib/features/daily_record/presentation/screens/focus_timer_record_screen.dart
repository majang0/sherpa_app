// lib/features/daily_record/presentation/screens/focus_timer_record_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import '../../../../shared/providers/global_user_provider.dart';


class FocusTimerRecordScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<FocusTimerRecordScreen> createState() => _FocusTimerRecordScreenState();
}

class _FocusTimerRecordScreenState extends ConsumerState<FocusTimerRecordScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  Timer? _timer;
  int _selectedMinutes = 30;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  final List<int> _presetMinutes = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _remainingSeconds = _selectedMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isRunning 
          ? const Color(0xFF1A1A2E) 
          : const Color(0xFFF7F9FB),
      appBar: SherpaCleanAppBar(
        title: '몰입 타이머',
        backgroundColor: _isRunning 
            ? const Color(0xFF1A1A2E) 
            : Colors.white,
        foregroundColor: _isRunning ? Colors.white : null,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        child: _isRunning 
            ? _buildRunningTimer()
            : _buildTimerSetup(),
      ),
    );
  }

  Widget _buildTimerSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildTimePresets(),
          const SizedBox(height: 32),
          _buildCustomTimeInput(),
          const SizedBox(height: 32),
          _buildFocusDescription(),
          const SizedBox(height: 40),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '몰입의 시간',
          style: GoogleFonts.notoSans(
            fontSize: 32,
            fontWeight: FontWeight.w200,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '디지털 디톡스로 깊은 집중을 경험해보세요',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
            height: 1.5,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시간 선택',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: AppColors.textPrimary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _presetMinutes.map((minutes) {
            final isSelected = _selectedMinutes == minutes;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMinutes = minutes;
                  _remainingSeconds = minutes * 60;
                });
                HapticFeedbackManager.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.transparent 
                        : AppColors.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '${minutes}분',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomTimeInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '직접 설정',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_selectedMinutes}분',
                  style: GoogleFonts.notoSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedMinutes = math.min(_selectedMinutes + 5, 180);
                        _remainingSeconds = _selectedMinutes * 60;
                      });
                      HapticFeedbackManager.lightImpact();
                    },
                    icon: Icon(Icons.add, color: AppColors.primary),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedMinutes = math.max(_selectedMinutes - 5, 5);
                        _remainingSeconds = _selectedMinutes * 60;
                      });
                      HapticFeedbackManager.lightImpact();
                    },
                    icon: Icon(Icons.remove, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '몰입 모드 안내',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 타이머 실행 중에는 알림이 차단됩니다\n• 깊은 호흡과 함께 집중해보세요\n• 30분 이상 완료하면 자동으로 퀘스트가 완료됩니다',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startTimer,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 24),
            const SizedBox(width: 8),
            Text(
              '몰입 시작',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunningTimer() {
    final progress = 1.0 - (_remainingSeconds / (_selectedMinutes * 60));
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Stack(
      children: [
        // 배경 파티클 효과
        _buildParticleBackground(),
        
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 타이머 원형 표시
              _buildCircularTimer(progress, minutes, seconds),
              const SizedBox(height: 40),
              
              // 현재 시간 표시
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: GoogleFonts.robotoMono(
                  fontSize: 52,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: 4,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              
              // 상태 메시지
              Text(
                _isPaused ? '일시정지됨' : '몰입 중...',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              
              // 컨트롤 버튼들
              _buildControlButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularTimer(double progress, int minutes, int seconds) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 250,
            height: 250,
            child: Stack(
              children: [
                // 배경 원
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                // 진행률 원
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
                    ),
                  ),
                ),
                // 중앙 아이콘
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Icon(
                      _isPaused ? Icons.pause : Icons.self_improvement,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleBackground() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(_rippleAnimation.value),
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 일시정지/재시작 버튼
        ElevatedButton(
          onPressed: _togglePause,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            shape: const CircleBorder(),
            elevation: 0,
          ),
          child: Icon(
            _isPaused ? Icons.play_arrow : Icons.pause,
            size: 24,
          ),
        ),
        const SizedBox(width: 40),
        
        // 정지 버튼
        ElevatedButton(
          onPressed: _stopTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            shape: const CircleBorder(),
            elevation: 0,
          ),
          child: const Icon(Icons.stop, size: 24),
        ),
      ],
    );
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    HapticFeedbackManager.heavyImpact();
    _pulseController.repeat(reverse: true);
    _rippleController.repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 0) {
          _completeTimer();
        }
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _pulseController.stop();
    } else {
      _pulseController.repeat(reverse: true);
    }
    
    HapticFeedbackManager.mediumImpact();
  }

  void _stopTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _rippleController.stop();
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
    
    HapticFeedbackManager.mediumImpact();
  }

  void _completeTimer() async {
    _timer?.cancel();
    _pulseController.stop();
    _rippleController.stop();

    // 몰입 시간 기록
    ref.read(globalUserProvider.notifier).updateFocusTime(_selectedMinutes);

    HapticFeedbackManager.heavyImpact();

    // 완료 다이얼로그
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '몰입 완료!',
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedMinutes}분간의 깊은 몰입을 마쳤습니다.\n정말 훌륭해요! 🎉',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '확인',
                  style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

/// 파티클 배경 페인터
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 배경에 떠다니는 파티클들
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i + 
                math.sin(animationValue * 2 * math.pi + i) * 30;
      final y = (size.height / 10) * (i % 10) + 
                math.cos(animationValue * 2 * math.pi + i) * 20;
      
      canvas.drawCircle(
        Offset(x, y),
        2 + math.sin(animationValue * 4 * math.pi + i) * 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}