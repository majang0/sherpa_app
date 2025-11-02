// lib/features/meetings/models/meeting_creation_model.dart

import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/available_meeting_model.dart';
import '../utils/meeting_image_utils.dart';

/// 모임 생성 데이터 모델
///
/// 모임 생성 과정에서 사용되는 모든 데이터를 담고 있는 불변 클래스입니다.
/// 4단계 생성 과정의 유효성 검사 메서드를 포함합니다.
class MeetingCreationData {
  final MeetingCategory? selectedCategory;
  final MeetingScope scope;
  final bool isOnline;
  final LatLng? location;
  final String? locationName;
  final String? detailedAddress;
  final int minParticipants;
  final int maxParticipants;
  final MeetingType meetingType;
  final double? price;
  final bool isFirstComeFirstServed;
  final List<File> photos;
  final String title;
  final String description;
  final DateTime? dateTime;
  final List<String> tags;
  final List<String> requirements;
  final List<String> preparationItems;

  const MeetingCreationData({
    this.selectedCategory,
    this.scope = MeetingScope.public,
    this.isOnline = true,
    this.location,
    this.locationName,
    this.detailedAddress,
    this.minParticipants = 2,
    this.maxParticipants = 10,
    this.meetingType = MeetingType.free,
    this.price,
    this.isFirstComeFirstServed = true,
    this.photos = const [],
    this.title = '',
    this.description = '',
    this.dateTime,
    this.tags = const [],
    this.requirements = const [],
    this.preparationItems = const [],
  });

  MeetingCreationData copyWith({
    MeetingCategory? selectedCategory,
    MeetingScope? scope,
    bool? isOnline,
    LatLng? location,
    String? locationName,
    String? detailedAddress,
    int? minParticipants,
    int? maxParticipants,
    MeetingType? meetingType,
    double? price,
    bool? isFirstComeFirstServed,
    List<File>? photos,
    String? title,
    String? description,
    DateTime? dateTime,
    List<String>? tags,
    List<String>? requirements,
    List<String>? preparationItems,
  }) {
    return MeetingCreationData(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      scope: scope ?? this.scope,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      locationName: locationName ?? this.locationName,
      detailedAddress: detailedAddress ?? this.detailedAddress,
      minParticipants: minParticipants ?? this.minParticipants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      meetingType: meetingType ?? this.meetingType,
      price: price ?? this.price,
      isFirstComeFirstServed:
          isFirstComeFirstServed ?? this.isFirstComeFirstServed,
      photos: photos ?? this.photos,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      requirements: requirements ?? this.requirements,
      preparationItems: preparationItems ?? this.preparationItems,
    );
  }

  /// Step 1: 카테고리 선택 유효성 검사
  bool isStep1Valid() => selectedCategory != null;

  /// Step 2: 장소 설정 유효성 검사
  bool isStep2Valid() {
    if (isOnline) return true;
    return location != null && locationName?.isNotEmpty == true;
  }

  /// Step 3: 참가 설정 유효성 검사
  bool isStep3Valid() {
    if (meetingType == MeetingType.paid) {
      return price != null && price! >= 3000;
    }
    return minParticipants >= 2 &&
        maxParticipants >= minParticipants &&
        maxParticipants <= 50;
  }

  /// Step 4: 모임 정보 유효성 검사
  bool isStep4Valid() {
    return title.isNotEmpty &&
        title.length >= 5 &&
        description.isNotEmpty &&
        description.length >= 10 &&
        dateTime != null;
  }

  /// 전체 데이터 유효성 검사
  bool isAllDataValid() {
    return isStep1Valid() && isStep2Valid() && isStep3Valid() && isStep4Valid();
  }

  /// AvailableMeeting 모델로 변환
  Future<AvailableMeeting> toAvailableMeeting({
    required String hostId,
    required String hostName,
  }) async {
    final meetingId = DateTime.now().millisecondsSinceEpoch.toString();

    final savedImageFileNames = await MeetingImageUtils.saveMeetingImages(
      tempFiles: photos,
      meetingId: meetingId,
    );

    return AvailableMeeting(
      id: meetingId,
      title: title,
      description: description,
      category: selectedCategory!,
      type: meetingType,
      scope: scope,
      dateTime: dateTime!,
      location: isOnline ? '온라인' : (locationName ?? ''),
      detailedLocation: detailedAddress ?? '',
      maxParticipants: maxParticipants,
      currentParticipants: 1,
      price: meetingType == MeetingType.paid ? price : null,
      hostName: hostName,
      hostId: hostId,
      tags: tags,
      requirements: requirements,
      preparationItems: preparationItems,
      imageFileNames: savedImageFileNames,
    );
  }
}
