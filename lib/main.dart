import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/Services/notification_service.dart';
import 'package:send_snap/UI/Screens/add_expenses.dart';
import 'package:send_snap/UI/Screens/all_transactions.dart';
import 'package:send_snap/UI/Screens/budget.dart';
import 'package:send_snap/UI/Screens/export_data.dart';
import 'package:send_snap/UI/Screens/home_page.dart';
import 'package:send_snap/UI/Screens/import_data.dart';
import 'package:send_snap/UI/Screens/notification_list.dart';
import 'package:send_snap/UI/Screens/notifications_settings.dart';
import 'package:send_snap/UI/Screens/profile.dart';
import 'package:send_snap/UI/Screens/settiings.dart';
import 'package:send_snap/UI/Screens/splash_screen.dart';
import 'package:send_snap/UI/Screens/theme_settings.dart';
import 'package:send_snap/UI/theme/theme.dart';
import 'package:send_snap/UI/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  await NotificationService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'Send Snap',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return SplashScreen();
      },
    ),
    GoRoute(
      name: '/home',
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      name: '/transactions',
      path: '/transactions',
      builder: (BuildContext context, GoRouterState state) {
        return const Transactions();
      },
    ),
    GoRoute(
      name: '/addExpense',
      path: '/addExpense',
      builder: (BuildContext context, GoRouterState state) {
        return const AddExpensePage();
      },
    ),
    GoRoute(
      name: '/budget',
      path: '/budget',
      builder: (BuildContext context, GoRouterState state) {
        return const CreateBudgetPage();
      },
    ),
    GoRoute(
      name: '/profile',
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfilePage();
      },
    ),
    GoRoute(
      name: '/export',
      path: '/export',
      builder: (BuildContext context, GoRouterState state) {
        return const ExportDataPage();
      },
    ),
    GoRoute(
      name: '/import',
      path: '/import',
      builder: (BuildContext context, GoRouterState state) {
        return const ImportDataPage();
      },
    ),
    GoRoute(
      name: '/notifSettings',
      path: '/notifSettings',
      builder: (BuildContext context, GoRouterState state) {
        return const NotificationSettingsPage();
      },
    ),
    GoRoute(
      name: '/notifList',
      path: '/notifList',
      builder: (BuildContext context, GoRouterState state) {
        return const NotificationListPage();
      },
    ),
    GoRoute(
      name: '/settings',
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsPage();
      },
    ),
    GoRoute(
      name: '/themeSettings',
      path: '/themeSettings',
      builder: (BuildContext context, GoRouterState state) {
        return const ThemeSettingsPage();
      },
    ),
  ],
);
