import 'package:dhara_practical_task/Views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModel/UserViewModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Services/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
