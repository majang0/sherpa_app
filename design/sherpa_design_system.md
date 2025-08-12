# 🏔️ Sherpa App 디자인 시스템

> **"따뜻하고 감정적인, 수제 같은 느낌의 디자인 시스템"**  
> 냉정하고 대량생산적인 느낌을 피하고, 사용자의 성장 여정에 어울리는 감정적 연결감을 만드는 디자인 가이드

## 🎨 디자인 철학

### 핵심 원칙

1. **감정적 연결감 (Emotional Connection)**
   - 사용자의 성장 여정에 공감하는 따뜻한 디자인
   - 차갑고 제도적인 느낌 대신 인간적이고 격려적인 분위기
   - 미세한 상호작용과 기쁨을 주는 요소들

2. **수제 품질감 (Handcrafted Quality)**  
   - 대량생산된 UI 키트 느낌 제거
   - 세심하게 고려된 여백과 비례
   - 유기적이고 자연스러운 모서리와 곡선

3. **깊이 기반 분리 (Depth-Based Separation)**
   - 얇은 테두리 대신 그림자와 색상 대비 활용
   - 자연스러운 조명과 입체감으로 시각적 계층 구조
   - 호흡감 있는 공간과 부드러운 전환

4. **프리미엄 느낌 (Premium Feel)**
   - 높은 품질의 소재감과 마감
   - 적절한 여백으로 여유롭고 편안한 느낌
   - 일관된 브랜드 경험과 세련된 디테일

---

## 🌟 그림자 시스템 (Shadow System)

### 그림자 철학

**얇은 테두리를 완전히 제거하고**, 그림자와 색상 대비로 시각적 분리를 달성합니다.
- ❌ **피해야 할 것**: `Border.all(color: Colors.grey.withOpacity(0.2), width: 1)`  
- ✅ **사용해야 할 것**: `BoxShadow`와 배경색 변화로 자연스러운 깊이감

### 4단계 입체감 시스템

#### Level 0: Flat (평면)
```dart
// 배경, 기본 표면 - 그림자 없음
decoration: BoxDecoration(
  color: ModernColors.background, // #FAFAFA
  borderRadius: BorderRadius.circular(16),
)
```

#### Level 1: Subtle (은은한 분리)  
```dart
// 카드, 컨테이너 - 부드러운 ambient shadow
decoration: BoxDecoration(
  color: ModernColors.surface,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: ModernColors.shadowBase.withOpacity(0.04),
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
  ],
)
```

#### Level 2: Medium (상호작용 요소)
```dart
// 버튼, 인터랙티브 카드 - 명확한 깊이감  
decoration: BoxDecoration(
  color: ModernColors.surface,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: ModernColors.shadowBase.withOpacity(0.06),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ],
)
```

#### Level 3: Raised (강조 요소)
```dart
// 중요한 버튼, 플로팅 액션 버튼 - 강한 입체감
decoration: BoxDecoration(
  color: ModernColors.surface,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: ModernColors.shadowBase.withOpacity(0.10),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ],
)
```

#### Level 4: Floating (플로팅 요소)
```dart
// 모달, 팝업, 드롭다운 - 최고 입체감
decoration: BoxDecoration(
  color: ModernColors.surface,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: ModernColors.shadowBase.withOpacity(0.16),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ],
)
```

---

## 🎨 색상 대비 계층 구조 (Color Contrast Hierarchy)

### 배경 색상 활용

테두리 대신 **배경색 변화**로 시각적 구분을 만듭니다:

```dart
// 페이지 배경
ModernColors.background      // #FAFAFA (가장 어두운 배경)

// 카드 배경  
ModernColors.surface         // #FFFFFF (밝은 카드)

// 상승된 카드
ModernColors.surfaceElevated // #F8FAFC (약간 어두운 카드)

// 기능별 컨텍스트 배경
ModernColors.exercise.withOpacity(0.05)  // 운동 관련 영역
ModernColors.reading.withOpacity(0.05)   // 독서 관련 영역  
ModernColors.diary.withOpacity(0.05)     // 일기 관련 영역
```

### 올바른 대비 패턴

✅ **권장 패턴:**
```dart
Container(
  decoration: BoxDecoration(
    color: ModernColors.surface,           // 밝은 배경
    borderRadius: BorderRadius.circular(16),
    boxShadow: [/* 적절한 그림자 */],
  ),
  child: Container(
    margin: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: ModernColors.background,      // 약간 더 어두운 내부
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

❌ **피해야 할 패턴:**
```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.withOpacity(0.2)), // 얇은 테두리
    borderRadius: BorderRadius.circular(16),
  ),
)
```

---

## 📏 유기적 간격 시스템 (Organic Spacing)

### 호흡감 있는 패딩

감정적 편안함을 위해 **넉넉한 패딩**을 사용합니다:

```dart
// 기본 패딩 (최소)
padding: EdgeInsets.all(16)

// 편안한 패딩 (권장)  
padding: EdgeInsets.all(20)

// 넓은 패딩 (프리미엄 느낌)
padding: EdgeInsets.all(24)

// 비대칭 패딩 (자연스러운 리듬)
padding: EdgeInsets.fromLTRB(24, 20, 24, 24)
```

### 모서리 곡선 (Corner Radius)

```dart
// 부드러운 곡선 (카드, 버튼)
borderRadius: BorderRadius.circular(16)

// 편안한 곡선 (컨테이너)  
borderRadius: BorderRadius.circular(20)

// 작은 요소 (태그, 칩)
borderRadius: BorderRadius.circular(12)

// 원형 (아바타, 아이콘)
borderRadius: BorderRadius.circular(999)
```

---

## 🏗️ 컴포넌트 패턴 (Component Patterns)

### 1. 기본 카드 패턴

```dart
Widget buildModernCard({
  required Widget child,
  Color? backgroundColor,
  int elevation = 1,
}) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: backgroundColor ?? ModernColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: ModernColors.getElevationShadow(elevation),
    ),
    child: child,
  );
}
```

### 2. 상호작용 버튼 패턴

```dart
Widget buildModernButton({
  required String text,
  required VoidCallback onPressed,
  Color? color,
}) {
  return Container(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? ModernColors.primary,
        foregroundColor: Colors.white,
        elevation: 0, // ElevatedButton 기본 그림자 제거
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: ModernColors.getElevationShadow(2),
    ),
  );
}
```

### 3. 정보 섹션 패턴

```dart
Widget buildInfoSection({
  required String title,
  required String subtitle,  
  required Widget child,
  Color? accentColor,
}) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: ModernColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: ModernColors.getElevationShadow(1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (accentColor ?? ModernColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.info_outline,
                color: accentColor ?? ModernColors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: /* title style */),
                  Text(subtitle, style: /* subtitle style */),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        child,
      ],
    ),
  );
}
```

---

## 🔄 마이그레이션 가이드 (Migration Guide)

### Border.all() → BoxShadow 변환

#### Before (피해야 할 패턴):
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: ModernColors.primary.withOpacity(0.15),
      width: 1,
    ),
  ),
  child: /* content */,
)
```

#### After (권장 패턴):
```dart
Container(
  decoration: BoxDecoration(
    color: ModernColors.surface,
    borderRadius: BorderRadius.circular(16), // 더 부드럽게
    boxShadow: ModernColors.getElevationShadow(1),
  ),
  padding: EdgeInsets.all(20), // 더 넉넉하게
  child: /* content */,
)
```

### 컨텍스트별 변환 예시

#### 1. 목표 아이템 카드
```dart
// Before: 얇은 테두리 + 작은 패딩
Container(
  margin: EdgeInsets.only(bottom: 16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: ModernColors.primary.withOpacity(0.15), width: 1.5),
  ),
  child: Padding(
    padding: EdgeInsets.all(20),
    child: /* content */,
  ),
)

// After: 그림자 + 호흡감 있는 디자인
Container(
  margin: EdgeInsets.only(bottom: 20), // 더 넓은 간격
  decoration: BoxDecoration(
    color: ModernColors.surface,
    borderRadius: BorderRadius.circular(20), // 더 부드러운 곡선
    boxShadow: [
      BoxShadow(
        color: ModernColors.shadowBase.withOpacity(0.06),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Padding(
    padding: EdgeInsets.all(24), // 더 넉넉한 패딩
    child: /* content */,
  ),
)
```

#### 2. 진행률 컨테이너
```dart
// Before: 조건부 테두리 색상
decoration: BoxDecoration(
  color: isCompleted ? ModernColors.success.withOpacity(0.08) : Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: isCompleted
        ? ModernColors.success.withOpacity(0.3)
        : ModernColors.primary.withOpacity(0.2),
    width: 1.5,
  ),
),

// After: 배경 변화 + 그림자 조합
decoration: BoxDecoration(
  color: isCompleted 
      ? ModernColors.success.withOpacity(0.05)  // 더 subtle한 배경
      : ModernColors.surface,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: (isCompleted ? ModernColors.success : ModernColors.primary)
          .withOpacity(0.08),
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
  ],
),
```

---

## ✅ Do's and Don'ts

### ✅ Do's (권장사항)

1. **그림자 사용**
   - BoxShadow로 자연스러운 깊이감 표현
   - 4단계 입체감 시스템 준수
   - 색상과 투명도로 상황별 맥락 제공

2. **넉넉한 공간**
   - 최소 16px, 권장 20-24px 패딩
   - 요소 간 호흡감 있는 마진
   - 터치하기 편한 최소 44px 높이

3. **부드러운 곡선**
   - 16-20px 모서리 반지름
   - 유기적이고 자연스러운 형태
   - 일관된 곡선 시스템

4. **의미 있는 색상**
   - 기능별 컨텍스트 색상 활용
   - 배경색 변화로 시각적 구분
   - 브랜드 색상과 조화로운 팔레트

### ❌ Don'ts (피해야 할 것)

1. **얇은 테두리**
   - `Border.all(width: 1)` 사용 금지
   - 회색 테두리로 구분하는 방식
   - opacity가 낮은 테두리 선

2. **좁은 공간**
   - 8px 이하의 작은 패딩
   - 빽빽하게 붙어있는 요소들
   - 터치하기 어려운 작은 버튼

3. **각진 형태**
   - border-radius 없는 직각 모서리
   - 4-8px의 과도하게 작은 곡선
   - 일관성 없는 곡선 반지름

4. **단조로운 색상**
   - 모든 곳에 같은 흰색 배경
   - 의미 없는 색상 선택
   - 대비가 부족한 텍스트

---

## 🔧 ModernColors 확장 필요사항

현재 `ModernColors` 클래스에 다음 그림자 시스템을 추가해야 합니다:

```dart
// ==================== 그림자 및 깊이 시스템 ====================

/// 그림자 베이스 색상
static const Color shadowBase = Color(0xFF1E293B);  // Slate-800
static const Color shadowSubtle = Color(0xFF0F172A); // Slate-900  
static const Color shadowWarm = Color(0xFF374151);  // Gray-700

/// 그림자 투명도 레벨
static const double shadowSubtleOpacity = 0.04;  // Level 1
static const double shadowLightOpacity = 0.06;   // Level 2  
static const double shadowMediumOpacity = 0.10;  // Level 3
static const double shadowStrongOpacity = 0.16;  // Level 4

/// 입체감 레벨별 그림자 반환
static List<BoxShadow> getElevationShadow(int level) {
  switch (level) {
    case 0:
      return [];
    case 1:
      return [
        BoxShadow(
          color: shadowBase.withOpacity(shadowSubtleOpacity),
          blurRadius: 6,
          offset: Offset(0, 1),
        ),
      ];
    case 2:
      return [
        BoxShadow(
          color: shadowBase.withOpacity(shadowLightOpacity),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ];
    case 3:
      return [
        BoxShadow(
          color: shadowBase.withOpacity(shadowMediumOpacity),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];
    case 4:
      return [
        BoxShadow(
          color: shadowBase.withOpacity(shadowStrongOpacity),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];
    default:
      return getElevationShadow(1);
  }
}
```

---

## 🎯 적용 우선순위

1. **🔥 High Priority**
   - daily_quest_widget.dart (현재 작업 중)
   - 기본 카드 컴포넌트들
   - 버튼 및 인터랙티브 요소들

2. **📋 Medium Priority**  
   - 캘린더 위젯들
   - 통계 표시 위젯들
   - 리스트 아이템들

3. **✨ Low Priority**
   - 세부 장식 요소들
   - 애니메이션 개선
   - 미세한 인터랙션 피드백

---

## 🚀 성공 기준

### 사용자 경험 개선
- ✅ "대량생산된" 느낌 제거
- ✅ 따뜻하고 감정적인 디자인 달성  
- ✅ 프리미엄 품질감 구현
- ✅ 시각적 계층구조 명확화

### 기술적 개선
- ✅ 모든 `Border.all()` 제거
- ✅ 그림자 기반 분리 시스템 구축
- ✅ 일관된 디자인 토큰 시스템
- ✅ 유지보수 가능한 컴포넌트 패턴

### 개발자 경험  
- ✅ 명확한 가이드라인과 예시 코드
- ✅ 쉬운 마이그레이션 경로 제공
- ✅ 재사용 가능한 패턴과 유틸리티
- ✅ 디자인 시스템 문서화

---

**💡 다음 단계: ModernColors에 그림자 시스템 추가 → daily_quest_widget.dart 리팩토링 적용**