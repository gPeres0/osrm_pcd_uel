// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osrm_pcd_uel/pages/rotation_page.dart';
import 'package:osrm_pcd_uel/services/route_service.dart';

class ListElement extends StatelessWidget {
  const ListElement({
    super.key,
    required this.name,
    required this.coordinates,
  });

  final String name;
  final ({double lat, double lon}) coordinates;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
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
    );
  }
}
