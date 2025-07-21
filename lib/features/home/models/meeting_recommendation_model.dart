import 'package:flutter/material.dart';
import 'growth_synergy_model.dart' show MeetingCategory;



enum MeetingDifficulty {
  beginner,
  intermediate,
  advanced
}

enum MeetingStatus {
  recruiting,
  almostFull,
  waitingList,
  closed
}

class RecommendedMeeting {
  final String id;
  final String title;
  final String description;
  final MeetingCategory category;
  final String thumbnailUrl;
  final String hostId;
  final String hostName;
  final String hostAvatarUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final int currentParticipants;
  final int maxParticipants;
  final List<String> participantAvatars;
  final List<String> friendsParticipating;
  final MeetingDifficulty difficulty;
  final int estimatedDuration; // 분 단위
  final int cost; // 원 단위
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final MeetingStatus status;
  final int pointReward;
  final int xpReward;
  final bool isRecommended;
  final double recommendationScore;
  final String recommendationReason;
  final bool isFavorite;
  final bool isJoined;

  const RecommendedMeeting({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    required this.hostId,
    required this.hostName,
    required this.hostAvatarUrl,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.participantAvatars,
    required this.friendsParticipating,
    required this.difficulty,
    required this.estimatedDuration,
    required this.cost,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.status,
    required this.pointReward,
    required this.xpReward,
    required this.isRecommended,
    required this.recommendationScore,
    required this.recommendationReason,
    this.isFavorite = false,
    this.isJoined = false,
  });

  String get categoryDisplayName {
    switch (category) {
      case MeetingCategory.networking:
        return '네트워킹';
      case MeetingCategory.study:
        return '스터디';
      case MeetingCategory.exercise:
        return '운동';
      case MeetingCategory.social:        // ✅ 누락된 케이스 추가
        return '모임';
      case MeetingCategory.career:
        return '취업준비';
      case MeetingCategory.hobby:
        return '취미';
      case MeetingCategory.culture:
        return '문화';
      case MeetingCategory.volunteer:
        return '봉사활동';
    }
  }

  Color get categoryColor {
    switch (category) {
      case MeetingCategory.networking:
        return const Color(0xFF2196F3);
      case MeetingCategory.study:
        return const Color(0xFF4CAF50);
      case MeetingCategory.exercise:
        return const Color(0xFFFF9800);
      case MeetingCategory.social:        // ✅ 누락된 케이스 추가
        return const Color(0xFFE91E63);
      case MeetingCategory.career:
        return const Color(0xFF9C27B0);
      case MeetingCategory.hobby:
        return const Color(0xFFFF5722);
      case MeetingCategory.culture:
        return const Color(0xFF607D8B);
      case MeetingCategory.volunteer:
        return const Color(0xFF795548);
    }
  }

  String get difficultyDisplayName {
    switch (difficulty) {
      case MeetingDifficulty.beginner:
        return '초급';
      case MeetingDifficulty.intermediate:
        return '중급';
      case MeetingDifficulty.advanced:
        return '고급';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case MeetingStatus.recruiting:
        return '모집중';
      case MeetingStatus.almostFull:
        return '마감임박';
      case MeetingStatus.waitingList:
        return '대기중';
      case MeetingStatus.closed:
        return '모집완료';
    }
  }

  bool get canJoin => status == MeetingStatus.recruiting || status == MeetingStatus.almostFull;

  double get participationRate => currentParticipants / maxParticipants;

  String get timeUntilStart {
    final now = DateTime.now();
    final difference = startTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 후';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 후';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 후';
    } else {
      return '진행중';
    }
  }

  RecommendedMeeting copyWith({
    String? id,
    String? title,
    String? description,
    MeetingCategory? category,
    String? thumbnailUrl,
    String? hostId,
    String? hostName,
    String? hostAvatarUrl,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    int? currentParticipants,
    int? maxParticipants,
    List<String>? participantAvatars,
    List<String>? friendsParticipating,
    MeetingDifficulty? difficulty,
    int? estimatedDuration,
    int? cost,
    double? rating,
    int? reviewCount,
    List<String>? tags,
    MeetingStatus? status,
    int? pointReward,
    int? xpReward,
    bool? isRecommended,
    double? recommendationScore,
    String? recommendationReason,
    bool? isFavorite,
    bool? isJoined,
  }) {
    return RecommendedMeeting(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      friendsParticipating: friendsParticipating ?? this.friendsParticipating,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      cost: cost ?? this.cost,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      pointReward: pointReward ?? this.pointReward,
      xpReward: xpReward ?? this.xpReward,
      isRecommended: isRecommended ?? this.isRecommended,
      recommendationScore: recommendationScore ?? this.recommendationScore,
      recommendationReason: recommendationReason ?? this.recommendationReason,
      isFavorite: isFavorite ?? this.isFavorite,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'thumbnailUrl': thumbnailUrl,
      'hostId': hostId,
      'hostName': hostName,
      'hostAvatarUrl': hostAvatarUrl,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'currentParticipants': currentParticipants,
      'maxParticipants': maxParticipants,
      'participantAvatars': participantAvatars,
      'friendsParticipating': friendsParticipating,
      'difficulty': difficulty.index,
      'estimatedDuration': estimatedDuration,
      'cost': cost,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'status': status.index,
      'pointReward': pointReward,
      'xpReward': xpReward,
      'isRecommended': isRecommended,
      'recommendationScore': recommendationScore,
      'recommendationReason': recommendationReason,
      'isFavorite': isFavorite,
      'isJoined': isJoined,
    };
  }

  factory RecommendedMeeting.fromJson(Map<String, dynamic> json) {
    return RecommendedMeeting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: MeetingCategory.values[json['category'] ?? 0],
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'] ?? '',
      hostAvatarUrl: json['hostAvatarUrl'] ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      currentParticipants: json['currentParticipants'] ?? 0,
      maxParticipants: json['maxParticipants'] ?? 1,
      participantAvatars: List<String>.from(json['participantAvatars'] ?? []),
      friendsParticipating: List<String>.from(json['friendsParticipating'] ?? []),
      difficulty: MeetingDifficulty.values[json['difficulty'] ?? 0],
      estimatedDuration: json['estimatedDuration'] ?? 60,
      cost: json['cost'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      status: MeetingStatus.values[json['status'] ?? 0],
      pointReward: json['pointReward'] ?? 0,
      xpReward: json['xpReward'] ?? 0,
      isRecommended: json['isRecommended'] ?? false,
      recommendationScore: (json['recommendationScore'] ?? 0.0).toDouble(),
      recommendationReason: json['recommendationReason'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      isJoined: json['isJoined'] ?? false,
    );
  }
}

class MeetingRecommendationState {
  final List<RecommendedMeeting> recommendedMeetings;
  final List<RecommendedMeeting> myMeetings;
  final List<RecommendedMeeting> upcomingMeetings;
  final bool isLoading;
  final String? error;
  final MeetingCategory? selectedCategory;
  final int currentCardIndex;

  const MeetingRecommendationState({
    required this.recommendedMeetings,
    required this.myMeetings,
    required this.upcomingMeetings,
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.currentCardIndex = 0,
  });

  MeetingRecommendationState copyWith({
    List<RecommendedMeeting>? recommendedMeetings,
    List<RecommendedMeeting>? myMeetings,
    List<RecommendedMeeting>? upcomingMeetings,
    bool? isLoading,
    String? error,
    MeetingCategory? selectedCategory,
    int? currentCardIndex,
  }) {
    return MeetingRecommendationState(
      recommendedMeetings: recommendedMeetings ?? this.recommendedMeetings,
      myMeetings: myMeetings ?? this.myMeetings,
      upcomingMeetings: upcomingMeetings ?? this.upcomingMeetings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
    );
  }

  factory MeetingRecommendationState.initial() {
    return const MeetingRecommendationState(
      recommendedMeetings: [],
      myMeetings: [],
      upcomingMeetings: [],
      isLoading: false,
      currentCardIndex: 0,
    );
  }
}
