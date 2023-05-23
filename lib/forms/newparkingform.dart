import 'package:ez_parking/layouts/homeScreen.dart';
import 'package:ez_parking/navbar/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ez_parking/utils/palette.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../utils/profileButtonDecoration.dart';
import '../components/parkingMarker.dart';
import '../database/database.dart';
import '../models/parking_loot.dart';

class NewParkingForm extends StatefulWidget {
  const NewParkingForm({required this.marker});

  final LatLng marker;
  @override
  NewParkingFormState createState() => new NewParkingFormState();
}

class NewParkingFormState extends State<NewParkingForm> {
  List<Widget> icons = <Widget>[
    Container(
      height: 100,
      width: 100,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Image.asset('assets/parkingicons/parking_s.png'),
      ),
    ),
    Container(
      height: 100,
      width: 100,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Image.asset('assets/parkingicons/parking_m.png'),
      ),
    ),
    Container(
      height: 100,
      width: 100,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Image.asset('assets/parkingicons/parking_h.png'),
      ),
    ),
  ];
  List<Widget> options = <Widget>[
    Container(
      height: 100,
      width: 100,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Image.asset('assets/parkingicons/ikona_niep.png'),
      ),
    ),
    Container(
      height: 100,
      width: 100,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Image.asset('assets/parkingicons/ikony_rodzina.png'),
      ),
    ),
    Container(
      height: 100,
      width: 100,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Image.asset('assets/parkingicons/warning.png'),
      ),
    ),
  ];
  final List<bool> _selectedOptions = <bool>[false, false, false];
  final List<bool> _selectedSize = <bool>[false, true, false];
  List<Marker> my_place = [];
  bool vertical = false;

  var uuid = Uuid();

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
          "New parking",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
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
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Choose size of parking',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Small                     Medium                      Big',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  child: ToggleButtons(
                    borderWidth: 3,
                    borderColor: MyColors.mountainMeadow,
                    direction: vertical ? Axis.vertical : Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0; i < _selectedSize.length; i++) {
                          _selectedSize[i] = i == index;
                        }
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: MyColors.mountainMeadow,
                    selectedColor: Colors.white,
                    fillColor: Colors.blue[200],
                    color: Colors.blue[400],
                    isSelected: _selectedSize,
                    children: icons,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  'Choose other options',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Disability                      Family                     Dangerzone',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ToggleButtons(
                  borderWidth: 3,
                  borderColor: MyColors.mountainMeadow,
                  direction: vertical ? Axis.vertical : Axis.horizontal,
                  onPressed: (int index) {
                    // All buttons are selectable.
                    setState(() {
                      _selectedOptions[index] = !_selectedOptions[index];
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: MyColors.mountainMeadow,
                  selectedColor: Colors.white,
                  fillColor: Colors.blue[200],
                  color: Colors.blue[400],
                  isSelected: _selectedOptions,
                  children: options,
                ),
                SizedBox(
                  height: 40,
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
                          var id = uuid.v4();
                          List<int> temp1 = [];
                          if (_selectedSize[0])
                            temp1.add(0);
                          else if (_selectedSize[1])
                            temp1.add(1);
                          else if (_selectedSize[2]) temp1.add(2);
                          if (_selectedOptions[0]) temp1.add(3);
                          if (_selectedOptions[1]) temp1.add(4);
                          if (_selectedOptions[2]) temp1.add(5);
                          DatabaseService(uid: id).addParkingToDB(
                              widget.marker.longitude.toString(),
                              widget.marker.latitude.toString(),
                              temp1);
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        },
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Add parking',
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
                              'Cancel',
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
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
