import 'package:flutter/material.dart';
import 'screens/pantalla_bienvenida.dart'; 

void main() {
  runApp(const TurnifyApp());
}

class TurnifyApp extends StatelessWidget {
  const TurnifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turnify',
      debugShowCheckedModeBanner: false,
      home: Pantalla1(),
    );
  }
}
