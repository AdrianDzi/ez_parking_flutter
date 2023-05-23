import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_parking/database/database.dart';
import 'package:ez_parking/utils/openroute_wrapper.dart';
import 'package:ez_parking/utils/profileButtonDecoration.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../navbar/navbar.dart';
import '../../utils/palette.dart';

class ParkingPreview extends StatefulWidget {
  const ParkingPreview(
      {required this.marker, required this.id, required this.setRouteCallback});

  final LatLng marker;
  final String id;
  final Function setRouteCallback;
  @override
  ParkingPreviewState createState() => new ParkingPreviewState();
}

class ParkingPreviewState extends State<ParkingPreview> {
  List<Marker> my_place = [];
  @override
  void initState() {
    my_place.add(
      Marker(
        builder: (context) => Icon(
          Icons.local_parking,
          color: Colors.blueAccent,
          size: 40.0,
        ),
        point: widget.marker,
      ),
    );
  }

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
          "Parking info",
          style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
        ),
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: MyColors.mountainMeadow,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Center(
                  child: Container(
                    color: Colors.white,
                    width: 300.0,
                    height: 500.0,
                    child: FlutterMap(
                      options: MapOptions(
                        center: widget.marker,
                        zoom: 13,
                        maxZoom: 18.0,
                        interactiveFlags:
                            InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(markers: my_place),
                      ],
                    ),
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.map,
              color: Colors.white,
            ),
            label: Text('map', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 70,
              alignment: Alignment.center,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder(
                    stream:
                        DatabaseService(uid: '').parkingCollection.snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        print("hasdata");
                        String log = "";
                        String lat = "";
                        List<dynamic> types = [];
                        for (var result in snapshot.data!.docs) {
                          log = result.get('longitude');
                          lat = result.get('latitude');
                          types = result.get('types');
                          if (result.id == widget.id) break;
                        }
                        int i = 0;
                        for (var t1 in types) {
                          i += 1;
                        }
                        Widget temp1 = Row(
                          children: [
                            Visibility(
                              visible: types.contains(0),
                              child: Container(
                                height: 70,
                                width: 70,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Image.asset(
                                      'assets/parkingicons/parking_s.png'),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: types.contains(1),
                              child: Container(
                                height: 70,
                                width: 70,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Image.asset(
                                      'assets/parkingicons/parking_m.png'),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: types.contains(2),
                              child: Container(
                                height: 70,
                                width: 70,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Image.asset(
                                      'assets/parkingicons/parking_h.png'),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: types.contains(3),
                              child: Container(
                                height: 70,
                                width: 70,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Image.asset(
                                      'assets/parkingicons/ikona_niep.png'),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: types.contains(4),
                              child: Container(
                                height: 70,
                                width: 70,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Image.asset(
                                      'assets/parkingicons/ikony_rodzina.png'),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: types.contains(5),
                              child: Container(
                                height: 70,
                                width: 70,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Image.asset(
                                      'assets/parkingicons/warning.png'),
                                ),
                              ),
                            ),
                          ],
                        );
                        return temp1;
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            StreamBuilder(
              stream: DatabaseService(uid: '').parkingCollection.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  print("hasdata");
                  String log = "";
                  String lat = "";
                  List<dynamic> types = [];
                  for (var result in snapshot.data!.docs) {
                    log = result.get('longitude');
                    lat = result.get('latitude');
                    types = result.get('types');
                    if (result.id == widget.id) break;
                  }
                  String wielkosc = "";
                  if (types.contains(0)) wielkosc = "Small";
                  if (types.contains(1)) wielkosc = "Medium";
                  if (types.contains(2)) wielkosc = "Big";

                  bool options = false;
                  if (types.contains(3) ||
                      types.contains(4) ||
                      types.contains(5)) options = true;
                  List<String> str = [];
                  if (types.contains(3)) str.add("Disability parking place");
                  if (types.contains(4)) str.add("Family friendly");
                  if (types.contains(5)) str.add("Dangerzone!!!");
                  Widget temp1 = Container(
                    child: Column(
                      children: [
                        Text(
                          "Size of parking",
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          wielkosc,
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontStyle: FontStyle.italic),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Visibility(
                          visible: options == true,
                          child: Text(
                            "Other options",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                        ),
                        Visibility(
                          visible: options == true,
                          child: Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: str.map((strone) {
                                return Row(children: [
                                  Text(
                                    "\u2022",
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ), //bullet text
                                  SizedBox(
                                    width: 10,
                                  ), //space between bullet and text
                                  Expanded(
                                    child: Text(
                                      strone,
                                      style: TextStyle(
                                          fontSize: 26, color: Colors.white),
                                    ), //text
                                  )
                                ]);
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                  return temp1;
                }
                return Container();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: raisedButtonStyleSmaller,
                    onPressed: () async {
                      LatLng currentPos =
                          await OpenRouteWrapper.getCurrentPos();
                      List<LatLng> route = await OpenRouteWrapper.getRoute(
                          currentPos, widget.marker);
                      widget.setRouteCallback(route);
                      Navigator.pop(context);
                    },
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Plan a route',
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
                          'Go back',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
