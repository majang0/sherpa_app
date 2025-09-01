import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../core/ai/activity_analysis_service.dart';
import '../../../../core/utils/exercise_calculator.dart';

/// 운동 분석 페이지 - 의학적 근거 기반 효과 표시
class ExerciseAnalysisPageMedical extends StatefulWidget {
  final Map<String, dynamic>? todayData;
  final Map<String, dynamic>? previousData;
  final String userName;
  
  const ExerciseAnalysisPageMedical({
    super.key,
    this.todayData,
    this.previousData,
    required this.userName,
  });
  
  @override
  State<ExerciseAnalysisPageMedical> createState() => _ExerciseAnalysisPageMedicalState();
}

class _ExerciseAnalysisPageMedicalState extends State<ExerciseAnalysisPageMedical> 
    with TickerProviderStateMixin {
  
  // AI 분석 데이터
  final ActivityAnalysisService _analysisService = ActivityAnalysisService.instance;
  ComprehensiveExerciseAnalysis? _analysisData;
  bool _isLoading = true;
  
  // 주황색 테마 색상
  static const Color exerciseOrange = Color(0xFFFF6B35);
  static const Color exerciseOrangeLight = Color(0xFFFFF3E0);
  static const Color exerciseOrangeMedium = Color(0xFFFFB74D);
  
  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }
  
  Future<void> _loadAnalysis() async {
    if (widget.todayData == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      final analysis = await _analysisService.analyzeExerciseComprehensive(
        todayExercise: widget.todayData!,
        previousExercise: widget.previousData,
        userName: widget.userName,
      );
      
      if (mounted) {
        setState(() {
          _analysisData = analysis;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.todayData == null) {
      return _buildEmptyState();
    }
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildMedicalBenefitsSection(),
          const SizedBox(height: 20),
          _buildAIAnalysisSection(),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        '오늘의 운동 기록이 없어요',
        style: GoogleFonts.notoSans(
          fontSize: 16,
          color: ModernColors.textSecondary,
        ),
      ),
    );
  }
  
  /// 의학적 근거 기반 효과 섹션
  Widget _buildMedicalBenefitsSection() {
    final exerciseType = widget.todayData?['type'] ?? '운동';
    final duration = widget.todayData?['duration'] ?? 0;
    final intensity = widget.todayData?['intensity'] ?? '보통';
    final exerciseTime = widget.todayData?['date'] ?? DateTime.now();
    
    // 실제 칼로리 계산 (의학적 근거 기반)
    final calories = widget.todayData?['calories'] ?? 
        ExerciseCalculator.calculateCalories(
          exerciseType: ExerciseTypeMapper.toKorean(exerciseType),
          durationMinutes: duration,
          intensity: intensity,
          weightKg: 65.0, // 사용자 체중 데이터가 있다면 사용
        );
    
    // 각 효과별 의학적 데이터 계산
    final heartRateData = ExerciseCalculator.calculateHeartRateEffect(
      durationMinutes: duration,
      intensity: intensity,
    );
    
    final bloodPressureData = ExerciseCalculator.getBloodPressureEffect(
      durationMinutes: duration,
      intensity: intensity,
    );
    
    final endorphinData = ExerciseCalculator.getEndorphinEffect(
      durationMinutes: duration,
      intensity: intensity,
    );
    
    final brainData = ExerciseCalculator.getBrainEffect(
      durationMinutes: duration,
      exerciseType: ExerciseTypeMapper.toKorean(exerciseType),
      intensity: intensity,
    );
    
    final metabolicData = ExerciseCalculator.getMetabolicEffect(
      calories: calories,
      intensity: intensity,
      durationMinutes: duration,
    );
    
    final muscleData = ExerciseCalculator.getMuscleGrowthEffect(
      exerciseType: ExerciseTypeMapper.toKorean(exerciseType),
      durationMinutes: duration,
      intensity: intensity,
    );
    
    final immuneData = ExerciseCalculator.getImmuneEffect(
      durationMinutes: duration,
      intensity: intensity,
    );
    
    final sleepData = ExerciseCalculator.getSleepEffect(
      durationMinutes: duration,
      intensity: intensity,
      exerciseTime: exerciseTime is DateTime ? exerciseTime : DateTime.now(),
    );
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            exerciseOrangeLight,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: exerciseOrange.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [exerciseOrange, exerciseOrangeMedium],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.science_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎯 의학적으로 증명된 효과',
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ACSM 가이드라인 기반 실제 데이터',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 메인 수치 카드
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 칼로리 & 대사
                  _buildMainMetric(
                    icon: '🔥',
                    title: '에너지 소모',
                    mainValue: '${metabolicData['totalCalories']}kcal',
                    subtitle: '즉시 ${metabolicData['immediateCalories']}kcal + EPOC ${metabolicData['epocCalories']}kcal',
                    detail: '${metabolicData['epocDuration']}시간 동안 추가 칼로리 소모',
                    color: exerciseOrange,
                  ),
                  
                  const Divider(height: 24),
                  
                  // 심박수 효과
                  _buildMainMetric(
                    icon: '💓',
                    title: '심혈관 강화',
                    mainValue: '+${heartRateData['increase']}bpm',
                    subtitle: '목표 심박수 ${heartRateData['targetHR']}회/분 도달',
                    detail: '혈압 ${bloodPressureData['systolic']}/${bloodPressureData['diastolic']}mmHg 감소',
                    color: Colors.red,
                  ),
                  
                  const Divider(height: 24),
                  
                  // 뇌 기능
                  _buildMainMetric(
                    icon: '🧠',
                    title: '두뇌 활성화',
                    mainValue: 'BDNF +${brainData['bdnfIncrease']}%',
                    subtitle: brainData['cognitiveEffect'].toString(),
                    detail: '집중력 ${brainData['focusDuration']} 지속',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          
          // 세부 효과 카드들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // 엔돌핀 효과
                _buildDetailCard(
                  icon: '😊',
                  title: '행복 호르몬',
                  data: endorphinData,
                  primaryInfo: '엔돌핀 레벨 ${endorphinData['level']}%',
                  secondaryInfo: endorphinData['moodEffect'].toString(),
                  additionalInfo: '효과 ${endorphinData['duration']} 지속',
                  progress: (endorphinData['level'] as int) / 100.0,
                  color: Colors.amber,
                ),
                
                const SizedBox(height: 12),
                
                // 근육 성장
                _buildDetailCard(
                  icon: '💪',
                  title: '근육 발달',
                  data: muscleData,
                  primaryInfo: '근육 성장률 ${muscleData['growthRate']}',
                  secondaryInfo: '단백질 합성 +${muscleData['proteinSynthesis']}',
                  additionalInfo: '${muscleData['muscleGroup']} 강화',
                  progress: 0.7,
                  color: Colors.blue,
                ),
                
                const SizedBox(height: 12),
                
                // 면역력
                _buildDetailCard(
                  icon: '🛡️',
                  title: '면역 체계',
                  data: immuneData,
                  primaryInfo: immuneData['effect'].toString(),
                  secondaryInfo: '면역력 ${immuneData['boost'] > 0 ? '+' : ''}${immuneData['boost']}%',
                  additionalInfo: immuneData['recommendation'].toString(),
                  progress: math.max(0, (immuneData['boost'] as int) / 30.0),
                  color: Colors.green,
                ),
                
                const SizedBox(height: 12),
                
                // 수면 질
                _buildDetailCard(
                  icon: '😴',
                  title: '수면 개선',
                  data: sleepData,
                  primaryInfo: sleepData['effect'].toString(),
                  secondaryInfo: '수면 질 ${sleepData['qualityImprovement']}',
                  additionalInfo: sleepData['recommendation'].toString(),
                  progress: 0.8,
                  color: Colors.indigo,
                ),
              ],
            ),
          ),
          
          // 과학적 팩트
          _buildScientificFact(duration, calories, intensity, exerciseType),
          
          const SizedBox(height: 16),
        ],
      ),
    ).animate()
      .slideY(begin: 0.1, end: 0, duration: 600.ms)
      .fadeIn(duration: 600.ms);
  }
  
  /// 메인 지표 위젯
  Widget _buildMainMetric({
    required String icon,
    required String title,
    required String mainValue,
    required String subtitle,
    required String detail,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textSecondary,
                ),
              ),
              Text(
                mainValue,
                style: GoogleFonts.notoSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ModernColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              if (detail.isNotEmpty)
                Text(
                  detail,
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: ModernColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 세부 효과 카드
  Widget _buildDetailCard({
    required String icon,
    required String title,
    required Map<String, dynamic> data,
    required String primaryInfo,
    required String secondaryInfo,
    required String additionalInfo,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    Text(
                      primaryInfo,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  secondaryInfo,
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  additionalInfo,
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: ModernColors.textTertiary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms)
      .fadeIn(duration: 400.ms);
  }
  
  /// 과학적 팩트 카드
  Widget _buildScientificFact(int duration, int calories, String intensity, String exerciseType) {
    final facts = [
      '30분 중강도 운동은 심혈관 질환 위험을 20% 감소시킵니다 (WHO 2020)',
      '주 150분 운동은 우울증 위험을 30% 낮춥니다 (Lancet Psychiatry 2018)',
      '규칙적인 운동은 뇌 부피를 2% 증가시킵니다 (Journal of Alzheimer\'s Disease)',
      '운동 후 72시간 동안 인슐린 민감도가 향상됩니다 (Diabetes Care 2013)',
      'HIIT 운동은 미토콘드리아 기능을 49% 향상시킵니다 (Cell Metabolism 2017)',
    ];
    
    final randomFact = facts[DateTime.now().minute % facts.length];
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            exerciseOrange.withOpacity(0.1),
            exerciseOrangeMedium.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: exerciseOrange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: exerciseOrange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: exerciseOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알고 계셨나요?',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: exerciseOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  randomFact,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textPrimary,
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
  
  /// AI 분석 섹션 (기존 분석 결과 표시)
  Widget _buildAIAnalysisSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_analysisData == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/sherpi/sherpi_cheering.png',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              Text(
                '셰르피의 분석',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 비교 분석
          if (_analysisData!.comparison.isNotEmpty) ...[
            _buildAnalysisItem(
              icon: '📊',
              title: '이전 운동과 비교',
              content: _analysisData!.comparison,
            ),
            const SizedBox(height: 12),
          ],
          
          // 추천
          if (_analysisData!.recommendation.isNotEmpty) ...[
            _buildAnalysisItem(
              icon: '💡',
              title: '다음 운동 팁',
              content: _analysisData!.recommendation,
            ),
            const SizedBox(height: 12),
          ],
          
          // 응원
          if (_analysisData!.encouragement.isNotEmpty)
            _buildAnalysisItem(
              icon: '🎉',
              title: '응원 메시지',
              content: _analysisData!.encouragement,
            ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisItem({
    required String icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textPrimary,
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
}