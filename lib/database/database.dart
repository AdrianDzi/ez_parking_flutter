import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../storage/firebasestorageapi.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('usersTable');
  final CollectionReference ticketCollection =
      FirebaseFirestore.instance.collection('ticketsTable');
  final CollectionReference parkingCollection =
      FirebaseFirestore.instance.collection('parkingTable');

//#1
  Future setUserInformation(String uid, String email) async {
    return await userCollection.doc(uid).set({
      'userId': uid,
      'email': email,
      'name': "",
      'surname': "",
      'role': 'user',
    });
  }

//#2
  Future deleteUserFromDB(String uid) async {
    await FirebaseApi.deleteFile(uid);
    await userCollection.doc(uid).delete();
    return true;
  }

//#3
  Future modifyUserData(String name, String surname, String uid) async {
    var result = await userCollection.where('userId', isEqualTo: uid).get();
    return await userCollection.doc(uid).update({
      'name': name,
      'surname': surname,
      'userId': uid,
      'email': result.docs[0].get('email'),
      'role': result.docs[0].get('role'),
    });
  }

//#4
  Future addTicketToDB(String unique_id, String name, String user_id,
      DateTime start, DateTime end) async {
    return await ticketCollection.doc(unique_id).set({
      'ticketId': unique_id,
      'name': name,
      'userId': user_id,
      'startTime': start,
      'endTime': end,
    });
  }

//#5
  Future readUserTicketsFromDB(String user_id) async {
    return ticketCollection.where("userId", isEqualTo: user_id).get();
  }

//#6
  Future addParkingToDB(
      String longitude, String latitude, List<int> types) async {
    return await parkingCollection.doc(uid).set({
      'longitude': longitude,
      'latitude': latitude,
      'types': types,
    });
  }

//#7
  Future readUserTicketsFromDBbyTodaysDate(String user_id) async {
    DateTime now = new DateTime.now();
    return ticketCollection
        .where("userId", isEqualTo: user_id)
        .where('endTime', isGreaterThanOrEqualTo: now)
        .get();
  }

//#8
  Future getAllParkings() async {
    return await parkingCollection.get();
  }

  Future getSpecifiedParkingByID(String id) async {
    return await parkingCollection.doc(id).get();
  }
}
