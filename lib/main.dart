import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/UI/Screens/add_expenses.dart';
import 'package:send_snap/UI/Screens/all_transactions.dart';
import 'package:send_snap/UI/Screens/budget.dart';
import 'package:send_snap/UI/Screens/export_data.dart';
import 'package:send_snap/UI/Screens/home_page.dart';
import 'package:send_snap/UI/Screens/profile.dart';
import 'package:send_snap/UI/Screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Send Snap',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  // initialLocation: '/home',
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
  ],
);
