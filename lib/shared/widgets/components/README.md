# Sherpa Design System - 2025 Component Library

## 개요 (Overview)

셰르파 앱의 2024-2025 디자인 트렌드를 반영한 현대적 컴포넌트 라이브러리입니다. 글래스모피즘, 뉴모피즘, 마이크로 인터랙션을 활용하여 사용자 경험을 극대화하는 디자인 시스템을 제공합니다.

## 디자인 철학 (Design Philosophy)

### 2025 디자인 트렌드
- **글래스모피즘 (Glassmorphism)**: 반투명 효과와 블러를 활용한 현대적 시각 효과
- **뉴모피즘 (Neumorphism)**: 부드러운 그림자와 하이라이트로 입체감 표현  
- **마이크로 인터랙션**: 섬세한 애니메이션과 피드백으로 자연스러운 상호작용
- **반응형 디자인**: 다양한 화면 크기와 디바이스에 최적화
- **접근성 우선**: WCAG 2.1 AA 기준 준수

### 핵심 컬러 시스템
- **메인 블루**: `#2563EB` (Mountain Blue - 산 중턱의 맑은 하늘)
- **라이트 블루**: `#60A5FA` (Light Sky Blue - 밝은 하늘) 
- **딥 블루**: `#1B365D` (Deep Mountain Blue - 깊은 산맥)
- **클라우드 화이트**: `#F8FAFC` (Cloud White - 구름 흰색)

## 컴포넌트 구조 (Component Structure)

### Atoms (기본 컴포넌트)
기본적인 UI 요소들로 더 이상 분해할 수 없는 최소 단위의 컴포넌트입니다.

#### Input Components
- **SherpaButton2025**: 현대적 버튼 컴포넌트 (다양한 변형과 애니메이션)
- **SherpaInput2025**: 입력 필드 (글래스 효과와 마이크로 인터랙션)
- **SherpaSearchBar2025**: 검색 바 (실시간 피드백과 자동완성 지원)
- **SherpaSelect2025**: 선택 드롭다운 (현대적 스타일링)

#### Layout Components  
- **SherpaContainer2025**: 유연한 컨테이너 (글래스/뉴모피즘 스타일)
- **SherpaGrid2025**: 반응형 그리드 시스템 (마소니, 스태거드 등)
- **SherpaStack2025**: 고급 스택 레이아웃 (패럴랙스, 깊이 효과)

#### Display Components
- **SherpaProgress2025**: 진행률 표시기 (선형, 원형, 반원형)
- **SherpaNotificationBadge2025**: 알림 배지 (다양한 스타일과 애니메이션)
- **SherpaChart2025**: 차트 컴포넌트 (선형, 막대, 도넛 차트)

#### Feedback Components
- **SherpaToast2025**: 토스트 알림 (자동 사라짐과 액션)
- **SherpaAlert2025**: 경고 및 알림 박스 (다양한 상태)
- **SherpaModal2025**: 모달 다이얼로그 (글래스 효과)

### Molecules (복합 컴포넌트)
여러 Atom들을 조합하여 특정 기능을 수행하는 컴포넌트입니다.

#### Navigation
- **SherpaTabBar2025**: 탭 네비게이션 (부드러운 전환 애니메이션)
- **SherpaAppBar2025**: 앱 헤더 (글래스 효과와 그라데이션)

#### Sherpa-Specific
- **SherpaActivityCard2025**: 활동 기록 카드 (운동, 독서, 일기 등)
- **SherpaMountainCard2025**: 산 정보 카드 (등반 관련)
- **SherpaQuestCard2025**: 퀘스트/도전과제 카드 (게임화 요소)

## 사용법 (Usage)

### 기본 임포트
```dart
import 'package:sherpa_app/shared/widgets/components/components.dart';
```

### 버튼 컴포넌트 사용 예제
```dart
// 기본 버튼
SherpaButton2025(
  text: '시작하기',
  onPressed: () => print('버튼 클릭!'),
)

// 글래스 효과 버튼
SherpaButton2025.glass(
  text: '글래스 버튼',
  category: 'climbing',
  onPressed: () {},
)

// 플로팅 액션 버튼
SherpaButton2025.floating(
  text: '+',
  size: SherpaButtonSize2025.large,
  onPressed: () {},
)
```

### 입력 컴포넌트 사용 예제
```dart
// 기본 입력 필드
SherpaInput2025(
  label: '사용자명',
  hint: '사용자명을 입력하세요',
  onChanged: (value) => print(value),
)

// 검색 바
SherpaSearchBar2025(
  hint: '산 이름으로 검색...',
  onSearch: (query) => performSearch(query),
  suggestions: ['지리산', '한라산', '설악산'],
)
```

### 레이아웃 컴포넌트 사용 예제
```dart
// 그리드 레이아웃
SherpaGrid2025.cards(
  children: [
    Card1(), Card2(), Card3(), Card4(),
  ],
  crossAxisCount: 2,
  spacing: 16,
)

// 스택 레이아웃
SherpaStack2025.floating(
  children: [
    BackgroundImage(),
    OverlayContent(),
  ],
)
```

### 카드 컴포넌트 사용 예제
```dart
// 활동 카드
SherpaActivityCard2025.exercise(
  title: '헬스장 운동',
  duration: Duration(hours: 1, minutes: 30),
  calories: 320,
  difficulty: ActivityDifficulty.medium,
  onTap: () => navigateToDetail(),
)

// 퀘스트 카드  
SherpaQuestCard2025.daily(
  questTitle: '오늘의 운동 목표',
  description: '30분 이상 운동하기',
  progress: 0.7,
  currentValue: 21,
  targetValue: 30,
  progressUnit: '분',
  onStart: () => startQuest(),
)
```

## 테마 시스템 (Theme System)

### 컬러 팔레트 사용
```dart
// 메인 컬러
AppColors2025.primary
AppColors2025.secondary

// 글래스 효과 컬러
AppColors2025.glassWhite20
AppColors2025.glassBlue30

// 카테고리별 컴포넌트
AppColors2025.getCategoryColor2025('exercise')
AppColors2025.getCategoryGlassColor('climbing')
```

### 글래스 뉴모피즘 스타일
```dart
// 글래스모피즘 데코레이션
GlassNeuStyle.glassMorphism(
  elevation: GlassNeuElevation.medium,
  color: AppColors2025.primary,
  borderRadius: AppSizes.radiusL,
)

// 뉴모피즘 데코레이션
GlassNeuStyle.softNeumorphism(
  baseColor: AppColors2025.surface,
  borderRadius: AppSizes.radiusM,
)
```

### 마이크로 인터랙션
```dart
// 호버 효과
MicroInteractions.hoverEffect(
  child: MyWidget(),
  scaleUpTo: 1.05,
)

// 슬라이드 인 애니메이션
MicroInteractions.slideInFade(
  child: MyWidget(),
  direction: SlideDirection.bottom,
)
```

## 반응형 디자인 (Responsive Design)

### 브레이크포인트
- **모바일**: < 600px
- **태블릿**: 600px - 1200px  
- **데스크톱**: > 1200px

### 반응형 그리드 사용
```dart
SherpaGrid2025.responsive(
  children: items,
  columns: {
    SherpaBreakpoint.mobile: 1,
    SherpaBreakpoint.tablet: 2, 
    SherpaBreakpoint.desktop: 3,
  },
)
```

## 접근성 (Accessibility)

### 기본 지원사항
- **시맨틱 라벨**: 모든 인터랙티브 요소에 의미있는 라벨 제공
- **색상 대비**: WCAG 2.1 AA 기준 준수 (4.5:1 이상)
- **터치 타겟**: 최소 44x44dp 크기 보장
- **포커스 관리**: 키보드 네비게이션 지원
- **스크린 리더**: VoiceOver, TalkBack 호환

### 접근성 사용 예제
```dart
SherpaButton2025(
  text: '제출',
  semanticLabel: '양식 제출하기',
  onPressed: submitForm,
)
```

## 성능 최적화 (Performance)

### 최적화 기법
- **위젯 재사용**: const 생성자 적극 활용
- **애니메이션 최적화**: 60fps 유지를 위한 효율적 애니메이션
- **메모리 관리**: 컨트롤러와 애니메이션 적절한 dispose
- **조건부 렌더링**: 필요한 경우에만 복잡한 효과 적용

## 커스터마이징 (Customization)

### 테마 확장
```dart
// 커스텀 컬러 적용
SherpaButton2025(
  text: '커스텀 버튼',
  customColor: Color(0xFF8B5CF6),
  onPressed: () {},
)

// 커스텀 스타일 적용
SherpaContainer2025.custom(
  decoration: myCustomDecoration,
  child: MyContent(),
)
```

## 마이그레이션 가이드 (Migration Guide)

### 기존 컴포넌트에서 2025 버전으로
```dart
// 기존 방식
SherpaButton(
  text: '버튼',
  onPressed: () {},
)

// 2025 버전
SherpaButton2025(
  text: '버튼',
  onPressed: () {},
  variant: SherpaButtonVariant2025.glass, // 새로운 스타일
  enableMicroInteractions: true, // 마이크로 인터랙션
)
```

## 문제 해결 (Troubleshooting)

### 자주 발생하는 문제
1. **애니메이션이 끊어짐**: `enableMicroInteractions: false`로 설정하여 테스트
2. **글래스 효과가 보이지 않음**: 배경색이 투명하지 않은지 확인
3. **반응형이 작동하지 않음**: `MediaQuery` 가 올바르게 전달되는지 확인

### 디버깅 팁
```dart
// 디버그 모드에서 컴포넌트 경계 표시
SherpaContainer2025(
  debugShowBounds: true, // 개발 중에만 사용
  child: MyContent(),
)
```

## 기여하기 (Contributing)

### 새로운 컴포넌트 추가 시
1. Atomic Design 원칙 준수
2. 2025 디자인 트렌드 반영
3. 접근성 기준 준수
4. 성능 최적화 고려
5. 문서화 완성

### 코드 스타일
- Dart 공식 스타일 가이드 준수
- 주석은 한국어와 영어 병행
- 의미있는 변수명과 함수명 사용

---

## 라이선스 (License)

이 컴포넌트 라이브러리는 셰르파 앱 전용으로 개발되었습니다.

## 업데이트 히스토리 (Update History)

### v2025.1.0 (2025-01-01)
- 초기 2025 디자인 시스템 구현
- 17개 핵심 컴포넌트 출시
- 글래스모피즘 & 뉴모피즘 스타일 지원
- 마이크로 인터랙션 시스템 도입
- 반응형 디자인 완전 지원