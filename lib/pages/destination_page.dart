import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DestinationPage extends StatefulWidget {
  const DestinationPage({super.key});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  final FlutterTts flutterTts = FlutterTts();
  @override
  void initState() {
    super.initState();
    speakText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text(
          'Você chegou no seu destino',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Future<void> speakText() async {
    await flutterTts.setLanguage('pt-BR');
    await flutterTts.speak('Você chegou no seu destino');
  }
}
