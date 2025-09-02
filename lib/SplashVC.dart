import 'package:dhara_practical_task/HomeVC.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SplashVC extends StatelessWidget {
  const SplashVC({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnimatedSplashScreen(
      splash: Center(
        child: Image.asset(
          'assests/images/appLogo.png',
          width: 150,
          height: 150,
        ),
      ),
      nextScreen: HomeVC(),
      backgroundColor: Colors.white,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      duration: 100,

    );
  }
}
