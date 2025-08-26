// lib/shared/utils/meeting_image_manager.dart

import 'dart:math';
import '../../features/meetings/models/available_meeting_model.dart';

/// 모임 이미지를 카테고리별로 관리하고 적절한 이미지를 제공하는 매니저
class MeetingImageManager {
  static final MeetingImageManager _instance = MeetingImageManager._internal();
  factory MeetingImageManager() => _instance;
  MeetingImageManager._internal();

  final Random _random = Random();

  /// 카테고리별 이미지 매핑
  static const Map<MeetingCategory, List<int>> _categoryImageMap = {
    MeetingCategory.exercise: [1, 2, 3, 4, 5, 6], // 운동 관련 이미지들
    MeetingCategory.study: [7, 8, 9, 10], // 스터디 관련 이미지들
    MeetingCategory.reading: [11, 12, 13], // 독서 관련 이미지들
    MeetingCategory.culture: [14, 15, 16, 17], // 문화 관련 이미지들
    MeetingCategory.outdoor: [18, 19, 20], // 아웃도어 관련 이미지들
    MeetingCategory.networking: [21, 22, 23], // 네트워킹 관련 이미지들
  };

  /// 전체 이미지 리스트 (카테고리 미분류용)
  static const List<int> _allImages = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23
  ];

  /// 모임에 적절한 이미지 경로 반환 (실제 이미지만 반환, 없으면 null)
  String? getImageForMeeting(AvailableMeeting meeting) {
    // 실제 이미지가 있으면 해당 이미지 사용
    if (meeting.hasImages && meeting.imageFileNames.isNotEmpty) {
      final dynamicPath = _getDynamicImagePath(meeting.imageFileNames.first);
      return dynamicPath;
    }
    
    // 이미지가 없으면 null 반환 (UI에서 이모지 표시하도록)
    return null;
  }

  /// 동적 이미지 경로 생성 (앱 문서 디렉토리 기반)
  String _getDynamicImagePath(String fileName) {
    // 동적 이미지는 파일 경로를 직접 반환
    // 실제 파일 존재 여부는 UI에서 처리
    return fileName;
  }

  /// 모임이 동적 이미지를 가지고 있는지 확인
  bool hasDynamicImage(AvailableMeeting meeting) {
    return meeting.hasImages && meeting.imageFileNames.isNotEmpty;
  }

  /// 카테고리별 랜덤 이미지 경로 반환
  String getImageForCategory(MeetingCategory category, [String? seed]) {
    final imageNumbers = _categoryImageMap[category] ?? _allImages;
    
    int imageNumber;
    if (seed != null) {
      // 시드가 있으면 동일한 모임은 항상 같은 이미지 사용
      final seedHash = seed.hashCode.abs();
      imageNumber = imageNumbers[seedHash % imageNumbers.length];
    } else {
      // 시드가 없으면 완전 랜덤
      imageNumber = imageNumbers[_random.nextInt(imageNumbers.length)];
    }
    
    return getSafeImagePath(imageNumber);
  }

  /// 특정 인덱스의 이미지 경로 반환 (기존 호환성용)
  String getImageByIndex(int index) {
    final imageNumber = _allImages[index % _allImages.length];
    return getSafeImagePath(imageNumber);
  }
  
  /// 안전한 이미지 경로 반환 (존재하는 이미지만 반환)
  String getSafeImagePath(int imageNumber) {
    // 1-23 범위의 이미지만 허용
    if (imageNumber >= 1 && imageNumber <= 23) {
      final path = 'assets/images/meeting/$imageNumber.jpg';
      return path;
    }
    // 범위를 벗어나면 첫 번째 이미지 반환
    return 'assets/images/meeting/1.jpg';
  }

  /// 카테고리별 대표 이미지 반환
  String getCategoryRepresentativeImage(MeetingCategory category) {
    final imageNumbers = _categoryImageMap[category] ?? _allImages;
    final imageNumber = imageNumbers.first;
    return getSafeImagePath(imageNumber);
  }

  /// 여러 이미지를 섞어서 반환 (갤러리용)
  List<String> getRandomImages(int count, {MeetingCategory? category}) {
    final imageNumbers = category != null 
        ? (_categoryImageMap[category] ?? _allImages)
        : _allImages;
    
    final shuffled = List<int>.from(imageNumbers)..shuffle(_random);
    final selected = shuffled.take(count).toList();
    
    return selected.map((num) => getSafeImagePath(num)).toList();
  }

  /// 이미지 존재 여부 확인 (개발용)
  bool isImageAvailable(int imageNumber) {
    return imageNumber >= 1 && imageNumber <= 23;
  }

  /// 카테고리별 이미지 개수 반환
  int getImageCountForCategory(MeetingCategory category) {
    return _categoryImageMap[category]?.length ?? _allImages.length;
  }

  /// 모든 카테고리의 이미지 정보 반환 (디버깅용)
  Map<MeetingCategory, List<String>> getAllCategoryImages() {
    return _categoryImageMap.map((category, imageNumbers) => 
        MapEntry(category, imageNumbers.map((num) => getSafeImagePath(num)).toList()));
  }
}

/// 이미지 매니저 확장 - 더미 데이터와 함께 사용
extension MeetingImageManagerExtension on MeetingImageManager {
  /// 더미 모임 데이터용 이미지 시퀀스 생성 (null 값 포함 가능)
  List<String?> generateImageSequence(List<AvailableMeeting> meetings) {
    return meetings.map((meeting) => getImageForMeeting(meeting)).toList();
  }

}