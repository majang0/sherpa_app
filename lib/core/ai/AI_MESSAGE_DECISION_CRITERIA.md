# 🧠 셰르피 AI 메시지 사용 기준 (명확한 결정 로직)

## 📋 개요

스마트 셰르피 시스템은 사용자 경험을 최적화하기 위해 **90% 즉시 응답 + 10% AI**의 하이브리드 방식을 사용합니다.

## 🎯 4단계 AI 사용 레벨

### 🔥 Level 1: `always` (항상 AI - 100%)
**처리 순서**: 캐시 AI → 실시간 AI → 정적 폴백

**적용 컨텍스트**:
- `SherpiContext.welcome` - 첫 만남, 재복귀
- `SherpiContext.longTimeNoSee` - 7일+ 미접속 후 복귀  
- `SherpiContext.milestone` - 100일, 365일 등 기념일
- `SherpiContext.specialEvent` - 생일, 기념일

**사용 이유**: 감정적 연결이 가장 중요한 특별한 순간

---

### ⭐ Level 2: `important` (조건부 AI - 30-50%)
**처리 순서**: 
- 조건 충족 → 캐시 AI → 실시간 AI
- 조건 미충족 → 정적 메시지

**적용 컨텍스트 & 조건**:

#### `SherpiContext.levelUp`
- **AI 사용**: 레벨 1, 5, 10, 20, 30, 50, 100... (특별 레벨)
- **정적 사용**: 레벨 2, 3, 4, 6, 7, 8, 9... (일반 레벨)

#### `SherpiContext.badgeEarned` 
- **AI 사용**: 첫 3개 뱃지까지
- **정적 사용**: 4번째 뱃지부터

#### `SherpiContext.climbingSuccess`
- **AI 사용**: 첫 3번의 등반 성공 OR 성공률 30% 이하인 어려운 산
- **정적 사용**: 일반적인 등반 성공

#### `SherpiContext.achievement`
- **AI 사용**: 첫 5개 성취까지
- **정적 사용**: 6번째 성취부터

---

### 📱 Level 3: `occasional` (특별 조건만 - 10-20%)
**처리 순서**: 
- 특별 조건 충족 → **캐시된 AI만** (실시간 AI 제외)
- 조건 미충족 OR 캐시 없음 → 정적 메시지

**적용 컨텍스트 & 조건**:

#### `SherpiContext.exerciseComplete`
- **캐시 AI 사용**: 연속 7일, 30일, 100일 OR 총 100회, 500회 달성
- **정적 사용**: 일반 운동 완료

#### `SherpiContext.studyComplete`
- **캐시 AI 사용**: 연속 7일, 30일 OR 총 50권, 100권 달성
- **정적 사용**: 일반 독서 완료

#### `SherpiContext.questComplete`
- **캐시 AI 사용**: 연속 7일, 30일 OR 특별/프리미엄 퀘스트
- **정적 사용**: 일반 퀘스트 완료

---

### 💬 Level 4: `rarely` (거의 정적 - 1%)
**처리 순서**: 
- 99% → 정적 메시지 (즉시)
- 1% → 깜짝 AI (무작위)

**적용 컨텍스트**:
- `SherpiContext.general` - 일반 상호작용
- `SherpiContext.guidance` - 안내 메시지  
- `SherpiContext.dailyGreeting` - 일상 인사
- `SherpiContext.encouragement` - 일반 격려

**깜짝 AI 조건**: `DateTime.now().millisecond % 100 == 0` (1% 확률)

---

## ⚡ 응답 속도 기준

| 메시지 소스 | 응답 시간 | 표시 | 색상 |
|------------|----------|------|------|
| **정적 메시지** | 0ms (즉시) | ⚡ 즉시 | 초록색 |
| **캐시된 AI** | 0ms (즉시) | 🚀 캐시 | 파란색 |  
| **실시간 AI** | 2-4초 | 🤖 AI | 보라색 |

---

## 🔄 캐시 시스템

### 사전 생성 대상
중요한 컨텍스트들의 메시지를 백그라운드에서 미리 생성:
- `welcome`, `levelUp`, `longTimeNoSee`, `milestone`, `specialEvent`

### 캐시 정책
- **만료 기간**: 7일
- **사용자별**: 레벨, 연속 접속일 기반 개인화
- **자동 정리**: 만료된 캐시 자동 삭제

---

## 🎮 실제 사용 예시

### 시나리오 1: 신규 사용자 첫 접속
```
SherpiContext.welcome (always)
→ 캐시 확인 → 없음 → 실시간 AI 생성 (2-3초)
→ 결과: 개인화된 환영 메시지 🤖
```

### 시나리지 2: 레벨 7 달성
```
SherpiContext.levelUp (important)
→ 조건 확인: 레벨 7 (특별 레벨 아님)
→ 결과: 정적 메시지 (즉시) ⚡
```

### 시나리오 3: 레벨 10 달성
```
SherpiContext.levelUp (important)  
→ 조건 확인: 레벨 10 (특별 레벨!)
→ 캐시 확인 → 있음 → 캐시된 AI 사용 (즉시)
→ 결과: 개인화된 축하 메시지 🚀
```

### 시나리오 4: 운동 5일차 완료
```
SherpiContext.exerciseComplete (occasional)
→ 조건 확인: 연속 5일 (특별 조건 아님)
→ 결과: 정적 메시지 (즉시) ⚡
```

### 시나리오 5: 운동 7일차 완료
```
SherpiContext.exerciseComplete (occasional)
→ 조건 확인: 연속 7일 (특별 조건!)
→ 캐시 확인 → 있음 → 캐시된 AI 사용 (즉시)
→ 결과: 개인화된 축하 메시지 🚀
```

### 시나리오 6: 일반적인 격려
```
SherpiContext.encouragement (rarely)
→ 깜짝 AI 확인: 1% 확률
→ 99% 확률: 정적 메시지 (즉시) ⚡
→ 1% 확률: 깜짝 AI 메시지 🤖
```

---

## 🛡️ 안전 장치

1. **항상 폴백**: AI 실패 시 항상 정적 메시지로 폴백
2. **타임아웃**: 실시간 AI 생성 시간 제한
3. **에러 처리**: 네트워크 오류 시 graceful degradation
4. **성능 모니터링**: 응답 시간과 소스 추적

---

## 📊 예상 사용 비율

전체 사용자 상호작용 기준:
- **정적 메시지**: ~85-90% (즉시 응답)
- **캐시된 AI**: ~8-12% (즉시 응답)  
- **실시간 AI**: ~1-3% (2-4초 응답)

→ **전체의 95%+가 즉시 응답**, 사용자 경험 최적화! 🚀