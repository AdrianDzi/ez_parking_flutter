import 'package:ez_parking/layouts/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layouts/homeScreen.dart';
import '../layouts/sigInScreen.dart';
import '../models/my_user.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);

    if (user == null) {
      return SignInScreen();
    } else {
      return HomeScreen();
    }
    // return home or auth
  }
}
