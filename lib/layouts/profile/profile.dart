import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_parking/auth_services/auth.dart';
import 'package:ez_parking/database/database.dart';
import 'package:ez_parking/layouts/profile/editing.dart';
import 'package:ez_parking/layouts/tickets/ticketshistory.dart';
import 'package:ez_parking/navbar/navbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ez_parking/utils/palette.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import '../../storage/firebasestorageapi.dart';
import '../../utils/profileButtonDecoration.dart';

class ProfileView extends StatefulWidget {
  @override
  ProfileViewState createState() => new ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  late File file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(),
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
            "Profile",
            style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
          ),
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
              stream: DatabaseService(uid: '')
                  .userCollection
                  .where('userId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  var user = snapshot.data!.docs[0];
                  var names;
                  var role;
                  if (user.get('name').toString().isEmpty &&
                      user.get('surname').toString().isEmpty) {
                    names = "[Brak danych]";
                  } else {
                    names = user.get('name') + " " + user.get('surname');
                  }
                  if (user.get('role') == "user") {
                    role = "User";
                  } else {
                    role = "Admin";
                  }
                  return Stack(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 10),
                                margin: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            1 /
                                            10),
                                decoration: BoxDecoration(
                                  color: MyColors.mountainMeadow,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                      color: Colors.black, width: 0.75),
                                ),
                                width:
                                    MediaQuery.of(context).size.width * 4 / 5,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    FutureBuilder(
                                      future: _getImage(context,
                                          "${FirebaseAuth.instance.currentUser!.uid}"),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<Widget> snapshot) {
                                        if (snapshot.data.toString() ==
                                            "Scaffold") {
                                          return Container(
                                            height: 135,
                                            width: 135,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 0.75,
                                              ),
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/ez.png'),
                                                fit: BoxFit.fill,
                                              ),
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            height: 135,
                                            width: 135,
                                            child: snapshot.data,
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('${role}',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('${names}',
                                        style: TextStyle(
                                            fontSize: 22, color: Colors.white)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('${user.get('email')}',
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.white)),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Colors.white,
                                height: 75,
                                thickness: 1,
                                indent: 45,
                                endIndent: 45,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: raisedButtonStyle,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TicketsHistory(),
                                        ),
                                      );
                                    },
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text('Tickets history',
                                            style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: raisedButtonStyle,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditData(),
                                        ),
                                      );
                                    },
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text('Edit data',
                                            style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: raisedButtonStyle,
                                    onPressed: () async {
                                      XFile? result;

                                      _openGallery() async {
                                        result = await ImagePicker().pickImage(
                                            maxHeight: 100,
                                            source: ImageSource.gallery);
                                        setState(() {});
                                      }
                                      // zostawic to bo to backup w razie co dzialajacej wersji

                                      // final result = await FilePicker.platform
                                      //     .pickFiles(allowMultiple: false);
                                      //final path = result!.files.single.path;
                                      await _openGallery();
                                      final path = result?.path;

                                      setState(() {
                                        file = File(path!);
                                      });
                                      print(file);
                                      getFilePath();
                                      if (path != null) {
                                        saveFile(path);
                                        Image image = Image.file(File(path));
                                      }

                                      //readFile();

                                      final destination =
                                          "${FirebaseAuth.instance.currentUser!.uid}";
                                      FirebaseApi.uploadFile(destination, file);

                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            Future.delayed(Duration(seconds: 1),
                                                () {
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                            });
                                            return AlertDialog(
                                              title: Text(
                                                'Avatar changed!',
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          });
                                      await Future.delayed(
                                          Duration(seconds: 1));
                                      Navigator.pop(context);
                                    },
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text('Change avatar',
                                            style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                      style: raisedDangerButtonStyle,
                                      onPressed: () async {
                                        Widget cancelButton = TextButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                        Widget continueButton = TextButton(
                                          child: Text("Continue"),
                                          onPressed: () async {
                                            Navigator.of(context).popUntil(
                                                (route) => route.isFirst);
                                            await AuthService().deleteUser(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                                    .toString());
                                          },
                                        );

                                        // set up the AlertDialog
                                        AlertDialog alert = AlertDialog(
                                          title: Text("Alert"),
                                          content: Text(
                                              "Do you want to delete your account?"),
                                          actions: [
                                            cancelButton,
                                            continueButton,
                                          ],
                                        );

                                        // show the dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      },
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text('Delete account',
                                              style: TextStyle(fontSize: 16)),
                                        ],
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                            ],
                          )),
                    ],
                  );
                } else {
                  return Container();
                }
              }),
        ));
  }

  Future<Widget> _getImage(BuildContext context, String imageName) async {
    late Widget image;
    try {
      await FirebaseApi.loadImage(context, imageName).then((value) {
        image = Container(
          height: 135,
          width: 135,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 0.75,
            ),
            image: DecorationImage(
              image: NetworkImage(value.toString()),
              fit: BoxFit.fill,
            ),
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        );
      });
    } catch (err) {
      return Scaffold();
    }
    return image;
  }

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/avatar.png'; // 3
    print(filePath);
    return filePath;
  }

  void saveFile(String path) async {
    File file = File(await getFilePath()); // 1
    File imagefile = File(path); //convert Path to File
    Uint8List imagebytes = await imagefile.readAsBytes(); //convert to bytes
    String base64string = base64.encode(imagebytes); //conve
    file.writeAsBytes(imagebytes);
  }
}
