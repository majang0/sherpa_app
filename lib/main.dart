import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Core
import 'main_navigation_screen.dart';
import 'core/constants/app_colors.dart';

// Providers
import 'shared/providers/global_sherpi_provider.dart';
import 'shared/providers/global_user_provider.dart';
import 'shared/providers/global_point_provider.dart';
import 'shared/providers/global_user_title_provider.dart';
import 'shared/providers/global_game_provider.dart';
import 'shared/providers/global_meeting_provider.dart';
import 'features/quests/providers/quest_provider_v2.dart';
import 'features/sherpi_relationship/providers/relationship_provider.dart';
import 'features/sherpi_emotion/providers/emotion_analysis_provider.dart';

// Screens - Meetings
import 'features/meetings/presentation/screens/meeting_detail_screen.dart';
import 'features/meetings/presentation/screens/meeting_application_screen.dart';
import 'features/meetings/presentation/screens/meeting_success_screen.dart';
import 'features/meetings/presentation/screens/meeting_review_screen.dart';
import 'features/meetings/presentation/screens/meeting_create_multi_step_screen.dart';

// Screens - Daily Record
import 'features/daily_record/presentation/screens/enhanced_daily_record_screen.dart';
import 'features/daily_record/presentation/screens/diary_write_edit_screen.dart';
import 'features/daily_record/presentation/screens/exercise_record_screen.dart';
import 'features/daily_record/presentation/screens/exercise_selection_screen.dart';
import 'features/daily_record/presentation/screens/exercise_dashboard_screen.dart';
import 'features/daily_record/presentation/screens/exercise_detail_screen.dart';
import 'features/daily_record/presentation/screens/exercise_edit_screen.dart';
import 'features/daily_record/presentation/screens/reading_record_screen.dart';

// Screens - Shared
import 'shared/presentation/screens/component_viewer_screen.dart';
import 'shared/presentation/screens/meeting_list_all_screen.dart';

// Screens - Sherpi Chat
import 'features/sherpi_chat/presentation/screens/sherpi_message_history_screen.dart';

// Models
import 'features/meetings/models/available_meeting_model.dart';
import 'shared/models/global_user_model.dart';


// SharedPreferences Provider 초기화
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences 초기화
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        sherpiRelationshipProvider.overrideWith((ref) => 
          SherpiRelationshipNotifier(sharedPreferences)
        ),
        emotionAnalysisProvider.overrideWith((ref) => 
          EmotionAnalysisNotifier(sharedPreferences)
        ),
      ],
      child: MyApp(),
    ),
  );
}



class MyApp extends ConsumerWidget {
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
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
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
        '/': (context) => MainNavigationScreen(),
        '/meeting_detail': (context) {
          final meeting = ModalRoute.of(context)!.settings.arguments as AvailableMeeting;
          return MeetingDetailScreen(meeting: meeting);
        },
        '/meeting_application': (context) {
          final meeting = ModalRoute.of(context)!.settings.arguments as AvailableMeeting;
          return MeetingApplicationScreen(meeting: meeting);
        },
        '/meeting_success': (context) {
          final meeting = ModalRoute.of(context)!.settings.arguments as AvailableMeeting;
          return MeetingSuccessScreen(meeting: meeting);
        },
        '/meeting_review': (context) {
          final meeting = ModalRoute.of(context)!.settings.arguments as AvailableMeeting;
          return MeetingReviewScreen(meeting: meeting);
        },
        '/meeting_create': (context) => MeetingCreateMultiStepScreen(),
        // ✅ 일일 기록 화면들 추가
        '/daily_record': (context) => EnhancedDailyRecordScreen(), // 메인 기록 화면
        '/diary_record': (context) => DiaryWriteEditScreen(),
        '/exercise_record': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
        '/exercise_dashboard': (context) => ExerciseDashboardScreen(),
        '/exercise_detail': (context) {
          final exercise = ModalRoute.of(context)!.settings.arguments as ExerciseLog;
          return ExerciseDetailScreen(exercise: exercise);
        },
        '/exercise_edit': (context) {
          final exercise = ModalRoute.of(context)!.settings.arguments as ExerciseLog;
          return ExerciseEditScreen(exercise: exercise);
        },
        '/reading_record': (context) => ReadingRecordScreen(),
        '/focus_timer': (context) => EnhancedDailyRecordScreen(), // 집중 타이머는 기록 화면에서 접근
        '/component_viewer': (context) => ComponentViewerScreen(),
        '/meeting_list_all': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return MeetingListAllScreen(
            initialCategory: args?['category'],
            sectionTitle: args?['sectionTitle'],
          );
        },
        '/sherpi_message_history': (context) => SherpiMessageHistoryScreen(),

      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
  
  /// 글로벌 Provider 초기화 메서드
  void _initializeGlobalProviders(WidgetRef ref) {
    try {
      // ✅ 7개 글로벌 Provider 초기화 순서대로
      
      // 1. 게임 시스템 초기화 (기초 데이터)
      ref.read(globalGameProvider);
      
      // 2. 사용자 데이터 초기화
      ref.read(globalUserProvider);
      
      // 3. 포인트 시스템 초기화
      ref.read(globalPointProvider);
      
      // 4. 칭호 시스템 초기화
      ref.read(globalUserTitleProvider);
      
      // 5. 퀘스트 시스템 V2 초기화
      ref.read(questProviderV2);
      
      // 6. 모임 시스템 초기화
      ref.read(globalMeetingProvider);
      
      // 7. 셰르피 시스템 초기화
      ref.read(sherpiProvider);
      
      // 8. 셰르피 관계 시스템 초기화
      ref.read(sherpiRelationshipProvider);
      
      // 9. 감정 분석 시스템 초기화
      ref.read(emotionAnalysisProvider);
      
      
    } catch (e) {
    }
  }
}
