import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_parking/auth_services/auth.dart';
import 'package:ez_parking/database/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ez_parking/utils/palette.dart';

import '../../utils/profileButtonDecoration.dart';

class EditData extends StatefulWidget {
  @override
  EditDataState createState() => new EditDataState();
}

class EditDataState extends State<EditData> {
  final AuthService auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String surname = "";
  int flag = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MyColors.steelTeal,
      appBar: AppBar(
        bottom: PreferredSize(
          child: Container(
            color: Colors.white,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(4.0),
        ),
        backgroundColor: MyColors.mountainMeadow,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          "Edit data",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      body: StreamBuilder(
          stream: DatabaseService(uid: '')
              .userCollection
              .where('userId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              var user = snapshot.data!.docs[0];
              if (flag == 0) {
                name = user.get('name').toString();
                surname = user.get('surname').toString();
                flag = 1;
              }
              return Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        initialValue: '${user.get('name').toString()}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9), fontSize: 20),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                  color: Colors.tealAccent)),
                          hintText: 'Name',
                          hintStyle: const TextStyle(color: Colors.white),
                          fillColor: Colors.white.withOpacity(0.3),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Colors.white70,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your name';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() => name = val);
                        },
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        initialValue: '${user.get('surname').toString()}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9), fontSize: 20),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                  color: Colors.tealAccent)),
                          hintText: 'Surname',
                          hintStyle: const TextStyle(color: Colors.white),
                          fillColor: Colors.white.withOpacity(0.3),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Colors.white70,
                          ),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter your surname' : null,
                        onChanged: (val) {
                          setState(() => surname = val);
                        },
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      Spacer(),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              MyColors.mountainMeadow),
                          minimumSize: MaterialStateProperty.all(Size(140, 35)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await DatabaseService(uid: '').modifyUserData(
                                name, surname, user.get('userId').toString());

                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.of(context).pop(true);
                                });
                                return AlertDialog(
                                  title: Text(
                                    'Zmieniono dane!',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: Text('Save data'),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
