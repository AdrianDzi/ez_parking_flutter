import 'package:ez_parking/models/parking_loot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../layouts/parking_view/parking_space_preview.dart';

class ParkingMarkerBuilder {
  static Marker create(
      LatLng point, ParkingLoot parkingLootInfo, Function setRouteCallback) {
    return Marker(
      width: 50,
      height: 50,
      point: point,
      builder: (context) => IconButton(
        onPressed: () async {
          print("ID parkingu to " + parkingLootInfo.uid.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParkingPreview(
                marker: point,
                id: parkingLootInfo.uid,
                setRouteCallback: setRouteCallback,
              ),
            ),
          );
          // await showDialog(
          //   context: context,
          //   builder: (BuildContext context) {
          //     return showParkingInformation(context);
          //   },
          // )
        },
        icon: Icon(
          Icons.local_parking,
          color: Colors.blueAccent,
          size: 40.0,
          semanticLabel: 'Parking ${parkingLootInfo.uid.toString()}',
        ),
      ),
    );
  }
}

AlertDialog showParkingInformation(BuildContext context) {
  return AlertDialog(
    title: const Text("Not implemented"),
    content: const Text("Parking details are not implemented yet."),
    actions: [
      TextButton(
        child: const Text("OK"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ],
  );
}
