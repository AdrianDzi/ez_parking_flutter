import 'package:ez_parking/auth_services/auth.dart';
import 'package:ez_parking/layouts/signUpScreen.dart';
import 'package:ez_parking/utils/color_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import '../reusable_widget.dart/reusable_widget.dart';
import 'homeScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService authService = AuthService();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  bool _passwordVisible = false;
  bool _validate = false;
  String _emailErrorMessage = '';
  String _passwordErrorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/backgrounds/SignInBackground.png'),
        fit: BoxFit.fill,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo_ez_app.png',
                    width: 140,
                    height: 140,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Login to EZ Parking",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _emailTextController,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                              color: Colors.tealAccent)),
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.3),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                      ),
                    ),
                    onChanged: (val) {
                      validateEmail(val);
                    },
                    cursorColor: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _emailErrorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextField(
                    controller: _passwordTextController,
                    obscureText: !_passwordVisible,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                              color: Colors.tealAccent)),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.3),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: hexStringToColor('#30ba8f'),
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    onChanged: (val) {
                      validatePassword(val);
                    },
                    cursorColor: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _passwordErrorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  signInSignUpButton(context, true, () async {
                    dynamic resValue = await authService.loginUser(
                        _emailTextController.text,
                        _passwordTextController.text);
                    if (resValue != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    }
                  }),
                  signUpOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _emailErrorMessage = "Email can not be empty";
      });
    } else if (!EmailValidator.validate(val, true)) {
      setState(() {
        _emailErrorMessage = "Invalid Email Address";
      });
    } else {
      setState(() {
        _emailErrorMessage = "";
      });
    }
  }

  void validatePassword(String val) {
    if (val.isEmpty) {
      setState(() {
        _passwordErrorMessage = "Password can not be empty";
      });
    } else {
      setState(() {
        _passwordErrorMessage = "";
      });
    }
  }

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  Row signUpOption() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Don't have account? ",
          style: TextStyle(color: Colors.white70)),
      GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()));
        },
        child: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
    ]);
  }
}
