import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Manual extends StatefulWidget {
  const Manual({super.key});

  @override
  State<Manual> createState() => _ManualState();
}

class _ManualState extends State<Manual> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("pt-BR");
    _flutterTts.speak(
        "Em sua tela está uma lista vertical de localizações da UEL, ao colocar seu dedo em uma delas será dito a você qual opção foi selecionada. Pressione novamente para gerar a rota da sua posição até seu destino. Você deverá girar seu telefone até que esteja apontando para a direção que deve seguir, isso será sinalizado com 3 vibrações e um efeito sonoro. Caminhe nessa direção até ser requisitado que gire novamente o celular, quando chegar ao destino receberá um áudio de chegada");
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 45,
      onPressed: () => _flutterTts.speak(
          "Em sua tela está uma lista vertical de localizações da UEL, ao colocar seu dedo em uma delas será dito a você qual opção foi selecionada. Pressione novamente para gerar a rota da sua posição até seu destino. Você deverá girar seu telefone até que esteja apontando para a direção que deve seguir, isso será sinalizado com 3 vibrações e um efeito sonoro. Caminhe nessa direção até ser requisitado que gire novamente o celular, quando chegar ao destino receberá um áudio de chegada"),
      icon: const Icon(Icons.question_mark),
      color: Colors.white,
    );
  }
}
