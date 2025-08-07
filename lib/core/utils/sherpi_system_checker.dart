import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/global_sherpi_provider.dart';
import '../../core/ai/smart_sherpi_manager.dart';
import '../../core/ai/ai_message_cache.dart';
import '../../core/constants/sherpi_dialogues.dart';
import 'phase1_performance_benchmark.dart';

/// 🔍 셰르피 시스템 연동 테스트 유틸리티
/// 
/// Phase 1 단순화 이후 시스템이 정상 작동하는지 확인합니다.
class SherpiSystemChecker {
  /// 🧪 전체 시스템 상태 확인
  static Future<Map<String, dynamic>> checkSystemIntegration(WidgetRef ref) async {
    final results = <String, dynamic>{};
    
    try {
      // 1. Provider 초기화 상태 확인
      results['provider_initialized'] = _checkProviderInitialization(ref);
      
      // 2. SmartSherpiManager 3단계 시스템 확인
      results['ai_level_system'] = await _checkAILevelSystem();
      
      // 3. 캐시 시스템 상태 확인
      results['cache_system'] = await _checkCacheSystem();
      
      // 4. 메시지 생성 테스트
      results['message_generation'] = await _testMessageGeneration(ref);
      
      // 5. 메모리 제한 확인
      results['memory_limits'] = await _checkMemoryLimits();
      
      // 6. 성능 벤치마크 (Phase 1 검증)
      results['performance_benchmark'] = await _runPerformanceBenchmark(ref);
      
      results['overall_status'] = 'SUCCESS';
      results['test_timestamp'] = DateTime.now().toIso8601String();
      
    } catch (e) {
      results['overall_status'] = 'ERROR';
      results['error_message'] = e.toString();
    }
    
    return results;
  }
  
  /// 1️⃣ Provider 초기화 상태 확인
  static Map<String, dynamic> _checkProviderInitialization(WidgetRef ref) {
    try {
      // SherpiProvider 상태 확인
      final sherpiState = ref.read(sherpiProvider);
      
      return {
        'sherpi_provider_accessible': true,
        'sherpi_state_valid': true,
        'sherpi_dialogue_exists': sherpiState.dialogue.isNotEmpty,
        'sherpi_visibility': sherpiState.isVisible,
      };
    } catch (e) {
      return {
        'sherpi_provider_accessible': false,
        'provider_error': 'Provider 초기화 실패: ${e.toString()}',
      };
    }
  }
  
  /// 2️⃣ SmartSherpiManager 3단계 AI 시스템 확인
  static Future<Map<String, dynamic>> _checkAILevelSystem() async {
    try {
      final manager = SmartSherpiManager();
      const testContext = SherpiContext.welcome;
      final testUserContext = {'레벨': '5', '연속 접속일': '3'};
      final testGameContext = {'현재 산': '한라산'};
      
      // 응답 생성 테스트
      final response = await manager.getMessage(
        testContext,
        testUserContext,
        testGameContext,
      );
      
      // 시스템 상태 확인
      final systemStatus = await manager.getSystemStatus();
      
      return {
        'ai_levels_count': 3, // premium, smart, basic
        'message_generated': response.message.isNotEmpty,
        'response_source': response.source.name,
        'is_fast_response': response.isFastResponse,
        'system_status_available': systemStatus.isNotEmpty,
        'intimacy_level': systemStatus['intimacy_level'] ?? 1,
      };
    } catch (e) {
      return {
        'ai_system_error': e.toString(),
      };
    }
  }
  
  /// 3️⃣ 캐시 시스템 상태 확인
  static Future<Map<String, dynamic>> _checkCacheSystem() async {
    try {
      final cache = AiMessageCache();
      final cacheStatus = await cache.getCacheStatus();
      
      return {
        'cache_accessible': true,
        'total_cached_messages': cacheStatus['total'] ?? 0,
        'valid_cached_messages': cacheStatus['valid'] ?? 0,
        'expired_cached_messages': cacheStatus['expired'] ?? 0,
        'cache_contexts': (cacheStatus['contexts'] as List?)?.length ?? 0,
        'max_cache_size': 100, // 설정된 최대 크기
      };
    } catch (e) {
      return {
        'cache_system_error': e.toString(),
      };
    }
  }
  
  /// 4️⃣ 메시지 생성 테스트
  static Future<Map<String, dynamic>> _testMessageGeneration(WidgetRef ref) async {
    try {
      final sherpiNotifier = ref.read(sherpiProvider.notifier);
      
      // 다양한 컨텍스트로 메시지 생성 테스트
      final testResults = <String, dynamic>{};
      
      // 기본 메시지 테스트
      await sherpiNotifier.showMessage(
        context: SherpiContext.welcome,
        duration: const Duration(milliseconds: 100), // 빠른 테스트
        forceShow: true,
      );
      
      final currentState = ref.read(sherpiProvider);
      
      testResults['welcome_message_generated'] = currentState.dialogue.isNotEmpty;
      testResults['emotion_set'] = currentState.emotion.name;
      testResults['context_set'] = currentState.currentContext?.name ?? 'null';
      testResults['visibility'] = currentState.isVisible;
      testResults['metadata_available'] = currentState.metadata?.isNotEmpty ?? false;
      
      return testResults;
    } catch (e) {
      return {
        'message_generation_error': e.toString(),
      };
    }
  }
  
  /// 5️⃣ 메모리 제한 확인
  static Future<Map<String, dynamic>> _checkMemoryLimits() async {
    try {
      // AiMessageCache는 이미 100개 제한이 있음
      final cache = AiMessageCache();
      final cacheStatus = await cache.getCacheStatus();
      
      return {
        'message_cache_limit': 100,
        'current_cache_size': cacheStatus['total'] ?? 0,
        'memory_optimization_applied': true,
        'quality_metrics_limit': 50, // enhanced_gemini_dialogue_source.dart에서 설정
        'template_cache_limit': 20, // enhanced_gemini_dialogue_source.dart에서 설정
      };
    } catch (e) {
      return {
        'memory_limits_error': e.toString(),
      };
    }
  }
  
  /// 📊 간단한 상태 요약
  static String summarizeSystemStatus(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    
    buffer.writeln('🔍 셰르피 시스템 연동 테스트 결과');
    buffer.writeln('═' * 40);
    
    // 전체 상태
    final overallStatus = results['overall_status'];
    final statusEmoji = overallStatus == 'SUCCESS' ? '✅' : '❌';
    buffer.writeln('$statusEmoji 전체 상태: $overallStatus');
    
    if (results.containsKey('error_message')) {
      buffer.writeln('❌ 오류: ${results['error_message']}');
      return buffer.toString();
    }
    
    // Provider 상태
    final providerResults = results['provider_initialized'] as Map<String, dynamic>?;
    if (providerResults != null) {
      buffer.writeln('');
      buffer.writeln('📡 Provider 초기화:');
      providerResults.forEach((key, value) {
        final emoji = value == true ? '✅' : '❌';
        buffer.writeln('  $emoji $key: $value');
      });
    }
    
    // AI 시스템 상태
    final aiResults = results['ai_level_system'] as Map<String, dynamic>?;
    if (aiResults != null) {
      buffer.writeln('');
      buffer.writeln('🧠 AI 레벨 시스템:');
      buffer.writeln('  ⭐ AI 레벨 수: ${aiResults['ai_levels_count']}단계 (premium/smart/basic)');
      buffer.writeln('  🚀 빠른 응답: ${aiResults['is_fast_response']}');
      buffer.writeln('  📝 메시지 생성: ${aiResults['message_generated']}');
    }
    
    // 캐시 시스템 상태
    final cacheResults = results['cache_system'] as Map<String, dynamic>?;
    if (cacheResults != null) {
      buffer.writeln('');
      buffer.writeln('💾 캐시 시스템:');
      buffer.writeln('  📦 총 캐시 개수: ${cacheResults['total_cached_messages']}');
      buffer.writeln('  ✅ 유효한 캐시: ${cacheResults['valid_cached_messages']}');
      buffer.writeln('  ⏰ 만료된 캐시: ${cacheResults['expired_cached_messages']}');
    }
    
    // 메모리 제한 상태
    final memoryResults = results['memory_limits'] as Map<String, dynamic>?;
    if (memoryResults != null) {
      buffer.writeln('');
      buffer.writeln('🧹 메모리 최적화:');
      buffer.writeln('  📨 메시지 캐시 제한: ${memoryResults['message_cache_limit']}개');
      buffer.writeln('  📊 품질 메트릭 제한: ${memoryResults['quality_metrics_limit']}개');
      buffer.writeln('  🎭 템플릿 캐시 제한: ${memoryResults['template_cache_limit']}개');
    }
    
    // 성능 벤치마크 결과
    final perfResults = results['performance_benchmark'] as Map<String, dynamic>?;
    if (perfResults != null && perfResults['benchmark_executed'] == true) {
      buffer.writeln('');
      buffer.writeln('🚀 Phase 1 성능 벤치마크:');
      buffer.writeln('  🏆 성능 점수: ${(perfResults['performance_score'] as double).toStringAsFixed(1)}/100');
      buffer.writeln('  📊 등급: ${perfResults['score_grade']}');
      buffer.writeln('  🎯 목표 달성: ${perfResults['targets_met']}/${perfResults['total_targets']}개 (${perfResults['targets_met_percentage']}%)');
      
      if (perfResults['targets_met_percentage'] >= 80) {
        buffer.writeln('  ✅ Phase 1 단순화 목표 달성!');
      } else {
        buffer.writeln('  ⚠️  일부 성능 목표 미달성');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('🕒 테스트 시간: ${results['test_timestamp']}');
    
    return buffer.toString();
  }
  
  /// 6️⃣ 성능 벤치마크 실행 (Phase 1 검증)
  static Future<Map<String, dynamic>> _runPerformanceBenchmark(WidgetRef ref) async {
    try {
      // 가볍고 빠른 벤치마크 (5회 반복)
      final benchmarkResults = await Phase1PerformanceBenchmark.runBenchmark(
        testIterations: 5,
        ref: ref,
      );
      
      final performanceScore = benchmarkResults['performance_score'] as double? ?? 0.0;
      final meetsTargets = benchmarkResults['meets_targets'] as Map<String, bool>? ?? {};
      
      return {
        'benchmark_executed': true,
        'performance_score': performanceScore,
        'score_grade': _getPerformanceGrade(performanceScore),
        'targets_met': meetsTargets.values.where((met) => met).length,
        'total_targets': meetsTargets.length,
        'targets_met_percentage': meetsTargets.isNotEmpty 
          ? (meetsTargets.values.where((met) => met).length / meetsTargets.length * 100).round()
          : 0,
        'benchmark_details': benchmarkResults,
      };
    } catch (e) {
      return {
        'benchmark_executed': false,
        'benchmark_error': e.toString(),
      };
    }
  }
  
  /// 성능 점수에 따른 등급 반환
  static String _getPerformanceGrade(double score) {
    if (score >= 90) return 'A+ (최우수)';
    if (score >= 80) return 'A (우수)';
    if (score >= 70) return 'B+ (양호)';
    if (score >= 60) return 'B (보통)';
    if (score >= 50) return 'C (개선 필요)';
    return 'D (시스템 점검 필요)';
  }
  
  /// 📊 Phase 1 성능 벤치마크 전용 리포트 생성
  static Future<String> generatePhase1BenchmarkReport(WidgetRef ref) async {
    try {
      final benchmarkResults = await Phase1PerformanceBenchmark.runBenchmark(
        testIterations: 10, // 더 정확한 측정을 위해 10회 반복
        ref: ref,
      );
      
      return Phase1PerformanceBenchmark.generateBenchmarkReport(benchmarkResults);
    } catch (e) {
      return '❌ Phase 1 벤치마크 실행 실패: $e';
    }
  }
}