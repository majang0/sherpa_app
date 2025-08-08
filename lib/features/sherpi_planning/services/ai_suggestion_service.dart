import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/models/global_user_model.dart';
import '../constants/planning_constants.dart';

/// AI 제안 서비스
/// 사용자의 현재 상태와 입력을 기반으로 실시간 목표 제안
class AiSuggestionService {
  
  /// 사용자 데이터 기반 스마트 제안 생성
  static List<GoalSuggestion> generateSmartSuggestions(GlobalUser user, {
    String? currentInput,
    String? selectedCategory,
  }) {
    final suggestions = <GoalSuggestion>[];
    
    // 1. 활동 기록 기반 제안
    _addActivityBasedSuggestions(user, suggestions);
    
    // 2. 레벨 기반 제안
    _addLevelBasedSuggestions(user, suggestions);
    
    // 3. 카테고리별 제안
    if (selectedCategory != null) {
      _addCategorySpecificSuggestions(selectedCategory, suggestions, user);
    }
    
    // 4. 시즌/시간 기반 제안
    _addTimeBasedSuggestions(suggestions);
    
    // 5. 현재 입력 기반 제안 (입력 중 실시간 제안)
    if (currentInput != null && currentInput.isNotEmpty) {
      _addInputBasedSuggestions(currentInput, suggestions);
    }
    
    // 중복 제거 및 우선순위 정렬
    return _prioritizeSuggestions(suggestions);
  }
  
  /// 활동 기록 기반 제안
  static void _addActivityBasedSuggestions(GlobalUser user, List<GoalSuggestion> suggestions) {
    // 운동 기록 분석
    final exerciseCount = user.dailyRecords.exerciseLogs.length;
    if (exerciseCount < 5) {
      suggestions.add(GoalSuggestion(
        title: '주 3회 운동 습관 만들기',
        description: '건강한 몸을 위해 규칙적인 운동을 시작해보세요',
        category: 'health',
        difficulty: 'beginner',
        estimatedDays: 30,
        icon: Icons.fitness_center,
        relevanceScore: 0.9,
        reason: '현재 운동 기록이 적어 추천드려요',
      ));
    } else if (exerciseCount > 20) {
      suggestions.add(GoalSuggestion(
        title: '운동 강도 높이기',
        description: '이미 운동 습관이 잘 잡혀있으니 다음 단계로 도전해보세요',
        category: 'health',
        difficulty: 'intermediate',
        estimatedDays: 30,
        icon: Icons.trending_up,
        relevanceScore: 0.8,
        reason: '꾸준한 운동 기록을 바탕으로 추천',
      ));
    }
    
    // 독서 기록 분석
    final readingCount = user.dailyRecords.readingLogs.length;
    if (readingCount < 3) {
      suggestions.add(GoalSuggestion(
        title: '매일 30분 독서하기',
        description: '하루 30분 독서로 지식과 교양을 쌓아보세요',
        category: 'learning',
        difficulty: 'beginner',
        estimatedDays: 21,
        icon: Icons.menu_book,
        relevanceScore: 0.85,
        reason: '독서 기록이 적어 추천드려요',
      ));
    }
    
    // 일기 기록 분석
    final diaryCount = user.dailyRecords.diaryLogs.length;
    if (diaryCount < 5) {
      suggestions.add(GoalSuggestion(
        title: '감사 일기 쓰기',
        description: '매일 3가지 감사한 일을 기록해보세요',
        category: 'growth',
        difficulty: 'beginner',
        estimatedDays: 21,
        icon: Icons.edit_note,
        relevanceScore: 0.75,
        reason: '일기 작성 습관 형성을 위해',
      ));
    }
  }
  
  /// 레벨 기반 제안
  static void _addLevelBasedSuggestions(GlobalUser user, List<GoalSuggestion> suggestions) {
    if (user.level < 10) {
      suggestions.add(GoalSuggestion(
        title: '레벨 10 달성하기',
        description: '첫 번째 큰 목표! 레벨 10을 향해 달려보세요',
        category: 'growth',
        difficulty: 'beginner',
        estimatedDays: 14,
        icon: Icons.emoji_events,
        relevanceScore: 0.95,
        reason: '현재 레벨 ${user.level}에서 추천',
      ));
    } else if (user.level < 20) {
      suggestions.add(GoalSuggestion(
        title: '전문가 레벨 도전',
        description: '레벨 20을 달성하고 전문가가 되어보세요',
        category: 'growth',
        difficulty: 'intermediate',
        estimatedDays: 30,
        icon: Icons.star,
        relevanceScore: 0.85,
        reason: '중급자를 위한 도전 목표',
      ));
    }
  }
  
  /// 카테고리별 제안
  static void _addCategorySpecificSuggestions(
    String category, 
    List<GoalSuggestion> suggestions,
    GlobalUser user,
  ) {
    switch (category) {
      case 'health':
        suggestions.addAll([
          GoalSuggestion(
            title: '하루 1만보 걷기',
            description: '건강한 일상을 위한 첫걸음',
            category: 'health',
            difficulty: 'beginner',
            estimatedDays: 30,
            icon: Icons.directions_walk,
            relevanceScore: 0.8,
          ),
          GoalSuggestion(
            title: '물 8잔 마시기',
            description: '충분한 수분 섭취로 건강 지키기',
            category: 'health',
            difficulty: 'beginner',
            estimatedDays: 21,
            icon: Icons.water_drop,
            relevanceScore: 0.75,
          ),
        ]);
        break;
        
      case 'growth':
        suggestions.addAll([
          GoalSuggestion(
            title: '새로운 기술 배우기',
            description: '관심있던 분야의 온라인 강의 수강',
            category: 'growth',
            difficulty: 'intermediate',
            estimatedDays: 30,
            icon: Icons.school,
            relevanceScore: 0.85,
          ),
          GoalSuggestion(
            title: '명상 습관 만들기',
            description: '하루 10분 명상으로 마음 다스리기',
            category: 'growth',
            difficulty: 'beginner',
            estimatedDays: 21,
            icon: Icons.self_improvement,
            relevanceScore: 0.7,
          ),
        ]);
        break;
        
      case 'relationship':
        suggestions.addAll([
          GoalSuggestion(
            title: '주 1회 가족과 식사',
            description: '가족과 함께하는 시간 늘리기',
            category: 'relationship',
            difficulty: 'beginner',
            estimatedDays: 30,
            icon: Icons.family_restroom,
            relevanceScore: 0.8,
          ),
          GoalSuggestion(
            title: '친구에게 안부 전하기',
            description: '매주 한 명씩 연락하기',
            category: 'relationship',
            difficulty: 'beginner',
            estimatedDays: 30,
            icon: Icons.chat,
            relevanceScore: 0.7,
          ),
        ]);
        break;
        
      case 'productivity':
        suggestions.addAll([
          GoalSuggestion(
            title: '아침 루틴 만들기',
            description: '생산적인 하루를 위한 아침 습관',
            category: 'productivity',
            difficulty: 'intermediate',
            estimatedDays: 21,
            icon: Icons.wb_sunny,
            relevanceScore: 0.85,
          ),
          GoalSuggestion(
            title: '할 일 목록 작성하기',
            description: '매일 아침 우선순위 정하기',
            category: 'productivity',
            difficulty: 'beginner',
            estimatedDays: 14,
            icon: Icons.checklist,
            relevanceScore: 0.8,
          ),
        ]);
        break;
    }
  }
  
  /// 시간 기반 제안
  static void _addTimeBasedSuggestions(List<GoalSuggestion> suggestions) {
    final now = DateTime.now();
    final month = now.month;
    final hour = now.hour;
    
    // 계절별 제안
    if (month >= 3 && month <= 5) {
      // 봄
      suggestions.add(GoalSuggestion(
        title: '봄맞이 대청소',
        description: '깨끗한 환경에서 새로운 시작',
        category: 'productivity',
        difficulty: 'beginner',
        estimatedDays: 7,
        icon: Icons.cleaning_services,
        relevanceScore: 0.6,
      ));
    } else if (month >= 6 && month <= 8) {
      // 여름
      suggestions.add(GoalSuggestion(
        title: '여름 몸매 만들기',
        description: '건강한 여름을 위한 운동 계획',
        category: 'health',
        difficulty: 'intermediate',
        estimatedDays: 30,
        icon: Icons.pool,
        relevanceScore: 0.7,
      ));
    }
    
    // 시간대별 제안
    if (hour >= 5 && hour < 9) {
      suggestions.add(GoalSuggestion(
        title: '미라클 모닝 실천',
        description: '아침 시간 활용하기',
        category: 'productivity',
        difficulty: 'intermediate',
        estimatedDays: 21,
        icon: Icons.alarm,
        relevanceScore: 0.65,
      ));
    }
  }
  
  /// 입력 기반 제안
  static void _addInputBasedSuggestions(String input, List<GoalSuggestion> suggestions) {
    final lowerInput = input.toLowerCase();
    
    if (lowerInput.contains('운동') || lowerInput.contains('health')) {
      suggestions.add(GoalSuggestion(
        title: '홈트레이닝 루틴 만들기',
        description: '집에서 할 수 있는 운동 프로그램',
        category: 'health',
        difficulty: 'beginner',
        estimatedDays: 30,
        icon: Icons.home,
        relevanceScore: 0.9,
        reason: '입력하신 내용과 관련된 추천',
      ));
    }
    
    if (lowerInput.contains('공부') || lowerInput.contains('study')) {
      suggestions.add(GoalSuggestion(
        title: '매일 1시간 공부하기',
        description: '꾸준한 학습 습관 만들기',
        category: 'learning',
        difficulty: 'intermediate',
        estimatedDays: 30,
        icon: Icons.book,
        relevanceScore: 0.9,
        reason: '입력하신 내용과 관련된 추천',
      ));
    }
  }
  
  /// 제안 우선순위 정렬
  static List<GoalSuggestion> _prioritizeSuggestions(List<GoalSuggestion> suggestions) {
    // 중복 제거
    final uniqueSuggestions = <String, GoalSuggestion>{};
    for (final suggestion in suggestions) {
      uniqueSuggestions[suggestion.title] = suggestion;
    }
    
    // 관련성 점수로 정렬
    final sortedList = uniqueSuggestions.values.toList()
      ..sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    
    // 상위 7개만 반환
    return sortedList.take(7).toList();
  }
  
  /// 실시간 제안 업데이트 (스트림)
  static Stream<List<GoalSuggestion>> getSuggestionStream(
    GlobalUser user,
    Stream<String> inputStream,
    Stream<String> categoryStream,
  ) async* {
    String currentInput = '';
    String currentCategory = 'health';
    
    // 입력 변화 감지
    inputStream.listen((input) => currentInput = input);
    categoryStream.listen((category) => currentCategory = category);
    
    // 500ms마다 제안 업데이트
    await for (final _ in Stream.periodic(const Duration(milliseconds: 500))) {
      yield generateSmartSuggestions(
        user,
        currentInput: currentInput,
        selectedCategory: currentCategory,
      );
    }
  }
}

/// 목표 제안 모델
class GoalSuggestion {
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int estimatedDays;
  final IconData icon;
  final double relevanceScore;
  final String? reason;
  
  GoalSuggestion({
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedDays,
    required this.icon,
    required this.relevanceScore,
    this.reason,
  });
  
  /// 제안을 목표로 변환
  Map<String, dynamic> toGoal() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'duration': estimatedDays,
      'difficulty': difficulty,
      'createdAt': DateTime.now(),
    };
  }
}