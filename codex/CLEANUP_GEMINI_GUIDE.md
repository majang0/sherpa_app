# Gemini 제거 가이드

**작성일**: 2025-09-20
**목적**: Gemini AI 관련 코드를 완전히 제거하고 OpenAI 중심으로 최적화

---

## 🎯 제거 대상

### 삭제할 파일들
```
lib/core/ai/sources/enhanced_gemini_dialogue_source.dart  ← 삭제
```

### 수정할 파일들
```
lib/features/sherpi/analysis/services/ai_insight_generator.dart  ← Gemini import 제거
```

---

## 📋 제거 작업 목록

### Task 1: Gemini 소스 파일 삭제

```bash
# Gemini dialogue source 삭제
rm lib/core/ai/sources/enhanced_gemini_dialogue_source.dart

# Git에서도 제거
git rm lib/core/ai/sources/enhanced_gemini_dialogue_source.dart
```

---

### Task 2: ai_insight_generator.dart 수정

**현재 코드** (제거 대상):
```dart
import 'package:sherpa_app/core/ai/sources/enhanced_gemini_dialogue_source.dart';

// ...

_geminiSource = EnhancedGeminiDialogueSource();
```

**수정 후 코드**:
```dart
// Gemini import 제거
// import 'package:sherpa_app/core/ai/sources/enhanced_gemini_dialogue_source.dart'; ← 삭제

import 'package:sherpa_app/core/ai/sources/openai_dialogue_source.dart';

class AiInsightGenerator {
  SherpiDialogueSource? _aiSource;
  final AnalysisConfigState _config;

  AiInsightGenerator(this._config) {
    _initializeAISource();
  }

  void _initializeAISource() {
    switch (_config.aiMode) {
      case AnalysisAIConfig.MODE_OPENAI:
        try {
          _aiSource = OpenAIDialogueSource();
          print('✅ OpenAI AI 소스 초기화 완료');
        } catch (e) {
          print('❌ OpenAI 초기화 실패: $e');
          _aiSource = null;
        }
        break;

      case AnalysisAIConfig.MODE_MOCK:
        _aiSource = MockAnalysisAISource();
        print('🎭 Mock AI 소스 사용');
        break;

      case AnalysisAIConfig.MODE_DISABLED:
      default:
        _aiSource = null;
        print('🚫 AI 비활성화 - 규칙 기반 분석만 사용');
    }
  }
}
```

---

### Task 3: 의존성 정리 (선택)

**pubspec.yaml** 확인:
```yaml
dependencies:
  # google_generative_ai 패키지가 있다면 제거 고려
  # google_generative_ai: ^0.x.x  ← 제거
```

Gemini SDK를 다른 곳에서 사용하지 않는다면:
```bash
# pubspec.yaml에서 google_generative_ai 제거 후
flutter pub get
```

---

### Task 4: 테스트 코드 정리

Gemini 관련 테스트가 있다면 제거:

```bash
# Gemini 관련 테스트 검색
grep -r "Gemini\|gemini" test/

# 발견된 테스트 파일 수정 또는 삭제
```

---

## 🔍 제거 확인

### 1. Import 확인
```bash
# Gemini 관련 import가 남아있는지 확인
grep -r "enhanced_gemini_dialogue_source" lib/
grep -r "EnhancedGeminiDialogueSource" lib/
grep -r "google_generative_ai" lib/
```

### 2. 컴파일 테스트
```bash
# 제거 후 컴파일 확인
flutter analyze
dart analyze
```

### 3. 테스트 실행
```bash
# 테스트 통과 확인
flutter test
```

---

## ✅ 체크리스트

- [ ] enhanced_gemini_dialogue_source.dart 파일 삭제
- [ ] ai_insight_generator.dart에서 Gemini import 제거
- [ ] ai_insight_generator.dart에서 Gemini 초기화 코드 제거
- [ ] pubspec.yaml에서 google_generative_ai 의존성 제거 (사용하지 않는 경우)
- [ ] Gemini 관련 테스트 코드 제거
- [ ] flutter analyze 통과
- [ ] flutter test 통과

---

## 📊 제거 후 구조

### AI 모드 (3가지로 단순화)
```
MODE_DISABLED  - AI 완전 비활성화 (기본값)
MODE_MOCK     - Mock AI (테스트용)
MODE_OPENAI   - OpenAI GPT 사용
```

### 파일 구조
```
lib/core/ai/sources/
├── openai_dialogue_source.dart     ← 메인 AI
└── mock_analysis_ai_source.dart    ← 테스트용
```

---

## 🎯 장점

1. **코드 단순화**
   - 하나의 AI 제공자만 관리
   - 유지보수 용이

2. **의존성 감소**
   - Google AI SDK 제거
   - 빌드 크기 감소

3. **일관성 향상**
   - OpenAI API 하나로 통일
   - 설정 관리 단순화

---

## 🚨 주의사항

1. **백업 권장**
   ```bash
   git add -A
   git commit -m "🔧 Backup: Gemini 제거 전 상태 저장"
   ```

2. **다른 기능 확인**
   - Gemini를 사용하는 다른 기능이 있는지 확인
   - 있다면 OpenAI로 대체 또는 제거

3. **API 키 관리**
   - OpenAI API 키만 필요
   - Gemini API 키는 환경변수에서 제거

---

**Gemini 제거 준비 완료!** 🧹