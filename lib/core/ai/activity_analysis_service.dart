import 'dart:async';
import 'package:sherpa_app/core/ai/openai_dialogue_source.dart';
import 'package:sherpa_app/core/ai/analysis_prompt_templates.dart';
import 'package:sherpa_app/core/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';

/// 🎯 활동 분석 서비스
/// 
/// 사용자의 운동, 독서, 일기 활동을 분석하고
/// ChatGPT API를 통해 개인화된 피드백을 생성합니다.
class ActivityAnalysisService {
  late final OpenAIClient _client;
  static ActivityAnalysisService? _instance;
  
  // 싱글톤 패턴
  static ActivityAnalysisService get instance {
    _instance ??= ActivityAnalysisService._();
    return _instance!;
  }
  
  ActivityAnalysisService._() {
    _initializeClient();
  }
  
  /// OpenAI 클라이언트 초기화
  void _initializeClient() {
    try {
      final apiKey = ApiConfig.openAIApiKey;
      
      _client = OpenAIClient(
        apiKey: apiKey,
        baseUrl: 'https://api.openai.com/v1',
      );
      
      print('🎯 Activity Analysis Service 초기화 성공');
    } catch (e) {
      print('❌ Activity Analysis Service 초기화 실패: $e');
      rethrow;
    }
  }
  
  /// 🏃 운동 분석
  Future<String> analyzeExercise({
    required Map<String, dynamic> todayExercise,
    Map<String, dynamic>? previousExercise,
    required String userName,
  }) async {
    try {
      final prompt = AnalysisPromptTemplates.generateExerciseAnalysisPrompt(
        todayExercise: todayExercise,
        previousExercise: previousExercise,
        userName: userName,
      );
      
      final response = await _callOpenAI(prompt);
      
      // 캐시에 저장
      await _saveToCache('exercise_analysis', response, todayExercise);
      
      return response;
    } catch (e) {
      print('❌ 운동 분석 실패: $e');
      return _getDefaultExerciseAnalysis(todayExercise, userName);
    }
  }
  
  /// 📚 독서 분석
  Future<String> analyzeReading({
    required Map<String, dynamic> todayReading,
    Map<String, dynamic>? previousReading,
    required String userName,
  }) async {
    try {
      final prompt = AnalysisPromptTemplates.generateReadingAnalysisPrompt(
        todayReading: todayReading,
        previousReading: previousReading,
        userName: userName,
      );
      
      final response = await _callOpenAI(prompt);
      
      // 캐시에 저장
      await _saveToCache('reading_analysis', response, todayReading);
      
      return response;
    } catch (e) {
      print('❌ 독서 분석 실패: $e');
      return _getDefaultReadingAnalysis(todayReading, userName);
    }
  }
  
  /// 📝 일기 분석
  Future<String> analyzeDiary({
    required Map<String, dynamic> todayDiary,
    Map<String, dynamic>? previousDiary,
    required String userName,
  }) async {
    try {
      final prompt = AnalysisPromptTemplates.generateDiaryAnalysisPrompt(
        todayDiary: todayDiary,
        previousDiary: previousDiary,
        userName: userName,
      );
      
      final response = await _callOpenAI(prompt);
      
      // 캐시에 저장
      await _saveToCache('diary_analysis', response, todayDiary);
      
      return response;
    } catch (e) {
      print('❌ 일기 분석 실패: $e');
      return _getDefaultDiaryAnalysis(todayDiary, userName);
    }
  }
  
  /// 🌟 종합 요약 분석
  Future<String> generateSummaryAnalysis({
    required Map<String, dynamic> todayExercise,
    required Map<String, dynamic> todayReading,
    required Map<String, dynamic> todayDiary,
    required String userName,
  }) async {
    try {
      final prompt = AnalysisPromptTemplates.generateSummaryAnalysisPrompt(
        todayExercise: todayExercise,
        todayReading: todayReading,
        todayDiary: todayDiary,
        userName: userName,
      );
      
      final response = await _callOpenAI(prompt);
      
      // 캐시에 저장
      await _saveToCache('summary_analysis', response, {
        'exercise': todayExercise,
        'reading': todayReading,
        'diary': todayDiary,
      });
      
      return response;
    } catch (e) {
      print('❌ 종합 분석 실패: $e');
      return _getDefaultSummaryAnalysis(todayExercise, todayReading, todayDiary, userName);
    }
  }
  
  /// OpenAI API 호출
  Future<String> _callOpenAI(String prompt) async {
    try {
      final chatCompletion = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-4-turbo'),
          messages: [
            ChatCompletionMessage.system(
              content: '''당신은 셰르피(Sherpi)입니다. 사용자의 일상 활동을 분석하고 
              따뜻한 격려와 응원을 제공하는 친근한 AI 동반자입니다.
              
              지침:
              - 항상 친근하고 다정한 말투 사용
              - 구체적인 데이터를 언급하며 개인화된 피드백 제공
              - 긍정적이고 희망적인 메시지 전달
              - 이모지를 적절히 사용하여 감정 표현
              - 4-5문장 이내로 간결하게 작성''',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(prompt),
            ),
          ],
          temperature: 0.85,
          maxTokens: 250,
          topP: 0.95,
        ),
      );
      
      final responseText = chatCompletion.choices.firstOrNull?.message.content;
      
      if (responseText != null && responseText.isNotEmpty) {
        print('✅ 활동 분석 생성 성공');
        return _processResponse(responseText);
      }
      
      throw Exception('Empty response from OpenAI');
    } catch (e) {
      print('❌ OpenAI API 호출 실패: $e');
      rethrow;
    }
  }
  
  /// 응답 후처리
  String _processResponse(String rawResponse) {
    String processed = rawResponse.trim();
    
    // 길이 제한 (250자)
    if (processed.length > 250) {
      processed = '${processed.substring(0, 247)}...';
    }
    
    return processed;
  }
  
  /// 캐시에 저장
  Future<void> _saveToCache(String key, String content, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'content': content,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final dateKey = _getTodayDateKey();
      final fullKey = 'analysis_${dateKey}_$key';
      
      await prefs.setString(fullKey, jsonEncode(cacheData));
      print('💾 분석 결과 캐시 저장: $fullKey');
    } catch (e) {
      print('❌ 캐시 저장 실패: $e');
    }
  }
  
  /// 캐시에서 읽기
  Future<String?> getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getTodayDateKey();
      final fullKey = 'analysis_${dateKey}_$key';
      
      final cached = prefs.getString(fullKey);
      if (cached != null) {
        final cacheData = jsonDecode(cached);
        print('💾 캐시에서 분석 결과 로드: $fullKey');
        return cacheData['content'] as String;
      }
    } catch (e) {
      print('❌ 캐시 읽기 실패: $e');
    }
    return null;
  }
  
  /// 오늘 날짜 키 생성
  String _getTodayDateKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
  }
  
  /// 모든 분석이 완료되었는지 확인
  Future<bool> areAllAnalysesComplete() async {
    final exerciseAnalysis = await getFromCache('exercise_analysis');
    final readingAnalysis = await getFromCache('reading_analysis');
    final diaryAnalysis = await getFromCache('diary_analysis');
    final summaryAnalysis = await getFromCache('summary_analysis');
    
    return exerciseAnalysis != null && 
           readingAnalysis != null && 
           diaryAnalysis != null &&
           summaryAnalysis != null;
  }
  
  /// 오늘의 모든 분석 결과 가져오기
  Future<TodayAnalysisData?> getTodayAnalyses() async {
    final exerciseAnalysis = await getFromCache('exercise_analysis');
    final readingAnalysis = await getFromCache('reading_analysis');
    final diaryAnalysis = await getFromCache('diary_analysis');
    final summaryAnalysis = await getFromCache('summary_analysis');
    
    if (exerciseAnalysis != null && 
        readingAnalysis != null && 
        diaryAnalysis != null &&
        summaryAnalysis != null) {
      return TodayAnalysisData(
        exerciseAnalysis: exerciseAnalysis,
        readingAnalysis: readingAnalysis,
        diaryAnalysis: diaryAnalysis,
        summaryAnalysis: summaryAnalysis,
        createdAt: DateTime.now(),
      );
    }
    
    return null;
  }
  
  // 기본 분석 메시지 (API 실패 시 사용)
  String _getDefaultExerciseAnalysis(Map<String, dynamic> data, String userName) {
    final type = data['type'] ?? '운동';
    final duration = data['duration'] ?? 0;
    final calories = data['calories'] ?? 0;
    
    return '''오늘 $type을(를) ${duration}분 동안 하셨네요! 
${calories}kcal를 소모하셨어요! 💪
꾸준한 운동이 $userName님을 더 건강하게 만들고 있어요.
오늘도 수고 많으셨어요!''';
  }
  
  String _getDefaultReadingAnalysis(Map<String, dynamic> data, String userName) {
    final title = data['title'] ?? '책';
    final pages = data['pages'] ?? 0;
    final category = data['category'] ?? '독서';
    
    return '''『$title』을(를) ${pages}페이지 읽으셨군요! 📚
$category 분야의 지식을 쌓는 유익한 시간이 되셨길 바라요.
$userName님의 꾸준한 독서 습관이 정말 멋져요!''';
  }
  
  String _getDefaultDiaryAnalysis(Map<String, dynamic> data, String userName) {
    final mood = data['mood'] ?? '평온한';
    
    return '''오늘 $userName님의 기분이 $mood 상태시군요! 
하루를 기록하는 습관이 $userName님의 성장에 큰 도움이 될 거예요.
셰르피가 늘 곁에서 응원할게요! 💝''';
  }
  
  String _getDefaultSummaryAnalysis(
    Map<String, dynamic> exercise,
    Map<String, dynamic> reading,
    Map<String, dynamic> diary,
    String userName,
  ) {
    final exerciseType = exercise['type'] ?? '운동';
    final readingCategory = reading['category'] ?? '독서';
    final mood = diary['mood'] ?? '평온한';
    
    return '''오늘 $exerciseType, $readingCategory 독서, 그리고 $mood 감정을 기록하셨네요! 🌟

몸과 마음, 지성을 모두 돌보는 $userName님의 균형잡힌 하루가 정말 인상적이에요.
이런 꾸준한 노력이 모여 더 나은 내일을 만들어갈 거예요.
$userName님과 함께하는 매일이 셰르피에게도 큰 기쁨이에요. 
오늘도 정말 수고 많으셨어요! 💪📚💝''';
  }
}

/// 오늘의 분석 데이터 모델
class TodayAnalysisData {
  final String exerciseAnalysis;
  final String readingAnalysis;
  final String diaryAnalysis;
  final String summaryAnalysis;
  final DateTime createdAt;
  
  TodayAnalysisData({
    required this.exerciseAnalysis,
    required this.readingAnalysis,
    required this.diaryAnalysis,
    required this.summaryAnalysis,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'exerciseAnalysis': exerciseAnalysis,
    'readingAnalysis': readingAnalysis,
    'diaryAnalysis': diaryAnalysis,
    'summaryAnalysis': summaryAnalysis,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory TodayAnalysisData.fromJson(Map<String, dynamic> json) {
    return TodayAnalysisData(
      exerciseAnalysis: json['exerciseAnalysis'] as String,
      readingAnalysis: json['readingAnalysis'] as String,
      diaryAnalysis: json['diaryAnalysis'] as String,
      summaryAnalysis: json['summaryAnalysis'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}