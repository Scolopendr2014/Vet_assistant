import 'package:flutter/material.dart';

class PatientDetailPage extends StatelessWidget {
  final String patientId;
  
  const PatientDetailPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация о пациенте'),
      ),
      body: Center(
        child: Text('Детали пациента: $patientId (будет реализовано)'),
      ),
    );
  }
}
