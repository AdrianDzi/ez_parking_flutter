import 'package:ez_parking/database/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/my_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MyUser? userFromFirebaseUser(User? user) {
    return user != null ? MyUser(uid: user.uid) : null;
  }

  Stream<MyUser?> get user {
    return _auth.authStateChanges().map(userFromFirebaseUser);
  }

  Future loginUser(String email, String pass) async {
    try {
      UserCredential resValue =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);
      User? u = resValue.user;
      return userFromFirebaseUser(u);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerUser(String email, String pass) async {
    try {
      UserCredential resValue = await _auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      User? u = resValue.user;
      await u?.sendEmailVerification();
      await DatabaseService(uid: u!.uid).setUserInformation(u.uid, email);
      return userFromFirebaseUser(u);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future deleteUser(String uid) async {
    User user = await _auth.currentUser!;
    await user.delete();
    await DatabaseService(uid: '').deleteUserFromDB(uid);
    return true;
  }
}
