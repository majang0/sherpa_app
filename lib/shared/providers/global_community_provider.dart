import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../features/home/models/community_model.dart';
import '../models/point_system_model.dart';
import 'global_point_provider.dart';
import 'global_sherpi_provider.dart';
import '../../core/constants/sherpi_dialogues.dart';

/// 글로벌 커뮤니티 상태 관리 Provider
final globalCommunityProvider = StateNotifierProvider<GlobalCommunityNotifier, CommunityState>((ref) {
  return GlobalCommunityNotifier(ref);
});

/// 커뮤니티 전체 상태
class CommunityState {
  final List<CommunityPost> posts;
  final Map<String, List<CommunityComment>> postComments; // postId -> comments
  final DailyCommunityActivity todayActivity;
  final CommunityStatistics statistics;
  final DateTime lastUpdated;

  const CommunityState({
    required this.posts,
    required this.postComments,
    required this.todayActivity,
    required this.statistics,
    required this.lastUpdated,
  });

  /// 초기 상태 생성 (샘플 데이터 포함)
  static CommunityState get initial => CommunityState(
    posts: _createSamplePosts(),
    postComments: _createSampleComments(),
    todayActivity: DailyCommunityActivity(
      date: DateTime.now(),
      activities: {},
      hasReceivedDailyReward: false,
    ),
    statistics: const CommunityStatistics(
      totalPosts: 0,
      totalComments: 0,
      totalLikes: 0,
      popularPosts: 0,
      helpfulComments: 0,
      activeDays: 0,
      totalPoints: 0,
    ),
    lastUpdated: DateTime.now(),
  );

  /// 샘플 게시글 생성
  static List<CommunityPost> _createSamplePosts() {
    final now = DateTime.now();
    return [
      CommunityPost(
        id: 'post_1',
        title: '북한산 등반 후기 🏔️',
        content: '오늘 북한산을 등반했어요! 날씨가 정말 좋아서 정상까지 무사히 올라갔습니다. 정상에서 본 서울 전경이 정말 아름다웠어요. 등반 시간은 약 3시간 정도 걸렸고, 중간에 쉬어가며 천천히 올라갔습니다.',
        authorName: '등산러버',
        authorId: 'user_001',
        createdAt: now.subtract(const Duration(hours: 2)),
        category: '등산',
        tags: ['북한산', '등반후기', '서울'],
        likesCount: 67, // 인기 게시글 (50개 이상)
        commentsCount: 12,
        viewsCount: 234,
        isLikedByUser: false,
        hasReceivedPopularReward: false,
        imageUrls: [],
        type: PostType.record,
      ),
      CommunityPost(
        id: 'post_2',
        title: '아토믹 해빗 독서 완주! 📚',
        content: '드디어 아토믹 해빗을 다 읽었어요! 습관의 복리 효과에 대해 많이 배웠습니다. 특히 1%씩 개선하면 1년 후에 37배 향상된다는 내용이 인상깊었어요. 앞으로 작은 습관들을 하나씩 만들어 보려고 합니다.',
        authorName: '책벌레',
        authorId: 'user_002',
        createdAt: now.subtract(const Duration(hours: 5)),
        category: '독서',
        tags: ['아토믹해빗', '습관', '자기계발'],
        likesCount: 34,
        commentsCount: 8,
        viewsCount: 156,
        isLikedByUser: true,
        hasReceivedPopularReward: false,
        imageUrls: [],
        type: PostType.record,
      ),
      CommunityPost(
        id: 'post_3',
        title: '초보자를 위한 운동 루틴 질문 💪',
        content: '운동을 시작한지 한 달 된 초보입니다. 현재 주 3회 헬스장에 가고 있는데, 어떤 운동을 중심으로 해야 할지 고민이에요. 목표는 근력 증가와 다이어트입니다. 조언 부탁드려요!',
        authorName: '운동초보',
        authorId: 'user_003',
        createdAt: now.subtract(const Duration(hours: 8)),
        category: '운동',
        tags: ['헬스', '초보', '루틴'],
        likesCount: 18,
        commentsCount: 23,
        viewsCount: 89,
        isLikedByUser: false,
        hasReceivedPopularReward: false,
        imageUrls: [],
        type: PostType.question,
      ),
      CommunityPost(
        id: 'post_4',
        title: '스터디 그룹 모집합니다! 📖',
        content: '프로그래밍 스터디 그룹을 만들려고 합니다. 매주 토요일 오후 2시에 온라인으로 모여서 함께 공부할 예정이에요. 현재 React와 Node.js를 주제로 생각하고 있습니다. 관심 있으신 분들 댓글 남겨주세요!',
        authorName: '개발자지망생',
        authorId: 'user_004',
        createdAt: now.subtract(const Duration(days: 1)),
        category: '스터디',
        tags: ['프로그래밍', '리액트', '스터디모집'],
        likesCount: 45,
        commentsCount: 15,
        viewsCount: 178,
        isLikedByUser: false,
        hasReceivedPopularReward: false,
        imageUrls: [],
        type: PostType.general,
      ),
      CommunityPost(
        id: 'post_5',
        title: '오늘의 작은 성취 ☀️',
        content: '오늘은 평소보다 30분 일찍 일어나서 아침 운동을 했어요! 작은 변화지만 하루가 더 알차게 느껴집니다. 여러분도 오늘 작은 성취가 있다면 공유해 주세요!',
        authorName: '아침형인간',
        authorId: 'user_005',
        createdAt: now.subtract(const Duration(hours: 12)),
        category: '일상',
        tags: ['아침운동', '성취', '일상'],
        likesCount: 52, // 인기 게시글
        commentsCount: 19,
        viewsCount: 203,
        isLikedByUser: true,
        hasReceivedPopularReward: false,
        imageUrls: [],
        type: PostType.general,
      ),
      CommunityPost(
        id: 'post_6',
        title: '등반 장비 추천 부탁드려요 🎒',
        content: '등반을 시작한지 얼마 안 된 초보입니다. 기본적인 등반 장비를 구입하려고 하는데, 어떤 브랜드나 제품을 추천해 주실 수 있나요? 예산은 20만원 정도 생각하고 있습니다.',
        authorName: '등반초보',
        authorId: 'user_006',
        createdAt: now.subtract(const Duration(days: 2)),
        category: '등산',
        tags: ['장비추천', '초보', '등반'],
        likesCount: 28,
        commentsCount: 31,
        viewsCount: 145,
        isLikedByUser: false,
        hasReceivedPopularReward: false,
        imageUrls: [],
        type: PostType.question,
      ),
    ];
  }

  /// 샘플 댓글 생성
  static Map<String, List<CommunityComment>> _createSampleComments() {
    final now = DateTime.now();
    
    return {
      'post_1': [
        CommunityComment(
          id: 'comment_1_1',
          postId: 'post_1',
          content: '정말 멋진 후기네요! 저도 다음 주에 북한산 가려고 계획 중이었는데 많은 도움이 됐어요. 혹시 어느 코스로 올라가셨나요?',
          authorName: '산사랑',
          authorId: 'user_007',
          createdAt: now.subtract(const Duration(hours: 1)),
          likesCount: 8,
          isLikedByUser: false,
          hasReceivedHelpfulReward: false,
        ),
        CommunityComment(
          id: 'comment_1_2',
          postId: 'post_1',
          content: '북한산은 정말 좋은 곳이죠! 다음에는 우이암코스도 도전해보세요. 조금 더 험하지만 경치가 정말 환상적이에요.',
          authorName: '등산베테랑',
          authorId: 'user_008',
          createdAt: now.subtract(const Duration(minutes: 45)),
          likesCount: 15, // 도움되는 댓글 (10개 이상)
          isLikedByUser: true,
          hasReceivedHelpfulReward: false,
        ),
      ],
      'post_2': [
        CommunityComment(
          id: 'comment_2_1',
          postId: 'post_2',
          content: '저도 이 책 읽고 있어요! 정말 좋은 책이죠. 특히 습관 쌓기의 4가지 법칙이 기억에 남아요.',
          authorName: '독서클럽',
          authorId: 'user_009',
          createdAt: now.subtract(const Duration(hours: 3)),
          likesCount: 12, // 도움되는 댓글
          isLikedByUser: false,
          hasReceivedHelpfulReward: false,
        ),
      ],
      'post_3': [
        CommunityComment(
          id: 'comment_3_1',
          postId: 'post_3',
          content: '초보자라면 우선 기본기부터 탄탄히 하시는 걸 추천해요. 스쿼트, 데드리프트, 벤치프레스 같은 대근육 운동을 중심으로 하시고, 유산소는 주 2-3회 정도면 충분해요!',
          authorName: '헬스트레이너',
          authorId: 'user_010',
          createdAt: now.subtract(const Duration(hours: 6)),
          likesCount: 25, // 도움되는 댓글
          isLikedByUser: false,
          hasReceivedHelpfulReward: false,
        ),
        CommunityComment(
          id: 'comment_3_2',
          postId: 'post_3',
          content: '저도 초보 때는 비슷한 고민이 있었어요. 무엇보다 꾸준히 하는 게 가장 중요한 것 같아요. 화이팅!',
          authorName: '운동러버',
          authorId: 'user_011',
          createdAt: now.subtract(const Duration(hours: 4)),
          likesCount: 7,
          isLikedByUser: true,
          hasReceivedHelpfulReward: false,
        ),
      ],
    };
  }

  CommunityState copyWith({
    List<CommunityPost>? posts,
    Map<String, List<CommunityComment>>? postComments,
    DailyCommunityActivity? todayActivity,
    CommunityStatistics? statistics,
    DateTime? lastUpdated,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      postComments: postComments ?? this.postComments,
      todayActivity: todayActivity ?? this.todayActivity,
      statistics: statistics ?? this.statistics,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.map((post) => post.toJson()).toList(),
      'postComments': postComments.map((key, value) => 
        MapEntry(key, value.map((comment) => comment.toJson()).toList())),
      'todayActivity': todayActivity.toJson(),
      'statistics': statistics.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CommunityState.fromJson(Map<String, dynamic> json) {
    return CommunityState(
      posts: (json['posts'] as List? ?? [])
          .map((item) => CommunityPost.fromJson(item))
          .toList(),
      postComments: (json['postComments'] as Map? ?? {}).map((key, value) =>
        MapEntry(key as String, 
          (value as List? ?? []).map((item) => CommunityComment.fromJson(item)).toList())),
      todayActivity: DailyCommunityActivity.fromJson(json['todayActivity'] ?? {}),
      statistics: CommunityStatistics.fromJson(json['statistics'] ?? {}),
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }
}

class GlobalCommunityNotifier extends StateNotifier<CommunityState> {
  final Ref ref;

  GlobalCommunityNotifier(this.ref) : super(CommunityState.initial) {
    _loadCommunityData();
  }

  /// SharedPreferences에서 커뮤니티 데이터 로드
  Future<void> _loadCommunityData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final communityJson = prefs.getString('global_community_data');
      if (communityJson != null) {
        final communityData = jsonDecode(communityJson);
        state = CommunityState.fromJson(communityData);
      }
    } catch (e) {
      print('Failed to load community data: $e');
    }
  }

  /// SharedPreferences에 커뮤니티 데이터 저장
  Future<void> _saveCommunityData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('global_community_data', jsonEncode(state.toJson()));
    } catch (e) {
      print('Failed to save community data: $e');
    }
  }

  // ==================== 게시글 관련 기능 ====================

  /// 게시글 좋아요/취소
  void togglePostLike(String postId) {
    final updatedPosts = state.posts.map((post) {
      if (post.id == postId) {
        final isLiking = !post.isLikedByUser;
        final updatedPost = post.copyWith(
          isLikedByUser: isLiking,
          likesCount: isLiking ? post.likesCount + 1 : post.likesCount - 1,
        );

        // 인기 게시글 보상 처리
        if (isLiking) {
          _handleActivityReward(CommunityActivityType.postLiked);
          _checkPopularPostReward(updatedPost);
        }

        return updatedPost;
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);
    _saveCommunityData();
  }

  /// 댓글 좋아요/취소
  void toggleCommentLike(String postId, String commentId) {
    final postComments = Map<String, List<CommunityComment>>.from(state.postComments);
    
    if (postComments.containsKey(postId)) {
      final updatedComments = postComments[postId]!.map((comment) {
        if (comment.id == commentId) {
          final isLiking = !comment.isLikedByUser;
          final updatedComment = comment.copyWith(
            isLikedByUser: isLiking,
            likesCount: isLiking ? comment.likesCount + 1 : comment.likesCount - 1,
          );

          // 도움되는 댓글 보상 처리
          if (isLiking) {
            _handleActivityReward(CommunityActivityType.commentLiked);
            _checkHelpfulCommentReward(updatedComment);
          }

          return updatedComment;
        }
        return comment;
      }).toList();

      postComments[postId] = updatedComments;
    }

    state = state.copyWith(postComments: postComments);
    _saveCommunityData();
  }

  /// 새 게시글 작성
  void createPost({
    required String title,
    required String content,
    required String category,
    required PostType type,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  }) {
    final newPost = CommunityPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      authorName: '박지호', // TODO: 실제 사용자 정보 연동
      authorId: 'user_001',
      createdAt: DateTime.now(),
      category: category,
      tags: tags,
      likesCount: 0,
      commentsCount: 0,
      viewsCount: 0,
      isLikedByUser: false,
      hasReceivedPopularReward: false,
      imageUrls: imageUrls,
      type: type,
    );

    state = state.copyWith(
      posts: [newPost, ...state.posts],
    );

    // 게시글 작성 활동 처리
    _handleActivityReward(CommunityActivityType.postCreated);
    _saveCommunityData();

    // 셰르피 반응
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '새 게시글을 작성했어요! 🎉 커뮤니티가 더 활발해지네요!',
      emotion: SherpiEmotion.cheering,
    );
  }

  /// 새 댓글 작성
  void createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) {
    final newComment = CommunityComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      content: content,
      authorName: '박지호', // TODO: 실제 사용자 정보 연동
      authorId: 'user_001',
      createdAt: DateTime.now(),
      likesCount: 0,
      isLikedByUser: false,
      hasReceivedHelpfulReward: false,
      parentCommentId: parentCommentId,
    );

    // 댓글 추가
    final postComments = Map<String, List<CommunityComment>>.from(state.postComments);
    if (postComments.containsKey(postId)) {
      postComments[postId] = [...postComments[postId]!, newComment];
    } else {
      postComments[postId] = [newComment];
    }

    // 게시글의 댓글 수 증가
    final updatedPosts = state.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(commentsCount: post.commentsCount + 1);
      }
      return post;
    }).toList();

    state = state.copyWith(
      posts: updatedPosts,
      postComments: postComments,
    );

    // 댓글 작성 활동 처리
    _handleActivityReward(CommunityActivityType.commentCreated);
    _saveCommunityData();

    // 셰르피 반응
    ref.read(sherpiProvider.notifier).showInstantMessage(
      context: SherpiContext.encouragement,
      customDialogue: '따뜻한 댓글을 남겨주셨네요! 💬 소통이 활발해져요!',
      emotion: SherpiEmotion.happy,
    );
  }

  // ==================== 활동 및 보상 처리 ====================

  /// 커뮤니티 활동 보상 처리
  void _handleActivityReward(CommunityActivityType activityType) {
    final today = DateTime.now();
    final todayActivity = state.todayActivity;

    // 오늘 활동에 추가
    final updatedActivities = Set<CommunityActivityType>.from(todayActivity.activities);
    updatedActivities.add(activityType);

    // 일일 활동 보상 (하루에 한 번만)
    if (!todayActivity.hasReceivedDailyReward && updatedActivities.isNotEmpty) {
      ref.read(globalPointProvider.notifier).onDailyActivity();
      
      state = state.copyWith(
        todayActivity: DailyCommunityActivity(
          date: today,
          activities: updatedActivities,
          hasReceivedDailyReward: true,
        ),
      );

      // 셰르피 알림
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.encouragement,
        customDialogue: '오늘 첫 커뮤니티 활동! +30P 획득! 🎯',
        emotion: SherpiEmotion.celebrating,
      );
    } else {
      state = state.copyWith(
        todayActivity: DailyCommunityActivity(
          date: today,
          activities: updatedActivities,
          hasReceivedDailyReward: todayActivity.hasReceivedDailyReward,
        ),
      );
    }
  }

  /// 인기 게시글 보상 확인 (좋아요 50개 이상)
  void _checkPopularPostReward(CommunityPost post) {
    if (post.isPopular && !post.hasReceivedPopularReward) {
      // 인기 게시글 보상 지급
      ref.read(globalPointProvider.notifier).onPopularPost();

      // 게시글 보상 수령 상태 업데이트
      final updatedPosts = state.posts.map((p) {
        if (p.id == post.id) {
          return p.copyWith(hasReceivedPopularReward: true);
        }
        return p;
      }).toList();

      state = state.copyWith(posts: updatedPosts);

      // 셰르피 축하 메시지
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.encouragement,
        customDialogue: '🎉 인기 게시글 달성! +100P 획득!\n많은 분들이 좋아해 주셨어요!',
        emotion: SherpiEmotion.celebrating,
      );
    }
  }

  /// 도움되는 댓글 보상 확인 (좋아요 10개 이상)
  void _checkHelpfulCommentReward(CommunityComment comment) {
    if (comment.isHelpful && !comment.hasReceivedHelpfulReward) {
      // 도움되는 댓글 보상 지급
      ref.read(globalPointProvider.notifier).onHelpfulAnswer();

      // 댓글 보상 수령 상태 업데이트
      final postComments = Map<String, List<CommunityComment>>.from(state.postComments);
      if (postComments.containsKey(comment.postId)) {
        final updatedComments = postComments[comment.postId]!.map((c) {
          if (c.id == comment.id) {
            return c.copyWith(hasReceivedHelpfulReward: true);
          }
          return c;
        }).toList();
        postComments[comment.postId] = updatedComments;
      }

      state = state.copyWith(postComments: postComments);

      // 셰르피 축하 메시지
      ref.read(sherpiProvider.notifier).showInstantMessage(
        context: SherpiContext.encouragement,
        customDialogue: '💡 도움되는 댓글! +50P 획득!\n소중한 정보를 나눠주셨네요!',
        emotion: SherpiEmotion.celebrating,
      );
    }
  }

  // ==================== 데이터 조회 ====================

  /// 카테고리별 게시글 필터링
  List<CommunityPost> getPostsByCategory(String category) {
    if (category == '전체') {
      return state.posts;
    }
    return state.posts.where((post) => post.category == category).toList();
  }

  /// 인기 게시글 조회
  List<CommunityPost> getPopularPosts() {
    return state.posts.where((post) => post.isPopular).toList();
  }

  /// 특정 게시글의 댓글 조회
  List<CommunityComment> getCommentsByPostId(String postId) {
    return state.postComments[postId] ?? [];
  }

  /// 오늘 활동 여부 확인
  bool get hasActivityToday {
    return state.todayActivity.isActiveToday;
  }

  /// 일일 활동 보상 수령 가능 여부
  bool get canClaimDailyReward {
    return hasActivityToday && !state.todayActivity.hasReceivedDailyReward;
  }

  /// 통계 업데이트
  void updateStatistics() {
    final posts = state.posts;
    final allComments = state.postComments.values.expand((comments) => comments).toList();

    final newStatistics = CommunityStatistics(
      totalPosts: posts.length,
      totalComments: allComments.length,
      totalLikes: posts.fold(0, (sum, post) => sum + post.likesCount) +
                  allComments.fold(0, (sum, comment) => sum + comment.likesCount),
      popularPosts: posts.where((post) => post.isPopular).length,
      helpfulComments: allComments.where((comment) => comment.isHelpful).length,
      activeDays: state.todayActivity.isActiveToday ? 1 : 0, // 임시로 설정
      totalPoints: 0, // 실제로는 포인트 시스템에서 계산
    );

    state = state.copyWith(statistics: newStatistics);
    _saveCommunityData();
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    // 통계 업데이트
    updateStatistics();
    
    // 오늘 날짜가 바뀌었다면 일일 활동 리셋
    final today = DateTime.now();
    if (state.todayActivity.date.day != today.day) {
      state = state.copyWith(
        todayActivity: DailyCommunityActivity(
          date: today,
          activities: {},
          hasReceivedDailyReward: false,
        ),
      );
      _saveCommunityData();
    }
  }
}

// ==================== UI용 Provider들 ====================

/// 카테고리별 게시글 Provider
final communityPostsByCategoryProvider = Provider.family<List<CommunityPost>, String>((ref, category) {
  final communityState = ref.watch(globalCommunityProvider);
  final notifier = ref.read(globalCommunityProvider.notifier);
  return notifier.getPostsByCategory(category);
});

/// 인기 게시글 Provider
final popularPostsProvider = Provider<List<CommunityPost>>((ref) {
  final communityState = ref.watch(globalCommunityProvider);
  final notifier = ref.read(globalCommunityProvider.notifier);
  return notifier.getPopularPosts();
});

/// 특정 게시글의 댓글 Provider
final postCommentsProvider = Provider.family<List<CommunityComment>, String>((ref, postId) {
  final communityState = ref.watch(globalCommunityProvider);
  final notifier = ref.read(globalCommunityProvider.notifier);
  return notifier.getCommentsByPostId(postId);
});

/// 오늘 활동 상태 Provider
final todayCommunityActivityProvider = Provider<DailyCommunityActivity>((ref) {
  final communityState = ref.watch(globalCommunityProvider);
  return communityState.todayActivity;
});

/// 커뮤니티 통계 Provider
final communityStatisticsProvider = Provider<CommunityStatistics>((ref) {
  final communityState = ref.watch(globalCommunityProvider);
  return communityState.statistics;
});

/// 일일 활동 보상 수령 가능 여부 Provider
final canClaimDailyActivityRewardProvider = Provider<bool>((ref) {
  final notifier = ref.read(globalCommunityProvider.notifier);
  return notifier.canClaimDailyReward;
});
