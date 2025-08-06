import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/available_meeting_model.dart';

/// 🏗️ 모임 생성 단계별 데이터 모델
class MeetingCreationData {
  // Step 1: 카테고리 선택
  final MeetingCategory? selectedCategory;
  
  // Step 2: 공개범위 및 위치 설정
  final MeetingScope scope;
  final bool isOnline;
  final LatLng? location;
  final String? locationName;
  final String? detailedAddress;
  
  // Step 3: 참여 조건 설정
  final int minParticipants;
  final int maxParticipants;
  final MeetingType meetingType;
  final double? price;
  final bool isFirstComeFirstServed; // true: 선착순, false: 승인제
  
  // Step 4: 상세 정보
  final List<File> photos;
  final String title;
  final String description;
  final DateTime? dateTime;
  final List<String> tags;
  final List<String> requirements;
  final List<String> preparationItems;

  const MeetingCreationData({
    // Step 1
    this.selectedCategory,
    
    // Step 2
    this.scope = MeetingScope.public,
    this.isOnline = true,
    this.location,
    this.locationName,
    this.detailedAddress,
    
    // Step 3
    this.minParticipants = 2,
    this.maxParticipants = 10,
    this.meetingType = MeetingType.free,
    this.price,
    this.isFirstComeFirstServed = true,
    
    // Step 4
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
      isFirstComeFirstServed: isFirstComeFirstServed ?? this.isFirstComeFirstServed,
      photos: photos ?? this.photos,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      requirements: requirements ?? this.requirements,
      preparationItems: preparationItems ?? this.preparationItems,
    );
  }

  /// 각 단계별 유효성 검사
  bool isStep1Valid() => selectedCategory != null;
  
  bool isStep2Valid() {
    if (isOnline) return true;
    return location != null && locationName?.isNotEmpty == true;
  }
  
  bool isStep3Valid() {
    if (meetingType == MeetingType.paid) {
      return price != null && price! >= 3000;
    }
    return minParticipants >= 2 && 
           maxParticipants >= minParticipants && 
           maxParticipants <= 50;
  }
  
  bool isStep4Valid() {
    return title.isNotEmpty && 
           title.length >= 5 && 
           description.isNotEmpty && 
           description.length >= 10 &&
           dateTime != null;
  }

  /// 전체 데이터 유효성 검사
  bool isAllDataValid() {
    return isStep1Valid() && 
           isStep2Valid() && 
           isStep3Valid() && 
           isStep4Valid();
  }

  /// AvailableMeeting 객체로 변환
  AvailableMeeting toAvailableMeeting({
    required String hostId,
    required String hostName,
  }) {
    return AvailableMeeting(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: selectedCategory!,
      type: meetingType,
      scope: scope,
      dateTime: dateTime!,
      location: isOnline ? '온라인' : (locationName ?? ''),
      detailedLocation: detailedAddress ?? '',
      maxParticipants: maxParticipants,
      currentParticipants: 1, // 호스트 포함
      price: meetingType == MeetingType.paid ? price : null,
      hostName: hostName,
      hostId: hostId,
      tags: tags,
      requirements: requirements,
      preparationItems: preparationItems,
    );
  }
}

/// 🎯 모임 생성 상태 관리자
class MeetingCreationNotifier extends StateNotifier<MeetingCreationData> {
  MeetingCreationNotifier() : super(const MeetingCreationData());

  /// Step 1: 카테고리 선택
  void selectCategory(MeetingCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Step 2: 공개범위 설정
  void setScope(MeetingScope scope) {
    state = state.copyWith(scope: scope);
  }

  /// Step 2: 온라인/오프라인 설정
  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(
      isOnline: isOnline,
      // 온라인으로 변경시 위치 정보 초기화
      location: isOnline ? null : state.location,
      locationName: isOnline ? null : state.locationName,
      detailedAddress: isOnline ? null : state.detailedAddress,
    );
  }

  /// Step 2: 위치 설정
  void setLocation(LatLng location, String locationName, [String? detailedAddress]) {
    state = state.copyWith(
      location: location,
      locationName: locationName,
      detailedAddress: detailedAddress,
    );
  }

  /// Step 3: 참가자 인원 설정
  void setParticipants(int min, int max) {
    state = state.copyWith(
      minParticipants: min,
      maxParticipants: max,
    );
  }

  /// Step 3: 모임 타입 설정
  void setMeetingType(MeetingType type, [double? price]) {
    state = state.copyWith(
      meetingType: type,
      price: type == MeetingType.paid ? (price ?? 3000) : null,
    );
  }

  /// Step 3: 참가 방식 설정 (선착순/승인제)
  void setRegistrationMethod(bool isFirstComeFirstServed) {
    state = state.copyWith(isFirstComeFirstServed: isFirstComeFirstServed);
  }

  /// Step 4: 사진 추가
  void addPhoto(File photo) {
    final photos = List<File>.from(state.photos);
    if (photos.length < 5) { // 최대 5장 제한
      photos.add(photo);
      state = state.copyWith(photos: photos);
    }
  }

  /// Step 4: 사진 제거
  void removePhoto(int index) {
    final photos = List<File>.from(state.photos);
    if (index >= 0 && index < photos.length) {
      photos.removeAt(index);
      state = state.copyWith(photos: photos);
    }
  }

  /// Step 4: 제목 설정
  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  /// Step 4: 설명 설정
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Step 4: 날짜 시간 설정
  void setDateTime(DateTime dateTime) {
    state = state.copyWith(dateTime: dateTime);
  }

  /// Step 4: 태그 추가
  void addTag(String tag) {
    final tags = List<String>.from(state.tags);
    if (!tags.contains(tag) && tags.length < 10) { // 최대 10개 제한
      tags.add(tag);
      state = state.copyWith(tags: tags);
    }
  }

  /// Step 4: 태그 제거
  void removeTag(String tag) {
    final tags = List<String>.from(state.tags);
    tags.remove(tag);
    state = state.copyWith(tags: tags);
  }

  /// Step 4: 준비물 추가
  void addPreparationItem(String item) {
    final items = List<String>.from(state.preparationItems);
    if (!items.contains(item) && items.length < 10) { // 최대 10개 제한
      items.add(item);
      state = state.copyWith(preparationItems: items);
    }
  }

  /// Step 4: 준비물 제거
  void removePreparationItem(String item) {
    final items = List<String>.from(state.preparationItems);
    items.remove(item);
    state = state.copyWith(preparationItems: items);
  }

  /// 전체 데이터 초기화 (새 모임 생성 시)
  void reset() {
    state = const MeetingCreationData();
  }

  /// 특정 단계로 이동 전 유효성 검사
  String? validateStep(int stepNumber) {
    switch (stepNumber) {
      case 1:
        if (!state.isStep1Valid()) {
          return '카테고리를 선택해주세요';
        }
        break;
      case 2:
        if (!state.isStep2Valid()) {
          return state.isOnline ? null : '모임 장소를 설정해주세요';
        }
        break;
      case 3:
        if (!state.isStep3Valid()) {
          if (state.meetingType == MeetingType.paid) {
            return '참가비는 3000P 이상 설정해주세요';
          }
          return '참가자 인원을 올바르게 설정해주세요';
        }
        break;
      case 4:
        if (!state.isStep4Valid()) {
          if (state.title.isEmpty || state.title.length < 5) {
            return '모임 제목은 5글자 이상 입력해주세요';
          }
          if (state.description.isEmpty || state.description.length < 10) {
            return '모임 설명은 10글자 이상 입력해주세요';
          }
          if (state.dateTime == null) {
            return '모임 날짜와 시간을 설정해주세요';
          }
        }
        break;
    }
    return null;
  }
}

/// Provider 정의
final meetingCreationProvider = StateNotifierProvider<MeetingCreationNotifier, MeetingCreationData>(
  (ref) => MeetingCreationNotifier(),
);

/// 현재 단계의 유효성 검사 결과 Provider
final currentStepValidationProvider = Provider.family<String?, int>((ref, stepNumber) {
  final notifier = ref.read(meetingCreationProvider.notifier);
  return notifier.validateStep(stepNumber);
});