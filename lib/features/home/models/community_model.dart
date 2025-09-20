import 'package:flutter/material.dart';

/// 커뮤니티 활동 모델 (기존 유지)
class CommunityActivity {
  final String id;
  final String title;
  final String type;
  final String description;
  final String emoji;
  final int participants;
  final int maxParticipants;
  final DateTime startTime;
  final bool isJoined;
  final String difficulty;
  final int rewardXP;
  final int rewardPoints;

  CommunityActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.emoji,
    required this.participants,
    required this.maxParticipants,
    required this.startTime,
    required this.isJoined,
    required this.difficulty,
    required this.rewardXP,
    required this.rewardPoints,
  });
}

/// 게시글 타입
enum PostType {
  general, // 일반 게시글
  question, // 질문
  tip, // 팁 공유
  record, // 기록 공유
  event, // 이벤트
}

/// 커뮤니티 게시글 모델
class CommunityPost {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final String category;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isLikedByUser;
  final bool hasReceivedPopularReward;
  final List<String> imageUrls;
  final PostType type;

  const CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    required this.category,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.isLikedByUser,
    required this.hasReceivedPopularReward,
    required this.imageUrls,
    required this.type,
  });

  /// 인기 게시글 여부 (좋아요 50개 이상)
  bool get isPopular => likesCount >= 50;

  /// 카테고리별 색상
  Color get categoryColor {
    switch (category) {
      case '등산':
        return const Color(0xFF10B981);
      case '독서':
        return const Color(0xFF6366F1);
      case '운동':
        return const Color(0xFFEF4444);
      case '스터디':
        return const Color(0xFFF59E0B);
      case '취미':
        return const Color(0xFF8B5CF6);
      case '일상':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// 카테고리별 이모지
  String get categoryEmoji {
    switch (category) {
      case '등산':
        return '🏔️';
      case '독서':
        return '📚';
      case '운동':
        return '💪';
      case '스터디':
        return '📖';
      case '취미':
        return '🎨';
      case '일상':
        return '☀️';
      default:
        return '💬';
    }
  }

  /// 게시 시간을 상대적으로 표시
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  CommunityPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorName,
    String? authorId,
    DateTime? createdAt,
    String? category,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    bool? isLikedByUser,
    bool? hasReceivedPopularReward,
    List<String>? imageUrls,
    PostType? type,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      hasReceivedPopularReward:
          hasReceivedPopularReward ?? this.hasReceivedPopularReward,
      imageUrls: imageUrls ?? this.imageUrls,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorName': authorName,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'tags': tags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'isLikedByUser': isLikedByUser,
      'hasReceivedPopularReward': hasReceivedPopularReward,
      'imageUrls': imageUrls,
      'type': type.name,
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '',
      authorId: json['authorId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
      isLikedByUser: json['isLikedByUser'] ?? false,
      hasReceivedPopularReward: json['hasReceivedPopularReward'] ?? false,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      type: PostType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PostType.general,
      ),
    );
  }
}

/// 커뮤니티 댓글 모델
class CommunityComment {
  final String id;
  final String postId;
  final String content;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final int likesCount;
  final bool isLikedByUser;
  final bool hasReceivedHelpfulReward;
  final String? parentCommentId; // 대댓글용

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    required this.likesCount,
    required this.isLikedByUser,
    required this.hasReceivedHelpfulReward,
    this.parentCommentId,
  });

  /// 도움되는 댓글 여부 (좋아요 10개 이상)
  bool get isHelpful => likesCount >= 10;

  /// 댓글 시간을 상대적으로 표시
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  CommunityComment copyWith({
    String? id,
    String? postId,
    String? content,
    String? authorName,
    String? authorId,
    DateTime? createdAt,
    int? likesCount,
    bool? isLikedByUser,
    bool? hasReceivedHelpfulReward,
    String? parentCommentId,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      hasReceivedHelpfulReward:
          hasReceivedHelpfulReward ?? this.hasReceivedHelpfulReward,
      parentCommentId: parentCommentId ?? this.parentCommentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'authorName': authorName,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'isLikedByUser': isLikedByUser,
      'hasReceivedHelpfulReward': hasReceivedHelpfulReward,
      'parentCommentId': parentCommentId,
    };
  }

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '',
      authorId: json['authorId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      likesCount: json['likesCount'] ?? 0,
      isLikedByUser: json['isLikedByUser'] ?? false,
      hasReceivedHelpfulReward: json['hasReceivedHelpfulReward'] ?? false,
      parentCommentId: json['parentCommentId'],
    );
  }
}

/// 커뮤니티 활동 타입
enum CommunityActivityType {
  postCreated, // 게시글 작성
  commentCreated, // 댓글 작성
  postLiked, // 게시글 좋아요
  commentLiked, // 댓글 좋아요
  postShared, // 게시글 공유
}

/// 일일 커뮤니티 활동 기록
class DailyCommunityActivity {
  final DateTime date;
  final Set<CommunityActivityType> activities;
  final bool hasReceivedDailyReward;

  const DailyCommunityActivity({
    required this.date,
    required this.activities,
    required this.hasReceivedDailyReward,
  });

  /// 오늘 활동했는지 확인
  bool get isActiveToday {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day &&
        activities.isNotEmpty;
  }

  DailyCommunityActivity copyWith({
    DateTime? date,
    Set<CommunityActivityType>? activities,
    bool? hasReceivedDailyReward,
  }) {
    return DailyCommunityActivity(
      date: date ?? this.date,
      activities: activities ?? this.activities,
      hasReceivedDailyReward:
          hasReceivedDailyReward ?? this.hasReceivedDailyReward,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'activities': activities.map((e) => e.name).toList(),
      'hasReceivedDailyReward': hasReceivedDailyReward,
    };
  }

  factory DailyCommunityActivity.fromJson(Map<String, dynamic> json) {
    return DailyCommunityActivity(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      activities: (json['activities'] as List? ?? [])
          .map((e) => CommunityActivityType.values.firstWhere(
                (type) => type.name == e,
                orElse: () => CommunityActivityType.postCreated,
              ))
          .toSet(),
      hasReceivedDailyReward: json['hasReceivedDailyReward'] ?? false,
    );
  }
}

/// 커뮤니티 통계
class CommunityStatistics {
  final int totalPosts;
  final int totalComments;
  final int totalLikes;
  final int popularPosts; // 인기 게시글 수
  final int helpfulComments; // 도움되는 댓글 수
  final int activeDays; // 활동한 날 수
  final int totalPoints; // 커뮤니티로 얻은 총 포인트

  const CommunityStatistics({
    required this.totalPosts,
    required this.totalComments,
    required this.totalLikes,
    required this.popularPosts,
    required this.helpfulComments,
    required this.activeDays,
    required this.totalPoints,
  });

  CommunityStatistics copyWith({
    int? totalPosts,
    int? totalComments,
    int? totalLikes,
    int? popularPosts,
    int? helpfulComments,
    int? activeDays,
    int? totalPoints,
  }) {
    return CommunityStatistics(
      totalPosts: totalPosts ?? this.totalPosts,
      totalComments: totalComments ?? this.totalComments,
      totalLikes: totalLikes ?? this.totalLikes,
      popularPosts: popularPosts ?? this.popularPosts,
      helpfulComments: helpfulComments ?? this.helpfulComments,
      activeDays: activeDays ?? this.activeDays,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPosts': totalPosts,
      'totalComments': totalComments,
      'totalLikes': totalLikes,
      'popularPosts': popularPosts,
      'helpfulComments': helpfulComments,
      'activeDays': activeDays,
      'totalPoints': totalPoints,
    };
  }

  factory CommunityStatistics.fromJson(Map<String, dynamic> json) {
    return CommunityStatistics(
      totalPosts: json['totalPosts'] ?? 0,
      totalComments: json['totalComments'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
      popularPosts: json['popularPosts'] ?? 0,
      helpfulComments: json['helpfulComments'] ?? 0,
      activeDays: json['activeDays'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
    );
  }
}
