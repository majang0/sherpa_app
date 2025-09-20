# AI/Sherpi 시스템 코드 품질 개선 실행 계획

**작성일**: 2025-09-20
**작성자**: Claude (Sequential Analysis + Codex Review Integration)
**문서 버전**: 1.0.0
**계획 기간**: 4주 (Sprint 0-4)
**목표**: 코드 품질 65점 → 85점, 프로덕션 준비도 45% → 90%

---

## 📊 Executive Summary

두 개의 코드 리뷰 분석 결과, **127시간의 기술 부채**와 **5개의 Critical Issues**가 발견되었습니다.
본 문서는 4주간의 Sprint 기반 개선 계획을 제시하며, 즉시 실행 가능한 작업부터 점진적 개선까지 체계적으로 구성했습니다.

### 현재 상태 vs 목표
| 지표 | 현재 | 2주 후 | 4주 후 |
|------|------|--------|--------|
| **코드 품질** | 65/100 | 80/100 | 85/100 |
| **테스트 커버리지** | 30% | 60% | 70% |
| **프로덕션 준비도** | 45% | 75% | 90% |
| **Critical Issues** | 5개 | 0개 | 0개 |
| **Warnings** | 50+ | <10 | <5 |
| **기술 부채** | 127h | 60h | 40h |

---

## 🚨 Critical Path (긴급 실행 경로)

### Sprint 0: Emergency Fixes (4시간 이내 즉시 실행)

#### 🔴 P0-1: 포인트 차감 로직 적용
**문제**: AI 분석이 포인트 없이도 실행됨 (비즈니스 크리티컬)
```dart
// 파일: lib/features/sherpi/analysis/services/ai_insight_generator.dart
// 수정 필요: generateAIInsights, generateAIRecommendations, generateSmartGrowthPlan

Future<List<Insight>> generateAIInsights(...) async {
  // 추가할 코드
  if (_ref == null || !_hasEnoughPoints()) {
    throw InsufficientPointsException('포인트 부족: ${ANALYSIS_COST}P 필요');
  }
  if (!await _deductPoints()) {
    throw InsufficientPointsException('포인트 차감 실패');
  }

  try {
    // 기존 AI 호출 로직...
  } catch (e) {
    // 포인트 롤백 고려
    await _refundPoints();
    rethrow;
  }
}
```
**예상 시간**: 1시간
**검증**: 포인트 0인 계정으로 분석 시도 → 차단 확인

#### 🔴 P0-2: PersonalizationSettings 제거
**문제**: undefined_shown_name 컴파일 경고
```dart
// 파일: lib/core/ai/managers/openai_sherpi_manager.dart
// Line 9-10, 17-18, 61-71 제거

// 제거할 import
- import 'package:sherpa_app/shared/providers/global_sherpi_provider.dart'
-     show PersonalizationSettings;

// 제거할 필드와 메서드
- PersonalizationSettings _personalizationSettings = const PersonalizationSettings();
- void setPersonalizationSettings(PersonalizationSettings settings) { ... }
```
**예상 시간**: 30분
**검증**: `flutter analyze | grep PersonalizationSettings` → 결과 없음

#### 🔴 P0-3: 기본 검증
```bash
# 실행 명령
flutter analyze
flutter test test/features/sherpi/
flutter run --debug
```
**예상 시간**: 30분
**통과 기준**: 컴파일 에러 0, 기존 테스트 통과

---

## 📅 Sprint Planning

### Sprint 1: Foundation (Day 1-2)

#### 목표
- Logger 시스템 구축
- Print 문 완전 제거
- 기본 안정성 확보

#### 작업 목록

##### S1-1: Logger 시스템 도입
```yaml
dependencies:
  logger: ^2.0.0  # pubspec.yaml 추가
```

```dart
// lib/core/utils/logger_service.dart (신규)
import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(String message) => _logger.d(message);
  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}

// 프로덕션 빌드시 로그 레벨 조정
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= Level.warning.index;
  }
}
```

##### S1-2: Print 문 일괄 교체
```bash
# 자동화 스크립트
find lib -name "*.dart" -exec sed -i "s/print('✅/LoggerService.info('/g" {} \;
find lib -name "*.dart" -exec sed -i "s/print('❌/LoggerService.error('/g" {} \;
find lib -name "*.dart" -exec sed -i "s/print('⚠️/LoggerService.warning('/g" {} \;
find lib -name "*.dart" -exec sed -i "s/print(/LoggerService.debug(/g" {} \;
```

**영향 파일**: 50+ 파일
**예상 시간**: 4시간
**산출물**: LoggerService 구현, 모든 print 문 제거
**검증**: `grep -r "print(" lib/ | wc -l` → 0

##### S1-3: 기본 단위 테스트
```dart
// test/core/ai/services/ai_insight_generator_test.dart (신규)
void main() {
  group('AiInsightGenerator Tests', () {
    test('Should throw exception when insufficient points', () async {
      // 포인트 부족 시나리오 테스트
    });

    test('Should deduct points on successful analysis', () async {
      // 포인트 차감 확인 테스트
    });

    test('Should refund points on analysis failure', () async {
      // 실패시 포인트 환불 테스트
    });
  });
}
```

**예상 시간**: 4시간
**산출물**: 10+ 단위 테스트
**검증**: `flutter test --coverage`

---

### Sprint 2: Clean Up (Week 1)

#### 목표
- 레거시 코드 완전 제거
- 코드 정리 및 최적화
- 문서 정합성 확보

#### 작업 목록

##### S2-1: 레거시 코드 제거
```bash
# 제거 대상
rm -rf lib/core/ai/managers/legacy/
# 800+ lines 제거

# 의존성 확인 및 수정
grep -r "legacy/smart_sherpi" lib/
# lib/features/sherpi/chat/providers/* 에서 참조 수정
```

**영향도**: HIGH (채팅 기능 영향)
**예상 시간**: 8시간
**위험 관리**: 채팅 기능 별도 테스트 필수

##### S2-2: Unused Imports 정리
```bash
# 자동 정리
dart fix --apply
flutter analyze | grep "unused" | awk '{print $NF}' | xargs -I {} dart fix --apply {}
```

**영향 파일**: 20+ 파일
**예상 시간**: 2시간
**검증**: `flutter analyze | grep unused | wc -l` → 0

##### S2-3: 문서 업데이트
- `docs/sherpi_system.md` - enableAIForNextMessage 제거
- `codex/ai_sherpi_progress_status.md` - debugForceAI 제거
- 새 아키텍처 다이어그램 추가

**예상 시간**: 4시간
**산출물**: 3+ 문서 업데이트

---

### Sprint 3: Quality Improvement (Week 2)

#### 목표
- 테스트 커버리지 60% 달성
- 에러 처리 강화
- 성능 최적화

#### 작업 목록

##### S3-1: 테스트 커버리지 확대
```dart
// 필수 테스트 영역
- AI 초기화: 5 tests
- 포인트 시스템: 8 tests
- 캐시 동작: 5 tests
- 메시지 매니저: 10 tests
- UI 컴포넌트: 12 tests
```

**목표**: 40개 신규 테스트
**예상 시간**: 16시간
**검증**: `flutter test --coverage` → 60%+

##### S3-2: 에러 처리 개선
```dart
// 표준 에러 처리 패턴
class AIServiceException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;

  AIServiceException({
    required this.message,
    required this.code,
    this.originalError,
  });
}

// 사용 예시
try {
  await _openAISource.getDialogue(...);
} on OpenAIException catch (e) {
  throw AIServiceException(
    message: '분석 서비스 일시 장애',
    code: 'AI_SERVICE_ERROR',
    originalError: e,
  );
}
```

**예상 시간**: 8시간
**산출물**: 통합 에러 처리 시스템

##### S3-3: 성능 프로파일링
```dart
// 성능 측정 포인트
- AI 응답 시간: < 3초
- 캐시 히트율: > 60%
- 메모리 사용량: < 200MB
- 앱 시작 시간: < 2초
```

**도구**: Flutter DevTools, Performance Overlay
**예상 시간**: 8시간
**산출물**: 성능 보고서, 최적화 권장사항

---

### Sprint 4: Architecture Enhancement (Week 3-4)

#### 목표
- 매니저 책임 분리
- Repository 패턴 도입
- CI/CD 파이프라인 구축

#### 작업 목록

##### S4-1: 매니저 리팩토링
```dart
// 현재: 단일 책임 원칙 위반
class OpenAISherpiManager { /* 모든 것 처리 */ }

// 개선: 책임 분리
class AISherpiService {
  // AI 관련 로직만
  Future<String> generateResponse(context, params);
}

class StaticMessageProvider {
  // 정적 메시지만
  String getStaticMessage(context);
}

class SherpiOrchestrator {
  // 조율 및 결정
  final AISherpiService _aiService;
  final StaticMessageProvider _staticProvider;

  Future<SherpiResponse> getMessage(context) {
    if (shouldUseAI(context)) {
      return _aiService.generateResponse(context);
    }
    return _staticProvider.getStaticMessage(context);
  }
}
```

**예상 시간**: 16시간
**영향도**: HIGH (전체 시스템)

##### S4-2: Repository 패턴
```dart
abstract class SherpiRepository {
  Future<SherpiResponse> getMessage(SherpiContext context);
  Future<void> saveMessage(SherpiMessage message);
  Future<List<SherpiMessage>> getHistory();
}

class SherpiRepositoryImpl implements SherpiRepository {
  final RemoteDataSource _remote;
  final LocalDataSource _local;
  final CacheManager _cache;

  // 구현...
}
```

**예상 시간**: 12시간
**산출물**: Clean Architecture 레이어

##### S4-3: CI/CD 파이프라인
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --debug

  quality:
    runs-on: ubuntu-latest
    steps:
      - name: Code Coverage Check
        run: |
          coverage=$(cat coverage/lcov.info | ...)
          if [ $coverage -lt 60 ]; then exit 1; fi
```

**예상 시간**: 8시간
**산출물**: 자동화된 품질 검증

---

## 📊 Risk Mitigation

### 위험 요소 및 대응 방안

| 위험 | 확률 | 영향 | 대응 방안 |
|------|------|------|-----------|
| **레거시 제거시 기능 손상** | 높음 | 높음 | 단계적 제거, 충분한 테스트 |
| **포인트 시스템 버그** | 중간 | 높음 | 롤백 메커니즘, A/B 테스트 |
| **성능 저하** | 낮음 | 중간 | 프로파일링, 점진적 최적화 |
| **일정 지연** | 중간 | 중간 | 버퍼 시간, 우선순위 조정 |

---

## 📈 Success Metrics

### 주간 체크포인트

#### Week 1 완료 기준
- [ ] Sprint 0 긴급 수정 완료
- [ ] Logger 시스템 구현
- [ ] Print 문 0개
- [ ] 기본 테스트 10개+
- [ ] flutter analyze errors: 0

#### Week 2 완료 기준
- [ ] 레거시 코드 제거
- [ ] Warnings < 10
- [ ] 테스트 커버리지 45%+
- [ ] 문서 업데이트 완료

#### Week 3 완료 기준
- [ ] 테스트 커버리지 60%+
- [ ] 에러 처리 시스템 구축
- [ ] 성능 벤치마크 완료
- [ ] 코드 품질 점수 80+

#### Week 4 완료 기준
- [ ] 아키텍처 개선 완료
- [ ] 테스트 커버리지 70%+
- [ ] CI/CD 파이프라인 구동
- [ ] 프로덕션 준비도 90%+

---

## 🔧 Resource Requirements

### 팀 구성 (권장)
- **리드 개발자**: 1명 (아키텍처, 코드 리뷰)
- **개발자**: 2명 (구현, 테스트)
- **QA**: 1명 (테스트, 검증)

### 도구 및 환경
- **필수**: Flutter 3.27.0+, Dart 3.5+
- **Logger**: logger ^2.0.0
- **테스트**: mockito, flutter_test
- **CI/CD**: GitHub Actions
- **모니터링**: Firebase Crashlytics

### 예상 총 소요 시간
- **Sprint 0**: 4시간
- **Sprint 1**: 16시간 (2일)
- **Sprint 2**: 40시간 (1주)
- **Sprint 3**: 40시간 (1주)
- **Sprint 4**: 60시간 (1.5주)
- **총계**: 160시간 (4주, 1-2명 기준)

---

## 📝 Monitoring & Reporting

### 일일 체크인
```markdown
## Daily Standup (YYYY-MM-DD)
- **완료**: [작업 목록]
- **진행중**: [작업 목록]
- **블로커**: [이슈 목록]
- **메트릭**: Coverage X%, Warnings Y개
```

### 주간 보고
```markdown
## Weekly Report (Week N)
- **Sprint 목표 달성률**: X%
- **코드 품질 점수**: X/100
- **테스트 커버리지**: X%
- **기술 부채 감소**: Xh
- **주요 성과**: [목록]
- **다음 주 계획**: [목록]
```

### 최종 검증 체크리스트
- [ ] 모든 Critical Issues 해결
- [ ] 테스트 커버리지 70%+
- [ ] 성능 목표 달성
- [ ] 문서 완전성
- [ ] 프로덕션 배포 준비

---

## 🎯 결론

본 계획을 통해 4주 내에 AI/Sherpi 시스템의 코드 품질을 **65점에서 85점**으로, 프로덕션 준비도를 **45%에서 90%**로 향상시킬 수 있습니다.

**핵심 성공 요인**:
1. **Sprint 0** 긴급 수정으로 즉각적인 안정성 확보
2. **단계적 접근**으로 리스크 최소화
3. **측정 가능한 목표**로 진행 상황 추적
4. **자동화**를 통한 품질 유지

**시작 신호**: Sprint 0를 **즉시 시작**하여 4시간 내 Critical Issues를 해결하세요.

---

**작성**: Claude AI with Sequential Thinking
**기반 문서**:
- AI_SHERPI_CODE_REVIEW_20250920.md (Codex)
- AI_SHERPI_COMPREHENSIVE_CODE_REVIEW_20250920.md (Claude)

**다음 단계**: Sprint 0 실행 → 일일 체크인 시작 → 주간 리뷰 실시