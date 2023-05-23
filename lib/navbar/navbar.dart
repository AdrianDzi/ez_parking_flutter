import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_parking/auth_services/auth.dart';
import 'package:ez_parking/database/database.dart';
import 'package:ez_parking/layouts/homeScreen.dart';
import 'package:ez_parking/layouts/profile/profile.dart';
import 'package:ez_parking/layouts/tickets/addnewticket.dart';
import 'package:ez_parking/utils/palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

import '../storage/firebasestorageapi.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    return StreamBuilder(
        stream: DatabaseService(uid: '')
            .userCollection
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            var user = snapshot.data!.docs[0];
            var names;
            if (user.get('name').toString().isEmpty &&
                user.get('surname').toString().isEmpty) {
              names = "[Brak danych]";
            } else {
              names = user.get('name') + " " + user.get('surname');
            }
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text("${names}"),
                    accountEmail: Text("${user.get('email')}"),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: FutureBuilder(
                          future: _getImage(context,
                              "${FirebaseAuth.instance.currentUser!.uid}"),
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.data.toString() == "Scaffold") {
                              return Image.asset(
                                'assets/images/ez.png',
                                width: 90,
                                height: 90,
                                fit: BoxFit.fill,
                              );
                            } else {
                              return Container(
                                child: snapshot.data,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: MyColors.mountainMeadow,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.map),
                    title: Text("Main"),
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Profile"),
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileView(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.alarm_add),
                    title: Text("Add new ticket"),
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewTicket(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.local_parking),
                    title: Text("xyz"),
                    onTap: () async {
                      print("test");
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("Log out"),
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      await auth.signOut();
                    },
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Future<Widget> _getImage(BuildContext context, String imageName) async {
    late Image image;
    try {
      await FirebaseApi.loadImage(context, imageName).then((value) {
        image = Image.network(
          value.toString(),
          width: 90,
          height: 90,
          fit: BoxFit.fill,
        );
      });
    } catch (err) {
      return Scaffold();
    }
    return image;
  }
}
