import 'package:flutter/material.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservaciones')),
      body: const SafeArea(
        child: Center(child: Text('Módulo base de reservaciones')),
      ),
    );
  }
}
