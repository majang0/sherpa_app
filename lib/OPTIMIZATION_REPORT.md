# 셰르파 앱 구조 최적화 보고서

## 📊 현재 구조 분석 완료

### 전체 구조 요약
- **총 16개 feature 모듈**
- **24개 provider 파일** (중복 존재)
- **28개 2025 컴포넌트** + 기존 컴포넌트 병존
- **43개 파일 in daily_record** (과도하게 큼)
- **Sherpi 관련 6개 폴더**로 분산

## 🗑️ 즉시 제거 가능한 항목

### 1. 불필요한 폴더/파일
```
lib/.idea/                                    # IDE 설정 파일
lib/features/sherpi_personalization/          # 예제 파일만 있음
  - personalization_usage_example.dart
  - relationship_growth_usage_example.dart
```

### 2. 사용되지 않는 의존성 (pubspec.yaml)
```yaml
go_router        # 실제 import 없음 (MaterialApp 라우팅 사용 중)
hive            # 실제 import 없음 (SharedPreferences 사용 중)  
hive_flutter    # 실제 import 없음
```

## 🔄 통합 필요 영역

### 1. Sherpi 시스템 통합
**현재**: 6개 폴더로 분산
```
features/sherpi_chat/
features/sherpi_emotion/
features/sherpi_relationship/
features/sherpi_analysis/
features/sherpi_planning/
features/sherpi_personalization/  # 제거
```

**제안**: `features/sherpi/` 하나로 통합
```
features/sherpi/
  ├── chat/
  ├── emotion/
  ├── relationship/
  ├── analysis/
  └── planning/
```

### 2. Daily Record 분리
**현재**: 43개 파일이 하나의 폴더에
```
features/daily_record/
  - exercise_* (운동)
  - reading_* (독서)
  - diary_* (일기)
  - movie_* (영화)
  - focus_timer_* (집중 타이머)
```

**제안**: 각 기능별로 분리
```
features/exercise/
features/reading/
features/diary/
features/movie/
features/focus_timer/
```

### 3. 단일 파일 Features 이동
**현재**: 1개 파일만 있는 features
```
features/shop/      → 1개 파일
features/wallet/    → 1개 파일
features/notification/ → 1개 파일
```

**제안**: 적절한 위치로 이동
```
features/profile/shop/     # 포인트샵은 프로필에
features/profile/wallet/   # 출금도 프로필에
shared/notification/       # 알림은 공유 기능으로
```

## 🎨 컴포넌트 시스템 정리

### 현재 상황
- **2025 컴포넌트**: 28개 파일, 39곳에서 사용 중
- **기존 컴포넌트**: sherpa_button.dart 등 5곳에서 사용 중
- **중복**: 같은 기능의 컴포넌트가 2개 버전으로 존재

### 제안
1. 2025 컴포넌트를 메인으로 채택
2. 기존 컴포넌트 사용처를 2025 버전으로 마이그레이션
3. components.dart에서 통합 export

## 🔗 Provider 중복 제거

### 중복 Provider
```
features/climbing/providers/climbing_providers.dart
shared/providers/global_climbing_provider.dart
→ 하나로 통합

features/meetings/providers/meeting_creation_provider.dart
shared/providers/global_meeting_provider.dart
→ 하나로 통합
```

## 📁 Meeting 관련 파일 정리

### 현재 분산된 Meeting 파일들
```
features/meetings/
features/community/         # meetings와 관련
shared/utils/meeting_*      # 3개 유틸리티
shared/widgets/*meeting*    # 여러 위젯
```

### 제안
모든 meeting 관련 코드를 `features/meetings/`로 통합

## 📈 최적화 효과

### 예상 개선사항
- **폴더 수**: 16개 → 12개 (25% 감소)
- **Provider 중복**: 4개 제거
- **코드 중복**: 컴포넌트 시스템 통합으로 약 30% 감소
- **구조 명확성**: 기능별 분리로 유지보수성 향상
- **의존성**: 불필요한 패키지 3개 제거

## 🚀 실행 우선순위

### Phase 1: 즉시 실행 (위험도 낮음)
1. lib/.idea/ 폴더 제거
2. sherpi_personalization 폴더 제거
3. 사용되지 않는 의존성 제거

### Phase 2: 구조 개선 (중간 위험도)
1. Sherpi 시스템 통합
2. Daily Record 분리
3. 단일 파일 features 이동

### Phase 3: 코드 정리 (높은 위험도)
1. Provider 중복 제거
2. 컴포넌트 시스템 통합
3. Meeting 파일 통합

---

**분석 완료**: 2025-09-08
**분석 도구**: Sequential MCP + 체계적 코드 분석