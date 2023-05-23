import 'package:ez_parking/auth_services/auth.dart';
import 'package:ez_parking/layouts/profile/editing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

import '../reusable_widget.dart/reusable_widget.dart';
import 'homeScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService authService = AuthService();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordConfirmTextController =
      TextEditingController();
  bool _passwordVisible = false;
  bool success = false;
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  var _text = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/backgrounds/SignUpBackground.png'),
        fit: BoxFit.fill,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "SignUp",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Form(
                key: _form,
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/logo_ez_app.png',
                      width: 140,
                      height: 140,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Register at EZ Parking",
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
                        fillColor: Colors.white.withOpacity(0.3),
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.white70,
                        ),
                      ),
                      cursorColor: Colors.white,
                    ),
                    SizedBox(
                      height: 20,
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
                        hintStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white.withOpacity(0.3),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.white70,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.tealAccent,
                            // color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      cursorColor: Colors.white,
                    ),
                    FlutterPwValidator(
                      controller: _passwordTextController,
                      minLength: 6,
                      uppercaseCharCount: 1,
                      numericCharCount: 1,
                      specialCharCount: 1,
                      normalCharCount: 3,
                      width: 400,
                      height: 150,
                      onSuccess: () {
                        setState(() {
                          success = true;
                        });
                        print("MATCHED");
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Password is matched")));
                      },
                      onFail: () {
                        setState(() {
                          success = false;
                        });
                        print("NOT MATCHED");
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _passwordConfirmTextController,
                      obscureText: !_passwordVisible,
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                                color: Colors.tealAccent)),
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(color: Colors.white),
                        fillColor: Colors.white.withOpacity(0.3),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.white70,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.tealAccent,
                            // color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      // autocorrect: ,
                      cursorColor: Colors.white,
                      validator: (value) {
                        if (value != _passwordTextController.text) {
                          return 'Passwords are not same';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    signInSignUpButton(context, false, () async {
                      if (_form.currentState!.validate()) {
                        if (_passwordTextController.text ==
                            _passwordConfirmTextController.text) {
                          dynamic resValue = await authService.registerUser(
                              _emailTextController.text,
                              _passwordTextController.text);
                          if (resValue != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditData()),
                            );
                            showDialog(
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 4), () {
                                  Navigator.of(context).pop(true);
                                });
                                return AlertDialog(
                                  title: Text(
                                    'Uzupełnij swoje dane w profilu użytkownika!',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            );
                          }
                        }
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
