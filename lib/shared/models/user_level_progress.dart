// lib/shared/models/user_level_progress.dart

class UserLevelProgress {
  final int currentLevelExp;
  final int requiredExpForNextLevel;
  final double progress;

  const UserLevelProgress({
    required this.currentLevelExp,
    required this.requiredExpForNextLevel,
    required this.progress,
  });

  factory UserLevelProgress.initial() {
    return const UserLevelProgress(
      currentLevelExp: 0,
      requiredExpForNextLevel: 100,
      progress: 0.0,
    );
  }
}
