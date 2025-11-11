import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/core/animation/micro_interactions.dart';
import 'package:sherpa_app/features/goals/models/routine_model.dart';
import 'package:sherpa_app/features/goals/providers/routine_provider.dart';

/// 이전 루틴 다이얼로그 (Complete Redesign - 2025-11-11)
///
/// 요구사항:
/// - [카테고리] 제목 / 날짜 범위 / 달성률 / 완주여부 표시
/// - 100% 달성 + 완주 시 골드 프리미엄 효과
/// - 클릭 시 상세 보기 및 삭제 가능 (수정 불가)
/// - 7개 샘플 루틴 자동 생성
class PreviousRoutinesDialog extends ConsumerStatefulWidget {
  const PreviousRoutinesDialog({super.key});

  @override
  ConsumerState<PreviousRoutinesDialog> createState() =>
      _PreviousRoutinesDialogState();
}

class _PreviousRoutinesDialogState
    extends ConsumerState<PreviousRoutinesDialog> {
  List<RoutineModel> _previousRoutines = [];
  List<RoutineModel> _filteredRoutines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreviousRoutines();
  }

  Future<void> _loadPreviousRoutines() async {
    setState(() => _isLoading = true);

    // 실제 데이터 로드 시도
    final routines =
        await ref.read(routineProvider.notifier).loadPreviousRoutines();

    // 실제 데이터 + 샘플 데이터 합치기 (개발용)
    final sampleRoutines = _generateSampleRoutines();
    final allRoutines = [...routines, ...sampleRoutines];

    setState(() {
      _previousRoutines = allRoutines;
      _filteredRoutines = allRoutines;
      _isLoading = false;
    });
  }

  /// 샘플 루틴 7개 생성
  List<RoutineModel> _generateSampleRoutines() {
    return [
      // 1. 완주 + 100% (골드 프리미엄 효과)
      RoutineModel(
        id: 'sample_1',
        category: '운동',
        name: '매주 월요일 등산하기',
        frequency: '주1회',
        weekdays: const ['월'],
        period: '언제까지',
        endDate: DateTime(2025, 10, 25),
        checkHistory: List.generate(8, (i) => '2025-09-${(i + 1) * 3}'),
        completionRate: 1.0,
        isCompleted: true,
        createdAt: DateTime(2025, 9, 1),
        finishedAt: DateTime(2025, 10, 25),
      ),

      // 2. 완주 + 100% (골드 프리미엄 효과)
      RoutineModel(
        id: 'sample_2',
        category: '학습',
        name: '매일 영어 단어 30개 외우기',
        frequency: '매일',
        period: '언제까지',
        endDate: DateTime(2025, 9, 30),
        checkHistory: List.generate(
            77, (i) => DateFormat('yyyy-MM-dd').format(DateTime(2025, 7, 15).add(Duration(days: i)))),
        completionRate: 1.0,
        isCompleted: true,
        createdAt: DateTime(2025, 7, 15),
        finishedAt: DateTime(2025, 9, 30),
      ),

      // 3. 미완주 + 73% (초록 프로그레스바)
      RoutineModel(
        id: 'sample_3',
        category: '문화',
        name: '주 1회 독서 한 권 완독하기',
        frequency: '주1회',
        weekdays: const ['일'],
        period: '언제까지',
        endDate: DateTime(2025, 10, 12),
        checkHistory: List.generate(8, (i) => '2025-08-${(i + 1) * 3}'),
        completionRate: 0.73,
        isCompleted: false,
        createdAt: DateTime(2025, 8, 10),
        finishedAt: DateTime(2025, 10, 12),
      ),

      // 4. 미완주 + 51% (노랑 프로그레스바)
      RoutineModel(
        id: 'sample_4',
        category: '건강',
        name: '매일 10분 명상하기',
        frequency: '매일',
        period: '언제까지',
        endDate: DateTime(2025, 8, 15),
        checkHistory: List.generate(
            38, (i) => DateFormat('yyyy-MM-dd').format(DateTime(2025, 6, 1).add(Duration(days: i * 2)))),
        completionRate: 0.51,
        isCompleted: false,
        createdAt: DateTime(2025, 6, 1),
        finishedAt: DateTime(2025, 8, 15),
      ),

      // 5. 미완주 + 29% (빨강 프로그레스바)
      RoutineModel(
        id: 'sample_5',
        category: '운동',
        name: '주 3회 수영하기',
        frequency: '주3회',
        weekdays: const ['월', '수', '금'],
        period: '언제까지',
        endDate: DateTime(2025, 7, 20),
        checkHistory: List.generate(9, (i) => '2025-05-${(i + 1) * 3}'),
        completionRate: 0.29,
        isCompleted: false,
        createdAt: DateTime(2025, 5, 1),
        finishedAt: DateTime(2025, 7, 20),
      ),

      // 6. 미완주 + 85% (초록 프로그레스바)
      RoutineModel(
        id: 'sample_6',
        category: '문화',
        name: '주 1회 박물관 방문하기',
        frequency: '주1회',
        weekdays: const ['토'],
        period: '언제까지',
        endDate: DateTime(2025, 9, 28),
        checkHistory: List.generate(20, (i) => '2025-04-${(i + 1) * 2}'),
        completionRate: 0.85,
        isCompleted: false,
        createdAt: DateTime(2025, 4, 10),
        finishedAt: DateTime(2025, 9, 28),
      ),

      // 7. 미완주 + 16% (빨강 프로그레스바)
      RoutineModel(
        id: 'sample_7',
        category: '기타',
        name: '매일 일기 쓰기',
        frequency: '매일',
        period: '언제까지',
        endDate: DateTime(2025, 4, 30),
        checkHistory: List.generate(
            10, (i) => DateFormat('yyyy-MM-dd').format(DateTime(2025, 3, 1).add(Duration(days: i * 6)))),
        completionRate: 0.16,
        isCompleted: false,
        createdAt: DateTime(2025, 3, 1),
        finishedAt: DateTime(2025, 4, 30),
      ),
    ];
  }

  /// 루틴 삭제
  Future<void> _deleteRoutine(RoutineModel routine) async {
    final confirmed = await _showDeleteConfirmation(routine);
    if (confirmed == true) {
      // 샘플 데이터는 로컬에서만 삭제
      setState(() {
        _previousRoutines.removeWhere((r) => r.id == routine.id);
        _filteredRoutines.removeWhere((r) => r.id == routine.id);
      });

      // 실제 Provider 데이터도 삭제
      await ref.read(routineProvider.notifier).deleteRoutine(routine.id);
    }
  }

  /// 삭제 확인 다이얼로그
  Future<bool?> _showDeleteConfirmation(RoutineModel routine) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ModernColors.error.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ModernColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 32,
                  color: ModernColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '루틴 삭제',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '정말 이 루틴을 삭제하시겠습니까?',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: ModernColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                routine.name,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: MicroInteractions.tapResponse(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: ModernColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '취소',
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MicroInteractions.tapResponse(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: ModernColors.error,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: ModernColors.error.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '삭제',
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF8F5), // Soft peach (routine theme)
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.success.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredRoutines.isEmpty
                          ? _buildEmptyState()
                          : _buildRoutineList(),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// 헤더
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: ModernColors.success.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Success 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  ModernColors.success,
                  Color(0xFF059669),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernColors.success.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.repeat,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // 타이틀
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이전 루틴',
                  style: GoogleFonts.notoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: ModernColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_filteredRoutines.length}개의 루틴',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 닫기 버튼
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: ModernColors.textSecondary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    ModernColors.success.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.repeat_outlined,
                size: 56,
                color: ModernColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '이전 루틴이 없어요',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '완료하거나 삭제한 루틴이 여기에 표시됩니다',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: ModernColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 루틴 리스트
  Widget _buildRoutineList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredRoutines.length,
      itemBuilder: (context, index) {
        final routine = _filteredRoutines[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRoutineCard(routine, index),
        );
      },
    );
  }

  /// 루틴 카드 (완전 리뉴얼)
  Widget _buildRoutineCard(RoutineModel routine, int index) {
    final isPerfect = routine.isCompleted && routine.completionRate >= 1.0;
    final categoryColor = _getCategoryColor(routine.category);
    final progressColor = _getProgressColor(routine.completionRate);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 4px 카테고리 컬러 라인 (카드 중앙에 고정 배치)
        Container(
          width: 4,
          height: 80,
          decoration: BoxDecoration(
            gradient: isPerfect
                ? const LinearGradient(
                    colors: [ModernColors.perfectGold, ModernColors.perfectOrange],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      categoryColor,
                      categoryColor.withValues(alpha: 0.5)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),

        // 카드 본문
        Expanded(
          child: MicroInteractions.tapResponse(
            onTap: () => _showRoutineDetail(routine),
            scaleDownTo: 0.98,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // 완주 + 100% → 흰색 배경 (골드 효과는 테두리와 그림자로만)
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPerfect
                      ? ModernColors.perfectGold.withValues(alpha: 0.3)
                      : categoryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPerfect
                        ? ModernColors.perfectGold.withValues(alpha: 0.15)
                        : categoryColor.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더: 카테고리 + 제목 + 트로피
                  Row(
                    children: [
                      Icon(_getCategoryIcon(routine.category),
                          color: categoryColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '[${routine.category}]',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          routine.name,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPerfect)
                        const Icon(
                          Icons.emoji_events,
                          color: ModernColors.perfectGold,
                          size: 22,
                        ),
                      const SizedBox(width: 8),
                      // 삭제 버튼
                      MicroInteractions.tapResponse(
                        onTap: () => _deleteRoutine(routine),
                        scaleDownTo: 0.95,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: ModernColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: ModernColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 날짜 범위
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: ModernColors.textSecondary.withValues(alpha: 0.6),
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${DateFormat('yyyy.MM.dd').format(routine.createdAt ?? DateTime.now())} ~ ${DateFormat('yyyy.MM.dd').format(routine.finishedAt ?? DateTime.now())}',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: ModernColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 프로그레스바 + 퍼센트
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: routine.completionRate,
                            minHeight: 8,
                            backgroundColor:
                                Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(progressColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(routine.completionRate * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 완주 여부 버튼 (프로그레스바 하단 중앙)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isPerfect
                            ? ModernColors.perfectGradient
                            : null,
                        color: isPerfect
                            ? null
                            : routine.isCompleted
                                ? ModernColors.success
                                : ModernColors.textSecondary
                                    .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isPerfect
                            ? [
                                BoxShadow(
                                  color: ModernColors.perfectGold
                                      .withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        routine.isCompleted ? '완주' : '미완주',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isPerfect || routine.isCompleted
                              ? Colors.white
                              : ModernColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
            delay: (150 + (index * 100)).ms,
            duration: 600.ms,
            curve: Curves.easeOutCubic)
        .slideX(
            begin: 0.05,
            end: 0,
            delay: (100 + (index * 80)).ms,
            curve: Curves.easeOutQuart);
  }

  /// 루틴 상세 다이얼로그
  void _showRoutineDetail(RoutineModel routine) {
    final isPerfect = routine.isCompleted && routine.completionRate >= 1.0;
    final categoryColor = _getCategoryColor(routine.category);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: isPerfect
                ? Border.all(
                    color: ModernColors.perfectGold.withValues(alpha: 0.2),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isPerfect
                    ? ModernColors.perfectGold.withValues(alpha: 0.15)
                    : categoryColor.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isPerfect
                          ? ModernColors.perfectGradient
                          : LinearGradient(
                              colors: [categoryColor, categoryColor],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isPerfect
                              ? ModernColors.perfectGold.withValues(alpha: 0.3)
                              : categoryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getCategoryIcon(routine.category),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.category,
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                        Text(
                          routine.name,
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isPerfect)
                    const Icon(
                      Icons.emoji_events,
                      color: ModernColors.perfectGold,
                      size: 32,
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // 상세 정보
              _buildDetailRow(
                Icons.repeat,
                '주기',
                routine.frequency,
                categoryColor,
              ),
              _buildDetailRow(
                Icons.calendar_today,
                '시작일',
                DateFormat('yyyy년 MM월 dd일')
                    .format(routine.createdAt ?? DateTime.now()),
                categoryColor,
              ),
              _buildDetailRow(
                Icons.event_available,
                '종료일',
                DateFormat('yyyy년 MM월 dd일')
                    .format(routine.finishedAt ?? DateTime.now()),
                categoryColor,
              ),
              _buildDetailRow(
                Icons.check_circle,
                '완료 횟수',
                '${routine.checkHistory.length}회',
                categoryColor,
              ),
              _buildDetailRow(
                Icons.trending_up,
                '달성률',
                '${(routine.completionRate * 100).toStringAsFixed(0)}%',
                _getProgressColor(routine.completionRate),
              ),
              _buildDetailRow(
                Icons.flag,
                '상태',
                routine.isCompleted ? '완주' : '미완주',
                routine.isCompleted ? ModernColors.success : ModernColors.warning,
              ),

              const SizedBox(height: 20),

              // 닫기 버튼
              MicroInteractions.tapResponse(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isPerfect
                        ? ModernColors.perfectGradient
                        : LinearGradient(
                            colors: [categoryColor, categoryColor],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isPerfect
                            ? ModernColors.perfectGold.withValues(alpha: 0.3)
                            : categoryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '닫기',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상세 정보 행
  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 프로그레스바 색상 결정
  Color _getProgressColor(double rate) {
    if (rate >= 1.0) return ModernColors.perfectGold; // 골드
    if (rate >= 0.7) return ModernColors.success; // 초록
    if (rate >= 0.4) return ModernColors.warning; // 노랑
    return ModernColors.error; // 빨강
  }

  /// 카테고리 색상
  Color _getCategoryColor(String category) {
    switch (category) {
      case '운동':
        return ModernColors.exercise; // 오렌지
      case '문화':
        return ModernColors.reading; // 그린
      case '학습':
        return ModernColors.primary; // 푸른색
      case '건강':
        return ModernColors.error; // 붉은색
      case '기타':
        return ModernColors.meeting; // 시안
      default:
        return ModernColors.meeting;
    }
  }

  /// 카테고리 아이콘
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '운동':
        return Icons.directions_run;
      case '문화':
        return Icons.menu_book;
      case '학습':
        return Icons.school;
      case '건강':
        return Icons.favorite;
      case '기타':
        return Icons.star;
      default:
        return Icons.star;
    }
  }
}
