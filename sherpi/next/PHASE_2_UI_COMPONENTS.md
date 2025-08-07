# Phase 2 UI 컴포넌트 라이브러리

## 🧩 개요

Phase 2에서 사용될 재사용 가능한 UI 컴포넌트들의 설계 및 구현 가이드입니다. 기존 셰르파 앱의 디자인 시스템을 확장하여 일관성 있는 사용자 경험을 제공합니다.

---

## 🎨 디자인 시스템 확장

### 색상 팔레트
```dart
// lib/core/theme/phase2_colors.dart
class Phase2Colors {
  // 설정 관련 색상
  static const Color settingsPrimary = Color(0xFF6366F1);   // 인디고
  static const Color settingsAccent = Color(0xFF8B5CF6);    // 바이올렛
  
  // 분석 관련 색상
  static const Color analyticsPrimary = Color(0xFF059669);  // 에메랄드
  static const Color analyticsAccent = Color(0xFF10B981);   // 에메랄드 라이트
  
  // 상호작용 관련 색상
  static const Color interactionPrimary = Color(0xFFEA580C); // 오렌지
  static const Color interactionAccent = Color(0xFFF97316);  // 오렌지 라이트
  
  // 보상 관련 색상
  static const Color rewardPrimary = Color(0xFFDC2626);     // 레드
  static const Color rewardAccent = Color(0xFFF59E0B);      // 골드
  
  // 친밀도 관련 색상
  static const Color intimacyPrimary = Color(0xFFEC4899);   // 핑크
  static const Color intimacyAccent = Color(0xFFF472B6);    // 핑크 라이트
  
  // 그라데이션
  static const LinearGradient settingsGradient = LinearGradient(
    colors: [settingsPrimary, settingsAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient analyticsGradient = LinearGradient(
    colors: [analyticsPrimary, analyticsAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### 타이포그래피
```dart
// lib/core/theme/phase2_text_styles.dart
class Phase2TextStyles {
  static TextStyle get sectionTitle => GoogleFonts.notoSans(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static TextStyle get cardTitle => GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static TextStyle get bodyText => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.5,
  );
  
  static TextStyle get caption => GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey.shade600,
  );
  
  static TextStyle get sherpiDialogue => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.6,
  );
}
```

---

## 🏗️ 기본 컴포넌트

## 1. 섹션 카드 컴포넌트

### SherpaCard
```dart
// lib/shared/widgets/phase2/sherpa_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SherpaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool showShadow;
  final Duration animationDelay;
  
  const SherpaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.showShadow = true,
    this.animationDelay = Duration.zero,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding!,
            child: child,
          ),
        ),
      ),
    ).animate(delay: animationDelay)
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0);
  }
}
```

### StatCard - 통계 표시용
```dart
// lib/shared/widgets/phase2/stat_card.dart
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String? trend;
  final String? sherpiComment;
  final VoidCallback? onTap;
  
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.trend,
    this.sherpiComment,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return SherpaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    trend!,
                    style: Phase2TextStyles.caption.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: Phase2TextStyles.caption),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: Phase2TextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (sherpiComment != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.format_quote, size: 12, color: Colors.blue.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      sherpiComment!,
                      style: Phase2TextStyles.caption.copyWith(
                        color: Colors.blue.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

## 2. 셰르피 관련 컴포넌트

### SherpiSpeechBubble - 셰르피 말풍선
```dart
// lib/shared/widgets/phase2/sherpi_speech_bubble.dart
class SherpiSpeechBubble extends StatelessWidget {
  final String message;
  final SherpiEmotion emotion;
  final bool showTypingAnimation;
  final bool showAvatar;
  final VoidCallback? onTap;
  
  const SherpiSpeechBubble({
    super.key,
    required this.message,
    this.emotion = SherpiEmotion.defaults,
    this.showTypingAnimation = true,
    this.showAvatar = true,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return SherpaCard(
      gradient: LinearGradient(
        colors: [
          Colors.blue.shade50,
          Colors.purple.shade50,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) ...[
            _SherpiAvatar(emotion: emotion),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '셰르피',
                  style: Phase2TextStyles.caption.copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (showTypingAnimation)
                  _TypewriterText(message)
                else
                  Text(message, style: Phase2TextStyles.sherpiDialogue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SherpiAvatar extends StatelessWidget {
  final SherpiEmotion emotion;
  
  const _SherpiAvatar({required this.emotion});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/sherpi/sherpi_${emotion.name}.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.face, color: Colors.blue.shade400);
          },
        ),
      ),
    );
  }
}
```

### SherpiActionButton - 셰르피 액션 버튼
```dart
// lib/shared/widgets/phase2/sherpi_action_button.dart
class SherpiActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isExpanded;
  
  const SherpiActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isExpanded = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                if (isExpanded) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: Phase2TextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .scale(duration: 200.ms, begin: Offset(0.8, 0.8))
      .fadeIn(duration: 200.ms);
  }
}
```

## 3. 상호작용 컴포넌트

### QuickResponseChip - 빠른 응답 칩
```dart
// lib/shared/widgets/phase2/quick_response_chip.dart
class QuickResponseChip extends StatefulWidget {
  final QuickResponse response;
  final VoidCallback onTap;
  final bool isSelected;
  final bool showAnimation;
  
  const QuickResponseChip({
    super.key,
    required this.response,
    required this.onTap,
    this.isSelected = false,
    this.showAnimation = true,
  });
  
  @override
  State<QuickResponseChip> createState() => _QuickResponseChipState();
}

class _QuickResponseChipState extends State<QuickResponseChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - (_controller.value * 0.1);
          
          return Transform.scale(
            scale: scale,
            child: Container(
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? Phase2Colors.interactionPrimary
                    : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: widget.isSelected
                      ? Phase2Colors.interactionPrimary
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.response.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.response.text,
                    style: Phase2TextStyles.bodyText.copyWith(
                      color: widget.isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### SettingsToggle - 설정 토글 컴포넌트
```dart
// lib/shared/widgets/phase2/settings_toggle.dart
class SettingsToggle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final Color? color;
  
  const SettingsToggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: icon != null
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? Phase2Colors.settingsPrimary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color ?? Phase2Colors.settingsPrimary,
                size: 20,
              ),
            )
          : null,
      title: Text(
        title,
        style: Phase2TextStyles.cardTitle,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Phase2TextStyles.caption,
            )
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: color ?? Phase2Colors.settingsPrimary,
      ),
      onTap: () => onChanged(!value),
    );
  }
}
```

## 4. 분석 및 시각화 컴포넌트

### ProgressCircle - 원형 진행률
```dart
// lib/shared/widgets/phase2/progress_circle.dart
class ProgressCircle extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Color color;
  final String? centerText;
  final TextStyle? centerTextStyle;
  final double strokeWidth;
  final Duration animationDuration;
  
  const ProgressCircle({
    super.key,
    required this.progress,
    this.size = 100,
    this.color = Colors.blue,
    this.centerText,
    this.centerTextStyle,
    this.strokeWidth = 6,
    this.animationDuration = const Duration(milliseconds: 1500),
  });
  
  @override
  State<ProgressCircle> createState() => _ProgressCircleState();
}

class _ProgressCircleState extends State<ProgressCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProgressCirclePainter(
              progress: _animation.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(
              child: widget.centerText != null
                  ? Text(
                      widget.centerText!,
                      style: widget.centerTextStyle ?? Phase2TextStyles.cardTitle,
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
```

### TrendChart - 간단한 트렌드 차트
```dart
// lib/shared/widgets/phase2/trend_chart.dart
class TrendChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;
  final bool showDots;
  final String? title;
  
  const TrendChart({
    super.key,
    required this.data,
    this.color = Colors.blue,
    this.height = 120,
    this.showDots = true,
    this.title,
  });
  
  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    return SherpaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: Phase2TextStyles.cardTitle),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: height,
            child: CustomPaint(
              painter: _TrendChartPainter(
                data: data,
                color: color,
                showDots: showDots,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}
```

## 5. 애니메이션 컴포넌트

### CountUpText - 숫자 카운트업 애니메이션
```dart
// lib/shared/widgets/phase2/count_up_text.dart
class CountUpText extends StatefulWidget {
  final int targetValue;
  final TextStyle? style;
  final Duration duration;
  final String suffix;
  
  const CountUpText({
    super.key,
    required this.targetValue,
    this.style,
    this.duration = const Duration(milliseconds: 2000),
    this.suffix = '',
  });
  
  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = IntTween(begin: 0, end: widget.targetValue)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${_animation.value}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
```

### PulsingDot - 맥박 애니메이션 점
```dart
// lib/shared/widgets/phase2/pulsing_dot.dart
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  
  const PulsingDot({
    super.key,
    this.color = Colors.blue,
    this.size = 8,
    this.duration = const Duration(seconds: 1),
  });
  
  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.repeat();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 맥박 효과
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(_opacityAnimation.value * 0.3),
                ),
              ),
            );
          },
        ),
        // 중앙 점
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
      ],
    );
  }
}
```

---

## 📱 화면별 컴포넌트 조합 예시

### 설정 화면 구성
```dart
// 설정 화면에서의 컴포넌트 조합 예시
Column(
  children: [
    SherpiSpeechBubble(
      message: "설정을 변경하면 제가 더 ${사용자명}님께 맞는 모습이 될 수 있어요!",
      emotion: SherpiEmotion.guiding,
    ),
    const SizedBox(height: 20),
    SherpaCard(
      child: Column(
        children: [
          SettingsToggle(
            title: '아침 인사',
            subtitle: '매일 아침 셰르피가 인사를 건네요',
            value: settings.morningGreeting,
            onChanged: (value) => updateSetting('morningGreeting', value),
            icon: Icons.wb_sunny,
            color: Phase2Colors.settingsPrimary,
          ),
          // ... 더 많은 설정들
        ],
      ),
    ),
  ],
)
```

### 분석 화면 구성
```dart
// 분석 화면에서의 컴포넌트 조합 예시
Column(
  children: [
    SherpiSpeechBubble(
      message: analytics.generateSherpiInsight('overview'),
      emotion: SherpiEmotion.happy,
    ),
    const SizedBox(height: 20),
    Row(
      children: [
        Expanded(
          child: StatCard(
            title: '총 활동일',
            value: '${analytics.totalDays}',
            unit: '일',
            icon: Icons.calendar_today,
            color: Phase2Colors.analyticsPrimary,
            sherpiComment: '꾸준함이 최고예요!',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: '현재 레벨',
            value: '${analytics.currentLevel}',
            unit: 'Lv',
            icon: Icons.grade,
            color: Phase2Colors.analyticsAccent,
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),
    TrendChart(
      data: analytics.growthTrend.map((e) => e.value).toList(),
      color: Phase2Colors.analyticsPrimary,
      title: '최근 성장 추이',
    ),
  ],
)
```

---

## 🎯 컴포넌트 사용 가이드라인

### 애니메이션 사용 원칙
1. **진입 애니메이션**: 모든 카드는 `fadeIn` + `slideY` 조합 사용
2. **상호작용 애니메이션**: 버튼은 `scale` 효과로 피드백 제공
3. **데이터 애니메이션**: 숫자는 `CountUpText`로 동적 표시
4. **로딩 상태**: `PulsingDot`으로 대기 상태 표현

### 색상 사용 원칙
1. **기능별 색상**: 각 기능 영역마다 전용 색상 사용
2. **그라데이션**: 중요한 카드나 헤더에만 제한적 사용
3. **접근성**: 모든 색상은 WCAG AA 기준 준수
4. **일관성**: 동일 기능은 항상 동일 색상 사용

### 반응형 고려사항
- 모든 컴포넌트는 최소 너비 320px에서 정상 동작
- 텍스트는 사용자 접근성 설정에 따라 크기 조정
- 터치 영역은 최소 44x44pt 보장

---

**💡 핵심 원칙**: 일관된 디자인 시스템을 통해 사용자가 친숙함을 느끼면서도, 각 기능의 개성은 색상과 아이콘으로 구분하여 직관적인 사용자 경험을 제공합니다.

---

*문서 버전: v1.0*  
*최종 수정: 2025년 1월 27일*