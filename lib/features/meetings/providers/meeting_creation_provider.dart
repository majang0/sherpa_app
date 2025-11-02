// lib/features/meetings/providers/meeting_creation_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/available_meeting_model.dart';
import '../models/meeting_creation_model.dart';

/// 모임 생성 상태 관리 Notifier
///
/// 모임 생성 과정의 모든 데이터 변경을 관리하고,
/// 각 단계별 유효성 검사를 수행합니다.
class MeetingCreationNotifier extends StateNotifier<MeetingCreationData> {
  MeetingCreationNotifier() : super(const MeetingCreationData());

  /// Step 1: 카테고리 선택
  void selectCategory(MeetingCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// 모임 범위 설정 (공개/비공개)
  void setScope(MeetingScope scope) {
    state = state.copyWith(scope: scope);
  }

  /// Step 2: 온라인/오프라인 설정
  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(
      isOnline: isOnline,
      location: isOnline ? null : state.location,
      locationName: isOnline ? null : state.locationName,
      detailedAddress: isOnline ? null : state.detailedAddress,
    );
  }

  /// Step 2: 장소 설정
  void setLocation(
    LatLng location,
    String locationName, [
    String? detailedAddress,
  ]) {
    state = state.copyWith(
      location: location,
      locationName: locationName,
      detailedAddress: detailedAddress,
    );
  }

  /// Step 3: 참가 인원 설정
  void setParticipants(int min, int max) {
    state = state.copyWith(
      minParticipants: min,
      maxParticipants: max,
    );
  }

  /// Step 3: 모임 유형 및 참가비 설정
  void setMeetingType(MeetingType type, [double? price]) {
    state = state.copyWith(
      meetingType: type,
      price: type == MeetingType.paid ? (price ?? 3000) : null,
    );
  }

  /// Step 3: 선착순/승인제 설정
  void setRegistrationMethod(bool isFirstComeFirstServed) {
    state = state.copyWith(isFirstComeFirstServed: isFirstComeFirstServed);
  }

  /// Step 4: 사진 추가 (최대 5장)
  void addPhoto(File photo) {
    final photos = List<File>.from(state.photos);
    if (photos.length < 5) {
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

  /// Step 4: 모임 제목 설정
  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  /// Step 4: 모임 설명 설정
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Step 4: 모임 날짜/시간 설정
  void setDateTime(DateTime dateTime) {
    state = state.copyWith(dateTime: dateTime);
  }

  /// 태그 추가 (최대 10개)
  void addTag(String tag) {
    final tags = List<String>.from(state.tags);
    if (!tags.contains(tag) && tags.length < 10) {
      tags.add(tag);
      state = state.copyWith(tags: tags);
    }
  }

  /// 태그 제거
  void removeTag(String tag) {
    final tags = List<String>.from(state.tags)..remove(tag);
    state = state.copyWith(tags: tags);
  }

  /// 준비물 추가 (최대 10개)
  void addPreparationItem(String item) {
    final items = List<String>.from(state.preparationItems);
    if (!items.contains(item) && items.length < 10) {
      items.add(item);
      state = state.copyWith(preparationItems: items);
    }
  }

  /// 준비물 제거
  void removePreparationItem(String item) {
    final items = List<String>.from(state.preparationItems)..remove(item);
    state = state.copyWith(preparationItems: items);
  }

  /// 모든 데이터 초기화
  void reset() {
    state = const MeetingCreationData();
  }

  /// 단계별 유효성 검사 및 에러 메시지 반환
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

/// 모임 생성 Provider (auto-dispose)
final meetingCreationProvider = StateNotifierProvider.autoDispose<
    MeetingCreationNotifier, MeetingCreationData>(
  (ref) => MeetingCreationNotifier(),
);
