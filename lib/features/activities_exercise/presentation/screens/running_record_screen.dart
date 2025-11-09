// lib/features/activities_exercise/presentation/screens/running_record_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import '../widgets/running_record_form.dart';

class RunningRecordScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const RunningRecordScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  ConsumerState<RunningRecordScreen> createState() =>
      _RunningRecordScreenState();
}

class _RunningRecordScreenState extends ConsumerState<RunningRecordScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _canSubmit = false;
  bool _isSubmitting = false;
  final GlobalKey<RunningRecordFormState> _formKey =
      GlobalKey<RunningRecordFormState>();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black87, size: 20),
          ),
        ),
        actions: [
          // 완료 버튼
          if (_canSubmit)
            Semantics(
              label: '러닝 기록 저장',
              button: true,
              hint: '입력한 러닝 기록을 저장하고 이전 화면으로 돌아갑니다',
              enabled: !_isSubmitting,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: _isSubmitting ? null : _submitRunning,
                  child: Text(
                    '완료',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _isSubmitting
                          ? ModernColors.textTertiary
                          : ModernColors.exercise,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 배경 그라데이션 (오렌지 계열)
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ModernColors.exercise,
                    ModernColors.exercise.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // 메인 콘텐츠
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 120), // AppBar 공간

                  // 헤더 섹션
                  _buildHeader(),

                  const SizedBox(height: 32),

                  // 러닝 전용 폼
                  RunningRecordForm(
                    key: _formKey,
                    selectedDate: widget.selectedDate,
                    onFormValidityChanged: (isValid) {
                      setState(() {
                        _canSubmit = isValid;
                      });
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[(widget.selectedDate.weekday - 1) % 7];
    final dateStr =
        '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ModernColors.exercise.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 제목과 아이콘
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.exercise,
                      ModernColors.exercise.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.exercise.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🏃‍♂️',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '러닝 기록하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ModernColors.exercise,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘의 러닝을 기록하세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 날짜 정보 - Borderless Design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.exercise.withValues(alpha: 0.05),
                  ModernColors.exercise.withValues(alpha: 0.08),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.exercise.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: ModernColors.exercise,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  dateStr,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.exercise,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  weekday,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.exercise,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 완료 버튼 클릭 시 호출되는 메서드
  Future<void> _submitRunning() async {
    setState(() {
      _isSubmitting = true;
    });

    // GlobalKey를 통해 폼의 submit 메서드 호출
    await _formKey.currentState?.submitRunningRecord();

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
