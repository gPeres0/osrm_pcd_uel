import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osrm_pcd_uel/pages/rotation_page.dart';
import 'package:osrm_pcd_uel/services/route_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  static const List<({String name, double lat, double lon})> places = [
    (name: 'Restaurante Universitário', lat: -23.32538, lon: -51.20182),
    (name: 'Departamento de Computação', lat: -23.32648, lon: -51.20155),
    (name: 'Cesa', lat: -23.32633, lon: -51.20470),
    (name: 'Departamento de Física', lat: -23.32646, lon: -51.20245),
    (name: 'Departamento de Estatística', lat: -23.32670, lon: -51.20221),
    (name: 'Departamento de Estatística', lat: -23.32670, lon: -51.20221),
    (name: 'Departamento de Geociências', lat: -23.32673, lon: -51.20155),
    (name: 'Biblioteca Central', lat: -23.32637, lon: -51.20049),
    (
      name: 'Departamento de Engenharia Elétrica',
      lat: -23.32730,
      lon: -51.20137
    )
  ];

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<Map<String, dynamic>>? steps;
  bool _locationPermissionGranted = false;
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    getLocation();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    setState(() {
      _locationPermissionGranted =
          permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always;
    });

    if (!_locationPermissionGranted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão Negada'),
        content: const Text(
            'Para usar este aplicativo, você precisa permitir o acesso à sua localização.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void getLocation() async {
    const ({double lat, double lon}) destination =
        (lat: -23.32538, lon: -51.20182);
    final curPosition = (await Geolocator.getCurrentPosition());
    final tempSteps = await getSegmentsFromCoordinates(
        lat1: curPosition.latitude,
        lon1: curPosition.longitude,
        lat2: destination.lat,
        lon2: destination.lon);
    setState(() {
      steps = tempSteps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: steps == null
          ? const Center(child: CircularProgressIndicator())
          : RotationPage(
              name: 'Lugar',
              steps: steps!,
            ),
    );
  }
}
