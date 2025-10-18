
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/UI/Screens/home_page.dart';
import 'package:send_snap/UI/Screens/pick_image_camera.dart';
import 'package:send_snap/UI/Screens/pick_image_gallery.dart';

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
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      name: '/imagegallery',
      path: '/imagegallery',
      builder: (BuildContext context, GoRouterState state) {
        return const ImagePickerGallery();
      },
    ),
    GoRoute(
      name: '/imagecamera',
      path: '/imagecamera',
      builder: (BuildContext context, GoRouterState state) {
        return const ImagePickerCamera();
      },
    ),
  ],
);
