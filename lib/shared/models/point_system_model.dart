import 'package:flutter/material.dart';

// 포인트 시스템 기본 설정
class PointSystemConfig {
  static const int POINT_TO_WON_RATIO = 1;           // 1포인트 = 1원
  static const double WITHDRAWAL_FEE_RATE = 0.10;    // 출금 수수료 10%
  static const int MIN_WITHDRAWAL_POINTS = 10000;    // 최소 출금 포인트
  static const int SIGNUP_BONUS_POINTS = 3000;       // 가입 보너스
  static const int FREE_MEETING_FEE = 1000;          // 무료 모임 수수료
  static const double PAID_MEETING_FEE_RATE = 0.05;  // 유료 모임 수수료 5%
}

enum PointSource {
  // 퀘스트 관련
  dailyQuestAd,         // 일일 퀘스트 전체 완료 후 광고
  weeklyQuestHard,      // 어려운 주간 퀘스트
  weeklyQuestAd,        // 주간 퀘스트 전체 완료 후 광고
  premiumQuestRare,     // 레어 프리미엄 퀘스트
  premiumQuestEpic,     // 에픽 프리미엄 퀘스트
  premiumQuestLegend,   // 전설 프리미엄 퀘스트

  // 일일 목표
  dailyGoalAd,          // 일일 목표 전체 완료 후 광고
  streakBonus,          // 연속 기록 보너스

  // 모임 관련
  meetingAttend,        // 모임 참석
  meetingHost,          // 모임 호스팅
  firstHostBonus,       // 첫 호스팅 보너스
  monthlyAttendBonus,   // 월 5회 이상 참석 보너스
  monthlyHostBonus,     // 월 5회 이상 호스팅 보너스

  // 커뮤니티
  popularPost,          // 인기 게시글
  helpfulAnswer,        // 도움되는 답변
  dailyActivity,        // 일일 활동

  // 기타
  levelUp,              // 레벨업
  signup,               // 가입 보너스
}

enum PointSpendType {
  freeMeeting,          // 무료 모임 참여
  paidMeeting,          // 유료 모임 참여
  freeChallenge,        // 무료 챌린지 참여
  paidChallenge,        // 유료 챌린지 참여
  meetingBoost,         // 모임 홍보 부스트
  premiumQuestPack,     // 프리미엄 퀘스트 팩
  analysisReport,       // 고급 분석 리포트
  questTicket,          // 퀘스트 완료 티켓
  streakProtection,     // 연속 기록 보호권
  pointGift,            // 포인트 선물
  pointDonation,        // 포인트 기부
  newUserSupport,       // 신규 유저 지원 팩
}

// ✅ 통합된 PointTransaction 클래스 (중복 제거)
class PointTransaction {
  final String id;
  final int amount;
  final PointSource? source;
  final PointSpendType? spendType;
  final bool isEarned;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const PointTransaction({
    required this.id,
    required this.amount,
    this.source,
    this.spendType,
    required this.isEarned,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  // ✅ 편의 생성자 - 간단한 트랜잭션용
  const PointTransaction.simple({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdAt,
  }) : source = null,
        spendType = null,
        isEarned = true,
        metadata = null;

  // ✅ type getter 추가 (기존 코드 호환성)
  String get type {
    if (isEarned) {
      return 'earned';
    } else if (spendType != null) {
      return 'spent';
    } else {
      return 'withdrawn';
    }
  }

  // ✅ timestamp getter 추가 (기존 코드 호환성)
  DateTime get timestamp => createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'source': source?.name,
      'spendType': spendType?.name,
      'isEarned': isEarned,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  PointTransaction copyWith({
    String? id,
    int? amount,
    PointSource? source,
    PointSpendType? spendType,
    bool? isEarned,
    String? description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return PointTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      spendType: spendType ?? this.spendType,
      isEarned: isEarned ?? this.isEarned,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

// ✅ 포인트 유틸리티 클래스
class PointUtils {
  // 포인트 획득량 계산
  static int calculateEarnedPoints(PointSource source) {
    switch (source) {
      case PointSource.dailyQuestAd:
        return 100;
      case PointSource.weeklyQuestHard:
        return 500;
      case PointSource.weeklyQuestAd:
        return 300;
      case PointSource.premiumQuestRare:
        return 200;
      case PointSource.premiumQuestEpic:
        return 500;
      case PointSource.premiumQuestLegend:
        return 1000;
      case PointSource.dailyGoalAd:
        return 50;
      case PointSource.streakBonus:
        return 100;
      case PointSource.meetingAttend:
        return 50;
      case PointSource.meetingHost:
        return 100;
      case PointSource.firstHostBonus:
        return 500;
      case PointSource.monthlyAttendBonus:
        return 300;
      case PointSource.monthlyHostBonus:
        return 500;
      case PointSource.popularPost:
        return 100;
      case PointSource.helpfulAnswer:
        return 50;
      case PointSource.dailyActivity:
        return 20;
      case PointSource.levelUp:
        return 200;
      case PointSource.signup:
        return PointSystemConfig.SIGNUP_BONUS_POINTS;
      default:
        return 0;
    }
  }

  // 포인트 소모량 계산
  static int calculateSpentPoints(PointSpendType spendType) {
    switch (spendType) {
      case PointSpendType.freeMeeting:
        return PointSystemConfig.FREE_MEETING_FEE;
      case PointSpendType.paidMeeting:
        return 0; // 유료 모임은 별도 계산
      case PointSpendType.freeChallenge:
        return 500;
      case PointSpendType.paidChallenge:
        return 0; // 유료 챌린지는 별도 계산
      case PointSpendType.meetingBoost:
        return 200;
      case PointSpendType.premiumQuestPack:
        return 2000;
      case PointSpendType.analysisReport:
        return 1000;
      case PointSpendType.questTicket:
        return 500;
      case PointSpendType.streakProtection:
        return 300;
      case PointSpendType.pointGift:
        return 0; // 선물 금액에 따라 다름
      case PointSpendType.pointDonation:
        return 0; // 기부 금액에 따라 다름
      case PointSpendType.newUserSupport:
        return 1000;
      default:
        return 0;
    }
  }

  // 포인트 소스 설명
  static String getSourceDescription(PointSource source) {
    switch (source) {
      case PointSource.dailyQuestAd:
        return '일일 퀘스트 완료 광고 시청';
      case PointSource.weeklyQuestHard:
        return '어려운 주간 퀘스트 완료';
      case PointSource.weeklyQuestAd:
        return '주간 퀘스트 완료 광고 시청';
      case PointSource.premiumQuestRare:
        return '레어 프리미엄 퀘스트 완료';
      case PointSource.premiumQuestEpic:
        return '에픽 프리미엄 퀘스트 완료';
      case PointSource.premiumQuestLegend:
        return '전설 프리미엄 퀘스트 완료';
      case PointSource.dailyGoalAd:
        return '일일 목표 완료 광고 시청';
      case PointSource.streakBonus:
        return '연속 기록 보너스';
      case PointSource.meetingAttend:
        return '모임 참석';
      case PointSource.meetingHost:
        return '모임 호스팅';
      case PointSource.firstHostBonus:
        return '첫 호스팅 보너스';
      case PointSource.monthlyAttendBonus:
        return '월간 참석 보너스';
      case PointSource.monthlyHostBonus:
        return '월간 호스팅 보너스';
      case PointSource.popularPost:
        return '인기 게시글 작성';
      case PointSource.helpfulAnswer:
        return '도움되는 답변 작성';
      case PointSource.dailyActivity:
        return '일일 활동 참여';
      case PointSource.levelUp:
        return '레벨업 달성';
      case PointSource.signup:
        return '회원가입 보너스';
      default:
        return '포인트 획득';
    }
  }

  // 포인트 소모 설명
  static String getSpendDescription(PointSpendType spendType) {
    switch (spendType) {
      case PointSpendType.freeMeeting:
        return '무료 모임 참여';
      case PointSpendType.paidMeeting:
        return '유료 모임 참여';
      case PointSpendType.freeChallenge:
        return '무료 챌린지 참여';
      case PointSpendType.paidChallenge:
        return '유료 챌린지 참여';
      case PointSpendType.meetingBoost:
        return '모임 홍보 부스트';
      case PointSpendType.premiumQuestPack:
        return '프리미엄 퀘스트 팩 구매';
      case PointSpendType.analysisReport:
        return '고급 분석 리포트 구매';
      case PointSpendType.questTicket:
        return '퀘스트 완료 티켓 구매';
      case PointSpendType.streakProtection:
        return '연속 기록 보호권 구매';
      case PointSpendType.pointGift:
        return '포인트 선물';
      case PointSpendType.pointDonation:
        return '포인트 기부';
      case PointSpendType.newUserSupport:
        return '신규 유저 지원 팩 구매';
      default:
        return '포인트 사용';
    }
  }
}
