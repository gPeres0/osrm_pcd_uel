import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osrm_pcd_uel/pages/rotation_page.dart';
import 'package:osrm_pcd_uel/services/route_service.dart';
import 'package:audioplayers/audioplayers.dart';

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
  double? distanceInMeters;
  bool loading = false;
StreamSubscription<Position>? _positionStreamSubscription;
  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("pt-BR");
    _startLocationTracking();
    _flutterTts.speak('Siga em frente por ${distanceInMeters?.round()} metros');
  }

  void _startLocationTracking() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          widget.steps.first["end_point"].lat,
          widget.steps.first["end_point"].lon,
        );
      });
      _checkIfAtTargetLocation(position);
    });
  }

  void _checkIfAtTargetLocation(Position position) {
    if (distanceInMeters == null) {
      return;
    }
    if (distanceInMeters! <= _distanceThreshold) {
      _performAction();
    }
  }

  void _performAction() {
    // Ação a ser realizada quando o usuário chegar à localização alvo
    widget.steps.removeAt(0);
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
                  Text('Siga em frente por ${distanceInMeters?.round()} metros'),
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
                                    maintainState: false
                              ));
                        }
                      },
                      child: const Text('Recalcular rota'))
                ],
              ),
      ),
    );
  }
}
