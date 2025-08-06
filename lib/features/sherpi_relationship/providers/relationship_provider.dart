import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../shared/models/sherpi_relationship_model.dart';
import '../../../core/constants/sherpi_dialogues.dart';

/// 🤝 셰르피 관계 상태 관리
class SherpiRelationshipNotifier extends StateNotifier<SherpiRelationship> {
  static const String _storageKey = 'sherpi_relationship';
  final SharedPreferences _prefs;

  SherpiRelationshipNotifier(this._prefs) 
      : super(_loadInitialState(_prefs)) {
    // 상태 변경 시 자동 저장
    addListener((state) {
      _saveToStorage(state);
    });
  }

  /// 초기 상태 로드
  static SherpiRelationship _loadInitialState(SharedPreferences prefs) {
    final String? savedData = prefs.getString(_storageKey);
    if (savedData != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(savedData);
        return SherpiRelationship.fromJson(json);
      } catch (e) {
        print('❌ 관계 데이터 로드 실패: $e');
      }
    }
    
    // 기본 상태
    return SherpiRelationship(
      firstMeetingDate: DateTime.now(),
      lastInteractionDate: DateTime.now(),
    );
  }

  /// 상태 저장
  Future<void> _saveToStorage(SherpiRelationship relationship) async {
    try {
      final String jsonData = jsonEncode(relationship.toJson());
      await _prefs.setString(_storageKey, jsonData);
    } catch (e) {
      print('❌ 관계 데이터 저장 실패: $e');
    }
  }

  /// 🎯 상호작용 기록
  void recordInteraction({
    required String interactionType,
    Map<String, dynamic>? context,
  }) {
    final now = DateTime.now();
    final lastDate = state.lastInteractionDate;
    
    // 연속 일수 계산
    int newConsecutiveDays = state.consecutiveDays;
    if (lastDate.day != now.day || 
        lastDate.month != now.month || 
        lastDate.year != now.year) {
      // 하루가 지났는지 확인
      final daysDiff = now.difference(lastDate).inDays;
      if (daysDiff == 1) {
        newConsecutiveDays++;
      } else if (daysDiff > 1) {
        newConsecutiveDays = 1; // 연속이 끊김
      }
    }

    // 상호작용 유형 카운트 업데이트
    final Map<String, int> updatedTypes = Map.from(state.interactionTypes);
    updatedTypes[interactionType] = (updatedTypes[interactionType] ?? 0) + 1;

    // 총 상호작용 횟수 증가
    final newTotalInteractions = state.totalInteractions + 1;

    // 친밀도 레벨 재계산
    final newIntimacyLevel = SherpiRelationship.calculateIntimacyLevel(
      newTotalInteractions, 
      newConsecutiveDays
    );

    // 성격 인사이트 업데이트
    final updatedInsights = state.personalityInsights.updateFromInteraction(
      interactionType: interactionType,
      context: context ?? {},
    );

    // 감정 동기화 수준 업데이트 (상호작용이 많을수록 증가)
    final newEmotionalSync = (state.emotionalSync + 0.01).clamp(0.0, 1.0);

    state = state.copyWith(
      totalInteractions: newTotalInteractions,
      consecutiveDays: newConsecutiveDays,
      lastInteractionDate: now,
      interactionTypes: updatedTypes,
      intimacyLevel: newIntimacyLevel,
      personalityInsights: updatedInsights,
      emotionalSync: newEmotionalSync,
    );

    // 레벨업 체크
    if (newIntimacyLevel > state.intimacyLevel) {
      _handleIntimacyLevelUp(newIntimacyLevel);
    }
  }

  /// 🌟 특별한 순간 추가
  void addSpecialMoment({
    required String type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) {
    final moment = SpecialMoment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: type,
      title: title,
      description: description,
      metadata: metadata ?? {},
    );

    final updatedMoments = [...state.specialMoments, moment];
    
    // 최대 50개까지만 보관
    if (updatedMoments.length > 50) {
      updatedMoments.removeAt(0);
    }

    state = state.copyWith(specialMoments: updatedMoments);
  }

  /// 💝 친밀도 레벨업 처리
  void _handleIntimacyLevelUp(int newLevel) {
    // 특별한 순간으로 기록
    addSpecialMoment(
      type: 'intimacy_levelup',
      title: '친밀도 레벨 $newLevel 달성!',
      description: '${state.relationshipTitle}가 되었어요!',
      metadata: {
        'previousLevel': state.intimacyLevel,
        'newLevel': newLevel,
        'totalInteractions': state.totalInteractions,
      },
    );
  }

  /// 📊 관계 통계 가져오기
  Map<String, dynamic> getRelationshipStats() {
    final daysSinceMeeting = DateTime.now().difference(state.firstMeetingDate).inDays;
    final averageInteractionsPerDay = daysSinceMeeting > 0 
        ? (state.totalInteractions / daysSinceMeeting).toStringAsFixed(1)
        : '0';

    // 가장 많은 상호작용 유형 찾기
    String? favoriteInteraction;
    int maxCount = 0;
    state.interactionTypes.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        favoriteInteraction = type;
      }
    });

    return {
      'daysTogether': daysSinceMeeting,
      'totalInteractions': state.totalInteractions,
      'consecutiveDays': state.consecutiveDays,
      'intimacyLevel': state.intimacyLevel,
      'relationshipTitle': state.relationshipTitle,
      'averageInteractionsPerDay': averageInteractionsPerDay,
      'favoriteInteraction': favoriteInteraction,
      'specialMomentsCount': state.specialMoments.length,
      'emotionalSync': state.emotionalSync,
      'emotionalSyncDescription': state.emotionalSyncDescription,
      'personalityType': state.personalityInsights.primaryPersonalityType,
      'nextLevelProgress': _calculateNextLevelProgress(),
    };
  }

  /// 다음 레벨 진행률 계산 (0.0 ~ 1.0)
  double _calculateNextLevelProgress() {
    if (state.intimacyLevel >= 10) return 1.0;
    
    final currentLevelRequirement = (state.intimacyLevel - 1) * 100;
    final nextLevelRequirement = state.intimacyLevel * 100;
    final range = nextLevelRequirement - currentLevelRequirement;
    final progress = state.totalInteractions - currentLevelRequirement;
    
    return (progress / range).clamp(0.0, 1.0);
  }

  /// 🔄 관계 초기화 (디버그용)
  void resetRelationship() {
    state = SherpiRelationship(
      firstMeetingDate: DateTime.now(),
      lastInteractionDate: DateTime.now(),
    );
  }

  /// 💭 특별한 순간 회상하기
  SpecialMoment? recallSpecialMoment({String? type}) {
    if (state.specialMoments.isEmpty) return null;

    if (type != null) {
      // 특정 타입의 순간 찾기
      final filtered = state.specialMoments.where((m) => m.type == type).toList();
      if (filtered.isNotEmpty) {
        return filtered[DateTime.now().millisecond % filtered.length];
      }
    }

    // 랜덤하게 하나 선택
    return state.specialMoments[DateTime.now().millisecond % state.specialMoments.length];
  }

  /// 💖 감정 동기화 점수 업데이트 (감정 분석 시스템 연동)
  void updateEmotionalSync(double newSyncScore) {
    // 현재 점수와 새 점수의 가중 평균 계산 (점진적 변화)
    final currentScore = state.emotionalSync;
    final weightedScore = (currentScore * 0.7) + (newSyncScore * 0.3);
    
    final updatedScore = weightedScore.clamp(0.0, 1.0);
    
    state = state.copyWith(emotionalSync: updatedScore);
    
    // 감정 동기화 수준이 크게 향상된 경우 특별한 순간으로 기록
    if (updatedScore - currentScore >= 0.2) {
      _recordEmotionalSyncImprovement(updatedScore);
    }
  }

  /// 💕 감정 동기화 개선 특별한 순간 기록
  void _recordEmotionalSyncImprovement(double newScore) {
    String title;
    String description;
    
    if (newScore >= 0.8) {
      title = '마음이 완전히 통했어요!';
      description = '셰르피와의 감정 동기화가 완벽해졌어요. 이제 서로를 완전히 이해해요!';
    } else if (newScore >= 0.6) {
      title = '깊은 유대감을 느껴요';
      description = '셰르피와의 감정적 연결이 더욱 강해졌어요. 서로의 마음을 잘 알 수 있어요.';
    } else if (newScore >= 0.4) {
      title = '마음이 통하기 시작해요';
      description = '셰르피와의 감정 교감이 늘어나고 있어요. 점점 더 가까워지는 느낌이에요.';
    } else {
      title = '서로를 알아가고 있어요';
      description = '셰르피와의 감정적 연결이 조금씩 좋아지고 있어요.';
    }

    addSpecialMoment(
      type: 'emotional_sync_improvement',
      title: title,
      description: description,
      metadata: {
        'syncScore': newScore,
        'improvement': newScore - state.emotionalSync,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 📈 감정 동기화 히스토리 분석
  Map<String, dynamic> getEmotionalSyncTrend() {
    final syncMoments = state.specialMoments
        .where((m) => m.type == 'emotional_sync_improvement')
        .toList();
    
    if (syncMoments.isEmpty) {
      return {
        'trend': 'stable',
        'improvements': 0,
        'lastImprovement': null,
        'averageGrowth': 0.0,
      };
    }

    // 최근 5개 개선 기록 분석
    final recentMoments = syncMoments.take(5).toList();
    double totalGrowth = 0.0;
    
    for (final moment in recentMoments) {
      final improvement = moment.metadata['improvement'] as double? ?? 0.0;
      totalGrowth += improvement;
    }
    
    final averageGrowth = totalGrowth / recentMoments.length;
    
    String trend = 'stable';
    if (averageGrowth > 0.1) {
      trend = 'rapidly_improving';
    } else if (averageGrowth > 0.05) {
      trend = 'improving';
    } else if (averageGrowth < -0.05) {
      trend = 'declining';
    }

    return {
      'trend': trend,
      'improvements': syncMoments.length,
      'lastImprovement': syncMoments.isNotEmpty 
          ? syncMoments.first.timestamp.toIso8601String()
          : null,
      'averageGrowth': averageGrowth,
      'currentLevel': state.emotionalSyncDescription,
    };
  }
}

/// 🌟 셰르피 관계 프로바이더
final sherpiRelationshipProvider = StateNotifierProvider<SherpiRelationshipNotifier, SherpiRelationship>((ref) {
  throw UnimplementedError('SharedPreferences를 main.dart에서 제공해야 합니다');
});

/// 관계 통계 프로바이더
final relationshipStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.watch(sherpiRelationshipProvider.notifier);
  return notifier.getRelationshipStats();
});

/// 특별한 순간 목록 프로바이더
final specialMomentsProvider = Provider<List<SpecialMoment>>((ref) {
  return ref.watch(sherpiRelationshipProvider).specialMoments;
});

/// 다음 레벨 진행률 프로바이더
final nextLevelProgressProvider = Provider<double>((ref) {
  final stats = ref.watch(relationshipStatsProvider);
  return stats['nextLevelProgress'] ?? 0.0;
});