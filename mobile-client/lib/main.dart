import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/users/pages/user_list_page.dart';
import 'features/users/pages/user_detail_page.dart';
import 'features/recording/pages/recording_page.dart';
import 'features/recording/pages/preview_page.dart';
import 'features/splash/pages/splash_page.dart';
import 'features/whisper/pages/whisper_list_page.dart';
import 'features/home/pages/home_page.dart';
import 'features/home/pages/story_viewer_page.dart';
import 'features/home/models/home_models.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const UserListPage(),
    ),
    GoRoute(
      path: '/users/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return UserDetailPage(userId: userId);
      },
    ),
    GoRoute(
      path: '/recording',
      builder: (context, state) => const RecordingPage(),
    ),
    GoRoute(
      path: '/recording/preview',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PreviewPage(
          filePath: extra['filePath'] as String,
          fileName: extra['fileName'] as String,
          duration: extra['duration'] as Duration,
        );
      },
    ),
    GoRoute(
      path: '/dev/whispers',
      builder: (context, state) => const WhisperListPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/story-viewer',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final userStory = extra['story'] as UserStory;
        return StoryViewerPage(story: userStory);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Voicelet',
      theme: AppTheme.themeData,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
      ],
      routerConfig: _router,
    );
  }
}
