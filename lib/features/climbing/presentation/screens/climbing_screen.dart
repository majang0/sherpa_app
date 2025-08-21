import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/climbing_power_analysis_widget.dart';
import '../widgets/user_stats_summary_widget.dart';
import '../widgets/today_growth_widget.dart';
import '../widgets/badge_management_widget.dart';
import '../widgets/animated_rpg_level_card.dart';
import '../widgets/ascent_dashboard_widget.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';

/// 클라이밍(레벨업) 화면 - RPG 스탯과 성장 분석
class ClimbingScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ClimbingScreen> createState() => _ClimbingScreenState();
}

class _ClimbingScreenState extends ConsumerState<ClimbingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SherpaCleanAppBar(
        title: '내 성장 분석',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 유저 RPG 레벨 카드 (맨 위)
            AnimatedRPGLevelCard(),
            const SizedBox(height: 16),
            
            // 사용자 스탯 요약
            UserStatsSummaryWidget(),
            const SizedBox(height: 16),
            
            // 등반하기 대시보드 (스탯과 파워 분석 사이)
            AscentDashboardWidget(),
            const SizedBox(height: 16),
            
            // 오늘의 성장
            TodayGrowthWidget(),
            const SizedBox(height: 16),
            
            // 클라이밍 파워 분석
            ClimbingPowerAnalysisWidget(),
            const SizedBox(height: 16),
            
            // 배지 관리
            BadgeManagementWidget(),
          ],
        ),
      ),
    );
  }
}