# 🎮 셰르파 앱 미니게임 상세 설계서

## 🎯 미니게임 시스템 개요

### 설계 원칙
1. **간단한 조작**: 1-2개 제스처로 플레이 가능
2. **짧은 플레이 시간**: 1-3분 내 완료
3. **즉각적인 피드백**: 실시간 점수와 효과
4. **성장과 연계**: 메인 게임 스탯과 직접 연결
5. **일일 제한**: 과도한 플레이 방지 및 일일 접속 유도

## 🏃 미니게임 #1: 산악 러너 (Mountain Runner)

### 게임 개요
- **장르**: 엔들리스 러너
- **목표**: 장애물을 피하며 최대한 멀리 달리기
- **플레이 시간**: 1-2분
- **일일 제한**: 3회

### 게임플레이 메커니즘
```dart
class MountainRunnerGame {
  // 기본 조작
  void jump() => character.velocity.y = -jumpPower;
  void slide() => character.height *= 0.5;
  void doubleJump() => if (canDoubleJump) jump();
  
  // 장애물 타입
  enum ObstacleType {
    rock,      // 점프로 회피
    branch,    // 슬라이드로 회피
    cliff,     // 더블점프 필요
    bird,      // 타이밍 중요
  }
  
  // 난이도 증가
  void updateDifficulty() {
    speed += 0.1 * (distance / 100);
    obstacleFrequency *= 0.98;
  }
}
```

### UI/UX 디자인
```
┌────────────────────────┐
│  Distance: 523m  x3♥   │  <- 상단 HUD
├────────────────────────┤
│                        │
│         🏃            │  <- 게임 영역
│    ____🪨_____🌲___   │
│////////////////////////│  <- 지형
├────────────────────────┤
│  [JUMP]    [SLIDE]    │  <- 조작 버튼
└────────────────────────┘
```

### 보상 시스템
```yaml
거리별 보상:
  100m 미만: 
    - 체력 EXP +10
    - 코인 +5
  100-300m:
    - 체력 EXP +30
    - 코인 +15
    - 아이템 확률 10%
  300-500m:
    - 체력 EXP +50
    - 코인 +30
    - 아이템 확률 25%
  500m 이상:
    - 체력 EXP +100
    - 코인 +50
    - 희귀 아이템 확률 10%

특별 보상:
  - 일일 최고 기록: 보너스 x2
  - 주간 랭킹 TOP 10: 특별 배지
  - 무피해 달성: 스킬 포인트 +1
```

## 📚 미니게임 #2: 등산 지식 퀴즈 (Peak Wisdom)

### 게임 개요
- **장르**: 퀴즈
- **목표**: 제한 시간 내 최대한 많은 문제 맞추기
- **플레이 시간**: 2-3분
- **일일 제한**: 5회

### 문제 카테고리
```typescript
interface QuizCategory {
  mountainKnowledge: {
    difficulty: 'easy' | 'medium' | 'hard';
    topics: ['산악 용어', '유명 산', '등산 장비', '안전 수칙'];
  };
  healthWellness: {
    topics: ['운동 효과', '영양', '스트레칭', '응급처치'];
  };
  sherpaWorld: {
    topics: ['게임 팁', '캐릭터 스토리', '숨겨진 요소'];
  };
}
```

### 게임 진행 방식
```dart
class QuizGame {
  int timeLimit = 10; // 문제당 10초
  int combo = 0;      // 연속 정답 콤보
  
  void answerQuestion(int choice) {
    if (isCorrect(choice)) {
      combo++;
      score += basePoint * (1 + combo * 0.1);
      timeLimit = max(5, 10 - combo ~/ 3); // 콤보 시 시간 단축
    } else {
      combo = 0;
      timeLimit = 10;
    }
  }
  
  // 힌트 시스템
  void useHint(HintType type) {
    switch(type) {
      case HintType.fiftyFifty:
        removeWrongAnswers(2);
        break;
      case HintType.skipQuestion:
        nextQuestion();
        break;
      case HintType.freezeTime:
        pauseTimer(5);
        break;
    }
  }
}
```

### UI 디자인
```
┌─────────────────────────┐
│  Q.5/10  ⏱10s  💎×3    │
├─────────────────────────┤
│  한국에서 가장 높은 산은? │
│                         │
│  ┌───────────────────┐  │
│  │  A. 설악산         │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │  B. 한라산  ✓     │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │  C. 지리산         │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │  D. 북한산         │  │
│  └───────────────────┘  │
│                         │
│  [💡50:50] [⏭️] [⏸️]   │
└─────────────────────────┘
```

## 🎯 미니게임 #3: 로프 매듭 마스터 (Knot Master)

### 게임 개요
- **장르**: 퍼즐/리듬
- **목표**: 제시된 매듭 패턴을 정확히 따라하기
- **플레이 시간**: 1-2분
- **일일 제한**: 3회

### 게임플레이
```dart
class KnotMasterGame {
  List<GesturePattern> patterns = [
    SwipeUp(),
    SwipeDown(),
    CircleClockwise(),
    CircleCounterClockwise(),
    Hold(),
    DoubleTap(),
  ];
  
  void checkPattern(List<Gesture> userInput) {
    double accuracy = calculateAccuracy(userInput, targetPattern);
    
    if (accuracy > 0.9) {
      score += 100;
      showEffect("Perfect!");
    } else if (accuracy > 0.7) {
      score += 50;
      showEffect("Good!");
    } else {
      showEffect("Try Again!");
    }
  }
}
```

### 난이도별 패턴
```
초급 (3-4 동작):
↑ → ↓ ← = "기본 매듭"

중급 (5-6 동작):
↑ ↺ → ↻ ↓ ← = "나비 매듭"

고급 (7-8 동작):
↑ ↺ TAP → HOLD ↻ ↓ ← = "프루식 매듭"

마스터 (9+ 동작 + 시간제한):
복잡한 패턴 + 3초 내 완성
```

## 👥 미니게임 #4: 팀 클라이밍 (Team Climbing)

### 게임 개요
- **장르**: 협동 멀티플레이
- **목표**: 다른 플레이어와 함께 정상 도달
- **플레이 시간**: 3-5분
- **일일 제한**: 5회

### 협동 메커니즘
```dart
class TeamClimbingGame {
  // 역할 분담
  enum PlayerRole {
    leader,    // 경로 개척
    support,   // 로프 관리
    carrier,   // 물자 운반
  }
  
  // 협동 액션
  void performTeamAction(TeamAction action) {
    switch(action) {
      case TeamAction.ropeAssist:
        partner.climbSpeed *= 1.5;
        break;
      case TeamAction.shareSupplies:
        partner.stamina += 20;
        break;
      case TeamAction.encouragement:
        team.morale += 10;
        break;
    }
  }
  
  // 동기화 보너스
  void checkSynchronization() {
    if (allPlayersInSync()) {
      teamScore *= 2;
      unlockSpecialRoute();
    }
  }
}
```

### 소셜 기능
- 친구 초대 시스템
- 길드원 우선 매칭
- 플레이 후 친구 추가
- 베스트 파트너 뱃지

## 💪 미니게임 #5: 의지력 챌린지 (Will Power)

### 게임 개요
- **장르**: 인내/지구력
- **목표**: 점점 어려워지는 도전 버티기
- **플레이 시간**: 무제한 (평균 2-3분)
- **일일 제한**: 1회

### 도전 타입
```dart
class WillPowerChallenge {
  // 터치 홀드 챌린지
  void touchHoldChallenge() {
    // 화면을 계속 터치하고 있기
    // 방해 요소: 가짜 경고, 시각적 방해
    duration = getCurrentHoldTime();
    if (duration > personalBest) {
      rewards.add(SpecialReward());
    }
  }
  
  // 패턴 기억 챌린지
  void patternMemoryChallenge() {
    // 점점 길어지는 패턴 기억하기
    patternLength++;
    showPattern(patternLength);
    hidePattern();
    checkUserInput();
  }
  
  // 집중력 챌린지
  void focusChallenge() {
    // 움직이는 타겟 따라가기
    targetSpeed += 0.1;
    distractionLevel++;
    checkAccuracy();
  }
}
```

## 🎰 특별 이벤트 미니게임

### 주말 레이드: 거대 얼음벽 정복
```dart
class WeekendRaidGame {
  int totalHP = 1000000; // 전체 유저가 함께 깎아야 할 HP
  
  void playerAttack(String userId, int damage) {
    totalHP -= damage;
    leaderboard.update(userId, damage);
    
    if (totalHP <= 0) {
      distributeRewards(leaderboard.getTopPlayers());
      announceVictory();
    }
  }
}
```

### 시즌 이벤트: 보물찾기
- 맵 곳곳에 숨겨진 보물
- 힌트는 일일 퀘스트로 획득
- 시즌 종료 시 최다 수집자 특별 보상

## 📊 미니게임 통합 시스템

### 일일 미니게임 로테이션
```dart
class DailyMiniGameRotation {
  Map<DateTime, List<MiniGame>> schedule = {
    Monday: [MountainRunner, QuizGame, KnotMaster],
    Tuesday: [TeamClimbing, WillPower, MountainRunner],
    Wednesday: [QuizGame, KnotMaster, TeamClimbing],
    // ...
  };
  
  // 보너스 게임
  MiniGame? getBonusGame() {
    if (allDailyGamesCompleted()) {
      return SpecialBonusGame();
    }
    return null;
  }
}
```

### 미니게임 마스터리 시스템
```yaml
마스터리 레벨:
  Bronze:
    - 게임 10회 플레이
    - 기본 보상 x1.1
  
  Silver:
    - 게임 50회 플레이
    - 평균 점수 70% 이상
    - 기본 보상 x1.3
    
  Gold:
    - 게임 100회 플레이
    - 평균 점수 85% 이상
    - 기본 보상 x1.5
    - 특별 스킨 해금
    
  Master:
    - 게임 500회 플레이
    - 평균 점수 95% 이상
    - 기본 보상 x2.0
    - 전용 칭호 및 이펙트
```

## 🏆 리더보드 시스템

### 개인 리더보드
- 일일 TOP 100
- 주간 TOP 100
- 월간 TOP 100
- 역대 TOP 10

### 길드 리더보드
- 길드 총점
- 평균 점수
- 참여율

## 💰 재화 시스템 연동

### 미니게임 전용 재화
```dart
class MiniGameCurrency {
  int tickets = 10;  // 일일 플레이 티켓
  int hints = 5;     // 힌트 아이템
  int boosters = 3;  // 점수 부스터
  
  void dailyReset() {
    tickets = 10;
    // VIP 유저는 추가 티켓
    if (user.isVIP) tickets += 5;
  }
}
```

### 메인 게임과의 교환
- 미니게임 코인 100 = 메인 게임 코인 10
- 미니게임 경험치 = 해당 스탯 경험치
- 특별 아이템은 양방향 사용 가능

## 🎨 비주얼 & 사운드

### 비주얼 스타일
- **전체적인 톤**: 밝고 캐주얼한 2D 그래픽
- **색상 팔레트**: 셰르파 앱 메인 컬러 활용
- **애니메이션**: 부드러운 트윈 애니메이션
- **이펙트**: 파티클, 컨페티, 광원 효과

### 사운드 디자인
- **BGM**: 경쾌하고 중독성 있는 루프
- **효과음**: 즉각적이고 만족스러운 피드백
- **음성**: 셰르피의 응원 음성

## 📱 기술 구현

### Flutter 게임 엔진 선택
```dart
// Flame 엔진 활용
dependencies:
  flame: ^1.10.0
  flame_audio: ^2.0.0
  flame_forge2d: ^0.15.0  // 물리엔진
```

### 성능 최적화
```dart
class GameOptimization {
  // 오브젝트 풀링
  final objectPool = Pool<GameObject>(
    create: () => GameObject(),
    reset: (obj) => obj.reset(),
  );
  
  // 프레임 제한
  static const targetFPS = 60;
  
  // 메모리 관리
  void cleanupResources() {
    removeOffscreenObjects();
    clearUnusedTextures();
  }
}
```

### 오프라인 지원
- 미니게임 기본 플레이는 오프라인 가능
- 점수는 로컬 저장 후 온라인 시 동기화
- 리더보드와 멀티플레이는 온라인 필수

---

*이 문서는 셰르파 앱의 미니게임 시스템 상세 설계를 담고 있습니다. 각 미니게임은 메인 게임과 유기적으로 연결되어 전체적인 게임 경험을 풍부하게 만들 것입니다.*