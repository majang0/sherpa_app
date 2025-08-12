# 🎨 Sherpa App 현대적 디자인 원칙 (2024)

> **"미니멀하고 세련된, 감성적이면서도 모던한 디자인"**

## 🔄 디자인 진화: 구식 → 현대적

### ❌ 구식 디자인 요소 (제거해야 할 것들)

1. **과도한 장식**
   - 텍스트 이모지 (🎯, 📖, 💪)
   - 강한 그라데이션
   - 불필요한 테두리
   - 과도한 그림자

2. **구식 타이포그래피**
   - NotoSans (너무 일반적)
   - 단조로운 폰트 굵기 (600, 700만)
   - 일관성 없는 크기

3. **높은 채도의 색상**
   - 진한 파란색 (#2563EB)
   - 강한 대비
   - 원색 위주

### ✅ 현대적 디자인 요소 (적용해야 할 것들)

## 1. 타이포그래피 시스템

### 폰트 선택
```css
/* 우선순위 */
1. Inter        /* 글로벌 스탠다드, 가장 현대적 */
2. Outfit       /* 부드럽고 친근한 */
3. Plus Jakarta Sans  /* 기하학적이고 깔끔한 */
```

### 크기 체계 (Modular Scale)
```dart
// 홀수 사용으로 더 샤프한 느낌
headline: 24px    // 제목
title: 18px       // 섹션 타이틀  
body: 15px        // 본문
caption: 13px     // 부가 정보
micro: 11px       // 최소 텍스트
```

### 굵기 체계
```dart
light: 300       // 부드러운 강조
regular: 400     // 기본 텍스트
medium: 500      // 중간 강조
semibold: 600    // 강한 강조
bold: 700        // 제목
```

## 2. 색상 팔레트

### Primary Colors (채도 낮춤)
```dart
modernPrimary: #5B7FFF    // 부드러운 파란색 (기존 #2563EB)
modernAccent: #8B5CF6     // 보라빛 악센트
modernSuccess: #10B981    // 민트 그린
```

### Neutral Grays (중성 회색)
```dart
gray50:  #F9FAFB   // 배경
gray100: #F3F4F6   // 카드 배경
gray200: #E5E7EB   // 테두리
gray300: #D1D5DB   // 비활성 테두리
gray400: #9CA3AF   // 비활성 텍스트
gray500: #6B7280   // 보조 텍스트
gray600: #4B5563   // 
gray700: #374151   // 
gray800: #1F2937   // 메인 텍스트
gray900: #111827   // 제목
```

### 사용 원칙
- **배경**: 흰색(#FCFCFC) 또는 매우 연한 회색(#F7F8FA)
- **텍스트**: 거의 검은색(#0A0D14) 사용
- **악센트**: 최소한으로, 중요한 곳에만

## 3. 아이콘 시스템

### ❌ 사용하지 말 것
```dart
// 텍스트 이모지
'🎯', '📖', '💪', '🏃', '📚'
```

### ✅ 사용할 것
```dart
// Flutter Icons - Outlined 버전
Icons.flag_outlined
Icons.timer_outlined  
Icons.directions_walk_outlined
Icons.fitness_center_outlined
Icons.auto_stories_outlined
Icons.edit_note_outlined
```

### 아이콘 스타일
- **스타일**: Outlined (filled 대신)
- **크기**: 20px (일관되게)
- **색상**: 모노톤 또는 브랜드 색상
- **스트로크**: 2px

## 4. 컴포넌트 디자인

### 카드 스타일
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),  // 더 작은 radius
    border: Border.all(
      color: ModernColors.gray100,  // 매우 연한 테두리
      width: 1,
    ),
  ),
  padding: EdgeInsets.all(20),  // 넉넉한 패딩
)
```

### 버튼 스타일
```dart
// Primary Button
TextButton(
  style: TextButton.styleFrom(
    backgroundColor: ModernColors.modernPrimary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),  // 적당한 곡선
    ),
  ),
)

// Ghost Button  
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: ModernColors.modernPrimary,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
)
```

### 진행률 표시
```dart
// 원형 프로그레스 (더 현대적)
CircularProgressIndicator(
  value: 0.7,
  strokeWidth: 3,  // 얇은 선
  backgroundColor: ModernColors.gray200,
  valueColor: AlwaysStoppedAnimation(ModernColors.modernPrimary),
)
```

## 5. 레이아웃 원칙

### 여백 시스템
```dart
// 8의 배수 사용
minimal: 8px
small: 12px  
medium: 16px
large: 20px
xlarge: 24px
xxlarge: 32px
```

### 정렬
- **좌측 정렬** 기본
- **중앙 정렬** 최소화
- **비대칭** 레이아웃 활용

### 계층 구조
1. **크기 대비**: 제목 24px vs 본문 15px
2. **굵기 대비**: Bold(700) vs Regular(400)
3. **색상 대비**: 검은색 vs 회색
4. **여백 활용**: 그룹핑과 분리

## 6. 애니메이션

### 전환 시간
```dart
instant: 0ms        // 즉시
fast: 200ms        // 빠른 전환
normal: 300ms      // 기본
slow: 500ms        // 느린 전환
```

### 이징 함수
```dart
Curves.easeOutCubic    // 부드러운 감속
Curves.easeInOutCubic  // 부드러운 가감속
Curves.fastOutSlowIn   // Material 표준
```

## 7. 실제 적용 예시

### Before (구식)
```dart
// 이모지 + NotoSans + 그라데이션 + 강한 색상
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.blue.withOpacity(0.3)),
  ),
  child: Text('🎯 목표 달성!', 
    style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w700)
  ),
)
```

### After (현대적)
```dart
// 아이콘 + Inter + 단색 + 부드러운 색상
Container(
  decoration: BoxDecoration(
    color: ModernColors.modernPrimary,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    children: [
      Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
      SizedBox(width: 8),
      Text('Goal Complete', 
        style: GoogleFonts.inter(
          fontSize: 15, 
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        )
      ),
    ],
  ),
)
```

## 8. 디자인 체크리스트

### 제거해야 할 것들 ❌
- [ ] 모든 텍스트 이모지
- [ ] 강한 그라데이션
- [ ] 높은 채도의 색상
- [ ] 두꺼운 테두리
- [ ] NotoSans 폰트
- [ ] 과도한 그림자

### 적용해야 할 것들 ✅
- [ ] Inter 또는 Outfit 폰트
- [ ] Outlined 아이콘
- [ ] 낮은 채도의 색상
- [ ] 미니멀한 테두리 (1px, gray100)
- [ ] 충분한 여백
- [ ] 명확한 계층 구조

## 9. 성공 지표

### 시각적 개선
- ✅ "양산형" 느낌 제거
- ✅ 현대적이고 세련된 외관
- ✅ 일관된 디자인 언어
- ✅ 깔끔한 계층 구조

### 사용성 개선  
- ✅ 더 읽기 쉬운 텍스트
- ✅ 명확한 상호작용 요소
- ✅ 직관적인 진행 상태
- ✅ 편안한 시각적 경험

---

**💡 핵심 원칙: "Less is More" - 최소한의 요소로 최대의 효과를**