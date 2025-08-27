// lib/shared/providers/global_meeting_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../features/meetings/models/available_meeting_model.dart';
import '../models/global_user_model.dart';
import 'global_user_provider.dart';
import 'global_point_provider.dart';
import 'global_sherpi_provider.dart';
import '../../core/constants/sherpi_dialogues.dart';
import 'notification_provider.dart';

/// 🌍 글로벌 모임 관리 Provider
/// 모든 모임 관련 데이터와 로직을 중앙에서 관리
final globalMeetingProvider = StateNotifierProvider<GlobalMeetingNotifier, GlobalMeetingState>((ref) {
  return GlobalMeetingNotifier(ref);
});

/// 글로벌 모임 상태
class GlobalMeetingState {
  final List<AvailableMeeting> availableMeetings;
  final List<AvailableMeeting> myJoinedMeetings;
  final bool isLoading;
  final String? errorMessage;

  const GlobalMeetingState({
    this.availableMeetings = const [],
    this.myJoinedMeetings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GlobalMeetingState copyWith({
    List<AvailableMeeting>? availableMeetings,
    List<AvailableMeeting>? myJoinedMeetings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GlobalMeetingState(
      availableMeetings: availableMeetings ?? this.availableMeetings,
      myJoinedMeetings: myJoinedMeetings ?? this.myJoinedMeetings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 글로벌 모임 관리 Notifier
class GlobalMeetingNotifier extends StateNotifier<GlobalMeetingState> {
  final Ref ref;

  GlobalMeetingNotifier(this.ref) : super(const GlobalMeetingState()) {
    _loadInitialData();
  }

  /// 초기 데이터 로드
  void _loadInitialData() {
    state = state.copyWith(isLoading: true);
    _loadSampleMeetings();
    state = state.copyWith(isLoading: false);
  }

  /// 샘플 모임 데이터 로드
  void _loadSampleMeetings() {
    final now = DateTime.now();

    final meetings = [
      // 🏃‍♂️ 운동 모임들
      AvailableMeeting(
        id: 'meeting_001',
        title: '새벽 러닝 모임',
        description: '함께 뛰며 건강한 하루를 시작해요!',
        category: MeetingCategory.exercise,
        type: MeetingType.free,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(hours: 18)), // 오늘 저녁
        location: '한강공원 여의도점',
        detailedLocation: '서울 영등포구 여의동로 330 한강공원 여의도점 주차장',
        maxParticipants: 15,
        currentParticipants: 11,
        hostName: '러닝마니아김씨',
        hostId: 'host_001',
        isRecurring: true,
        tags: ['러닝', '새벽', '초보환영', '아침식사'],
        requirements: ['편한 운동복', '러닝화', '물병'],
        // Assets 이미지 추가 (운동 카테고리 - 이미지 1-6)
        imageFileNames: ['asset:1.jpg'],
      ),
      AvailableMeeting(
        id: 'meeting_002',
        title: '홈트 함께하기',
        description: '집에서 함께 운동해요! 줌으로 만나서 30분간 홈트레이닝을 진행합니다.',
        category: MeetingCategory.exercise,
        type: MeetingType.free,
        scope: MeetingScope.university,
        dateTime: now.add(const Duration(hours: 12)), // 오늘 오후
        location: '온라인 (Zoom)',
        detailedLocation: '줌 링크는 참여 확정 후 공유됩니다',
        maxParticipants: 20,
        currentParticipants: 8,
        hostName: '홈트러버',
        hostId: 'host_002',
        universityName: '영남이공대학교',
        tags: ['홈트', '온라인', '저녁'],
        requirements: ['매트', '수건', '물'],
        // Assets 이미지 추가
        imageFileNames: ['asset:2.jpg'],
      ),

      // 📚 스터디 모임들
      AvailableMeeting(
        id: 'meeting_003',
        title: 'IT 개발자 스터디',
        description: 'React Native 실습 위주로 프로젝트를 함께 만들어요.',
        category: MeetingCategory.study,
        type: MeetingType.paid,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 5, hours: 19)),
        location: '선릉역 코워킹스페이스',
        detailedLocation: '서울 강남구 테헤란로 123 ABC빌딩 5층',
        maxParticipants: 12,
        currentParticipants: 9,
        price: 20000.0,
        hostName: '개발자이씨',
        hostId: 'host_003',
        tags: ['개발', 'React Native', '실습', '프로젝트'],
        requirements: ['노트북', '개발환경 세팅', '기본지식'],
        // Assets 이미지 추가 (스터디 카테고리 - 이미지 7-10)
        imageFileNames: ['asset:7.jpg'],
      ),
      AvailableMeeting(
        id: 'meeting_004',
        title: '영어 회화 스터디',
        description: '원어민과 함께하는 레벨별 자유 회화 시간입니다.',
        category: MeetingCategory.study,
        type: MeetingType.free,
        scope: MeetingScope.university,
        dateTime: now.add(const Duration(days: 3, hours: 18)),
        location: '영남이공대 학생회관',
        detailedLocation: '영남이공대학교 학생회관 2층 동아리방',
        maxParticipants: 15,
        currentParticipants: 7,
        hostName: '영어마스터',
        hostId: 'host_004',
        universityName: '영남이공대학교',
        tags: ['영어', '회화', '원어민', '레벨별'],
        // Assets 이미지 추가
        imageFileNames: ['asset:8.jpg'],
      ),

      // 📖 독서 모임들
      AvailableMeeting(
        id: 'meeting_005',
        title: '독서 토론 모임',
        description: '이번 주 책: "아토믹 해빗" - 함께 읽고 토론해요.',
        category: MeetingCategory.reading,
        type: MeetingType.free,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 3, hours: 14)),
        location: '강남역 스터디카페',
        detailedLocation: '서울 강남구 강남대로 지하 1층 북카페',
        maxParticipants: 10,
        currentParticipants: 6,
        hostName: '책벌레박씨',
        hostId: 'host_005',
        tags: ['독서', '토론', '자기계발', '주말'],
        requirements: ['해당 책 읽고 오기', '토론 주제 준비'],
        // Assets 이미지 추가 (독서 카테고리 - 이미지 11-13)
        imageFileNames: ['asset:11.jpg'],
      ),

      // 🏔️ 아웃도어/여행 모임들
      AvailableMeeting(
        id: 'meeting_006',
        title: '사진 동호회 출사',
        description: '서울숲에서 가을 단풍 사진 촬영과 기초 강의를 진행합니다.',
        category: MeetingCategory.outdoor,
        type: MeetingType.free,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 7, hours: 10)),
        location: '서울숲 입구',
        detailedLocation: '서울 성동구 뚝섬로 273 서울숲공원 정문',
        maxParticipants: 20,
        currentParticipants: 12,
        hostName: '사진작가최씨',
        hostId: 'host_006',
        tags: ['사진', '출사', '단풍', '주말'],
        requirements: ['카메라(스마트폰 가능)', '편한 신발'],
        // Assets 이미지 추가 (아웃도어 카테고리 - 이미지 18-20)
        imageFileNames: ['asset:18.jpg'],
      ),

      // 💪 운동/스포츠 모임들 (요가)
      AvailableMeeting(
        id: 'meeting_007',
        title: '요가 클래스',
        description: '초급자도 쉽게 따라할 수 있는 힐링 요가 시간입니다.',
        category: MeetingCategory.exercise,
        type: MeetingType.free,
        scope: MeetingScope.university,
        dateTime: now.add(const Duration(days: 2, hours: 18)),
        location: '홍대 요가스튜디오',
        detailedLocation: '서울 마포구 와우산로 123 2층 요가스튜디오',
        maxParticipants: 8,
        currentParticipants: 5,
        hostName: '요가강사정씨',
        hostId: 'host_007',
        universityName: '영남이공대학교',
        tags: ['요가', '힐링', '스트레칭', '저녁'],
        requirements: ['매트', '편한 옷', '수건'],
        // Assets 이미지 추가
        imageFileNames: ['asset:3.jpg'],
      ),

      // 🤝 네트워킹 모임들
      AvailableMeeting(
        id: 'meeting_008',
        title: '창업 아이디어 모임',
        description: '창업 아이디어 공유와 네트워킹을 위한 모임입니다.',
        category: MeetingCategory.networking,
        type: MeetingType.paid,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 4, hours: 19)),
        location: '강남 스타트업 허브',
        detailedLocation: '서울 강남구 테헤란로 142 아크플레이스 지하1층',
        maxParticipants: 25,
        currentParticipants: 18,
        price: 15000.0,
        hostName: '스타트업대표',
        hostId: 'host_008',
        tags: ['창업', '네트워킹', '아이디어', '투자'],
        requirements: ['명함', '간단한 자기소개 준비'],
        // Assets 이미지 추가 (네트워킹 카테고리 - 이미지 21-23)
        imageFileNames: ['asset:21.jpg'],
      ),

      // 📖 추가 독서 모임 (중간 가격대)
      AvailableMeeting(
        id: 'meeting_009',
        title: '비즈니스 도서 읽기 모임',
        description: '매주 경영 서적을 읽고 토론하는 모임입니다.',
        category: MeetingCategory.reading,
        type: MeetingType.paid,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 6, hours: 15)),
        location: '강남역 북카페',
        detailedLocation: '서울 강남구 강남대로 123 비즈센터 3층',
        maxParticipants: 12,
        currentParticipants: 8,
        price: 8000.0, // 1만원 이하 테스트용
        hostName: '독서리더',
        hostId: 'host_009',
        tags: ['독서', '비즈니스', '경영', '토론'],
        requirements: ['이번 주 지정도서', '노트'],
        // Assets 이미지 추가
        imageFileNames: ['asset:12.jpg'],
      ),

      // 🏔️ 아웃도어 모임 (저가격대)
      AvailableMeeting(
        id: 'meeting_010',
        title: '한강 걷기 모임',
        description: '건강한 산책과 소통을 위한 한강 걷기 모임입니다.',
        category: MeetingCategory.outdoor,
        type: MeetingType.paid,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(hours: 6)), // 오늘 오전
        location: '여의도 한강공원',
        detailedLocation: '서울 영등포구 여의동로 330 한강공원 여의도점',
        maxParticipants: 30,
        currentParticipants: 22,
        price: 5000.0, // 1만원 이하 테스트용
        hostName: '산책매니아',
        hostId: 'host_010',
        tags: ['산책', '건강', '소통', '한강'],
        requirements: ['편한 신발', '물병'],
        // Assets 이미지 추가
        imageFileNames: ['asset:19.jpg'],
      ),

      // 🎭 문화 모임 (고가격대)
      AvailableMeeting(
        id: 'meeting_011',
        title: '뮤지컬 관람 및 토론',
        description: '뮤지컬 팬텀 단체 관람 후 카페에서 감상 토론을 나눕니다.',
        category: MeetingCategory.culture,
        type: MeetingType.paid,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 8, hours: 19)),
        location: '충무아트센터',
        detailedLocation: '서울 중구 퇴계로 387 충무아트센터 대극장',
        maxParticipants: 8,
        currentParticipants: 5,
        price: 45000.0, // 1만원 이상 테스트용
        hostName: '뮤지컬러버',
        hostId: 'host_011',
        tags: ['뮤지컬', '문화', '토론', '예술'],
        requirements: ['뮤지컬 관람료 별도', '토론 참여 의지'],
        // Assets 이미지 추가 (문화 카테고리 - 이미지 14-17)
        imageFileNames: ['asset:14.jpg'],
      ),

      // 💪 추가 운동 모임 (무료)
      AvailableMeeting(
        id: 'meeting_012',
        title: '주말 축구 모임',
        description: '매주 토요일 아침 축구를 즐기는 동호회입니다.',
        category: MeetingCategory.exercise,
        type: MeetingType.free,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 9, hours: 9)),
        location: '올림픽공원 축구장',
        detailedLocation: '서울 송파구 올림픽로 424 올림픽공원 축구장 A코트',
        maxParticipants: 22,
        currentParticipants: 18,
        hostName: '축구대장',
        hostId: 'host_012',
        tags: ['축구', '운동', '주말', '동호회'],
        requirements: ['축구화', '운동복', '개인 물병'],
        // Assets 이미지 추가
        imageFileNames: ['asset:5.jpg'],
      ),

      // 💻 온라인 모임 (스터디)
      AvailableMeeting(
        id: 'meeting_016',
        title: '온라인 코딩 스터디',
        description: 'Python 기초부터 고급까지 함께 공부하는 온라인 스터디입니다.',
        category: MeetingCategory.study,
        type: MeetingType.free,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 3, hours: 20)),
        location: '온라인',
        detailedLocation: 'Zoom 링크는 참여 확정 후 공유됩니다',
        maxParticipants: 15,
        currentParticipants: 9,
        hostName: '파이썬마스터',
        hostId: 'host_016',
        tags: ['Python', '온라인', '코딩', '프로그래밍'],
        requirements: ['노트북', '파이썬 설치', '안정적인 인터넷'],
        // Assets 이미지 추가
        imageFileNames: ['asset:9.jpg'],
      ),

      // 📚 추가 스터디 모임 (무료)
      AvailableMeeting(
        id: 'meeting_013',
        title: '토익 스터디 그룹',
        description: '토익 800점 목표로 함께 공부하는 스터디입니다.',
        category: MeetingCategory.study,
        type: MeetingType.free,
        scope: MeetingScope.university,
        dateTime: now.add(const Duration(days: 2, hours: 20)),
        location: '부산대학교 도서관',
        detailedLocation: '부산 금정구 부산대학로 63번길 2 부산대학교 중앙도서관',
        maxParticipants: 6,
        currentParticipants: 4,
        hostName: '토익마스터',
        hostId: 'host_013',
        universityName: '부산대학교',
        tags: ['토익', '영어', '시험', '스터디'],
        requirements: ['토익 교재', '노트북'],
        // Assets 이미지 추가
        imageFileNames: ['asset:10.jpg'],
      ),

      // 🤝 추가 네트워킹 모임 (중간가격)
      AvailableMeeting(
        id: 'meeting_014',
        title: '직장인 네트워킹 모임',
        description: '다양한 업계 직장인들과의 네트워킹 시간입니다.',
        category: MeetingCategory.networking,
        type: MeetingType.paid,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 5, hours: 18)),
        location: '대전 유성구 카페',
        detailedLocation: '대전 유성구 대학로 123 네트워킹 카페',
        maxParticipants: 20,
        currentParticipants: 14,
        price: 7000.0, // 1만원 이하 테스트용
        hostName: '네트워킹킹',
        hostId: 'host_014',
        tags: ['네트워킹', '직장인', '커리어', '소통'],
        requirements: ['명함', '자기소개서 준비'],
        // Assets 이미지 추가
        imageFileNames: ['asset:23.jpg'],
      ),

      // 🏔️ 추가 아웃도어 모임 (고가격)
      AvailableMeeting(
        id: 'meeting_015',
        title: '제주도 2박3일 여행',
        description: '제주도 맛집 투어와 관광명소를 함께 둘러보는 여행입니다.',
        category: MeetingCategory.outdoor,
        type: MeetingType.paid,
        scope: MeetingScope.public,
        dateTime: now.add(const Duration(days: 21, hours: 8)),
        location: '제주국제공항',
        detailedLocation: '제주특별자치도 제주시 공항로 2 제주국제공항 국내선청사',
        maxParticipants: 8,
        currentParticipants: 6,
        price: 180000.0, // 1만원 이상 테스트용
        hostName: '제주러버',
        hostId: 'host_015',
        tags: ['여행', '제주도', '관광', '맛집'],
        requirements: ['여권 또는 신분증', '편한 신발', '카메라'],
        // Assets 이미지 추가
        imageFileNames: ['asset:20.jpg'],
      ),
    ];

    state = state.copyWith(availableMeetings: meetings);
  }

  /// 모임 참여 (완전한 글로벌 연동)
  Future<bool> joinMeeting(AvailableMeeting meeting) async {
    try {
      // 1. 참여 가능성 체크
      if (!meeting.canJoin) {
        ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.encouragement,
          customDialogue: '이미 마감되었거나 시간이 지난 모임이에요! 😅',
          emotion: SherpiEmotion.thinking,
        );
        return false;
      }

      // 2. 포인트 차감
      final pointNotifier = ref.read(globalPointProvider.notifier);
      final fee = meeting.participationFee;

      final success = pointNotifier.spendPoints(
        fee.toInt(),
        '모임 참여 수수료: ${meeting.title}',
      );

      if (!success) {
        final currentPoints = ref.read(globalTotalPointsProvider);
        ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.encouragement,
          customDialogue: '포인트가 부족해요! 현재 ${currentPoints}P 보유중입니다. ${fee.toInt()}P가 필요해요.',
          emotion: SherpiEmotion.thinking,
        );
        return false;
      }

      // 모임 참가 결제 알림 생성
      ref.read(notificationProvider.notifier).notifyMeetingComplete(
        meeting.title,
        meeting.currentParticipants + 1,
        fee: fee.toInt(),
      );

      // 3. 글로벌 사용자 데이터에 기록 추가
      final userNotifier = ref.read(globalUserProvider.notifier);

      final meetingLog = MeetingLog(
        id: 'meeting_log_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        meetingName: meeting.title,
        category: meeting.category.displayName,
        satisfaction: 4.5,
        mood: 'happy',
        note: '${meeting.location}에서 참여',
        isShared: false,
      );

      // 4. 자동 보상 처리 (글로벌 시스템 활용)
      userNotifier.addMeetingLog(meetingLog);

      // 5. 추가 보상 지급
      final additionalXp = meeting.experienceReward - 50.0;
      if (additionalXp > 0) {
        userNotifier.addExperience(additionalXp);
      }

      // 6. 능력치 보상
      final statRewards = meeting.statRewards;
      if (statRewards.isNotEmpty) {
        userNotifier.increaseStats(
          deltaStamina: statRewards['stamina'] ?? 0,
          deltaKnowledge: statRewards['knowledge'] ?? 0,
          deltaTechnique: statRewards['technique'] ?? 0,
          deltaSociality: statRewards['sociality'] ?? 0,
          deltaWillpower: statRewards['willpower'] ?? 0,
        );
      }

      // 7. 모임 참여자 수 증가
      final updatedMeetings = state.availableMeetings.map((m) {
        if (m.id == meeting.id) {
          return m.copyWith(currentParticipants: m.currentParticipants + 1);
        }
        return m;
      }).toList();

      // 8. 내 참여 모임에 추가
      final updatedJoinedMeetings = [...state.myJoinedMeetings, meeting];

      state = state.copyWith(
        availableMeetings: updatedMeetings,
        myJoinedMeetings: updatedJoinedMeetings,
      );

      // 9. 성공 피드백
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.meetingJoined,
        customDialogue: '🎉 "${meeting.title}" 모임 참여 완료!\n경험치 +${meeting.experienceReward.toInt()}, 포인트 +${meeting.participationReward.toInt()}',
        emotion: SherpiEmotion.cheering,
      );

      return true;
    } catch (e) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.encouragement,
        customDialogue: '모임 참여 중 오류가 발생했어요. 다시 시도해주세요! 😅',
        emotion: SherpiEmotion.thinking,
      );
      return false;
    }
  }

  /// 모임 후기 작성
  void completeMeetingReview({
    required String meetingId,
    required double satisfaction,
    required String mood,
    String? note,
  }) {
    final userNotifier = ref.read(globalUserProvider.notifier);
    
    // 참여한 모임 정보 찾기
    final meeting = state.availableMeetings.firstWhere(
      (m) => m.id == meetingId,
      orElse: () => state.myJoinedMeetings.firstWhere(
        (m) => m.id == meetingId,
        orElse: () => AvailableMeeting(
          id: meetingId,
          title: '알 수 없는 모임',
          description: '',
          category: MeetingCategory.all,
          type: MeetingType.free,
          scope: MeetingScope.public,
          dateTime: DateTime.now(),
          location: '',
          detailedLocation: '',
          maxParticipants: 0,
          currentParticipants: 0,
          hostName: '',
          hostId: '',
        ),
      ),
    );
    
    // 🔥 모임 로그 추가 (퀘스트 추적을 위해 필수!)
    final meetingLog = MeetingLog(
      id: '${meetingId}_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      meetingName: meeting.title,
      category: meeting.category.name,
      satisfaction: satisfaction,
      mood: _getMoodIcon(mood),
      note: note,
      isShared: false,
    );
    
    userNotifier.addMeetingLog(meetingLog);

    // 후기 완료 보너스
    userNotifier.addExperience(25.0);
    userNotifier.increaseStats(deltaWillpower: 0.1);

    // 🔄 주간 퀘스트 시스템 업데이트 트리거 (핵심 수정!)
    // handleActivityCompletion이 자동으로 셰르피 메시지를 표시함
    userNotifier.handleActivityCompletion(
      activityType: 'meeting_review',
      xp: 0.0, // 위에서 이미 지급했으므로 0
      points: 0,
      statIncreases: {},
      message: '모임 후기 작성 완료!',
      additionalData: {
        'meetingId': meetingId,
        'category': meeting.category.name,
        'satisfaction': satisfaction,
        'hasNote': note != null && note.isNotEmpty,
        'weeklyUpdate': true, // 주간 퀘스트 업데이트가 필요함을 표시
      },
    );
  }
  
  /// 기분 이모티콘 매핑
  String _getMoodIcon(String mood) {
    switch (mood) {
      case 'happy':
        return '😊';
      case 'excited':
        return '🤩';
      case 'satisfied':
        return '😌';
      case 'neutral':
        return '😐';
      case 'disappointed':
        return '😞';
      default:
        return '😊';
    }
  }

  /// 카테고리별 모임 필터링
  List<AvailableMeeting> getMeetingsByCategory(MeetingCategory? category) {
    if (category == null) return state.availableMeetings;
    // '전체' 카테고리인 경우 모든 모임 반환
    if (category == MeetingCategory.all) return state.availableMeetings;
    return state.availableMeetings.where((meeting) => meeting.category == category).toList();
  }

  /// 범위별 모임 필터링
  List<AvailableMeeting> getMeetingsByScope(MeetingScope? scope) {
    if (scope == null) return state.availableMeetings;
    return state.availableMeetings.where((meeting) => meeting.scope == scope).toList();
  }

  /// 참여 가능한 모임만 필터링
  List<AvailableMeeting> get availableMeetings {
    return state.availableMeetings.where((meeting) => meeting.canJoin).toList();
  }

  /// 인기 모임 (참여자가 많은 순)
  List<AvailableMeeting> get popularMeetings {
    final sortedMeetings = List<AvailableMeeting>.from(state.availableMeetings);
    sortedMeetings.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
    return sortedMeetings.take(5).toList();
  }

  /// 추천 모임 (사용자 능력치 기반)
  List<AvailableMeeting> getRecommendedMeetings() {
    final user = ref.read(globalUserProvider);
    final stats = user.stats;

    final sortedMeetings = List<AvailableMeeting>.from(availableMeetings);

    if (stats.stamina >= stats.knowledge && stats.stamina >= stats.technique) {
      // 체력이 높으면 운동/아웃도어 모임 추천
      sortedMeetings.sort((a, b) {
        final aIsActive = a.category == MeetingCategory.exercise || a.category == MeetingCategory.outdoor;
        final bIsActive = b.category == MeetingCategory.exercise || b.category == MeetingCategory.outdoor;
        if (aIsActive && !bIsActive) return -1;
        if (!aIsActive && bIsActive) return 1;
        return 0;
      });
    } else if (stats.knowledge >= stats.technique) {
      // 지식이 높으면 스터디/독서 모임 추천
      sortedMeetings.sort((a, b) {
        final aIsStudy = a.category == MeetingCategory.study || a.category == MeetingCategory.reading;
        final bIsStudy = b.category == MeetingCategory.study || b.category == MeetingCategory.reading;
        if (aIsStudy && !bIsStudy) return -1;
        if (!aIsStudy && bIsStudy) return 1;
        return 0;
      });
    } else {
      // 기술이 높으면 문화/네트워킹 모임 추천
      sortedMeetings.sort((a, b) {
        final aIsSocial = a.category == MeetingCategory.networking || a.category == MeetingCategory.culture;
        final bIsSocial = b.category == MeetingCategory.networking || b.category == MeetingCategory.culture;
        if (aIsSocial && !bIsSocial) return -1;
        if (!aIsSocial && bIsSocial) return 1;
        return 0;
      });
    }

    return sortedMeetings.take(3).toList();
  }

  /// 임박한 모임 (7일 이내)
  List<AvailableMeeting> get upcomingMeetings {
    return state.availableMeetings.where((meeting) =>
      meeting.canJoin &&
      meeting.timeUntilStart.inDays <= 7 &&
      meeting.timeUntilStart.inMinutes > 0 // 과거가 아닌 미래 모임만
    ).toList();
  }

  /// 새 모임 추가 (모임 개설 시 사용)
  Future<bool> addMeeting(AvailableMeeting newMeeting) async {
    try {
      // 1. 중복 ID 체크
      if (state.availableMeetings.any((meeting) => meeting.id == newMeeting.id)) {
        ref.read(sherpiProvider.notifier).showInstantMessage(
          context: SherpiContext.encouragement,
          customDialogue: '이미 존재하는 모임입니다! 😅',
          emotion: SherpiEmotion.thinking,
        );
        return false;
      }

      // 2. 새 모임을 기존 목록에 추가 (최신 모임이 맨 앞에 오도록)
      final updatedMeetings = [newMeeting, ...state.availableMeetings];

      // 3. 상태 업데이트
      state = state.copyWith(availableMeetings: updatedMeetings);

      // 4. 성공 피드백
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.achievement,
        customDialogue: '🎉 "${newMeeting.title}" 모임이 성공적으로 개설되었습니다!\n다른 사용자들이 참가할 수 있도록 모임을 홍보해보세요.',
        emotion: SherpiEmotion.cheering,
      );

      return true;
    } catch (e) {
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.encouragement,
        customDialogue: '모임 개설 중 오류가 발생했어요. 다시 시도해주세요! 😅',
        emotion: SherpiEmotion.thinking,
      );
      return false;
    }
  }

  /// 데이터 새로고침
  void refresh() {
    _loadInitialData();
  }
}

// ==================== UI용 Provider들 ====================

/// 카테고리별 모임 Provider
final globalMeetingsByCategoryProvider = Provider.family<List<AvailableMeeting>, MeetingCategory?>((ref, category) {
  final notifier = ref.read(globalMeetingProvider.notifier);
  return notifier.getMeetingsByCategory(category);
});

/// 범위별 모임 Provider
final globalMeetingsByScopeProvider = Provider.family<List<AvailableMeeting>, MeetingScope?>((ref, scope) {
  final notifier = ref.read(globalMeetingProvider.notifier);
  return notifier.getMeetingsByScope(scope);
});

/// 참여 가능한 모임 Provider
final globalAvailableMeetingsProvider = Provider<List<AvailableMeeting>>((ref) {
  final state = ref.watch(globalMeetingProvider);
  return state.availableMeetings;
});

/// 인기 모임 Provider
final globalPopularMeetingsProvider = Provider<List<AvailableMeeting>>((ref) {
  final notifier = ref.read(globalMeetingProvider.notifier);
  return notifier.popularMeetings;
});

/// 추천 모임 Provider
final globalRecommendedMeetingsProvider = Provider<List<AvailableMeeting>>((ref) {
  final notifier = ref.read(globalMeetingProvider.notifier);
  return notifier.getRecommendedMeetings();
});

/// 임박한 모임 Provider
final globalUpcomingMeetingsProvider = Provider<List<AvailableMeeting>>((ref) {
  final notifier = ref.read(globalMeetingProvider.notifier);
  return notifier.upcomingMeetings;
});

/// 놓치면 아쉬운 모임 Provider (임박한 모임과 동일)
final globalUrgentMeetingsProvider = Provider<List<AvailableMeeting>>((ref) {
  final notifier = ref.read(globalMeetingProvider.notifier);
  return notifier.upcomingMeetings;
});

/// 내 참여 모임 Provider
final globalMyJoinedMeetingsProvider = Provider<List<AvailableMeeting>>((ref) {
  final state = ref.watch(globalMeetingProvider);
  return state.myJoinedMeetings;
});

/// 참여한 모임 기록 Provider (글로벌 데이터 활용)
final globalMyMeetingLogsProvider = Provider<List<MeetingLog>>((ref) {
  final user = ref.watch(globalUserProvider);
  return user.dailyRecords.meetingLogs;
});

/// 이번 달 참여한 모임 수 Provider
final globalThisMonthMeetingCountProvider = Provider<int>((ref) {
  final meetingLogs = ref.watch(globalMyMeetingLogsProvider);
  final now = DateTime.now();

  return meetingLogs.where((log) =>
    log.date.year == now.year && log.date.month == now.month
  ).length;
});

/// 모임 통계 Provider
final globalMeetingStatsProvider = Provider<GlobalMeetingStats>((ref) {
  final meetingLogs = ref.watch(globalMyMeetingLogsProvider);
  final user = ref.watch(globalUserProvider);

  final totalMeetings = meetingLogs.length;
  final thisMonthCount = ref.watch(globalThisMonthMeetingCountProvider);
  final averageSatisfaction = meetingLogs.isNotEmpty
    ? meetingLogs.map((log) => log.satisfaction).reduce((a, b) => a + b) / meetingLogs.length
    : 0.0;

  // 카테고리별 참여 횟수
  final categoryStats = <String, int>{};
  for (final log in meetingLogs) {
    categoryStats[log.category] = (categoryStats[log.category] ?? 0) + 1;
  }

  return GlobalMeetingStats(
    totalParticipated: totalMeetings,
    thisMonthCount: thisMonthCount,
    averageSatisfaction: averageSatisfaction,
    socialityLevel: user.stats.sociality,
    categoryStats: categoryStats,
  );
});

/// 글로벌 모임 통계 데이터 클래스
class GlobalMeetingStats {
  final int totalParticipated;
  final int thisMonthCount;
  final double averageSatisfaction;
  final double socialityLevel;
  final Map<String, int> categoryStats;

  const GlobalMeetingStats({
    required this.totalParticipated,
    required this.thisMonthCount,
    required this.averageSatisfaction,
    required this.socialityLevel,
    required this.categoryStats,
  });

  String get favoriteCategory {
    if (categoryStats.isEmpty) return '없음';

    final sorted = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  String get satisfactionGrade {
    if (averageSatisfaction >= 4.5) return 'S';
    if (averageSatisfaction >= 4.0) return 'A';
    if (averageSatisfaction >= 3.5) return 'B';
    if (averageSatisfaction >= 3.0) return 'C';
    return 'D';
  }
}