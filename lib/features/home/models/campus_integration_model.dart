import 'package:flutter/material.dart';

// 🎓 캠퍼스 위치 정보 모델
class CampusLocation {
  final String locationId;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String buildingCode;
  final String floor;
  final int capacity;
  final List<String> facilities;
  final bool isAvailable;
  final Map<String, dynamic> operatingHours;
  final DateTime lastUpdated;

  const CampusLocation({
    required this.locationId,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.buildingCode,
    required this.floor,
    required this.capacity,
    required this.facilities,
    required this.isAvailable,
    required this.operatingHours,
    required this.lastUpdated,
  });

  String get fullAddress => '$buildingCode $floor $name';

  bool get hasWifi => facilities.contains('wifi');
  bool get hasProjector => facilities.contains('projector');
  bool get hasWhiteboard => facilities.contains('whiteboard');
  bool get hasComputers => facilities.contains('computers');
  bool get hasMicrophone => facilities.contains('microphone');

  String get facilitiesText => facilities.join(', ');

  bool get isCurrentlyOpen {
    final now = DateTime.now();
    final currentDay = _getCurrentDayKey();
    final hours = operatingHours[currentDay] as String?;

    if (hours == null || hours == '24:00') return true;
    if (hours == 'closed') return false;

    final parts = hours.split('-');
    if (parts.length != 2) return false;

    try {
      final openTime = _parseTime(parts[0]);
      final closeTime = _parseTime(parts[1]);
      final currentTime = now.hour * 60 + now.minute;

      return currentTime >= openTime && currentTime <= closeTime;
    } catch (e) {
      return false;
    }
  }

  String _getCurrentDayKey() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
      case DateTime.tuesday:
      case DateTime.wednesday:
      case DateTime.thursday:
      case DateTime.friday:
        return 'weekday';
      case DateTime.saturday:
      case DateTime.sunday:
        return 'weekend';
      default:
        return 'weekday';
    }
  }

  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  CampusLocation copyWith({
    String? locationId,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? buildingCode,
    String? floor,
    int? capacity,
    List<String>? facilities,
    bool? isAvailable,
    Map<String, dynamic>? operatingHours,
    DateTime? lastUpdated,
  }) {
    return CampusLocation(
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      buildingCode: buildingCode ?? this.buildingCode,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      facilities: facilities ?? this.facilities,
      isAvailable: isAvailable ?? this.isAvailable,
      operatingHours: operatingHours ?? this.operatingHours,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory CampusLocation.fromJson(Map<String, dynamic> json) {
    return CampusLocation(
      locationId: json['locationId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      buildingCode: json['buildingCode'] as String,
      floor: json['floor'] as String,
      capacity: json['capacity'] as int,
      facilities: List<String>.from(json['facilities'] as List),
      isAvailable: json['isAvailable'] as bool,
      operatingHours: Map<String, dynamic>.from(json['operatingHours'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'buildingCode': buildingCode,
      'floor': floor,
      'capacity': capacity,
      'facilities': facilities,
      'isAvailable': isAvailable,
      'operatingHours': operatingHours,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

// 🎓 캠퍼스 건물 정보 모델
class CampusBuilding {
  final String buildingId;
  final String buildingName;
  final String buildingCode;
  final double latitude;
  final double longitude;
  final List<CampusLocation> locations;
  final String buildingType; // 'academic', 'dormitory', 'facility', 'library'
  final Map<String, dynamic> buildingInfo;
  final DateTime lastUpdated;

  const CampusBuilding({
    required this.buildingId,
    required this.buildingName,
    required this.buildingCode,
    required this.latitude,
    required this.longitude,
    required this.locations,
    required this.buildingType,
    required this.buildingInfo,
    required this.lastUpdated,
  });

  int get totalCapacity => locations.fold(0, (sum, location) => sum + location.capacity);
  int get availableLocations => locations.where((location) => location.isAvailable).length;
  int get totalLocations => locations.length;
  double get occupancyRate => totalLocations > 0 ? (totalLocations - availableLocations) / totalLocations : 0.0;

  String get buildingTypeDisplayName {
    switch (buildingType) {
      case 'academic':
        return '학술관';
      case 'dormitory':
        return '기숙사';
      case 'facility':
        return '편의시설';
      case 'library':
        return '도서관';
      default:
        return '기타';
    }
  }

  Color get buildingTypeColor {
    switch (buildingType) {
      case 'academic':
        return Colors.blue;
      case 'dormitory':
        return Colors.purple;
      case 'facility':
        return Colors.orange;
      case 'library':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get buildingTypeEmoji {
    switch (buildingType) {
      case 'academic':
        return '🎓';
      case 'dormitory':
        return '🏠';
      case 'facility':
        return '🏢';
      case 'library':
        return '📚';
      default:
        return '🏛️';
    }
  }

  List<CampusLocation> get availableLocationsList =>
      locations.where((location) => location.isAvailable).toList();

  CampusBuilding copyWith({
    String? buildingId,
    String? buildingName,
    String? buildingCode,
    double? latitude,
    double? longitude,
    List<CampusLocation>? locations,
    String? buildingType,
    Map<String, dynamic>? buildingInfo,
    DateTime? lastUpdated,
  }) {
    return CampusBuilding(
      buildingId: buildingId ?? this.buildingId,
      buildingName: buildingName ?? this.buildingName,
      buildingCode: buildingCode ?? this.buildingCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locations: locations ?? this.locations,
      buildingType: buildingType ?? this.buildingType,
      buildingInfo: buildingInfo ?? this.buildingInfo,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory CampusBuilding.fromJson(Map<String, dynamic> json) {
    return CampusBuilding(
      buildingId: json['buildingId'] as String,
      buildingName: json['buildingName'] as String,
      buildingCode: json['buildingCode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locations: (json['locations'] as List)
          .map((e) => CampusLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      buildingType: json['buildingType'] as String,
      buildingInfo: Map<String, dynamic>.from(json['buildingInfo'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buildingId': buildingId,
      'buildingName': buildingName,
      'buildingCode': buildingCode,
      'latitude': latitude,
      'longitude': longitude,
      'locations': locations.map((e) => e.toJson()).toList(),
      'buildingType': buildingType,
      'buildingInfo': buildingInfo,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

// 🎓 길드 랭킹 시스템 모델
class GuildRanking {
  final String guildId;
  final String universityName;
  final int currentRank;
  final int previousRank;
  final double totalScore;
  final double weeklyScore;
  final int totalMembers;
  final int activeMembers;
  final List<String> recentAchievements;
  final DateTime lastUpdated;
  final Map<String, dynamic> additionalStats;

  const GuildRanking({
    required this.guildId,
    required this.universityName,
    required this.currentRank,
    required this.previousRank,
    required this.totalScore,
    required this.weeklyScore,
    required this.totalMembers,
    required this.activeMembers,
    required this.recentAchievements,
    required this.lastUpdated,
    required this.additionalStats,
  });

  int get rankChange => previousRank - currentRank;
  bool get isRankUp => rankChange > 0;
  bool get isRankDown => rankChange < 0;
  bool get isRankSame => rankChange == 0;

  String get rankChangeText {
    if (rankChange > 0) return '↗️ +$rankChange';
    if (rankChange < 0) return '↘️ ${rankChange.abs()}';
    return '➡️ 0';
  }

  Color get rankChangeColor {
    if (rankChange > 0) return Colors.green;
    if (rankChange < 0) return Colors.red;
    return Colors.grey;
  }

  String get rankChangeDescription {
    if (rankChange > 0) return '$rankChange계단 상승';
    if (rankChange < 0) return '${rankChange.abs()}계단 하락';
    return '순위 유지';
  }

  double get activityRate => totalMembers > 0 ? (activeMembers / totalMembers) * 100 : 0.0;

  String get rankTier {
    if (currentRank <= 3) return 'S';
    if (currentRank <= 10) return 'A';
    if (currentRank <= 30) return 'B';
    if (currentRank <= 100) return 'C';
    return 'D';
  }

  Color get rankTierColor {
    switch (rankTier) {
      case 'S':
        return Colors.amber;
      case 'A':
        return Colors.blue;
      case 'B':
        return Colors.green;
      case 'C':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  GuildRanking copyWith({
    String? guildId,
    String? universityName,
    int? currentRank,
    int? previousRank,
    double? totalScore,
    double? weeklyScore,
    int? totalMembers,
    int? activeMembers,
    List<String>? recentAchievements,
    DateTime? lastUpdated,
    Map<String, dynamic>? additionalStats,
  }) {
    return GuildRanking(
      guildId: guildId ?? this.guildId,
      universityName: universityName ?? this.universityName,
      currentRank: currentRank ?? this.currentRank,
      previousRank: previousRank ?? this.previousRank,
      totalScore: totalScore ?? this.totalScore,
      weeklyScore: weeklyScore ?? this.weeklyScore,
      totalMembers: totalMembers ?? this.totalMembers,
      activeMembers: activeMembers ?? this.activeMembers,
      recentAchievements: recentAchievements ?? this.recentAchievements,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      additionalStats: additionalStats ?? this.additionalStats,
    );
  }

  factory GuildRanking.fromJson(Map<String, dynamic> json) {
    return GuildRanking(
      guildId: json['guildId'] as String,
      universityName: json['universityName'] as String,
      currentRank: json['currentRank'] as int,
      previousRank: json['previousRank'] as int,
      totalScore: (json['totalScore'] as num).toDouble(),
      weeklyScore: (json['weeklyScore'] as num).toDouble(),
      totalMembers: json['totalMembers'] as int,
      activeMembers: json['activeMembers'] as int,
      recentAchievements: List<String>.from(json['recentAchievements'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      additionalStats: Map<String, dynamic>.from(json['additionalStats'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guildId': guildId,
      'universityName': universityName,
      'currentRank': currentRank,
      'previousRank': previousRank,
      'totalScore': totalScore,
      'weeklyScore': weeklyScore,
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'recentAchievements': recentAchievements,
      'lastUpdated': lastUpdated.toIso8601String(),
      'additionalStats': additionalStats,
    };
  }
}

// 🎓 길드 대항전 시스템 모델
class GuildCompetition {
  final String competitionId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participatingGuilds;
  final Map<String, double> guildScores;
  final String competitionType; // 'weekly', 'monthly', 'special', 'seasonal'
  final Map<String, dynamic> rewards;
  final bool isActive;
  final Map<String, dynamic> rules;
  final String status; // 'upcoming', 'active', 'ended'

  const GuildCompetition({
    required this.competitionId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.participatingGuilds,
    required this.guildScores,
    required this.competitionType,
    required this.rewards,
    required this.isActive,
    required this.rules,
    required this.status,
  });

  Duration get timeRemaining => endDate.difference(DateTime.now());
  Duration get timeUntilStart => startDate.difference(DateTime.now());
  bool get isEnded => DateTime.now().isAfter(endDate);
  bool get hasStarted => DateTime.now().isAfter(startDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  double get progressPercentage {
    if (isUpcoming) return 0.0;
    if (isEnded) return 100.0;

    final total = endDate.difference(startDate).inMilliseconds;
    final elapsed = DateTime.now().difference(startDate).inMilliseconds;
    return (elapsed / total * 100).clamp(0, 100);
  }

  List<MapEntry<String, double>> get sortedGuildScores {
    final entries = guildScores.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  String get competitionTypeDisplayName {
    switch (competitionType) {
      case 'weekly':
        return '주간 대항전';
      case 'monthly':
        return '월간 대항전';
      case 'special':
        return '특별 이벤트';
      case 'seasonal':
        return '시즌 대항전';
      default:
        return '대항전';
    }
  }

  Color get competitionTypeColor {
    switch (competitionType) {
      case 'weekly':
        return Colors.blue;
      case 'monthly':
        return Colors.purple;
      case 'special':
        return Colors.orange;
      case 'seasonal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'upcoming':
        return '시작 예정';
      case 'active':
        return '진행 중';
      case 'ended':
        return '종료됨';
      default:
        return '알 수 없음';
    }
  }

  String get timeDisplayText {
    if (isUpcoming) {
      final days = timeUntilStart.inDays;
      final hours = timeUntilStart.inHours % 24;
      if (days > 0) return '$days일 후 시작';
      if (hours > 0) return '$hours시간 후 시작';
      return '곧 시작';
    } else if (isActive) {
      final days = timeRemaining.inDays;
      final hours = timeRemaining.inHours % 24;
      if (days > 0) return '$days일 남음';
      if (hours > 0) return '$hours시간 남음';
      return '곧 종료';
    } else {
      return '종료됨';
    }
  }

  int getGuildRank(String guildId) {
    final sorted = sortedGuildScores;
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].key == guildId) {
        return i + 1;
      }
    }
    return -1;
  }

  double getGuildScore(String guildId) {
    return guildScores[guildId] ?? 0.0;
  }

  GuildCompetition copyWith({
    String? competitionId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? participatingGuilds,
    Map<String, double>? guildScores,
    String? competitionType,
    Map<String, dynamic>? rewards,
    bool? isActive,
    Map<String, dynamic>? rules,
    String? status,
  }) {
    return GuildCompetition(
      competitionId: competitionId ?? this.competitionId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participatingGuilds: participatingGuilds ?? this.participatingGuilds,
      guildScores: guildScores ?? this.guildScores,
      competitionType: competitionType ?? this.competitionType,
      rewards: rewards ?? this.rewards,
      isActive: isActive ?? this.isActive,
      rules: rules ?? this.rules,
      status: status ?? this.status,
    );
  }

  factory GuildCompetition.fromJson(Map<String, dynamic> json) {
    return GuildCompetition(
      competitionId: json['competitionId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participatingGuilds: List<String>.from(json['participatingGuilds'] as List),
      guildScores: Map<String, double>.from(json['guildScores'] as Map),
      competitionType: json['competitionType'] as String,
      rewards: Map<String, dynamic>.from(json['rewards'] as Map),
      isActive: json['isActive'] as bool,
      rules: Map<String, dynamic>.from(json['rules'] as Map),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competitionId': competitionId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participatingGuilds': participatingGuilds,
      'guildScores': guildScores,
      'competitionType': competitionType,
      'rewards': rewards,
      'isActive': isActive,
      'rules': rules,
      'status': status,
    };
  }
}

// 🎓 캠퍼스 이벤트 모델
class CampusEvent {
  final String eventId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final CampusLocation location;
  final String eventType; // 'academic', 'social', 'competition', 'official', 'cultural'
  final List<String> organizers;
  final int maxParticipants;
  final int currentParticipants;
  final bool isPublic;
  final Map<String, dynamic> eventDetails;
  final List<String> tags;
  final String? imageUrl;
  final double? fee;
  final bool requiresRegistration;

  const CampusEvent({
    required this.eventId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.eventType,
    required this.organizers,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.isPublic,
    required this.eventDetails,
    required this.tags,
    this.imageUrl,
    this.fee,
    required this.requiresRegistration,
  });

  bool get isFull => currentParticipants >= maxParticipants;
  Duration get timeUntilStart => startTime.difference(DateTime.now());
  Duration get duration => endTime.difference(startTime);
  bool get isOngoing => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get hasEnded => DateTime.now().isAfter(endTime);
  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get isToday =>
      DateTime.now().day == startTime.day &&
          DateTime.now().month == startTime.month &&
          DateTime.now().year == startTime.year;

  double get occupancyRate => maxParticipants > 0 ? (currentParticipants / maxParticipants) * 100 : 0.0;
  int get availableSpots => maxParticipants - currentParticipants;

  String get eventTypeDisplayName {
    switch (eventType) {
      case 'academic':
        return '학술 행사';
      case 'social':
        return '사교 모임';
      case 'competition':
        return '경쟁 대회';
      case 'official':
        return '공식 행사';
      case 'cultural':
        return '문화 행사';
      default:
        return '기타 행사';
    }
  }

  Color get eventTypeColor {
    switch (eventType) {
      case 'academic':
        return Colors.blue;
      case 'social':
        return Colors.pink;
      case 'competition':
        return Colors.orange;
      case 'official':
        return Colors.purple;
      case 'cultural':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get eventTypeEmoji {
    switch (eventType) {
      case 'academic':
        return '📖';
      case 'social':
        return '🎉';
      case 'competition':
        return '🏆';
      case 'official':
        return '📋';
      case 'cultural':
        return '🎭';
      default:
        return '📅';
    }
  }

  String get statusText {
    if (isOngoing) return '진행 중';
    if (hasEnded) return '종료됨';
    if (timeUntilStart.inDays > 0) return '${timeUntilStart.inDays}일 후';
    if (timeUntilStart.inHours > 0) return '${timeUntilStart.inHours}시간 후';
    return '곧 시작';
  }

  String get participationText {
    if (isFull) return '마감';
    if (availableSpots <= 5) return '${availableSpots}자리 남음';
    return '$currentParticipants/$maxParticipants명';
  }

  bool get canRegister => isPublic && !isFull && !hasEnded && isUpcoming;

  String get feeText {
    if (fee == null || fee == 0) return '무료';
    return '${fee!.toInt()}원';
  }

  CampusEvent copyWith({
    String? eventId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    CampusLocation? location,
    String? eventType,
    List<String>? organizers,
    int? maxParticipants,
    int? currentParticipants,
    bool? isPublic,
    Map<String, dynamic>? eventDetails,
    List<String>? tags,
    String? imageUrl,
    double? fee,
    bool? requiresRegistration,
  }) {
    return CampusEvent(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
      organizers: organizers ?? this.organizers,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isPublic: isPublic ?? this.isPublic,
      eventDetails: eventDetails ?? this.eventDetails,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      fee: fee ?? this.fee,
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
    );
  }

  factory CampusEvent.fromJson(Map<String, dynamic> json) {
    return CampusEvent(
      eventId: json['eventId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: CampusLocation.fromJson(json['location'] as Map<String, dynamic>),
      eventType: json['eventType'] as String,
      organizers: List<String>.from(json['organizers'] as List),
      maxParticipants: json['maxParticipants'] as int,
      currentParticipants: json['currentParticipants'] as int,
      isPublic: json['isPublic'] as bool,
      eventDetails: Map<String, dynamic>.from(json['eventDetails'] as Map),
      tags: List<String>.from(json['tags'] as List),
      imageUrl: json['imageUrl'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
      requiresRegistration: json['requiresRegistration'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location.toJson(),
      'eventType': eventType,
      'organizers': organizers,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'isPublic': isPublic,
      'eventDetails': eventDetails,
      'tags': tags,
      'imageUrl': imageUrl,
      'fee': fee,
      'requiresRegistration': requiresRegistration,
    };
  }
}

// 🎓 학사 일정 모델
class AcademicSchedule {
  final String scheduleId;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? endDate; // 기간이 있는 일정의 경우
  final String scheduleType; // 'exam', 'registration', 'vacation', 'event', 'deadline'
  final String department;
  final bool isImportant;
  final Map<String, dynamic> additionalInfo;
  final List<String> affectedGrades;
  final String? notificationMessage;
  final bool isRecurring;

  const AcademicSchedule({
    required this.scheduleId,
    required this.title,
    required this.description,
    required this.date,
    this.endDate,
    required this.scheduleType,
    required this.department,
    required this.isImportant,
    required this.additionalInfo,
    required this.affectedGrades,
    this.notificationMessage,
    required this.isRecurring,
  });

  Duration get timeUntilDate => date.difference(DateTime.now());
  bool get isToday => DateTime.now().day == date.day &&
      DateTime.now().month == date.month &&
      DateTime.now().year == date.year;
  bool get isThisWeek => timeUntilDate.inDays <= 7 && timeUntilDate.inDays >= 0;
  bool get isThisMonth => timeUntilDate.inDays <= 30 && timeUntilDate.inDays >= 0;
  bool get isPast => DateTime.now().isAfter(date);
  bool get isOngoing => endDate != null && DateTime.now().isAfter(date) && DateTime.now().isBefore(endDate!);

  Duration? get duration => endDate?.difference(date);

  String get scheduleTypeDisplayName {
    switch (scheduleType) {
      case 'exam':
        return '시험';
      case 'registration':
        return '수강신청';
      case 'vacation':
        return '방학';
      case 'event':
        return '행사';
      case 'deadline':
        return '마감';
      default:
        return '일정';
    }
  }

  Color get scheduleTypeColor {
    switch (scheduleType) {
      case 'exam':
        return Colors.red;
      case 'registration':
        return Colors.blue;
      case 'vacation':
        return Colors.green;
      case 'event':
        return Colors.orange;
      case 'deadline':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String get scheduleTypeEmoji {
    switch (scheduleType) {
      case 'exam':
        return '📝';
      case 'registration':
        return '📋';
      case 'vacation':
        return '🌴';
      case 'event':
        return '🎪';
      case 'deadline':
        return '⏰';
      default:
        return '📅';
    }
  }

  String get timeDisplayText {
    if (isPast) return '지난 일정';
    if (isToday) return '오늘';
    if (isOngoing) return '진행 중';

    final days = timeUntilDate.inDays;
    if (days == 1) return '내일';
    if (days <= 7) return '$days일 후';
    if (days <= 30) return '$days일 후';

    final weeks = (days / 7).floor();
    if (weeks <= 4) return '$weeks주 후';

    final months = (days / 30).floor();
    return '$months개월 후';
  }

  String get urgencyLevel {
    if (isPast) return 'past';
    if (isToday || isOngoing) return 'urgent';
    if (timeUntilDate.inDays <= 3) return 'high';
    if (timeUntilDate.inDays <= 7) return 'medium';
    return 'low';
  }

  Color get urgencyColor {
    switch (urgencyLevel) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  bool isRelevantForGrade(String grade) {
    return affectedGrades.isEmpty || affectedGrades.contains(grade) || affectedGrades.contains('전체');
  }

  AcademicSchedule copyWith({
    String? scheduleId,
    String? title,
    String? description,
    DateTime? date,
    DateTime? endDate,
    String? scheduleType,
    String? department,
    bool? isImportant,
    Map<String, dynamic>? additionalInfo,
    List<String>? affectedGrades,
    String? notificationMessage,
    bool? isRecurring,
  }) {
    return AcademicSchedule(
      scheduleId: scheduleId ?? this.scheduleId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      scheduleType: scheduleType ?? this.scheduleType,
      department: department ?? this.department,
      isImportant: isImportant ?? this.isImportant,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      affectedGrades: affectedGrades ?? this.affectedGrades,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  factory AcademicSchedule.fromJson(Map<String, dynamic> json) {
    return AcademicSchedule(
      scheduleId: json['scheduleId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      scheduleType: json['scheduleType'] as String,
      department: json['department'] as String,
      isImportant: json['isImportant'] as bool,
      additionalInfo: Map<String, dynamic>.from(json['additionalInfo'] as Map),
      affectedGrades: List<String>.from(json['affectedGrades'] as List),
      notificationMessage: json['notificationMessage'] as String?,
      isRecurring: json['isRecurring'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'scheduleType': scheduleType,
      'department': department,
      'isImportant': isImportant,
      'additionalInfo': additionalInfo,
      'affectedGrades': affectedGrades,
      'notificationMessage': notificationMessage,
      'isRecurring': isRecurring,
    };
  }
}

// 🎓 캠퍼스 통합 상태 모델
class CampusIntegrationState {
  final List<CampusBuilding> campusBuildings;
  final List<CampusEvent> campusEvents;
  final List<AcademicSchedule> academicSchedules;
  final List<GuildRanking> guildRankings;
  final List<GuildCompetition> guildCompetitions;
  final CampusLocation? currentLocation;
  final double? userLatitude;
  final double? userLongitude;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  const CampusIntegrationState({
    required this.campusBuildings,
    required this.campusEvents,
    required this.academicSchedules,
    required this.guildRankings,
    required this.guildCompetitions,
    this.currentLocation,
    this.userLatitude,
    this.userLongitude,
    this.isLoading = false,
    this.error,
    required this.lastUpdated,
  });

  List<CampusEvent> get todayEvents => campusEvents.where((event) => event.isToday).toList();
  List<CampusEvent> get upcomingEvents => campusEvents.where((event) => event.isUpcoming).toList();
  List<CampusEvent> get ongoingEvents => campusEvents.where((event) => event.isOngoing).toList();

  List<AcademicSchedule> get todaySchedules => academicSchedules.where((schedule) => schedule.isToday).toList();
  List<AcademicSchedule> get thisWeekSchedules => academicSchedules.where((schedule) => schedule.isThisWeek).toList();
  List<AcademicSchedule> get importantSchedules => academicSchedules.where((schedule) => schedule.isImportant).toList();

  List<GuildCompetition> get activeCompetitions => guildCompetitions.where((comp) => comp.isActive).toList();
  List<GuildCompetition> get upcomingCompetitions => guildCompetitions.where((comp) => comp.isUpcoming).toList();

  int get totalAvailableLocations => campusBuildings.fold(0, (sum, building) => sum + building.availableLocations);
  int get totalLocations => campusBuildings.fold(0, (sum, building) => sum + building.totalLocations);

  CampusIntegrationState copyWith({
    List<CampusBuilding>? campusBuildings,
    List<CampusEvent>? campusEvents,
    List<AcademicSchedule>? academicSchedules,
    List<GuildRanking>? guildRankings,
    List<GuildCompetition>? guildCompetitions,
    CampusLocation? currentLocation,
    double? userLatitude,
    double? userLongitude,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CampusIntegrationState(
      campusBuildings: campusBuildings ?? this.campusBuildings,
      campusEvents: campusEvents ?? this.campusEvents,
      academicSchedules: academicSchedules ?? this.academicSchedules,
      guildRankings: guildRankings ?? this.guildRankings,
      guildCompetitions: guildCompetitions ?? this.guildCompetitions,
      currentLocation: currentLocation ?? this.currentLocation,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory CampusIntegrationState.initial() {
    return CampusIntegrationState(
      campusBuildings: [],
      campusEvents: [],
      academicSchedules: [],
      guildRankings: [],
      guildCompetitions: [],
      currentLocation: null,
      userLatitude: null,
      userLongitude: null,
      isLoading: false,
      lastUpdated: DateTime.now(),
    );
  }
}
