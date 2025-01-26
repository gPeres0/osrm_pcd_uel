// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osrm_pcd_uel/pages/rotation_page.dart';
import 'package:osrm_pcd_uel/services/route_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ListElement extends StatelessWidget {
  ListElement({
    super.key,
    required this.name,
    required this.coordinates,
  });

  final String name;
  final ({double lat, double lon}) coordinates;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: Icon(
        Icons.arrow_forward,
        size: 18,
        color: Colors.blue[900],
      ),
      title: Text(
        name,
        style:
            const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      ),
      splashColor: Colors.lightBlue[50],
      onTap: () async {
        final position = await Geolocator.getCurrentPosition();
        final steps = await getSegmentsFromCoordinates(
            lat1: position.latitude,
            lon1: position.longitude,
            lat2: coordinates.lat,
            lon2: coordinates.lon);
        if (context.mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RotationPage(name: name, steps: steps),
              ));
        }
      },
      onLongPress: () => _flutterTts.speak(name),
    );
  }
}
