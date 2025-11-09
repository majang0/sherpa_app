import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Core
import 'main_navigation_screen.dart';
import 'core/theme/modern_colors.dart';

// Providers (Level-based organization)
import 'shared/providers/level_0_foundation/global_game_provider.dart';
import 'shared/providers/level_1_user_data/global_user_provider.dart';
import 'shared/providers/level_1_user_data/global_point_provider.dart';
import 'shared/providers/level_1_user_data/global_user_title_provider.dart';
import 'shared/providers/level_2_features/global_meeting_provider.dart';
import 'shared/providers/level_3_ai/global_sherpi_provider.dart';
import 'features/quests/providers/quest_provider_v2.dart';
import 'features/goals/providers/goal_provider.dart'; // 목표 Provider
import 'features/goals/providers/routine_provider.dart'; // 루틴 Provider
import 'features/sherpi/relationship/providers/relationship_provider.dart';
import 'features/sherpi/emotion/providers/emotion_analysis_provider.dart';

// Screens - Meetings
import 'features/meetings/presentation/screens/available_meeting_detail_screen.dart';
import 'features/meetings/presentation/screens/meeting_application_screen.dart';
import 'features/meetings/presentation/screens/meeting_success_screen.dart';
import 'features/meetings/presentation/screens/meeting_review_screen.dart';
import 'features/meetings/presentation/screens/meeting_list_all_screen.dart';

// Screens - Daily Record
import 'features/daily_record/presentation/screens/enhanced_daily_record_screen.dart';
import 'features/activities_diary/presentation/screens/diary_write_edit_screen.dart';
import 'features/activities_exercise/presentation/screens/exercise_record_screen.dart';
import 'features/activities_exercise/presentation/screens/exercise_selection_screen.dart';
import 'features/activities_exercise/presentation/screens/exercise_dashboard_screen.dart';
import 'features/activities_exercise/presentation/screens/exercise_detail_screen.dart';
import 'features/activities_exercise/presentation/screens/exercise_edit_screen.dart';
import 'features/activities_exercise/presentation/screens/running_detail_screen.dart';
import 'features/activities_exercise/presentation/screens/running_edit_screen.dart';
import 'features/activities_reading/presentation/screens/reading_record_screen.dart';
import 'features/activities_focus/presentation/screens/focus_timer_record_screen.dart';
import 'shared/widgets/dialogs/analysis_pages/diary_analysis_page.dart';

// Screens - Shared
import 'shared/presentation/screens/component_viewer_screen.dart';

// Screens - Sherpi Chat
import 'features/sherpi/chat/presentation/screens/sherpi_message_history_screen.dart';

// Screens - Goals Achievement
import 'features/goals/presentation/screens/goals_screen.dart';
import 'features/goals/presentation/screens/routines_screen.dart';
import 'features/goals/presentation/screens/ai_analysis_screen.dart';

// Models
import 'features/meetings/models/available_meeting_model.dart';
import 'shared/models/global_user_model.dart';
import 'features/activities_exercise/models/detailed_exercise_models.dart';

// SharedPreferences Provider 초기화
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 환경 변수 초기화 (.env 파일 로드)
  await dotenv.load(fileName: ".env");

  // 🧪 API 키 상태 디버그 (개발 중에만 사용)
  // ApiConfig.debugApiKeyStatus(); // 필요시 주석 해제

  // SharedPreferences 초기화
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        relationshipProvider.overrideWith(
            (ref) => SherpiRelationshipNotifier(sharedPreferences)),
        emotionAnalysisProvider
            .overrideWith((ref) => EmotionAnalysisNotifier(sharedPreferences)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ 앱 시작 시 모든 글로벌 Provider 초기화
    _initializeGlobalProviders(ref);

    return MaterialApp(
      title: 'Sherpa',
      // ✅ 한국어 로케일 및 지역화 설정
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어 (fallback)
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: ModernColors.primary,
        scaffoldBackgroundColor: ModernColors.background,
        fontFamily: 'NotoSans',
      ),
      // ✅ 전역 셰르피 오버레이를 위한 builder 추가
      builder: (context, child) {
        return Stack(
          children: [
            // 기본 앱 화면
            child ?? const SizedBox(),
            // ✅ 전역 셰르피 오버레이 (모든 화면에서 표시)
            /*
            Consumer(
              builder: (context, ref, child) {
                return GlobalSherpiOverlay();
              },
            ),
        */
          ],
        );
      },
      // ✅ 라우팅 설정 추가
      routes: {
        '/': (context) => const MainNavigationScreen(),
        '/meeting_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return _buildMeetingRoute(
            args: args,
            routeName: '/meeting_detail',
            builder: (meeting) =>
                AvailableMeetingDetailScreen(meeting: meeting),
          );
        },
        '/meeting_application': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return _buildMeetingRoute(
            args: args,
            routeName: '/meeting_application',
            builder: (meeting) => MeetingApplicationScreen(meeting: meeting),
          );
        },
        '/meeting_success': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return _buildMeetingRoute(
            args: args,
            routeName: '/meeting_success',
            builder: (meeting) => MeetingSuccessScreen(meeting: meeting),
          );
        },
        '/meeting_review': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return _buildMeetingRoute(
            args: args,
            routeName: '/meeting_review',
            builder: (meeting) => MeetingReviewScreen(meeting: meeting),
          );
        },
        '/meeting_list_all': (context) => const MeetingListAllScreen(),
        // ✅ 일일 기록 화면들 추가
        '/daily_record': (context) =>
            const EnhancedDailyRecordScreen(), // 메인 기록 화면
        '/diary_record': (context) => const DiaryWriteEditScreen(),
        '/exercise_record': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return ExerciseRecordScreen(
            exerciseType: args?['exerciseType'] ?? '러닝',
            selectedDate: args?['selectedDate'] ?? DateTime.now(),
          );
        },
        '/exercise_selection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as DateTime?;
          return ExerciseSelectionScreen(
            selectedDate: args ?? DateTime.now(),
          );
        },
        '/exercise_dashboard': (context) => const ExerciseDashboardScreen(),
        '/exercise_detail': (context) {
          final exercise =
              ModalRoute.of(context)!.settings.arguments as ExerciseLog;
          return ExerciseDetailScreen(exercise: exercise);
        },
        '/exercise_edit': (context) {
          final exercise =
              ModalRoute.of(context)!.settings.arguments as ExerciseLog;
          return ExerciseEditScreen(exercise: exercise);
        },
        '/running_detail': (context) {
          final runningRecord =
              ModalRoute.of(context)!.settings.arguments as RunningRecord;
          return RunningDetailScreen(runningRecord: runningRecord);
        },
        '/running_edit': (context) {
          final runningRecord =
              ModalRoute.of(context)!.settings.arguments as RunningRecord;
          return RunningEditScreen(runningRecord: runningRecord);
        },
        '/reading_record': (context) => const ReadingRecordScreen(),
        '/focus_timer': (context) =>
            const EnhancedDailyRecordScreen(), // 집중 타이머는 기록 화면에서 접근
        '/focus_timer_record': (context) => const FocusTimerRecordScreen(),
        '/diary_analysis': (context) => const DiaryAnalysisPage(),
        '/component_viewer': (context) => const ComponentViewerScreen(),
        '/sherpi_message_history': (context) =>
            const SherpiMessageHistoryScreen(),
        // ✅ 목표 달성 화면들 추가
        '/goals': (context) => const GoalsScreen(),
        '/routines': (context) => const RoutinesScreen(),
        '/ai_analysis': (context) => const AiAnalysisScreen(),
      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }

  /// 글로벌 Provider 초기화 메서드
  void _initializeGlobalProviders(WidgetRef ref) {
    try {
      // ✅ 11개 글로벌 Provider 초기화 순서대로

      // Level 0: Foundation (1개)
      // 1. 게임 시스템 초기화 (기초 데이터)
      ref.read(globalGameProvider);

      // Level 1: User Data (3개)
      // 2. 사용자 데이터 초기화
      ref.read(globalUserProvider);

      // 3. 포인트 시스템 초기화
      ref.read(globalPointProvider);

      // 4. 칭호 시스템 초기화
      ref.read(globalUserTitleProvider);

      // Level 2: Features (4개)
      // 5. 퀘스트 시스템 V2 초기화
      ref.read(questProviderV2);

      // 6. 모임 시스템 초기화
      ref.read(globalMeetingProvider);

      // 7. 목표 시스템 초기화
      ref.read(goalProvider);

      // 8. 루틴 시스템 초기화
      ref.read(routineProvider);

      // Level 3: AI & Advanced (3개)
      // 9. 셰르피 시스템 초기화
      ref.read(sherpiProvider);

      // 10. 셰르피 관계 시스템 초기화
      ref.read(relationshipProvider);

      // 11. 감정 분석 시스템 초기화
      ref.read(emotionAnalysisProvider);
    } catch (e) {
      // 에러 무시 - 중요하지 않은 작업
    }
  }
}

Widget _buildMeetingRoute({
  required dynamic args,
  required String routeName,
  required Widget Function(AvailableMeeting) builder,
}) {
  return Consumer(
    builder: (context, ref, _) {
      final meeting = _resolveMeetingArgument(args, ref);
      if (meeting == null) {
        return MeetingNotFoundScreen(routeName: routeName);
      }
      return builder(meeting);
    },
  );
}

AvailableMeeting? _resolveMeetingArgument(dynamic args, WidgetRef ref) {
  if (args is AvailableMeeting) {
    return args;
  }

  if (args is Map) {
    final meetingId = args['meetingId'];
    if (meetingId is String && meetingId.isNotEmpty) {
      final meetingState = ref.read(globalMeetingProvider);
      return _findMeetingById(meetingState.availableMeetings, meetingId) ??
          _findMeetingById(meetingState.myJoinedMeetings, meetingId);
    }
  }

  return null;
}

AvailableMeeting? _findMeetingById(
  Iterable<AvailableMeeting> meetings,
  String meetingId,
) {
  for (final meeting in meetings) {
    if (meeting.id == meetingId) {
      return meeting;
    }
  }
  return null;
}

class MeetingNotFoundScreen extends StatelessWidget {
  final String routeName;

  const MeetingNotFoundScreen({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모임을 찾을 수 없어요'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 56,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '요청하신 모임 정보를 찾을 수 없습니다.',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                routeName,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('이전 화면으로'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
