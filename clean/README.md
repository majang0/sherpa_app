# 🏔️ Sherpa App 코드 최적화 프로젝트

> **프로젝트 시작일**: 2025년 8월 11일  
> **예상 완료일**: 2025년 2월 말 (약 6-8주)  
> **목표**: 코드베이스 35% 감소, 성능 30% 향상

## 📋 프로젝트 개요

셰르파 앱은 현재 **156,319줄**의 Flutter 코드로 구성된 대규모 모바일 애플리케이션입니다. 이 최적화 프로젝트는 코드 품질 향상, 유지보수성 개선, 성능 최적화를 목표로 합니다.

### 현재 상태
- 📊 **코드 규모**: 156,319 lines
- 📁 **Feature 모듈**: 14개
- 🔄 **Provider 파일**: 15개 (평균 800줄)
- 🎨 **2025 버전 컴포넌트**: 35개 (중복)
- ⚠️ **1000줄 이상 파일**: 30개

### 목표 상태
- 📊 **코드 규모**: ~100,000 lines (35% 감소)
- 📁 **Feature 모듈**: 10개 (통합 및 정리)
- 🔄 **Provider 파일**: 25개 (평균 200줄)
- 🎨 **컴포넌트 시스템**: 통합 완료
- ✅ **파일 크기**: 모두 500줄 이하

## 🗂️ 문서 구조

```
clean/
├── README.md                      # 이 파일 (프로젝트 개요)
├── OPTIMIZATION_PLAN.md           # 전체 최적화 계획서
├── PHASE1_CHECKLIST.md           # Phase 1 실행 체크리스트
├── PROVIDER_REFACTORING_GUIDE.md # Provider 리팩토링 가이드
└── COMPONENT_MIGRATION_MAP.md    # 컴포넌트 마이그레이션 매핑
```

## 🚀 Quick Start

### 1. 즉시 시작 가능한 작업 (Today!)

```bash
# 1. 백업 브랜치 생성
git checkout -b optimization/backup-20250111
git push origin optimization/backup-20250111

# 2. Phase 1 브랜치 생성
git checkout -b optimization/phase1

# 3. 개발용 파일 제거 (약 4,000줄 감소)
rm lib/shared/presentation/screens/component_viewer_screen.dart
rm lib/features/sherpi_personalization/*_usage_example.dart
rm lib/core/utils/phase1_performance_benchmark.dart

# 4. 변경사항 커밋
git add .
git commit -m "chore: 개발용 파일 제거 (Phase 1-1)"

# 5. 빌드 테스트
flutter clean && flutter pub get
flutter build apk --debug
```

**예상 결과**: 즉시 4,000줄 감소, APK 크기 5% 감소

### 2. 이번 주 목표

| 일자 | 작업 | 예상 감소 |
|------|------|-----------|
| Day 1 | 개발용 파일 제거 | -4,000줄 |
| Day 2 | SharedPreferences.clear() 제거 | -500줄 |
| Day 3 | TODO/FIXME 정리 | -200줄 |
| Day 4 | Deprecated 코드 제거 | -300줄 |
| Day 5 | 테스트 및 검증 | - |

**주간 목표**: 5,000줄 감소, 성능 10% 향상

## 📊 전체 로드맵

### 🟢 Phase 1: Quick Wins (Week 1)
**목표**: 불필요한 코드 15,000줄 제거  
**문서**: [PHASE1_CHECKLIST.md](./PHASE1_CHECKLIST.md)

- ✅ 개발용 코드 제거
- ✅ 샘플 데이터 조건부 처리
- ✅ TODO/FIXME 해결
- ✅ Deprecated 메서드 제거

### 🟡 Phase 2: Provider 리팩토링 (Week 2-3)
**목표**: God Object 제거, 의존성 정리  
**문서**: [PROVIDER_REFACTORING_GUIDE.md](./PROVIDER_REFACTORING_GUIDE.md)

- [ ] GlobalUserProvider 분할 (2,331줄 → 5개 파일)
- [ ] 이벤트 기반 통신 구현
- [ ] Provider 간 의존성 제거
- [ ] 테스트 커버리지 80% 달성

### 🟡 Phase 3: 컴포넌트 통합 (Week 4-5)
**목표**: 2025 버전으로 통합, 중복 제거  
**문서**: [COMPONENT_MIGRATION_MAP.md](./COMPONENT_MIGRATION_MAP.md)

- [ ] Core 컴포넌트 마이그레이션
- [ ] Feature 컴포넌트 통합
- [ ] 신규 컴포넌트 활용
- [ ] 기존 컴포넌트 제거

### 🔴 Phase 4: Feature 재구성 (Week 6-7)
**목표**: Sherpi 통합, Meeting 모델 통합

- [ ] Sherpi 6개 모듈 → 1개 통합 모듈
- [ ] Meeting 3개 모델 → 1개 기본 + 확장
- [ ] 중복 기능 제거
- [ ] 모듈 간 명확한 경계 설정

### 🔵 Phase 5: 성능 최적화 (Week 8)
**목표**: 30% 성능 향상

- [ ] 빌드 최적화
- [ ] 런타임 최적화
- [ ] 메모리 최적화
- [ ] 번들 크기 최적화

## 📈 진행 상황 추적

### 주요 메트릭

| 메트릭 | 현재 | 목표 | 진행률 |
|--------|------|------|--------|
| 코드 라인 수 | 156,319 | 100,000 | 0% |
| APK 크기 | 20MB | 15MB | 0% |
| 빌드 시간 | 120초 | 80초 | 0% |
| 시작 시간 | 3초 | 2초 | 0% |
| Provider 파일 | 15개 | 25개 | 0% |
| 테스트 커버리지 | 30% | 80% | 0% |

### 주간 체크포인트

- [ ] **Week 1**: Phase 1 완료, 15,000줄 감소
- [ ] **Week 3**: Phase 2 완료, Provider 리팩토링
- [ ] **Week 5**: Phase 3 완료, 컴포넌트 통합
- [ ] **Week 7**: Phase 4 완료, Feature 재구성
- [ ] **Week 8**: Phase 5 완료, 성능 최적화

## 🛠️ 도구 및 스크립트

### 코드 분석
```bash
# 파일별 라인 수 분석
find lib -name "*.dart" -type f -exec wc -l {} + | sort -rn | head -30

# TODO/FIXME 찾기
grep -r "TODO\|FIXME" lib/

# 사용되지 않는 import 찾기
flutter pub run dart_code_metrics:metrics analyze lib
```

### 성능 측정
```bash
# APK 크기 확인
flutter build apk --analyze-size

# 빌드 시간 측정
time flutter build apk

# 메모리 프로파일링
flutter pub global run devtools
```

## ⚠️ 위험 관리

### 높은 위험도 작업
1. **Provider 리팩토링** - 앱 전체에 영향
2. **컴포넌트 마이그레이션** - UI 변경
3. **Feature 재구성** - 기능 영향

### 대응 전략
1. **Feature Flag 사용** - 점진적 롤아웃
2. **백업 브랜치 유지** - 즉시 롤백 가능
3. **A/B 테스팅** - 사용자 영향 최소화

## 👥 팀 협업

### 역할 분담 제안
- **Lead Developer**: Provider 리팩토링 주도
- **UI Developer**: 컴포넌트 마이그레이션
- **QA Engineer**: 테스트 및 검증
- **DevOps**: 빌드 및 배포 최적화

### 커뮤니케이션
- **일일 스탠드업**: 진행 상황 공유
- **주간 리뷰**: Phase 완료 검토
- **Slack 채널**: #sherpa-optimization

## 📝 다음 단계

### 즉시 실행 (Today)
1. ✅ 이 문서를 팀과 공유
2. ✅ Phase 1 브랜치 생성
3. ✅ 개발용 파일 제거 시작

### 이번 주
1. ⏳ Phase 1 완료
2. ⏳ 성능 벤치마크 수립
3. ⏳ Phase 2 준비

### 다음 주
1. 📅 Provider 리팩토링 시작
2. 📅 테스트 작성
3. 📅 문서 업데이트

## 💬 문의 및 피드백

이 최적화 프로젝트에 대한 질문이나 제안사항이 있으시면 언제든지 문의해 주세요.

---

> 💡 **Remember**: 이 최적화는 마라톤이지 스프린트가 아닙니다. 안전하고 체계적으로 진행하여 최상의 결과를 달성합시다!

---

**Last Updated**: 2025년 8월 11일  
**Document Version**: 1.0.0  
**Author**: Claude Code with Sequential Thinking