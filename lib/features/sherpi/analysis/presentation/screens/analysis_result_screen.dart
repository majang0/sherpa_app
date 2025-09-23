import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../services/user_data_analyzer.dart';

/// 분석 결과 화면
class AnalysisResultScreen extends ConsumerStatefulWidget {
  final AnalysisResult analysisResult;

  const AnalysisResultScreen({
    super.key,
    required this.analysisResult,
  });

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // 커스텀 앱바
          _buildSliverAppBar(),

          // 탭바
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(_tabController),
          ),

          // 탭 컨텐츠
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPatternsTab(),
                _buildInsightsTab(),
                _buildRecommendationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 커스텀 슬라이버 앱바
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '나의 성장 분석',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // 배경 패턴
              Positioned.fill(
                child: CustomPaint(
                  painter: _PatternPainter(),
                ),
              ),
              // 분석 날짜
              Positioned(
                bottom: 60,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.analysisResult.analyzedAt.year}년 ${widget.analysisResult.analyzedAt.month}월 ${widget.analysisResult.analyzedAt.day}일 분석',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 개요 탭
  Widget _buildOverviewTab() {
    final patterns = widget.analysisResult.activityPatterns;
    final performance = widget.analysisResult.performanceMetrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핵심 지표 카드들
          _buildMetricCards(patterns, performance),
          const SizedBox(height: 24),

          // 활동 분포 차트
          _buildActivityDistributionCard(),
          const SizedBox(height: 20),

          // 요일별 활동 차트
          _buildWeeklyActivityChart(),
          const SizedBox(height: 20),

          // 기분 분포 차트
          _buildMoodDistributionCard(),
        ],
      ),
    );
  }

  /// 패턴 탭
  Widget _buildPatternsTab() {
    final patterns = widget.analysisResult.activityPatterns;
    final mood = widget.analysisResult.moodAnalysis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 활동 패턴 상세
          _buildPatternDetailCard(
            title: '활동 시간대 분석',
            icon: Icons.access_time,
            children: [
              _buildPatternItem(
                '가장 활발한 시간',
                patterns.mostActiveTime,
                Icons.wb_sunny,
                Colors.orange,
              ),
              _buildPatternItem(
                '가장 활발한 요일',
                patterns.mostActiveDay,
                Icons.calendar_today,
                Colors.blue,
              ),
              _buildPatternItem(
                '일관성 점수',
                '${patterns.consistencyScore.toStringAsFixed(0)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 연속 기록
          _buildStreakCard(patterns),
          const SizedBox(height: 20),

          // 기분 패턴
          _buildMoodPatternCard(mood),
        ],
      ),
    );
  }

  /// 인사이트 탭
  Widget _buildInsightsTab() {
    final insights = widget.analysisResult.insights;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        final insight = insights[index];
        return _buildInsightCard(insight)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 * index))
            .slideY(begin: 0.1, end: 0);
      },
    );
  }

  /// 추천사항 탭
  Widget _buildRecommendationsTab() {
    final recommendations = widget.analysisResult.recommendations;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return _buildRecommendationCard(recommendation)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 * index))
            .slideX(begin: 0.1, end: 0);
      },
    );
  }

  /// 핵심 지표 카드들
  Widget _buildMetricCards(
      ActivityPatterns patterns, PerformanceMetrics performance) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildMetricCard(
          title: '총 활동',
          value: performance.totalActivities.toString(),
          icon: Icons.fitness_center,
          color: Colors.blue,
        ),
        _buildMetricCard(
          title: '목표 달성률',
          value: '${performance.goalCompletionRate.toStringAsFixed(0)}%',
          icon: Icons.flag,
          color: Colors.green,
        ),
        _buildMetricCard(
          title: '현재 연속',
          value: '${patterns.currentStreak}일',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        _buildMetricCard(
          title: '평균 만족도',
          value: performance.averageSatisfaction.toStringAsFixed(1),
          icon: Icons.sentiment_satisfied,
          color: Colors.purple,
        ),
      ],
    );
  }

  /// 지표 카드
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms, duration: 400.ms);
  }

  /// 활동 분포 카드
  Widget _buildActivityDistributionCard() {
    final activityData =
        widget.analysisResult.activityPatterns.activityFrequency;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '활동 분포',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _createPieChartSections(activityData),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 범례
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: activityData.entries.map((entry) {
              final color = _getActivityColor(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.key}: ${entry.value}회',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 요일별 활동 차트
  Widget _buildWeeklyActivityChart() {
    final weeklyData =
        widget.analysisResult.activityPatterns.weeklyDistribution;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '요일별 활동 패턴',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: _createBarGroups(weeklyData),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['월', '화', '수', '목', '금', '토', '일'];
                        return Text(
                          days[value.toInt() - 1],
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 기분 분포 카드
  Widget _buildMoodDistributionCard() {
    final moodData = widget.analysisResult.moodAnalysis.moodDistribution;

    if (moodData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기분 분포',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...moodData.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    _getMoodEmoji(entry.key),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMoodLabel(entry.key),
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getMoodColor(entry.key),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.value.toStringAsFixed(0)}%',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 패턴 상세 카드
  Widget _buildPatternDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  /// 패턴 아이템
  Widget _buildPatternItem(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 연속 기록 카드
  Widget _buildStreakCard(ActivityPatterns patterns) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '연속 기록',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  '현재 ${patterns.currentStreak}일 연속!',
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '최장 기록: ${patterns.longestStreak}일',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 기분 패턴 카드
  Widget _buildMoodPatternCard(MoodAnalysis mood) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기분 분석',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _getMoodEmoji(mood.dominantMood),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주요 기분',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _getMoodLabel(mood.dominantMood),
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '안정성: ${mood.moodStability.toStringAsFixed(0)}%',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (mood.activityMoodMap.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              '활동별 기분',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mood.activityMoodMap.entries.map((entry) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMoodColor(entry.value).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getMoodColor(entry.value).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getMoodEmoji(entry.value),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 인사이트 카드
  Widget _buildInsightCard(Insight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getInsightColor(insight.type).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getInsightColor(insight.type).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getInsightColor(insight.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              insight.icon,
              color: _getInsightColor(insight.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        insight.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getInsightColor(insight.type)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getInsightTypeLabel(insight.type),
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getInsightColor(insight.type),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  insight.description,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 추천사항 카드
  Widget _buildRecommendationCard(Recommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // 추천사항 액션 처리
            _handleRecommendationAction(recommendation);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getRecommendationColor(recommendation.type),
                        _getRecommendationColor(recommendation.type)
                            .withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    recommendation.icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.title,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation.description,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRecommendationColor(recommendation.type)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recommendation.actionText,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getRecommendationColor(recommendation.type),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 우선순위 표시
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        recommendation.priority,
                        (index) => const Icon(
                          Icons.star,
                          size: 8,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === 헬퍼 메서드들 ===

  List<PieChartSectionData> _createPieChartSections(Map<String, int> data) {
    final total = data.values.fold(0, (sum, value) => sum + value);

    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = _getActivityColor(entry.key);

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _createBarGroups(Map<int, double> data) {
    return data.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: AppColors.primary,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }

  Color _getActivityColor(String activity) {
    switch (activity) {
      case '운동':
        return Colors.blue;
      case '독서':
        return Colors.green;
      case '일기':
        return Colors.purple;
      case '모임':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'very_happy':
        return '😄';
      case 'happy':
        return '😊';
      case 'good':
        return '🙂';
      case 'normal':
        return '😐';
      case 'tired':
        return '😪';
      case 'stressed':
        return '😤';
      default:
        return '😊';
    }
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'very_happy':
        return '매우 행복';
      case 'happy':
        return '행복';
      case 'good':
        return '좋음';
      case 'normal':
        return '보통';
      case 'tired':
        return '피곤';
      case 'stressed':
        return '스트레스';
      default:
        return '보통';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'very_happy':
        return Colors.green;
      case 'happy':
        return Colors.lightGreen;
      case 'good':
        return Colors.blue;
      case 'normal':
        return Colors.grey;
      case 'tired':
        return Colors.orange;
      case 'stressed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.strength:
        return Colors.green;
      case InsightType.weakness:
        return Colors.orange;
      case InsightType.opportunity:
        return Colors.blue;
      case InsightType.trend:
        return Colors.purple;
      case InsightType.achievement:
        return Colors.amber;
    }
  }

  String _getInsightTypeLabel(InsightType type) {
    switch (type) {
      case InsightType.strength:
        return '강점';
      case InsightType.weakness:
        return '약점';
      case InsightType.opportunity:
        return '기회';
      case InsightType.trend:
        return '트렌드';
      case InsightType.achievement:
        return '성취';
    }
  }

  Color _getRecommendationColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.goal:
        return Colors.blue;
      case RecommendationType.activity:
        return Colors.green;
      case RecommendationType.improvement:
        return Colors.orange;
      case RecommendationType.challenge:
        return Colors.red;
      case RecommendationType.balance:
        return Colors.purple;
    }
  }

  void _handleRecommendationAction(Recommendation recommendation) {
    // 추천사항에 따른 액션 처리
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recommendation.title} 실행'),
        backgroundColor: _getRecommendationColor(recommendation.type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// 탭바 델리게이트
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabBarDelegate(this.tabController);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: '개요'),
          Tab(text: '패턴'),
          Tab(text: '인사이트'),
          Tab(text: '추천'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

/// 패턴 페인터
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 10; i++) {
      canvas.drawCircle(
        const Offset(0, 0),
        20.0 + (i * 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
