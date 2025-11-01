# 셰르파 앱 디자인 시스템 가이드

> **⚠️ 중요**: ModernColors만 사용하세요! AppColors와 RecordColors는 **금지**입니다.
> 이 문서는 `CLAUDE.md`의 UI/UX Patterns 섹션과 `셰르파 앱 참고내용.txt`를 기반으로 작성되었습니다.

---

## Part 1: 컬러 시스템

### 1.1 ModernColors (필수!) ✅

**위치**: `lib/core/theme/modern_colors.dart`

**사용 규칙**:
```dart
// ✅ 올바른 사용
import 'package:sherpa_app/core/theme/modern_colors.dart';

ModernColors.primary      // 메인 브랜드 블루
ModernColors.success      // 성공 그린
ModernColors.background   // 배경 색상
```

```dart
// ❌ 절대 금지!
import 'package:sherpa_app/core/theme/app_colors.dart';  // 레거시!
import 'package:sherpa_app/features/daily_record/constants/record_colors.dart';  // 레거시!

AppColors.primary      // 사용하지 마세요!
RecordColors.blue      // 사용하지 마세요!
```

---

### 1.2 ModernColors 전체 팔레트

#### 주요 브랜드 색상
```dart
ModernColors.primary        // #2563EB - 메인 브랜드 블루
ModernColors.primaryLight   // #60A5FA - 밝은 블루
ModernColors.primaryDark    // #1E40AF - 어두운 블루
```

#### 시맨틱 색상
```dart
ModernColors.success        // #10B981 - 성공/긍정
ModernColors.warning        // #F59E0B - 경고
ModernColors.error          // #EF4444 - 에러/위험
ModernColors.info           // #3B82F6 - 정보
```

#### 배경 및 표면
```dart
ModernColors.background     // #F9FAFB - 앱 배경
ModernColors.surface        // #FFFFFF - 카드 배경
ModernColors.surfaceLight   // #F3F4F6 - 밝은 표면
ModernColors.surfaceDark    // #E5E7EB - 어두운 표면
```

#### 텍스트
```dart
ModernColors.textPrimary    // #111827 - 주요 텍스트
ModernColors.textSecondary  // #6B7280 - 보조 텍스트
ModernColors.textDisabled   // #9CA3AF - 비활성 텍스트
```

#### 테두리
```dart
ModernColors.border         // #E5E7EB - 기본 테두리
ModernColors.borderLight    // #F3F4F6 - 밝은 테두리
ModernColors.borderDark     // #D1D5DB - 어두운 테두리
```

---

### 1.3 능력치별 색상 (게임 시스템)

```dart
ModernColors.stamina        // #EF4444 - 체력 (빨강)
ModernColors.knowledge      // #3B82F6 - 지식 (파랑)
ModernColors.sociality      // #10B981 - 사교성 (초록)
ModernColors.willpower      // #F59E0B - 의지 (주황)
ModernColors.technique      // #8B5CF6 - 기술 (보라)
```

---

## Part 2: Sherpi AI 시스템

### 2.1 Sherpi 감정 시스템 (6가지)

#### 감정 종류
```dart
enum SherpiEmotion {
  normal,      // 😊 기본 상태
  cheering,    // 🎉 응원/축하
  proud,       // 😌 자랑스러움
  thinking,    // 🤔 생각 중
  surprised,   // 😲 놀람
  concerned,   // 😟 걱정/위로
}
```

**위치**: `lib/shared/providers/global_sherpi_provider.dart`

---

#### 감정별 사용 시나리오

| 감정 | 아이콘 | 사용 시나리오 | 메시지 톤 |
|------|--------|---------------|-----------|
| **normal** | 😊 | 일반 상황, 기본 안내 | 밝고 친근함 |
| **cheering** | 🎉 | 레벨업, 등반 성공, 퀘스트 완료 | 열정적이고 축하하는 |
| **proud** | 😌 | 연속 목표 달성, 큰 성취 | 따뜻하고 자랑스러운 |
| **thinking** | 🤔 | 전략 제안, 분석 제공 | 논리적이고 조언하는 |
| **surprised** | 😲 | 예상 밖 성취, 희귀 보상 | 놀랍고 기쁨 |
| **concerned** | 😟 | 등반 실패, 슬픈 감정 일기 | 위로하고 격려하는 |

---

### 2.2 Sherpi 컨텍스트 시스템 (5가지)

```dart
enum SherpiContext {
  levelUp,        // 레벨업 달성
  questComplete,  // 퀘스트 완료
  climbSuccess,   // 등반 성공
  meeting,        // 모임 참여
  dailyGoal,      // 일일 목표 달성
}
```

---

#### 컨텍스트별 메시지 예시

**levelUp** (레벨업):
```
감정: cheering 🎉
메시지: "와! 레벨 {level}로 올랐어요! 이제 {newTitle} 칭호를 받으셨어요!
앞으로 더 높은 산에 도전할 수 있게 되었답니다! 🏔️"
```

**questComplete** (퀘스트 완료):
```
감정: proud 😌
메시지: "오늘도 퀘스트를 완벽하게 완료하셨네요!
{xp}XP와 {points}포인트를 획득하셨어요. 꾸준한 모습이 정말 멋져요!"
```

**climbSuccess** (등반 성공):
```
감정: cheering 🎉
메시지: "{mountainName} 등반 성공! 🎉
난이도 {difficulty}의 산을 {successProbability}% 확률로 정복하셨어요!
{xp}XP와 {points}포인트를 획득하셨습니다!"
```

**meeting** (모임 참여):
```
감정: normal 😊
메시지: "{meetingName} 모임에 참여하셨군요!
새로운 사람들과의 만남은 언제나 설레는 일이에요.
사교성 능력치가 성장할 기회랍니다! 🤝"
```

**dailyGoal** (일일 목표):
```
감정: proud 😌
메시지: "오늘의 5가지 목표를 모두 달성하셨어요!
200XP, 50포인트, 그리고 의지 0.1 상승!
{consecutiveDays}일 연속 달성 중이에요! 대단해요! 🔥"
```

---

### 2.3 Sherpi 메시지 톤 규칙

#### 기본 원칙
1. **존댓말 사용**: "~세요", "~랍니다"
2. **이모지 활용**: 감정 표현 강화
3. **구체적 데이터**: 숫자와 수치 명시
4. **긍정적 프레임**: 실패도 성장 기회로 표현

---

#### 메시지 길이 가이드
- **짧은 메시지** (1-2줄): 일반 활동, 간단한 축하
- **중간 메시지** (2-3줄): 중요 성취, 분석 제공
- **긴 메시지** (3-5줄): 레벨업, 큰 성취, 상세 피드백

---

#### 데이터 기반 피드백 예시 (txt 파일 기반)

**운동 기록 피드백**:
```
"오늘은 60분 힘든 강도의 러닝으로 350kcal 소모!
엔돌핀을 팍팍 터뜨려 스트레스가 사라졌을 거에요!
박수 증가(+90bpm)와 학습능력 향상(BDNF 36% 증가)의 효과도 있어요!"
```

**독서 기록 피드백**:
```
"지난주 독서를 262페이지나 하셨네요!
이번 주는 100페이지 독서와 영화 한 편 어떠세요?
새로운 관점을 접할 좋은 기회가 될 거예요! 📚🎬"
```

**정서적 지지 (슬픔 감정)**:
```
감정: concerned 😟
"비 온 뒤 무지개가 뜨듯, 내일은 더 밝은 날이 올 거예요.
지금은 힘들어도 괜찮아요. 천천히 가도 괜찮답니다.
저는 항상 당신 곁에 있어요. 💙"
```

---

### 2.4 Sherpi API 사용법

**위치**: `lib/shared/providers/global_sherpi_provider.dart`

```dart
// 즉시 메시지 표시 (정적 메시지)
ref.read(sherpiProvider.notifier).showInstantMessage(
  context: SherpiContext.levelUp,
  customDialogue: '레벨업 축하해요!',
  emotion: SherpiEmotion.cheering,
  duration: Duration(seconds: 5),
);

// 컨텍스트 기반 메시지 (동적 생성)
ref.read(sherpiProvider.notifier).showMessage(
  context: SherpiContext.questComplete,
  userContext: userContext,
  gameContext: gameContext,
);

// 게임 관련 메시지
ref.read(sherpiProvider.notifier).showGameMessage(
  context: context,
  gameData: {
    'mountainName': '북한산',
    'xp': 150,
    'points': 80,
  },
);

// 메시지 숨기기
ref.read(sherpiProvider.notifier).hideMessage();

// 감정 변경
ref.read(sherpiProvider.notifier).changeEmotion(
  SherpiEmotion.cheering,
);
```

---

## Part 3: UI 컴포넌트 패턴

### 3.1 표준 앱 바 (SherpaCleanAppBar)

```dart
SherpaCleanAppBar(
  title: 'Page Title',
  backgroundColor: ModernColors.background,
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {},
    ),
  ],
)
```

**위치**: `lib/shared/widgets/sherpa_clean_app_bar.dart`

---

### 3.2 애니메이션 버튼 (SherpaButton)

```dart
SherpaButton(
  text: 'Continue',
  onPressed: () {
    // 자동으로 haptic feedback 제공
  },
  backgroundColor: ModernColors.primary,
  textColor: Colors.white,
)
```

**특징**:
- 자동 햅틱 피드백
- 애니메이션 효과
- 로딩 상태 지원

---

### 3.3 능력치 표시

```dart
// 능력치별 색상 사용
Container(
  decoration: BoxDecoration(
    color: ModernColors.stamina.withOpacity(0.1),
    border: Border.all(color: ModernColors.stamina),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Text('💪', style: TextStyle(fontSize: 24)),
      SizedBox(width: 8),
      Text(
        '체력: ${stats.stamina.toStringAsFixed(1)}%',
        style: TextStyle(
          color: ModernColors.stamina,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
)
```

---

## Part 4: 레이아웃 패턴

### 4.1 카드 기반 레이아웃

```dart
Container(
  decoration: BoxDecoration(
    color: ModernColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 카드 내용
    ],
  ),
)
```

---

### 4.2 섹션 헤더

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Text(
    'Section Title',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: ModernColors.textPrimary,
    ),
  ),
)
```

---

## Part 5: 애니메이션 패턴

### 5.1 flutter_animate 사용

```dart
import 'package:flutter_animate/flutter_animate.dart';

Widget.animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.2, end: 0)
```

**주요 애니메이션**:
- `fadeIn()`: 페이드 인
- `slideY()`: 세로 슬라이드
- `shimmer()`: 반짝이는 효과

---

### 5.2 Lottie 애니메이션

```dart
import 'package:lottie/lottie.dart';

Lottie.asset(
  'assets/animations/success.json',
  width: 200,
  height: 200,
  repeat: false,
)
```

**사용 시나리오**:
- 등반 성공/실패
- 레벨업 축하
- 로딩 화면

---

## Part 6: 접근성 (Accessibility)

### 6.1 시맨틱 라벨

```dart
Semantics(
  label: '등반 시작 버튼',
  button: true,
  child: SherpaButton(
    text: '등반 시작',
    onPressed: () {},
  ),
)
```

---

### 6.2 색상 대비

**ModernColors는 WCAG AA 기준 충족**:
- 텍스트-배경 대비: 최소 4.5:1
- 큰 텍스트-배경 대비: 최소 3:1

---

### 6.3 터치 타겟 크기

**최소 크기**: 48x48 dp
```dart
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(
    icon: Icon(Icons.info),
    onPressed: () {},
  ),
)
```

---

## Part 7: 반응형 디자인

### 7.1 화면 크기 대응

```dart
// MediaQuery 사용
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < 600;

// 반응형 패딩
EdgeInsets.symmetric(
  horizontal: isMobile ? 16 : 32,
  vertical: 16,
)

// 반응형 그리드
GridView.count(
  crossAxisCount: isMobile ? 2 : 4,
  children: [...],
)
```

---

## Part 8: SKILL.md 작성 시 참고사항

### 8.1 Role 3 (UI/UX Guardian) 작성 시

**필수 검증 항목**:
1. ✅ ModernColors 사용 여부
2. ❌ AppColors/RecordColors 사용 금지
3. ✅ Sherpi 감정-컨텍스트 조합 적절성
4. ✅ 접근성 기준 충족 (대비, 터치 크기)
5. ✅ 애니메이션 성능 (60fps 유지)

**SKILL.md 예시**:
```markdown
## 활성화 조건
- "UI 디자인 검증해줘"
- "ModernColors 사용 확인"
- "Sherpi 감정 적절한지 확인"

## 검증 프로세스
1. `import` 문에서 AppColors/RecordColors 검색
2. ModernColors 사용 확인
3. Sherpi 감정-컨텍스트 조합 검증
4. 접근성 기준 확인 (색상 대비, 터치 크기)
5. 애니메이션 성능 확인
```

---

### 8.2 Role 5 (Fullstack Implementer) 작성 시

**UI 컴포넌트 작성 체크리스트**:
```dart
// ✅ 체크리스트
// [ ] ModernColors만 사용
// [ ] Sherpi 감정 적절히 설정
// [ ] Sherpi 메시지 톤 규칙 준수
// [ ] 접근성 라벨 추가
// [ ] 터치 타겟 48x48 이상
// [ ] 색상 대비 4.5:1 이상
// [ ] 애니메이션 60fps 유지
// [ ] 반응형 레이아웃 적용
```

---

## Part 9: 실전 예제

### 9.1 등반 성공 화면

```dart
class ClimbSuccessScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: SherpaCleanAppBar(
        title: '등반 성공!',
      ),
      body: Column(
        children: [
          // Lottie 애니메이션
          Lottie.asset('assets/animations/success.json')
            .animate()
            .fadeIn(),

          // Sherpi 메시지
          SherpiMessageCard(
            emotion: SherpiEmotion.cheering,
            message: '북한산 등반 성공! 🎉',
          ),

          // 보상 카드
          RewardCard(
            xp: 150,
            points: 80,
            statIncreases: {'stamina': 0.3},
          ).animate().slideY(),

          // 계속하기 버튼
          SherpaButton(
            text: '다음 산 도전하기',
            onPressed: () {},
            backgroundColor: ModernColors.primary,
          ),
        ],
      ),
    );
  }
}
```

---

### 9.2 능력치 표시 위젯

```dart
class StatsDisplay extends StatelessWidget {
  final GlobalStats stats;

  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatRow('💪', '체력', stats.stamina, ModernColors.stamina),
        _buildStatRow('🧠', '지식', stats.knowledge, ModernColors.knowledge),
        _buildStatRow('🛠️', '기술', stats.technique, ModernColors.technique),
        _buildStatRow('🤝', '사교성', stats.sociality, ModernColors.sociality),
        _buildStatRow('🔥', '의지', stats.willpower, ModernColors.willpower),
      ],
    );
  }

  Widget _buildStatRow(String icon, String name, double value, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    color: ModernColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 마지막 업데이트

- **작성일**: 2025-09-08
- **기준 문서**: `CLAUDE.md`, `셰르파 앱 참고내용.txt`
- **기준 코드**: `lib/core/theme/modern_colors.dart`, `lib/shared/providers/global_sherpi_provider.dart`
- **검증 완료**: 실제 코드 확인 완료 ✅

---

## ⚠️ 최종 경고

**절대 잊지 마세요**:
1. **ModernColors만 사용하세요! AppColors/RecordColors 금지!**
2. **Sherpi 감정과 컨텍스트를 적절히 조합하세요!**
3. **접근성 기준을 준수하세요! (대비 4.5:1, 터치 48x48)**
4. **데이터 기반 피드백으로 Sherpi 메시지를 작성하세요!**
