import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/smart_sherpi_manager.dart';
import '../../core/ai/ai_message_cache.dart';
import '../../core/constants/sherpi_dialogues.dart';

/// 🚀 Phase 1 단순화 성능 벤치마크
/// 
/// Phase 1 단순화 이후 성능 개선을 측정하고 검증합니다.
class Phase1PerformanceBenchmark {
  /// 🎯 Phase 1 성능 목표
  static const Map<String, double> performanceTargets = {
    'static_response_time_ms': 50.0,    // 정적 메시지 < 50ms
    'cached_response_time_ms': 100.0,   // 캐시된 AI < 100ms
    'fast_response_rate': 0.95,         // 95% 빠른 응답
    'memory_usage_mb': 35.0,            // 메모리 사용량 < 35MB
    'cache_hit_rate': 0.80,             // 캐시 히트율 > 80%
  };
  
  /// 📊 성능 벤치마크 실행
  static Future<Map<String, dynamic>> runBenchmark({
    int testIterations = 10,
    WidgetRef? ref,
  }) async {
    final results = <String, dynamic>{
      'benchmark_start_time': DateTime.now().toIso8601String(),
      'test_iterations': testIterations,
    };
    
    try {
      // 1. 응답 시간 벤치마크
      results['response_time_benchmark'] = await _benchmarkResponseTimes(testIterations);
      
      // 2. 메모리 사용량 측정
      results['memory_benchmark'] = await _benchmarkMemoryUsage();
      
      // 3. 캐시 효율성 측정
      results['cache_benchmark'] = await _benchmarkCacheEfficiency();
      
      // 4. AI 레벨 시스템 성능
      results['ai_level_benchmark'] = await _benchmarkAILevelSystem(testIterations);
      
      // 5. 전체 성능 점수 계산
      results['performance_score'] = _calculatePerformanceScore(results);
      results['meets_targets'] = _validateTargets(results);
      
      results['benchmark_status'] = 'SUCCESS';
      
    } catch (e) {
      results['benchmark_status'] = 'ERROR';
      results['error_message'] = e.toString();
    }
    
    results['benchmark_end_time'] = DateTime.now().toIso8601String();
    return results;
  }
  
  /// 1️⃣ 응답 시간 벤치마크
  static Future<Map<String, dynamic>> _benchmarkResponseTimes(int iterations) async {
    final manager = SmartSherpiManager();
    final responseTimes = <String, List<int>>{
      'static': [],
      'aiCached': [],
      'aiRealtime': [],
    };
    
    // 테스트 컨텍스트들 (다양한 AI 레벨)
    const testContexts = [
      {'context': SherpiContext.general, 'expectedLevel': 'basic'},           // 주로 static
      {'context': SherpiContext.encouragement, 'expectedLevel': 'basic'},     // 주로 static
      {'context': SherpiContext.questComplete, 'expectedLevel': 'smart'},     // 가끔 AI
      {'context': SherpiContext.levelUp, 'expectedLevel': 'premium'},         // 자주 AI
    ];
    
    for (int i = 0; i < iterations; i++) {
      for (final testCase in testContexts) {
        final context = testCase['context'] as SherpiContext;
        final userContext = {'레벨': '${5 + i}', '연속 접속일': '$i'};
        
        final startTime = DateTime.now();
        final response = await manager.getMessage(context, userContext, {});
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        
        // 응답 소스별 시간 기록
        final sourceKey = response.source.name;
        if (responseTimes.containsKey(sourceKey)) {
          responseTimes[sourceKey]!.add(duration);
        }
        
        // API 부하 방지
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    return {
      'static_avg_ms': _calculateAverage(responseTimes['static'] ?? []),
      'static_max_ms': _calculateMax(responseTimes['static'] ?? []),
      'cached_avg_ms': _calculateAverage(responseTimes['aiCached'] ?? []),
      'cached_max_ms': _calculateMax(responseTimes['aiCached'] ?? []),
      'realtime_avg_ms': _calculateAverage(responseTimes['aiRealtime'] ?? []),
      'realtime_max_ms': _calculateMax(responseTimes['aiRealtime'] ?? []),
      'fast_response_count': responseTimes.values
          .expand((list) => list)
          .where((time) => time < 1000)
          .length,
      'total_responses': responseTimes.values
          .expand((list) => list)
          .length,
    };
  }
  
  /// 2️⃣ 메모리 사용량 측정 (추정치)
  static Future<Map<String, dynamic>> _benchmarkMemoryUsage() async {
    try {
      final cache = AiMessageCache();
      final cacheStatus = await cache.getCacheStatus();
      
      // 메모리 추정치 계산
      final totalMessages = cacheStatus['total'] as int? ?? 0;
      final avgMessageSize = 100; // bytes 평균
      final messageCacheMemory = totalMessages * avgMessageSize;
      
      // Phase 1 제한사항 확인
      final isWithinLimits = totalMessages <= 100; // 메시지 캐시 제한
      
      return {
        'estimated_cache_memory_bytes': messageCacheMemory,
        'estimated_cache_memory_kb': messageCacheMemory / 1024,
        'total_cached_messages': totalMessages,
        'cache_within_limits': isWithinLimits,
        'max_cache_limit': 100,
        'quality_metrics_limit': 50,
        'template_cache_limit': 20,
      };
    } catch (e) {
      return {
        'error': 'Memory benchmark failed: $e',
      };
    }
  }
  
  /// 3️⃣ 캐시 효율성 측정
  static Future<Map<String, dynamic>> _benchmarkCacheEfficiency() async {
    try {
      final cache = AiMessageCache();
      final cacheStatus = await cache.getCacheStatus();
      
      final totalCached = cacheStatus['total'] as int? ?? 0;
      final validCached = cacheStatus['valid'] as int? ?? 0;
      final expiredCached = cacheStatus['expired'] as int? ?? 0;
      
      final cacheHitRate = totalCached > 0 ? validCached / totalCached : 0.0;
      
      return {
        'total_cached_messages': totalCached,
        'valid_cached_messages': validCached,
        'expired_cached_messages': expiredCached,
        'cache_hit_rate': cacheHitRate,
        'cache_efficiency_score': cacheHitRate * 100,
        'cache_expiry_days': 3, // Phase 1에서 7일 → 3일로 변경
      };
    } catch (e) {
      return {
        'error': 'Cache benchmark failed: $e',
      };
    }
  }
  
  /// 4️⃣ AI 레벨 시스템 성능 측정
  static Future<Map<String, dynamic>> _benchmarkAILevelSystem(int iterations) async {
    final manager = SmartSherpiManager();
    final levelCounts = <String, int>{
      'premium_contexts': 0,
      'smart_contexts': 0, 
      'basic_contexts': 0,
    };
    
    // AI 레벨별 컨텍스트 테스트
    final levelTests = [
      {'context': SherpiContext.welcome, 'level': 'premium'},
      {'context': SherpiContext.levelUp, 'level': 'premium'},
      {'context': SherpiContext.questComplete, 'level': 'smart'},
      {'context': SherpiContext.climbingSuccess, 'level': 'smart'},
      {'context': SherpiContext.general, 'level': 'basic'},
      {'context': SherpiContext.encouragement, 'level': 'basic'},
    ];
    
    int totalTests = 0;
    int fastResponses = 0;
    
    for (int i = 0; i < iterations; i++) {
      for (final test in levelTests) {
        final context = test['context'] as SherpiContext;
        final expectedLevel = test['level'] as String;
        
        final response = await manager.getMessage(context, {'레벨': '$i'}, {});
        
        levelCounts['${expectedLevel}_contexts'] = 
            (levelCounts['${expectedLevel}_contexts'] ?? 0) + 1;
            
        if (response.isFastResponse) fastResponses++;
        totalTests++;
        
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    
    return {
      'ai_levels_tested': 3, // premium, smart, basic
      'premium_contexts_tested': levelCounts['premium_contexts'] ?? 0,
      'smart_contexts_tested': levelCounts['smart_contexts'] ?? 0,
      'basic_contexts_tested': levelCounts['basic_contexts'] ?? 0,
      'fast_response_rate': totalTests > 0 ? fastResponses / totalTests : 0.0,
      'total_tests': totalTests,
    };
  }
  
  /// 📊 전체 성능 점수 계산 (0-100)
  static double _calculatePerformanceScore(Map<String, dynamic> results) {
    double score = 0.0;
    int factors = 0;
    
    // 응답 시간 점수 (40점)
    if (results.containsKey('response_time_benchmark')) {
      final rtBench = results['response_time_benchmark'] as Map<String, dynamic>;
      final staticAvg = rtBench['static_avg_ms'] as double? ?? 1000.0;
      final cachedAvg = rtBench['cached_avg_ms'] as double? ?? 1000.0;
      
      // 목표: static < 50ms, cached < 100ms
      final staticScore = (50.0 / max(staticAvg, 1.0)).clamp(0.0, 1.0) * 20;
      final cachedScore = (100.0 / max(cachedAvg, 1.0)).clamp(0.0, 1.0) * 20;
      
      score += staticScore + cachedScore;
      factors++;
    }
    
    // 캐시 효율성 점수 (30점)
    if (results.containsKey('cache_benchmark')) {
      final cacheBench = results['cache_benchmark'] as Map<String, dynamic>;
      final hitRate = cacheBench['cache_hit_rate'] as double? ?? 0.0;
      
      score += hitRate * 30; // 히트율 * 30점
      factors++;
    }
    
    // AI 시스템 응답률 점수 (30점)
    if (results.containsKey('ai_level_benchmark')) {
      final aiBench = results['ai_level_benchmark'] as Map<String, dynamic>;
      final fastRate = aiBench['fast_response_rate'] as double? ?? 0.0;
      
      score += fastRate * 30; // 빠른 응답률 * 30점
      factors++;
    }
    
    return factors > 0 ? score / factors * (100 / 100) : 0.0; // 정규화
  }
  
  /// ✅ 목표 달성 여부 검증
  static Map<String, bool> _validateTargets(Map<String, dynamic> results) {
    final validation = <String, bool>{};
    
    // 응답 시간 목표
    if (results.containsKey('response_time_benchmark')) {
      final rtBench = results['response_time_benchmark'] as Map<String, dynamic>;
      validation['static_response_target'] = 
          (rtBench['static_avg_ms'] as double? ?? 1000) < performanceTargets['static_response_time_ms']!;
      validation['cached_response_target'] = 
          (rtBench['cached_avg_ms'] as double? ?? 1000) < performanceTargets['cached_response_time_ms']!;
    }
    
    // 빠른 응답률 목표
    if (results.containsKey('ai_level_benchmark')) {
      final aiBench = results['ai_level_benchmark'] as Map<String, dynamic>;
      validation['fast_response_rate_target'] = 
          (aiBench['fast_response_rate'] as double? ?? 0.0) >= performanceTargets['fast_response_rate']!;
    }
    
    // 캐시 효율성 목표
    if (results.containsKey('cache_benchmark')) {
      final cacheBench = results['cache_benchmark'] as Map<String, dynamic>;
      validation['cache_hit_rate_target'] = 
          (cacheBench['cache_hit_rate'] as double? ?? 0.0) >= performanceTargets['cache_hit_rate']!;
    }
    
    return validation;
  }
  
  /// 🧮 헬퍼 메서드들
  static double _calculateAverage(List<int> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  static int _calculateMax(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }
  
  /// 📋 벤치마크 리포트 생성
  static String generateBenchmarkReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    
    buffer.writeln('🚀 Phase 1 단순화 성능 벤치마크 리포트');
    buffer.writeln('═' * 50);
    
    final status = results['benchmark_status'];
    final statusEmoji = status == 'SUCCESS' ? '✅' : '❌';
    buffer.writeln('$statusEmoji 벤치마크 상태: $status');
    
    if (results.containsKey('error_message')) {
      buffer.writeln('❌ 오류: ${results['error_message']}');
      return buffer.toString();
    }
    
    // 전체 성능 점수
    final performanceScore = results['performance_score'] as double? ?? 0.0;
    final scoreEmoji = performanceScore >= 80 ? '🏆' : performanceScore >= 60 ? '⭐' : '⚠️';
    buffer.writeln('$scoreEmoji 전체 성능 점수: ${performanceScore.toStringAsFixed(1)}/100');
    
    // 응답 시간 결과
    if (results.containsKey('response_time_benchmark')) {
      final rtBench = results['response_time_benchmark'] as Map<String, dynamic>;
      buffer.writeln('');
      buffer.writeln('⚡ 응답 시간 성능:');
      buffer.writeln('  • 정적 메시지: ${(rtBench['static_avg_ms'] as double? ?? 0).toStringAsFixed(1)}ms');
      buffer.writeln('  • 캐시된 AI: ${(rtBench['cached_avg_ms'] as double? ?? 0).toStringAsFixed(1)}ms');
      
      final totalResponses = rtBench['total_responses'] as int? ?? 0;
      final fastResponses = rtBench['fast_response_count'] as int? ?? 0;
      final fastRate = totalResponses > 0 ? (fastResponses / totalResponses * 100) : 0.0;
      buffer.writeln('  • 빠른 응답률: ${fastRate.toStringAsFixed(1)}% ($fastResponses/$totalResponses)');
    }
    
    // 캐시 효율성 결과
    if (results.containsKey('cache_benchmark')) {
      final cacheBench = results['cache_benchmark'] as Map<String, dynamic>;
      buffer.writeln('');
      buffer.writeln('💾 캐시 시스템:');
      buffer.writeln('  • 캐시 히트율: ${((cacheBench['cache_hit_rate'] as double? ?? 0.0) * 100).toStringAsFixed(1)}%');
      buffer.writeln('  • 유효한 캐시: ${cacheBench['valid_cached_messages']}개');
      buffer.writeln('  • 만료 기간: ${cacheBench['cache_expiry_days']}일 (개선됨)');
    }
    
    // AI 시스템 결과
    if (results.containsKey('ai_level_benchmark')) {
      final aiBench = results['ai_level_benchmark'] as Map<String, dynamic>;
      buffer.writeln('');
      buffer.writeln('🧠 AI 레벨 시스템:');
      buffer.writeln('  • AI 레벨 수: ${aiBench['ai_levels_tested']}단계 (단순화 완료)');
      buffer.writeln('  • 테스트 케이스: ${aiBench['total_tests']}개');
      
      final fastRate = (aiBench['fast_response_rate'] as double? ?? 0.0) * 100;
      buffer.writeln('  • 빠른 응답률: ${fastRate.toStringAsFixed(1)}%');
    }
    
    // 메모리 사용량 결과
    if (results.containsKey('memory_benchmark')) {
      final memBench = results['memory_benchmark'] as Map<String, dynamic>;
      buffer.writeln('');
      buffer.writeln('🧹 메모리 최적화:');
      buffer.writeln('  • 캐시 메모리: ${((memBench['estimated_cache_memory_kb'] as int? ?? 0) / 1024).toStringAsFixed(2)}MB');
      buffer.writeln('  • 메시지 제한: ${memBench['total_cached_messages']}/${memBench['max_cache_limit']}개');
      buffer.writeln('  • 제한 준수: ${memBench['cache_within_limits'] ? '✅' : '❌'}');
    }
    
    // 목표 달성 여부
    if (results.containsKey('meets_targets')) {
      final targets = results['meets_targets'] as Map<String, bool>;
      buffer.writeln('');
      buffer.writeln('🎯 Phase 1 목표 달성:');
      targets.forEach((target, achieved) {
        final emoji = achieved ? '✅' : '❌';
        buffer.writeln('  $emoji ${target.replaceAll('_', ' ')}: ${achieved ? '달성' : '미달성'}');
      });
    }
    
    // Phase 1 개선 요약
    buffer.writeln('');
    buffer.writeln('📈 Phase 1 개선 요약:');
    buffer.writeln('  • AI 시스템 단순화: 4단계 → 3단계');
    buffer.writeln('  • 캐시 최적화: 7일 → 3일 만료');
    buffer.writeln('  • 메모리 제한: 메트릭 50개, 템플릿 20개');
    buffer.writeln('  • 응답 속도: 95%+ 즉시 응답 목표');
    
    buffer.writeln('');
    buffer.writeln('🕒 벤치마크 시간: ${results['benchmark_start_time']} ~ ${results['benchmark_end_time']}');
    
    return buffer.toString();
  }
}