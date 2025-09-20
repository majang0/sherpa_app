import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/point_system_model.dart';

/// 포인트 데이터 모델 (기존 코드 호환성용)
class PointData {
  final int totalPoints;
  final int withdrawablePoints;
  final List<PointTransaction> transactions;
  final DateTime lastUpdated;

  const PointData({
    required this.totalPoints,
    required this.withdrawablePoints,
    required this.transactions,
    required this.lastUpdated,
  });

  /// 가입 시 기본 포인트 (3000 포인트)
  static PointData get initial => PointData(
        totalPoints: PointSystemConfig.SIGNUP_BONUS_POINTS,
        withdrawablePoints: 0,
        transactions: [
          PointTransaction(
            id: 'welcome_bonus',
            amount: PointSystemConfig.SIGNUP_BONUS_POINTS,
            isEarned: true,
            description: '가입 축하 보너스',
            createdAt: DateTime.now(),
            source: PointSource.signup,
          ),
        ],
        lastUpdated: DateTime.now(),
      );

  /// 출금 가능한 포인트 계산 (10,000 포인트 단위)
  int get actualWithdrawablePoints {
    return (totalPoints ~/ PointSystemConfig.MIN_WITHDRAWAL_POINTS) *
        PointSystemConfig.MIN_WITHDRAWAL_POINTS;
  }

  /// 출금 시 수수료 계산 (10%)
  int calculateWithdrawalFee(int withdrawAmount) {
    return (withdrawAmount * PointSystemConfig.WITHDRAWAL_FEE_RATE).round();
  }

  /// 출금 후 실제 받을 금액 (수수료 제외)
  int calculateActualWithdrawal(int withdrawAmount) {
    return withdrawAmount - calculateWithdrawalFee(withdrawAmount);
  }

  /// 무료 모임 참여 가능 여부 (1000 포인트 필요)
  bool get canJoinFreeMeeting {
    return totalPoints >= PointSystemConfig.FREE_MEETING_FEE;
  }

  /// 유료 모임 수수료 계산 (5%)
  int calculatePaidMeetingFee(int meetingPrice) {
    return (meetingPrice * PointSystemConfig.PAID_MEETING_FEE_RATE).round();
  }

  PointData copyWith({
    int? totalPoints,
    int? withdrawablePoints,
    List<PointTransaction>? transactions,
    DateTime? lastUpdated,
  }) {
    return PointData(
      totalPoints: totalPoints ?? this.totalPoints,
      withdrawablePoints: withdrawablePoints ?? this.withdrawablePoints,
      transactions: transactions ?? this.transactions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalPoints': totalPoints,
        'withdrawablePoints': withdrawablePoints,
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory PointData.fromJson(Map<String, dynamic> json) => PointData(
        totalPoints: json['totalPoints']?.toInt() ??
            PointSystemConfig.SIGNUP_BONUS_POINTS,
        withdrawablePoints: json['withdrawablePoints']?.toInt() ?? 0,
        transactions: (json['transactions'] as List?)
                ?.map((t) => PointTransaction(
                      id: t['id'] ?? '',
                      amount: t['amount']?.toInt() ?? 0,
                      isEarned: t['isEarned'] ?? true,
                      description: t['description'] ?? '',
                      createdAt: DateTime.tryParse(t['createdAt'] ?? '') ??
                          DateTime.now(),
                      source: t['source'] != null
                          ? PointSource.values.firstWhere(
                              (e) => e.name == t['source'],
                              orElse: () => PointSource.signup,
                            )
                          : null,
                      spendType: t['spendType'] != null
                          ? PointSpendType.values.firstWhere(
                              (e) => e.name == t['spendType'],
                              orElse: () => PointSpendType.freeMeeting,
                            )
                          : null,
                    ))
                .toList() ??
            [],
        lastUpdated:
            DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      );
}

/// 포인트 거래 유형 (기존 코드 호환성용)
enum PointTransactionType {
  bonus, // 보너스 (가입, 이벤트 등)
  earned, // 획득 (등반 성공, 퀘스트 완료 등)
  spent, // 사용 (모임 수수료 등)
  withdrawal, // 출금
  refund, // 환불
  other, // 기타
}

/// 글로벌 포인트 상태 관리 Provider
final globalPointProvider =
    StateNotifierProvider<GlobalPointNotifier, PointData>((ref) {
  return GlobalPointNotifier();
});

class GlobalPointNotifier extends StateNotifier<PointData> {
  GlobalPointNotifier() : super(PointData.initial) {
    _loadPointData();
  }

  /// 연속 기록 보너스 설정
  static int getStreakBonus(int consecutiveDays) {
    if (consecutiveDays >= 365) return 1000; // 1년 연속
    if (consecutiveDays >= 100) return 500; // 100일 연속
    if (consecutiveDays >= 30) return 200; // 30일 연속
    if (consecutiveDays >= 7) return 50; // 7일 연속
    return 0;
  }

  /// SharedPreferences에서 포인트 데이터 로드
  Future<void> _loadPointData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🔧 테스트를 위해 매번 3천 포인트로 초기화
      await prefs.remove('global_point_data'); // 기존 데이터 삭제
      state = PointData.initial; // 3천 포인트로 초기화
      await _savePointData(); // 초기화된 데이터 저장

      // ✅ 원래 로직 (주석 처리)
      // final pointJson = prefs.getString('global_point_data');
      // if (pointJson != null) {
      //   final pointData = jsonDecode(pointJson);
      //   state = PointData.fromJson(pointData);
      // }
    } catch (e) {}
  }

  /// SharedPreferences에 포인트 데이터 저장
  Future<void> _savePointData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('global_point_data', jsonEncode(state.toJson()));
    } catch (e) {}
  }

  /// 포인트 추가 (등반 성공, 퀘스트 완료 등)
  void addPoints(int amount, String description,
      {PointTransactionType type = PointTransactionType.earned}) {
    final transaction = PointTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      isEarned: type == PointTransactionType.earned ||
          type == PointTransactionType.bonus,
      description: description,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      totalPoints: state.totalPoints + amount,
      transactions: [...state.transactions, transaction],
      lastUpdated: DateTime.now(),
    );

    _savePointData();
  }

  /// 세분화된 포인트 지급 (소스 추적 기능 포함)
  void earnPoints(int amount, PointSource source, String description) {
    final transaction = PointTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      isEarned: true,
      description: description,
      createdAt: DateTime.now(),
      source: source,
    );

    state = state.copyWith(
      totalPoints: state.totalPoints + amount,
      transactions: [...state.transactions, transaction],
      lastUpdated: DateTime.now(),
    );

    _savePointData();
    _showPointEarnedMessage(amount, source);
  }

  /// 포인트 사용 (모임 수수료 등)
  bool spendPoints(int amount, String description) {
    if (state.totalPoints < amount) {
      return false; // 포인트 부족
    }

    final transaction = PointTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      isEarned: false,
      description: description,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      totalPoints: state.totalPoints - amount,
      transactions: [...state.transactions, transaction],
      lastUpdated: DateTime.now(),
    );

    _savePointData();
    return true;
  }

  /// 세분화된 포인트 사용 (유형 추적 기능 포함)
  bool spendPointsDetailed(
      int amount, PointSpendType spendType, String description) {
    if (state.totalPoints < amount) {
      // 부족 메시지 추가 예정 (셀르피 연동)
      return false;
    }

    final transaction = PointTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      isEarned: false,
      description: description,
      createdAt: DateTime.now(),
      spendType: spendType,
    );

    state = state.copyWith(
      totalPoints: state.totalPoints - amount,
      transactions: [...state.transactions, transaction],
      lastUpdated: DateTime.now(),
    );

    _savePointData();
    return true;
  }

  /// 무료 모임 수수료 지불 (1000 포인트)
  bool payFreeMeetingFee(String meetingName) {
    return spendPoints(
        PointSystemConfig.FREE_MEETING_FEE, '무료 모임 수수료: $meetingName');
  }

  /// 유료 모임 수수료 지불 (5%)
  bool payPaidMeetingFee(int meetingPrice, String meetingName) {
    final fee = state.calculatePaidMeetingFee(meetingPrice);
    return spendPoints(fee, '유료 모임 수수료: $meetingName ($fee 포인트)');
  }

  /// 포인트 출금 처리
  bool withdrawPoints(int amount) {
    if (amount < PointSystemConfig.MIN_WITHDRAWAL_POINTS ||
        amount % PointSystemConfig.MIN_WITHDRAWAL_POINTS != 0) {
      return false; // 10,000 포인트 단위가 아님
    }

    if (state.totalPoints < amount) {
      return false; // 포인트 부족
    }

    final fee = state.calculateWithdrawalFee(amount);
    final actualAmount = amount - fee;

    final withdrawalTransaction = PointTransaction(
      id: 'withdrawal_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      isEarned: false,
      description: '포인트 출금 (수수료 $fee 포인트 포함)',
      createdAt: DateTime.now(),
      metadata: {
        'withdrawalAmount': amount,
        'fee': fee,
        'actualAmount': actualAmount,
        'exchangeRate': PointSystemConfig.POINT_TO_WON_RATIO,
      },
    );

    state = state.copyWith(
      totalPoints: state.totalPoints - amount,
      transactions: [...state.transactions, withdrawalTransaction],
      lastUpdated: DateTime.now(),
    );

    _savePointData();
    return true;
  }

  /// 포인트 환불
  void refundPoints(int amount, String description) {
    final transaction = PointTransaction(
      id: 'refund_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      isEarned: true,
      description: '환불: $description',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      totalPoints: state.totalPoints + amount,
      transactions: [...state.transactions, transaction],
      lastUpdated: DateTime.now(),
    );

    _savePointData();
  }

  /// 거래 내역 초기화 (관리자용)
  void clearTransactions() {
    state = state.copyWith(
      transactions: [],
      lastUpdated: DateTime.now(),
    );
    _savePointData();
  }

  // ==================== 퀘스트 관련 포인트 지급 ====================

  /// 일일 퀘스트 전체 완료 후 광고 시청
  void onDailyQuestAllClearAd() {
    earnPoints(100, PointSource.dailyQuestAd, '일일 퀘스트 전체 완료 + 광고 시청');
  }

  /// 어려운 주간 퀘스트 완료
  void onWeeklyQuestHardComplete() {
    earnPoints(100, PointSource.weeklyQuestHard, '어려운 주간 퀘스트 완료');
  }

  /// 주간 퀘스트 전체 완료 후 광고 시청
  void onWeeklyQuestAllClearAd() {
    earnPoints(300, PointSource.weeklyQuestAd, '주간 퀘스트 전체 완료 + 광고 시청');
  }

  /// 프리미엄 퀘스트 완료
  void onPremiumQuestComplete(String rarity) {
    int points;
    PointSource source;
    String description;

    switch (rarity.toLowerCase()) {
      case 'rare':
        points = 100;
        source = PointSource.premiumQuestRare;
        description = '레어 프리미엄 퀘스트 완료';
        break;
      case 'epic':
        points = 200;
        source = PointSource.premiumQuestEpic;
        description = '에픽 프리미엄 퀘스트 완료';
        break;
      case 'legendary':
        points = 300;
        source = PointSource.premiumQuestLegend;
        description = '전설 프리미엄 퀘스트 완료';
        break;
      default:
        return;
    }

    earnPoints(points, source, description);
  }

  // ==================== 일일 목표 관련 포인트 지급 ====================

  /// 일일 목표 전체 완료 (기본 보상)
  int onDailyGoalAllClear() {
    const points = 50;
    earnPoints(points, PointSource.dailyGoalAd, '일일 목표 전체 완료');
    return points;
  }

  /// 일일 목표 전체 완료 후 광고 시청
  void onDailyGoalAllClearAd() {
    earnPoints(100, PointSource.dailyGoalAd, '일일 목표 전체 완료 + 광고 시청');
  }

  /// 연속 기록 보너스
  void onStreakBonus(int consecutiveDays) {
    final bonus = getStreakBonus(consecutiveDays);
    if (bonus > 0) {
      earnPoints(
          bonus, PointSource.streakBonus, '${consecutiveDays}일 연속 기록 보너스');
    }
  }

  // ==================== 모임 관련 포인트 지급 ====================

  /// 모임 참석
  void onMeetingAttend() {
    earnPoints(100, PointSource.meetingAttend, '모임 참석');
  }

  /// 모임 호스팅
  void onMeetingHost({bool isFirstTime = false}) {
    earnPoints(300, PointSource.meetingHost, '모임 호스팅');

    if (isFirstTime) {
      earnPoints(700, PointSource.firstHostBonus, '첫 모임 호스팅 보너스');
    }
  }

  /// 월 5회 이상 참석 보너스
  void onMonthlyAttendBonus() {
    earnPoints(200, PointSource.monthlyAttendBonus, '월 5회 이상 참석 보너스');
  }

  /// 월 5회 이상 호스팅 보너스
  void onMonthlyHostBonus() {
    earnPoints(500, PointSource.monthlyHostBonus, '월 5회 이상 호스팅 보너스');
  }

  // ==================== 커뮤니티 관련 포인트 지급 ====================

  /// 인기 게시글 (좋아요 50개 이상)
  void onPopularPost() {
    earnPoints(100, PointSource.popularPost, '인기 게시글 달성');
  }

  /// 도움되는 답변 (댓글 좋아요 10개 이상)
  void onHelpfulAnswer() {
    earnPoints(50, PointSource.helpfulAnswer, '도움되는 답변 작성');
  }

  /// 일일 활동 (하루 1회)
  void onDailyActivity() {
    earnPoints(30, PointSource.dailyActivity, '일일 커뮤니티 활동');
  }

  /// 레벨업
  void onLevelUp(int newLevel) {
    earnPoints(100, PointSource.levelUp, '레벨 ${newLevel} 달성');
  }

  // ==================== 포인트 사용 메서드들 ====================

  /// 무료 모임 참여
  bool joinFreeMeeting() {
    return spendPointsDetailed(1000, PointSpendType.freeMeeting, '무료 모임 참여');
  }

  /// 유료 모임 참여
  bool joinPaidMeeting(int amount) {
    return spendPointsDetailed(amount, PointSpendType.paidMeeting, '유료 모임 참여');
  }

  /// 무료 챌린지 참여
  bool joinFreeChallenge() {
    return spendPointsDetailed(500, PointSpendType.freeChallenge, '무료 챌린지 참여');
  }

  /// 유료 챌린지 참여
  bool joinPaidChallenge(int amount) {
    return spendPointsDetailed(
        amount, PointSpendType.paidChallenge, '유료 챌린지 참여');
  }

  /// 모임 홍보 부스트
  bool boostMeeting() {
    return spendPointsDetailed(3000, PointSpendType.meetingBoost, '모임 홍보 부스트');
  }

  /// 프리미엄 퀘스트 팩
  bool buyPremiumQuestPack() {
    return spendPointsDetailed(
        2000, PointSpendType.premiumQuestPack, '프리미엄 퀘스트 팩 구매');
  }

  /// 고급 분석 리포트
  bool buyAnalysisReport() {
    return spendPointsDetailed(
        3000, PointSpendType.analysisReport, '고급 분석 리포트 구매');
  }

  /// 퀘스트 완료 티켓
  bool buyQuestTicket() {
    return spendPointsDetailed(
        1000, PointSpendType.questTicket, '퀘스트 완료 티켓 구매');
  }

  /// 연속 기록 보호권
  bool buyStreakProtection() {
    return spendPointsDetailed(
        500, PointSpendType.streakProtection, '연속 기록 보호권 구매');
  }

  /// 친구에게 포인트 선물
  bool giftPointsToFriend(int amount, String friendName) {
    return spendPointsDetailed(
        amount, PointSpendType.pointGift, '${friendName}님에게 포인트 선물');
  }

  /// 신규 유저 지원 팩
  bool buyNewUserSupportPack(String friendName) {
    return spendPointsDetailed(
        1000, PointSpendType.newUserSupport, '${friendName}님에게 신규 유저 지원 팩 선물');
  }

  // ==================== 메시지 시스템 ====================

  /// 포인트 획득 메시지 표시
  void _showPointEarnedMessage(int amount, PointSource source) {
    String message;
    // 셀르피 이모션은 추후 연동 예정

    switch (source) {
      case PointSource.dailyQuestAd:
        message = '일일 퀘스트 완료! +${amount}P 🎯';
        break;
      case PointSource.weeklyQuestHard:
        message = '어려운 주간 퀘스트 완료! +${amount}P 💪';
        break;
      case PointSource.streakBonus:
        message = '연속 기록 보너스! +${amount}P 🔥';
        break;
      case PointSource.meetingHost:
        message = '모임 호스팅! +${amount}P 👥';
        break;
      case PointSource.firstHostBonus:
        message = '첫 호스팅 축하! +${amount}P 🎉';
        break;
      case PointSource.levelUp:
        message = '레벨업 축하! +${amount}P 🚀';
        break;
      default:
        message = '+${amount}P 획득! 💰';
    }

    // TODO: 셀르피 연동 추가 예정
  }
}

/// 전체 앱에서 사용하는 포인트 관련 Provider들
final globalTotalPointsProvider = Provider<int>((ref) {
  final pointData = ref.watch(globalPointProvider);
  return pointData.totalPoints;
});

final globalWithdrawablePointsProvider = Provider<int>((ref) {
  final pointData = ref.watch(globalPointProvider);
  return pointData.actualWithdrawablePoints;
});

final globalCanJoinFreeMeetingProvider = Provider<bool>((ref) {
  final pointData = ref.watch(globalPointProvider);
  return pointData.canJoinFreeMeeting;
});

final globalPointTransactionsProvider = Provider<List<PointTransaction>>((ref) {
  final pointData = ref.watch(globalPointProvider);
  return pointData.transactions;
});

final globalRecentTransactionsProvider =
    Provider<List<PointTransaction>>((ref) {
  final transactions = ref.watch(globalPointTransactionsProvider);
  return transactions.take(10).toList(); // 최근 10개 거래
});
