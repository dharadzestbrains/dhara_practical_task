import 'package:dhara_practical_task/SplashVC.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModel/UserViewModel.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashVC(),
    );
  }
}
