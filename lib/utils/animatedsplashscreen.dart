import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:ez_parking/wrapper/wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Container(
        child: Image.asset(
          'assets/images/logo_ez_app.png',
        ),
      ),
      nextScreen: const Wrapper(),
      splashIconSize: 150,
      duration: 2000,
      splashTransition: SplashTransition.rotationTransition,
    );
  }
}
