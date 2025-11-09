import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_analysis_model.freezed.dart';
part 'achievement_analysis_model.g.dart';

/// AI 목표 분석 모델
///
/// 목표와 루틴에 대한 AI 분석 결과를 관리합니다.
@freezed
class AchievementAnalysisModel with _$AchievementAnalysisModel {
  const factory AchievementAnalysisModel({
    /// 분석 ID
    required String id,

    /// 분석 카테고리 (목표 카테고리와 동일)
    required String category,

    /// 분석 내용 (AI 생성 텍스트 또는 데모 placeholder)
    required String analysisContent,

    /// 포인트 비용
    @Default(30) int pointsCost,

    /// 분석 일시
    required DateTime analyzedAt,

    /// 관련 목표 ID 리스트
    @Default([]) List<String> relatedGoalIds,

    /// 관련 루틴 ID 리스트
    @Default([]) List<String> relatedRoutineIds,
  }) = _AchievementAnalysisModel;

  factory AchievementAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementAnalysisModelFromJson(json);
}

/// 데모 분석 결과 생성 헬퍼
class AchievementAnalysisHelper {
  /// 데모 분석 결과 생성
  static AchievementAnalysisModel createDemoAnalysis({
    required String category,
    required List<String> goalIds,
    required List<String> routineIds,
  }) {
    return AchievementAnalysisModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      analysisContent: _getDemoContent(category),
      pointsCost: 30,
      analyzedAt: DateTime.now(),
      relatedGoalIds: goalIds,
      relatedRoutineIds: routineIds,
    );
  }

  /// 카테고리별 데모 분석 내용
  static String _getDemoContent(String category) {
    switch (category) {
      case '운동':
        return '''
📊 운동 목표 분석 결과

**강점**
✅ 꾸준한 러닝 루틴으로 기초 체력 우수
✅ 마라톤 경험으로 장거리 페이스 관리 능력 보유

**개선 필요**
⚠️ 대회 2주 전 훈련량 부족 (권장: 주 3-4회)
⚠️ 오르막 코스 대비 훈련 필요

**추천 전략**
1. 주 3회 이상 러닝 루틴 유지
2. 대회 1주 전 코스 사전 답사
3. 컨디션 관리: 충분한 수면 (7시간 이상)

💡 AI 연결은 추후 구현됩니다.
현재는 데모 버전입니다.
''';

      case '대회':
        return '''
📊 대회 목표 분석 결과

**성공 패턴**
✅ 과제보고서 작성에 신경 쓸 때 좋은 결과
✅ AI 가점 항목 활용 전략 효과적
✅ 컨설팅 활용 시 성공률 높음

**실패 패턴**
❌ GPT 자동 생성 서류는 낮은 평가
❌ 질문 대비 부족 시 불합격 가능성
❌ 발표 준비 소홀 시 위험

**추천 전략**
1. 서류: 직접 작성 + 컨설팅 피드백
2. 발표: 예상 질문 리스트 작성 및 연습
3. 차별화: AI 활용 방안 구체적으로 제시

💡 AI 연결은 추후 구현됩니다.
현재는 데모 버전입니다.
''';

      case '학습':
        return '''
📊 학습 목표 분석 결과

**학습 패턴**
✅ 매일 30분 꾸준한 학습 루틴 우수
✅ 앱 개발 실습 중심 학습 효과적

**개선 필요**
⚠️ 주말 학습 시간 부족
⚠️ 복습 루틴 추가 필요

**추천 전략**
1. 매일 학습 루틴 유지
2. 주말 2시간 심화 학습 추가
3. 주 1회 복습 세션 설정

💡 AI 연결은 추후 구현됩니다.
현재는 데모 버전입니다.
''';

      case '자격증':
        return '''
📊 자격증 목표 분석 결과

**준비 상황**
✅ 학습 루틴 설정 완료
⚠️ 모의고사 일정 추가 권장

**추천 전략**
1. 주 3회 이상 학습 루틴
2. 월 2회 모의고사 응시
3. 약점 과목 집중 학습

💡 AI 연결은 추후 구현됩니다.
현재는 데모 버전입니다.
''';

      default:
        return '''
📊 목표 분석 결과

**분석 중...**

현재 설정된 목표와 루틴을 기반으로
AI가 분석을 진행합니다.

💡 AI 연결은 추후 구현됩니다.
현재는 데모 버전입니다.
''';
    }
  }
}
