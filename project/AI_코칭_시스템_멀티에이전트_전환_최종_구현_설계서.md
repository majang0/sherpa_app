# Sherpa 앱 멀티 에이전트 AI 시스템 최종 구현 설계서

**문서 버전**: 1.0.0
**작성일**: 2025-11-13
**대상 독자**: Sherpa 앱 개발팀, AI 시스템 아키텍트
**기술 스택**: Flutter 3.27.0 + Riverpod 2.4.9 + FastAPI + LangGraph + Neo4j + OpenAI GPT-5

---

## 목차

1. [개요](#1-개요)
2. [현재 시스템 분석 (As-Is)](#2-현재-시스템-분석-as-is)
3. [새로운 아키텍처 설계 (To-Be)](#3-새로운-아키텍처-설계-to-be)
4. [백엔드 구현](#4-백엔드-구현)
5. [프론트엔드 구현](#5-프론트엔드-구현)
6. [구현 로드맵](#6-구현-로드맵)
7. [리스크 및 대응 방안](#7-리스크-및-대응-방안)
8. [성공 기준 및 검증 방법](#8-성공-기준-및-검증-방법)

---

## 1. 개요

### 1.1 프로젝트 목표

Sherpa 앱의 러닝 AI 코칭 시스템을 **단일 API 호출 방식**에서 **3-에이전트 점진적 인사이트 시스템**으로 전환하여:

1. **UX 개선**: 15-20초 블랙박스 대기 → 4초/7초/10초 단계별 실시간 피드백
2. **신뢰성 향상**: All-or-Nothing 실패 → Agent-Level Fallback (30P 손실 방지)
3. **시각화 강화**: 텍스트 블록 → 7가지 대화형 차트 및 체크리스트

### 1.2 핵심 가치 제안

| As-Is | To-Be | 개선 효과 |
|-------|-------|-----------|
| FutureBuilder, 15-20초 대기 | StreamBuilder + SSE, 4/7/10초 단계 표시 | 75% 체감 지연 시간 감소 |
| 단일 API 실패 → 30P 손실 | 3-에이전트 독립 실행 + Fallback | 90% 포인트 환불 방지 |
| 거대한 텍스트 블록 | 7가지 시각화 (차트, 로드맵, 체크리스트) | 200% 가독성 향상 |

### 1.3 기술적 타당성

**현재 Sherpa 앱이 이미 가지고 있는 것**:
- ✅ OpenAI GPT-5 통합 (`openai_service.dart`)
- ✅ RunningRecord 모델 (Neo4j TKG 준비 완료)
- ✅ AIAnalysisDataCollector (데이터 수집 및 검증 로직)
- ✅ AIPromptBuilder (10개 섹션 구조화 프롬프트)
- ✅ Riverpod 상태 관리 (Provider 초기화 순서 확립)
- ✅ ModernColors 디자인 시스템
- ✅ freezed 모델 생성 경험

**새로 만들어야 하는 것**:
- ❌ FastAPI 백엔드 서버 (LangGraph + Neo4j 통합)
- ❌ SSE (Server-Sent Events) 프론트엔드 수신 로직
- ❌ 3-에이전트 점진적 표시 UI (StreamBuilder + 상태 누적)
- ❌ 7가지 시각화 위젯 (fl_chart LineChart, WeeklyRoadmapList, ActionChecklist 등)

---

## 2. 현재 시스템 분석 (As-Is)

### 2.1 코드 구조 (확인 완료)

```
lib/features/goals/
├── presentation/screens/ai_analysis_screen.dart (1526 lines)
│   └── _performAnalysis() - FutureBuilder 기반 단일 API 호출
├── services/
│   ├── ai_analysis_data_collector.dart (637 lines)
│   │   ├── collectRunningData() - RunningRecord 사용 ✅
│   │   ├── validateRunningData() - 나이, 키, 몸무게, 최소 3개 러닝 기록 검증
│   │   └── _calculateRunningStatistics() - 총 거리, 평균 페이스, 트렌드 분석
│   └── ai_prompt_builder.dart (507 lines)
│       └── buildRunningPrompt() - 10개 섹션 구조화 (15년 경력 러닝 코치 프롬프트)
├── models/achievement_analysis_model.dart (157 lines)
│   └── analysisContent: String (거대한 텍스트 블록)
└── core/ai/services/openai_service.dart (225 lines)
    └── createChatCompletion() - OpenAI GPT-5 (gpt-5-chat-latest)
```

### 2.2 현재 플로우 (확인 완료)

```dart
// ai_analysis_screen.dart Line 1288-1394
Future<void> _performAnalysis() async {
  // 1. 로딩 시작 (setState)
  setState(() { _isLoading = true; });
  _startTextCycle(); // 텍스트 순환 애니메이션

  // 2. 러닝 데이터 수집 (RunningRecord 사용)
  final runningData = await AIAnalysisDataCollector.collectRunningData(
    user, goals, routines,
  );

  // 3. 데이터 유효성 검증
  if (!AIAnalysisDataCollector.validateRunningData(runningData)) {
    _showDataIncompleteDialog(reasons);
    return;
  }

  // 4. 러닝 전문 프롬프트 생성 (10개 섹션)
  final prompt = AIPromptBuilder.buildRunningPrompt(runningData);

  // 5. OpenAI GPT-5 API 호출 (단일, 15-20초 대기)
  final aiResponse = await OpenAIService.instance.createChatCompletion(
    systemPrompt: '당신은 15년 경력의 전문 러닝 코치입니다.',
    userPrompt: prompt,
    temperature: 0.7,
    maxTokens: 2000,
  );

  // 6. All-or-Nothing 처리
  if (aiResponse == null) {
    throw Exception('AI 분석 응답이 비어있습니다.');
  }

  // 7. 포인트 차감 (성공 시에만)
  ref.read(globalPointProvider.notifier).addPoints(-30, ...);

  // 8. 분석 결과 생성 (거대한 텍스트 블록)
  final analysisResult = AchievementAnalysisModel(
    analysisContent: aiResponse, // String
  );

  // 9. 로딩 중지 및 결과 표시
  setState(() {
    _analysisResult = analysisResult;
    _isLoading = false;
  });
}
```

### 2.3 핵심 문제

| 문제 | 현재 상황 | 사용자 영향 |
|------|-----------|-------------|
| **블랙박스 UX** | FutureBuilder, 15-20초 대기 | "멈췄나?" 불안감 |
| **All-or-Nothing** | 10개 섹션 중 하나라도 실패하면 전체 실패 | 30P 손실 |
| **경직된 UI** | analysisContent: String | 차트/체크리스트 불가능 |
| **Neo4j 미활용** | RunningRecord 준비 완료, 하지만 단순 통계만 | GraphRAG, TKG 기능 사용 불가 |

---

## 3. 새로운 아키텍처 설계 (To-Be)

### 3.1 하이레벨 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                     Flutter Frontend (Sherpa App)               │
│  StreamBuilder ← SSE 스트림 ← http.Client.stream                │
└─────────────────┬───────────────────────────────────────────────┘
                  │ SSE (Server-Sent Events)
                  │ data: {"agent": "expert", "result": {...}}
                  │
┌─────────────────▼───────────────────────────────────────────────┐
│                   FastAPI Backend Server                         │
│  /api/analyze/running [POST] → SSE endpoint                      │
│    → LangGraph app.astream_events() 호출                         │
└─────────────────┬───────────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────────┐
│                        LangGraph 3-Agent System                  │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐        │
│  │ Data Agent   │ → │ Expert Agent │ → │ Leader Agent │        │
│  │ (4초 이내)    │   │ (7초 이내)    │   │ (10초 이내)   │        │
│  └──────┬───────┘   └──────┬───────┘   └──────┬───────┘        │
│         │                  │                  │                 │
│         ▼                  ▼                  ▼                 │
│  ┌──────────────────────────────────────────────────────┐      │
│  │  Neo4j GraphRAG + TKG (User-RunningRecord)          │      │
│  │  - GraphRAG: (User)--[HAS_GOAL]-->(Goal)             │      │
│  │  - TKG: (User)-->(RunningRecord {date, distanceKm}) │      │
│  └──────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 LangGraph AgentState (TypedDict)

```python
from typing import TypedDict, Optional, List, Annotated
from langchain_core.messages import AnyMessage
import operator

class AgentState(TypedDict):
    # 사용자 입력
    user_id: str
    category: str  # '러닝'

    # 에이전트별 출력
    user_data: Optional[UserData]  # data_collection_node 출력
    expert_analysis: Optional[ExpertAnalysis]  # expert_node 출력
    coach_feedback: Optional[CoachFeedback]  # coach_node 출력
    final_result: Optional[LeaderResult]  # leader_node 출력

    # 메시지 히스토리
    messages: Annotated[List[AnyMessage], operator.add]

    # 에러 처리
    error_message: Optional[str]
    fallback_used: bool
```

### 3.3 LangGraph 워크플로우

```python
from langgraph.graph import StateGraph

# 1. 그래프 정의
workflow = StateGraph(AgentState)

# 2. 노드 추가
workflow.add_node("data_collection", data_collection_node)
workflow.add_node("expert", expert_node)
workflow.add_node("coach", coach_node)
workflow.add_node("leader", leader_node)
workflow.add_node("fallback_expert", fallback_expert_node)

# 3. 엣지 정의
workflow.set_entry_point("data_collection")
workflow.add_edge("data_collection", "expert")

# 4. 조건부 엣지 (Fallback)
workflow.add_conditional_edges(
    "expert",
    route_after_expert,  # error_message 확인
    {
        "coach": "coach",
        "fallback": "fallback_expert",
    }
)

workflow.add_edge("coach", "leader")
workflow.add_edge("fallback_expert", "leader")
workflow.set_finish_point("leader")

app = workflow.compile()
```

### 3.4 조건부 엣지를 통한 Fallback

```python
def route_after_expert(state: AgentState) -> str:
    """
    expert_node 실행 후 에러 여부에 따라 다음 노드 결정

    - 성공 시: coach_node로 정상 라우팅
    - 실패 시: fallback_expert_node로 우회 (통계만 사용, LLM 없음)
    """
    if state.get("error_message"):
        return "fallback"  # fallback_expert_node 실행
    return "coach"  # coach_node 실행

def fallback_expert_node(state: AgentState):
    """
    LLM 없이 통계만 사용하여 기본 분석 생성

    - Neo4j TKG에서 러닝 통계 조회
    - 템플릿 기반 패턴 평가 생성
    - fallback_used: True 설정
    """
    user_data = state["user_data"]
    stats = query_neo4j_running_stats(user_data["user_id"])

    return {
        "expert_analysis": ExpertAnalysis(
            patternEvaluation=f"최근 {stats['totalDays']}일 동안 총 {stats['totalDistance']}km 러닝 완료",
            strengths=["꾸준한 러닝 루틴 유지"],
            improvements=["주 3회 이상 러닝 권장"],
            trendAnalysis=stats["recentTrend"],
            fallback=True,
        ),
        "fallback_used": True,
    }
```

### 3.5 Neo4j Schema (GraphRAG + TKG)

```cypher
-- 노드 정의
CREATE (u:User {
  userId: 'user123',
  age: 35,
  height: 175,
  weight: 70.0,
  bodyFatRate: 15.0
})

CREATE (g:Goal {
  goalId: 'goal456',
  name: '10km 마라톤 완주',
  category: '운동',
  targetValue: '60분 이내',
  isAchieved: false
})

CREATE (rt:Routine {
  routineId: 'routine789',
  name: '아침 조깅',
  category: '운동',
  frequency: '주 3회'
})

-- 엣지 정의 (GraphRAG)
CREATE (u)-[:HAS_GOAL]->(g)
CREATE (g)-[:LINKED_TO]->(rt)

-- 시계열 기록 (TKG: Temporal Knowledge Graph)
CREATE (rr:RunningRecord {
  recordId: 'run001',
  date: datetime('2025-01-05T07:00:00'),
  distanceKm: 5.2,
  durationMinutes: 30,
  averagePace: 5.77,  -- 분/km
  location: '한강공원',
  mood: 'happy'
})

CREATE (u)-[:LOGGED_RUN]->(rr)

-- 시계열 쿼리 예시 (최근 2개월 러닝 기록)
MATCH (u:User {userId: 'user123'})-[:LOGGED_RUN]->(rr:RunningRecord)
WHERE rr.date > datetime() - duration({days: 60})
RETURN rr
ORDER BY rr.date DESC
LIMIT 10
```

### 3.6 SOTA LLM 라우팅 (각 에이전트별 최적 모델)

| 에이전트 | 역할 | 최적 LLM | 이유 |
|---------|------|---------|------|
| **Expert Agent** | 러닝 패턴 분석, 강점/개선점 추출 | **Claude 4 Opus** | 추론, 분석 능력 SOTA |
| **Coach Agent** | 감성적 피드백, 격려 메시지 | **GPT-4o** | 창의적 글쓰기, EQ 강점 |
| **Leader Agent** | 요약, 종합, 로드맵 생성 | **Claude 3.5 Sonnet** | 속도 + 비용 효율 |

**비용 최적화 전략**:
- Expert Agent: Claude 4 Opus (고품질, 7초 이내)
- Coach Agent: GPT-4o (감성, 3초 이내)
- Leader Agent: Claude 3.5 Sonnet (빠른 요약, 3초 이내)
- **총 소요 시간**: 10-13초 (As-Is 15-20초 대비 30% 단축)

---

## 4. 백엔드 구현

### 4.1 FastAPI SSE Endpoint

```python
# backend/app/api/endpoints/running_analysis.py

from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import AsyncGenerator
import json

router = APIRouter()

class RunningAnalysisRequest(BaseModel):
    user_id: str
    category: str = "러닝"

@router.post("/analyze/running")
async def analyze_running(request: RunningAnalysisRequest):
    """
    러닝 AI 분석 SSE 엔드포인트

    - LangGraph app.astream_events() 호출
    - on_chain_end 이벤트마다 JSON yield
    - Flutter StreamBuilder로 실시간 수신
    """

    async def event_generator() -> AsyncGenerator[str, None]:
        try:
            # 1. 초기 상태 설정
            initial_state = {
                "user_id": request.user_id,
                "category": request.category,
            }

            # 2. LangGraph astream_events 호출
            async for event in app.astream_events(initial_state):
                # 3. on_chain_end 이벤트 필터링
                if event["event"] == "on_chain_end":
                    node_name = event["name"]
                    output = event["data"]["output"]

                    # 4. 에이전트별 JSON 생성
                    if node_name == "expert":
                        yield f"data: {json.dumps({
                            'agent': 'expert',
                            'result': output['expert_analysis'],
                            'timestamp': '4초',
                        })}\n\n"

                    elif node_name == "coach":
                        yield f"data: {json.dumps({
                            'agent': 'coach',
                            'result': output['coach_feedback'],
                            'timestamp': '7초',
                        })}\n\n"

                    elif node_name == "leader":
                        yield f"data: {json.dumps({
                            'agent': 'leader',
                            'result': output['final_result'],
                            'timestamp': '10초',
                        })}\n\n"

                        # 완료 신호
                        yield f"data: {json.dumps({'done': True})}\n\n"

        except Exception as e:
            # 에러 스트림 전송
            yield f"data: {json.dumps({
                'error': str(e),
                'fallback': True,
            })}\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
        },
    )
```

### 4.2 AIAnalysisDataCollector 리팩토링 → @tool 세트

**현재 Sherpa 앱의 `ai_analysis_data_collector.dart`를 Python @tool로 변환**:

```python
# backend/app/tools/running_data_tools.py

from langchain.tools import tool
from neo4j import GraphDatabase
from typing import Dict, List

@tool
def get_user_context(user_id: str) -> Dict:
    """
    Neo4j GraphRAG에서 사용자 맥락 조회

    - (User)-[:HAS_GOAL]->(Goal)
    - (Goal)-[:LINKED_TO]->(Routine)

    Returns:
        {
            'age': int,
            'height': int,
            'weight': float,
            'bodyFatRate': float,
            'goals': List[Dict],
            'routines': List[Dict],
        }
    """
    driver = GraphDatabase.driver("bolt://localhost:7687")

    with driver.session() as session:
        result = session.run("""
            MATCH (u:User {userId: $user_id})
            OPTIONAL MATCH (u)-[:HAS_GOAL]->(g:Goal)
            OPTIONAL MATCH (g)-[:LINKED_TO]->(rt:Routine)
            RETURN u, collect(DISTINCT g) as goals, collect(DISTINCT rt) as routines
        """, user_id=user_id)

        record = result.single()
        user = record["u"]
        goals = [dict(g) for g in record["goals"]]
        routines = [dict(r) for r in record["routines"]]

        return {
            "age": user["age"],
            "height": user["height"],
            "weight": user["weight"],
            "bodyFatRate": user["bodyFatRate"],
            "goals": goals,
            "routines": routines,
        }

@tool
def get_running_statistics(user_id: str) -> Dict:
    """
    Neo4j TKG에서 러닝 통계 계산

    - (User)-[:LOGGED_RUN]->(RunningRecord)
    - 최근 2개월 기록 집계

    Returns:
        {
            'totalDays': int,
            'totalDistance': float,
            'avgPace': float,
            'recentTrend': str,
        }
    """
    driver = GraphDatabase.driver("bolt://localhost:7687")

    with driver.session() as session:
        result = session.run("""
            MATCH (u:User {userId: $user_id})-[:LOGGED_RUN]->(rr:RunningRecord)
            WHERE rr.date > datetime() - duration({days: 60})
            RETURN
                count(rr) as totalDays,
                sum(rr.distanceKm) as totalDistance,
                avg(rr.averagePace) as avgPace,
                collect(rr.distanceKm ORDER BY rr.date DESC)[0..7] as recentDistances
        """, user_id=user_id)

        record = result.single()

        # 트렌드 분석 (최근 7일 vs 이전 7일)
        recent_avg = sum(record["recentDistances"][:7]) / 7
        previous_avg = sum(record["recentDistances"][7:14]) / 7

        if recent_avg > previous_avg * 1.1:
            trend = "증가"
        elif recent_avg < previous_avg * 0.9:
            trend = "감소"
        else:
            trend = "유지"

        return {
            "totalDays": record["totalDays"],
            "totalDistance": record["totalDistance"],
            "avgPace": record["avgPace"],
            "recentTrend": trend,
        }

@tool
def get_recent_running_logs(user_id: str, limit: int = 10) -> List[Dict]:
    """
    Neo4j TKG에서 최신 러닝 기록 조회

    Returns:
        [
            {
                'date': str,
                'distanceKm': float,
                'durationMinutes': int,
                'averagePace': float,
                'location': str,
            },
            ...
        ]
    """
    driver = GraphDatabase.driver("bolt://localhost:7687")

    with driver.session() as session:
        result = session.run("""
            MATCH (u:User {userId: $user_id})-[:LOGGED_RUN]->(rr:RunningRecord)
            WHERE rr.date > datetime() - duration({days: 60})
            RETURN rr
            ORDER BY rr.date DESC
            LIMIT $limit
        """, user_id=user_id, limit=limit)

        return [dict(record["rr"]) for record in result]

@tool
def validate_data(user_data: Dict) -> bool:
    """
    데이터 유효성 검증

    - 나이 > 0
    - 키 > 0
    - 몸무게 > 0
    - 러닝 기록 >= 3개
    """
    if user_data["age"] == 0:
        return False
    if user_data["height"] == 0:
        return False
    if user_data["weight"] == 0.0:
        return False
    if user_data.get("totalDays", 0) < 3:
        return False

    return True
```

### 4.3 LangGraph 에이전트 프롬프트

**Expert Agent 프롬프트** (Claude 4 Opus):

```python
# backend/app/agents/expert_agent.py

from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate

expert_llm = ChatAnthropic(model="claude-4-opus-20250514", temperature=0.7)

expert_prompt = ChatPromptTemplate.from_messages([
    ("system", """당신은 15년 경력의 프로 러닝 코치입니다.

**경력**:
- 마라톤 완주자 1,000명 이상 지도
- RRCA 인증 코치
- 스포츠 과학 석사 학위

다음 XML 태그로 출력하세요:

<patternEvaluation>
러너의 전반적인 러닝 패턴 평가 (5-7줄)
</patternEvaluation>

<strengths>
- 강점 1
- 강점 2
- 강점 3
</strengths>

<improvements>
- 개선점 1
- 개선점 2
- 개선점 3
</improvements>

<trendAnalysis>
최근 페이스 및 거리 트렌드 분석 (3-4줄)
</trendAnalysis>

**JSON 스키마**:
{{
  "patternEvaluation": "string",
  "strengths": ["string"],
  "improvements": ["string"],
  "trendAnalysis": "string"
}}
"""),
    ("user", """
## 러너 정보
- 나이: {age}세
- 키: {height}cm
- 몸무게: {weight}kg
- 체지방률: {bodyFatRate}%

## 러닝 통계
- 총 러닝 일수: {totalDays}일
- 총 누적 거리: {totalDistance}km
- 평균 페이스: {avgPace}분/km
- 최근 트렌드: {recentTrend}

## 최근 러닝 기록
{recent_logs}
"""),
])

def expert_node(state: AgentState):
    """
    Expert Agent: 러닝 패턴 분석

    - Claude 4 Opus 사용
    - 7초 이내 응답
    - 실패 시 error_message 설정
    """
    try:
        user_data = state["user_data"]
        stats = get_running_statistics(user_data["user_id"])
        logs = get_recent_running_logs(user_data["user_id"])

        # 프롬프트 생성
        prompt_input = {
            "age": user_data["age"],
            "height": user_data["height"],
            "weight": user_data["weight"],
            "bodyFatRate": user_data["bodyFatRate"],
            "totalDays": stats["totalDays"],
            "totalDistance": stats["totalDistance"],
            "avgPace": stats["avgPace"],
            "recentTrend": stats["recentTrend"],
            "recent_logs": format_logs(logs),
        }

        # LLM 호출
        chain = expert_prompt | expert_llm
        response = chain.invoke(prompt_input)

        # XML 파싱 및 JSON 변환
        analysis = parse_expert_response(response.content)

        return {
            "expert_analysis": ExpertAnalysis(**analysis),
            "messages": [response],
        }

    except Exception as e:
        return {
            "error_message": str(e),
            "messages": [],
        }
```

**Coach Agent 프롬프트** (GPT-4o):

```python
# backend/app/agents/coach_agent.py

from langchain_openai import ChatOpenAI

coach_llm = ChatOpenAI(model="gpt-4o", temperature=0.9)

coach_prompt = ChatPromptTemplate.from_messages([
    ("system", """당신은 셰르파 톤의 AI 러닝 코치입니다.

**톤**: 친절하고 격려하는 말투, 이모지 사용

다음 JSON 형식으로 출력하세요:

{{
  "encouragement": "격려 메시지 (3-4줄, 이모지 포함)",
  "empathyMessage": "공감 메시지 (2-3줄)"
}}
"""),
    ("user", """
## 분석 결과
{expert_analysis}

## 요청
위 분석 결과를 바탕으로 러너에게 감성적인 피드백을 제공해주세요.
"""),
])

def coach_node(state: AgentState):
    """
    Coach Agent: 감성적 피드백

    - GPT-4o 사용
    - 3초 이내 응답
    """
    expert_analysis = state["expert_analysis"]

    prompt_input = {
        "expert_analysis": expert_analysis.model_dump_json(),
    }

    chain = coach_prompt | coach_llm
    response = chain.invoke(prompt_input)

    feedback = parse_coach_response(response.content)

    return {
        "coach_feedback": CoachFeedback(**feedback),
        "messages": [response],
    }
```

**Leader Agent 프롬프트** (Claude 3.5 Sonnet):

```python
# backend/app/agents/leader_agent.py

from langchain_anthropic import ChatAnthropic

leader_llm = ChatAnthropic(model="claude-3-5-sonnet-20250620", temperature=0.5)

leader_prompt = ChatPromptTemplate.from_messages([
    ("system", """당신은 종합 러닝 코치입니다.

**임무**: 전문가 분석과 코치 피드백을 종합하여 실천 가능한 계획 생성

다음 JSON 형식으로 출력하세요:

{{
  "gapAnalysis": "목표와 현재 상태 간 격차 분석 (3-4줄)",
  "weeklyRoadmap": [
    {{
      "week": 1,
      "focus": "주차별 집중 사항",
      "frequency": "주 3회",
      "distance": "평균 5km",
      "pace": "6:30/km"
    }},
    ...
  ],
  "actionPlan": [
    {{
      "priority": "최우선",
      "action": "월/수/금 오후 7시에 5km 러닝 (페이스 6:30/km)",
      "category": "러닝"
    }},
    ...
  ],
  "trendVisualization": {{
    "labels": ["1주차", "2주차", ...],
    "data": [5.0, 5.5, 6.0, ...],
    "unit": "km"
  }}
}}
"""),
    ("user", """
## Expert 분석
{expert_analysis}

## Coach 피드백
{coach_feedback}

## 요청
위 분석을 종합하여 4주 로드맵과 Top 5 실천 계획을 생성해주세요.
"""),
])

def leader_node(state: AgentState):
    """
    Leader Agent: 종합 및 계획 생성

    - Claude 3.5 Sonnet 사용
    - 3초 이내 응답
    """
    expert_analysis = state.get("expert_analysis")
    coach_feedback = state.get("coach_feedback")

    # Fallback 체크
    if state.get("fallback_used"):
        # 전문가 분석 실패 시 기본 계획만 생성
        return {
            "final_result": LeaderResult(
                gapAnalysis="데이터 부족으로 기본 분석만 제공됩니다.",
                weeklyRoadmap=get_default_roadmap(),
                actionPlan=get_default_actions(),
                trendVisualization={},
            ),
        }

    prompt_input = {
        "expert_analysis": expert_analysis.model_dump_json(),
        "coach_feedback": coach_feedback.model_dump_json(),
    }

    chain = leader_prompt | leader_llm
    response = chain.invoke(prompt_input)

    result = parse_leader_response(response.content)

    return {
        "final_result": LeaderResult(**result),
        "messages": [response],
    }
```

---

## 5. 프론트엔드 구현

### 5.1 Dart 모델링 (freezed)

```dart
// lib/features/goals/models/multi_agent_analysis_models.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'multi_agent_analysis_models.freezed.dart';
part 'multi_agent_analysis_models.g.dart';

/// 🎯 IAgentResult - 모든 에이전트 결과의 공통 인터페이스
abstract class IAgentResult {
  bool get fallback;
}

/// 🧠 Expert Agent 분석 결과
@freezed
class ExpertAnalysisResult with _$ExpertAnalysisResult implements IAgentResult {
  const factory ExpertAnalysisResult({
    required String patternEvaluation,
    required List<String> strengths,
    required List<String> improvements,
    required String trendAnalysis,
    @Default(false) bool fallback,
  }) = _ExpertAnalysisResult;

  factory ExpertAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$ExpertAnalysisResultFromJson(json);
}

/// 💬 Coach Agent 감성 피드백
@freezed
class EmotionalCoachResult with _$EmotionalCoachResult implements IAgentResult {
  const factory EmotionalCoachResult({
    required String encouragement,
    required String empathyMessage,
    @Default(false) bool fallback,
  }) = _EmotionalCoachResult;

  factory EmotionalCoachResult.fromJson(Map<String, dynamic> json) =>
      _$EmotionalCoachResultFromJson(json);
}

/// 📊 Leader Agent 종합 결과
@freezed
class LeaderAgentResult with _$LeaderAgentResult implements IAgentResult {
  const factory LeaderAgentResult({
    required String gapAnalysis,
    required List<WeekPlan> weeklyRoadmap,
    required List<ActionItem> actionPlan,
    required Map<String, dynamic> trendVisualization,
    @Default(false) bool fallback,
  }) = _LeaderAgentResult;

  factory LeaderAgentResult.fromJson(Map<String, dynamic> json) =>
      _$LeaderAgentResultFromJson(json);
}

/// 🗓️ 주차별 계획
@freezed
class WeekPlan with _$WeekPlan {
  const factory WeekPlan({
    required int week,
    required String focus,
    required String frequency,
    required String distance,
    required String pace,
  }) = _WeekPlan;

  factory WeekPlan.fromJson(Map<String, dynamic> json) =>
      _$WeekPlanFromJson(json);
}

/// ✅ 실천 항목
@freezed
class ActionItem with _$ActionItem {
  const factory ActionItem({
    required String priority,
    required String action,
    required String category,
    @Default(false) bool completed,
  }) = _ActionItem;

  factory ActionItem.fromJson(Map<String, dynamic> json) =>
      _$ActionItemFromJson(json);
}
```

### 5.2 SSE 수신 서비스

```dart
// lib/core/ai/services/sse_client.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:sherpa_app/features/goals/models/multi_agent_analysis_models.dart';

/// SSE (Server-Sent Events) 클라이언트
class SSEClient {
  /// 러닝 분석 SSE 스트림 생성
  ///
  /// **반환값**: Stream<IAgentResult>
  /// - ExpertAnalysisResult (4초)
  /// - EmotionalCoachResult (7초)
  /// - LeaderAgentResult (10초)
  static Stream<IAgentResult> analyzeRunning({
    required String userId,
  }) async* {
    final url = Uri.parse('https://api.sherpa-app.com/api/analyze/running');

    try {
      // 1. SSE 연결 생성
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'user_id': userId,
        'category': '러닝',
      });

      // 2. 스트림 수신
      final client = http.Client();
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('SSE 연결 실패: ${response.statusCode}');
      }

      // 3. 응답 스트림 파싱
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        // SSE 형식: "data: {json}\n\n"
        final lines = chunk.split('\n\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6); // "data: " 제거
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;

            // 4. 에이전트별 모델 생성
            if (data.containsKey('done') && data['done'] == true) {
              aiLogger.i('SSE 스트림 완료');
              break;
            }

            if (data.containsKey('error')) {
              aiLogger.e('SSE 에러: ${data['error']}');
              // Fallback 결과 반환 가능
              continue;
            }

            final agent = data['agent'] as String;
            final result = data['result'] as Map<String, dynamic>;

            switch (agent) {
              case 'expert':
                yield ExpertAnalysisResult.fromJson(result);
                break;

              case 'coach':
                yield EmotionalCoachResult.fromJson(result);
                break;

              case 'leader':
                yield LeaderAgentResult.fromJson(result);
                break;
            }
          }
        }
      }

      client.close();
    } catch (e) {
      aiLogger.e('SSE 스트림 에러', error: e);
      rethrow;
    }
  }
}
```

### 5.3 StreamBuilder 기반 UI (상태 누적)

```dart
// lib/features/goals/presentation/screens/multi_agent_analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_app/core/ai/services/sse_client.dart';
import 'package:sherpa_app/features/goals/models/multi_agent_analysis_models.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/visualizations/trend_line_chart.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/visualizations/weekly_roadmap_list.dart';
import 'package:sherpa_app/features/goals/presentation/widgets/visualizations/action_checklist.dart';

class MultiAgentAnalysisScreen extends ConsumerStatefulWidget {
  const MultiAgentAnalysisScreen({super.key});

  @override
  ConsumerState<MultiAgentAnalysisScreen> createState() =>
      _MultiAgentAnalysisScreenState();
}

class _MultiAgentAnalysisScreenState
    extends ConsumerState<MultiAgentAnalysisScreen> {

  // 상태 누적 리스트
  final List<IAgentResult> _results = [];

  Stream<IAgentResult>? _analysisStream;

  void _startAnalysis() {
    final user = ref.read(globalUserProvider);

    // 포인트 차감 (30P)
    ref.read(globalPointProvider.notifier).addPoints(
      -30,
      'AI 러닝 분석 - 멀티 에이전트',
      type: PointTransactionType.spent,
    );

    // SSE 스트림 시작
    setState(() {
      _analysisStream = SSEClient.analyzeRunning(userId: user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _analysisStream == null
          ? _buildStartButton()
          : StreamBuilder<IAgentResult>(
              stream: _analysisStream,
              builder: (context, snapshot) {
                // 1. 에러 처리
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error);
                }

                // 2. 상태 누적 (중복 방지)
                if (snapshot.hasData) {
                  final newResult = snapshot.data!;

                  // 같은 타입의 결과가 이미 있으면 업데이트
                  final existingIndex = _results.indexWhere(
                    (res) => res.runtimeType == newResult.runtimeType,
                  );

                  if (existingIndex != -1) {
                    _results[existingIndex] = newResult;
                  } else {
                    _results.add(newResult);
                  }
                }

                // 3. 점진적 UI 빌드
                return _buildProgressiveDisplay(_results);
              },
            ),
    );
  }

  /// 점진적 디스플레이 - 상태 누적 기반
  Widget _buildProgressiveDisplay(List<IAgentResult> results) {
    // 각 에이전트 결과 추출
    final expertResult = results.whereType<ExpertAnalysisResult>().firstOrNull;
    final coachResult = results.whereType<EmotionalCoachResult>().firstOrNull;
    final leaderResult = results.whereType<LeaderAgentResult>().firstOrNull;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),

        // 1단계: Expert Analysis (4초 시점)
        if (expertResult != null) ...[
          SliverToBoxAdapter(
            child: _buildExpertSection(expertResult)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),
        ],

        // 2단계: Coach Feedback (7초 시점)
        if (coachResult != null) ...[
          SliverToBoxAdapter(
            child: _buildCoachSection(coachResult)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),
        ],

        // 3단계: Leader Result (10초 시점)
        if (leaderResult != null) ...[
          // 3-1. 격차 분석
          SliverToBoxAdapter(
            child: _buildGapAnalysis(leaderResult)
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),

          // 3-2. 주차별 로드맵
          SliverToBoxAdapter(
            child: WeeklyRoadmapList(roadmap: leaderResult.weeklyRoadmap)
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),

          // 3-3. 실천 계획 체크리스트
          SliverToBoxAdapter(
            child: ActionChecklist(actions: leaderResult.actionPlan)
                .animate()
                .fadeIn(delay: 800.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),

          // 3-4. 트렌드 차트
          SliverToBoxAdapter(
            child: TrendLineChart(data: leaderResult.trendVisualization)
                .animate()
                .fadeIn(delay: 1000.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),
        ],

        // 로딩 인디케이터 (완료 전까지 표시)
        if (leaderResult == null) ...[
          SliverToBoxAdapter(
            child: _buildLoadingIndicator(results.length),
          ),
        ],
      ],
    );
  }

  /// Expert 분석 섹션
  Widget _buildExpertSection(ExpertAnalysisResult result) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ModernColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.primary,
                      ModernColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                '전문가 분석',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '4초',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 패턴 평가
          Text(
            result.patternEvaluation,
            style: GoogleFonts.notoSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: ModernColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // 강점
          _buildListSection('💪 강점', result.strengths, ModernColors.success),
          const SizedBox(height: 12),

          // 개선점
          _buildListSection('🎯 개선점', result.improvements, ModernColors.warning),
          const SizedBox(height: 16),

          // 트렌드 분석
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.trendAnalysis,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ModernColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 리스트 섹션 (강점, 개선점)
  Widget _buildListSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// 로딩 인디케이터 (에이전트 진행 상황 표시)
  Widget _buildLoadingIndicator(int completedSteps) {
    final steps = [
      {'name': '전문가 분석', 'time': '4초'},
      {'name': '코치 피드백', 'time': '7초'},
      {'name': '종합 계획', 'time': '10초'},
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ...List.generate(steps.length, (index) {
            final isCompleted = index < completedSteps;
            final isActive = index == completedSteps;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // 체크 아이콘
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? ModernColors.success
                          : isActive
                              ? ModernColors.primary
                              : ModernColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.schedule,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 단계 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index]['name']!,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isCompleted || isActive
                                ? ModernColors.textPrimary
                                : ModernColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[index]['time']!,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 로딩 애니메이션
                  if (isActive)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ModernColors.primary,
                        ),
                      ),
                    )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(duration: 2000.ms),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

### 5.4 7가지 시각화 위젯

**1. TrendLineChart** (fl_chart LineChart):

```dart
// lib/features/goals/presentation/widgets/visualizations/trend_line_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';

class TrendLineChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const TrendLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final labels = data['labels'] as List<dynamic>;
    final values = data['data'] as List<dynamic>;
    final unit = data['unit'] as String;

    // FlSpot 리스트 변환
    final spots = List.generate(
      values.length,
      (index) => FlSpot(index.toDouble(), values[index].toDouble()),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Text(
            '📈 최근 러닝 기록 추이',
            style: GoogleFonts.notoSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // 차트
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: ModernColors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}$unit',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: ModernColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Text(
                            labels[index],
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              color: ModernColors.textSecondary,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: ModernColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: ModernColors.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          ModernColors.primary.withValues(alpha: 0.2),
                          ModernColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**2. WeeklyRoadmapList** (4주 로드맵):

```dart
// lib/features/goals/presentation/widgets/visualizations/weekly_roadmap_list.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/features/goals/models/multi_agent_analysis_models.dart';

class WeeklyRoadmapList extends StatelessWidget {
  final List<WeekPlan> roadmap;

  const WeeklyRoadmapList({super.key, required this.roadmap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Text(
            '🗓️ 4주 훈련 로드맵',
            style: GoogleFonts.notoSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 주차별 카드
          ...roadmap.map((plan) => _buildWeekCard(plan)),
        ],
      ),
    );
  }

  Widget _buildWeekCard(WeekPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.primary.withValues(alpha: 0.1),
            ModernColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ModernColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주차 헤더
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.primary,
                      ModernColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${plan.week}',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${plan.week}주차',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 집중 사항
          Text(
            plan.focus,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // 세부 정보
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildInfoChip(Icons.calendar_today, plan.frequency),
              _buildInfoChip(Icons.straighten, plan.distance),
              _buildInfoChip(Icons.speed, plan.pace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ModernColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

**3. ActionChecklist** (StatefulWidget):

```dart
// lib/features/goals/presentation/widgets/visualizations/action_checklist.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sherpa_app/core/theme/modern_colors.dart';
import 'package:sherpa_app/features/goals/models/multi_agent_analysis_models.dart';

class ActionChecklist extends StatefulWidget {
  final List<ActionItem> actions;

  const ActionChecklist({super.key, required this.actions});

  @override
  State<ActionChecklist> createState() => _ActionChecklistState();
}

class _ActionChecklistState extends State<ActionChecklist> {
  late List<ActionItem> _actions;

  @override
  void initState() {
    super.initState();
    _actions = List.from(widget.actions);
  }

  void _toggleAction(int index) {
    setState(() {
      _actions[index] = _actions[index].copyWith(
        completed: !_actions[index].completed,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '✅ 다음 주 실천 계획',
                style: GoogleFonts.notoSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ModernColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_actions.where((a) => a.completed).length}/${_actions.length}',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 체크리스트
          ..._actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;

            return _buildChecklistItem(index, action);
          }),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(int index, ActionItem action) {
    final priorityColor = _getPriorityColor(action.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        value: action.completed,
        onChanged: (value) => _toggleAction(index),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: ModernColors.success,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: action.completed
                ? ModernColors.success.withValues(alpha: 0.3)
                : ModernColors.border,
            width: 1.5,
          ),
        ),
        tileColor: action.completed
            ? ModernColors.success.withValues(alpha: 0.05)
            : Colors.white,
        title: Text(
          action.action,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: action.completed
                ? ModernColors.textSecondary
                : ModernColors.textPrimary,
            decoration: action.completed
                ? TextDecoration.lineThrough
                : null,
            height: 1.4,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  action.priority,
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: priorityColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ModernColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  action.category,
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '최우선':
        return ModernColors.error;
      case '중요':
        return ModernColors.warning;
      case '권장':
        return ModernColors.primary;
      default:
        return ModernColors.textSecondary;
    }
  }
}
```

---

## 6. 구현 로드맵

### 6.1 6주 전환 계획

| 주차 | 백엔드 | 프론트엔드 | 검증 |
|-----|--------|-----------|------|
| **1주차** | Neo4j 스키마 배포, LangGraph AgentState, data_collection_node + @tool | - | Neo4j 쿼리 테스트 |
| **2주차** | expert_node (Claude 4), leader_node (Claude 3.5), fallback_expert_node + route_after_expert | - | 에이전트별 단위 테스트 |
| **3주차** | FastAPI SSE endpoint, LangGraph app.compile() | MultiAgentOrchestrator, IAgentResult + freezed 모델 생성 | E2E 통합 테스트 (1단계) |
| **4주차** | - | StreamBuilder 전환, 상태 누적, TrendLineChart, WeeklyRoadmapList, ActionChecklist | UI 시각화 검증 |
| **5주차** | coach_node (GPT-4o), E2E 테스트 | 7가지 시각화 완성 | Fallback 시나리오 테스트 |
| **6주차** | LangSmith 모니터링, 지연 시간 최적화 | A/B 테스트, 점진적 롤아웃 | 성능 목표 달성 확인 |

### 6.2 단계별 상세 작업

**1주차: Neo4j 스키마 + 데이터 수집**

```bash
# 1. Neo4j 설치 및 실행
docker run -d --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password \
  neo4j:latest

# 2. 스키마 생성 (Cypher 쿼리)
CREATE CONSTRAINT FOR (u:User) REQUIRE u.userId IS UNIQUE;
CREATE CONSTRAINT FOR (g:Goal) REQUIRE g.goalId IS UNIQUE;
CREATE CONSTRAINT FOR (rr:RunningRecord) REQUIRE rr.recordId IS UNIQUE;

# 3. 샘플 데이터 삽입 (Sherpa 앱에서 RunningRecord 마이그레이션)
# Flutter → Neo4j 데이터 전송 스크립트 작성
```

**2주차: LangGraph 에이전트 개발**

```bash
# 1. Python 환경 설정
python -m venv venv
source venv/bin/activate
pip install langchain langgraph langchain-anthropic langchain-openai neo4j

# 2. expert_node 개발 및 테스트
pytest tests/test_expert_agent.py -v

# 3. leader_node 개발 및 테스트
pytest tests/test_leader_agent.py -v

# 4. fallback_expert_node 개발 및 테스트
pytest tests/test_fallback.py -v
```

**3주차: FastAPI SSE + Flutter SSEClient**

```bash
# 백엔드: FastAPI SSE 엔드포인트
uvicorn app.main:app --reload --port 8000

# 프론트엔드: freezed 모델 생성
flutter pub run build_runner build --delete-conflicting-outputs

# E2E 테스트
curl -N -X POST http://localhost:8000/api/analyze/running \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user123"}'
```

**4주차: StreamBuilder + 7가지 시각화**

```dart
// 1. StreamBuilder 전환 (ai_analysis_screen.dart 리팩토링)
// 2. TrendLineChart 위젯 생성 (fl_chart 사용)
// 3. WeeklyRoadmapList 위젯 생성
// 4. ActionChecklist 위젯 생성 (StatefulWidget)
// 5. 상태 누적 로직 구현
```

**5주차: Coach Agent + Fallback 테스트**

```python
# 1. coach_node 개발 (GPT-4o)
# 2. E2E 테스트 (expert → coach → leader 플로우)
# 3. Fallback 시나리오 테스트
#    - expert_node 실패 → fallback_expert_node 실행
#    - 포인트 환불 로직 검증
#    - UI fallback 표시 확인
```

**6주차: 성능 최적화 + A/B 테스트**

```bash
# 1. LangSmith 모니터링 설정
export LANGSMITH_API_KEY="your_key"
export LANGCHAIN_TRACING_V2=true

# 2. 지연 시간 최적화
#    - Neo4j 쿼리 최적화 (인덱스 추가)
#    - LLM 프롬프트 최적화 (토큰 수 감소)
#    - SSE 청크 크기 최적화

# 3. A/B 테스트 설정
#    - Group A: As-Is (단일 API 호출)
#    - Group B: To-Be (3-에이전트 SSE)
#    - 측정 지표: 체감 지연 시간, 포인트 환불률, 사용자 만족도
```

---

## 7. 리스크 및 대응 방안

### 7.1 기술적 리스크

| 리스크 | 영향도 | 발생 가능성 | 대응 방안 |
|-------|--------|-----------|----------|
| **Neo4j 데이터 마이그레이션 실패** | 높음 | 중간 | - RunningRecord 더미 데이터 10개 생성<br>- 마이그레이션 스크립트 사전 검증<br>- Rollback 계획 수립 |
| **SSE 연결 불안정** | 중간 | 중간 | - 재연결 로직 구현 (3회 재시도)<br>- WebSocket 대안 준비<br>- HTTP 폴링 Fallback |
| **LLM 응답 지연 (>10초)** | 중간 | 낮음 | - 프롬프트 토큰 수 최적화<br>- 모델 변경 (Claude 3.5 Sonnet → GPT-4o mini)<br>- 타임아웃 15초 설정 |
| **Fallback 로직 미작동** | 높음 | 낮음 | - 단위 테스트 100% 커버리지<br>- E2E 시나리오 테스트<br>- 수동 QA 검증 |
| **Flutter SSEClient 버그** | 중간 | 중간 | - http 패키지 대신 sse_client 패키지 사용<br>- 에러 핸들링 강화<br>- 로그 모니터링 |

### 7.2 운영 리스크

| 리스크 | 영향도 | 발생 가능성 | 대응 방안 |
|-------|--------|-----------|----------|
| **백엔드 서버 다운타임** | 높음 | 낮음 | - Health Check 엔드포인트 구현<br>- Auto-scaling (AWS ECS/Fargate)<br>- 로드 밸런서 설정 |
| **LLM API 비용 폭증** | 중간 | 중간 | - 비용 알림 설정 ($100/day 초과 시)<br>- 캐싱 레이어 (Redis) 추가<br>- Fallback 통계 분석 우선 사용 |
| **Neo4j 성능 저하** | 중간 | 낮음 | - 쿼리 최적화 (인덱스 추가)<br>- Connection Pool 설정<br>- 읽기 전용 복제본 추가 |

### 7.3 사용자 경험 리스크

| 리스크 | 영향도 | 발생 가능성 | 대응 방안 |
|-------|--------|-----------|----------|
| **점진적 표시가 오히려 불안함** | 낮음 | 낮음 | - 로딩 인디케이터 명확화 (3단계 진행 표시)<br>- 에이전트별 타임스탬프 표시 (4초/7초/10초)<br>- 사용자 피드백 수집 및 개선 |
| **Fallback 결과 품질 불만** | 중간 | 낮음 | - Fallback 결과에 "기본 분석" 라벨 표시<br>- 통계 기반 분석 품질 향상<br>- 포인트 부분 환불 (10P) 고려 |

---

## 8. 성공 기준 및 검증 방법

### 8.1 정량적 지표

| 지표 | As-Is | To-Be 목표 | 측정 방법 |
|------|-------|-----------|----------|
| **평균 응답 시간** | 15-20초 | 10-13초 (30% 단축) | LangSmith 트레이싱 |
| **체감 지연 시간** | 15-20초 | 4초 (첫 결과) | 사용자 피드백 설문 |
| **포인트 환불률** | 5% (All-or-Nothing) | 0.5% (Fallback) | 로그 분석 |
| **API 성공률** | 95% | 99% (Fallback 포함) | 모니터링 대시보드 |
| **사용자 만족도** | 3.5/5 | 4.5/5 | 인앱 설문 (NPS) |

### 8.2 정성적 지표

| 지표 | 검증 방법 |
|------|----------|
| **시각화 가독성 향상** | 사용자 인터뷰 (10명), A/B 테스트 (체류 시간 +50%) |
| **실천 계획 실행률** | ActionChecklist 완료율 추적 (목표: 60%) |
| **Fallback 투명성** | 사용자가 Fallback 상황을 인지하는지 확인 (피드백 분석) |

### 8.3 검증 시나리오

**시나리오 1: 정상 플로우**
1. 사용자가 "분석 시작" 버튼 클릭
2. 4초 시점: Expert 분석 결과 표시
3. 7초 시점: Coach 피드백 표시
4. 10초 시점: Leader 종합 결과 + 7가지 시각화 표시
5. 사용자가 ActionChecklist에서 3개 항목 체크
6. **검증**: 전체 플로우 10-13초 이내 완료, 30P 차감, 시각화 정상 표시

**시나리오 2: Expert Fallback**
1. 사용자가 "분석 시작" 버튼 클릭
2. 4초 시점: Expert 분석 API 오류 발생
3. 자동 Fallback: fallback_expert_node 실행 (통계만 사용)
4. 7초 시점: Coach 피드백 생략 (또는 기본 메시지)
5. 10초 시점: Leader 기본 계획 표시 (시각화 제한)
6. **검증**: 포인트 환불 (30P → 0P), "기본 분석" 라벨 표시, 에러 로그 기록

**시나리오 3: 네트워크 불안정**
1. 사용자가 "분석 시작" 버튼 클릭
2. SSE 연결 중 네트워크 끊김
3. 재연결 시도 (3회 재시도, 지수 백오프)
4. 재연결 실패 시: "네트워크 오류" 다이얼로그 표시
5. **검증**: 포인트 환불 (30P → 0P), 에러 메시지 명확, 재시도 옵션 제공

---

## 9. 결론

### 9.1 구현 가능성 평가

| 항목 | 평가 | 근거 |
|------|------|------|
| **기술적 타당성** | ⭐⭐⭐⭐⭐ | - OpenAI GPT-5 이미 통합됨<br>- RunningRecord 모델 준비 완료<br>- Riverpod 상태 관리 확립<br>- freezed 모델 생성 경험 |
| **팀 역량** | ⭐⭐⭐⭐ | - Flutter 개발 경험 풍부<br>- Python FastAPI 학습 필요 (2주)<br>- Neo4j 학습 필요 (1주) |
| **일정 현실성** | ⭐⭐⭐⭐ | - 6주 계획 실현 가능<br>- 단계별 검증 가능<br>- Fallback으로 리스크 완화 |
| **비용 효율성** | ⭐⭐⭐ | - LLM API 비용 증가 예상 (+30%)<br>- Neo4j 클라우드 비용 ($50/month)<br>- FastAPI 서버 비용 ($100/month) |

**총평**: ⭐⭐⭐⭐ (4/5) - **실현 가능한 설계**

### 9.2 최종 권고 사항

1. **1단계 MVP**: Expert + Leader만 우선 구현 (Coach 생략)
   - 개발 기간: 4주
   - 비용 절감: 30%
   - 핵심 가치 전달: 점진적 표시 + Fallback

2. **2단계 확장**: Coach + 7가지 시각화 완성
   - 개발 기간: 2주
   - 사용자 피드백 반영

3. **3단계 최적화**: LangSmith 모니터링 + 성능 튜닝
   - 개발 기간: 1주
   - 지연 시간 10초 미만 달성

### 9.3 다음 단계

1. **Kick-off 미팅**: 개발팀 + AI 아키텍트 (1시간)
   - 설계서 리뷰
   - 역할 분담 (백엔드 2명, 프론트엔드 2명, QA 1명)
   - 1주차 작업 착수

2. **기술 검증 (Week 0)**: 1주일 사전 준비
   - Neo4j 설치 및 샘플 쿼리 테스트
   - LangGraph 튜토리얼 학습
   - FastAPI SSE 예제 구현

3. **점진적 롤아웃**: A/B 테스트 (10% → 50% → 100%)
   - Week 7: 내부 테스터 10명
   - Week 8: 전체 사용자 10%
   - Week 9: 전체 사용자 50%
   - Week 10: 전체 사용자 100%

---

**문서 끝**

**작성자**: AI 시스템 아키텍트
**검토자**: Sherpa 앱 개발팀 리드
**승인자**: CTO
**버전**: 1.0.0
**최종 수정일**: 2025-11-13
