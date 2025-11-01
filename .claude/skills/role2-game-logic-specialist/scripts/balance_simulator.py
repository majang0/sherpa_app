#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
셰르파 앱 게임 밸런스 시뮬레이터

이 스크립트는 셰르파 앱의 게임 밸런스를 시뮬레이션하고 검증합니다.
모든 공식은 `game_balance_formulas.md`와 `game_constants.dart`를 기반으로 합니다.

사용법:
    # 등반력 시뮬레이션
    python balance_simulator.py --mode climbing --level 15 --stamina 15 --knowledge 10 --technique 5

    # 레벨업 시뮬레이션
    python balance_simulator.py --mode levelup --activities-per-day 3 --xp-per-activity 50 --days 30

    # 포인트 경제 시뮬레이션
    python balance_simulator.py --mode points --daily-quests 3 --meetings 2 --days 30
"""

import argparse
import math
import sys
import io
from typing import Dict, List, Tuple

# Windows 환경에서 UTF-8 출력 지원
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')


# ============================================================================
# Part 1: 등반력 시스템 공식
# ============================================================================

def calculate_title_bonus(level: int) -> int:
    """
    레벨에 따른 칭호 보너스 계산

    출처: game_balance_formulas.md Part 2.2
    코드: lib/core/constants/game_constants.dart:58-75
    """
    if level >= 50:
        return 600  # 전설의 셰르파
    elif level >= 40:
        return 400  # 마스터 셰르파
    elif level >= 30:
        return 250  # 셰르파
    elif level >= 20:
        return 120  # 전문 산악인
    elif level >= 10:
        return 50   # 숙련된 등반가
    else:
        return 0    # 초보 등반가


def calculate_base_power(level: int) -> int:
    """
    기본 등반력 계산

    공식: 기본 등반력 = (레벨 × 10) + 칭호 보너스

    출처: game_balance_formulas.md Part 1.2
    코드: lib/core/constants/game_constants.dart:12-14
    """
    title_bonus = calculate_title_bonus(level)
    return (level * 10) + title_bonus


def calculate_stats_bonus(stamina: float, knowledge: float, technique: float) -> float:
    """
    능력치 보너스 계산 (⚠️ 사교성과 의지는 포함되지 않음!)

    공식: 능력치 보너스 = 체력% + 지식% + 기술%

    출처: game_balance_formulas.md Part 1.3
    코드: lib/core/constants/game_constants.dart:17-20
    """
    return stamina + knowledge + technique


def calculate_final_power(level: int, stamina: float, knowledge: float,
                          technique: float, badge_bonus: float = 0.0) -> float:
    """
    최종 등반력 계산

    공식: 등반력 = (기본 등반력) × (1 + 능력치 보너스 총합) × (1 + 뱃지 보너스 총합)

    출처: game_balance_formulas.md Part 1.1
    코드: lib/core/constants/game_constants.dart:40-53
    """
    base_power = calculate_base_power(level)
    stats_bonus = calculate_stats_bonus(stamina, knowledge, technique)

    final_power = base_power * (1 + stats_bonus / 100) * (1 + badge_bonus / 100)
    return final_power


def calculate_success_probability(user_power: float, mountain_power: float,
                                  willpower: float = 0.0, badge_success_bonus: float = 0.0) -> float:
    """
    등반 성공 확률 계산

    공식: 최종 성공 확률 = 기본 성공 확률(등반력 비율) + 의지 보정치 + 뱃지 보너스

    출처: game_balance_formulas.md Part 5.3
    코드: lib/core/constants/game_constants.dart:130-169
    """
    power_ratio = user_power / mountain_power

    # 기본 성공 확률 계산
    if power_ratio < 1:
        # 등반력 부족 시: 급격한 확률 감소 (3제곱 함수)
        base_prob = 0.05 + 0.45 * (power_ratio ** 3)
    else:
        # 등반력 초과 시: 완만한 확률 증가 (지수 함수의 역함수)
        base_prob = 0.5 + 0.45 * (1 - math.exp(-0.5 * (power_ratio - 1)))
        base_prob = min(base_prob, 0.95)  # 최대 95%로 제한

    # 의지 보정치
    willpower_bonus = (willpower / 100) * 0.1

    # 최종 확률
    final_prob = base_prob + willpower_bonus + (badge_success_bonus / 100)
    return min(final_prob, 1.0)  # 100% 초과 방지


# ============================================================================
# Part 2: 레벨 및 승급 시스템
# ============================================================================

def calculate_required_xp(level: int) -> int:
    """
    레벨업에 필요한 XP 계산

    공식: 요구 XP = (현재 레벨 ^ 1.5) × 40 + (현재 레벨 × 20)

    출처: game_balance_formulas.md Part 2.1
    코드: lib/core/constants/game_constants.dart:100-102
    """
    return int((level ** 1.5) * 40 + (level * 20))


def calculate_badge_slots(level: int) -> int:
    """
    레벨에 따른 뱃지 슬롯 개수

    출처: game_balance_formulas.md Part 2.3
    코드: lib/core/constants/game_constants.dart:115-120
    """
    if level >= 30:
        return 4
    elif level >= 20:
        return 3
    elif level >= 10:
        return 2
    else:
        return 1


def calculate_mountain_power(difficulty: int) -> int:
    """
    산의 난이도에 따른 요구 등반력 계산

    출처: game_balance_formulas.md Part 6.2
    코드: lib/core/constants/game_constants.dart:309-323
    """
    if difficulty <= 9:
        # 초심자의 언덕
        return difficulty * 40
    elif difficulty <= 49:
        # 한국의 명산
        return 360 + (difficulty - 9) * 80
    elif difficulty <= 99:
        # 아시아의 지붕
        return int(3560 + ((difficulty - 49) ** 1.5) * 15)
    else:
        # 세계의 정상, 신들의 산맥
        return int(21000 + ((difficulty - 99) ** 1.8) * 30)


# ============================================================================
# Part 3: 포인트 시스템
# ============================================================================

class PointSystem:
    """
    포인트 획득/소비 시스템

    출처: game_balance_formulas.md Part 7
    코드: lib/shared/models/point_system_model.dart
    """

    # 획득처 (코드 기준)
    DAILY_QUEST_CLEAR = 50      # 광고 시청 필요
    WEEKLY_QUEST_HARD = 100
    WEEKLY_QUEST_CLEAR = 100    # 광고 시청 필요
    DAILY_GOAL_CLEAR = 50       # 광고 시청 필요

    MEETING_ATTENDANCE = 100
    MEETING_HOSTING = 300
    FIRST_HOSTING = 700
    MONTHLY_5_ATTENDANCE = 300  # 코드 기준 (txt는 200)
    MONTHLY_5_HOSTING = 500

    COMMUNITY_DAILY = 20        # 코드 기준 (txt는 30)
    POPULAR_POST = 100
    HELPFUL_COMMENT = 50

    # 프리미엄 퀘스트
    PREMIUM_RARE = 100
    PREMIUM_EPIC = 200
    PREMIUM_LEGENDARY = 300

    # 사용처 (코드 기준)
    FREE_MEETING = 1000
    PREMIUM_QUEST_PACK = 2000   # 한 달
    QUEST_TICKET = 500
    STREAK_PROTECTION = 300     # 코드 기준 (txt는 500)
    MEETING_BOOST = 200
    ANALYSIS_REPORT = 1000
    FREE_CHALLENGE = 500

    @staticmethod
    def calculate_daily_income(daily_quests_cleared: bool = False,
                              meetings_attended: int = 0,
                              meetings_hosted: int = 0,
                              community_active: bool = False) -> int:
        """일일 포인트 획득량 계산"""
        total = 0

        if daily_quests_cleared:
            total += PointSystem.DAILY_QUEST_CLEAR

        total += meetings_attended * PointSystem.MEETING_ATTENDANCE
        total += meetings_hosted * PointSystem.MEETING_HOSTING

        if community_active:
            total += PointSystem.COMMUNITY_DAILY

        return total


# ============================================================================
# 시뮬레이션 모드
# ============================================================================

def simulate_climbing(args):
    """등반력 시뮬레이션 모드"""
    print("=" * 70)
    print("🏔️  등반력 시뮬레이션")
    print("=" * 70)

    level = args.level
    stamina = args.stamina
    knowledge = args.knowledge
    technique = args.technique
    willpower = args.willpower
    sociality = args.sociality
    badge_bonus = args.badge_bonus
    badge_success = args.badge_success

    # 기본 정보
    base_power = calculate_base_power(level)
    title_bonus = calculate_title_bonus(level)
    stats_bonus = calculate_stats_bonus(stamina, knowledge, technique)
    final_power = calculate_final_power(level, stamina, knowledge, technique, badge_bonus)
    badge_slots = calculate_badge_slots(level)

    print(f"\n📊 캐릭터 정보")
    print(f"  레벨: {level}")
    print(f"  칭호 보너스: +{title_bonus}")
    print(f"  뱃지 슬롯: {badge_slots}개")

    print(f"\n💪 능력치")
    print(f"  체력 (Stamina):    {stamina:>6.1f}%")
    print(f"  지식 (Knowledge):  {knowledge:>6.1f}%")
    print(f"  기술 (Technique):  {technique:>6.1f}%")
    print(f"  의지 (Willpower):  {willpower:>6.1f}% (등반 성공률 보정)")
    print(f"  사교성 (Sociality): {sociality:>6.1f}% (시간 단축 효과)")

    print(f"\n⚡ 등반력 계산")
    print(f"  기본 등반력:       {base_power:>6.0f}")
    print(f"  능력치 보너스:     +{stats_bonus:>5.1f}% (체력+지식+기술)")
    print(f"  뱃지 보너스:       +{badge_bonus:>5.1f}%")
    print(f"  ─────────────────────────")
    print(f"  최종 등반력:       {final_power:>6.0f}")

    # 난이도별 성공 확률 표
    print(f"\n🎯 난이도별 등반 성공 확률")
    print(f"{'난이도':<8} {'산 이름':<15} {'요구 등반력':<12} {'성공 확률':<10}")
    print("─" * 60)

    test_mountains = [
        (1, "동네 오르막길"),
        (5, "관악산"),
        (10, "지리산"),
        (20, "설악산"),
        (30, "한라산"),
        (50, "후지산"),
        (75, "키나발루산"),
        (100, "몽블랑"),
        (150, "킬리만자로"),
        (200, "에베레스트"),
    ]

    for diff, name in test_mountains:
        mountain_power = calculate_mountain_power(diff)
        success_prob = calculate_success_probability(final_power, mountain_power,
                                                     willpower, badge_success)
        print(f"{diff:<8} {name:<15} {mountain_power:<12} {success_prob*100:>6.1f}%")

    print("\n" + "=" * 70)


def simulate_levelup(args):
    """레벨업 시뮬레이션 모드"""
    print("=" * 70)
    print("📈 레벨업 시뮬레이션")
    print("=" * 70)

    activities_per_day = args.activities_per_day
    xp_per_activity = args.xp_per_activity
    days = args.days
    start_level = args.start_level

    print(f"\n⚙️  시뮬레이션 설정")
    print(f"  시작 레벨: {start_level}")
    print(f"  일일 활동 횟수: {activities_per_day}회")
    print(f"  활동당 평균 XP: {xp_per_activity}")
    print(f"  시뮬레이션 기간: {days}일")

    daily_xp = activities_per_day * xp_per_activity
    print(f"  일일 XP 획득량: {daily_xp}")

    # 시뮬레이션
    current_level = start_level
    current_xp = 0
    total_xp_earned = 0

    print(f"\n📊 레벨 진행")
    print(f"{'일차':<6} {'레벨':<6} {'현재 XP':<12} {'요구 XP':<12} {'누적 XP':<12} {'진행률':<8}")
    print("─" * 70)

    for day in range(1, days + 1):
        current_xp += daily_xp
        total_xp_earned += daily_xp
        required_xp = calculate_required_xp(current_level)

        # 레벨업 체크
        while current_xp >= required_xp:
            current_xp -= required_xp
            current_level += 1
            required_xp = calculate_required_xp(current_level)

        progress = (current_xp / required_xp) * 100

        # 5일마다 또는 레벨업 시 출력
        if day % 5 == 0 or current_xp < daily_xp:
            print(f"{day:<6} {current_level:<6} {current_xp:<12.0f} {required_xp:<12.0f} "
                  f"{total_xp_earned:<12.0f} {progress:>6.1f}%")

    print("\n📈 결과 요약")
    print(f"  최종 레벨: {start_level} → {current_level} (레벨 {current_level - start_level} 상승)")
    print(f"  총 획득 XP: {total_xp_earned:,}")
    print(f"  평균 레벨업 소요일: {days / max(1, current_level - start_level):.1f}일")

    print("\n" + "=" * 70)


def simulate_points(args):
    """포인트 경제 시뮬레이션 모드"""
    print("=" * 70)
    print("💰 포인트 경제 시뮬레이션")
    print("=" * 70)

    days = args.days
    daily_quests = args.daily_quests
    meetings = args.meetings
    hosted_meetings = args.hosted_meetings
    community_active = args.community_active

    print(f"\n⚙️  시뮬레이션 설정")
    print(f"  기간: {days}일")
    print(f"  일일 퀘스트 올클리어: {daily_quests}회")
    print(f"  모임 참석: 주 {meetings}회")
    print(f"  모임 주최: 주 {hosted_meetings}회")
    print(f"  커뮤니티 활동: {'매일' if community_active else '없음'}")

    # 월간 계산
    weeks = days // 7

    # 일일 수입
    daily_income = 0
    if daily_quests > 0:
        daily_income += PointSystem.DAILY_QUEST_CLEAR

    if community_active:
        daily_income += PointSystem.COMMUNITY_DAILY

    # 주간 수입
    weekly_income = 0
    weekly_income += meetings * PointSystem.MEETING_ATTENDANCE
    weekly_income += hosted_meetings * PointSystem.MEETING_HOSTING

    # 월간 보너스
    monthly_bonus = 0
    if meetings >= 5:
        monthly_bonus += PointSystem.MONTHLY_5_ATTENDANCE
    if hosted_meetings >= 5:
        monthly_bonus += PointSystem.MONTHLY_5_HOSTING

    # 총 수입 계산
    total_income = (daily_income * days) + (weekly_income * weeks) + (monthly_bonus * (days // 30))

    print(f"\n💵 수입 내역")
    print(f"  일일 수입: {daily_income:,} Point/일")
    print(f"  주간 수입: {weekly_income:,} Point/주")
    print(f"  월간 보너스: {monthly_bonus:,} Point/월")
    print(f"  ─────────────────────────")
    print(f"  총 수입: {total_income:,} Point")
    print(f"  일평균: {total_income / days:,.0f} Point/일")

    # 일반적인 지출 예시
    print(f"\n💳 일반적인 지출 예시")
    print(f"  무료 모임 참여 (1회): {PointSystem.FREE_MEETING:,} Point")
    print(f"  프리미엄 퀘스트 팩 (한 달): {PointSystem.PREMIUM_QUEST_PACK:,} Point")
    print(f"  퀘스트 완료 티켓: {PointSystem.QUEST_TICKET:,} Point")
    print(f"  연속 기록 보호권: {PointSystem.STREAK_PROTECTION:,} Point")

    # 구매력 분석
    print(f"\n🛒 구매력 분석 ({days}일 기준)")
    print(f"  무료 모임: {total_income // PointSystem.FREE_MEETING}회 참여 가능")
    print(f"  프리미엄 팩: {total_income // PointSystem.PREMIUM_QUEST_PACK}개월 구독 가능")
    print(f"  퀘스트 티켓: {total_income // PointSystem.QUEST_TICKET}개 구매 가능")

    print("\n" + "=" * 70)


# ============================================================================
# CLI 인터페이스
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='셰르파 앱 게임 밸런스 시뮬레이터',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
예시:
  # 등반력 시뮬레이션 (레벨 15, 체력 15%, 지식 10%, 기술 5%)
  python balance_simulator.py --mode climbing --level 15 --stamina 15 --knowledge 10 --technique 5

  # 레벨업 시뮬레이션 (하루 3회 활동, 활동당 50 XP, 30일)
  python balance_simulator.py --mode levelup --activities-per-day 3 --xp-per-activity 50 --days 30

  # 포인트 경제 시뮬레이션 (하루 퀘스트 1회, 주당 모임 2회, 30일)
  python balance_simulator.py --mode points --daily-quests 1 --meetings 2 --days 30
        """
    )

    parser.add_argument('--mode',
                       choices=['climbing', 'levelup', 'points'],
                       required=True,
                       help='시뮬레이션 모드')

    # Climbing mode arguments
    parser.add_argument('--level', type=int, default=15,
                       help='캐릭터 레벨 (기본값: 15)')
    parser.add_argument('--stamina', type=float, default=15.0,
                       help='체력 능력치 %% (기본값: 15.0)')
    parser.add_argument('--knowledge', type=float, default=10.0,
                       help='지식 능력치 %% (기본값: 10.0)')
    parser.add_argument('--technique', type=float, default=5.0,
                       help='기술 능력치 %% (기본값: 5.0)')
    parser.add_argument('--willpower', type=float, default=0.0,
                       help='의지 능력치 %% (성공률 보정, 기본값: 0.0)')
    parser.add_argument('--sociality', type=float, default=0.0,
                       help='사교성 능력치 %% (시간 단축, 기본값: 0.0)')
    parser.add_argument('--badge-bonus', type=float, default=0.0,
                       help='뱃지 등반력 보너스 %% (기본값: 0.0)')
    parser.add_argument('--badge-success', type=float, default=0.0,
                       help='뱃지 성공률 보너스 %% (기본값: 0.0)')

    # Levelup mode arguments
    parser.add_argument('--activities-per-day', type=int, default=3,
                       help='일일 활동 횟수 (기본값: 3)')
    parser.add_argument('--xp-per-activity', type=int, default=50,
                       help='활동당 평균 XP (기본값: 50)')
    parser.add_argument('--start-level', type=int, default=1,
                       help='시작 레벨 (기본값: 1)')

    # Points mode arguments
    parser.add_argument('--daily-quests', type=int, default=1,
                       help='일일 퀘스트 올클리어 횟수 (기본값: 1)')
    parser.add_argument('--meetings', type=int, default=2,
                       help='주당 모임 참석 횟수 (기본값: 2)')
    parser.add_argument('--hosted-meetings', type=int, default=0,
                       help='주당 모임 주최 횟수 (기본값: 0)')
    parser.add_argument('--community-active', action='store_true',
                       help='커뮤니티 활동 여부 (기본값: False)')

    # Common arguments
    parser.add_argument('--days', type=int, default=30,
                       help='시뮬레이션 기간 (일) (기본값: 30)')

    args = parser.parse_args()

    # 모드별 실행
    if args.mode == 'climbing':
        simulate_climbing(args)
    elif args.mode == 'levelup':
        simulate_levelup(args)
    elif args.mode == 'points':
        simulate_points(args)


if __name__ == '__main__':
    main()
