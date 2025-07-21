# 셰르파 앱 디자인 시스템 2025

## 🎨 디자인 철학: "무해한 성장 (Harmless Growth)"

셰르파 앱은 사용자가 압박감 없이 편안하고 부드러운 환경에서 자신의 성장에 집중할 수 있도록 설계되었습니다. "함께 오르는 즐거움"이라는 핵심 가치를 시각적으로 구현하며, 2025년 최신 디자인 트렌드를 반영한 혁신적이면서도 친근한 경험을 제공합니다.

## 🌊 2025 디자인 트렌드 적용 전략

### 1. Glassmorphism Evolution - 다층 유리 효과
- **Multi-layered Depth**: 3개 층의 유리 레이어로 공간적 깊이감 표현
- **Dynamic Blur**: 콘텐츠 중요도에 따라 10px~25px 범위의 가변 블러
- **Luminosity Mapping**: 배경 빛의 강도를 실시간으로 반영하는 투명도 조절

### 2. Bento Box Layout - 모듈형 레이아웃
- **Adaptive Grid**: 8px 기반 그리드 시스템 (Mobile: 4 columns, Tablet: 8 columns)
- **Smart Spacing**: 콘텐츠 밀도에 따라 16px~32px 가변 여백
- **Borderless Cards**: 그림자와 배경색만으로 구분되는 경계 없는 카드

### 3. Micro-interactions 2.0 - 물리 기반 인터랙션
- **Spring Physics**: 모든 애니메이션에 스프링 물리 엔진 적용
- **Haptic Harmony**: 시각적 피드백과 동기화된 햅틱 반응
- **Gesture Anticipation**: 사용자 제스처를 예측하는 선행 애니메이션

### 4. Variable Typography - 동적 가변 폰트
- **Context-aware Scaling**: 콘텐츠 중요도에 따른 폰트 크기 자동 조절
- **Emotional Weight**: 상황에 맞는 폰트 두께 변화 (300~700)

## 🎨 컬러 시스템

### Primary Palette - 주요 색상

| Token | Name | HEX | RGB | Use Case |
|-------|------|-----|-----|----------|
| `primary-500` | Deep Ocean Blue | #2563EB | 37, 99, 235 | 주요 CTA, 브랜드 아이덴티티 |
| `primary-400` | Ocean Blue | #3B82F6 | 59, 130, 246 | 활성 상태, 선택된 요소 |
| `primary-300` | Sky Blue | #60A5FA | 96, 165, 250 | 호버 상태, 보조 강조 |
| `primary-200` | Light Sky | #93C5FD | 147, 197, 253 | 배경 그라데이션 |
| `primary-100` | Pale Sky | #DBEAFE | 219, 234, 254 | 섹션 배경 |
| `primary-50` | Sky Mist | #EFF6FF | 239, 246, 255 | 기본 배경 |

### Neutral Palette - 중립 색상

| Token | Name | HEX | RGB | Use Case |
|-------|------|-----|-----|----------|
| `neutral-900` | Deep Charcoal | #0F172A | 15, 23, 42 | 주요 텍스트 |
| `neutral-700` | Charcoal | #334155 | 51, 65, 85 | 본문 텍스트 |
| `neutral-500` | Stone | #64748B | 100, 116, 139 | 보조 텍스트 |
| `neutral-300` | Light Stone | #CBD5E1 | 203, 213, 225 | 비활성 텍스트 |
| `neutral-100` | Pale Stone | #F1F5F9 | 241, 245, 249 | 구분선 |
| `neutral-50` | White Smoke | #F8FAFC | 248, 250, 252 | 배경 |

### Accent Palette - 강조 색상

| Token | Name | HEX | RGB | Use Case |
|-------|------|-----|-----|----------|
| `success-500` | Forest Green | #10B981 | 16, 185, 129 | 성공, 완료 상태 |
| `success-100` | Mint Cream | #D1FAE5 | 209, 250, 229 | 성공 배경 |
| `warning-500` | Sunset Orange | #F59E0B | 245, 158, 11 | 경고, 주의 |
| `warning-100` | Peach Cream | #FEF3C7 | 254, 243, 199 | 경고 배경 |
| `accent-gold` | Royal Gold | #FCD34D | 252, 211, 77 | 특별 성취, 프리미엄 |
| `accent-purple` | Mystic Purple | #8B5CF6 | 139, 92, 246 | 독서, 지식 관련 |

### Dynamic Gradients - 동적 그라데이션

```css
/* Primary Glow - 주요 빛 번짐 효과 */
linear-gradient(135deg, #2563EB 0%, #60A5FA 50%, #EFF6FF 100%)

/* Success Aura - 성공 오라 */
radial-gradient(circle at center, #10B981 0%, #D1FAE5 60%, transparent 100%)

/* Premium Shine - 프리미엄 광택 */
linear-gradient(45deg, #FCD34D 0%, #FEF3C7 50%, #FCD34D 100%)

/* Ambient Light - 환경광 */
conic-gradient(from 180deg, #EFF6FF 0deg, #DBEAFE 90deg, #EFF6FF 360deg)
```

## ✏️ 타이포그래피 시스템

### Type Scale - 타입 스케일

| Level | Name | Size | Weight | Line Height | Letter Spacing | Use Case |
|-------|------|------|--------|-------------|----------------|----------|
| `display-lg` | Display Large | 48px | 700 | 56px | -0.02em | 메인 타이틀 |
| `display-md` | Display Medium | 36px | 600 | 44px | -0.01em | 섹션 타이틀 |
| `heading-xl` | Heading XL | 30px | 600 | 38px | -0.01em | 페이지 제목 |
| `heading-lg` | Heading Large | 24px | 600 | 32px | 0 | 카드 제목 |
| `heading-md` | Heading Medium | 20px | 500 | 28px | 0 | 서브 제목 |
| `heading-sm` | Heading Small | 18px | 500 | 26px | 0 | 리스트 제목 |
| `body-lg` | Body Large | 16px | 400 | 24px | 0 | 주요 본문 |
| `body-md` | Body Medium | 14px | 400 | 22px | 0.01em | 일반 본문 |
| `body-sm` | Body Small | 13px | 400 | 20px | 0.01em | 보조 설명 |
| `caption` | Caption | 12px | 400 | 18px | 0.02em | 메타 정보 |
| `overline` | Overline | 11px | 500 | 16px | 0.05em | 라벨 |

### Font Family

```css
font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
```

### Dynamic Typography Rules

1. **Responsive Scaling**: 화면 크기에 따라 1.125배율로 자동 조절
2. **Contrast Adaptation**: 배경 밝기에 따라 font-weight 자동 조절 (±100)
3. **Reading Mode**: 긴 텍스트는 자동으로 line-height 1.2배 증가

## 🌟 그림자 및 레이어 시스템

### Shadow Scale - 그림자 스케일

```css
/* elevation-0: 평면 (그림자 없음) */
box-shadow: none;

/* elevation-1: 약간 떠있음 (hover 상태) */
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05), 
            0 1px 2px rgba(0, 0, 0, 0.1);

/* elevation-2: 기본 카드 */
box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 
            0 2px 4px -1px rgba(0, 0, 0, 0.06);

/* elevation-3: 떠있는 버튼 */
box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.08), 
            0 4px 6px -2px rgba(0, 0, 0, 0.05);

/* elevation-4: 모달, 드롭다운 */
box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.08), 
            0 10px 10px -5px rgba(0, 0, 0, 0.04);

/* elevation-5: 팝업, 중요 알림 */
box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
```

### Glass Layers - 유리 레이어

```css
/* glass-base: 기본 유리 효과 */
background: rgba(255, 255, 255, 0.7);
backdrop-filter: blur(10px);
-webkit-backdrop-filter: blur(10px);

/* glass-frosted: 서리낀 유리 */
background: rgba(255, 255, 255, 0.5);
backdrop-filter: blur(20px) saturate(180%);
-webkit-backdrop-filter: blur(20px) saturate(180%);

/* glass-crystal: 크리스탈 유리 */
background: linear-gradient(135deg, 
  rgba(255, 255, 255, 0.8) 0%, 
  rgba(255, 255, 255, 0.4) 100%);
backdrop-filter: blur(15px) brightness(1.1);
-webkit-backdrop-filter: blur(15px) brightness(1.1);
```

### Glow Effects - 빛 번짐 효과

```css
/* glow-primary: 주요 요소 빛 */
box-shadow: 0 0 20px rgba(37, 99, 235, 0.3),
            0 0 40px rgba(37, 99, 235, 0.1);

/* glow-success: 성공 빛 */
box-shadow: 0 0 20px rgba(16, 185, 129, 0.3),
            0 0 40px rgba(16, 185, 129, 0.1);

/* glow-gold: 특별 성취 빛 */
box-shadow: 0 0 30px rgba(252, 211, 77, 0.4),
            0 0 60px rgba(252, 211, 77, 0.2);
```

## 🎬 모션 및 애니메이션 원칙

### Animation Timing - 애니메이션 타이밍

| Type | Duration | Easing | Use Case |
|------|----------|--------|----------|
| `micro` | 100ms | ease-out | 호버, 포커스 |
| `short` | 200ms | cubic-bezier(0.4, 0, 0.2, 1) | 버튼 클릭, 토글 |
| `medium` | 300ms | cubic-bezier(0.4, 0, 0.2, 1) | 모달 열기, 탭 전환 |
| `long` | 500ms | cubic-bezier(0.4, 0, 0.2, 1) | 페이지 전환 |
| `extra-long` | 800ms | cubic-bezier(0.4, 0, 0.2, 1) | 복잡한 전환 |

### Spring Physics - 스프링 물리 상수

```javascript
const springConfig = {
  gentle: { stiffness: 120, damping: 14 },    // 부드러운 바운스
  snappy: { stiffness: 180, damping: 20 },    // 빠른 반응
  bouncy: { stiffness: 200, damping: 10 },    // 탄력적인 움직임
  stiff: { stiffness: 260, damping: 26 }      // 즉각적인 반응
};
```

### Gesture Animations - 제스처 애니메이션

1. **Tap & Hold**: 0.95 scale → 1.05 scale (gentle spring)
2. **Swipe**: translateX with velocity matching
3. **Pinch**: scale with resistance at boundaries
4. **Pull to Refresh**: elastic overscroll with rotation

### Transition Patterns - 전환 패턴

```css
/* fade-scale: 페이드 + 스케일 */
@keyframes fadeScale {
  from { opacity: 0; transform: scale(0.9); }
  to { opacity: 1; transform: scale(1); }
}

/* slide-fade: 슬라이드 + 페이드 */
@keyframes slideFade {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* glow-pulse: 빛 펄스 */
@keyframes glowPulse {
  0%, 100% { opacity: 0.3; transform: scale(1); }
  50% { opacity: 0.6; transform: scale(1.05); }
}
```

## 🎯 컴포넌트별 디자인 가이드

### Buttons - 버튼

```css
/* Primary Button */
.btn-primary {
  background: linear-gradient(135deg, #2563EB 0%, #3B82F6 100%);
  color: white;
  padding: 12px 24px;
  border-radius: 16px;
  font-weight: 500;
  box-shadow: 0 4px 6px -1px rgba(37, 99, 235, 0.2);
  transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(37, 99, 235, 0.3);
}

/* Glass Button */
.btn-glass {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: #2563EB;
  padding: 12px 24px;
  border-radius: 16px;
}
```

### Cards - 카드

```css
/* Base Card */
.card {
  background: white;
  border-radius: 24px;
  padding: 24px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
}

/* Glass Card */
.card-glass {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 24px;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

/* Elevated Card */
.card-elevated {
  background: white;
  border-radius: 24px;
  padding: 24px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.08);
}
```

### Input Fields - 입력 필드

```css
/* Base Input */
.input {
  background: #F8FAFC;
  border: 2px solid transparent;
  border-radius: 16px;
  padding: 12px 16px;
  font-size: 14px;
  transition: all 200ms ease;
}

.input:focus {
  background: white;
  border-color: #2563EB;
  box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
}

/* Glass Input */
.input-glass {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 12px 16px;
}
```

## 🚀 구현 가이드라인

### Flutter ThemeData 적용 예시

```dart
import 'package:flutter/material.dart';

class SherpaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Primary Colors
      primaryColor: const Color(0xFF2563EB),
      primaryColorLight: const Color(0xFF60A5FA),
      primaryColorDark: const Color(0xFF1D4ED8),
      
      // Background Colors
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB),
        secondary: Color(0xFF10B981),
        surface: Colors.white,
        background: Color(0xFFF8FAFC),
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF0F172A),
        onBackground: Color(0xFF0F172A),
        onError: Colors.white,
      ),
      
      // Typography
      fontFamily: 'Noto Sans KR',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
          height: 1.17,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
          height: 1.27,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.44,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.01,
          height: 1.57,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.01,
          height: 1.54,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.02,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05,
          height: 1.45,
        ),
      ),
      
      // Component Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
      ),
    );
  }
}
```

### 주요 위젯 커스터마이징 예시

```dart
// Glass Container
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  
  const GlassContainer({
    required this.child,
    this.blur = 20,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Glow Button
class GlowButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color glowColor;
  
  const GlowButton({
    required this.text,
    required this.onPressed,
    this.glowColor = const Color(0xFF2563EB),
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: glowColor.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: glowColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
```

## 📋 디자인 체크리스트

### 일관성 체크
- [ ] 모든 버튼의 border-radius가 16px 이상인가?
- [ ] 모든 카드의 border-radius가 24px인가?
- [ ] 색상이 정의된 팔레트 내에서만 사용되었는가?
- [ ] 타이포그래피가 정의된 스케일을 따르는가?

### 접근성 체크
- [ ] 텍스트와 배경의 명도 대비가 4.5:1 이상인가?
- [ ] 터치 타겟이 최소 44x44px인가?
- [ ] 모든 인터랙티브 요소에 시각적 피드백이 있는가?

### 성능 체크
- [ ] 애니메이션이 60fps로 부드럽게 작동하는가?
- [ ] 블러 효과가 성능에 영향을 주지 않는가?
- [ ] 이미지가 적절히 최적화되었는가?

### 브랜드 일관성
- [ ] "함께 오르는 즐거움"이 시각적으로 표현되었는가?
- [ ] 무해하고 부드러운 느낌이 전달되는가?
- [ ] 성장과 발전의 긍정적 메시지가 담겨있는가?

## 🎯 최종 목표

이 디자인 시스템은 셰르파 앱을 "2025년 트렌디 앱 디자인 레퍼런스"로 만들기 위한 완성된 가이드라인입니다. 모든 디자인 결정은 사용자에게 압박감 없는 편안한 성장 경험을 제공하는 것을 목표로 하며, 최신 트렌드를 반영하면서도 시대를 초월한 우아함을 추구합니다.