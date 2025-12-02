import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/map_screen.dart';
import '../screens/station/station_list_screen.dart';
import '../screens/station/station_detail_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_confirmation_screen.dart';
import '../screens/booking/booking_detail_screen.dart';
import '../screens/charging/scan_qr_screen.dart';
import '../screens/charging/active_session_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/ev_management_screen.dart';
import '../screens/profile/add_ev_screen.dart';
import '../screens/profile/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String map = '/map';
  static const String stationList = '/stations';
  static const String stationDetail = '/station/:id';
  static const String booking = '/booking/:stationId/:chargerId';
  static const String bookingConfirmation = '/booking-confirmation/:bookingId';
  static const String bookingDetail = '/booking-detail/:bookingId';
  static const String scanQr = '/scan-qr';
  static const String activeSession = '/session/:sessionId';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String evManagement = '/ev-management';
  static const String addEv = '/add-ev';
  static const String editEv = '/edit-ev/:evId';
  static const String settings = '/settings';

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: map,
        name: 'map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: stationList,
        name: 'station-list',
        builder: (context, state) => const StationListScreen(),
      ),
      GoRoute(
        path: stationDetail,
        name: 'station-detail',
        builder: (context, state) {
          final stationId = state.pathParameters['id']!;
          return StationDetailScreen(stationId: stationId);
        },
      ),
      GoRoute(
        path: booking,
        name: 'booking',
        builder: (context, state) {
          final stationId = state.pathParameters['stationId']!;
          final chargerId = state.pathParameters['chargerId']!;

          return BookingScreen(stationId: stationId, chargerId: chargerId);
        },
      ),
      GoRoute(
        path: bookingConfirmation,
        name: 'booking-confirmation',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingConfirmationScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: bookingDetail,
        name: 'booking-detail',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingDetailScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: scanQr,
        name: 'scan-qr',
        builder: (context, state) {
          final bookingId = state.uri.queryParameters['bookingId'];
          return ScanQrScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: activeSession,
        name: 'active-session',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return ActiveSessionScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: evManagement,
        name: 'ev-management',
        builder: (context, state) => const EvManagementScreen(),
      ),
      GoRoute(
        path: addEv,
        name: 'add-ev',
        builder: (context, state) => const AddEvScreen(),
      ),
      GoRoute(
        path: editEv,
        name: 'edit-ev',
        builder: (context, state) {
          final evId = state.pathParameters['evId']!;
          return AddEvScreen(evId: evId);
        },
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
