import 'dart:math' as math;

class Mountain {
  final int id;
  final String name;
  final String region;
  final int difficultyLevel;
  final double durationHours;
  final double requiredPower;
  final String? imageUrl;
  final bool isGateway;


  const Mountain({
    required this.id,
    required this.name,
    required this.region,
    required this.difficultyLevel,
    required this.durationHours,
    required this.requiredPower,
    this.imageUrl,
    this.isGateway = false,
  });

  // 구간별 복합 성장 곡선에 따른 요구 등반력 계산
  static double calculateRequiredPower(int difficultyLevel) {
    if (difficultyLevel <= 9) {
      // 초심자의 언덕
      return difficultyLevel * 40.0;
    } else if (difficultyLevel <= 49) {
      // 한국의 명산
      return 360 + (difficultyLevel - 9) * 80.0;
    } else if (difficultyLevel <= 99) {
      // 아시아의 지붕
      return 3560 + math.pow(difficultyLevel - 49, 1.5) * 15;
    } else {
      // 세계의 정상, 신들의 산맥
      return 21000 + math.pow(difficultyLevel - 99, 1.8) * 30;
    }
  }

  Mountain copyWith({
    int? id,
    String? name,
    String? region,
    int? difficultyLevel,
    double? durationHours,
    double? requiredPower,
    String? imageUrl,
  }) {
    return Mountain(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      durationHours: durationHours ?? this.durationHours,
      requiredPower: requiredPower ?? this.requiredPower,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Mountain.fromJson(Map<String, dynamic> json) {
    return Mountain(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      difficultyLevel: json['difficultyLevel'] ?? 0,
      durationHours: (json['durationHours'] ?? 0).toDouble(),
      requiredPower: (json['requiredPower'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      isGateway: json['isGateway'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'difficultyLevel': difficultyLevel,
      'durationHours': durationHours,
      'requiredPower': requiredPower,
      'imageUrl': imageUrl,
      'isGateway': isGateway,
    };
  }
}
