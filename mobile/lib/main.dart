import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'controllers/app_controller.dart';
import 'core/df_ui.dart';
import 'core/services/notification_service.dart';
import 'core/services/signalr_service.dart';
import 'translations/languages.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'pages/auth/views/login_view.dart';
import 'pages/auth/views/subscription_expired_view.dart';
import 'pages/notifications/views/notifications_view.dart';
import 'pages/profile/views/profile_view.dart';
import 'pages/settings/views/settings_view.dart';
import 'pages/stock/views/stock_view.dart';
import 'pages/patients/views/patient_profile_view.dart';
import 'pages/secretaires/views/secretaires_view.dart';
import 'pages/admin/views/admin_dashboard_view.dart';
import 'pages/admin/views/cabinets_management_view.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  await dotenv.load(fileName: '.env.$env');

  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('[Notifications] init failed: $e');
  }

  try {
    await SignalRService.instance.init();
    // Surface every real-time notification as a local OS notification,
    // regardless of which screen is currently open.
    SignalRService.instance.notificationEventsStream.stream.listen((e) {
      NotificationService.show(
        title: e.title.isEmpty ? 'Notification' : e.title,
        body: e.description,
        id: (int.tryParse(e.id) ?? e.id.hashCode).abs() % 2147483647,
      );
    });
  } catch (e) {
    debugPrint('[SignalR] init failed: $e');
  }

  try {
    await initializeDateFormatting('fr_FR');
  } catch (_) {}

  Get.put(AppController());
  runApp(const DentiFlowApp());
}

class DentiFlowApp extends StatelessWidget {
  const DentiFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (AppController ctrl) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DentiFlow',
          translations: Languages(),
          locale: ctrl.locale,
          fallbackLocale: const Locale('fr', 'FR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'),
            Locale('en', 'US'),
          ],
          themeMode: ctrl.themeMode,
          theme: DfColors.light(),
          darkTheme: DfColors.dark(),
          initialRoute: '/splash',
          routes: {
            '/splash': (_) => const SplashScreen(),
            '/login': (_) => const LoginView(),
            '/home': (_) => const HomeScreen(),
            '/subscription-expired': (_) => const SubscriptionExpiredView(),
            '/notifications': (_) => const NotificationsView(),
            '/profile': (_) => const ProfileView(),
            '/settings': (_) => const SettingsView(),
            '/stock': (_) => const StockView(),
            '/patient-profile': (_) => const PatientProfileView(),
            '/staff': (_) => const SecretairesView(),
            '/admin': (_) => const AdminDashboardView(),
            '/admin/cabinets': (_) => const CabinetsManagementView(),
          },
        );
      },
    );
  }
}
