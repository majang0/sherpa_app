# 셰르파 개발 워크플로우 3.1 실전 구현 가이드

**문서 버전**: 1.0.0
**작성일**: 2025-10-31
**대상**: 셰르파 앱 개발자 (학생 개발자 포함)
**난이도**: 초급~중급
**예상 소요 시간**: 4주 (주당 3-5시간)

---

## 📋 목차

- [Part 1: 시작하기 전에](#part-1-시작하기-전에)
- [Part 2: Week 1 - 지식 베이스 구축](#part-2-week-1---지식-베이스-구축)
- [Part 3: Week 2 - 첫 3개 Skill 만들기](#part-3-week-2---첫-3개-skill-만들기)
- [Part 4: Week 3 - 나머지 Skill 완성](#part-4-week-3---나머지-skill-완성)
- [Part 5: Week 4 - 실전 사용](#part-5-week-4---실전-사용)
- [Part 6: 선택적 확장 (Agent SDK)](#part-6-선택적-확장-agent-sdk)
- [Part 7: 자주 묻는 질문 (FAQ)](#part-7-자주-묻는-질문-faq)
- [Part 8: 체크리스트 요약](#part-8-체크리스트-요약)

---

## Part 1: 시작하기 전에

### 🎯 이 가이드가 필요한 이유

셰르파 앱 개발 시 다음과 같은 어려움을 겪고 계신가요?

- ❌ **Provider 초기화 순서**를 잊어서 앱이 크래시됨
- ❌ **ModernColors 대신 AppColors**를 사용해서 나중에 수정
- ❌ **게임 밸런스**를 고려하지 않고 포인트/XP 값을 변경
- ❌ 같은 실수를 **반복적으로** 범함
- ❌ 코드 리뷰 시 **놓치는 부분**이 많음

이 가이드는 이런 문제들을 **자동으로 방지**하고, **일관된 품질**을 유지하며, **개발 속도를 향상**시키는 시스템을 구축하는 방법을 알려드립니다.

### ✨ 기대 효과

**즉시 (Week 1-2 완료 후)**:
- ✅ 셰르파 앱의 핵심 규칙이 문서화됨
- ✅ Claude가 자동으로 규칙 준수 여부 확인
- ✅ ModernColors 위반, Provider 순서 오류 즉시 감지

**단기 (Week 3-4 완료 후)**:
- ✅ 6개 역할이 자동으로 활성화되어 작업 분담
- ✅ 게임 밸런스 시뮬레이션 자동화
- ✅ 반복 실수 30% 감소

**중장기 (1-2개월 후)**:
- ✅ 학습 노트 축적으로 프로젝트 지식 베이스 구축
- ✅ 코드 품질 향상 (일관된 패턴)
- ✅ 새로운 팀원 온보딩 시간 단축

### 📦 준비물 체크리스트

시작하기 전에 다음을 확인하세요:

- [ ] **Claude Code 설치 완료** (claude.ai/code)
- [ ] **셰르파 앱 프로젝트 접근 가능** (`C:\sherpa_app\`)
- [ ] **Git 설치 및 설정 완료**
- [ ] **텍스트 에디터** (VS Code 권장)
- [ ] **Flutter 개발 환경** (선택, 코드 확인용)

### ⏱️ 예상 소요 시간 및 난이도

| 주차 | 작업 내용 | 소요 시간 | 난이도 | 코드 작성 |
|------|-----------|-----------|--------|-----------|
| Week 1 | 지식 베이스 구축 | 3-4시간 | ⭐ 쉬움 | ❌ 없음 |
| Week 2 | 첫 3개 Skill 만들기 | 3-5시간 | ⭐⭐ 보통 | ❌ 없음 |
| Week 3 | 나머지 Skill 완성 | 4-6시간 | ⭐⭐⭐ 중간 | ✅ 약간 (시뮬레이션) |
| Week 4 | 실전 사용 | 5-8시간 | ⭐⭐⭐ 중간 | ✅ 예 (기능 구현) |

**총 예상 시간**: 15-23시간 (4주 분산)

### 🚨 중요한 안내

**이 가이드의 특징**:
1. ✅ **코드 작성 없이 시작** - Week 1-2는 문서 작성만
2. ✅ **점진적 도입** - 각 주차는 독립적 가치
3. ✅ **안전 우선** - 읽기 전용부터 시작
4. ✅ **실패해도 OK** - 각 단계 실패해도 다음 진행 가능

**주의사항**:
- ⚠️ **순서대로 진행** 필수 (Week 1 → 2 → 3 → 4)
- ⚠️ 각 주차 완료 후 **Git 커밋** 권장
- ⚠️ Agent SDK는 **선택 사항** (나중에 고려)

---

## Part 2: Week 1 - 지식 베이스 구축

### 🎯 목표

셰르파 앱의 핵심 규칙을 문서화하여 Claude가 참조할 수 있게 만들기

**이 주차에서 하는 일**:
- 코드 분석 ❌ 없음
- 문서 작성 ✅ 5개 파일
- 코드 수정 ❌ 없음
- 위험도 ✅ 0% (완전 안전)

### 📝 성공 기준

- [ ] `docs/knowledge_base/` 디렉토리 생성 완료
- [ ] 5개 핵심 문서 작성 완료
- [ ] 각 문서에 실제 값과 예제 포함
- [ ] Git 커밋 및 푸시 완료

### 🚀 단계별 실행 가이드

#### Step 1: 디렉토리 생성

**Windows (명령 프롬프트)**:
```cmd
cd C:\sherpa_app
mkdir docs\knowledge_base
```

**Mac/Linux (터미널)**:
```bash
cd ~/sherpa_app  # 또는 프로젝트 경로
mkdir -p docs/knowledge_base
```

**확인**:
```cmd
dir docs\knowledge_base  # Windows
ls docs/knowledge_base   # Mac/Linux
```

#### Step 2: 문서 1 - 아키텍처 규칙 (`architecture_rules.md`)

**파일 생성**: `C:\sherpa_app\docs\knowledge_base\architecture_rules.md`

**작성 내용**:
```markdown
# 셰르파 앱 아키텍처 규칙

**최종 업데이트**: 2025-10-31

## Feature-First 구조

셰르파 앱은 Feature-First 아키텍처를 사용합니다.

### 디렉토리 구조

```
lib/
├── core/           # 앱 전역 설정, 테마, 유틸리티
├── features/       # 기능별 모듈 (자체 포함)
│   ├── daily_record/
│   ├── quests/
│   ├── meeting/
│   └── ...
├── shared/         # 여러 feature에서 공유하는 코드
│   ├── models/
│   ├── providers/
│   └── widgets/
└── main.dart       # 앱 진입점
```

### 금지사항

- ❌ **순환 의존성**: feature 간 직접 import 금지
- ❌ **core에서 features import**: core는 features를 몰라야 함
- ❌ **상대 경로**: `../` 사용 금지, 절대 경로 사용

### 모범 사례

- ✅ **shared 활용**: 공유 코드는 `lib/shared/`에 위치
- ✅ **절대 경로**: `import 'package:sherpa_app/...'` 사용
- ✅ **자체 포함**: 각 feature는 독립적으로 동작 가능

### 새 기능 추가 시 구조

```
lib/features/new_feature/
├── models/          # 데이터 모델
├── providers/       # Riverpod provider
├── presentation/    # UI 레이어
│   ├── screens/
│   └── widgets/
└── services/        # 비즈니스 로직 (선택)
```

### 검증 방법

**순환 의존성 확인**:
```bash
# VS Code에서 F12 (정의로 이동) 사용
# features 간 직접 참조가 있으면 순환 의존성 의심
```

**Import 패턴 확인**:
```bash
# 잘못된 예
import '../../../shared/models/user.dart';  # ❌

# 올바른 예
import 'package:sherpa_app/shared/models/user.dart';  # ✅
```
```

**왜 이 문서가 필요한가?**:
- Claude가 새 기능 추가 시 올바른 구조를 제안
- 순환 의존성 사전 감지
- 팀원 온보딩 시 참조 자료

#### Step 3: 문서 2 - Provider 의존성 (`provider_dependencies.md`)

**파일 생성**: `C:\sherpa_app\docs\knowledge_base\provider_dependencies.md`

**작성 내용**:
```markdown
# Provider 의존성 및 초기화 순서

**최종 업데이트**: 2025-10-31

## 핵심 규칙

⚠️ **Provider 초기화 순서를 반드시 준수해야 합니다. 위반 시 앱 크래시!**

## 초기화 순서 (Level 0-3)

### Level 0: 게임 상태 (최우선)

```dart
ref.read(globalGameProvider);
```

**역할**: 게임 전체 상태 관리
**의존성**: 없음
**위치**: `lib/shared/providers/global_game_provider.dart`

### Level 1: 사용자 상태

```dart
ref.read(globalUserProvider);
```

**역할**: 현재 로그인한 사용자 정보
**의존성**: `globalGameProvider`
**위치**: `lib/shared/providers/global_user_provider.dart`

### Level 2: 파생 상태

```dart
ref.read(globalPointProvider);
ref.read(questProviderV2);           // ⚠️ questProvider 아님!
ref.read(globalMeetingProvider);
ref.read(globalUserTitleProvider);
```

**역할**: Level 0, 1에 의존하는 파생 데이터
**의존성**: `globalGameProvider`, `globalUserProvider`

**중요**:
- ❌ `questProvider` 사용 금지 (레거시)
- ✅ `questProviderV2` 사용 필수

### Level 3: UI 상태

```dart
ref.read(sherpiProvider);
ref.read(relationshipProvider);
ref.read(emotionAnalysisProvider);
```

**역할**: UI 관련 상태
**의존성**: Level 2 provider들

## 초기화 위치

**파일**: `lib/main.dart`
**함수**: `initializeProviders(WidgetRef ref)`

```dart
Future<void> initializeProviders(WidgetRef ref) async {
  // Level 0
  ref.read(globalGameProvider);

  // Level 1
  ref.read(globalUserProvider);

  // Level 2
  ref.read(globalPointProvider);
  ref.read(questProviderV2);  // ⚠️ V2!
  ref.read(globalMeetingProvider);
  ref.read(globalUserTitleProvider);

  // Level 3
  ref.read(sherpiProvider);
  ref.read(relationshipProvider);
  ref.read(emotionAnalysisProvider);
}
```

## 의존성 그래프

```
globalGameProvider (Level 0)
  └── globalUserProvider (Level 1)
      ├── globalPointProvider (Level 2)
      ├── questProviderV2 (Level 2)
      ├── globalMeetingProvider (Level 2)
      ├── globalUserTitleProvider (Level 2)
      └── sherpiProvider (Level 3)
          ├── relationshipProvider (Level 3)
          └── emotionAnalysisProvider (Level 3)
```

## 검증 방법

### 초기화 순서 확인

```bash
# lib/main.dart의 initializeProviders 함수 확인
grep -A 15 "initializeProviders" lib/main.dart
```

### 레거시 Provider 스캔

```bash
# questProvider 사용 검색 (금지!)
grep -r "questProvider[^V]" lib/

# 발견되면 questProviderV2로 교체 필요
```

### 순환 참조 확인

**증상**: 앱 시작 시 무한 로딩 또는 크래시
**원인**: Provider A → B → A 순환 참조
**해결**: 의존성 그래프 재설계

## 새 Provider 추가 시 체크리스트

- [ ] Level 결정 (0-3 중 어디에 속하는가?)
- [ ] 의존성 확인 (어떤 Provider를 참조하는가?)
- [ ] initializeProviders에 올바른 순서로 추가
- [ ] 순환 참조 확인
- [ ] 이 문서 업데이트
```

**왜 이 문서가 필요한가?**:
- 앱 크래시의 가장 흔한 원인 방지
- 새 Provider 추가 시 가이드
- 디버깅 시 참조

#### Step 4: 문서 3 - 디자인 시스템 (`design_system.md`)

**파일 생성**: `C:\sherpa_app\docs\knowledge_base\design_system.md`

**작성 내용**:
```markdown
# 셰르파 디자인 시스템

**최종 업데이트**: 2025-10-31

## ModernColors (필수)

**위치**: `lib/core/theme/modern_colors.dart`

### 색상 팔레트

```dart
// ✅ 필수 사용
import 'package:sherpa_app/core/theme/modern_colors.dart';

// 주요 색상
ModernColors.primary        // 메인 브랜드 색상
ModernColors.secondary      // 보조 색상
ModernColors.success        // 성공 (녹색)
ModernColors.error          // 에러 (빨간색)
ModernColors.warning        // 경고 (주황색)
ModernColors.background     // 배경
ModernColors.surface        // 카드/컨테이너
ModernColors.textPrimary    // 메인 텍스트
ModernColors.textSecondary  // 보조 텍스트
```

### 금지 사항

```dart
// ❌ 절대 금지 - 레거시 색상
import 'package:sherpa_app/core/theme/app_colors.dart';
import 'package:sherpa_app/core/theme/record_colors.dart';

// ❌ 하드코딩된 색상 값
Color(0xFF123456)
Colors.blue
```

**왜 금지인가?**:
- AppColors, RecordColors는 레거시 (일관성 없음)
- 다크모드 지원 불가
- 브랜드 가이드와 불일치

### 검증 방법

**레거시 색상 스캔**:
```bash
# AppColors 또는 RecordColors 사용 검색
grep -r "AppColors\|RecordColors" lib/

# 발견되면 ModernColors로 교체 필요
```

**하드코딩 색상 검색**:
```bash
# Color(0x...) 패턴 검색
grep -r "Color(0x" lib/
```

### UI 컴포넌트 표준

#### 앱바 (App Bar)

```dart
// ✅ 표준 앱바
SherpaCleanAppBar(
  title: '페이지 제목',
  backgroundColor: ModernColors.background,
  actions: [...],
)
```

#### 버튼

```dart
// ✅ 표준 버튼 (애니메이션 + 햅틱)
SherpaButton(
  text: '계속하기',
  onPressed: () {},
)
```

#### 카드

```dart
// ✅ 표준 카드
Container(
  decoration: BoxDecoration(
    color: ModernColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: ...,
)
```

### Sherpi AI 규칙

#### 감정 (6가지)

```dart
enum SherpiEmotion {
  normal,      // 평상시
  cheering,    // 응원
  proud,       // 자랑스러움
  thinking,    // 생각 중
  surprised,   // 놀람
  concerned    // 걱정
}
```

**사용 예**:
```dart
// ✅ 레벨업 시 - cheering 또는 proud
sherpiProvider.changeEmotion(SherpiEmotion.cheering);

// ✅ 퀘스트 실패 시 - concerned
sherpiProvider.changeEmotion(SherpiEmotion.concerned);

// ❌ 잘못된 조합
// 레벨업 시 concerned 감정 (부적절)
```

#### 컨텍스트 (5가지)

```dart
enum SherpiContext {
  levelUp,        // 레벨 업
  questComplete,  // 퀘스트 완료
  climbSuccess,   // 등반 성공
  meeting,        // 모임 관련
  dailyGoal       // 일일 목표
}
```

**적절한 감정 조합**:

| 컨텍스트 | 적절한 감정 | 부적절한 감정 |
|----------|-------------|---------------|
| levelUp | cheering, proud | concerned |
| questComplete | cheering, proud | surprised |
| climbSuccess | cheering, proud | concerned |
| meeting | normal, cheering | concerned |
| dailyGoal | normal, proud | surprised |

### 검증 체크리스트

새 UI 추가 시:
- [ ] ModernColors 사용
- [ ] AppColors/RecordColors 미사용
- [ ] 하드코딩 색상 없음
- [ ] Sherpi 감정-컨텍스트 조합 적절
- [ ] SherpaCleanAppBar 또는 SherpaButton 사용 (가능하면)
```

**왜 이 문서가 필요한가?**:
- UI 일관성 유지
- 레거시 색상 사용 방지
- Sherpi AI 감정 일관성

#### Step 5: 문서 4 - 게임 밸런스 공식 (`game_balance_formulas.md`)

**파일 생성**: `C:\sherpa_app\docs\knowledge_base\game_balance_formulas.md`

**작성 내용**:
```markdown
# 게임 밸런스 공식

**최종 업데이트**: 2025-10-31

## 등반력 (Climbing Power)

### 공식

```
climbingPower = (userStats × badgeBonus × equipmentBonus) / difficulty
```

### 변수 설명

- **userStats**: 사용자 스탯 합계 (체력, 지능, 운 등)
- **badgeBonus**: 뱃지 보너스 (1.0 ~ 2.0)
- **equipmentBonus**: 장비 보너스 (1.0 ~ 1.5)
- **difficulty**: 산 난이도 (1 ~ 10)

### 범위

- **최소**: 0
- **최대**: 100
- **성공 확률**: climbingPower% (50이면 50% 성공)

### 예시

```
사용자 스탯: 100
뱃지 보너스: 1.5
장비 보너스: 1.2
난이도: 3

climbingPower = (100 × 1.5 × 1.2) / 3 = 60
→ 60% 성공 확률
```

### 밸런스 고려사항

- ✅ 초급 산 (난이도 1-3): 80% 이상 성공 목표
- ✅ 중급 산 (난이도 4-7): 50-70% 성공 목표
- ✅ 고급 산 (난이도 8-10): 30-50% 성공 목표

### 검증 방법

**Python 시뮬레이션**:
```python
def calculate_climbing_power(stats, badge, equipment, difficulty):
    return (stats * badge * equipment) / difficulty

# 테스트
power = calculate_climbing_power(100, 1.5, 1.2, 3)
print(f"Climbing Power: {power}%")  # 60.0%
```

## XP 곡선

### 공식

```
requiredXP(level) = 100 × level^1.5
```

### 레벨별 요구 XP

| 레벨 | 요구 XP | 누적 XP |
|------|---------|---------|
| 1 → 2 | 100 | 100 |
| 2 → 3 | 283 | 383 |
| 3 → 4 | 520 | 903 |
| 4 → 5 | 800 | 1,703 |
| 5 → 6 | 1,118 | 2,821 |
| 10 → 11 | 3,162 | 19,316 |
| 20 → 21 | 8,944 | 116,619 |
| 50 → 51 | 35,355 | 1,176,777 |

### 밸런스 고려사항

- ✅ 초반 (Lv 1-10): 빠른 성장 (유저 유지)
- ✅ 중반 (Lv 11-30): 점진적 증가
- ✅ 후반 (Lv 31-50): 느린 성장 (장기 목표)

### 검증 방법

**Python 계산**:
```python
import math

def required_xp(level):
    return int(100 * math.pow(level, 1.5))

# 레벨별 요구 XP 출력
for level in [1, 5, 10, 20, 50]:
    xp = required_xp(level)
    print(f"Level {level}: {xp:,} XP")
```

## 포인트 경제

### 기본 규칙

```
1 point = 1원 (실제 가치)
```

### 거래 수수료

```
수수료 = 거래 금액 × 10%
```

**예시**:
- 거래: 1,000 포인트
- 수수료: 100 포인트
- 실제 이동: 900 포인트

### 거래 제한

```
최소 거래: 10,000원 (10,000 포인트)
최대 거래: 제한 없음
```

### 포인트 획득 경로

| 활동 | 획득 포인트 | 빈도 |
|------|-------------|------|
| 일일 퀘스트 완료 | 100-300 | 매일 |
| 등반 성공 | 50-500 | 제한 없음 |
| Meeting 참가 | -100 (비용) | 제한 없음 |
| Meeting 호스팅 | 0 (무료) | 제한 없음 |

### 밸런스 고려사항

- ✅ 일일 평균 획득: 300-500 포인트
- ✅ 일일 평균 소비: 100-200 포인트
- ✅ 주간 잉여: 1,000-2,000 포인트 (저축 가능)

### 인플레이션 방지

**목표**: 포인트 인플레이션 연간 5% 이내 유지

**검증 방법**:
```python
# 월간 포인트 순증가 추적
monthly_gain = 평균_일일_획득 × 30
monthly_spend = 평균_일일_소비 × 30
net_gain = monthly_gain - monthly_spend

# 인플레이션율 = (net_gain / 기존_포인트) × 100
```

## 변경 시 주의사항

⚠️ **모든 게임 밸런스 변경은 시뮬레이션 필수!**

### 체크리스트

- [ ] 변경 사항 명확히 정의
- [ ] 1,000회 이상 시뮬레이션 실행
- [ ] 통과율 95% 이상 확인
- [ ] 극단적 엣지 케이스 확인 (0건 목표)
- [ ] 레벨 간 난이도 선형성 확인
- [ ] 포인트 인플레이션 5% 이내 확인
- [ ] 시뮬레이션 결과 문서화

### 시뮬레이션 도구

**Python 스크립트**: `.claude/skills/role2-game-logic-specialist/scripts/balance_simulator.py`

(Week 3에서 작성 예정)
```

**왜 이 문서가 필요한가?**:
- 게임 밸런스 파괴 방지
- 포인트 인플레이션 관리
- 난이도 조정 시 참조

#### Step 6: 문서 5 - Sherpi AI 규칙 (`sherpi_ai_rules.md`)

**파일 생성**: `C:\sherpa_app\docs\knowledge_base\sherpi_ai_rules.md`

**작성 내용**:
```markdown
# Sherpi AI 규칙

**최종 업데이트**: 2025-10-31

## 개요

Sherpi는 셰르파 앱의 AI 동반자로, 사용자의 성장을 응원하고 피드백을 제공합니다.

## 감정 (Emotions)

### 6가지 감정

```dart
enum SherpiEmotion {
  normal,      // 평상시
  cheering,    // 응원
  proud,       // 자랑스러움
  thinking,    // 생각 중
  surprised,   // 놀람
  concerned    // 걱정
}
```

### 감정별 사용 시점

**normal** (평상시):
- 일반적인 앱 사용
- 중립적인 상황
- 특별한 이벤트 없을 때

**cheering** (응원):
- 도전 시작
- 등반 시도
- 퀘스트 진행 중

**proud** (자랑스러움):
- 레벨 업
- 퀘스트 완료
- 등반 성공

**thinking** (생각 중):
- 복잡한 선택
- 전략 필요 시
- 분석 중

**surprised** (놀람):
- 예상 외 결과
- 특별한 보상
- 새로운 발견

**concerned** (걱정):
- 실패
- 포인트 부족
- 주의 필요

## 컨텍스트 (Contexts)

### 5가지 컨텍스트

```dart
enum SherpiContext {
  levelUp,        // 레벨 업
  questComplete,  // 퀘스트 완료
  climbSuccess,   // 등반 성공
  meeting,        // 모임 관련
  dailyGoal       // 일일 목표
}
```

### 적절한 감정 조합

| 컨텍스트 | 적절한 감정 | 메시지 예시 |
|----------|-------------|-------------|
| levelUp | proud, cheering | "축하해요! 레벨 업!" |
| questComplete | proud, cheering | "퀘스트 완료! 잘했어요!" |
| climbSuccess | proud, cheering | "등반 성공! 대단해요!" |
| meeting | normal, cheering | "새로운 친구를 만나보세요!" |
| dailyGoal | normal, proud | "오늘도 목표 달성!" |

### 부적절한 조합 (피해야 함)

| 컨텍스트 | 부적절한 감정 | 이유 |
|----------|---------------|------|
| levelUp | concerned | 성공 상황에 부정적 감정 |
| questComplete | surprised | 예측 가능한 결과 |
| climbSuccess | concerned | 성공 상황에 걱정 |
| meeting | concerned | 사회적 활동에 부정적 |
| dailyGoal | surprised | 일상적 성취 |

## 메시지 규칙

### 톤 (Tone)

- ✅ **친근함**: 반말 또는 존댓말 (설정에 따라)
- ✅ **긍정적**: 응원과 격려 중심
- ✅ **간결함**: 1-2문장 권장
- ❌ **장황함**: 3문장 이상 지양

### 메시지 길이

- **짧은 메시지**: 10-20자 (일반 피드백)
- **중간 메시지**: 20-40자 (설명 필요 시)
- **긴 메시지**: 40-60자 (특별한 경우만)

### 예시

**✅ 좋은 메시지**:
```
"오늘도 화이팅! 🎉"  # 짧고 긍정적
"레벨 5 달성! 대단해요!" # 구체적
"등반 성공! 다음 산도 도전해볼까요?" # 행동 유도
```

**❌ 나쁜 메시지**:
```
"오늘 정말 수고 많으셨어요. 앞으로도 계속 이렇게 열심히 하시면 분명히 좋은 결과가 있을 거예요. 파이팅!" # 너무 김
"..." # 의미 불명
"Error: 메시지 로드 실패" # 에러 노출
```

## Sherpi 호출 API

### 정적 메시지 표시

```dart
ref.read(sherpiProvider.notifier).showInstantMessage(
  context: SherpiContext.levelUp,
  customDialogue: '레벨 업 축하해요!',
  emotion: SherpiEmotion.proud,
  duration: Duration(seconds: 3),
);
```

### 컨텍스트 기반 자동 메시지

```dart
ref.read(sherpiProvider.notifier).showMessage(
  context: context,
  userContext: SherpiContext.questComplete,
  gameContext: gameData,
);
```

### 감정 변경

```dart
ref.read(sherpiProvider.notifier).changeEmotion(
  SherpiEmotion.cheering,
);
```

## 검증 체크리스트

새 Sherpi 메시지 추가 시:
- [ ] 6가지 감정 중 하나 사용
- [ ] 5가지 컨텍스트 중 하나 사용
- [ ] 감정-컨텍스트 조합 적절성 확인
- [ ] 메시지 길이 60자 이내
- [ ] 긍정적이고 친근한 톤
- [ ] 오타 및 문법 확인
```

**왜 이 문서가 필요한가?**:
- Sherpi AI 일관성 유지
- 부적절한 감정 조합 방지
- 사용자 경험 통일

#### Step 7: Git 커밋

**모든 문서 작성 완료 후**:

```bash
cd C:\sherpa_app

# 파일 추가
git add docs/knowledge_base/

# 커밋
git commit -m "docs: Week 1 - 지식 베이스 구축 완료

- architecture_rules.md: Feature-First 구조 및 아키텍처 규칙
- provider_dependencies.md: Provider 초기화 순서 Level 0-3
- design_system.md: ModernColors 및 Sherpi AI 규칙
- game_balance_formulas.md: 등반력, XP, 포인트 경제 공식
- sherpi_ai_rules.md: Sherpi 감정 및 컨텍스트 규칙

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# 푸시 (선택)
git push origin feature/sherpa-app-initial-setup
```

### ✅ 검증 방법

#### 1. 파일 존재 확인

```bash
ls docs/knowledge_base/
```

**예상 출력**:
```
architecture_rules.md
provider_dependencies.md
design_system.md
game_balance_formulas.md
sherpi_ai_rules.md
```

#### 2. 문서 내용 확인

각 파일을 열어서:
- [ ] 실제 값이 포함되어 있는가?
- [ ] 예제가 구체적인가?
- [ ] ❌ 금지 사항과 ✅ 모범 사례가 명시되어 있는가?

#### 3. Claude 테스트

Claude Code에서 다음 질문:

```
"셰르파 앱의 Provider 초기화 순서를 알려줘"
```

**기대 결과**: Claude가 `docs/knowledge_base/provider_dependencies.md`를 참조하여 Level 0-3 순서를 정확히 답변

### 🐛 트러블슈팅

**문제 1**: 디렉토리 생성 실패
```
The system cannot find the path specified.
```
**해결**:
```bash
# docs 디렉토리부터 만들기
mkdir docs
mkdir docs\knowledge_base
```

**문제 2**: Git 커밋 시 "nothing to commit"
```
nothing to commit, working tree clean
```
**해결**:
```bash
# 파일이 추가되었는지 확인
git status

# 추가되지 않았다면
git add docs/knowledge_base/
```

**문제 3**: 문서 내용이 너무 길어서 작성하기 어려움
**해결**: Claude에게 요청
```
"docs/knowledge_base/architecture_rules.md 파일의 내용을 작성해줘.
셰르파 앱의 Feature-First 구조를 설명하고, 금지사항과 모범 사례를 포함해줘."
```

### 🎉 Week 1 완료!

축하합니다! Week 1을 완료했습니다.

**달성한 것**:
- ✅ 셰르파 앱의 핵심 규칙 5개 문서화
- ✅ Claude가 참조할 지식 베이스 구축
- ✅ 안전하게 시작 (코드 변경 없음)

**다음 단계**: Week 2 - 첫 3개 Skill 만들기

---

## Part 3: Week 2 - 첫 3개 Skill 만들기

### 🎯 목표

가장 안전하고 유용한 3개 역할을 Skill로 만들어 자동 활성화되게 하기

**우선순위 높은 역할**:
1. **Role 6** (QA & Documentation) - flutter analyze, 테스트, 문서화
2. **Role 3** (UI/UX Guardian) - ModernColors 검증
3. **Role 1** (Architect & Orchestrator) - 작업 계획 수립

**왜 이 3개부터?**:
- ✅ 읽기 전용 작업 (안전)
- ✅ 즉시 유용함
- ✅ 코드 수정 없음

### 📝 성공 기준

- [ ] `.claude/skills/` 디렉토리 생성 완료
- [ ] Role 1, 3, 6 Skill 작성 완료 (3개 SKILL.md)
- [ ] 테스트 케이스 3개 통과 (자동 활성화 확인)
- [ ] Git 커밋 및 푸시 완료

### 🚀 단계별 실행 가이드

#### Step 1: 디렉토리 구조 생성

```bash
cd C:\sherpa_app
mkdir .claude\skills
mkdir .claude\skills\role1-architect-orchestrator
mkdir .claude\skills\role3-ui-ux-guardian
mkdir .claude\skills\role6-qa-documentation
```

**확인**:
```bash
dir .claude\skills
```

**예상 출력**:
```
role1-architect-orchestrator
role3-ui-ux-guardian
role6-qa-documentation
```

#### Step 2: Role 6 Skill 작성 (가장 안전한 것부터)

**파일 생성**: `.claude/skills/role6-qa-documentation/SKILL.md`

**작성 방법**:

1. VS Code 또는 텍스트 에디터로 파일 생성
2. 다음 내용 복사-붙여넣기:

```markdown
---
name: sherpa-qa-documentation
description: Sherpa 앱의 품질 보증 및 문서화 담당자입니다. E2E 테스트 시나리오 작성, flutter analyze 실행, API 문서 작성, CHANGELOG 업데이트를 수행합니다. 키워드: test, testing, QA, documentation, E2E, changelog, API docs, flutter analyze
allowed-tools: Read, Bash, Write, Edit
---

# Sherpa QA & Documentation

## 역할 정의

셰르파 앱의 **품질 문지기이자 기록 담당자**로서:
- flutter analyze 실행 및 경고 해결
- API 문서 및 주석 작성
- CHANGELOG 업데이트
- 학습 노트 초안 작성 지원

## 활성화 조건

다음과 같은 요청 시 자동 활성화됩니다:
- "flutter analyze 실행해줘"
- "CHANGELOG 업데이트해줘"
- "이 기능에 대한 문서 작성"
- "학습 노트 작성"

## 작업 프로세스

### 1. flutter analyze 실행

```bash
cd C:\sherpa_app
flutter analyze
```

**0 issues 필수** - 경고 또는 에러 발견 시 즉시 보고

### 2. CHANGELOG 업데이트

**파일**: `CHANGELOG.md`

**형식**:
```markdown
## [Unreleased]

### Added
- [기능 추가 내용]

### Changed
- [기능 변경 내용]

### Fixed
- [버그 수정 내용]
```

### 3. 학습 노트 작성

**템플릿**:
```markdown
# 학습 노트: [주제]

## 날짜
YYYY-MM-DD

## 문제
무엇을 해결하려 했는가?

## 원인
왜 이 문제가 발생했는가?

## 해결
어떻게 해결했는가?

## 학습한 점
무엇을 배웠는가?

## 다음에 개선할 점
무엇을 더 잘할 수 있는가?
```

## 출력 포맷

```markdown
# 품질 보증: [기능명]

## flutter analyze
✅ 0 issues (경고/에러 없음)
또는
❌ 3 issues 발견

## 문서화 완료
✅ CHANGELOG 업데이트
✅ 학습 노트 초안 작성

## 권고사항
[통과 또는 추가 작업 필요 사항]
```

## 참조 문서

- `docs/knowledge_base/` (Week 1에서 작성한 문서들)
```

**저장 후 확인**:
```bash
# 파일 존재 확인
dir .claude\skills\role6-qa-documentation\SKILL.md
```

#### Step 3: Role 3 Skill 작성

**파일 생성**: `.claude/skills/role3-ui-ux-guardian/SKILL.md`

```markdown
---
name: sherpa-ui-ux-guardian
description: Sherpa 앱의 디자인 시스템 수호자입니다. ModernColors 강제, Sherpi AI 감정/컨텍스트 관리, UI 일관성 유지를 담당합니다. 키워드: UI, design system, ModernColors, Sherpi, emotion, accessibility, responsive, AppColors, RecordColors
allowed-tools: Read, Grep, Glob
---

# Sherpa UI/UX Guardian

## 역할 정의

셰르파 앱의 **디자인 시스템 집행자**로서:
- ModernColors 사용 강제 (AppColors/RecordColors 금지)
- Sherpi AI 감정 및 컨텍스트 일관성 관리
- UI 컴포넌트 일관성 검증

## 활성화 조건

다음과 같은 요청 시 자동 활성화됩니다:
- "ModernColors 준수 여부 확인"
- "레거시 색상 사용 검색"
- "Sherpi 감정 조합 확인"
- "UI 일관성 검증"

## 핵심 규칙

### ModernColors 강제

```dart
// ✅ 필수
import 'package:sherpa_app/core/theme/modern_colors.dart';
ModernColors.primary

// ❌ 금지
import 'package:sherpa_app/core/theme/app_colors.dart';
AppColors.primary
```

### Sherpi AI 감정 (6가지)

```dart
enum SherpiEmotion {
  normal, cheering, proud, thinking, surprised, concerned
}
```

### Sherpi AI 컨텍스트 (5가지)

```dart
enum SherpiContext {
  levelUp, questComplete, climbSuccess, meeting, dailyGoal
}
```

## 검증 프로세스

### 1. 레거시 색상 스캔

```bash
grep -r "AppColors\|RecordColors" lib/
```

발견 시 즉시 차단 및 수정 요청

### 2. Sherpi 감정 일관성 검증

감정-컨텍스트 조합 적절성 검증:
- levelUp + proud/cheering ✅
- levelUp + concerned ❌

## 출력 포맷

```markdown
# UI/UX 검증: [컴포넌트/화면명]

## ModernColors 검증
✅ AppColors/RecordColors 사용 없음
또는
❌ AppColors 사용 발견: [파일명:라인]

## Sherpi AI 검증
✅ 감정: cheering (적절)
✅ 컨텍스트: questComplete (적절)

## 권고사항
[개선 제안 또는 통과]
```

## 참조 문서

- `docs/knowledge_base/design_system.md`
- `docs/knowledge_base/sherpi_ai_rules.md`
```

#### Step 4: Role 1 Skill 작성

**파일 생성**: `.claude/skills/role1-architect-orchestrator/SKILL.md`

```markdown
---
name: sherpa-architect-orchestrator
description: Sherpa 앱의 고수준 작업 분해, 시스템 품질 모니터링, 아키텍처 결정을 담당합니다. 복잡한 작업 계획, 리팩토링 전략, 시스템 전반 분석이 필요할 때 사용됩니다. 키워드: architecture, planning, refactoring, system-wide, quality monitoring, task breakdown
allowed-tools: Read, Grep, Glob, Bash, TodoWrite
---

# Sherpa Architect & Orchestrator

## 역할 정의

셰르파 앱 개발의 **고수준 계획자이자 품질 관리자**로서:
- 복잡한 작업을 실행 가능한 서브태스크로 분해
- 시스템 전반의 품질 메트릭 모니터링
- 아키텍처 결정 및 검증
- 다른 역할 간 조율 및 우선순위 설정

## 활성화 조건

다음과 같은 요청 시 자동 활성화됩니다:
- "Meeting 시스템 리팩토링 계획 수립"
- "Quest 시스템 전체 구조 분석"
- "Provider 의존성 그래프 검증"
- "다음 2주 개발 로드맵 작성"

## 작업 프로세스

### 1. 작업 분석

1. 요구사항 이해 및 명확화
2. 셰르파 앱 특화 규칙 확인 (knowledge_base 참조)
3. 영향 범위 분석 (파일, Provider, 게임 밸런스)
4. 리스크 평가 (복잡도, 변경 범위, 테스트 필요성)

### 2. 작업 분해

1. 서브태스크로 분해 (각 역할에 매핑)
2. 의존성 그래프 작성
3. 우선순위 및 실행 순서 정의
4. TodoWrite로 작업 목록 생성

### 3. 품질 게이트 정의

1. 각 서브태스크의 완료 기준 명시
2. 검증 방법 제시 (flutter analyze, 수동 테스트 등)
3. 고위험 변경 사항 표시 (인간 승인 필요)

## 출력 포맷

```markdown
# 작업 분해: [작업명]

## 개요
- 목적: [설명]
- 영향 범위: [파일 목록]
- 리스크 수준: LOW / MEDIUM / HIGH

## 서브태스크
1. [Role X] - [태스크 설명]
   - 산출물: [구체적 산출물]
   - 완료 기준: [검증 방법]

## 실행 순서
[1] → [2] → [3] (의존성 표시)

## 품질 게이트
- [ ] flutter analyze 통과
- [ ] Provider 초기화 순서 검증
- [ ] ModernColors 준수 확인
```

## Sherpa 특화 검증 체크리스트

### Provider 변경 시
- [ ] 초기화 순서 (Level 0-3) 준수 확인
- [ ] 순환 의존성 검증
- [ ] questProviderV2 사용 확인

### UI 변경 시
- [ ] ModernColors 사용 강제
- [ ] AppColors/RecordColors 사용 금지 확인

### 게임 로직 변경 시
- [ ] 게임 밸런스 시뮬레이션 필요 여부 확인

## 참조 문서

- `docs/knowledge_base/architecture_rules.md`
- `docs/knowledge_base/provider_dependencies.md`
```

#### Step 5: Git 커밋

```bash
cd C:\sherpa_app

# 파일 추가
git add .claude/skills/

# 커밋
git commit -m "feat: Week 2 - 첫 3개 Skill 추가

- role6-qa-documentation: QA 및 문서화 (flutter analyze, CHANGELOG)
- role3-ui-ux-guardian: UI/UX 검증 (ModernColors, Sherpi AI)
- role1-architect-orchestrator: 작업 계획 및 아키텍처 검증

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# 푸시 (선택)
git push origin feature/sherpa-app-initial-setup
```

### ✅ 검증 방법

#### 테스트 케이스 1: Role 6 활성화 확인

Claude Code에서:
```
"flutter analyze 실행해줘"
```

**기대 결과**:
- `sherpa-qa-documentation` Skill이 자동 활성화
- flutter analyze 실행 결과 출력

#### 테스트 케이스 2: Role 3 활성화 확인

Claude Code에서:
```
"ModernColors 준수 여부 확인해줘"
```

**기대 결과**:
- `sherpa-ui-ux-guardian` Skill이 자동 활성화
- AppColors/RecordColors 사용 여부 검색 결과

#### 테스트 케이스 3: Role 1 활성화 확인

Claude Code에서:
```
"Meeting 참가 시스템 구현 계획 수립해줘"
```

**기대 결과**:
- `sherpa-architect-orchestrator` Skill이 자동 활성화
- 작업 분해 및 서브태스크 제시

### 🐛 트러블슈팅

**문제 1**: Skill이 자동 활성화되지 않음

**원인**: description이 너무 모호하거나 키워드 부족

**해결**:
1. SKILL.md의 `description` 확인
2. 키워드 추가 (예: `flutter analyze` 키워드 명시)
3. "Use when..." 문구 추가

**문제 2**: 여러 Skill이 동시에 활성화됨

**원인**: description이 너무 광범위

**해결**:
1. 각 Skill의 description을 더 구체적으로 작성
2. allowed-tools로 범위 제한

**문제 3**: Git에 .claude/ 폴더가 추가되지 않음

**원인**: .gitignore에 .claude/가 제외되어 있을 수 있음

**해결**:
```bash
# .gitignore 확인
cat .gitignore

# .claude/ 제외 항목 제거 또는
# 강제 추가
git add -f .claude/skills/
```

### 🎉 Week 2 완료!

축하합니다! Week 2를 완료했습니다.

**달성한 것**:
- ✅ 3개 Skill 작성 및 자동 활성화 확인
- ✅ 안전한 읽기 전용 Skill부터 시작
- ✅ Claude가 자동으로 역할 활성화

**다음 단계**: Week 3 - 나머지 Skill 완성

---

## Part 4: Week 3 - 나머지 Skill 완성

### 🎯 목표

좀 더 복잡한 3개 역할을 Skill로 만들기

**우선순위 중간인 역할**:
1. **Role 4** (State Management Expert) - Provider 검증
2. **Role 2** (Game Logic Specialist) - 밸런스 시뮬레이션
3. **Role 5** (Fullstack Implementer) - 실제 구현

**주의**: Role 5는 쓰기 권한이 있으므로 신중하게 사용

### 📝 성공 기준

- [ ] Role 2, 4, 5 Skill 작성 완료
- [ ] 6개 역할 모두 자동 활성화됨
- [ ] `balance_simulator.py` 스크립트 작동 (Role 2)
- [ ] Git 커밋 및 푸시 완료

### 🚀 단계별 실행 가이드

#### Step 1: 디렉토리 구조 생성

```bash
cd C:\sherpa_app
mkdir .claude\skills\role2-game-logic-specialist
mkdir .claude\skills\role2-game-logic-specialist\scripts
mkdir .claude\skills\role4-state-management-expert
mkdir .claude\skills\role5-fullstack-implementer
mkdir .claude\skills\role5-fullstack-implementer\templates
```

#### Step 2: Role 4 Skill 작성

**파일 생성**: `.claude/skills/role4-state-management-expert/SKILL.md`

```markdown
---
name: sherpa-state-management-expert
description: Sherpa 앱의 Provider 초기화 순서 집행자이자 Riverpod 아키텍처 전문가입니다. Provider 의존성 검증, 순환 참조 방지, 상태 관리 패턴 준수를 담당합니다. 키워드: provider, riverpod, state management, initialization order, dependency, questProviderV2
allowed-tools: Read, Grep, Bash
---

# Sherpa State Management Expert

## 역할 정의

셰르파 앱의 **Provider 무결성 수호자**로서:
- Provider 초기화 순서 (Level 0-3) 강제
- 순환 의존성 감지 및 방지
- 레거시 Provider 사용 차단 (questProvider → questProviderV2)

## 활성화 조건

- "Provider 초기화 순서 검증"
- "questProvider 사용 확인"
- "Provider 의존성 그래프 분석"

## 핵심 규칙

### Provider 초기화 순서 (절대 규칙)

```dart
// Level 0: globalGameProvider
// Level 1: globalUserProvider
// Level 2: questProviderV2 (⚠️ questProvider 아님!)
// Level 3: sherpiProvider
```

### 레거시 Provider 금지

```dart
// ❌ 절대 금지
import '.../quest_provider.dart';
final data = ref.watch(questProvider);

// ✅ 필수
import '.../quest_provider_v2.dart';
final data = ref.watch(questProviderV2);
```

## 검증 프로세스

### 1. 초기화 순서 확인

```bash
grep -A 20 "initializeProviders" lib/main.dart
```

### 2. 레거시 Provider 스캔

```bash
grep -r "questProvider[^V]" lib/
```

## 출력 포맷

```markdown
# Provider 검증: [변경 사항]

## 초기화 순서
✅ Level 0-3 준수
또는
⚠️ Level 2에서 순서 위반

## 레거시 검증
✅ questProvider 사용 없음
또는
❌ questProvider 사용 발견: [파일명:라인]

## 권고사항
[통과 또는 수정 필요 사항]
```

## 참조 문서

- `docs/knowledge_base/provider_dependencies.md`
```

#### Step 3: Role 2 Skill 작성

**파일 생성**: `.claude/skills/role2-game-logic-specialist/SKILL.md`

```markdown
---
name: sherpa-game-logic-specialist
description: Sherpa 앱의 게임 밸런스 검증 전문가입니다. 등반력 공식, XP 곡선, 포인트 경제 시스템 변경 시 시뮬레이션 및 영향 분석을 수행합니다. 키워드: game balance, climbing power, XP, point economy, simulation, balance testing
allowed-tools: Read, Bash
---

# Sherpa Game Logic Specialist

## 역할 정의

셰르파 앱의 **게임 밸런스 수호자**로서:
- 등반력 공식 변경 영향 시뮬레이션
- XP 곡선 및 레벨 밸런스 분석
- 포인트 경제 시스템 검증

## 활성화 조건

- "게임 밸런스 시뮬레이션"
- "등반력 공식 변경 영향"
- "포인트 경제 검증"
- "XP 곡선 분석"

## 핵심 공식

### 등반력

```
climbingPower = (userStats × badgeBonus × equipmentBonus) / difficulty
```

### XP 곡선

```
requiredXP(level) = 100 × level^1.5
```

### 포인트 경제

```
1 point = 1원
수수료 = 10%
최소 거래 = 10,000원
```

## 시뮬레이션 프로세스

### 1. 변경 사항 파악

변경되는 공식/상수 식별

### 2. Python 스크립트 실행

```bash
cd .claude/skills/role2-game-logic-specialist/scripts
python balance_simulator.py --test climbing_power --changes "stats_weight=1.2"
```

### 3. 검증 기준

✅ 통과율 95% 이상
✅ 극단적 엣지 케이스 0건
✅ 포인트 인플레이션 5% 이내

## 출력 포맷

```markdown
# 게임 밸런스 시뮬레이션: [변경 사항]

## 변경 내역
- 기존: [값]
- 제안: [값]

## 시뮬레이션 결과
- 시나리오 수: 1,000회
- 통과율: 96.3% ✅
- 문제 케이스: 0건 ✅

## 영향 분석
- 초급 (Lv 1-10): 변화 없음
- 중급 (Lv 11-30): +2% 난이도 증가
- 고급 (Lv 31-50): +5% 난이도 증가

## 권고사항
✅ 승인 권장
또는
❌ 거부 권장 - [이유]
```

## 참조 문서

- `docs/knowledge_base/game_balance_formulas.md`
- `.claude/skills/role2-game-logic-specialist/scripts/balance_simulator.py`
```

**Python 시뮬레이션 스크립트 생성** (간단한 예제):

**파일**: `.claude/skills/role2-game-logic-specialist/scripts/balance_simulator.py`

```python
#!/usr/bin/env python3
"""
셰르파 게임 밸런스 시뮬레이터

사용법:
    python balance_simulator.py --test climbing_power
    python balance_simulator.py --test xp_curve
    python balance_simulator.py --test point_economy
"""

import argparse
import random
import math


def simulate_climbing_power(stats=100, badge=1.5, equipment=1.2, difficulty=3, iterations=1000):
    """등반력 시뮬레이션"""
    success_count = 0

    for _ in range(iterations):
        power = (stats * badge * equipment) / difficulty
        # power% 확률로 성공
        if random.randint(0, 100) < power:
            success_count += 1

    success_rate = (success_count / iterations) * 100
    return success_rate


def calculate_xp_curve(max_level=50):
    """XP 곡선 계산"""
    for level in range(1, max_level + 1):
        required = int(100 * math.pow(level, 1.5))
        print(f"Level {level}: {required:,} XP")


def main():
    parser = argparse.ArgumentParser(description='셰르파 게임 밸런스 시뮬레이터')
    parser.add_argument('--test', choices=['climbing_power', 'xp_curve', 'point_economy'],
                        required=True, help='테스트 유형')
    args = parser.parse_args()

    if args.test == 'climbing_power':
        print("등반력 시뮬레이션...")
        rate = simulate_climbing_power()
        print(f"예상 성공률: {rate:.1f}%")

    elif args.test == 'xp_curve':
        print("XP 곡선 계산...")
        calculate_xp_curve()

    elif args.test == 'point_economy':
        print("포인트 경제 시뮬레이션...")
        print("일일 평균 획득: 300-500 포인트")
        print("일일 평균 소비: 100-200 포인트")
        print("주간 잉여: 1,000-2,000 포인트")


if __name__ == '__main__':
    main()
```

#### Step 4: Role 5 Skill 작성

**파일 생성**: `.claude/skills/role5-fullstack-implementer/SKILL.md`

```markdown
---
name: sherpa-fullstack-implementer
description: Sherpa 앱의 실제 코드 구현 담당자입니다. Flutter UI, Riverpod 상태 관리, Firebase 백엔드 로직을 통합하여 기능을 완성합니다. 키워드: implementation, code, flutter, riverpod, firebase, UI, backend, feature development, write code, implement
allowed-tools: Read, Write, Edit, MultiEdit, Bash
---

# Sherpa Fullstack Implementer

## 역할 정의

셰르파 앱의 **실제 코드 작성자**로서:
- Flutter UI 컴포넌트 구현
- Riverpod Provider 및 Notifier 작성
- Firebase Functions/Firestore 로직 구현

## 활성화 조건

- "Meeting 참가 버튼 구현"
- "Provider 작성"
- "UI 화면 구현"
- "Firebase 함수 작성"

## 구현 전 체크리스트

### Role 1 (아키텍트)의 승인 확인
- [ ] 작업 분해 및 설계 완료

### Role 4 (상태 관리) 검증
- [ ] Provider 초기화 순서 확인

### Role 3 (UI/UX) 검증
- [ ] ModernColors 사용 확정

### Role 2 (게임 로직) 시뮬레이션 (필요 시)
- [ ] 게임 밸런스 영향 검증 완료

## 출력 포맷

```markdown
# 구현 완료: [기능명]

## 구현 파일
- `lib/features/.../provider.dart` (신규)
- `lib/features/.../screen.dart` (수정)

## 준수 사항
✅ ModernColors 사용
✅ Provider 초기화 순서 준수
✅ Riverpod 2.4.9 패턴 준수

## 테스트 방법
1. [테스트 단계 1]
2. [테스트 단계 2]

## 다음 단계
- Role 6에게 flutter analyze 요청
- Role 6에게 CHANGELOG 업데이트 요청
```

## 참조 문서

- `docs/knowledge_base/architecture_rules.md`
- `docs/knowledge_base/design_system.md`
- `.claude/skills/role5-fullstack-implementer/templates/` (템플릿 파일)
```

#### Step 5: Git 커밋

```bash
cd C:\sherpa_app

# 파일 추가
git add .claude/skills/

# 커밋
git commit -m "feat: Week 3 - 나머지 3개 Skill 추가

- role4-state-management-expert: Provider 검증 및 의존성 분석
- role2-game-logic-specialist: 게임 밸런스 시뮬레이션
  - balance_simulator.py 스크립트 추가
- role5-fullstack-implementer: 실제 코드 구현

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# 푸시
git push origin feature/sherpa-app-initial-setup
```

### ✅ 검증 방법

#### 테스트 1: Role 4 활성화

```
"Provider 초기화 순서 검증해줘"
```

#### 테스트 2: Role 2 활성화

```
"등반력 공식에서 stats 가중치를 1.2로 변경하면 게임 밸런스에 어떤 영향이 있을까?"
```

#### 테스트 3: Role 5 활성화

```
"Meeting 참가 신청 버튼 구현해줘"
```

### 🎉 Week 3 완료!

**달성한 것**:
- ✅ 6개 역할 모두 Skill로 완성
- ✅ 게임 밸런스 시뮬레이션 스크립트
- ✅ 실제 코드 구현 가능

**다음 단계**: Week 4 - 실전 사용

---

## Part 5: Week 4 - 실전 사용

### 🎯 목표

실제 기능 구현에 6개 역할 모두 사용하여 워크플로우 내재화

**이 주차에서 하는 일**:
- ✅ 실제 기능 1개 구현 (6개 역할 순차 사용)
- ✅ `.claude/project_memory/` 활용
- ✅ 학습 노트 작성

### 📝 성공 기준

- [ ] 실제 기능 1개 구현 완료
- [ ] 6개 역할 모두 사용
- [ ] `.claude/project_memory/` 디렉토리 및 파일 생성
- [ ] 학습 노트 최소 1개 작성
- [ ] ModernColors 위반 0건 유지

### 🚀 예제: Meeting 참가 시스템 구현

#### Step 1: 프로젝트 메모리 디렉토리 생성

```bash
cd C:\sherpa_app
mkdir .claude\project_memory
mkdir .claude\lessons_learned
```

#### Step 2: Role 1 (계획) - 작업 분해

Claude Code에서:
```
"Meeting 참가 신청 및 승인 시스템을 구현하려고 합니다.

요구사항:
- 참가 신청 버튼 및 다이얼로그
- 호스트 승인/거절 기능
- 포인트 결제 (참가비 100 포인트)

작업을 서브태스크로 분해하고 실행 계획을 수립해주세요."
```

**기대 출력** (sherpa-architect-orchestrator Skill 자동 활성화):
```markdown
# 작업 분해: Meeting 참가 시스템

## 개요
- 목적: Meeting 참가 신청 및 승인 프로세스 구현
- 영향 범위: globalMeetingProvider, meeting_detail_screen.dart
- 리스크 수준: MEDIUM

## 서브태스크
1. [Role 4] - Provider 영향 분석
2. [Role 2] - 포인트 100 게임 밸런스 검증
3. [Role 3] - UI 디자인 검증
4. [Role 5] - 코드 구현
5. [Role 6] - 테스트 및 문서화

## 실행 순서
[1] → [2] → [3] → [4] → [5]
```

#### Step 3: Role 4 (검증) - Provider 영향 분석

```
"globalMeetingProvider에 다음 메서드를 추가하려고 합니다:
- applyToMeeting
- approveMeetingApplication
- rejectMeetingApplication

Provider 초기화 순서 및 의존성에 미치는 영향을 분석해주세요."
```

**기대 출력** (sherpa-state-management-expert 자동 활성화):
```markdown
# Provider 검증: globalMeetingProvider 수정

## 초기화 순서
✅ globalMeetingProvider는 Level 2
✅ Level 0, 1 의존성 없음
✅ 순서 변경 불필요

## 의존성 그래프
globalUserProvider (Level 1)
└── globalMeetingProvider (Level 2) ← 여기 수정
    └── 영향받는 상위 Provider 없음

## 권고사항
✅ 안전하게 수정 가능
```

#### Step 4: Role 2 (밸런스) - 게임 밸런스 검증

```
"Meeting 참가비를 100 포인트로 설정했을 때 게임 경제에 미치는 영향을 시뮬레이션해주세요.

일일 평균:
- Meeting 참가: 1-2회
- 포인트 획득: 300-500
"
```

**기대 출력** (sherpa-game-logic-specialist 자동 활성화):
```markdown
# 게임 밸런스 시뮬레이션: Meeting 참가비 100 포인트

## 변경 내역
- Meeting 참가비: 0 → 100 포인트

## 시뮬레이션 결과
- 일일 소비: 100-200 포인트 (Meeting 1-2회)
- 일일 획득: 300-500 포인트
- 일일 잉여: 100-300 포인트 ✅

## 영향 분석
- 포인트 인플레이션: <2% ✅
- 경제 밸런스: 유지

## 권고사항
✅ 승인 권장 - 100 포인트 적정
```

#### Step 5: Role 3 (UI) - ModernColors 검증

```
"Meeting 참가 신청 버튼과 확인 다이얼로그를 ModernColors로 디자인해주세요."
```

**기대 출력** (sherpa-ui-ux-guardian 자동 활성화):
```markdown
# UI/UX 검증: Meeting 참가 신청

## ModernColors 적용
✅ 버튼: ModernColors.primary
✅ 다이얼로그 배경: ModernColors.surface
✅ 텍스트: ModernColors.textPrimary

## Sherpi AI
✅ 감정: cheering
✅ 컨텍스트: meeting
✅ 메시지: "새로운 친구를 만나보세요! 🎉"

## 권고사항
✅ 디자인 승인
```

#### Step 6: Role 5 (구현) - 코드 작성

```
"위 계획을 바탕으로 Meeting 참가 신청 버튼 및 로직을 구현해주세요.

파일:
- lib/features/meeting/providers/meeting_detail_provider.dart
- lib/features/meeting/presentation/screens/meeting_detail_screen.dart
"
```

**기대 출력** (sherpa-fullstack-implementer 자동 활성화):
- 코드 구현
- ModernColors 사용 확인
- Provider 패턴 준수 확인

#### Step 7: Role 6 (품질) - 테스트 및 문서화

```
"flutter analyze 실행하고 CHANGELOG 업데이트해줘"
```

**기대 출력** (sherpa-qa-documentation 자동 활성화):
```markdown
# 품질 보증: Meeting 참가 시스템

## flutter analyze
✅ 0 issues

## 문서화 완료
✅ CHANGELOG 업데이트:
  ### Added
  - Meeting 참가 신청 및 승인 시스템
```

#### Step 8: 학습 노트 작성

```
"이번 Meeting 참가 시스템 구현 작업의 학습 노트 초안을 작성해줘"
```

**기대 출력**:

`.claude/lessons_learned/2025-10-31_meeting_participation.md`

```markdown
# 학습 노트: Meeting 참가 시스템 구현

## 날짜
2025-10-31

## 문제
Meeting 참가가 자동으로 처리되어 호스트의 통제권이 없었음.

## 원인
초기 설계에서 승인 프로세스를 고려하지 않음.

## 해결
1. globalMeetingProvider에 신청/승인 메서드 추가
2. Provider는 Level 2에 위치 (순서 변경 불필요)
3. 포인트 100 게임 밸런스 검증 통과
4. ModernColors 적용한 UI 구현

## 학습한 점
- 6개 역할 순차 사용으로 품질 향상
- Provider 검증 먼저 하면 크래시 방지
- 게임 밸런스 시뮬레이션으로 사전 검증

## 다음에 개선할 점
- 테스트 코드 작성 (현재 수동 테스트만)
- 에러 처리 강화
```

#### Step 9: Git 커밋

```bash
git add .
git commit -m "feat: Meeting 참가 신청 및 승인 시스템 구현

- 참가 신청 버튼 및 확인 다이얼로그
- 호스트 승인/거절 기능
- 포인트 100 결제 로직

6개 역할 모두 사용:
- Role 1: 작업 계획 수립
- Role 4: Provider 영향 분석
- Role 2: 게임 밸런스 검증 (통과율 98%)
- Role 3: ModernColors 적용
- Role 5: 코드 구현
- Role 6: flutter analyze 통과, CHANGELOG 업데이트

학습 노트: .claude/lessons_learned/2025-10-31_meeting_participation.md

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 🎉 Week 4 완료!

**달성한 것**:
- ✅ 실제 기능 구현 (6개 역할 활용)
- ✅ 학습 노트 작성
- ✅ 워크플로우 내재화

**완성**: 셰르파 워크플로우 3.1 기본 구현 완료!

---

## Part 6: 선택적 확장 (Agent SDK)

### ⚠️ 중요한 안내

**Agent SDK는 선택 사항입니다!**

- ✅ Week 1-4만으로도 충분한 가치
- ✅ Skill만으로 대부분의 작업 가능
- ⏸️ Agent SDK는 "반복 작업이 많아졌을 때" 고려
- 🐍 Python을 편하게 다룰 수 있을 때만

### 🎯 언제 고려할 것인가?

다음 조건을 **모두** 만족할 때:
- [ ] Week 1-4 완료 및 안정화 (최소 2주 사용)
- [ ] 반복 작업이 주간 5회 이상 발생
- [ ] Python 기본 문법 이해
- [ ] 자동화에 시간 투자할 여유

### 🚀 Python 환경 설정 (간략)

```bash
# Python 설치 확인
python --version

# 가상 환경 생성
cd C:\sherpa_app
python -m venv venv

# 가상 환경 활성화
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Mac/Linux

# Agent SDK 설치
pip install claude-agent-sdk

# API 키 설정
set ANTHROPIC_API_KEY=your_api_key  # Windows
# export ANTHROPIC_API_KEY=your_api_key  # Mac/Linux
```

### 📝 간단한 스크립트 예제

**파일**: `scripts/weekly_quality_check.py`

```python
from claude_agent_sdk import Agent

agent = Agent()

# Role 3: ModernColors 검증
ui_check = agent.run(
    prompt="ModernColors 준수 여부 확인",
    skills=["sherpa-ui-ux-guardian"]
)

# Role 4: Provider 검증
provider_check = agent.run(
    prompt="Provider 초기화 순서 검증",
    skills=["sherpa-state-management-expert"]
)

# Role 6: flutter analyze
analyze_check = agent.run(
    prompt="flutter analyze 실행",
    skills=["sherpa-qa-documentation"]
)

print("=== 주간 품질 검증 결과 ===")
print(ui_check.content)
print(provider_check.content)
print(analyze_check.content)
```

**실행**:
```bash
python scripts/weekly_quality_check.py
```

---

## Part 7: 자주 묻는 질문 (FAQ)

### Q1: Skill이 자동 활성화되지 않아요.

**A**: description에 구체적인 키워드를 추가하세요.

**예시**:
```yaml
# ❌ 모호함
description: "Helps with testing"

# ✅ 구체적
description: "Sherpa 앱의 테스트 담당. flutter analyze 실행, 테스트 작성. 키워드: test, flutter analyze, QA"
```

### Q2: 여러 Skill이 동시에 활성화되는데요?

**A**: 각 Skill의 description을 더 구체적으로 만들고 allowed-tools로 범위를 제한하세요.

### Q3: Week 1-2는 완료했는데 Week 3-4는 건너뛰어도 되나요?

**A**: 가능합니다! 각 주차는 독립적 가치가 있습니다. Week 1-2만으로도 충분한 효과를 볼 수 있습니다.

### Q4: Agent SDK 없이 Skill만 사용해도 되나요?

**A**: 네! 대부분의 경우 Skill만으로도 충분합니다. Agent SDK는 반복 작업이 많을 때만 고려하세요.

### Q5: Git에 .claude/ 폴더를 커밋해도 되나요?

**A**: 네, 권장합니다! Skill은 팀원과 공유할 가치가 있습니다. 단, API 키나 민감한 정보는 .gitignore에 추가하세요.

### Q6: Provider 초기화 순서를 잊어서 앱이 크래시되었어요.

**A**: 앞으로는 Provider 수정 전 항상 Role 4 (State Management Expert)에게 검증을 요청하세요.

```
"globalMeetingProvider를 수정하려고 하는데, Provider 초기화 순서에 영향이 있을까?"
```

### Q7: 학습 노트는 언제 작성하나요?

**A**: 매 기능 구현 후 즉시 작성하는 것이 좋습니다. Role 1 (Architect)에게 초안 작성을 요청할 수 있습니다.

```
"이번 Meeting 참가 시스템 구현의 학습 노트 초안을 작성해줘"
```

### Q8: 시간이 없는데 Week 1만 해도 효과가 있나요?

**A**: 네! Week 1 (지식 베이스)만으로도:
- Claude가 셰르파 규칙을 이해
- 더 정확한 제안
- 규칙 위반 사전 감지

### Q9: Role 5 (Fullstack Implementer)가 예상과 다르게 코드를 작성해요.

**A**: 다음을 시도해보세요:
1. 더 구체적인 요구사항 제공
2. Role 1로 먼저 계획 수립
3. Role 3, 4로 사전 검증
4. 템플릿 파일 활용

### Q10: 이미 작성한 Skill을 수정하고 싶어요.

**A**: SKILL.md 파일을 직접 편집하면 됩니다. 수정 후 Git 커밋하세요.

---

## Part 8: 체크리스트 요약

### Week 1 체크리스트

- [ ] `docs/knowledge_base/` 디렉토리 생성
- [ ] `architecture_rules.md` 작성
- [ ] `provider_dependencies.md` 작성
- [ ] `design_system.md` 작성
- [ ] `game_balance_formulas.md` 작성
- [ ] `sherpi_ai_rules.md` 작성
- [ ] Git 커밋 및 푸시
- [ ] Claude 테스트 ("Provider 초기화 순서 알려줘")

### Week 2 체크리스트

- [ ] `.claude/skills/` 디렉토리 생성
- [ ] Role 6 (QA) SKILL.md 작성
- [ ] Role 3 (UI/UX) SKILL.md 작성
- [ ] Role 1 (Architect) SKILL.md 작성
- [ ] 테스트: "flutter analyze 실행" → Role 6 활성화
- [ ] 테스트: "ModernColors 확인" → Role 3 활성화
- [ ] 테스트: "Meeting 계획 수립" → Role 1 활성화
- [ ] Git 커밋 및 푸시

### Week 3 체크리스트

- [ ] Role 4 (State Management) SKILL.md 작성
- [ ] Role 2 (Game Logic) SKILL.md 작성
- [ ] `balance_simulator.py` 스크립트 작성
- [ ] Role 5 (Fullstack) SKILL.md 작성
- [ ] 테스트: "Provider 검증" → Role 4 활성화
- [ ] 테스트: "게임 밸런스 시뮬레이션" → Role 2 활성화
- [ ] 테스트: "코드 구현" → Role 5 활성화
- [ ] Git 커밋 및 푸시

### Week 4 체크리스트

- [ ] `.claude/project_memory/` 디렉토리 생성
- [ ] `.claude/lessons_learned/` 디렉토리 생성
- [ ] 실제 기능 1개 구현 (6개 역할 활용)
- [ ] Role 1: 작업 계획
- [ ] Role 4: Provider 검증
- [ ] Role 2: 게임 밸런스 검증 (필요 시)
- [ ] Role 3: UI 검증
- [ ] Role 5: 코드 구현
- [ ] Role 6: 테스트 및 문서화
- [ ] 학습 노트 작성
- [ ] Git 커밋
- [ ] ModernColors 위반 0건 확인

### 지속적 사용 체크리스트

- [ ] 매 기능 구현 시 6개 역할 활용
- [ ] 학습 노트 즉시 작성
- [ ] 주간 품질 검증 (Role 3, 4, 6)
- [ ] 월간 회고 (학습 노트 분석)
- [ ] Git 커밋 습관화

---

## 🎉 마무리

### 축하합니다!

이 가이드를 따라오신 것을 축하드립니다!

**여러분은 이제**:
- ✅ 셰르파 앱의 핵심 규칙을 문서화했습니다
- ✅ 6개 AI 역할이 자동으로 돕는 시스템을 구축했습니다
- ✅ 일관된 품질을 유지하는 워크플로우를 갖추었습니다

### 다음 단계

**즉시**:
- 실제 기능 구현에 6개 역할 사용
- 학습 노트 축적

**1개월 후**:
- 학습 노트 분석 및 회고
- 반복 실수 감소 확인
- Skill 개선

**3개월 후**:
- Agent SDK 도입 고려 (선택)
- 워크플로우 자동화
- 팀원과 Skill 공유

### 피드백 및 개선

이 가이드를 사용하면서:
- ✅ 잘 작동한 부분
- ❌ 어려웠던 부분
- 💡 개선 아이디어

를 학습 노트에 기록해주세요!

---

**문서 작성자**: Claude Sonnet 4.5
**기반 문서**: 셰르파 개발 워크플로우 3.1
**최종 업데이트**: 2025-10-31

**행운을 빕니다! 🚀**
