import 'package:flutter/material.dart';

class ExaminationCreatePage extends StatelessWidget {
  final String? patientId;
  
  const ExaminationCreatePage({super.key, this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать протокол'),
      ),
      body: Center(
        child: Text('Создание протокола (будет реализовано)'),
      ),
    );
  }
}
