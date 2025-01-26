import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osrm_pcd_uel/pages/go_page.dart';
import 'package:osrm_pcd_uel/services/route_service.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class RotationPage extends StatefulWidget {
  const RotationPage({super.key, required this.name, required this.steps});

  final List<Map<String, dynamic>> steps;
  final String name;

  @override
  State<RotationPage> createState() => _RotationPageState();
}

class _RotationPageState extends State<RotationPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _targetAngle = 0;
  bool _isVibrating = false;
  bool _isTargetReached = false;
  Timer? _vibrationTimer;
  Timer? _intensityTimer;
  int _vibrationDuration = 0;
  bool loading = false;
  bool soundPlaying = false;
  StreamSubscription? vibrationListener;
  bool closed = false;

  @override
  void initState() {
    super.initState();
    _targetAngle = widget.steps.first['bearing_degrees'];
    _flutterTts.setLanguage("pt-BR");
    _startCompassListener();
    _flutterTts.speak('Gire seu celular até ele apitar três vezes');
  }

  void _startCompassListener() {
    vibrationListener = FlutterCompass.events!.listen((CompassEvent event) {
      final double? bearing = event.heading;

      if (bearing != null) {
        final double difference =
            _calculateAngleDifference(bearing, _targetAngle);

        if (difference < 30.0) {
          _adjustVibrationIntensity(difference);
        } else if (_isVibrating) {
          _stopVibration();
        }

        if (difference >= 30.0 && _isTargetReached) {
          _isTargetReached = false;
          _vibrationDuration = 0;
        }
      }
    });
  }

  double _calculateAngleDifference(double bearing, double targetAngle) {
    double difference = (bearing - targetAngle).abs();
    if (difference > 180.0) {
      difference = 360.0 - difference;
    }
    return difference;
  }

  void _adjustVibrationIntensity(double difference) {
    int intensity = ((30.0 - difference) / 30.0 * 255).toInt();
    int actualIntensity = 0;
    if (intensity > 200) {
      actualIntensity = 255;
    }

    if (!_isVibrating) {
      _startVibration(actualIntensity);
    } else {
      Vibration.vibrate(pattern: [0, 100], intensities: [actualIntensity]);
      if (intensity > 10) {
        _vibrationDuration += 100;
      } else {
        _vibrationDuration = 0;
      }
      print(_vibrationDuration);
      if (_vibrationDuration >= 1000) {
        if (_vibrationDuration >= 8000) {
          if (!closed) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GoPage(name: widget.name, steps: widget.steps),
                    maintainState: false));
          }
          closed = true;
        }
        _playPositiveSound();
      }
    }
  }

  void _startVibration(int intensity) {
    Vibration.vibrate(pattern: [0, 100], intensities: [intensity]);
    _isVibrating = true;
    _intensityTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      Vibration.vibrate(pattern: [0, 100], intensities: [intensity]);
    });
  }

  void _stopVibration() {
    Vibration.cancel();
    _isVibrating = false;
    _vibrationDuration = 0;
    _intensityTimer?.cancel();
  }

  void _playPositiveSound() async {
    _isTargetReached = true;
    if (soundPlaying) return;
    soundPlaying = true;
    await _audioPlayer.play(AssetSource('success_sound.mp3'));
    soundPlaying = false;
    //_stopVibration();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
    _vibrationTimer?.cancel();
    _intensityTimer?.cancel();
    vibrationListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name} - Tela de rotação'),
      ),
      body: Center(
        child: loading
            ? CircularProgressIndicator(
                color: Colors.blue[900],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 17.0,
                      ),
                      'Gire seu celular até ele apitar três vezes'),
                  ElevatedButton(
                      style: const ButtonStyle(
                        shape: WidgetStatePropertyAll(CircleBorder(
                          eccentricity: 1.0,
                        )),
                        elevation: WidgetStatePropertyAll(0),
                        alignment: Alignment.center,
                        padding: WidgetStatePropertyAll(EdgeInsets.only(
                            top: 115, bottom: 115, left: 20, right: 20)),
                      ),
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
                              ));
                        }
                      },
                      child: Text(
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 40.0,
                              color: Colors.blue[900]),
                          'Recalcular rota'))
                ],
              ),
      ),
    );
  }
}
