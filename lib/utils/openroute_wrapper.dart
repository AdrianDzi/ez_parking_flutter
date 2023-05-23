import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OpenRouteWrapper {
  static String key = "5b3ce3597851110001cf624886"
      "540ce586ae4adbbcdef1d84929d548";
  static String directions_url =
      "https://api.openrouteservice.org/v2/directions/driving-car";
  static String matrix_url =
      "https://api.openrouteservice.org/v2/matrix/driving-car";

  static String geocode_url = "https://api.openrouteservice.org/geocode";

  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final response = await http.get(Uri.parse(
        '${directions_url}?api_key=${key}&start=${latlng_format_for_openroute(start)}&end=${latlng_format_for_openroute(end)}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      List<dynamic> coords =
          responseData["features"][0]["geometry"]["coordinates"];
      return coords.map((item) => LatLng(item[1], item[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }

  static Future<String> getGeocodeFromLatLng(LatLng position) async {
    final response = await http.get(Uri.parse(
        '${geocode_url}/reverse?api_key=${key}&point.lon=${position.longitude}&point.lat=${position.latitude}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      final address = responseData["features"][0]["properties"]["label"];
      return address;
    }

    throw Exception('Failed to get address');
  }

  static List<LatLng> getNearest(
      LatLng source, List<LatLng> destinations, int count) {
    destinations.sort((a, b) {
      if (distance(a, source) > distance(b, source)) {
        return 1;
      }
      return -1;
    });
    return destinations.take(count).toList();
  }

  static Future<LatLng> getCurrentPos() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(pos.latitude, pos.longitude);
  }

  static String latlng_format_for_openroute(LatLng value) {
    return "${value.longitude.toString()},${value.latitude.toString()}";
  }

  static double distance(LatLng latlng1, LatLng latlng2) {
    final lat1 = latlng1.latitude;
    final lon1 = latlng1.longitude;
    final lat2 = latlng2.latitude;
    final lon2 = latlng2.longitude;
    return acos(
            sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1)) *
        6371;
  }
}
