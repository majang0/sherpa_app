// features/climbing/models/badge.dart
// 글로벌 뱃지 시스템으로 마이그레이션된 호환성 파일

// 🔄 글로벌 뱃지 시스템 re-export
export '../../../shared/models/global_badge_model.dart';

// 🔄 기존 코드 호환성을 위한 타입 별칭
import '../../../shared/models/global_badge_model.dart' as global;

// 기존 Badge 타입을 GlobalBadge로 리다이렉트
typedef Badge = global.GlobalBadge;
typedef BadgeTier = global.GlobalBadgeTier;

// 기존 enum 호환성
class BadgeEffectType {
  static const String climbingPowerMultiply = 'CLIMBING_POWER_MULTIPLY';
  static const String successProbAdd = 'SUCCESS_PROB_ADD';
  static const String pointMultiply = 'POINT_MULTIPLY';
  static const String failureXpMultiply = 'FAILURE_XP_MULTIPLY';
}
