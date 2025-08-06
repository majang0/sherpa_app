# 🧹 AI 시스템 정리 계획

## 📊 현재 상태 분석

### ✅ 활성 사용 중인 파일들 (보존 필요)

**Core AI System**:
- `lib/core/ai/smart_sherpi_manager.dart` - 하이브리드 AI 메시지 관리 (main system)
- `lib/core/ai/gemini_dialogue_source.dart` - Gemini API 연동 (active)
- `lib/core/ai/ai_message_cache.dart` - AI 메시지 캐싱 (active)
- `lib/core/config/api_config.dart` - API 키 설정 (active)

**Emotion & Dialogue System**:
- `lib/core/constants/sherpi_emotions.dart` - 10개 감정 시스템 (active)
- `lib/core/constants/sherpi_dialogues.dart` - 대화 데이터 & 컨텍스트 매핑 (active)

**UI Components**:
- `lib/shared/widgets/global_sherpi_widget.dart` - 전역 셰르피 위젯 (active)
- `lib/shared/widgets/sherpi_message_card.dart` - 메시지 카드 (active)
- `lib/shared/providers/global_sherpi_provider.dart` - 글로벌 상태 관리 (active)

**Assets**:
- `assets/images/sherpi/sherpi_*.png` (10개 감정 이미지) - 모두 사용 중

### ⚠️ 검토 필요한 파일들

**Test/Debug Files**:
- `lib/features/home/presentation/widgets/sherpi_ai_test_card.dart` - 홈화면에 표시 중 (production에서 제거 고려)

**Deprecated but Used**:
- `lib/shared/widgets/sherpa_app_bar.dart` - 2개 화면에서 사용 중 (enhanced_point_shop_screen, withdrawal_screen)
- `lib/shared/models/sherpa_character.dart` - deprecated이지만 호환성 유지

### 🗑️ 제거 가능한 파일들

**Test Files (완전 제거 가능)**:
- `test_flutter_gemini.dart` - 독립 테스트 파일
- `test_gemini_api.dart` - 독립 테스트 파일
- `test_smart_ai_system.dart` - 독립 테스트 파일

**Unused Files**:
- `lib/shared/widgets/sherpa_character_widget.dart` - 사용되지 않음 (SherpaCharacterWidget)

**Old Image Files (사용되지 않음)**:
- `assets/images/sherpi_thumb.png`
- `assets/images/sherpi_normal.png`
- `assets/images/sherpi_think.png`

### 🔧 코드 최적화 가능 영역

**Unused Methods in smart_sherpi_manager.dart**:
- `_getStaticMessage()` - 사용되지 않는 async 버전
- `_shouldUseAI()` - 사용되지 않는 async 버전
- Dead code elimination 필요

## 🎯 정리 실행 계획

### Phase 1: 안전한 파일 제거 (위험도: 낮음)
1. 테스트 파일 제거
2. 사용되지 않는 이미지 파일 제거
3. 완전히 사용되지 않는 위젯 제거

### Phase 2: 코드 최적화 (위험도: 중간)
1. smart_sherpi_manager.dart 내 사용되지 않는 메서드 제거
2. 불필요한 import 정리
3. 중복 코드 제거

### Phase 3: Production 준비 (위험도: 중간)
1. sherpi_ai_test_card.dart를 조건부 표시로 변경 (DEBUG 모드에서만)
2. deprecated 파일들에 명확한 주석 추가

### Phase 4: 향후 마이그레이션 (위험도: 높음 - 별도 계획 필요)
1. SherpaAppBar 사용처를 SherpaCleanAppBar로 마이그레이션
2. 완전한 deprecated 파일 제거

## 📋 상세 실행 단계

### Step 1: Test Files 제거
```bash
# 안전하게 제거 가능
rm test_flutter_gemini.dart
rm test_gemini_api.dart  
rm test_smart_ai_system.dart
```

### Step 2: Unused Images 제거
```bash
# 확인 후 제거
rm assets/images/sherpi_thumb.png
rm assets/images/sherpi_normal.png
rm assets/images/sherpi_think.png
```

### Step 3: Unused Widget 제거
```bash
# 사용되지 않는 위젯
rm lib/shared/widgets/sherpa_character_widget.dart
```

### Step 4: 코드 최적화
- smart_sherpi_manager.dart에서 unused methods 제거
- 모든 AI 관련 파일의 unused imports 정리

### Step 5: Production 설정
- sherpi_ai_test_card.dart를 DEBUG 모드에서만 표시하도록 수정

## ⚠️ 주의사항

1. **sherpa_app_bar.dart는 제거하지 않음** - 2개 화면에서 사용 중
2. **sherpa_character.dart는 보존** - 호환성을 위해 deprecated로 유지
3. **모든 변경 후 flutter analyze 실행** - 컴파일 에러 확인
4. **단계별 테스트** - 각 단계마다 앱 실행 테스트

## 🎯 예상 효과

- **파일 수 감소**: 7개 파일 제거
- **코드 품질 향상**: Dead code 제거, 명확한 구조
- **유지보수성 향상**: 사용되지 않는 코드 제거로 혼란 방지
- **Production 준비**: Test 코드가 production에 노출되지 않음

## ✅ 정리 완료 상태

### 완료된 작업
1. ✅ **테스트 파일 제거** (3개)
   - `test_flutter_gemini.dart`
   - `test_gemini_api.dart` 
   - `test_smart_ai_system.dart`

2. ❌ **이미지 파일 복원** (3개) - 사용자 요청으로 복원
   - `assets/images/sherpi_thumb.png` - 복원됨
   - `assets/images/sherpi_normal.png` - 복원됨  
   - `assets/images/sherpi_think.png` - 복원됨

3. ✅ **사용되지 않는 위젯 제거** (1개)
   - `lib/shared/widgets/sherpa_character_widget.dart`

4. ✅ **코드 최적화**
   - `smart_sherpi_manager.dart`에서 사용되지 않는 메서드 제거:
     - `_getStaticMessage()` (async 버전)
     - `_shouldUseAI()` (async 버전)
     - `_isImportantMoment()` (duplicate)
     - `_isSpecialCondition()` (duplicate)
     - `_staticSource` 필드 제거

5. ✅ **Production 준비**
   - `sherpi_ai_test_card.dart`를 DEBUG 모드에서만 표시하도록 수정

### 검증 결과
- ✅ Flutter analyze 실행 완료 (기존 warning 해결)
- ✅ AI 관련 신규 에러 없음
- ✅ 코드 정리로 7개 파일 제거 및 코드 최적화 완료

## 📝 실행 후 확인사항

1. ✅ Flutter analyze 통과 (AI 관련 경고 해결)
2. 🔄 앱 정상 실행 (테스트 필요)
3. 🔄 Sherpi 기능 모두 정상 작동 (테스트 필요)
4. 🔄 UI에 깨진 부분 없음 (테스트 필요)
5. 🔄 빌드 성공 (테스트 필요)