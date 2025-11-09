import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/widgets/sherpa_clean_app_bar.dart';
import 'package:sherpa_app/shared/widgets/sherpa_button.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_point_provider.dart';
import 'package:sherpa_app/features/goals/models/achievement_analysis_model.dart';

/// AI 분석 화면
///
/// 목표 달성에 대한 셰르피의 AI 분석을 제공하는 화면
class AiAnalysisScreen extends ConsumerStatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen> {
  String? _selectedCategory;
  bool _isLoading = false;
  AchievementAnalysisModel? _analysisResult;

  @override
  Widget build(BuildContext context) {
    final totalPoints = ref.watch(globalTotalPointsProvider);

    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: const SherpaCleanAppBar(
        title: '셰르피 분석',
        backgroundColor: ModernColors.background,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _analysisResult != null
              ? _buildAnalysisResult()
              : _buildCategorySelection(totalPoints),
    );
  }

  /// 카테고리 선택 화면
  Widget _buildCategorySelection(int totalPoints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설명 카드
          _buildInfoCard(totalPoints),
          const SizedBox(height: 24),

          // 카테고리 선택
          Text(
            '분석할 목표 카테고리를 선택하세요',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildCategoryCard('운동', Icons.fitness_center, ModernColors.exercise,
              '운동 목표 달성 분석 및 개선 방안'),
          const SizedBox(height: 12),
          _buildCategoryCard('대회', Icons.emoji_events, ModernColors.quest,
              '대회 참여 목표 분석 및 전략 제안'),
          const SizedBox(height: 12),
          _buildCategoryCard(
              '학습', Icons.school, ModernColors.reading, '학습 목표 달성 분석 및 학습 전략'),
          const SizedBox(height: 12),
          _buildCategoryCard('자격증', Icons.workspace_premium, ModernColors.focus,
              '자격증 취득 목표 분석 및 준비 계획'),
          const SizedBox(height: 24),

          // 분석 시작 버튼
          if (_selectedCategory != null)
            SherpaButton(
              text: '분석 시작 (30P)',
              onPressed: () => _startAnalysis(totalPoints),
              backgroundColor: ModernColors.quest,
            ),
        ],
      ),
    );
  }

  /// 정보 카드
  Widget _buildInfoCard(int totalPoints) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.quest.withValues(alpha: 0.1),
            ModernColors.quest.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.quest.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernColors.quest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 24,
                  color: ModernColors.quest,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '셰르피 AI 분석',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ModernColors.quest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '30 포인트',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '셰르피가 당신의 목표 달성 과정을 분석하고, 개선 방안과 전략을 제시해드립니다.',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 16,
                color: ModernColors.quest,
              ),
              const SizedBox(width: 6),
              Text(
                '보유 포인트: $totalPoints P',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.quest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 카테고리 카드
  Widget _buildCategoryCard(
      String category, IconData icon, Color color, String description) {
    final isSelected = _selectedCategory == category;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withValues(alpha: 0.1) : ModernColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : ModernColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: ModernColors.quest,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// 로딩 상태
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ModernColors.quest.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ModernColors.quest),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '셰르피가 분석 중입니다...',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '잠시만 기다려주세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 분석 결과 화면
  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildResultHeader(),
          const SizedBox(height: 24),

          // 분석 내용
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ModernColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _analysisResult!.analysisContent,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ModernColors.textPrimary,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 다시 분석하기 버튼
          SherpaButton(
            text: '다시 분석하기',
            onPressed: () {
              setState(() {
                _analysisResult = null;
                _selectedCategory = null;
              });
            },
            backgroundColor: Colors.transparent,
            textColor: ModernColors.quest,
          ),
        ],
      ),
    );
  }

  /// 결과 헤더
  Widget _buildResultHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.quest,
            ModernColors.quest.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '셰르피 분석 결과',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_analysisResult!.category} 카테고리 분석',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '분석 일시: ${_analysisResult!.analyzedAt.toString().split('.')[0]}',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 분석 시작
  void _startAnalysis(int totalPoints) {
    // 포인트 부족 체크
    if (totalPoints < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '포인트가 부족합니다. (필요: 30P, 보유: ${totalPoints}P)',
            style: GoogleFonts.notoSans(),
          ),
          backgroundColor: ModernColors.error,
        ),
      );
      return;
    }

    // 확인 다이얼로그
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '셰르피 분석 시작',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '30 포인트를 사용하여 "$_selectedCategory" 카테고리의 목표를 분석하시겠습니까?',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: GoogleFonts.notoSans()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performAnalysis();
            },
            child: Text(
              '분석 시작',
              style: GoogleFonts.notoSans(color: ModernColors.quest),
            ),
          ),
        ],
      ),
    );
  }

  /// 분석 수행
  Future<void> _performAnalysis() async {
    // 포인트 차감
    ref.read(globalPointProvider.notifier).addPoints(
          -30,
          'AI 목표 분석 - $_selectedCategory 카테고리',
          type: PointTransactionType.spent,
        );

    // 로딩 시작
    setState(() {
      _isLoading = true;
    });

    // 시뮬레이션: 2초 대기 후 데모 결과 표시
    await Future.delayed(const Duration(seconds: 2));

    // 데모 분석 결과 생성
    final analysisResult = AchievementAnalysisHelper.createDemoAnalysis(
      category: _selectedCategory!,
      goalIds: [],
      routineIds: [],
    );

    // 결과 표시
    if (mounted) {
      setState(() {
        _analysisResult = analysisResult;
        _isLoading = false;
      });
    }
  }
}
