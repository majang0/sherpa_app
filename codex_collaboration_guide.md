# Codex 협업 가이드

## ⚠️ 중요 공지
**Codex Bridge MCP는 Windows 환경에서 정상 작동하지 않습니다.**
- MCP 통합 시도 ❌ (하지 마세요)
- Codex CLI 직접 사용 ✅ (권장)
- 이 가이드는 CLI 직접 사용 기준으로 작성되었습니다

## 🚀 현재 환경
- **Codex CLI**: v0.36.0 (정상 작동)
- **AI 모델**: gpt-5-codex high (고성능 모델 사용 중)
- **실행 방법**: `codex exec "질문 또는 명령"`
- **작업 디렉토리**: 현재 프로젝트 루트에서 실행

## 🤝 Claude + Codex 협업 전략

### 1. 역할 분담 원칙
**Claude Code (나)**
- 실제 코드 작성 및 수정
- 파일 생성/삭제/이동
- 테스트 실행 및 디버깅
- 실시간 구현 작업

**Codex**
- 코드 리뷰 및 검증
- 패턴 분석 및 제안
- 보안 취약점 탐지
- 아키텍처 평가

### 2. 효과적인 협업 패턴

#### 패턴 A: 구현 → 검증
```bash
# 1. Claude가 코드 구현
# 2. Codex로 검증
codex exec "Review the recent changes and identify potential issues"
# 3. 피드백 반영하여 수정
```

#### 패턴 B: 분석 → 구현
```bash
# 1. Codex로 현황 분석
codex exec "Analyze the current code structure and suggest improvements"
# 2. Claude가 제안사항 구현
# 3. Codex로 재검증
```

#### 패턴 C: 병렬 검토
```bash
# Claude가 작업하는 동안 동시에:
codex exec "Find similar patterns in the codebase"
codex exec "Check for potential conflicts with existing code"
```

## 💡 스마트한 Codex 활용법

### 1. 구체적인 컨텍스트 제공
```bash
# ❌ 나쁜 예
codex exec "Fix the bug"

# ✅ 좋은 예
codex exec "In auth.js line 45-60, identify why the JWT token validation fails"
```

### 2. 단계별 질문 분해
```bash
# 복잡한 문제를 작은 단위로
codex exec "1. List all API endpoints in the project"
codex exec "2. Which endpoints lack authentication?"
codex exec "3. Suggest security improvements for each"
```

### 3. 비교 분석 활용
```bash
# Before/After 비교
codex exec "Compare the performance implications of using map() vs for loop in this context"

# 패턴 비교
codex exec "Compare this implementation with industry best practices"
```

## 🔄 효과적인 워크플로우

### 워크플로우 1: 코드 리팩토링
```bash
# Step 1: 현재 상태 분석
codex exec "Analyze code smells in the current module"

# Step 2: 개선 계획 수립
codex exec "Prioritize refactoring tasks by impact and effort"

# Step 3: Claude 구현 → Codex 검증 반복
# Step 4: 최종 검증
codex exec "Verify that refactoring preserved all functionality"
```

### 워크플로우 2: 버그 수정
```bash
# Step 1: 근본 원인 분석
codex exec "Analyze the stack trace and identify root cause"

# Step 2: 해결책 제안
codex exec "Suggest multiple approaches to fix this issue"

# Step 3: 부작용 체크
codex exec "What side effects might this fix cause?"
```

### 워크플로우 3: 새 기능 구현
```bash
# Step 1: 영향 분석
codex exec "How would adding this feature affect existing architecture?"

# Step 2: 구현 패턴 조사
codex exec "Show examples of similar features in well-known projects"

# Step 3: 테스트 전략
codex exec "Generate test scenarios for this new feature"
```

## 🎯 프롬프트 작성 팁

### 명확한 범위 지정
```bash
# 파일 지정
codex exec "In utils/helpers.js, review the date formatting functions"

# 라인 범위 지정
codex exec "Review lines 100-150 in main.py for memory leaks"

# 함수 지정
codex exec "Analyze the performCalculation() function for optimization"
```

### 출력 형식 지정
```bash
# 리스트 형식
codex exec "List all global variables in the project as bullet points"

# 테이블 형식
codex exec "Create a table comparing these three algorithms: time complexity, space complexity, use cases"

# 코드 형식
codex exec "Rewrite this function using modern JavaScript syntax"
```

### 관점 지정
```bash
# 보안 관점
codex exec "From a security perspective, review this authentication flow"

# 성능 관점
codex exec "From a performance perspective, analyze this database query"

# 유지보수 관점
codex exec "From a maintainability perspective, evaluate this class structure"
```

## ⚡ 실시간 협업 시나리오

### 시나리오: 복잡한 버그 수정
```bash
# Claude 작업 중...
"user_auth.js 수정 중입니다..."

# 동시에 터미널에서:
codex exec "Find all places where user_auth is imported"
codex exec "Check if changing this function signature breaks anything"

# 결과를 Claude에게 전달
"Codex 분석 결과, 3개 파일에서 영향받습니다..."
```

### 시나리오: 성능 최적화
```bash
# 1. Codex로 병목 지점 찾기
codex exec "Profile this function and identify bottlenecks"

# 2. Claude가 최적화 구현
"반복문을 Map으로 변경하고..."

# 3. Codex로 개선 확인
codex exec "Compare performance: old vs new implementation"
```

## 🚫 피해야 할 패턴

### 1. 너무 광범위한 요청
```bash
# ❌ 피하세요
codex exec "Improve the entire application"

# ✅ 구체적으로
codex exec "Improve error handling in the API layer"
```

### 2. 컨텍스트 없는 질문
```bash
# ❌ 피하세요
codex exec "Why doesn't it work?"

# ✅ 컨텍스트 포함
codex exec "Why does the login function return undefined when credentials are correct?"
```

### 3. 실행 요청
```bash
# ❌ Codex는 실행 불가
codex exec "Run the test suite"

# ✅ 분석 요청
codex exec "Review the test coverage and suggest missing test cases"
```

## 📈 협업 효율 극대화

### 배치 분석
한 번에 여러 측면 분석하기:
```bash
# 스크립트로 일괄 실행
codex exec "1. Security issues?" && \
codex exec "2. Performance issues?" && \
codex exec "3. Code style issues?"
```

### 컨텍스트 유지
연속된 질문으로 깊이 있는 분석:
```bash
codex exec "What does the authenticate() function do?"
codex exec "What security measures does it implement?"
codex exec "What vulnerabilities might it have?"
codex exec "How would you improve it?"
```

### 크로스 체크
Claude 작업을 Codex로 검증:
```bash
# Claude: "인증 로직을 수정했습니다"
codex exec "Review the authentication changes for security best practices"
codex exec "Does this follow OWASP guidelines?"
```

## 🔑 핵심 원칙

1. **명확한 커뮤니케이션**: 구체적이고 명확한 프롬프트 사용
2. **역할 존중**: 각 도구의 강점 활용
3. **반복 검증**: 구현 → 검증 → 수정 사이클
4. **컨텍스트 공유**: 분석 결과를 서로 공유
5. **병렬 작업**: 동시에 다른 측면 분석

---

**Remember**: Codex는 읽기 전용 모드로 작동합니다. 실제 수정은 항상 Claude Code가 수행합니다.