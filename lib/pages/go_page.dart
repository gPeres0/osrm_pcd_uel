import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osrm_pcd_uel/pages/destination_page.dart';
import 'package:osrm_pcd_uel/pages/rotation_page.dart';
import 'package:osrm_pcd_uel/services/polyline_utility.dart';
import 'package:osrm_pcd_uel/services/route_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:signals/signals_flutter.dart';

class GoPage extends StatefulWidget {
  const GoPage({super.key, required this.name, required this.steps});

  final List<Map<String, dynamic>> steps;
  final String name;

  @override
  State<GoPage> createState() => _GoPageState();
}

class _GoPageState extends State<GoPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final double _distanceThreshold = 10.0;
  final distanceInMeters = signal(-1.0, autoDispose: true);
  bool loading = false;
  Timer? timer;
  bool timerOver = false;

  StreamSubscription<Position>? _positionStreamSubscription;
  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("pt-BR");
    _startLocationTracking();
  }

  void _startLocationTracking() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      distanceInMeters.value = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.steps.first["end_point"].lat,
        widget.steps.first["end_point"].lon,
      );
      timer ??= Timer(
        Duration(seconds: distanceInMeters.value.round()),
        () => setState(() {
          timerOver = true;
        }),
      );
      _checkIfAtTargetLocation(position);
    });
  }

  void _checkIfAtTargetLocation(Position position) {
    if (distanceInMeters.value < 0) {
      return;
    }
    if (!timerOver) {
      return;
    }
    if (distanceInMeters.value <= _distanceThreshold) {
      _performAction(position);
    }
  }

  void _performAction(Position position) {
    // Ação a ser realizada quando o usuário chegar à localização alvo
    widget.steps.removeAt(0);
    if (widget.steps.isEmpty) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DestinationPage(),
          ));
    }
    widget.steps.first['start_point'] =
        (lat: position.latitude, lon: position.longitude);
    widget.steps.first['bearing_degrees'] = calculateBearing(position.latitude, position.longitude, widget.steps.first['end_point'].lat, widget.steps.first['end_point'].lon);
    widget.steps.first['distance_meters'] = haversineDistance(position.latitude, position.longitude, widget.steps.first['end_point'].lat, widget.steps.first['end_point'].lon);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RotationPage(name: widget.name, steps: widget.steps),
        ));
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
    _positionStreamSubscription?.cancel();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  Text(
                      'Siga em frente por ${distanceInMeters.watch(context).round()} metros'),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        final ({double lat, double lon}) destination =
                            widget.steps.last['end_point'];
                        final curPosition =
                            (await Geolocator.getCurrentPosition());
                        final steps = await getSegmentsFromCoordinates(
                            lat1: curPosition.latitude,
                            lon1: curPosition.longitude,
                            lat2: destination.lat,
                            lon2: destination.lon);
                        if (context.mounted) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RotationPage(
                                      name: widget.name, steps: steps),
                                  maintainState: false));
                        }
                      },
                      child: const Text('Recalcular rota'))
                ],
              ),
      ),
    );
  }
}
