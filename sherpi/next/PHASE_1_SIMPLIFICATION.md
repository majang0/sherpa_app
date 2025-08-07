# Phase 1: 시스템 단순화 및 최적화 (1개월)

## 🎯 목표

현재 과도하게 복잡한 AI 시스템을 **사용자 가치 중심**으로 단순화하고, 성능과 비용 효율성을 개선합니다.

**핵심 원칙**: "복잡함보다 단순함, 기능보다 성능, 기술보다 사용자"

## 📅 일정 및 마일스톤

### Week 1-2: 아키텍처 단순화
- [ ] 4단계 → 3단계 AI 레벨 재구성
- [ ] 개인화 시스템 정리
- [ ] 코드 중복 제거

### Week 3-4: 성능 최적화
- [ ] API 호출 최적화
- [ ] 캐시 전략 재검토
- [ ] 메모리 사용량 최적화

## 🔧 세부 작업 계획

### 1. AI 레벨 시스템 단순화

#### 현재 상태 (4단계)
```
📊 현재: 복잡한 4단계 시스템
├── always (100% AI) - 특별한 순간
├── important (30-50% AI) - 조건부 사용  
├── occasional (10-20% AI) - 마일스톤만
└── rarely (1% AI) - 일상 상호작용
```

#### 목표 상태 (3단계)
```
🎯 개선: 단순한 3단계 시스템
├── PREMIUM (80% AI) - 중요한 순간들
├── SMART (15% AI) - 특별한 달성
└── BASIC (5% AI) - 일상 상호작용
```

#### 구체적 변경사항

**1.1. AiUsageLevel enum 단순화**
```dart
// 기존 (lib/core/ai/smart_sherpi_manager.dart:322)
enum AiUsageLevel {
  always,      // 100% AI
  important,   // 30-50% AI  
  occasional,  // 10-20% AI
  rarely,      // 1% AI
}

// ↓ 변경

enum AiUsageLevel {
  premium,     // 80% AI - 중요한 순간
  smart,       // 15% AI - 특별한 달성
  basic,       // 5% AI - 일상 상호작용
}
```

**1.2. 컨텍스트 매핑 재정의**
```dart
// 새로운 매핑
static const Map<SherpiContext, AiUsageLevel> _aiUsageLevels = {
  // 🌟 PREMIUM: 감정적 연결이 중요한 순간
  SherpiContext.welcome: AiUsageLevel.premium,
  SherpiContext.longTimeNoSee: AiUsageLevel.premium,
  SherpiContext.levelUp: AiUsageLevel.premium, // 모든 레벨업을 premium으로
  SherpiContext.milestone: AiUsageLevel.premium,
  
  // ⭐ SMART: 특별한 성취 순간  
  SherpiContext.badgeEarned: AiUsageLevel.smart,
  SherpiContext.climbingSuccess: AiUsageLevel.smart,
  SherpiContext.questComplete: AiUsageLevel.smart,
  
  // 💬 BASIC: 일상적 상호작용
  SherpiContext.general: AiUsageLevel.basic,
  SherpiContext.dailyGreeting: AiUsageLevel.basic,
  SherpiContext.encouragement: AiUsageLevel.basic,
  SherpiContext.exerciseComplete: AiUsageLevel.basic,
};
```

**1.3. 조건부 로직 단순화**
복잡한 조건 체크를 제거하고 컨텍스트 기반으로만 결정:
```dart
bool _shouldUseAI(SherpiContext context, AiUsageLevel level) {
  final randomValue = DateTime.now().millisecond / 1000.0;
  
  switch (level) {
    case AiUsageLevel.premium:
      return randomValue < 0.8; // 80%
    case AiUsageLevel.smart:
      return randomValue < 0.15; // 15%
    case AiUsageLevel.basic:
      return randomValue < 0.05; // 5%
  }
}
```

### 2. 개인화 시스템 정리

#### 현재 문제점
- 개인화 매니저가 비활성화됨 (`_usePersonalization = false`)
- PersonalizedSherpiManager 코드가 제거됨
- 복잡한 성격 유형 시스템이 활용되지 않음

#### 해결 방안

**2.1. 비활성화된 개인화 코드 완전 제거**
```dart
// 제거할 코드들
- PersonalizedSherpiManager 관련 모든 코드
- _usePersonalization 플래그 및 관련 로직
- 사용하지 않는 성격 유형별 프롬프트 템플릿
```

**2.2. 핵심 개인화 기능만 유지**
```dart
// 유지할 핵심 개인화 기능
✅ 사용자 레벨 기반 메시지
✅ 연속 접속일 기반 친밀도
✅ 최근 활동 기반 컨텍스트
❌ 복잡한 성격 유형 분류
❌ 시간대/에너지/감정 적응
❌ 동적 프롬프트 어댑테이션
```

**2.3. 단순화된 개인화 로직**
```dart
String _buildSimplePersonalizedPrompt(
  SherpiContext context,
  Map<String, dynamic>? userContext,
) {
  final userName = userContext?['name'] ?? '사용자';
  final userLevel = userContext?['level'] ?? 1;
  final consecutiveDays = userContext?['consecutive_days'] ?? 1;
  
  // 기본 시스템 프롬프트 + 간단한 사용자 정보만
  return '''
당신은 셰르피입니다. $userName님(레벨 $userLevel, ${consecutiveDays}일 연속)의 성장 동반자입니다.

현재 상황: ${context.name}

응답 원칙:
- "우리" 언어로 동반자 관계 강조
- 2-3문장으로 따뜻하고 개인적인 메시지
- 이모지 1-2개 적절히 사용
- 절대 평가하거나 비난하지 말 것
  ''';
}
```

### 3. 코드 중복 제거

#### 3.1. 중복된 응답 처리 로직 통합
현재 여러 클래스에 분산된 응답 처리를 하나로 통합:
```dart
// 통합할 클래스들
- SmartSherpiManager
- EnhancedGeminiDialogueSource  
- StaticDialogueSource

// → ResponseManager로 통합
class ResponseManager {
  Future<SherpiResponse> getResponse(
    SherpiContext context,
    Map<String, dynamic>? userContext,
  );
}
```

#### 3.2. 불필요한 추상화 레이어 제거
```dart
// 제거 대상
- SherpiDialogueSource 인터페이스 (사용처가 제한적)
- 복잡한 Builder 패턴들
- 과도한 Factory 메소드들
```

### 4. 성능 최적화

#### 4.1. API 호출 최적화

**현재 문제점**:
- 백그라운드에서 5개 컨텍스트의 메시지를 무조건 사전 생성
- API 부하 방지를 위한 2초 딜레이가 총 10초 소요

**개선 방안**:
```dart
// 기존: 모든 premium 컨텍스트 사전 생성
static const List<SherpiContext> _premiumContexts = [
  SherpiContext.welcome,
  SherpiContext.levelUp, 
  SherpiContext.longTimeNoSee,
  SherpiContext.milestone,
  SherpiContext.specialEvent,
];

// 개선: 사용자별 맞춤 사전 생성
List<SherpiContext> _getPersonalizedContexts(Map<String, dynamic> userContext) {
  final contexts = <SherpiContext>[SherpiContext.welcome]; // 항상 포함
  
  final level = userContext['level'] ?? 1;
  final lastLogin = userContext['last_login_days_ago'] ?? 0;
  
  // 조건부 추가
  if (level > 0 && level % 5 == 0) contexts.add(SherpiContext.levelUp);
  if (lastLogin > 3) contexts.add(SherpiContext.longTimeNoSee);
  
  return contexts;
}
```

#### 4.2. 캐시 전략 재검토

**현재**: 7일 캐시 만료
**문제점**: 
- 과도한 저장 공간 사용
- 사용자 변화 반영 지연
- 불필요한 오래된 캐시 보관

**개선안**: 3일 캐시 + 스마트 갱신
```dart
static const Duration _cacheExpiry = Duration(days: 3); // 7일 → 3일

// 스마트 캐시 갱신 조건
bool _shouldRefreshCache(CachedMessage cached, Map<String, dynamic> currentContext) {
  // 사용자 레벨이 변경되면 즉시 갱신
  final cachedLevel = cached.userContext['level'] ?? 1;
  final currentLevel = currentContext['level'] ?? 1;
  return cachedLevel != currentLevel;
}
```

#### 4.3. 메모리 사용량 최적화

**현재 문제점**:
- 무제한 메트릭 수집 (`List<ResponseQualityMetric>`)
- 프롬프트 템플릿 캐시 무제한 증가
- 메시지 캐시 크기 제한 없음

**개선안**:
```dart
// 메트릭 수집 제한
static const int _maxQualityMetrics = 50; // 100 → 50

// 템플릿 캐시 크기 제한
static const int _maxTemplateCache = 20;

// 메시지 캐시 크기 제한  
static const int _maxMessageCache = 100;

// LRU 정책으로 오래된 항목 제거
void _cleanupCache() {
  if (_cache.length > _maxMessageCache) {
    // 오래된 항목부터 제거
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.generatedAt.compareTo(b.value.generatedAt));
    
    final toRemove = sortedEntries.take(_cache.length - _maxMessageCache);
    for (final entry in toRemove) {
      _cache.remove(entry.key);
    }
  }
}
```

## 📊 성공 지표

### 코드 복잡도 감소
- [ ] **클래스 개수**: 12개 → 8개 (33% 감소)
- [ ] **메소드 복잡도**: 평균 8 → 평균 5 (38% 감소)
- [ ] **코드 라인 수**: 2000라인 → 1400라인 (30% 감소)

### 성능 개선
- [ ] **API 호출 감소**: 월 1000회 → 월 800회 (20% 감소)
- [ ] **앱 메모리 사용**: +50MB → +35MB (30% 감소)
- [ ] **응답 속도**: 95% 즉시 → 97% 즉시 유지

### 유지보수성 향상
- [ ] **신규 개발자 온보딩**: 3일 → 1일
- [ ] **버그 재현 시간**: 평균 30분 → 평균 15분
- [ ] **새 기능 추가 시간**: 평균 2일 → 평균 1일

## 🚨 리스크 관리

### 주요 리스크
1. **기능 손실**: 복잡한 개인화 기능 제거로 인한 품질 저하
2. **사용자 혼란**: AI 사용 패턴 변화로 인한 일시적 혼란
3. **성능 이슈**: 캐시 정책 변경으로 인한 응답 시간 증가

### 대응 방안
1. **점진적 배포**: A/B 테스트로 50% 사용자에게만 적용 후 확대
2. **모니터링 강화**: 핵심 메트릭 실시간 추적
3. **롤백 준비**: 이전 버전으로 즉시 복구 가능한 구조

## ✅ 완료 체크리스트

### Week 1-2: 아키텍처 단순화
- [ ] AiUsageLevel enum을 3단계로 변경
- [ ] 컨텍스트 매핑 재정의
- [ ] 복잡한 조건부 로직 제거
- [ ] 개인화 관련 사용하지 않는 코드 제거
- [ ] 핵심 개인화 기능만 유지
- [ ] 중복된 응답 처리 로직 통합

### Week 3-4: 성능 최적화  
- [ ] 선택적 백그라운드 생성으로 변경
- [ ] 캐시 만료 기간 7일 → 3일 변경
- [ ] 스마트 캐시 갱신 로직 구현
- [ ] 메모리 사용량 제한 로직 추가
- [ ] LRU 캐시 정리 로직 구현
- [ ] 성능 테스트 및 최적화 확인

### 문서화
- [ ] 변경된 아키텍처 문서 업데이트
- [ ] API 사용 가이드라인 작성
- [ ] 성능 최적화 가이드 작성
- [ ] 트러블슈팅 가이드 업데이트

---

**이 단계를 완료하면 셰르피 AI 시스템은 30% 더 단순하고, 20% 더 빠르며, 훨씬 유지보수하기 쉬운 상태가 될 것입니다.**