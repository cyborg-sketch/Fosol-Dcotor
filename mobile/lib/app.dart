import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/camera/camera_screen.dart';
import 'features/dashboard/trend_dashboard_screen.dart';
import 'features/diagnosis/analyzing_screen.dart';
import 'features/diagnosis/diagnosis_result_screen.dart';
import 'features/field_worker/field_worker_queue_screen.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/treatment/treatment_screen.dart';
import 'features/voice/voice_screen.dart';

final _router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/camera', builder: (_, __) => const CameraScreen()),
    GoRoute(path: '/voice', builder: (_, __) => const VoiceScreen()),
    GoRoute(
      path: '/analyzing',
      builder: (context, state) => AnalyzingScreen(input: state.extra),
    ),
    GoRoute(
      path: '/diagnosis/:id',
      builder: (context, state) {
        final data = state.extra;
        if (data is Map) {
          return DiagnosisResultScreen.fromApi(Map<String, dynamic>.from(data));
        }
        return const DiagnosisResultScreen(); // design-preview fallback, no live data
      },
    ),
    GoRoute(
      path: '/treatment',
      builder: (context, state) {
        final data = state.extra;
        if (data is Map) {
          return TreatmentScreen.fromExtra(data);
        }
        return const TreatmentScreen(); // design-preview fallback, no live data
      },
    ),
    GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/field-worker', builder: (_, __) => const FieldWorkerQueueScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const TrendDashboardScreen()),
  ],
);

class FasolDoctorApp extends StatelessWidget {
  const FasolDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fasol Doctor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
