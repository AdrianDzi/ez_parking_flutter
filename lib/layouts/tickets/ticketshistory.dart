import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_parking/navbar/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ez_parking/utils/palette.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../utils/profileButtonDecoration.dart';

class TicketsHistory extends StatefulWidget {
  @override
  TicketsHistoryState createState() => new TicketsHistoryState();
}

class TicketsHistoryState extends State<TicketsHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Tickets History",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      body: StreamBuilder(
          stream: DatabaseService(uid: '')
              .ticketCollection
              .where('userId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .orderBy('startTime', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot2) {
            if (!snapshot2.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView(
              padding: EdgeInsets.only(top: 20),
              children: snapshot2.data!.docs.map((document) {
                Timestamp temp = document['startTime'];
                DateTime date = temp.toDate();
                DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss');
                DateTime temp2 = displayFormater.parse(date.toString());
                DateFormat serverFormater = DateFormat('dd-MM-yyyy HH:mm');
                String dateDisplay = serverFormater.format(temp2);
                temp = document['endTime'];
                date = temp.toDate();
                temp2 = displayFormater.parse(date.toString());
                String dateDisplay2 = serverFormater.format(temp2);
                return Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 4 / 5,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      decoration: BoxDecoration(
                          color: MyColors.mountainMeadow.withOpacity(0.8),
                          border: Border.all(
                              width: 3,
                              color: MyColors.mountainMeadow.withOpacity(0.8)),
                          borderRadius: BorderRadius.all(Radius.circular(45))),
                      child: Column(
                        children: [
                          Text(
                            '${document['name']}',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Start: $dateDisplay",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "End: $dateDisplay2",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                );
              }).toList(),
            );
          }),
    );
  }
}
