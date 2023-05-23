import 'package:ez_parking/utils/color_utils.dart';
import 'package:flutter/material.dart';

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.0)),
    child: ElevatedButton(
      onPressed: () async {
        onTap();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: hexStringToColor('#30ba8f'),
        shape: StadiumBorder(),
      ),
      child: Text(
        isLogin ? 'LOG IN' : 'SIGN UP',
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}
