import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_parking/models/parking_ticket.dart';
import 'package:ez_parking/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:ez_parking/navbar/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ez_parking/utils/palette.dart';
import 'package:ez_parking/database/database.dart';
import 'package:uuid/uuid.dart';
import '../../utils/profileButtonDecoration.dart';

class NewTicket extends StatefulWidget {
  @override
  NewTicketState createState() => new NewTicketState();
}

String formatDateTime(DateTime dateTime) =>
    DateFormat("yyyy-MM-dd HH:mm").format(dateTime);

Future<List<TableRow>> generateTicketInformation() async {
  List<TableRow> rows = [
    TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          child: const Text(
            "Name",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          child: const Text(
            "Start time",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          child: const Text(
            "End time",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    )
  ];

  QuerySnapshot ticketsData = await DatabaseService(uid: '')
      .readUserTicketsFromDBbyTodaysDate(
          FirebaseAuth.instance.currentUser!.uid);

  List<ParkingTicket> tickets = ticketsData.docs
      .map((e) => ParkingTicket(
          name: e["name"],
          startTime: e["startTime"].toDate(),
          endTime: e["endTime"].toDate()))
      .toList();

  tickets.sort((a, b) => a.startTime.isBefore(b.startTime) ? -1 : 1);
  tickets.removeWhere(((element) => element.startTime.isAfter(DateTime.now())));
  for (var ticket in tickets) {
    rows.add(TableRow(children: [
      Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          ticket.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          formatDateTime(ticket.startTime),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          formatDateTime(ticket.endTime),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ]));
  }
  return rows;
}

class NewTicketState extends State<NewTicket> {
  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now().add(const Duration(minutes: 15));
  var uuid = Uuid();

  void scheduleNotificationsTest(String text, DateTime date, String ticket_id) {
    var scheduledNotificationDateTime = date;
    flutterLocalNotificationsPlugin.schedule(
        ticket_id.hashCode,
        'Bilet parkingowy',
        text,
        scheduledNotificationDateTime,
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: NavBar(),
      backgroundColor: MyColors.steelTeal,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.white,
            height: 1.0,
          ),
        ),
        backgroundColor: MyColors.mountainMeadow,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          "Tickets",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.topLeft,
            child: const Text(
              "Current active tickets:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              height: 400,
              child: SingleChildScrollView(
                child: FutureBuilder<List<TableRow>>(
                    future: generateTicketInformation(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Table(
                          border: TableBorder.all(color: Colors.white),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: snapshot.requireData,
                        );
                      }
                      return Container();
                    }),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: raisedButtonStyleSmaller,
                  onPressed: () {},
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Scan ticket',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: raisedButtonStyleSmaller,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Add ticket',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    Widget cancelButton = TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    );
                    TextEditingController startDateController =
                        TextEditingController(
                            text: formatDateTime(startDateTime));

                    TextEditingController endDateController =
                        TextEditingController(
                      text: formatDateTime(endDateTime),
                    );

                    TextEditingController nameController =
                        TextEditingController(text: "Ticket");

                    Widget continueButton = TextButton(
                      child: const Text("Ok"),
                      onPressed: () async {
                        if (endDateTime.isBefore(startDateTime)) {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Invalid data"),
                                content: const Text(
                                    "Start time has to be before end time."),
                                actions: [
                                  TextButton(
                                    child: const Text("OK"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }

                        var uid = uuid.v4();
                        DatabaseService(uid: '').addTicketToDB(
                            uid,
                            nameController.text,
                            FirebaseAuth.instance.currentUser!.uid,
                            startDateTime,
                            endDateTime);
                        setState(() {}); // Update table
                        DateTime ticketDate = endDateTime;
                        String text =
                            'Twój bilet parkingowy kończy się za 10 minut!';
                        //UID TRZEBA BY NIE BYLO TAKIE SAMO
                        //BO WTEDY JEDNO NADPISUJE DRUGIE I WYSWIETLA SIE TYLKO TO 1MINUTE
                        DateTime notificationDate = DateTime(
                            ticketDate.year,
                            ticketDate.month,
                            ticketDate.day,
                            ticketDate.hour,
                            ticketDate.minute - 10,
                            ticketDate.second);
                        scheduleNotificationsTest(
                            text, notificationDate, uid + '10');

                        text = 'Twój bilet parkingowy kończy się za 1 minutę!';
                        notificationDate = DateTime(
                            ticketDate.year,
                            ticketDate.month,
                            ticketDate.day,
                            ticketDate.hour,
                            ticketDate.minute - 1,
                            ticketDate.second);
                        scheduleNotificationsTest(
                            text, notificationDate, uid + '1');
                        Navigator.pop(context);
                      },
                    );

                    // set up the AlertDialog
                    AlertDialog alert = AlertDialog(
                      title: const Text("Add ticket"),
                      scrollable: true,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: "Name",
                            ),
                            controller: nameController,
                          ),
                          TextField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.calendar_today),
                                labelText: "Start date and time",
                              ),
                              readOnly: true,
                              controller: startDateController,
                              onTap: () async {
                                DateTime? dateTime =
                                    await pickDateTime(context);
                                if (dateTime != null) {
                                  setState(() {
                                    startDateTime = dateTime;
                                    startDateController.text =
                                        formatDateTime(dateTime);
                                  });
                                }
                              }),
                          TextField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.calendar_today),
                                labelText: "End date and time",
                              ),
                              readOnly: true,
                              controller: endDateController,
                              onTap: () async {
                                DateTime? dateTime =
                                    await pickDateTime(context);
                                if (dateTime != null) {
                                  setState(() {
                                    endDateTime = dateTime;
                                    endDateController.text =
                                        formatDateTime(dateTime);
                                  });
                                }
                              }),
                        ],
                      ),
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<DateTime?> pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, pickedTime.hour, pickedTime.minute);
        return selectedDateTime;
      }
    }
    return null;
  }
}
