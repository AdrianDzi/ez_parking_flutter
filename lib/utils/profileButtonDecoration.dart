import 'package:ez_parking/utils/palette.dart';
import 'package:flutter/material.dart';

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.white,
  primary: MyColors.mountainMeadow,
  minimumSize: Size(165, 85),
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(25)),
  ),
  side: const BorderSide(
    width: 0.75, // the thickness
    color: Colors.black, // the color of the border
  ),
);

final ButtonStyle raisedButtonStyleSmaller = ElevatedButton.styleFrom(
  onPrimary: Colors.white,
  primary: MyColors.mountainMeadow,
  minimumSize: Size(160, 85),
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(25)),
  ),
  side: const BorderSide(
    width: 0.75, // the thickness
    color: Colors.black, // the color of the border
  ),
);

final ButtonStyle raisedDangerButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.white,
  primary: Colors.red.shade600,
  minimumSize: Size(165, 85),
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(25)),
  ),
  side: const BorderSide(
    width: 0.75, // the thickness
    color: Colors.black, // the color of the border
  ),
);
