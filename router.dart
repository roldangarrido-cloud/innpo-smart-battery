import 'package:go_router/go_router.dart';

import '../features/battery/presentation/screens/alarms_screen.dart';
import '../features/battery/presentation/screens/battery_tab_scaffold.dart';
import '../features/battery/presentation/screens/demo_mode_screen.dart';
import '../features/battery/presentation/screens/technical_mode_screen.dart';
import '../features/bluetooth/presentation/bluetooth_scan_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/reports/presentation/report_preview_screen.dart';
import '../features/settings/presentation/app_settings_screen.dart';
import '../features/support/presentation/offline_help_screen.dart';
import '../features/support/presentation/remote_diagnostic_consent_screen.dart';
import '../features/support/presentation/remote_diagnostic_finished_screen.dart';
import '../features/support/presentation/remote_diagnostic_intro_screen.dart';
import '../features/support/presentation/remote_diagnostic_session_screen.dart';
import '../features/support/presentation/support_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/splash',
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const BluetoothScanScreen(),
    ),
    GoRoute(
      path: '/battery/:id',
      builder: (context, state) => BatteryTabScaffold(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
        initialIndex: 0,
      ),
    ),
    GoRoute(
      path: '/battery/:id/cells',
      builder: (context, state) => BatteryTabScaffold(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
        initialIndex: 1,
      ),
    ),
    GoRoute(
      path: '/battery/:id/alarms',
      builder: (context, state) => AlarmsScreen(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
      ),
    ),
    GoRoute(
      path: '/battery/:id/history',
      builder: (context, state) => BatteryTabScaffold(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
        initialIndex: 2,
      ),
    ),
    GoRoute(
      path: '/battery/:id/diagnostic',
      builder: (context, state) => BatteryTabScaffold(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
        initialIndex: 3,
      ),
    ),
    GoRoute(
      path: '/battery/:id/settings',
      builder: (context, state) => BatteryTabScaffold(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
        initialIndex: 4,
      ),
    ),
    GoRoute(
      path: '/battery/:id/status',
      redirect: (context, state) =>
          '/battery/${state.pathParameters['id'] ?? 'mock-battery-1'}',
    ),
    GoRoute(
      path: '/battery/:id/technical',
      builder: (context, state) => TechnicalModeScreen(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
      ),
    ),
    GoRoute(
      path: '/reports/:id',
      builder: (context, state) => ReportPreviewScreen(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
      ),
    ),
    GoRoute(
      path: '/remote-diagnostic/:id',
      builder: (context, state) => RemoteDiagnosticIntroScreen(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
      ),
    ),
    GoRoute(
      path: '/remote-diagnostic/:id/consent',
      builder: (context, state) => RemoteDiagnosticConsentScreen(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
      ),
    ),
    GoRoute(
      path: '/remote-diagnostic/:id/session',
      builder: (context, state) => RemoteDiagnosticSessionScreen(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
      ),
    ),
    GoRoute(
      path: '/remote-diagnostic/:id/finished',
      builder: (context, state) => RemoteDiagnosticFinishedScreen(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
      ),
    ),
    GoRoute(
      path: '/support/:id',
      builder: (context, state) => SupportScreen(
        batteryId: state.pathParameters['id'] ?? 'mock-battery-1',
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const AppSettingsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const OfflineHelpScreen(),
    ),
    GoRoute(
      path: '/demo',
      builder: (context, state) => const DemoModeScreen(),
    ),
  ],
);
