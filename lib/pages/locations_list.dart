import 'package:flutter/material.dart';
import 'package:osrm_pcd_uel/widgets/list_element.dart';
import 'package:osrm_pcd_uel/widgets/manual.dart';

class LocationsList extends StatelessWidget {
  const LocationsList({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [Manual()],),
      body: ListView(
        children: List.generate(
          places.length,
          (index) => ListElement(
              name: places[index].name,
              coordinates: (lat: places[index].lat, lon: places[index].lon)),
        ),
      ),
    );
  }
}
