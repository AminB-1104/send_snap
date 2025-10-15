import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/UI/Screens/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  Hive.registerAdapter(ExpenseModelAdapter());
  await Hive.openBox('expenses');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Send Snap',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
