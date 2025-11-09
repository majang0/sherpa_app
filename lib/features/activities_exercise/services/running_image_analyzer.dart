// lib/features/activities_exercise/services/running_image_analyzer.dart

import 'dart:convert';
import 'dart:io';
import 'package:sherpa_app/core/ai/services/openai_service.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';

/// 🏃 러닝 이미지 분석 결과 모델
class RunningData {
  final double distanceKm;
  final int paceMinutes;
  final int paceSeconds;
  final int totalHours;
  final int totalMinutes;
  final int totalSeconds;

  const RunningData({
    required this.distanceKm,
    required this.paceMinutes,
    required this.paceSeconds,
    required this.totalHours,
    required this.totalMinutes,
    required this.totalSeconds,
  });

  /// 총 시간을 분으로 변환
  int get totalDurationMinutes => (totalHours * 60) + totalMinutes;

  /// 페이스를 double로 변환 (분/km)
  double get averagePace => paceMinutes + (paceSeconds / 60.0);

  /// 시간 포맷팅
  String get formattedTime {
    if (totalHours > 0) {
      return '$totalHours시간 $totalMinutes분 $totalSeconds초';
    } else {
      return '$totalMinutes분 $totalSeconds초';
    }
  }

  /// 페이스 포맷팅
  String get formattedPace => "$paceMinutes'$paceSeconds\"";

  factory RunningData.fromJson(Map<String, dynamic> json) {
    return RunningData(
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      paceMinutes: (json['pace_min'] ?? 0).toInt(),
      paceSeconds: (json['pace_sec'] ?? 0).toInt(),
      totalHours: (json['total_hours'] ?? 0).toInt(),
      totalMinutes: (json['total_minutes'] ?? 0).toInt(),
      totalSeconds: (json['total_seconds'] ?? 0).toInt(),
    );
  }

  @override
  String toString() {
    return 'RunningData(distance: ${distanceKm}km, pace: ${formattedPace}, time: $formattedTime)';
  }
}

/// 🏃 러닝 이미지 분석 서비스 (GPT-5 Vision)
///
/// 나이키런, 스트라바 등 러닝 앱 스크린샷에서 운동 데이터를 추출합니다.
class RunningImageAnalyzer {
  final OpenAIService _openAIService;

  RunningImageAnalyzer({OpenAIService? openAIService})
      : _openAIService = openAIService ?? OpenAIService.instance;

  /// 시스템 프롬프트 - AI 역할 정의
  static const String _systemPrompt = '''당신은 러닝 앱 스크린샷에서 운동 데이터를 정확하게 추출하는 전문가입니다.
나이키런(Nike Run Club), 스트라바(Strava), 가민(Garmin) 등 다양한 러닝 앱의 UI를 이해합니다.
숫자와 단위를 정확히 구분하고, JSON 형식으로 구조화된 데이터를 반환합니다.''';

  /// 사용자 프롬프트 - 분석 요청
  static const String _userPrompt = '''이 러닝 앱 스크린샷에서 다음 정보를 추출해주세요:

1. **거리 (distance_km)**: 킬로미터 단위의 숫자 (예: 21.06, 5.0, 10.5)
2. **1km당 페이스 (pace_min, pace_sec)**: 분과 초를 구분 (예: 4'54" → pace_min: 4, pace_sec: 54)
3. **총 시간 (total_hours, total_minutes, total_seconds)**: 시, 분, 초를 구분 (예: 1:43:08 → hours: 1, minutes: 43, seconds: 8)

**중요 규칙**:
- 숫자만 추출하고 단위는 제거하세요 (km, 분, 초 등)
- 페이스는 반드시 분과 초를 구분하세요 (4'54" → 4분 54초)
- 시간이 1시간 미만이면 hours: 0으로 설정하세요
- 데이터가 명확하지 않으면 null을 사용하지 말고 0을 사용하세요

**반환 형식** (JSON만 반환, 다른 텍스트 없음):
{
  "distance_km": 21.06,
  "pace_min": 4,
  "pace_sec": 54,
  "total_hours": 1,
  "total_minutes": 43,
  "total_seconds": 8
}''';

  /// 🎯 러닝 이미지 분석 실행
  ///
  /// [imageFile] - 분석할 이미지 파일
  ///
  /// Returns: RunningData 또는 null (실패 시)
  Future<RunningData?> analyzeRunningImage(File imageFile) async {
    try {
      aiLogger.i('러닝 이미지 분석 시작: ${imageFile.path}');

      // 1. 이미지를 Base64로 인코딩
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      aiLogger.i('이미지 인코딩 완료 (${imageBytes.length} bytes)');

      // 2. OpenAI Vision API 호출
      final responseText = await _openAIService.analyzeImage(
        imageBase64: base64Image,
        systemPrompt: _systemPrompt,
        userPrompt: _userPrompt,
        maxTokens: 300, // JSON 응답이므로 토큰 적게 사용
        temperature: 0.1, // 매우 낮은 temperature로 정확성 극대화
      );

      if (responseText == null || responseText.isEmpty) {
        aiLogger.w('OpenAI Vision API 응답 없음');
        return null;
      }

      aiLogger.i('AI 응답 수신: $responseText');

      // 3. JSON 파싱
      final runningData = _parseJsonResponse(responseText);

      if (runningData != null) {
        // 4. 데이터 검증
        if (_validateRunningData(runningData)) {
          aiLogger.i('러닝 데이터 분석 성공: $runningData');
          return runningData;
        } else {
          aiLogger.w('러닝 데이터 검증 실패 (비현실적인 값)');
          return null;
        }
      } else {
        aiLogger.w('JSON 파싱 실패');
        return null;
      }
    } catch (e) {
      aiLogger.e('러닝 이미지 분석 실패', error: e);
      return null;
    }
  }

  /// JSON 응답 파싱
  RunningData? _parseJsonResponse(String responseText) {
    try {
      // JSON 블록 추출 (```json ... ``` 형식 처리)
      String jsonText = responseText.trim();

      // 마크다운 코드 블록 제거
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7); // ```json 제거
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3); // ``` 제거
      }

      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3); // ``` 제거
      }

      jsonText = jsonText.trim();

      // JSON 파싱
      final jsonData = json.decode(jsonText) as Map<String, dynamic>;
      return RunningData.fromJson(jsonData);
    } catch (e) {
      aiLogger.e('JSON 파싱 오류', error: e);
      return null;
    }
  }

  /// 러닝 데이터 유효성 검증
  bool _validateRunningData(RunningData data) {
    // 거리 검증 (0.1km ~ 100km)
    if (data.distanceKm < 0.1 || data.distanceKm > 100) {
      aiLogger.w('거리 범위 초과: ${data.distanceKm}km');
      return false;
    }

    // 페이스 검증 (2'00" ~ 15'00" /km)
    final totalPaceSeconds = (data.paceMinutes * 60) + data.paceSeconds;
    if (totalPaceSeconds < 120 || totalPaceSeconds > 900) {
      // 2분 ~ 15분
      aiLogger.w('페이스 범위 초과: ${data.paceMinutes}분 ${data.paceSeconds}초');
      return false;
    }

    // 총 시간 검증 (최소 1분, 최대 10시간)
    final totalMinutes = data.totalDurationMinutes;
    if (totalMinutes < 1 || totalMinutes > 600) {
      aiLogger.w('시간 범위 초과: $totalMinutes분');
      return false;
    }

    // 일관성 체크: 거리 × 페이스 ≈ 총 시간 (±10분 오차 허용)
    final calculatedMinutes = data.distanceKm * data.averagePace;
    final diff = (calculatedMinutes - totalMinutes).abs();

    if (diff > 10) {
      aiLogger.w(
          '데이터 일관성 문제: 계산된 시간($calculatedMinutes분) vs 실제 시간($totalMinutes분), 차이: $diff분');
      // 경고만 출력하고 통과시킴 (GPS 오차 등으로 실제로 차이가 날 수 있음)
    }

    return true;
  }

  /// API 키 유효성 확인
  bool get isApiKeyValid => _openAIService.isApiKeyValid;
}
