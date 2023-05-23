import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez_parking/database/database.dart';
import 'package:ez_parking/layouts/parking_view/parking_space_preview.dart';
import 'package:ez_parking/components/parkingMarker.dart';
import 'package:ez_parking/forms/newparkingform.dart';
import 'package:ez_parking/layouts/sigInScreen.dart';
import 'package:ez_parking/models/parking_loot.dart';
import 'package:ez_parking/navbar/navbar.dart';
import 'package:ez_parking/utils/openroute_wrapper.dart';
import 'package:ez_parking/utils/palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final List<LatLng> currentRoute;
  const HomeScreen({super.key, this.currentRoute = const []});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<LatLng> currentRoute;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    currentRoute = widget.currentRoute;
  }

  void setRoute(List<LatLng> newRoute) {
    setState(() {
      currentRoute = newRoute;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> _markers = [];
    return Scaffold(
      drawer: NavBar(),
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
          "EZ Parking",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: StreamBuilder(
          stream: DatabaseService(uid: '').parkingCollection.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              _markers.clear();
              for (var result in snapshot.data!.docs) {
                String log = result.get('longitude');
                String lat = result.get('latitude');
                LatLng pos = LatLng(double.parse(lat), double.parse(log));
                String id = result.id;
                _markers.add(
                  ParkingMarkerBuilder.create(
                    pos,
                    ParkingLoot(uid: id),
                    setRoute,
                  ),
                );
              }
              return FlutterMap(
                options: MapOptions(
                    center: LatLng(51.7663, 19.4776),
                    zoom: 13,
                    maxZoom: 18.0,
                    interactiveFlags:
                        InteractiveFlag.all & ~InteractiveFlag.rotate,
                    onLongPress: (tapPosition, point) async {
                      final RenderObject? overlay =
                          Overlay.of(context)?.context.findRenderObject();
                      final result = await showMenu(
                        context: context,
                        position: RelativeRect.fromRect(
                            Rect.fromLTWH(tapPosition.global.dx,
                                tapPosition.global.dy, 30, 30),
                            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                                overlay.paintBounds.size.height)),
                        items: [
                          const PopupMenuItem(
                            value: 'find_nearest',
                            child: Text('Find nearest parking'),
                          ),
                          const PopupMenuItem(
                            value: 'create_parking',
                            child: Text('Add parking'),
                          ),
                        ],
                      );
                      if (result == "create_parking") {
                        createParkingAlert(context, point);
                      } else if (result == "find_nearest") {
                        await findNearestParkingPlaces(
                            context, _markers, tapPosition, point);
                      }
                    }),
                nonRotatedChildren: [
                  AttributionWidget.defaultWidget(
                    source: 'OpenStreetMap contributors',
                    onSourceTapped: () {},
                  ),
                ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  PolylineLayer(
                    polylineCulling: false,
                    polylines: [
                      Polyline(
                        points: currentRoute,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                  MarkerLayer(markers: _markers),
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<void> findNearestParkingPlaces(BuildContext context,
      List<Marker> _markers, var tapPosition, LatLng point) async {
    List<LatLng> destinations = _markers.map((marker) => marker.point).toList();
    List<LatLng> nearest = OpenRouteWrapper.getNearest(point, destinations, 3);
    LatLng currentPos = await OpenRouteWrapper.getCurrentPos();

    List<String> nearestNames = (await Future.wait(nearest
            .map((e) async => await OpenRouteWrapper.getGeocodeFromLatLng(e))))
        .toList();

    List<PopupMenuEntry<dynamic>> nearestToSelect = nearest
        .asMap()
        .map((i, e) {
          return MapEntry(
              i,
              PopupMenuItem(
                value: i.toString(),
                child: Text(nearestNames[i]),
              ));
        })
        .values
        .toList();

    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();
    final result = await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            Rect.fromLTWH(tapPosition.global.dx, tapPosition.global.dy, 30, 30),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),
        items: nearestToSelect);

    if (result != null) {
      final value = int.tryParse(result);
      if (value != null) {
        setRoute(await OpenRouteWrapper.getRoute(
            currentPos, nearest.elementAt(value)));
      }
    }
  }

  void createParkingAlert(BuildContext context, LatLng point) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewParkingForm(marker: point),
          ),
        );
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Do you want to create parking here?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
